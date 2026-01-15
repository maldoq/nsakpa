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
    """Décorateur pour vérifier que l'utilisateur est un artisan"""
    def wrapper(request, *args, **kwargs):
        if not request.user.is_authenticated:
            return redirect('login')
        if request.user.role not in ['artisan', 'admin']:
            messages.error(request, "Accès réservé aux artisans")
            return redirect('home')
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
        'out_of_stock': products.filter(stock=0).count(),
    }
    
    # Calcul des pourcentages
    prev_orders_count = previous_orders.count() or 1
    prev_revenue = previous_orders.aggregate(total=Sum('total_amount'))['total'] or 1
    
    orders_percentage = ((stats['total_orders'] - prev_orders_count) / prev_orders_count) * 100
    revenue_percentage = ((stats['total_revenue'] - prev_revenue) / prev_revenue) * 100
    customers_percentage = 0  # À calculer
    stock_percentage = 0
    
    # Dernières commandes
    recent_orders = orders.order_by('-created_at')[:5]
    
    # Produits populaires
    popular_products = products.order_by('-average_rating')[:5]
    
    context = {
        'stats': stats,
        'orders_percentage': orders_percentage,
        'revenue_percentage': revenue_percentage,
        'customers_percentage': customers_percentage,
        'stock_percentage': stock_percentage,
        'recent_orders': recent_orders,
        'popular_products': popular_products,
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
        # Clients qui ont commandé chez cet artisan
        customer_ids = Order.objects.filter(
            items__product__artisan=request.user
        ).values_list('buyer_id', flat=True).distinct()
        customers = User.objects.filter(id__in=customer_ids)
    
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
    if request.method == 'POST':
        # Mise à jour du profil
        user = request.user
        user.first_name = request.POST.get('first_name', user.first_name)
        user.last_name = request.POST.get('last_name', user.last_name)
        user.phone = request.POST.get('phone', user.phone)
        user.location = request.POST.get('location', user.location)
        user.bio = request.POST.get('bio', user.bio)
        user.stand_name = request.POST.get('stand_name', user.stand_name)
        user.stand_location = request.POST.get('stand_location', user.stand_location)
        
        if 'profile_image' in request.FILES:
            user.profile_image = request.FILES['profile_image']
        
        user.save()
        messages.success(request, 'Profil mis à jour avec succès!')
        return redirect('dashboard:profile')
    
    context = {
        'user': request.user,
    }
    return render(request, 'dashboard/profile.html', context)


@login_required
@artisan_required
def settings_view(request):
    """Paramètres du compte"""
    context = {
        'user': request.user,
    }
    return render(request, 'dashboard/settings.html', context)
