# orders/models.py
from django.db import models
from django.conf import settings
from products.models import Product

class Order(models.Model):
    class Status(models.TextChoices):
        PENDING = 'pending', 'En attente'
        PAID = 'paid', 'Payé'
        PREPARING = 'preparing', 'En préparation'
        DELIVERING = 'delivering', 'En livraison'
        DELIVERED = 'delivered', 'Livré'
        CANCELLED = 'cancelled', 'Annulé'

    buyer = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='orders')
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDING)
    total_amount = models.DecimalField(max_digits=12, decimal_places=0)
    
    delivery_address = models.TextField()
    delivery_phone = models.CharField(max_length=20)
    note = models.TextField(null=True, blank=True)
    
    payment_method = models.CharField(max_length=50, default='orange_money')
    transaction_id = models.CharField(max_length=100, null=True, blank=True)
    is_paid = models.BooleanField(default=False)
    
    # Champs pour la livraison et réception
    is_delivered = models.BooleanField(default=False)
    delivered_at = models.DateTimeField(null=True, blank=True)
    is_received = models.BooleanField(default=False)
    received_at = models.DateTimeField(null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Commande #{self.id} - {self.buyer.username}"


class OrderItem(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='items')
    product = models.ForeignKey(Product, on_delete=models.SET_NULL, null=True)
    
    product_name = models.CharField(max_length=200)
    quantity = models.IntegerField(default=1)
    unit_price = models.DecimalField(max_digits=10, decimal_places=0)
    
    artisan = models.ForeignKey(
        settings.AUTH_USER_MODEL, 
        on_delete=models.SET_NULL, 
        null=True, 
        related_name='sales_items'
    )

    def save(self, *args, **kwargs):
        # Remplir automatiquement les champs si le produit existe
        if self.product:
            if not self.product_name:
                self.product_name = self.product.name
            if not self.unit_price:
                self.unit_price = self.product.price
            if not self.artisan:
                self.artisan = self.product.artisan
        super().save(*args, **kwargs)
    
    @property
    def total_price(self):
        return self.unit_price * self.quantity

    def __str__(self):
        return f"{self.product_name} x{self.quantity}"