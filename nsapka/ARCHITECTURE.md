# 🏗️ Architecture de l'Application N'SAPKA

## 📊 Flux de Navigation

```
┌─────────────────────────────────────────────────────────────┐
│                    LANCEMENT DE L'APP                        │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                  ONBOARDING (3 pages)                        │
│  • Page 1: Bienvenue sur N'SAPKA                            │
│  • Page 2: Plongez au cœur du voyage artisanal              │
│  • Page 3: Soutenez le talent local                         │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│              SÉLECTION TYPE D'UTILISATEUR                    │
│                                                              │
│    ┌──────────────┐              ┌──────────────┐          │
│    │   ACHETEUR   │              │   ARTISAN    │          │
│    │      🛍️      │              │      🎨      │          │
│    └──────────────┘              └──────────────┘          │
└─────────────────────────────────────────────────────────────┘
           ↓                                  ↓
┌──────────────────────┐          ┌──────────────────────┐
│  CONNEXION ACHETEUR  │          │  CONNEXION ARTISAN   │
│  • Téléphone         │          │  • Téléphone         │
│  • Mot de passe      │          │  • Mot de passe      │
│  • OTP (optionnel)   │          │  • OTP (optionnel)   │
└──────────────────────┘          └──────────────────────┘
           ↓                                  ↓
┌──────────────────────┐          ┌──────────────────────┐
│  INTERFACE ACHETEUR  │          │  INTERFACE ARTISAN   │
└──────────────────────┘          └──────────────────────┘
```

## 🛍️ Interface Acheteur - Navigation

```
┌─────────────────────────────────────────────────────────────┐
│                    BOTTOM NAVIGATION                         │
│  ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐             │
│  │  🏠 │  │  📋 │  │  ❤️ │  │  🛒 │  │  👤 │             │
│  │Home │  │Cata │  │Fav  │  │Cart │  │Prof │             │
│  └─────┘  └─────┘  └─────┘  └─────┘  └─────┘             │
└─────────────────────────────────────────────────────────────┘

HOME (Accueil)
├── AppBar avec logo N'SAPKA
├── Barre de recherche
├── Catégories horizontales
│   ├── Tous
│   ├── Sculptures
│   ├── Peintures
│   ├── Textiles
│   ├── Bijoux
│   ├── Poterie
│   └── Vannerie
├── Section "Près de vous"
└── Grille de produits
    └── Carte produit
        ├── Image
        ├── Badge "Édition limitée"
        ├── Bouton favori ❤️
        ├── Nom du produit
        ├── Artisan
        ├── Prix
        └── Note ⭐

CATALOG (Catalogue)
└── Vue complète du catalogue (à implémenter)

FAVORITES (Favoris)
└── Liste des produits favoris (à implémenter)

CART (Panier)
└── Panier d'achat (à implémenter)

PROFILE (Profil)
└── Profil utilisateur (à implémenter)
```

## 🎨 Interface Artisan - Navigation

```
┌─────────────────────────────────────────────────────────────┐
│                    BOTTOM NAVIGATION                         │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐       │
│  │    📦   │  │    📋   │  │    💬   │  │    👤   │       │
│  │Produits │  │Commandes│  │Messages │  │  Profil │       │
│  └─────────┘  └─────────┘  └─────────┘  └─────────┘       │
└─────────────────────────────────────────────────────────────┘
                              +
                    ┌─────────────────┐
                    │  FAB "Ajouter"  │
                    │       ➕        │
                    └─────────────────┘

PRODUITS (Mes produits)
├── AppBar "Mon Atelier"
├── Statistiques du mois
│   ├── 📊 Ventes
│   ├── 💰 Revenus
│   ├── 📦 Produits
│   └── ⭐ Note
├── Filtres
└── Liste des produits
    └── Carte produit
        ├── Image
        ├── Nom
        ├── Prix
        ├── Stock
        ├── Ventes
        └── Menu actions (Modifier, Supprimer)

AJOUTER PRODUIT (via FAB)
├── Bannière d'aide
├── Section photos
│   └── Multi-sélection d'images
├── Nom du produit
├── Description
│   └── 🎤 Saisie vocale
├── Catégorie (dropdown)
├── Prix et Stock
├── Switch "Édition limitée"
└── Boutons (Annuler, Enregistrer)

COMMANDES
└── Liste des commandes (à implémenter)

MESSAGES
└── Messagerie avec clients (à implémenter)

PROFILE
└── Profil artisan (à implémenter)
```

## 🎨 Palette de Couleurs

```
┌─────────────────────────────────────────────────────────────┐
│                    COULEURS PRINCIPALES                      │
├─────────────────────────────────────────────────────────────┤
│  PRIMARY (Or foncé)        │  #B8860B  │  ████████████     │
│  PRIMARY LIGHT (Or)        │  #DAA520  │  ████████████     │
│  PRIMARY DARK              │  #8B6914  │  ████████████     │
├─────────────────────────────────────────────────────────────┤
│  SECONDARY (Marron)        │  #8B4513  │  ████████████     │
│  SECONDARY LIGHT           │  #CD853F  │  ████████████     │
│  SECONDARY DARK            │  #654321  │  ████████████     │
├─────────────────────────────────────────────────────────────┤
│  ACCENT (Orange)           │  #FF8C00  │  ████████████     │
│  ACCENT LIGHT              │  #FFA500  │  ████████████     │
├─────────────────────────────────────────────────────────────┤
│  TERRACOTTA                │  #E07A5F  │  ████████████     │
│  SAND (Sable)              │  #F4E4C1  │  ████████████     │
│  CLAY (Argile)             │  #D4A574  │  ████████████     │
└─────────────────────────────────────────────────────────────┘
```

