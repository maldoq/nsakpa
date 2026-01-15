from django.db import transaction
from django.utils import timezone
from decimal import Decimal
import uuid
import logging

from .models import Order, OrderItem
from products.models import Product

logger = logging.getLogger(__name__)


class PaymentService:
    """Service de gestion des paiements"""
    
    # Frais de transaction par méthode de paiement
    TRANSACTION_FEES = {
        'orange_money': Decimal('0.02'),  # 2%
        'mtn_momo': Decimal('0.02'),
        'wave': Decimal('0.01'),  # 1%
        'card': Decimal('0.025'),  # 2.5%
        'delivery': Decimal('0'),  # Pas de frais
    }
    
    @classmethod
    @transaction.atomic
    def create_order_from_cart(cls, user, cart_items, delivery_address, delivery_phone, payment_method='orange_money', note=''):
        """
        Crée une commande à partir du panier
        Vérifie et décrémente le stock de manière atomique
        """
        if not cart_items:
            raise ValueError("Le panier est vide")
        
        # Créer la commande
        order = Order.objects.create(
            buyer=user,
            delivery_address=delivery_address,
            delivery_phone=delivery_phone,
            payment_method=payment_method,
            note=note,
            total_amount=0,
        )
        
        total = Decimal('0')
        
        for item_data in cart_items:
            product_id = item_data.get('product_id') or item_data.get('id')
            quantity = int(item_data.get('quantity', 1))
            
            # Verrouiller le produit pour éviter les conflits de stock
            try:
                product = Product.objects.select_for_update().get(id=product_id)
            except Product.DoesNotExist:
                raise ValueError(f"Produit {product_id} introuvable")
            
            # Vérifier le stock
            if product.stock < quantity:
                raise ValueError(
                    f"Stock insuffisant pour '{product.name}'. "
                    f"Disponible: {product.stock}, Demandé: {quantity}"
                )
            
            # Décrémenter le stock
            product.stock -= quantity
            product.save()
            
            # Créer l'item de commande
            unit_price = product.price
            OrderItem.objects.create(
                order=order,
                product=product,
                product_name=product.name,
                quantity=quantity,
                unit_price=unit_price,
                artisan=product.artisan,
            )
            
            total += unit_price * quantity
            
            logger.info(
                f"Stock décrémenté pour {product.name}: "
                f"{product.stock + quantity} -> {product.stock}"
            )
        
        # Mettre à jour le total
        order.total_amount = total
        order.save()
        
        return order
    
    @classmethod
    @transaction.atomic
    def process_payment(cls, order, payment_method, phone_number=None):
        """
        Traite le paiement d'une commande
        """
        if order.is_paid:
            raise ValueError("Cette commande est déjà payée")
        
        # Simuler l'appel à l'API du provider de paiement
        payment_result = cls._call_payment_provider(
            order=order,
            payment_method=payment_method,
            phone_number=phone_number
        )
        
        if payment_result['success']:
            order.is_paid = True
            order.status = Order.Status.PAID
            order.transaction_id = payment_result['transaction_id']
            order.payment_method = payment_method
            order.paid_at = timezone.now()
            order.save()
            
            # Notifier l'artisan (à implémenter)
            cls._notify_artisans(order)
            
            logger.info(f"Paiement réussi pour commande #{order.id}")
            return payment_result
        else:
            raise ValueError(payment_result.get('error', 'Échec du paiement'))
    
    @classmethod
    def _call_payment_provider(cls, order, payment_method, phone_number=None):
        """
        Simule l'appel à l'API du provider de paiement
        En production, remplacer par les vrais appels API
        """
        # SIMULATION - En production, intégrer les vrais providers
        # Orange Money, MTN MoMo, Wave, etc.
        
        transaction_id = f"TXN_{uuid.uuid4().hex[:12].upper()}"
        
        # Simuler un délai de traitement
        import time
        time.sleep(0.5)
        
        # Simuler un succès (90% de chance)
        import random
        if random.random() > 0.1:
            return {
                'success': True,
                'transaction_id': transaction_id,
                'message': 'Paiement effectué avec succès',
                'provider_response': {
                    'status': 'SUCCESSFUL',
                    'reference': transaction_id,
                }
            }
        else:
            return {
                'success': False,
                'error': 'Transaction refusée par le provider',
            }
    
    @classmethod
    def _notify_artisans(cls, order):
        """Notifie les artisans d'une nouvelle commande"""
        artisan_ids = set()
        for item in order.items.all():
            if item.artisan_id:
                artisan_ids.add(item.artisan_id)
        
        # TODO: Envoyer des notifications (SMS, email, push)
        logger.info(f"Notification envoyée aux artisans: {artisan_ids}")
    
    @classmethod
    @transaction.atomic
    def cancel_order(cls, order, reason=''):
        """
        Annule une commande et restaure le stock
        """
        if not order.can_be_cancelled:
            raise ValueError(
                f"Impossible d'annuler une commande au statut '{order.get_status_display()}'"
            )
        
        # Restaurer le stock
        order.restore_stock()
        
        # Mettre à jour le statut
        order.status = Order.Status.CANCELLED
        order.note = f"{order.note}\nAnnulation: {reason}" if order.note else f"Annulation: {reason}"
        order.save()
        
        # Si déjà payé, initier un remboursement
        if order.is_paid:
            cls._process_refund(order)
        
        logger.info(f"Commande #{order.id} annulée. Stock restauré.")
        return order
    
    @classmethod
    def _process_refund(cls, order):
        """Traite le remboursement d'une commande"""
        # TODO: Implémenter le remboursement via les APIs des providers
        order.status = Order.Status.REFUNDED
        order.save()
        logger.info(f"Remboursement initié pour commande #{order.id}")
    
    @classmethod
    @transaction.atomic
    def release_escrow(cls, order):
        """
        Libère l'escrow pour payer les artisans
        Appelé quand l'acheteur confirme la réception
        """
        if order.escrow_released:
            raise ValueError("L'escrow a déjà été libéré")
        
        if order.status != Order.Status.DELIVERED:
            raise ValueError("La commande doit être livrée pour libérer l'escrow")
        
        order.escrow_released = True
        order.escrow_released_at = timezone.now()
        order.save()
        
        # TODO: Transférer les fonds aux artisans
        logger.info(f"Escrow libéré pour commande #{order.id}")
        return order