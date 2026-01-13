from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User

class CustomUserAdmin(UserAdmin):
    model = User
    # Champs affichés dans la liste des utilisateurs
    list_display = ['username', 'email', 'role', 'phone', 'is_staff', 'is_active']
    
    # Filtres sur le côté
    list_filter = ['role', 'is_staff', 'is_active']
    
    # Champs modifiables dans le formulaire d'édition
    fieldsets = UserAdmin.fieldsets + (
        ('Informations N\'SPAKA', {'fields': ('role', 'phone', 'profile_image', 'location')}),
        ('Informations Artisan', {'fields': ('bio', 'stand_name', 'specialties', 'stand_location', 'years_of_experience', 'is_verified')}),
    )
    
    # Champs modifiables lors de la création d'un utilisateur
    add_fieldsets = UserAdmin.add_fieldsets + (
        ('Informations N\'SPAKA', {'fields': ('role', 'phone', 'email')}),
    )

# Enregistrer le modèle
admin.site.register(User, CustomUserAdmin)