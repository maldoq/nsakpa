from django.urls import path
from . import views
from orders.views import payment, process_payment, confirmation, check_stock

# URLs pour les artisans (namespace: artisans)
artisans_patterns = [
    path('', views.artisans_list, name='artisans_list'),
    path('<int:pk>/', views.artisan_detail, name='artisan_detail'),
]

# URLs pour le blog (namespace: blog)
blog_patterns = [
    path('', views.post_list, name='post_list'),
    path('create/', views.create_article, name='create_article'),
    path('<int:pk>/update/', views.update_article, name='update_article'),
    path('<int:pk>/delete/', views.delete_article, name='delete_article'),
    path('<slug:slug>/', views.post_detail, name='post_detail'),
]

# URLs principales du website
urlpatterns = [
    # Pages principales
    path('', views.home, name='home'),
    path('products/', views.products_list, name='products'),
    path('products/<int:pk>/', views.product_detail, name='product_detail'),
    path('about/', views.about, name='about'),
    path('contact/', views.contact, name='contact'),
    
    # Panier
    path('cart/', views.cart_view, name='cart'),
    path('cart/add/<int:product_id>/', views.add_to_cart, name='add_to_cart'),
    path('cart/remove/<int:product_id>/', views.remove_from_cart, name='remove_from_cart'),
    path('cart/update/<int:product_id>/', views.update_cart, name='update_cart'),
    path('cart/sync/', views.sync_cart, name='sync_cart'),  # NOUVELLE LIGNE
    
    # Paiement (importé depuis orders.views)
    path('payment/', payment, name='payment'),
    path('payment/process/', process_payment, name='process_payment'),
    path('confirmation/', confirmation, name='confirmation'),
    path('check-stock/', check_stock, name='check_stock'),
    
    # Commandes client
    path('order/<int:pk>/', views.client_order_detail, name='client_order_detail'),
    path('order/<int:pk>/status/', views.change_status, name='change_status'),
    
    # Profil client
    path('profile/', views.client_profile, name='client_profile'),
    path('profile/address/save/', views.client_profile_address, name='client_profile_address'),
    path('profile/address/delete/<int:pk>/', views.delete_address, name='delete_address'),
    
    # Authentification
    path('login/', views.login_view, name='login'),
    path('register/', views.register_view, name='register'),
    path('logout/', views.logout_view, name='logout'),
    path('forgot-password/', views.forgot_password, name='forgot_password'),
    path('reset-password/<str:token>/', views.reset_password, name='reset_password'),
    
    # Newsletter
    path('newsletter/subscribe/', views.newsletter_subscribe, name='newsletter_subscribe'),
    
    # Autres
    path('preview/', views.previsualisation, name='previsualisation'),
]
