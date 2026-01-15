from django.contrib import admin
from django.urls import path, include
from drf_spectacular.views import SpectacularAPIView, SpectacularRedocView, SpectacularSwaggerView
from django.conf import settings
from django.conf.urls.static import static
from website.views import artisans_list, artisan_detail, post_list
from orders.views import artisan_application  # Import from orders.views

# Artisans patterns
artisans_patterns = [
    path('', artisans_list, name='artisans_list'),
    path('<int:pk>/', artisan_detail, name='artisan_detail'),  # Changed artisan_id to pk
    path('apply/', artisan_application, name='artisan_application'),
]

# Blog patterns
blog_patterns = [
    path('', post_list, name='post_list'),
]

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
    path('', include('website.urls')),  # Pages principales du site
    path('artisans/', include((artisans_patterns, 'artisans'), namespace='artisans')),
    path('blog/', include((blog_patterns, 'blog'), namespace='blog')),
    
    # === DASHBOARD ARTISAN ===
    path('dashboard/', include('dashboard.urls', namespace='dashboard')),
]

# Serve media AND static files during development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATICFILES_DIRS[0])
