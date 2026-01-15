from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.auth.decorators import login_required
from django.contrib.auth import login, logout, authenticate
from django.contrib import messages
from django.core.paginator import Paginator
from django.db.models import Q
from products.models import Product
from orders.models import Order, OrderItem
from users.models import User
from django.views.decorators.http import require_POST
from django.views.decorators.csrf import csrf_protect
from django.http import JsonResponse


# ==================== PAGES PRINCIPALES ====================

def home(request):
    """Page d'accueil"""
    # Récupérer les catégories uniques des produits
    categories = Product.objects.values_list('category', flat=True).distinct()[:6]
    featured_products = Product.objects.all().order_by('-created_at')[:8]
    
    context = {
        'categories': categories,
        'featured_products': featured_products,
    }
    return render(request, 'website/index.html', context)


def products_list(request):
    """Liste des produits avec filtres"""
    products = Product.objects.all()
    
    # Récupérer les catégories uniques
    categories = Product.objects.values_list('category', flat=True).distinct()
    
    # Filtres
    category = request.GET.get('category')
    search_query = request.GET.get('q')
    sort_by = request.GET.get('sort', 'newest')
    
    if category:
        products = products.filter(category=category)
    
    if search_query:
        products = products.filter(
            Q(name__icontains=search_query) | 
            Q(description__icontains=search_query)
        )
    
    # Tri
    if sort_by == 'price_asc':
        products = products.order_by('price')
    elif sort_by == 'price_desc':
        products = products.order_by('-price')
    elif sort_by == 'popular':
        products = products.order_by('-average_rating')
    else:  # newest
        products = products.order_by('-created_at')
    
    # Pagination
    paginator = Paginator(products, 12)
    page = request.GET.get('page')
    products = paginator.get_page(page)
    
    context = {
        'products': products,
        'categories': categories,
        'selected_category': category,
        'search_query': search_query,
        'sort_by': sort_by,
    }
    return render(request, 'website/products.html', context)


def product_detail(request, pk):
    """Détail d'un produit"""
    product = get_object_or_404(Product, pk=pk)
    related_products = Product.objects.filter(
        category=product.category
    ).exclude(pk=pk)[:4]
    
    context = {
        'product': product,
        'related_products': related_products,
    }
    return render(request, 'website/product-detail.html', context)


def about(request):
    """Page À propos"""
    return render(request, 'website/apropos.html')


def contact(request):
    """Page Contact"""
    if request.method == 'POST':
        # Traitement du formulaire de contact
        name = request.POST.get('name')
        email = request.POST.get('email')
        subject = request.POST.get('subject')
        message = request.POST.get('message')
        # TODO: Envoyer l'email ou sauvegarder le message
        messages.success(request, 'Votre message a été envoyé avec succès!')
        return redirect('contact')
    
    return render(request, 'website/contact.html')


# ==================== ARTISANS ====================

def artisans_list(request):
    """Liste des artisans"""
    artisans = User.objects.filter(role='artisan', is_active=True)
    
    # Pagination
    paginator = Paginator(artisans, 12)
    page = request.GET.get('page')
    artisans = paginator.get_page(page)
    
    context = {
        'artisans': artisans,
    }
    return render(request, 'website/artisans.html', context)


def artisan_detail(request, pk):
    """Détail d'un artisan"""
    artisan = get_object_or_404(User, pk=pk, role='artisan')
    products = Product.objects.filter(artisan=artisan)
    
    context = {
        'artisan': artisan,
        'products': products,
    }
    return render(request, 'website/artisan_detail.html', context)


# ==================== BLOG ====================

def post_list(request):
    """Liste des articles du blog"""
    # TODO: Replace with actual blog posts from database
    posts = []  # Or BlogPost.objects.all() if you have a model
    return render(request, 'website/blog.html', {'posts': posts})


def post_detail(request, pk):
    """Détail d'un article"""
    context = {
        'post': None,
    }
    return render(request, 'website/post_detail.html', context)


def create_article(request):
    """Créer un article"""
    return render(request, 'website/create_article.html')


def update_article(request, pk):
    """Modifier un article"""
    return render(request, 'website/update_article.html')


