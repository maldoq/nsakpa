from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ReviewViewSet, ConversationViewSet, MessageViewSet

router = DefaultRouter()
router.register(r'reviews', ReviewViewSet)
router.register(r'conversations', ConversationViewSet)
router.register(r'messages', MessageViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
