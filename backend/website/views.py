from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth import login, authenticate, logout
from django.contrib.auth import get_user_model
from django.contrib.auth.decorators import login_required  # <-- Add this line
from django.contrib import messages
from django.db.models import Q
from django.views.decorators.csrf import csrf_protect
from django.views.decorators.http import require_POST
from .forms import WebsiteLoginForm, WebsiteRegistrationForm
from django.core.paginator import Paginator
from products.models import Product
from orders.models import Order, OrderItem
from users.models import Address # Assurez-vous d'importer Address
from .models import BlogPost


User = get_user_model()

# ==================== PAGES PRINCIPALES ====================


CATEGORIES_DATA = [
    {'id': 'sculpture', 'name': 'Sculpture', 'icon': 'fa-hammer', 'color': '#8B4513', 'description': 'Œuvres taillées dans le bois et la pierre'},
    {'id': 'tissage', 'name': 'Tissage', 'icon': 'fa-scroll', 'color': '#D2691E', 'description': 'Textiles traditionnels et modernes'},
    {'id': 'poterie', 'name': 'Poterie', 'icon': 'fa-mug-hot', 'color': '#A0522D', 'description': 'Céramiques et terres cuites'},
    {'id': 'bijoux', 'name': 'Bijoux', 'icon': 'fa-gem', 'color': '#DAA520', 'description': 'Parures en or, argent et perles'},
    {'id': 'vannerie', 'name': 'Vannerie', 'icon': 'fa-shopping-basket', 'color': '#CD853F', 'description': 'Paniers et objets tressés'},
    {'id': 'mode', 'name': 'Mode', 'icon': 'fa-tshirt', 'color': '#C71585', 'description': 'Vêtements et accessoires de mode'},
]

def home(request):
    """Page d'accueil"""
    # Récupérer les produits récents comme produits vedettes
    featured_products = Product.objects.filter(stock__gt=0).order_by('-created_at')[:8]
    
    context = {
        'featured_products': featured_products,
        'categories': CATEGORIES_DATA,
    }
    return render(request, 'website/index.html', context)

def products_list(request):
    """Liste des produits avec filtres"""
    products = Product.objects.all()
    
    # Filtres
    category = request.GET.get('category')
    search_query = request.GET.get('q')
    sort_by = request.GET.get('sort', 'newest')
    
    if category:
        products = products.filter(category__iexact=category)
    
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
        'categories': CATEGORIES_DATA,
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
        return redirect('website:contact')  # <-- Correction ici
    
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
    posts = BlogPost.objects.filter(is_published=True).select_related('author')
    
    # Filter by category if provided
    category = request.GET.get('category')
    if category:
        posts = posts.filter(category=category)
    
    # Pagination
    paginator = Paginator(posts, 12)
    page = request.GET.get('page')
    posts = paginator.get_page(page)
    
    return render(request, 'website/blog.html', {
        'posts': posts,
        'selected_category': category,
    })


