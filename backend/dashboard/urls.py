from django.urls import path
from . import views

app_name = 'dashboard'

urlpatterns = [
    path('', views.dashboard_home, name='home'),
    path('products/', views.products_list, name='products'),
    path('orders/', views.orders_list, name='orders'),
    path('customers/', views.customers_list, name='customers'),
    path('categories/', views.categories_list, name='categories'),
    path('notifications/', views.notifications_list, name='notifications'),
    path('notifications/<int:pk>/', views.notification_detail, name='notification_detail'),
    path('profile/', views.profile, name='profile'),
    path('settings/', views.settings_view, name='settings'),
]