## 📁 Structure des Fichiers

```
nsapka/
│
├── lib/
│   ├── core/
│   │   └── constants/
│   │       ├── app_colors.dart      ← Toutes les couleurs
│   │       ├── app_strings.dart     ← Tous les textes
│   │       └── app_theme.dart       ← Thème Material
│   │
│   ├── features/
│   │   │
│   │   ├── onboarding/              ← Écrans de bienvenue
│   │   │   ├── models/
│   │   │   │   └── onboarding_model.dart
│   │   │   ├── screens/
│   │   │   │   └── onboarding_screen.dart
│   │   │   └── widgets/
│   │   │       └── onboarding_page.dart
│   │   │
│   │   ├── auth/                    ← Authentification
│   │   │   └── screens/
│   │   │       ├── auth_selection_screen.dart
│   │   │       └── login_screen.dart
│   │   │
│   │   ├── buyer/                   ← Interface Acheteur
│   │   │   ├── screens/
│   │   │   │   └── buyer_home_screen.dart
│   │   │   └── widgets/
│   │   │       ├── product_card.dart
│   │   │       └── category_chip.dart
│   │   │
│   │   └── artisan/                 ← Interface Artisan
│   │       └── screens/
│   │           ├── artisan_home_screen.dart
│   │           └── add_product_screen.dart
│   │
│   └── main.dart                    ← Point d'entrée + Routes
│
├── assets/
│   ├── images/                      ← Images de produits
│   ├── icons/                       ← Icônes personnalisées
│   └── logo/                        ← Logo N'SAPKA
│
├── pubspec.yaml                     ← Dépendances
│
└── Documentation/
    ├── INSTRUCTIONS.md              ← Guide complet
    ├── DEMARRAGE_RAPIDE.md         ← Démarrage rapide
    ├── RESUME_COMPLET.md           ← Résumé détaillé
    └── ARCHITECTURE.md             ← Ce fichier
```

## 🔄 Gestion d'État (Prévu)

```
Provider (State Management)
│
├── AuthProvider
│   ├── User currentUser
│   ├── bool isAuthenticated
│   ├── login()
│   ├── logout()
│   └── register()
│
├── ProductProvider
│   ├── List<Product> products
│   ├── fetchProducts()
│   ├── addProduct()
│   ├── updateProduct()
│   └── deleteProduct()
│
├── CartProvider
│   ├── List<CartItem> items
│   ├── addToCart()
│   ├── removeFromCart()
│   └── clearCart()
│
└── FavoriteProvider
    ├── List<Product> favorites
    ├── addToFavorites()
    └── removeFromFavorites()
```

## 🌐 API Backend (À implémenter)

```
API Endpoints Requis
│
├── /auth
│   ├── POST /register
│   ├── POST /login
│   ├── POST /verify-otp
│   └── POST /refresh-token
│
├── /products
│   ├── GET  /products
│   ├── GET  /products/:id
│   ├── POST /products
│   ├── PUT  /products/:id
│   └── DELETE /products/:id
│
├── /orders
│   ├── GET  /orders
│   ├── GET  /orders/:id
│   ├── POST /orders
│   └── PUT  /orders/:id/status
│
├── /payments
│   ├── POST /payments/initiate
│   ├── POST /payments/verify
│   └── GET  /payments/:id
│
└── /messages
    ├── GET  /messages
    ├── POST /messages
    └── PUT  /messages/:id/read
```

## 🎯 Fonctionnalités par Priorité

### ✅ MVP (Implémenté - UI seulement)
- [x] Onboarding
- [x] Sélection utilisateur
- [x] Connexion/Inscription (UI)
- [x] Interface Acheteur
- [x] Interface Artisan
- [x] Ajout de produit (UI)
- [x] Navigation
- [x] Design system

### 🔄 Phase 2 (Backend requis)
- [ ] Authentification réelle (OTP)
- [ ] CRUD produits
- [ ] Upload images/vidéos
- [ ] Recherche et filtres
- [ ] Panier fonctionnel

### 🚀 Phase 3 (Fonctionnalités avancées)
- [ ] Paiement Mobile Money
- [ ] Messagerie temps réel
- [ ] Notifications push
- [ ] Géolocalisation
- [ ] Saisie vocale (Speech-to-Text)
- [ ] Traduction multilingue
- [ ] QR Shop
- [ ] Analytics

## 💾 Stockage Local

```
SharedPreferences
├── user_token          (String)
├── user_type           (String: 'buyer' | 'artisan')
├── is_first_launch     (bool)
├── language            (String)
└── theme_mode          (String)
```

## 🔐 Sécurité

```
Mesures de Sécurité
├── HTTPS uniquement
├── JWT pour authentification
├── Validation côté serveur
├── Rate limiting
├── Chiffrement des données sensibles
└── Escrow pour paiements
```

---

**Cette architecture est conçue pour être évolutive et maintenable ! 🚀**
