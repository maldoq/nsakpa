from django.urls import path
from . import views

app_name = 'dashboard'

urlpatterns = [
    path('', views.dashboard_home, name='home'),
    path('products/', views.products_list, name='products'),
    
    # Orders
    path('orders/', views.orders_list, name='orders'),
    path('orders/change-status/', views.change_order_status, name='change_order_status'),
    path('orders/change-payment-status/', views.change_payment_status, name='change_payment_status'),
    path('orders/batch-update/', views.batch_update_orders, name='batch_update_orders'),
    path('orders/<int:pk>/details/', views.get_order_details, name='get_order_details'),
    path('orders/<int:pk>/update-tracking/', views.update_tracking, name='update_tracking'),
    path('orders/<int:pk>/add-note/', views.add_note, name='add_note'),
    
    path('customers/', views.customers_list, name='customers'),
    path('categories/', views.categories_list, name='categories'),
    path('notifications/', views.notifications_list, name='notifications'),
    path('notifications/<int:pk>/', views.notification_detail, name='notification_detail'),
    path('profile/', views.profile, name='profile'),
    path('settings/', views.settings_view, name='settings'),
]