def delete_article(request, pk):
    """Supprimer un article"""
    return render(request, 'website/delete_article.html')


# ==================== PANIER (stocké en session) ====================

def cart_view(request):
    """Page du panier"""
    cart = request.session.get('cart', {})
    cart_items = []
    total = 0
    
    for product_id, quantity in cart.items():
        try:
            product = Product.objects.get(pk=product_id)
            item_total = product.price * quantity
            cart_items.append({
                'product': product,
                'quantity': quantity,
                'total': item_total,
            })
            total += item_total
        except Product.DoesNotExist:
            pass
    
    context = {
        'cart_items': cart_items,
        'total': total,
    }
    return render(request, 'website/cart.html', context)


def add_to_cart(request, product_id):
    """Ajouter au panier"""
    product = get_object_or_404(Product, pk=product_id)
    cart = request.session.get('cart', {})
    
    product_id_str = str(product_id)
    if product_id_str in cart:
        cart[product_id_str] += 1
    else:
        cart[product_id_str] = 1
    
    request.session['cart'] = cart
    messages.success(request, f'{product.name} ajouté au panier!')
    
    # Rediriger vers la page précédente ou le panier
    next_url = request.GET.get('next', 'cart')
    return redirect(next_url)


def remove_from_cart(request, product_id):
    """Retirer du panier"""
    cart = request.session.get('cart', {})
    product_id_str = str(product_id)
    
    if product_id_str in cart:
        del cart[product_id_str]
        request.session['cart'] = cart
        messages.success(request, 'Article retiré du panier')
    
    return redirect('cart')


def update_cart(request, product_id):
    """Mettre à jour la quantité dans le panier"""
    if request.method == 'POST':
        quantity = int(request.POST.get('quantity', 1))
        cart = request.session.get('cart', {})
        product_id_str = str(product_id)
        
        if quantity > 0:
            cart[product_id_str] = quantity
        else:
            if product_id_str in cart:
                del cart[product_id_str]
        
        request.session['cart'] = cart
    
    return redirect('cart')


# ==================== COMMANDES ====================

@login_required
def payment(request):
    """Page de paiement"""
    cart = request.session.get('cart', {})
    cart_items = []
    total = 0
    
    for product_id, quantity in cart.items():
        try:
            product = Product.objects.get(pk=product_id)
            item_total = product.price * quantity
            cart_items.append({
                'product': product,
                'quantity': quantity,
                'total': item_total,
            })
            total += item_total
        except Product.DoesNotExist:
            pass
    
    if request.method == 'POST':
        # Créer la commande
        order = Order.objects.create(
            buyer=request.user,
            total_amount=total,
            delivery_address=request.POST.get('address', ''),
            delivery_phone=request.POST.get('phone', request.user.phone),
            payment_method=request.POST.get('payment_method', 'orange_money'),
        )
        
        # Créer les items de la commande
        for item in cart_items:
            OrderItem.objects.create(
                order=order,
                product=item['product'],
                quantity=item['quantity'],
            )
        
        # Vider le panier
        request.session['cart'] = {}
        
        return redirect('confirmation')
    
    context = {
        'cart_items': cart_items,
        'total': total,
    }
    return render(request, 'website/payment.html', context)


@login_required
def confirmation(request):
    """Page de confirmation de commande"""
    # Récupérer la dernière commande de l'utilisateur
    last_order = Order.objects.filter(buyer=request.user).order_by('-created_at').first()
    
    context = {
        'order': last_order,
    }
    return render(request, 'website/confirmation.html', context)


@login_required
def client_order_detail(request, pk):
    """Détail d'une commande client"""
    order = get_object_or_404(Order, pk=pk, buyer=request.user)
    context = {
        'order': order,
    }
    return render(request, 'website/client_order_detail.html', context)


@login_required
def change_status(request, pk):
    """Changer le statut d'une commande"""
    return render(request, 'website/change_status.html')


# ==================== PROFIL CLIENT ====================

@login_required
def client_profile(request):
    """Profil du client"""
    orders = Order.objects.filter(buyer=request.user).order_by('-created_at')
    
    context = {
        'user': request.user,
        'orders': orders,
    }
    return render(request, 'website/profile.html', context)


