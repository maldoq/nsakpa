# N'SAPKA - Application Mobile Artisanale

## 🎨 Description
N'SAPKA est une plateforme numérique innovante qui met en relation les artisans et producteurs locaux avec des acheteurs désireux d'acquérir des articles authentiques, faits main et de qualité.

## 📱 Fonctionnalités Implémentées

### ✅ Écrans d'Onboarding (3 pages)
1. **Page 1 - Bienvenue** : Introduction à N'SAPKA avec le logo (main)
2. **Page 2 - Voyage Artisanal** : Découverte des produits artisanaux
3. **Page 3 - Soutien Local** : Importance du soutien aux artisans

### ✅ Authentification
- **Sélection du type d'utilisateur** : Acheteur ou Artisan
- **Connexion/Inscription** : Formulaire avec numéro de téléphone et mot de passe
- **Connexion par OTP** : Option de connexion par SMS (à implémenter côté backend)

### ✅ Interface Acheteur
- **Accueil** : Catalogue de produits avec recherche et filtres
- **Catégories** : Navigation par catégories (Sculptures, Peintures, Textiles, etc.)
- **Produits** : Cartes de produits avec image, prix, artisan, note
- **Navigation** : 5 onglets (Accueil, Catalogue, Favoris, Panier, Profil)

### ✅ Interface Artisan
- **Tableau de bord** : Statistiques (ventes, revenus, produits, note)
- **Gestion des produits** : Liste des produits avec stock et ventes
- **Navigation** : 4 onglets (Produits, Commandes, Messages, Profil)
- **Bouton d'ajout** : FAB pour ajouter rapidement un produit

## 🎨 Palette de Couleurs Africaine

L'application utilise une palette chaleureuse inspirée de l'artisanat africain :

- **Primaire** : Or foncé (#B8860B) - Représente la richesse artisanale
- **Secondaire** : Marron (#8B4513) - Évoque la terre et les matériaux naturels
- **Accent** : Orange (#FF8C00) - Apporte chaleur et dynamisme
- **Terracotta** : (#E07A5F) - Couleur terre cuite traditionnelle
- **Sable** : (#F4E4C1) - Tons doux et accueillants

## 📂 Structure du Projet

```
lib/
├── core/
│   └── constants/
│       ├── app_colors.dart      # Palette de couleurs
│       ├── app_strings.dart     # Textes de l'application
│       └── app_theme.dart       # Thème Material Design
├── features/
│   ├── onboarding/
│   │   ├── models/
│   │   ├── screens/
│   │   └── widgets/
│   ├── auth/
│   │   └── screens/
│   ├── buyer/
│   │   ├── screens/
│   │   └── widgets/
│   └── artisan/
│       └── screens/
└── main.dart                    # Point d'entrée
```

## 🚀 Installation et Lancement

### Prérequis
- Flutter SDK installé
- Un émulateur Android/iOS ou un appareil physique

### Étapes

1. **Installer les dépendances** :
```bash
cd c:/Users/HP\ PC/OneDrive/Desktop/flutter_projet/nsapka
flutter pub get
```

2. **Vérifier les appareils disponibles** :
```bash
flutter devices
```

3. **Lancer l'application** :
```bash
flutter run
```

Ou depuis VS Code :
- Appuyez sur `F5`
- Ou cliquez sur "Run" > "Start Debugging"

## 📦 Dépendances Utilisées

- `provider` : Gestion d'état
- `smooth_page_indicator` : Indicateurs de pages pour l'onboarding
- `flutter_svg` : Support des images SVG
- `cached_network_image` : Cache d'images réseau
- `image_picker` : Sélection d'images
- `video_player` : Lecture de vidéos
- `http` & `dio` : Requêtes HTTP
- `shared_preferences` : Stockage local
- `intl` : Internationalisation

## 🎯 Prochaines Étapes

### À Implémenter (Backend requis)
1. **Authentification réelle** :
   - Intégration OTP par SMS
   - Gestion des sessions utilisateur
   - Récupération de mot de passe

2. **Gestion des produits** :
   - Ajout/modification/suppression de produits
   - Upload d'images et vidéos
   - Saisie vocale pour artisans analphabètes

3. **Catalogue et recherche** :
   - API de recherche de produits
   - Filtres avancés
   - Géolocalisation "près de moi"

4. **Panier et commandes** :
   - Gestion du panier
   - Processus de commande
   - Suivi de livraison

5. **Paiement** :
   - Intégration Mobile Money (Orange Money, MTN MoMo)
   - Système d'escrow
   - Historique des transactions

6. **Messagerie** :
   - Chat entre acheteur et artisan
   - Notifications push

7. **Fonctionnalités avancées** :
   - Système de notation et avis
   - QR Shop pour chaque stand
   - Traduction multilingue
   - Mode vocal (TTS/ASR)

## 🐛 Problèmes Connus

1. **Dépendances manquantes** : Exécutez `flutter pub get` pour installer toutes les dépendances
2. **Assets manquants** : Les dossiers assets sont créés mais vides. Ajoutez vos images dans :
   - `assets/images/` : Images de produits
   - `assets/icons/` : Icônes personnalisées
   - `assets/logo/` : Logo de l'application

## 📸 Ajout d'Images

Pour ajouter des images à votre application :

1. Placez vos images dans les dossiers appropriés :
   - `assets/images/onboarding1.png`
   - `assets/images/onboarding2.png`
   - `assets/images/onboarding3.png`

2. Les images seront automatiquement chargées grâce à la configuration dans `pubspec.yaml`

## 🎨 Personnalisation

### Modifier les couleurs
Éditez `lib/core/constants/app_colors.dart` pour changer la palette de couleurs.

### Modifier les textes
Éditez `lib/core/constants/app_strings.dart` pour changer les textes de l'application.

### Modifier le thème
Éditez `lib/core/constants/app_theme.dart` pour personnaliser le thème Material Design.

## 📞 Support

Pour toute question ou problème, référez-vous à la documentation Flutter :
- [Documentation Flutter](https://docs.flutter.dev/)
- [Cookbook Flutter](https://docs.flutter.dev/cookbook)

## 🎉 Félicitations !

Vous avez maintenant une base solide pour votre application N'SAPKA. L'interface est moderne, responsive et prête à être connectée à un backend pour les fonctionnalités complètes.

**Bon développement ! 🚀**
