# orders/views.py
from products.models import Product
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db import transaction
from .models import Order, OrderItem
from .serializers import OrderSerializer

class OrderViewSet(viewsets.ModelViewSet):
    queryset = Order.objects.all()
    serializer_class = OrderSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Order.objects.filter(buyer=self.request.user)

    @transaction.atomic
    def create(self, request, *args, **kwargs):
        user = request.user

        items_data = request.data.get('items', [])
        delivery_address = request.data.get('delivery_address')
        delivery_phone = request.data.get('delivery_phone')
        payment_method = request.data.get('payment_method', 'orange_money')

        if not items_data:
            return Response(
                {"error": "Le panier est vide"},
                status=status.HTTP_400_BAD_REQUEST
            )

        # 1️⃣ Créer la commande vide
        order = Order.objects.create(
            buyer=user,
            delivery_address=delivery_address,
            delivery_phone=delivery_phone,
            payment_method=payment_method,
            total_amount=0,
        )

        total = 0

        # 2️⃣ Créer les items
        for item in items_data:
            product_id = item.get('product_id')
            quantity = int(item.get('quantity', 1))

            try:
                product = Product.objects.get(id=product_id)
            except Product.DoesNotExist:
                transaction.set_rollback(True)
                return Response(
                    {"error": f"Produit {product_id} introuvable"},
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Vérifier le stock
            if product.stock < quantity:
                transaction.set_rollback(True)
                return Response(
                    {"error": f"Stock insuffisant pour {product.name}"},
                    status=status.HTTP_400_BAD_REQUEST
                )

            unit_price = product.price
            line_total = unit_price * quantity
            total += line_total

            OrderItem.objects.create(
                order=order,
                product=product,
                product_name=product.name,
                quantity=quantity,
                unit_price=unit_price,
                artisan=product.artisan,
            )

            # Décrémenter le stock
            product.stock -= quantity
            product.save()

        # 3️⃣ Mettre à jour le total
        order.total_amount = total
        order.save()

        # 4️⃣ Retourner la commande complète
        serializer = self.get_serializer(order)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    @action(detail=False, methods=['get'], url_path='my')
    def my_orders(self, request):
        """GET /api/orders/my/?limit=3"""
        user = request.user
        qs = Order.objects.filter(buyer=user).order_by('-created_at')

        limit = request.query_params.get('limit')
        if limit:
            try:
                qs = qs[:int(limit)]
            except ValueError:
                pass

        serializer = self.get_serializer(qs, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['post'], url_path='pay')
    def pay_order(self, request):
        """
        POST /api/orders/pay/
        Body: {
            "order_id": "123",
            "payment_method": "orange_money",
            "phone_number": "0700000000"
        }
        """
        user = request.user
        order_id = request.data.get('order_id')
        payment_method = request.data.get('payment_method')
        phone_number = request.data.get('phone_number')

        if not order_id:
            return Response(
                {"error": "order_id requis"},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            order = Order.objects.get(id=order_id, buyer=user)
        except Order.DoesNotExist:
            return Response(
                {"error": "Commande introuvable"},
                status=status.HTTP_404_NOT_FOUND
            )

        # Vérifier que la commande n'est pas déjà payée
        if order.is_paid:
            return Response(
                {"error": "Cette commande est déjà payée"},
                status=status.HTTP_400_BAD_REQUEST
            )

        # 🔥 SIMULATION DE PAIEMENT
        # Dans un vrai système, ici vous appelleriez l'API du provider
        # (Orange Money, MTN, Wave, etc.)
        
        # Pour l'instant, on simule un paiement réussi
        import uuid
        transaction_id = f"TXN_{uuid.uuid4().hex[:12].upper()}"
        
        # Mettre à jour la commande
        order.is_paid = True
        order.status = Order.Status.PAID
        order.transaction_id = transaction_id
        order.payment_method = payment_method
        order.save()

        return Response({
            "success": True,
            "message": "Paiement effectué avec succès",
            "transaction_id": transaction_id,
            "order": OrderSerializer(order).data
        })

    @action(detail=True, methods=['post'], url_path='confirm-delivery')
    def confirm_delivery(self, request, pk=None):
        """
        POST /api/orders/{id}/confirm-delivery/
        Permet au buyer de confirmer la réception
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
        
        order.status = Order.Status.DELIVERED
        order.save()
        
        return Response({
            "success": True,
            "message": "Livraison confirmée"
        })

    @action(detail=True, methods=['post'], url_path='cancel')
    def cancel_order(self, request, pk=None):
        """
        POST /api/orders/{id}/cancel/
        Annuler une commande
        """
        order = self.get_object()
        
        if order.buyer != request.user:
            return Response(
                {"error": "Non autorisé"},
                status=status.HTTP_403_FORBIDDEN
            )
        
        if order.status in [Order.Status.DELIVERED, Order.Status.CANCELLED]:
            return Response(
                {"error": "Impossible d'annuler cette commande"},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        order.status = Order.Status.CANCELLED
        order.save()
        
        # Remettre le stock
        for item in order.items.all():
            if item.product:
                item.product.stock += item.quantity
                item.product.save()
        
        return Response({
            "success": True,
            "message": "Commande annulée"
        })