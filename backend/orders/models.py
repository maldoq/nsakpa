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
    
    # Un panier peut contenir des produits de plusieurs artisans,
    # mais pour simplifier la gestion artisan, on peut soit scinder les commandes,
    # soit lier à un artisan principal si c'est une commande par artisan.
    # Ici, je garde une commande globale.
    
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDING)
    total_amount = models.DecimalField(max_digits=12, decimal_places=0)
    
    # Infos livraison
    delivery_address = models.TextField()
    delivery_phone = models.CharField(max_length=20)
    note = models.TextField(null=True, blank=True)
    
    # Paiement (Orange Money, Wave, etc.)
    payment_method = models.CharField(max_length=50, default='orange_money')
    transaction_id = models.CharField(max_length=100, null=True, blank=True)
    is_paid = models.BooleanField(default=False)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Commande #{self.id} - {self.buyer.username}"

class OrderItem(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='items')
    product = models.ForeignKey(Product, on_delete=models.SET_NULL, null=True)
    
    # On sauvegarde les infos au moment de l'achat (si le prix change plus tard)
    product_name = models.CharField(max_length=200)
    quantity = models.IntegerField(default=1)
    unit_price = models.DecimalField(max_digits=10, decimal_places=0)
    
    # Pour faciliter les requêtes côté artisan
    artisan = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, related_name='sales_items')

    def save(self, *args, **kwargs):
        if self.product and not self.product_name:
            self.product_name = self.product.name
            self.artisan = self.product.artisan
        super().save(*args, **kwargs)