# 🎨 N'SAPKA - Plateforme Artisanale Africaine

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-3.9.2-blue?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.0-blue?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green" alt="Platform">
  <img src="https://img.shields.io/badge/License-MIT-yellow" alt="License">
</div>

## 📱 À Propos

**N'SAPKA** est une plateforme mobile innovante qui connecte les artisans et producteurs locaux avec des acheteurs désireux d'acquérir des articles authentiques, faits main et de qualité. L'application célèbre le savoir-faire artisanal africain à travers une interface moderne et accueillante.

### ✨ Caractéristiques Principales

- 🎨 **Design Africain Authentique** : Palette de couleurs chaudes (or, marron, terracotta)
- 🛍️ **Interface Acheteur** : Catalogue, recherche, favoris, panier
- 🎭 **Interface Artisan** : Gestion produits, statistiques, commandes
- 🎤 **Saisie Vocale** : Support pour artisans analphabètes
- 📱 **Responsive** : Optimisé pour tous les écrans mobiles
- 🌍 **Multilingue** : Prêt pour FR/EN et langues locales

## 🚀 Démarrage Rapide

### Prérequis

- Flutter SDK (3.9.2 ou supérieur)
- Dart SDK (3.0 ou supérieur)
- Android Studio / Xcode
- Un émulateur ou appareil physique

### Installation

```bash
# 1. Cloner le projet
cd "c:/Users/HP PC/OneDrive/Desktop/flutter_projet/nsapka"

# 2. Installer les dépendances
flutter pub get

# 3. Lancer l'application
flutter run
```

### Méthode Alternative (VS Code)

1. Ouvrez le projet dans VS Code
2. Lancez votre émulateur
3. Appuyez sur **F5**
4. Sélectionnez votre appareil

## 📸 Captures d'Écran

### Onboarding
- 3 pages de bienvenue élégantes
- Navigation fluide avec indicateurs
- Design inspiré de l'artisanat africain

### Interface Acheteur
- Catalogue de produits avec recherche
- Catégories (Sculptures, Peintures, Textiles...)
- Cartes produits avec badges "Édition limitée"
- Navigation par onglets (Accueil, Catalogue, Favoris, Panier, Profil)

### Interface Artisan
- Tableau de bord avec statistiques
- Gestion complète des produits
- Ajout de produit avec saisie vocale
- Navigation par onglets (Produits, Commandes, Messages, Profil)

## 🏗️ Architecture

```
lib/
├── core/
│   └── constants/          # Couleurs, textes, thème
├── features/
│   ├── onboarding/         # Écrans de bienvenue
│   ├── auth/               # Authentification
│   ├── buyer/              # Interface acheteur
│   └── artisan/            # Interface artisan
└── main.dart               # Point d'entrée
```

## 🎨 Palette de Couleurs

| Couleur | Hex | Usage |
|---------|-----|-------|
| Or foncé | `#B8860B` | Primaire |
| Marron | `#8B4513` | Secondaire |
| Orange | `#FF8C00` | Accent |
| Terracotta | `#E07A5F` | Tertiaire |
| Sable | `#F4E4C1` | Fond |

## 📦 Dépendances

- `provider` - Gestion d'état
- `smooth_page_indicator` - Indicateurs onboarding
- `image_picker` - Sélection d'images
- `video_player` - Lecture vidéos
- `http` / `dio` - Requêtes API
- `shared_preferences` - Stockage local
- `intl` - Internationalisation

## 🎯 Fonctionnalités

### ✅ Implémenté (UI)
- [x] Onboarding (3 pages)
- [x] Sélection Acheteur/Artisan
- [x] Connexion/Inscription
- [x] Interface Acheteur complète
- [x] Interface Artisan complète
- [x] Ajout de produit avec saisie vocale
- [x] Navigation par onglets
- [x] Design system complet

### 🔄 À Implémenter (Backend)
- [ ] Authentification réelle (OTP)
- [ ] CRUD produits
- [ ] Panier et commandes
- [ ] Paiement Mobile Money
- [ ] Messagerie temps réel
- [ ] Notifications push
- [ ] Géolocalisation
- [ ] Traduction automatique

## 📚 Documentation

- [INSTRUCTIONS.md](INSTRUCTIONS.md) - Guide complet
- [DEMARRAGE_RAPIDE.md](DEMARRAGE_RAPIDE.md) - Démarrage rapide
- [RESUME_COMPLET.md](RESUME_COMPLET.md) - Résumé détaillé
- [ARCHITECTURE.md](ARCHITECTURE.md) - Architecture technique
- [COMMANDES.txt](COMMANDES.txt) - Commandes essentielles

## 🧪 Tests

```bash
# Lancer les tests
flutter test

# Analyser le code
flutter analyze

# Formater le code
flutter format .
```

## 📱 Build

```bash
# Android APK
flutter build apk

# Android App Bundle
flutter build appbundle

# iOS
flutter build ios
```

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 👥 Auteurs

- **Équipe N'SAPKA** - Développement initial

## 🙏 Remerciements

- Artisans de Grand Bassam pour leur inspiration
- Communauté Flutter pour les ressources
- Tous les contributeurs du projet

## 📞 Contact

Pour toute question ou suggestion :
- Email: contact@nsapka.com
- Site web: www.nsapka.com

---

<div align="center">
  <p>Fait avec ❤️ pour l'artisanat africain</p>
  <p>© 2025 N'SAPKA - Tous droits réservés</p>
</div>
