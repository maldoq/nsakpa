from django.db import models
from django.conf import settings

class Product(models.Model):
    # Lien avec l'artisan (User)
    artisan = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='products')
    
    name = models.CharField(max_length=200)
    description = models.TextField()
    price = models.DecimalField(max_digits=10, decimal_places=0) # FCFA n'a pas de décimales habituellement
    stock = models.IntegerField(default=1)
    
    # Catégories vues dans BuyerHomeScreen (Sculpture, Mobilier, Mode, etc.)
    category = models.CharField(max_length=100)
    
    # Gestion des éditions limitées (vu dans BuyerHomeEnhanced)
    is_limited_edition = models.BooleanField(default=False)
    limited_quantity = models.IntegerField(null=True, blank=True)
    
    # Données spécifiques N'SAPKA
    origin = models.CharField(max_length=100, default="Côte d'Ivoire")
    video_url = models.FileField(upload_to='product_videos/', null=True, blank=True) # Pour les vidéos de présentation
    tags = models.JSONField(default=list, blank=True) # Ex: ['Bronze', 'Luxe']
    
    # Métriques (calculées ou mises en cache)
    average_rating = models.FloatField(default=0.0)
    review_count = models.IntegerField(default=0)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name

class ProductImage(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='images')
    image = models.ImageField(upload_to='products/')
    is_main = models.BooleanField(default=False) # L'image principale affichée dans la liste