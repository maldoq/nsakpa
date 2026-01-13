from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import UserViewSet, login_view

router = DefaultRouter()
router.register(r'users', UserViewSet)

urlpatterns = [
    # Login custom doit être AVANT le router pour être prioritaire si conflit
    path('auth/login/', login_view, name='login'),
    
    # Routes générées par le router (dont /users/)
    path('', include(router.urls)),
]