# ==================== AUTHENTIFICATION ====================

def login_view(request):
    """Page de connexion"""
    if request.user.is_authenticated:
        return redirect('home')
    
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        user = authenticate(request, username=username, password=password)
        
        if user is not None:
            login(request, user)
            next_url = request.GET.get('next', 'home')
            messages.success(request, f'Bienvenue {user.first_name or user.username}!')
            return redirect(next_url)
        else:
            messages.error(request, 'Nom d\'utilisateur ou mot de passe incorrect')
    
    return render(request, 'login.html')


def register_view(request):
    """Page d'inscription"""
    if request.user.is_authenticated:
        return redirect('home')
    
    if request.method == 'POST':
        username = request.POST.get('username')
        email = request.POST.get('email')
        phone = request.POST.get('phone')
        password = request.POST.get('password')
        password2 = request.POST.get('password2')
        
        if password != password2:
            messages.error(request, 'Les mots de passe ne correspondent pas')
        elif User.objects.filter(username=username).exists():
            messages.error(request, 'Ce nom d\'utilisateur existe déjà')
        elif User.objects.filter(email=email).exists():
            messages.error(request, 'Cet email existe déjà')
        elif User.objects.filter(phone=phone).exists():
            messages.error(request, 'Ce numéro de téléphone existe déjà')
        else:
            user = User.objects.create_user(
                username=username,
                email=email,
                phone=phone,
                password=password,
                role='buyer'
            )
            login(request, user)
            messages.success(request, 'Compte créé avec succès!')
            return redirect('home')
    
    return render(request, 'register.html')


def logout_view(request):
    """Déconnexion"""
    logout(request)
    messages.success(request, 'Vous avez été déconnecté')
    return redirect('home')


def forgot_password(request):
    """Page mot de passe oublié"""
    return render(request, 'forgot_password.html')


def reset_password(request, token):
    """Page réinitialisation mot de passe"""
    return render(request, 'reset_password.html')


# ==================== NEWSLETTER ====================

def newsletter_subscribe(request):
    """Inscription à la newsletter"""
    if request.method == 'POST':
        email = request.POST.get('email')
        # TODO: Sauvegarder l'email dans un modèle Newsletter
        messages.success(request, 'Merci pour votre inscription à notre newsletter!')
    return redirect('home')


# ==================== PRÉVISUALISATION ====================

def previsualisation(request):
    """Page de prévisualisation"""
    return render(request, 'website/previsualisation.html')


@csrf_protect
@require_POST
def artisan_application(request):
    """Handle artisan application form submission"""
    if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
        # Get form data
        full_name = request.POST.get('full_name', '').strip()
        email = request.POST.get('email', '').strip()
        phone = request.POST.get('phone', '').strip()
        country = request.POST.get('country', '').strip()
        craft_type = request.POST.get('craft_type', '').strip()
        experience = request.POST.get('experience', '').strip()
        description = request.POST.get('description', '').strip()
        
        errors = {}
        
        # Basic validation
        if not full_name:
            errors['full_name'] = 'Le nom complet est requis'
        if not email:
            errors['email'] = 'L\'email est requis'
        if not phone:
            errors['phone'] = 'Le téléphone est requis'
        if not country:
            errors['country'] = 'Le pays est requis'
        if not craft_type:
            errors['craft_type'] = 'Le type d\'artisanat est requis'
        if not experience:
            errors['experience'] = 'L\'expérience est requise'
        if not description:
            errors['description'] = 'La description est requise'
        
        if not request.POST.get('terms_accepted'):
            errors['terms_accepted'] = 'Vous devez accepter les conditions'
        
        if errors:
            return JsonResponse({'success': False, 'errors': errors})
        
        # TODO: Save the application to database or send email notification
        return JsonResponse({
            'success': True,
            'message': 'Votre candidature a été envoyée avec succès ! Nous vous contacterons bientôt.'
        })
    
    # Non-AJAX request
    return JsonResponse({'success': False, 'error': 'Invalid request'}, status=400)
