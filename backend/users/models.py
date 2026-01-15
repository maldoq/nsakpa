from django.db import models
from django.contrib.auth.models import AbstractUser

class User(AbstractUser):
    class Role(models.TextChoices):
        BUYER = 'buyer', 'Acheteur'
        ARTISAN = 'artisan', 'Artisan'
        ADMIN = 'admin', 'Administrateur'
        COMMUNITY_AGENT = 'community_agent', 'Agent Communautaire'
        DELIVERY = 'delivery', 'Livreur'

    role = models.CharField(max_length=20, choices=Role.choices, default=Role.BUYER)
    phone = models.CharField(max_length=15, unique=True, null=True, blank=True)
    profile_image = models.ImageField(upload_to='profile_images/', null=True, blank=True)
    location = models.CharField(max_length=255, blank=True)
    
    # Champs spécifiques Artisan
    bio = models.TextField(blank=True)
    stand_name = models.CharField(max_length=100, blank=True)
    stand_location = models.CharField(max_length=255, blank=True)
    specialties = models.JSONField(default=list, blank=True)
    certifications = models.JSONField(default=list, blank=True)
    years_of_experience = models.IntegerField(default=0)
    is_verified = models.BooleanField(default=False)
    is_certified = models.BooleanField(default=False)
    rating = models.FloatField(default=0.0)
    total_sales = models.IntegerField(default=0)
    qr_code = models.ImageField(upload_to='qr_codes/', null=True, blank=True)
    
    working_hours = models.JSONField(default=dict, blank=True)

    REQUIRED_FIELDS = ['phone', 'email'] # email est dans AbstractUser

    def __str__(self):
        return f"{self.username} ({self.role})"

# ADD THIS MODEL CLASS:
class Address(models.Model):
    ADDRESS_TYPE_CHOICES = [
        ('billing', 'Facturation'),
        ('shipping', 'Livraison'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='addresses')
    address_type = models.CharField(max_length=10, choices=ADDRESS_TYPE_CHOICES, default='shipping')
    street_address = models.CharField(max_length=255)
    apartment = models.CharField(max_length=100, blank=True, null=True)
    city = models.CharField(max_length=100)
    postal_code = models.CharField(max_length=20)
    country = models.CharField(max_length=100)
    is_default = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.street_address}, {self.city} ({self.get_address_type_display()})"
    
    class Meta:
        verbose_name_plural = "Addresses"