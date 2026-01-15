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
from django.http import JsonResponse
from django.views.decorators.http import require_POST
from django.views.decorators.csrf import csrf_exempt


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
        sales_count=Count('orderitem')
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
    
    # Get choices for template
    order_status_choices = Order.Status.choices
    payment_status_choices = Order.PaymentStatus.choices
    
    context = {
        'orders': orders,
        'order_status_choices': order_status_choices,
        'payment_status_choices': payment_status_choices,
        'current_status': status,
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

# ==================== ORDER MANAGEMENT API ====================

@login_required
@artisan_required
@require_POST
def change_order_status(request):
    order_id = request.POST.get('order_id')
    status = request.POST.get('status')
    
    order = get_object_or_404(Order, id=order_id)
    order.status = status
    order.save()
    
    return JsonResponse({'success': True, 'status_display': order.get_status_display()})

@login_required
@artisan_required
@require_POST
def change_payment_status(request):
    order_id = request.POST.get('order_id')
    status = request.POST.get('status')
    
    order = get_object_or_404(Order, id=order_id)
    order.payment_status = status
    if status == Order.PaymentStatus.COMPLETED:
        order.is_paid = True
        if not order.paid_at:
            order.paid_at = timezone.now()
    order.save()
    
    return JsonResponse({'success': True, 'payment_status_display': order.get_payment_status_display()})

@login_required
@artisan_required
def get_order_details(request, pk):
    order = get_object_or_404(Order, pk=pk)
    
    items_data = []
    for item in order.items.all():
        items_data.append({
            'product_name': item.product_name,
            'product_sku': item.product_sku,
            'product_image': item.product.images.first().image.url if item.product and item.product.images.exists() else None,
            'unit_price': str(item.price),
            'quantity': item.quantity,
            'total_price': str(item.total),
        })
    
    # Format notes
    notes = []
    if order.note:
        # Assuming notes are just text for now, but JS expects structured
        notes.append({
            'user': 'Système/Admin',
            'created_at': order.updated_at.strftime("%d %b %Y %H:%M"),
            'note': order.note
        })

    data = {
        'success': True,
        'order': {
            'id': order.id,
            'order_number': order.order_number,
            'status': order.status,
            'status_display': order.get_status_display(),
            'created_at': order.created_at.strftime("%d %b %Y %H:%M"),
            'payment_method': order.payment_method,
            'payment_method_display': order.get_payment_method_display(),
            'payment_status': order.payment_status,
            'payment_status_display': order.get_payment_status_display(),
            'tracking_number': order.tracking_number,
            'estimated_delivery_date': order.estimated_delivery_date.strftime("%d %b %Y") if order.estimated_delivery_date else None,
            'subtotal': str(order.subtotal),
            'tax_amount': str(order.tax_amount),
            'shipping_cost': str(order.shipping_cost),
            'total_amount': str(order.total_amount),
            'shipping_address': order.shipping_address_text,
            'billing_address': order.shipping_address_text,
            'customer': {
                'name': f"{order.buyer.first_name} {order.buyer.last_name}",
                'email': order.buyer.email,
                'date_joined': order.buyer.date_joined.strftime("%d %b %Y"),
                'orders_count': order.buyer.orders.count(),
                'image': order.buyer.profile_picture.url if hasattr(order.buyer, 'profile_picture') and order.buyer.profile_picture else None,
            },
            'items': items_data,
            'notes': notes,
        }
    }
    return JsonResponse(data)

@login_required
@artisan_required
@require_POST
def update_tracking(request, pk):
    order = get_object_or_404(Order, pk=pk)
    tracking_number = request.POST.get('tracking_number')
    order.tracking_number = tracking_number
    order.save()
    return JsonResponse({'success': True})

@login_required
@artisan_required
@require_POST
def add_note(request, pk):
    order = get_object_or_404(Order, pk=pk)
    note_text = request.POST.get('note_text')
    
    timestamp = timezone.now().strftime("%Y-%m-%d %H:%M")
    new_note = f"[{timestamp}] {request.user.get_full_name() or request.user.username}: {note_text}"
    
    if order.note:
        order.note += "\n" + new_note
    else:
        order.note = new_note
    order.save()
    
    return JsonResponse({
        'success': True, 
        'user': request.user.get_full_name() or request.user.username,
        'date': timestamp,
        'note_text': note_text
    })

@login_required
@artisan_required
@require_POST
def batch_update_orders(request):
    order_ids = request.POST.get('order_ids', '').split(',')
    status = request.POST.get('status')
    note = request.POST.get('note')
    
    updated_count = 0
    for order_id in order_ids:
        if not order_id: continue
        try:
            order = Order.objects.get(id=order_id)
            if status:
                order.status = status
            if note:
                timestamp = timezone.now().strftime("%Y-%m-%d %H:%M")
                new_note = f"[{timestamp}] {request.user.get_full_name() or request.user.username}: {note}"
                if order.note:
                    order.note += "\n" + new_note
                else:
                    order.note = new_note
            order.save()
            updated_count += 1
        except Order.DoesNotExist:
            continue
            
    return JsonResponse({'success': True, 'updated_count': updated_count})
