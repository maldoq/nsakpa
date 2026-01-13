from django.db import models
from django.contrib.auth.models import AbstractUser

class User(AbstractUser):
    class Role(models.TextChoices):
        BUYER = 'buyer', 'Acheteur'
        ARTISAN = 'artisan', 'Artisan'
        ADMIN = 'admin', 'Administrateur'

    # Champs communs
    role = models.CharField(max_length=10, choices=Role.choices, default=Role.BUYER)
    phone = models.CharField(max_length=20, unique=True)
    profile_image = models.ImageField(upload_to='profiles/', null=True, blank=True)
    location = models.CharField(max_length=255, null=True, blank=True)
    
    # Champs spécifiques Artisan (basés sur UserModel.dart)
    bio = models.TextField(null=True, blank=True)
    stand_name = models.CharField(max_length=100, null=True, blank=True)
    stand_location = models.CharField(max_length=255, null=True, blank=True)
    years_of_experience = models.IntegerField(default=0)
    is_verified = models.BooleanField(default=False)
    is_certified = models.BooleanField(default=False)
    
    # Stockage JSON pour les listes (specialties, certifications)
    specialties = models.JSONField(default=list, blank=True) 
    certifications = models.JSONField(default=list, blank=True) 
    working_hours = models.JSONField(default=dict, blank=True)

    REQUIRED_FIELDS = ['phone', 'email'] # email est dans AbstractUser

    def __str__(self):
        return f"{self.username} ({self.role})"