from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.core.paginator import Paginator
from django.db.models import Sum, Count, Q
from django.utils import timezone
from datetime import timedelta
from products.models import Product
from orders.models import Order, OrderItem
from users.models import User


def artisan_required(view_func):
    """Décorateur pour vérifier que l'utilisateur est un artisan ou admin"""
    def wrapper(request, *args, **kwargs):
        if request.user.role not in ['artisan', 'admin']:
            messages.error(request, "Accès réservé aux artisans.")
            return redirect('website:home')
        return view_func(request, *args, **kwargs)
    return wrapper


@login_required
@artisan_required
def dashboard_home(request):
    """Page d'accueil du tableau de bord"""
    user = request.user
    today = timezone.now()
    last_month = today - timedelta(days=30)
    previous_month = last_month - timedelta(days=30)
    
    # Statistiques actuelles
    if user.role == 'admin':
        orders = Order.objects.all()
        products = Product.objects.all()
    else:
        orders = Order.objects.filter(items__product__artisan=user).distinct()
        products = Product.objects.filter(artisan=user)
    
    current_orders = orders.filter(created_at__gte=last_month)
    previous_orders = orders.filter(created_at__gte=previous_month, created_at__lt=last_month)
    
    # Calcul des statistiques
    stats = {
        'total_orders': current_orders.count(),
        'total_revenue': current_orders.aggregate(total=Sum('total_amount'))['total'] or 0,
        'new_customers': User.objects.filter(role='buyer', date_joined__gte=last_month).count(),
        'total_products': products.count(),
    }
    
    # Calcul des variations
    prev_orders_count = previous_orders.count()
    prev_revenue = previous_orders.aggregate(total=Sum('total_amount'))['total'] or 0
    
    stats['orders_change'] = ((stats['total_orders'] - prev_orders_count) / max(prev_orders_count, 1)) * 100
    stats['revenue_change'] = ((stats['total_revenue'] - prev_revenue) / max(prev_revenue, 1)) * 100
    
    # Dernières commandes
    recent_orders = orders.order_by('-created_at')[:5]
    
    # Produits les plus vendus
    top_products = products.annotate(
        sales_count=Count('order_items')
    ).order_by('-sales_count')[:5]
    
    context = {
        'stats': stats,
        'recent_orders': recent_orders,
        'top_products': top_products,
    }
    return render(request, 'dashboard/dashboard.html', context)


@login_required
@artisan_required
def products_list(request):
    """Liste des produits de l'artisan"""
    if request.user.role == 'admin':
        products = Product.objects.all()
    else:
        products = Product.objects.filter(artisan=request.user)
    
    # Filtres
    search = request.GET.get('q')
    category = request.GET.get('category')
    
    if search:
        products = products.filter(
            Q(name__icontains=search) | Q(description__icontains=search)
        )
    if category:
        products = products.filter(category=category)
    
    # Pagination
    paginator = Paginator(products, 10)
    page = request.GET.get('page')
    products = paginator.get_page(page)
    
    # Récupérer les catégories uniques
    categories = Product.objects.values_list('category', flat=True).distinct()
    
    context = {
        'products': products,
        'categories': categories,
    }
    return render(request, 'dashboard/products.html', context)


@login_required
@artisan_required
def orders_list(request):
    """Liste des commandes"""
    if request.user.role == 'admin':
        orders = Order.objects.all()
    else:
        orders = Order.objects.filter(items__product__artisan=request.user).distinct()
    
    # Filtres
    status = request.GET.get('status')
    date_from = request.GET.get('date_from')
    date_to = request.GET.get('date_to')
    
    if status:
        orders = orders.filter(status=status)
    if date_from:
        orders = orders.filter(created_at__date__gte=date_from)
    if date_to:
        orders = orders.filter(created_at__date__lte=date_to)
    
    orders = orders.order_by('-created_at')
    
    # Pagination
    paginator = Paginator(orders, 10)
    page = request.GET.get('page')
    orders = paginator.get_page(page)
    
    context = {
        'orders': orders,
    }
    return render(request, 'dashboard/order.html', context)


@login_required
@artisan_required
def customers_list(request):
    """Liste des clients"""
    if request.user.role == 'admin':
        customers = User.objects.filter(role='buyer')
    else:
        # Clients qui ont acheté des produits de cet artisan
        customers = User.objects.filter(
            orders__items__product__artisan=request.user
        ).distinct()
    
    # Annoter avec les statistiques
    customers = customers.annotate(
        total_orders=Count('orders'),
        total_spent=Sum('orders__total_amount')
    )
    
    # Pagination
    paginator = Paginator(customers, 10)
    page = request.GET.get('page')
    customers = paginator.get_page(page)
    
    context = {
        'customers': customers,
    }
    return render(request, 'dashboard/customer.html', context)


@login_required
@artisan_required
def categories_list(request):
    """Liste des catégories"""
    # Récupérer les catégories uniques avec le nombre de produits
    categories = Product.objects.values('category').annotate(
        product_count=Count('id')
    ).order_by('category')
    
    context = {
        'categories': categories,
    }
    return render(request, 'dashboard/category.html', context)


@login_required
@artisan_required
def notifications_list(request):
    """Liste des notifications"""
    # TODO: Créer un modèle Notification
    notifications = []
    
    context = {
        'notifications': notifications,
    }
    return render(request, 'dashboard/notifications.html', context)


@login_required
@artisan_required
def notification_detail(request, pk):
    """Détail d'une notification"""
    context = {
        'notification': None,
    }
    return render(request, 'dashboard/notification_detail.html', context)


@login_required
@artisan_required
def profile(request):
    """Profil de l'artisan"""
    context = {
        'user': request.user,
    }
    return render(request, 'dashboard/profile.html', context)


@login_required
@artisan_required
def settings_view(request):
    """Paramètres du compte"""
    context = {}
    return render(request, 'dashboard/settings.html', context)
