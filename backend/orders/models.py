# orders/models.py
from django.db import models
from django.conf import settings
import uuid

class Order(models.Model):
    class Status(models.TextChoices):
        PENDING = 'pending', 'En attente'
        PAID = 'paid', 'Payé'
        PREPARING = 'preparing', 'En préparation'
        DELIVERING = 'delivering', 'En livraison'
        DELIVERED = 'delivered', 'Livré'
        CANCELLED = 'cancelled', 'Annulé'
        REFUNDED = 'refunded', 'Remboursé'

    class PaymentMethod(models.TextChoices):
        ORANGE_MONEY = 'orange_money', 'Orange Money'
        MTN_MOMO = 'mtn_momo', 'MTN Mobile Money'
        WAVE = 'wave', 'Wave'
        CARD = 'card', 'Carte bancaire'
        CASH_ON_DELIVERY = 'delivery', 'Paiement à la livraison'

    class PaymentStatus(models.TextChoices):
        PENDING = 'pending', 'En attente'
        COMPLETED = 'completed', 'Payé'
        FAILED = 'failed', 'Échoué'
        REFUNDED = 'refunded', 'Remboursé'

    # Numéro de commande unique
    order_number = models.CharField(max_length=20, unique=True, blank=True)
    
    buyer = models.ForeignKey(
        settings.AUTH_USER_MODEL, 
        on_delete=models.CASCADE, 
        related_name='orders'
    )
    status = models.CharField(
        max_length=20, 
        choices=Status.choices, 
        default=Status.PENDING
    )
    
    # Montants
    subtotal = models.DecimalField(max_digits=12, decimal_places=0, default=0)
    shipping_cost = models.DecimalField(max_digits=12, decimal_places=0, default=0)
    tax_amount = models.DecimalField(max_digits=12, decimal_places=0, default=0)
    total_amount = models.DecimalField(max_digits=12, decimal_places=0)
    
    # Adresse de livraison (ancienne méthode - texte)
    delivery_address = models.TextField(blank=True, default='')
    delivery_phone = models.CharField(max_length=20, blank=True, default='')
    
    # Nouveaux champs d'adresse de livraison
    shipping_first_name = models.CharField(max_length=100, blank=True, default='')
    shipping_last_name = models.CharField(max_length=100, blank=True, default='')
    shipping_email = models.EmailField(blank=True, default='')
    shipping_phone = models.CharField(max_length=20, blank=True, default='')
    shipping_address = models.TextField(blank=True, default='')
    shipping_city = models.CharField(max_length=100, blank=True, default='')
    shipping_postal_code = models.CharField(max_length=20, blank=True, default='')
    shipping_country = models.CharField(max_length=100, default='Côte d\'Ivoire')
    
    # Adresse de facturation (optionnel)
    billing_first_name = models.CharField(max_length=100, blank=True, default='')
    billing_last_name = models.CharField(max_length=100, blank=True, default='')
    billing_email = models.EmailField(blank=True, default='')
    billing_phone = models.CharField(max_length=20, blank=True, default='')
    billing_address = models.TextField(blank=True, default='')
    billing_city = models.CharField(max_length=100, blank=True, default='')
    billing_postal_code = models.CharField(max_length=20, blank=True, default='')
    billing_country = models.CharField(max_length=100, default='Côte d\'Ivoire')
    
    note = models.TextField(blank=True, null=True)
    
    # Paiement
    payment_method = models.CharField(
        max_length=50, 
        choices=PaymentMethod.choices,
        default=PaymentMethod.ORANGE_MONEY
    )
    payment_status = models.CharField(
        max_length=20,
        choices=PaymentStatus.choices,
        default=PaymentStatus.PENDING
    )
    transaction_id = models.CharField(max_length=100, blank=True, null=True)
    is_paid = models.BooleanField(default=False)
    paid_at = models.DateTimeField(blank=True, null=True)
    
    # Livraison
    tracking_number = models.CharField(max_length=100, blank=True, null=True)
    estimated_delivery_date = models.DateField(blank=True, null=True)
    
    # Dates
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"Commande #{self.order_number or self.id} - {self.buyer.username}"

    def save(self, *args, **kwargs):
        # Générer un numéro de commande si non défini
        if not self.order_number:
            self.order_number = f"NSK-{uuid.uuid4().hex[:8].upper()}"
        
        # Calculer total_amount si non défini
        if not self.total_amount:
            self.total_amount = self.subtotal + self.shipping_cost + self.tax_amount
            
        super().save(*args, **kwargs)

    @property
    def shipping_address_text(self):
        """Retourne l'adresse de livraison formatée"""
        parts = [
            f"{self.shipping_first_name} {self.shipping_last_name}".strip(),
            self.shipping_address,
            f"{self.shipping_postal_code} {self.shipping_city}".strip(),
            self.shipping_country,
            self.shipping_phone,
        ]
        return '\n'.join(filter(None, parts))

    @property
    def customer(self):
        """Alias pour buyer pour la compatibilité avec les templates"""
        return self.buyer


class OrderItem(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='items')
    product = models.ForeignKey('products.Product', on_delete=models.SET_NULL, null=True)
    product_name = models.CharField(max_length=255, blank=True)  # Sauvegarde du nom
    product_sku = models.CharField(max_length=50, blank=True)
    quantity = models.PositiveIntegerField(default=1)
    price = models.DecimalField(max_digits=12, decimal_places=0)  # Prix unitaire
    total = models.DecimalField(max_digits=12, decimal_places=0, default=0)  # Prix total ligne
    options = models.JSONField(default=dict, blank=True)  # Options (taille, couleur, etc.)

    def __str__(self):
        return f"{self.quantity}x {self.product_name or self.product}"

    def save(self, *args, **kwargs):
        # Calculer le total de la ligne
        if not self.total:
            self.total = self.price * self.quantity
        
        # Sauvegarder le nom du produit
        if self.product and not self.product_name:
            self.product_name = self.product.name
            
        super().save(*args, **kwargs)

    @property
    def unit_price(self):
        return self.price

    @property
    def total_price(self):
        return self.total or (self.price * self.quantity)

    def get_total(self):
        return self.total_price