def post_detail(request, pk):
    """Détail d'un article"""
    post = get_object_or_404(BlogPost, pk=pk, is_published=True)
    
    # Get related posts in the same category
    related_posts = BlogPost.objects.filter(
        category=post.category,
        is_published=True
    ).exclude(pk=pk)[:3]
    
    context = {
        'post': post,
        'related_posts': related_posts,
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
    next_url = request.GET.get('next', 'website:cart') # <-- Correction ici
    if next_url == 'cart': next_url = 'website:cart'
    return redirect(next_url)

def remove_from_cart(request, product_id):
    """Retirer du panier"""
    cart = request.session.get('cart', {})
    product_id_str = str(product_id)
    
    if product_id_str in cart:
        del cart[product_id_str]
        request.session['cart'] = cart
        messages.success(request, 'Article retiré du panier')
    
    return redirect('website:cart') # <-- Correction ici

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
        
        return redirect('website:confirmation') # <-- Correction ici
    
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
    
    # Récupérer les articles de blog de l'utilisateur
    user_blog_posts = BlogPost.objects.filter(author=request.user).order_by('-published_at')

    context = {
        'user': request.user,
        'orders': orders,
        'user_blog_posts': user_blog_posts,
        # AJOUTER CES VARIABLES POUR LES ADRESSES :
        'user_addresses': Address.objects.filter(user=request.user),
        'address_types': Address.ADDRESS_TYPE_CHOICES, # Assurez-vous que votre modèle a ce champ
    }
    return render(request, 'website/profile.html', context)

@login_required
@require_POST
def client_profile_address(request):
    """Ajouter ou modifier une adresse"""
    address_id = request.POST.get('address_id')
    
    if address_id:
        # Modification
        address = get_object_or_404(Address, pk=address_id, user=request.user)
    else:
        # Création
        address = Address(user=request.user)
    
    # Remplissage des champs
    address.address_type = request.POST.get('address_type')
    address.street_address = request.POST.get('street_address')
    address.apartment = request.POST.get('apartment')
    address.city = request.POST.get('city')
    address.postal_code = request.POST.get('postal_code')
    address.country = request.POST.get('country')
    
    # Gestion de l'adresse par défaut
    if request.POST.get('is_default'):
        Address.objects.filter(user=request.user).update(is_default=False)
        address.is_default = True
        
    address.save()
    messages.success(request, "Adresse enregistrée avec succès.")
    return redirect('website:client_profile')

@login_required
def delete_address(request, pk):
    """Supprimer une adresse (appelé via AJAX ou direct)"""
    address = get_object_or_404(Address, pk=pk, user=request.user)
    address.delete()
    
    if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
        return JsonResponse({'success': True})
        
    messages.success(request, "Adresse supprimée.")
    return redirect('website:client_profile')


# ==================== AUTHENTIFICATION ====================

def login_view(request):
    """Connexion au site web"""
    if request.user.is_authenticated:
        return redirect('website:home')

    if request.method == 'POST':
        form = WebsiteLoginForm(request.POST)
        if form.is_valid():
            login_input = form.cleaned_data['username']
            password = form.cleaned_data['password']

            # Chercher l'utilisateur par Username, Email ou Phone
            user_obj = User.objects.filter(
                Q(username=login_input) | 
                Q(email=login_input) | 
                Q(phone=login_input)
            ).first()

            if user_obj is not None:
                user = authenticate(username=user_obj.username, password=password)
                if user is not None:
                    login(request, user)
                    messages.success(request, f"Bienvenue {user.first_name} !")
                    
                    # Redirection selon le rôle
                    if user.role == 'artisan':
                        return redirect('dashboard:home')
                    return redirect('website:home')
                else:
                    messages.error(request, "Mot de passe incorrect.")
            else:
                messages.error(request, "Aucun compte trouvé avec cet identifiant.")
    else:
        form = WebsiteLoginForm()

    return render(request, 'login.html', {'form': form})

def register_view(request):
    """Inscription sur le site web"""
    if request.user.is_authenticated:
        return redirect('website:home')

    if request.method == 'POST':
        form = WebsiteRegistrationForm(request.POST)
        if form.is_valid():
            try:
                user = form.save()
                login(request, user)  # Connexion automatique
                messages.success(request, "Votre compte a été créé avec succès !")
                
                if user.role == 'artisan':
                    return redirect('dashboard:home')
                return redirect('website:home')
            except Exception as e:
                messages.error(request, f"Erreur lors de l'inscription : {str(e)}")
        else:
            messages.error(request, "Veuillez corriger les erreurs dans le formulaire.")
    else:
        form = WebsiteRegistrationForm()

    return render(request, 'register.html', {'form': form})

def logout_view(request):
    """Déconnexion"""
    logout(request)
    messages.info(request, "Vous avez été déconnecté.")
    return redirect('website:login')


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
    return redirect('website:home') # <-- Correction ici


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
