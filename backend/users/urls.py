from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import UserViewSet, login_view, get_favorites, add_favorite, remove_favorite

router = DefaultRouter()
router.register(r'users', UserViewSet)

urlpatterns = [
    # Login custom doit être AVANT le router pour être prioritaire si conflit
    path('auth/login/', login_view, name='login'),
    
    # Endpoints favoris
    path('favorites/', get_favorites, name='get_favorites'),
    path('favorites/<int:product_id>/add/', add_favorite, name='add_favorite'),
    path('favorites/<int:product_id>/remove/', remove_favorite, name='remove_favorite'),
    
    # Routes générées par le router (dont /users/)
    path('', include(router.urls)),
]