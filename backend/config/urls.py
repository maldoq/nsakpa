from django.contrib import admin
from django.urls import path, include
from drf_spectacular.views import SpectacularAPIView, SpectacularRedocView, SpectacularSwaggerView
from django.conf import settings
from django.conf.urls.static import static
# Importez toutes les vues nécessaires ici
from website.views import (
    artisans_list, artisan_detail, 
    post_list, post_detail, create_article, update_article, delete_article,
    artisan_application  # Déplacé ici depuis orders.views
)

# Artisans patterns
artisans_patterns = [
    path('', artisans_list, name='artisans_list'),
    path('<int:pk>/', artisan_detail, name='artisan_detail'),
    path('apply/', artisan_application, name='artisan_application'),
]

# Blog patterns - CORRIGÉ
blog_patterns = [
    path('', post_list, name='post_list'),
    path('create/', create_article, name='create_article'),
    path('<int:pk>/update/', update_article, name='update_article'),
    path('<int:pk>/delete/', delete_article, name='delete_article'),
    
    path('<slug:slug>/', post_detail, name='post_detail'),
]

# === API REST (pour Flutter) ===
from rest_framework.routers import DefaultRouter
from orders.views import OrderViewSet, PaymentMethodViewSet

router = DefaultRouter()
router.register(r'orders', OrderViewSet, basename='order')
router.register(r'payment-methods', PaymentMethodViewSet, basename='payment-method')

urlpatterns = [
    path('admin/', admin.site.urls),
    
    # === API REST (pour Flutter) ===
    path('api/', include('users.urls')),
    path('api/', include('products.urls')),
    path('api/', include('orders.urls')),
    path('api/', include('social.urls')),

    # === ROUTES SWAGGER ===
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    path('api/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),
    
    # === SITE WEB (Templates) ===
    path('', include(('website.urls', 'website'), namespace='website')),
    path('artisans/', include((artisans_patterns, 'artisans'), namespace='artisans')),
    path('blog/', include((blog_patterns, 'blog'), namespace='blog')),
    
    # === DASHBOARD ARTISAN ===
    path('dashboard/', include('dashboard.urls', namespace='dashboard')),

    # === API REST (pour Flutter) ===
    path('api/', include(router.urls)),
]

# AJOUTEZ CE BLOC À LA FIN DU FICHIER
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
