# orders/views.py
from products.models import Product
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db import transaction
from django.utils import timezone
from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from django.views.decorators.http import require_POST
from django.views.decorators.csrf import csrf_protect
from django.http import JsonResponse
from django.contrib import messages
import json
import logging

from .models import Order, OrderItem
from users.models import Address  # Correction: Address est dans users.models
from .serializers import OrderSerializer, OrderItemSerializer
from .services import PaymentService

logger = logging.getLogger(__name__)


class OrderViewSet(viewsets.ModelViewSet):
    serializer_class = OrderSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role == 'artisan':
            # Artisan voit les commandes contenant ses produits
            return Order.objects.filter(
                items__artisan=user
            ).distinct().order_by('-created_at')
        else:
            # Acheteur voit ses propres commandes
            return Order.objects.filter(buyer=user).order_by('-created_at')

    @transaction.atomic
    def create(self, request, *args, **kwargs):
        """
        POST /api/orders/
        Crée une commande à partir du panier
        """
        user = request.user
        items_data = request.data.get('items', [])
        delivery_address = request.data.get('delivery_address')
        delivery_phone = request.data.get('delivery_phone')
        payment_method = request.data.get('payment_method', 'orange_money')
        note = request.data.get('note', '')

        if not items_data:
            return Response(
                {"error": "Le panier est vide"},
                status=status.HTTP_400_BAD_REQUEST
            )

        if not delivery_address or not delivery_phone:
            return Response(
                {"error": "Adresse et téléphone de livraison requis"},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            order = PaymentService.create_order_from_cart(
                user=user,
                cart_items=items_data,
                delivery_address=delivery_address,
                delivery_phone=delivery_phone,
                payment_method=payment_method,
                note=note,
            )
            
            return Response({
                "success": True,
                "message": "Commande créée avec succès",
                "order": OrderSerializer(order).data
            }, status=status.HTTP_201_CREATED)
            
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            return Response(
                {"error": f"Erreur lors de la création de la commande: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    @action(detail=False, methods=['post'], url_path='pay')
    def pay_order(self, request):
        """
        POST /api/orders/pay/
        Traite le paiement d'une commande
        """
        order_id = request.data.get('order_id')
        payment_method = request.data.get('payment_method', 'orange_money')
        phone_number = request.data.get('phone_number')

        if not order_id:
            return Response(
                {"error": "order_id requis"},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            order = Order.objects.get(id=order_id, buyer=request.user)
        except Order.DoesNotExist:
            return Response(
                {"error": "Commande introuvable"},
                status=status.HTTP_404_NOT_FOUND
            )

        try:
            result = PaymentService.process_payment(
                order=order,
                payment_method=payment_method,
                phone_number=phone_number
            )
            
            return Response({
                "success": True,
                "message": "Paiement effectué avec succès",
                "transaction_id": result['transaction_id'],
                "order": OrderSerializer(order).data
            })
            
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )

    @action(detail=True, methods=['post'], url_path='cancel')
    def cancel_order(self, request, pk=None):
        """
        POST /api/orders/{id}/cancel/
        Annule une commande et restaure le stock
        """
        order = self.get_object()
        
        if order.buyer != request.user:
            return Response(
                {"error": "Non autorisé"},
                status=status.HTTP_403_FORBIDDEN
            )

        reason = request.data.get('reason', 'Annulation par le client')

        try:
            order = PaymentService.cancel_order(order, reason)
            return Response({
                "success": True,
                "message": "Commande annulée avec succès",
                "order": OrderSerializer(order).data
            })
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )

    @action(detail=True, methods=['post'], url_path='confirm-delivery')
    def confirm_delivery(self, request, pk=None):
        """
        POST /api/orders/{id}/confirm-delivery/
        Confirme la réception et libère l'escrow
        """
        order = self.get_object()
        
        if order.buyer != request.user:
            return Response(
                {"error": "Non autorisé"},
                status=status.HTTP_403_FORBIDDEN
            )
        
        if order.status != Order.Status.DELIVERING:
            return Response(
                {"error": "La commande n'est pas en livraison"},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            order.status = Order.Status.DELIVERED
            order.save()
            
            # Libérer l'escrow pour payer les artisans
            PaymentService.release_escrow(order)
            
            return Response({
                "success": True,
                "message": "Livraison confirmée. Les artisans seront payés.",
                "order": OrderSerializer(order).data
            })
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )

    @action(detail=True, methods=['post'], url_path='update-status')
    def update_status(self, request, pk=None):
        """
        POST /api/orders/{id}/update-status/
        Met à jour le statut (pour les artisans)
        """
        order = self.get_object()
        new_status = request.data.get('status')
        
        # Vérifier que l'utilisateur est artisan de cette commande
        if request.user.role != 'artisan':
            return Response(
                {"error": "Réservé aux artisans"},
                status=status.HTTP_403_FORBIDDEN
            )
        
        valid_transitions = {
            Order.Status.PAID: [Order.Status.PREPARING],
            Order.Status.PREPARING: [Order.Status.DELIVERING],
        }
        
        allowed = valid_transitions.get(order.status, [])
        if new_status not in allowed:
            return Response(
                {"error": f"Transition de statut non autorisée"},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        order.status = new_status
        order.save()
        
        return Response({
            "success": True,
            "message": f"Statut mis à jour: {order.get_status_display()}",
            "order": OrderSerializer(order).data
        })


class PaymentMethodViewSet(viewsets.ViewSet):
    """
    Liste les méthodes de paiement disponibles
    """
    
    def list(self, request):
        methods = [
            {
                'code': 'orange_money',
                'name': 'Orange Money',
                'icon': 'orange_money',
                'description': 'Paiement via Orange Money',
                'available': True,
            },
            {
                'code': 'mtn_momo',
                'name': 'MTN Mobile Money',
                'icon': 'mtn_momo',
                'description': 'Paiement via MTN MoMo',
                'available': True,
            },
            {
                'code': 'wave',
                'name': 'Wave',
                'icon': 'wave',
                'description': 'Paiement via Wave',
                'available': True,
            },
            {
                'code': 'card',
                'name': 'Carte bancaire',
                'icon': 'credit_card',
                'description': 'Visa, Mastercard',
                'available': False,  # Pas encore disponible
            },
            {
                'code': 'delivery',
                'name': 'Paiement à la livraison',
                'icon': 'cash',
                'description': 'Payez en espèces à la réception',
                'available': True,
            },
        ]
        return Response(methods)


@login_required
def payment(request):
    """Page de paiement"""
    cart = request.session.get('cart', {})
    
    if not cart:
        messages.warning(request, "Votre panier est vide.")
        return redirect('website:cart')
    
    # Calculer les totaux
    cart_items = []
    subtotal = 0
    
    for product_id, item in cart.items():
        try:
            product = Product.objects.get(pk=product_id)
            item_total = product.price * item['quantity']
            cart_items.append({
                'product': product,
                'quantity': item['quantity'],
                'total': item_total,
                'options': item.get('options', {})
            })
            subtotal += item_total
        except Product.DoesNotExist:
            continue
    
    # Frais de livraison (exemple: gratuit au-dessus de 50000 FCFA)
    shipping_cost = 0 if subtotal >= 50000 else 2500
    total = subtotal + shipping_cost
    
    # Récupérer les adresses de l'utilisateur
    try:
        user_addresses = Address.objects.filter(user=request.user)
    except:
        user_addresses = []
    
    context = {
        'cart_items': cart_items,
        'subtotal': subtotal,
        'shipping_cost': shipping_cost,
        'total': total,
        'user_addresses': user_addresses,
    }
    
    return render(request, 'website/payment.html', context)


@login_required
@require_POST
def process_payment(request):
    """Traiter le paiement et créer la commande"""
    cart = request.session.get('cart', {})
    
    if not cart:
        return JsonResponse({'success': False, 'error': 'Panier vide'}, status=400)
    
    try:
        # Récupérer les données du formulaire
        data = json.loads(request.body) if request.content_type == 'application/json' else request.POST
        
        payment_method = data.get('payment_method', 'card')
        
        # Informations de livraison
        shipping_data = {
            'first_name': data.get('shipping_first_name', request.user.first_name),
            'last_name': data.get('shipping_last_name', request.user.last_name),
            'email': data.get('shipping_email', request.user.email),
            'phone': data.get('shipping_phone', getattr(request.user, 'phone', '')),
            'address': data.get('shipping_address', ''),
            'city': data.get('shipping_city', ''),
            'postal_code': data.get('shipping_postal_code', ''),
            'country': data.get('shipping_country', 'Côte d\'Ivoire'),
        }
        
        # Vérifier le stock avant de procéder
        stock_errors = []
        cart_items = []
        subtotal = 0
        
        for product_id, item in cart.items():
            try:
                product = Product.objects.select_for_update().get(pk=product_id)
                quantity = item['quantity']
                
                if product.stock < quantity:
                    stock_errors.append({
                        'product': product.name,
                        'requested': quantity,
                        'available': product.stock
                    })
                else:
                    item_total = product.price * quantity
                    cart_items.append({
                        'product': product,
                        'quantity': quantity,
                        'price': product.price,
                        'total': item_total,
                        'options': item.get('options', {})
                    })
                    subtotal += item_total
            except Product.DoesNotExist:
                stock_errors.append({
                    'product': f'Produit #{product_id}',
                    'error': 'Produit introuvable'
                })
        
        if stock_errors:
            return JsonResponse({
                'success': False,
                'error': 'Stock insuffisant',
                'stock_errors': stock_errors
            }, status=400)
        
        # Calculer les frais et le total
        shipping_cost = 0 if subtotal >= 50000 else 2500
        total = subtotal + shipping_cost
        
        # Créer la commande
        with transaction.atomic():
            # Générer un numéro de commande unique
            import uuid
            order_number = f"NSK-{uuid.uuid4().hex[:8].upper()}"
            
            order = Order.objects.create(
                order_number=order_number,
                buyer=request.user,
                status='pending',
                subtotal=subtotal,
                shipping_cost=shipping_cost,
                total_amount=total,  # CORRECTION ICI: total_amount au lieu de total
                payment_method=payment_method,
                payment_status='pending',
                shipping_first_name=shipping_data['first_name'],
                shipping_last_name=shipping_data['last_name'],
                shipping_email=shipping_data['email'],
                shipping_phone=shipping_data['phone'],
                shipping_address=shipping_data['address'],
                shipping_city=shipping_data['city'],
                shipping_postal_code=shipping_data['postal_code'],
                shipping_country=shipping_data['country'],
            )
            
            # Créer les items de commande et diminuer le stock
            for item in cart_items:
                product = item['product']
                quantity = item['quantity']
                
                OrderItem.objects.create(
                    order=order,
                    product=product,
                    quantity=quantity,
                    price=item['price'],
                    total=item['total'],
                    options=item.get('options', {})
                )
                
                # DIMINUER LE STOCK
                product.stock -= quantity
                product.save(update_fields=['stock'])
                
                logger.info(f"Stock mis à jour pour {product.name}: -{quantity} (nouveau stock: {product.stock})")
            
            # Simuler le traitement du paiement selon la méthode
            payment_success = simulate_payment(payment_method, total, data)
            
            if payment_success:
                order.payment_status = 'completed'
                order.status = 'paid'
                order.save()
                
                # Vider le panier
                request.session['cart'] = {}
                request.session.modified = True
                
                return JsonResponse({
                    'success': True,
                    'order_id': order.id,
                    'order_number': order.order_number,
                    'redirect_url': f'/confirmation/?order={order.order_number}'
                })
            else:
                # Annuler la commande et restaurer le stock
                for item in cart_items:
                    product = item['product']
                    product.stock += item['quantity']
                    product.save(update_fields=['stock'])
                
                order.payment_status = 'failed'
                order.status = 'cancelled'
                order.save()
                
                return JsonResponse({
                    'success': False,
                    'error': 'Le paiement a échoué. Veuillez réessayer.'
                }, status=400)
    
    except json.JSONDecodeError:
        return JsonResponse({'success': False, 'error': 'Données invalides'}, status=400)
    except Exception as e:
        logger.error(f"Erreur lors du paiement: {str(e)}")
        return JsonResponse({'success': False, 'error': str(e)}, status=500)


def simulate_payment(payment_method, amount, data):
    """
    Simuler le traitement du paiement
    En production, intégrer avec les vrais services de paiement
    """
    # Pour la démo, on simule un succès
    # En production, intégrer:
    # - Orange Money API
    # - MTN MoMo API
    # - Stripe/PayPal pour cartes
    
    if payment_method == 'orange_money':
        phone = data.get('mobile_phone', '')
        # Intégrer Orange Money API ici
        return True
    
    elif payment_method == 'mtn_momo':
        phone = data.get('mobile_phone', '')
        # Intégrer MTN MoMo API ici
        return True
    
    elif payment_method == 'card':
        # Intégrer Stripe/autre gateway ici
        card_number = data.get('card_number', '')
        # Validation basique pour la démo
        return True
    
    elif payment_method == 'cash_on_delivery':
        # Paiement à la livraison - toujours accepté
        return True
    
    return False


@login_required
def confirmation(request):
    """Page de confirmation de commande"""
    order_number = request.GET.get('order')
    
    if not order_number:
        messages.error(request, "Numéro de commande manquant.")
        return redirect('website:home')
    
    try:
        order = Order.objects.get(order_number=order_number, buyer=request.user)
        order_items = order.items.all()
        
        context = {
            'order': order,
            'order_items': order_items,
        }
        return render(request, 'website/confirmation.html', context)
    
    except Order.DoesNotExist:
        messages.error(request, "Commande introuvable.")
        return redirect('website:home')


@login_required
def check_stock(request):
    """Vérifier la disponibilité du stock (API AJAX)"""
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            product_id = data.get('product_id')
            quantity = data.get('quantity', 1)
            
            product = Product.objects.get(pk=product_id)
            
            return JsonResponse({
                'available': product.stock >= quantity,
                'stock': product.stock,
                'product_name': product.name
            })
        except Product.DoesNotExist:
            return JsonResponse({'available': False, 'error': 'Produit introuvable'}, status=404)
        except Exception as e:
            return JsonResponse({'available': False, 'error': str(e)}, status=500)
    
    return JsonResponse({'error': 'Méthode non autorisée'}, status=405)