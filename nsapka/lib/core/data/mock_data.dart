import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/blog_article_model.dart';
import '../models/review_model.dart';
import '../models/order_model.dart';

/// Données mockées pour simuler le backend (FRONTEND ONLY)
class MockData {
  // ARTISANS RÉELS (basés sur votre terrain)
  static final List<UserModel> artisans = [
    UserModel(
      id: 'art1',
      name: 'Essi Reine',
      email: 'essi.reine@nsapka.ci',
      phone: '+225 07 00 00 01',
      role: UserRole.artisan,
      location: 'Grand Bassam',
      profileImage: 'assets/logo/unnamed (2).jpg', // Logo car pas de photo
      bio: 'Artisane passionnée depuis 32 ans. Fabrique objets d\'art (masques, assiettes, objets de cuisine en bois, nattes, bande en batik). Héritage familial, travaille avec sa mère. Accueil chaleureux et sourire solaire.',
      isVerified: true,
      rating: 4.8,
      totalSales: 156,
      createdAt: DateTime(1992, 1, 1), // 32 ans d'expérience
      standName: 'Chez Maman Tranquille',
      specialties: ['Masques', 'Décoration', 'Batik', 'Objets en bois'],
      yearsOfExperience: 32,
      certifications: ['Artisan Certifié Grand Bassam', 'Héritage Familial'],
      qrCode: 'QR_MAMAN_TRANQUILLE',
    ),
    UserModel(
      id: 'art2',
      name: 'Dje David',
      email: 'dje.david@nsapka.ci',
      phone: '+225 07 00 00 02',
      role: UserRole.artisan,
      location: 'Grand Bassam',
      profileImage: 'assets/images/WhatsApp Image 2025-11-05 at 21.48.26.jpeg',
      bio: 'Peintre passionné, exerce le métier depuis 7 ans. Mes œuvres racontent l\'histoire de l\'Afrique à travers la peinture contemporaine.',
      isVerified: true,
      rating: 4.9,
      totalSales: 203,
      createdAt: DateTime(2018, 1, 1), // 7 ans d'expérience
      standName: 'Chez le Lion de la Plage',
      specialties: ['Peinture', 'Art contemporain', 'Portraits'],
      yearsOfExperience: 7,
      certifications: ['Artisan Certifié Grand Bassam'],
      qrCode: 'QR_LION_PLAGE',
    ),
    UserModel(
      id: 'art3',
      name: 'Ousmane Seyni',
      email: 'ousmane.seyni@nsapka.ci',
      phone: '+225 07 00 00 03',
      role: UserRole.artisan,
      location: 'Grand Bassam',
      profileImage: 'assets/logo/unnamed (2).jpg', // Logo car pas de photo
      bio: 'Vente d\'objets variés : sculptures coloniales, tabourets, colliers, supports téléphoniques en bois, trophées en bronze. Héritage père-fils. Équipe de 5 personnes dont 2 externes.',
      isVerified: true,
      rating: 4.7,
      totalSales: 189,
      createdAt: DateTime(2000, 1, 1),
      standName: 'Chez Ousmane',
      specialties: ['Sculptures coloniales', 'Mobilier', 'Bijoux', 'Bronze'],
      yearsOfExperience: 25,
      certifications: ['Maître Artisan', 'Héritage Familial'],
      qrCode: 'QR_OUSMANE',
    ),
    UserModel(
      id: 'art4',
      name: 'Azor Adams',
      email: 'azor.adams@nsapka.ci',
      phone: '+225 07 00 00 04',
      role: UserRole.artisan,
      location: 'Grand Bassam',
      profileImage: 'assets/logo/unnamed (2).jpg', // Logo car pas de photo
      bio: 'Artiste peintre spécialisé en art abstrait et art africain. Décoration intérieure. Parle français et anglais.',
      isVerified: true,
      rating: 4.8,
      totalSales: 134,
      createdAt: DateTime(2015, 1, 1),
      standName: 'Galerie Azor',
      specialties: ['Art abstrait', 'Art africain', 'Décoration intérieure', 'Peinture'],
      yearsOfExperience: 10,
      certifications: ['Artiste Peintre Certifié'],
      qrCode: 'QR_AZOR',
    ),
    UserModel(
      id: 'art5',
      name: 'Diarra Aboubakar',
      email: 'diarra.aboubakar@nsapka.ci',
      phone: '+225 07 00 00 05',
      role: UserRole.artisan,
      location: 'Grand Bassam',
      profileImage: 'assets/images/09a1f2114f16f1cdfdc935daddc2ea66.jpg',
      bio: 'Sculptures sur bois (ébène, yoroko…), grandes statues, utilise moule pour mannequins. Héritage familial depuis 1990, équipe de 4 personnes.',
      isVerified: true,
      rating: 4.9,
      totalSales: 167,
      createdAt: DateTime(1990, 1, 1), // Depuis 1990
      standName: 'L\'Atelier des Maîtres',
      specialties: ['Grandes sculptures', 'Ébène', 'Yoroko', 'Mannequins'],
      yearsOfExperience: 35,
      certifications: ['Maître Sculpteur', 'Héritage Familial', 'Expert Bois Précieux'],
      qrCode: 'QR_DIARRA',
    ),
  ];

  // PRODUITS MOCKÉS (basés sur les artisans réels)
  static final List<ProductModel> products = [
    // Produits Essi Reine
    ProductModel(
      id: 'prod1',
      name: 'Masque Baoulé Traditionnel',
      description: 'Masque artisanal sculpté à la main, représentant la tradition Baoulé. Pièce unique.',
      price: 25000,
      stock: 3,
      category: 'Masques',
      images: ['assets/images/WhatsApp Image 2025-11-05 at 21.48.27.jpeg'],
      artisanId: 'art1',
      artisanName: 'Essi Reine',
      artisanStand: 'Chez Maman Tranquille',
      rating: 4.9,
      reviewCount: 12,
      isLimitedEdition: true,
      limitedQuantity: 3,
      origin: 'Grand Bassam, Côte d\'Ivoire',
      tags: ['Traditionnel', 'Fait main', 'Unique'],
      createdAt: DateTime(2024, 10, 1),
    ),
    ProductModel(
      id: 'prod2',
      name: 'Assiette en Bois Sculpté',
      description: 'Assiette décorative en bois local, motifs traditionnels gravés.',
      price: 8500,
      stock: 15,
      category: 'Cuisine',
      images: ['assets/images/WhatsApp Image 2025-11-05 at 21.48.35 (1).jpeg'],
      artisanId: 'art1',
      artisanName: 'Essi Reine',
      artisanStand: 'Chez Maman Tranquille',
      rating: 4.7,
      reviewCount: 28,
      origin: 'Grand Bassam, Côte d\'Ivoire',
      tags: ['Cuisine', 'Décoration', 'Bois'],
      createdAt: DateTime(2024, 10, 15),
    ),
    ProductModel(
      id: 'prod3',
      name: 'Natte Artisanale',
      description: 'Natte tissée à la main, idéale pour la décoration ou usage quotidien.',
      price: 12000,
      stock: 8,
      category: 'Décoration',
      images: ['assets/images/WhatsApp Image 2025-11-05 at 21.48.35 (1).jpeg'],
      artisanId: 'art1',
      artisanName: 'Essi Reine',
      artisanStand: 'Chez Maman Tranquille',
      rating: 4.5,
      reviewCount: 19,
      origin: 'Grand Bassam, Côte d\'Ivoire',
      tags: ['Tissage', 'Traditionnel'],
      createdAt: DateTime(2024, 9, 20),
    ),
    
    // Produits Dje David
    ProductModel(
      id: 'prod4',
      name: 'Tableau Abstrait "Soleil d\'Afrique"',
      description: 'Peinture acrylique sur toile, représentant un coucher de soleil africain.',
      price: 45000,
      stock: 1,
      category: 'Peinture',
      images: ['assets/images/WhatsApp Image 2025-11-05 at 21.48.26.jpeg'],
      videoUrl: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
      artisanId: 'art2',
      artisanName: 'Dje David',
      artisanStand: 'Chez le Lion de la Plage',
      rating: 5.0,
      reviewCount: 8,
      isLimitedEdition: true,
      limitedQuantity: 1,
      origin: 'Grand Bassam, Côte d\'Ivoire',
      tags: ['Art', 'Peinture', 'Unique', 'Moderne'],
      createdAt: DateTime(2024, 10, 25),
    ),
    ProductModel(
      id: 'prod5',
      name: 'Sculpture "Guerrier Akan"',
      description: 'Sculpture en bois représentant un guerrier Akan. Hauteur 60cm.',
      price: 38000,
      stock: 2,
      category: 'Sculpture',
      images: ['assets/images/WhatsApp Image 2025-11-05 at 21.48.30.jpeg'],
      artisanId: 'art2',
      artisanName: 'Dje David',
      artisanStand: 'Chez le Lion de la Plage',
      rating: 4.8,
      reviewCount: 15,
      isLimitedEdition: true,
      limitedQuantity: 2,
      origin: 'Grand Bassam, Côte d\'Ivoire',
      tags: ['Sculpture', 'Bois', 'Traditionnel'],
      createdAt: DateTime(2024, 10, 10),
    ),
    
    // Produits Ousmane Seyni
    ProductModel(
      id: 'prod6',
      name: 'Tabouret Traditionnel Senoufo',
      description: 'Tabouret en bois massif, design Senoufo authentique.',
      price: 22000,
      stock: 10,
      category: 'Mobilier',
      images: ['assets/images/WhatsApp Image 2025-11-05 at 21.48.36 (1).jpeg'],
      artisanId: 'art3',
      artisanName: 'Ousmane Seyni',
      artisanStand: 'Chez Ousmane',
      rating: 4.6,
      reviewCount: 34,
      origin: 'Grand Bassam, Côte d\'Ivoire',
      tags: ['Mobilier', 'Bois', 'Traditionnel'],
      createdAt: DateTime(2024, 9, 5),
    ),
    ProductModel(
      id: 'prod7',
      name: 'Trophée en Bronze "Excellence"',
      description: 'Trophée artisanal en bronze, idéal pour récompenses et cérémonies.',
      price: 55000,
      stock: 5,
      category: 'Décoration',
      images: ['assets/images/WhatsApp Image 2025-11-05 at 21.48.35.jpeg'],
      artisanId: 'art3',
      artisanName: 'Ousmane Seyni',
      artisanStand: 'Chez Ousmane',
      rating: 4.9,
      reviewCount: 11,
      origin: 'Grand Bassam, Côte d\'Ivoire',
      tags: ['Bronze', 'Luxe', 'Cérémonie'],
      createdAt: DateTime(2024, 10, 18),
    ),
    
    // Produits Azor Adams
    ProductModel(
      id: 'prod8',
      name: 'Toile Abstraite "Rythmes Africains"',
      description: 'Œuvre abstraite inspirée des rythmes et couleurs d\'Afrique. 80x100cm.',
      price: 65000,
      stock: 1,
      category: 'Peinture',
      images: ['assets/images/WhatsApp Image 2025-11-05 at 21.48.35.jpeg'],
      videoUrl: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
      artisanId: 'art4',
      artisanName: 'Azor Adams',
      artisanStand: 'Azor Art Gallery',
      rating: 5.0,
      reviewCount: 6,
      isLimitedEdition: true,
      limitedQuantity: 1,
      origin: 'Grand Bassam, Côte d\'Ivoire',
      tags: ['Art moderne', 'Abstrait', 'Unique'],
      createdAt: DateTime(2024, 10, 28),
    ),
    
    // Produits Diarra Aboubakar
    ProductModel(
      id: 'prod9',
      name: 'Grande Statue Ébène "Ancêtres"',
      description: 'Statue monumentale en ébène, représentant les ancêtres. Hauteur 1m50.',
      price: 125000,
      stock: 1,
      category: 'Sculpture',
      images: ['assets/images/WhatsApp Image 2025-11-05 at 21.48.35 (1).jpeg'],
      artisanId: 'art5',
      artisanName: 'Diarra Aboubakar',
      artisanStand: 'Atelier Diarra',
      rating: 4.9,
      reviewCount: 4,
      isLimitedEdition: true,
      limitedQuantity: 1,
      origin: 'Grand Bassam, Côte d\'Ivoire',
      tags: ['Sculpture', 'Ébène', 'Monumental', 'Luxe'],
      createdAt: DateTime(2024, 10, 5),
    ),
    ProductModel(
      id: 'prod10',
      name: 'Mannequin Décoratif en Yoroko',
      description: 'Mannequin artisanal en bois de yoroko, idéal pour boutiques ou décoration.',
      price: 48000,
      stock: 3,
      category: 'Décoration',
      images: ['assets/images/WhatsApp Image 2025-11-05 at 21.48.30.jpeg'],
      artisanId: 'art5',
      artisanName: 'Diarra Aboubakar',
      artisanStand: 'Atelier Diarra',
      rating: 4.7,
      reviewCount: 9,
      origin: 'Grand Bassam, Côte d\'Ivoire',
      tags: ['Bois', 'Décoration', 'Professionnel'],
      createdAt: DateTime(2024, 9, 28),
    ),
  ];

  // ACHETEURS MOCKÉS
  static final List<UserModel> buyers = [
    UserModel(
      id: 'buy1',
      name: 'Marie Kouassi',
      email: 'marie.k@email.ci',
      phone: '+225 07 11 11 11',
      role: UserRole.buyer,
      location: 'Abidjan',
      createdAt: DateTime(2024, 8, 10),
    ),
    UserModel(
      id: 'buy2',
      name: 'Jean-Pierre Martin',
      email: 'jp.martin@email.fr',
      phone: '+33 6 12 34 56 78',
      role: UserRole.buyer,
      location: 'Paris, France',
      createdAt: DateTime(2024, 9, 15),
    ),
  ];

  // COMMUNITY AGENTS
  static final List<UserModel> agents = [
    UserModel(
      id: 'agent1',
      name: 'Konan Yao',
      email: 'konan.yao@nsapka.ci',
      phone: '+225 07 22 22 22',
      role: UserRole.communityAgent,
      location: 'Grand Bassam',
      isVerified: true,
      createdAt: DateTime(2024, 1, 1),
    ),
  ];

  // ARTICLES DE BLOG SUR L'ARTISANAT AFRICAIN
  static final List<BlogArticleModel> blogArticles = [
    BlogArticleModel(
      id: 'blog1',
      title: 'L\'Art du Masque Baoulé : Entre Tradition et Spiritualité',
      subtitle: 'Découvrez l\'histoire fascinante des masques Baoulé, symboles de la culture ivoirienne',
      content: '''
Les masques Baoulé sont bien plus que de simples objets décoratifs. Ils incarnent l'âme et l'histoire du peuple Baoulé de Côte d'Ivoire.

**L'Histoire des Masques Baoulé**

Au XVIIIe siècle, la reine Abla Pokou mena son peuple vers l'ouest pour échapper aux guerres. Pour traverser le fleuve Comoé, elle dut sacrifier son fils unique. Ce sacrifice donna naissance au nom "Baoulé" qui signifie "l'enfant est mort".

Les masques Baoulé perpétuent cette mémoire collective. Chaque masque raconte une histoire, représente un ancêtre ou incarne un esprit protecteur.

**Les Types de Masques**

1. **Goli** : Masque de divertissement utilisé lors des cérémonies festives
2. **Mblo** : Portrait d'une personne réelle, célébrant sa beauté et ses qualités
3. **Kplé-Kplé** : Masque de justice utilisé lors des jugements traditionnels

**La Fabrication Artisanale**

Chaque masque est sculpté à la main dans du bois noble (ébène, acajou, iroko). Le processus peut prendre plusieurs semaines :

- Sélection du bois selon les critères spirituels
- Sculpture minutieuse des traits
- Polissage et finitions
- Bénédiction par les anciens

**Valeur Culturelle Aujourd'hui**

Ces masques ne sont pas de simples souvenirs touristiques. Ils représentent :
- L'identité culturelle ivoirienne
- Le savoir-faire ancestral transmis de génération en génération
- Un lien vivant avec les ancêtres
- Une forme d'art reconnue mondialement

En achetant un masque Baoulé authentique, vous ne possédez pas qu'un objet : vous devenez gardien d'une histoire millénaire.
      ''',
      author: 'Dr. Kouamé Adjoua',
      authorRole: 'Historienne de l\'Art Africain',
      coverImage: 'assets/images/WhatsApp Image 2025-11-05 at 21.48.27.jpeg',
      tags: ['Culture', 'Histoire', 'Baoulé', 'Masques'],
      category: 'Histoire',
      readTime: 8,
      publishedAt: DateTime(2024, 10, 15),
      likes: 234,
      comments: 45,
      isFeatured: true,
    ),
    
    BlogArticleModel(
      id: 'blog2',
      title: 'Le Batik Africain : L\'Art de la Teinture Traditionnelle',
      subtitle: 'Plongez dans l\'univers coloré du batik, technique ancestrale de teinture sur tissu',
      content: '''
Le batik est une technique de teinture sur tissu qui remonte à des siècles en Afrique de l'Ouest. Cette méthode artisanale crée des motifs uniques qui racontent des histoires.

**Origines et Signification**

Le mot "batik" vient du javanais "ambatik" qui signifie "écrire avec de la cire". En Afrique, cette technique s'est développée de manière unique, intégrant des symboles et motifs propres à chaque ethnie.

**Le Processus de Création**

1. **Préparation du tissu** : Lavage et séchage du coton blanc
2. **Application de la cire** : Dessin des motifs à la cire chaude
3. **Teinture** : Immersion dans des bains de couleur naturelle
4. **Retrait de la cire** : Révélation des motifs
5. **Répétition** : Pour créer des motifs multicolores

**Symbolisme des Motifs**

Chaque motif a une signification :
- **Spirales** : Le cycle de la vie
- **Lignes brisées** : Les défis surmontés
- **Cercles** : L'unité et la communauté
- **Étoiles** : Les ancêtres qui veillent

**Impact Économique et Social**

Le batik n'est pas qu'un art, c'est aussi :
- Une source de revenus pour des milliers de familles
- Un moyen de préserver les traditions
- Une forme d'expression artistique contemporaine
- Un pont entre générations

**Le Batik Moderne**

Aujourd'hui, les artisans innovent en créant :
- Des vêtements de mode contemporaine
- Des accessoires de décoration
- Des œuvres d'art murales
- Des collaborations avec des designers internationaux

Chaque pièce de batik est unique. Les variations de température, de temps de teinture et de gestes de l'artisan font que deux pièces ne seront jamais identiques.
      ''',
      author: 'Aminata Traoré',
      authorRole: 'Artisane et Formatrice',
      coverImage: 'assets/images/WhatsApp Image 2025-11-05 at 21.48.35 (1).jpeg',
      tags: ['Artisanat', 'Textile', 'Batik', 'Tradition'],
      category: 'Artisanat',
      readTime: 6,
      publishedAt: DateTime(2024, 10, 20),
      likes: 189,
      comments: 32,
      isFeatured: true,
    ),
    
    BlogArticleModel(
      id: 'blog3',
      title: 'Sculpture sur Bois : L\'Héritage des Maîtres Artisans',
      subtitle: 'Comment les sculpteurs africains transforment le bois en œuvres d\'art vivantes',
      content: '''
La sculpture sur bois est l'une des formes d'art les plus anciennes d'Afrique. Elle incarne la connexion profonde entre l'homme, la nature et le spirituel.

**Les Bois Sacrés**

Chaque essence de bois a sa signification :
- **Ébène** : Force et longévité
- **Acajou** : Royauté et prestige
- **Iroko** : Protection spirituelle
- **Teck** : Résistance et durabilité

**L'Apprentissage du Métier**

Devenir sculpteur prend des années :
- 3-5 ans d'apprentissage auprès d'un maître
- Apprentissage des rituels et prières
- Maîtrise des outils traditionnels
- Compréhension des symboles culturels

**Techniques Traditionnelles**

Les sculpteurs utilisent des outils simples mais efficaces :
- Herminettes pour dégrossir
- Ciseaux à bois pour les détails
- Râpes et limes pour le polissage
- Huiles naturelles pour la finition

**Thèmes Récurrents**

Les sculptures racontent des histoires :
- **Maternité** : Célébration de la vie
- **Guerriers** : Courage et protection
- **Ancêtres** : Mémoire collective
- **Animaux totems** : Connexion spirituelle

**Préservation du Savoir-Faire**

Face à la modernisation, les artisans luttent pour :
- Transmettre leurs connaissances aux jeunes
- Valoriser leur travail économiquement
- Innover tout en respectant les traditions
- Obtenir une reconnaissance internationale

**L'Impact Environnemental**

Les sculpteurs responsables :
- Utilisent du bois de sources durables
- Replantent des arbres
- Évitent les essences menacées
- Travaillent avec des coopératives forestières

Chaque sculpture est une prière, un hommage aux ancêtres et un legs pour les générations futures.
      ''',
      author: 'Kofi Mensah',
      authorRole: 'Maître Sculpteur',
      coverImage: 'assets/images/WhatsApp Image 2025-11-05 at 21.48.30.jpeg',
      tags: ['Sculpture', 'Bois', 'Tradition', 'Artisanat'],
      category: 'Artisanat',
      readTime: 7,
      publishedAt: DateTime(2024, 10, 25),
      likes: 156,
      comments: 28,
      isFeatured: false,
    ),
    
    BlogArticleModel(
      id: 'blog4',
      title: 'Grand Bassam : Berceau de l\'Artisanat Ivoirien',
      subtitle: 'Découvrez l\'histoire de cette ville coloniale devenue capitale de l\'artisanat',
      content: '''
Grand Bassam n'est pas qu'une ville historique classée au patrimoine mondial de l'UNESCO. C'est le cœur battant de l'artisanat ivoirien.

**Histoire de Grand Bassam**

Fondée au XVe siècle, Grand Bassam fut :
- Première capitale de la Côte d'Ivoire (1893-1900)
- Centre commercial majeur
- Point de rencontre des cultures
- Aujourd'hui : Ville d'art et d'histoire

**Le Quartier Artisanal**

Le marché artisanal de Grand Bassam regroupe :
- Plus de 200 artisans
- 15 spécialités différentes
- Des générations de savoir-faire
- Une ambiance unique et authentique

**Les Artisans de Bassam**

Rencontrez les maîtres artisans :
- **Essi Reine** : 32 ans de métier, spécialiste des masques
- **Dje David** : Peintre et sculpteur reconnu
- **Ousmane Seyni** : Le plus grand atelier du quartier
- **Diarra Aboubakar** : Maître des sculptures monumentales

**Pourquoi Bassam ?**

La ville offre des conditions uniques :
- Proximité de la mer (inspiration)
- Tourisme culturel important
- Communauté d'artisans solidaire
- Soutien des autorités locales

**Défis et Opportunités**

Les artisans font face à :
- Concurrence de produits importés
- Besoin de modernisation
- Difficulté d'accès aux marchés internationaux
- Manque de visibilité en ligne

**N'SAPKA : La Solution Numérique**

Notre plateforme aide les artisans à :
- Vendre en ligne 24/7
- Atteindre des clients internationaux
- Gérer leur stock facilement
- Raconter leur histoire

Visiter Grand Bassam, c'est voyager dans le temps tout en soutenant l'avenir de l'artisanat africain.
      ''',
      author: 'N\'SAPKA Team',
      authorRole: 'Équipe Éditoriale',
      coverImage: 'assets/images/image.png',
      tags: ['Grand Bassam', 'Histoire', 'Artisanat', 'Côte d\'Ivoire'],
      category: 'Culture',
      readTime: 5,
      publishedAt: DateTime(2024, 10, 28),
      likes: 298,
      comments: 67,
      isFeatured: true,
    ),
    
    BlogArticleModel(
      id: 'blog5',
      title: 'Pourquoi Acheter de l\'Artisanat Authentique ?',
      subtitle: 'L\'impact social, culturel et économique de vos achats artisanaux',
      content: '''
Chaque achat d'artisanat authentique est un acte de préservation culturelle et de soutien économique.

**Impact Économique Direct**

Quand vous achetez un produit artisanal :
- 80% du prix va directement à l'artisan
- Soutien à une famille entière (moyenne 5 personnes)
- Création d'emplois locaux
- Développement de l'économie locale

**Préservation Culturelle**

Vous contribuez à :
- Maintenir des techniques ancestrales vivantes
- Encourager la transmission du savoir-faire
- Valoriser l'identité culturelle
- Documenter l'histoire pour les générations futures

**Qualité et Unicité**

Les produits artisanaux offrent :
- Pièces uniques, jamais identiques
- Qualité supérieure aux produits de masse
- Durabilité et longévité
- Histoire et âme dans chaque objet

**Impact Environnemental**

L'artisanat traditionnel est :
- Écologique (matériaux naturels)
- Durable (techniques éprouvées)
- Local (pas de transport intercontinental)
- Respectueux de la nature

**Connexion Humaine**

Acheter artisanal, c'est :
- Connaître l'histoire du créateur
- Dialoguer avec l'artisan
- Comprendre le processus de création
- Créer un lien authentique

**Comment Reconnaître l'Authenticité ?**

Vérifiez :
- Nom de l'artisan et son histoire
- Photos du processus de création
- Variations naturelles (pas de perfection industrielle)
- Matériaux locaux et traditionnels
- Prix juste (ni trop bas, ni excessif)

**Le Rôle de N'SAPKA**

Nous garantissons :
- Vérification de chaque artisan
- Traçabilité des produits
- Prix équitables
- Soutien aux artisans analphabètes

Votre achat est un vote pour un monde plus juste, plus beau et plus authentique.
      ''',
      author: 'Marie Kouadio',
      authorRole: 'Économiste Sociale',
      coverImage: 'assets/images/atelier-africain-artisan-djembe.jpg',
      tags: ['Impact Social', 'Économie', 'Authenticité'],
      category: 'Culture',
      readTime: 6,
      publishedAt: DateTime(2024, 11, 1),
      likes: 412,
      comments: 89,
      isFeatured: true,
    ),
  ];

  // PRODUITS ARTISANAUX AUTHENTIQUES
  static final List<ProductModel> productsData = [
    // PRODUITS DE ESSI REINE (art1) - Masques et objets décoratifs
    ProductModel(
      id: 'prod1',
      name: 'Masque Sud Africain Traditionnel',
      description: 'Masque traditionnel sud-africain en bois sculpté à la main. Représente la sagesse ancestrale et la beauté culturelle africaine. Pièce unique réalisée avec des techniques ancestrales.',
      price: 45000,
      stock: 5,
      category: 'Masques',
      images: ['assets/images/WhatsApp Image 2025-11-05 at 21.48.27.jpeg'],
      artisanId: 'art1',
      artisanName: 'Essi Reine',
      rating: 4.8,
      createdAt: DateTime(2024, 10, 1),
      tags: ['Masque', 'Traditionnel', 'Sud-Africain', 'Sculpture'],
      origin: 'Grand Bassam, Côte d\'Ivoire',
    ),

    // PRODUITS DE DJE DAVID (art2) - Peintures et sculptures
    ProductModel(
      id: 'prod2',
      name: 'Sculpture "Les Colons"',
      description: 'Sculpture artistique représentant l\'histoire coloniale à travers le regard contemporain d\'un peintre africain. Œuvre unique qui raconte l\'histoire de l\'Afrique moderne.',
      price: 120000,
      stock: 1,
      category: 'Sculpture',
      images: ['assets/images/WhatsApp Image 2025-11-05 at 21.48.25.jpeg'],
      artisanId: 'art2',
      artisanName: 'Dje David',
      rating: 4.9,
      createdAt: DateTime(2024, 10, 5),
      tags: ['Sculpture', 'Histoire', 'Art contemporain', 'Unique'],
      origin: 'Grand Bassam, Côte d\'Ivoire',
    ),

    ProductModel(
      id: 'prod3',
      name: 'Sculpture Femme Modèle',
      description: 'Magnifique sculpture représentant la femme africaine dans toute sa grâce et sa beauté. Pièce artistique réalisée avec passion, symbole de la féminité et de la force.',
      price: 85000,
      stock: 3,
      category: 'Sculpture',
      images: ['assets/images/WhatsApp Image 2025-11-05 at 21.48.28.jpeg'],
      artisanId: 'art2',
      artisanName: 'Dje David',
      rating: 4.9,
      createdAt: DateTime(2024, 10, 8),
      tags: ['Sculpture', 'Femme', 'Beauté', 'Art africain'],
      origin: 'Grand Bassam, Côte d\'Ivoire',
    ),

    ProductModel(
      id: 'prod4',
      name: 'Poupée Africaine Décorative',
      description: 'Poupée artisanale africaine, parfaite pour la décoration intérieure. Réalisée avec des tissus traditionnels et des perles, elle apporte une touche authentique à votre intérieur.',
      price: 25000,
      stock: 8,
      category: 'Décoration',
      images: ['assets/images/WhatsApp Image 2025-11-05 at 21.48.35.jpeg'],
      artisanId: 'art2',
      artisanName: 'Dje David',
      rating: 4.8,
      createdAt: DateTime(2024, 10, 10),
      tags: ['Poupée', 'Décoration', 'Tissus', 'Artisanat'],
      origin: 'Grand Bassam, Côte d\'Ivoire',
    ),

    ProductModel(
      id: 'prod5',
      name: 'Bijoux Artisanaux Traditionnels',
      description: 'Collection de bijoux africains traditionnels. Collier et boucles d\'oreilles en perles et matériaux naturels, symboles de la culture africaine.',
      price: 35000,
      stock: 6,
      category: 'Bijoux',
      images: ['assets/images/WhatsApp Image 2025-11-05 at 21.48.35.jpeg'],
      artisanId: 'art2',
      artisanName: 'Dje David',
      rating: 4.7,
      createdAt: DateTime(2024, 10, 12),
      tags: ['Bijoux', 'Perles', 'Tradition', 'Afrique'],
      origin: 'Grand Bassam, Côte d\'Ivoire',
    ),

    ProductModel(
      id: 'prod6',
      name: 'Tasse Africaine Artisanale',
      description: 'Tasse en céramique artisanale avec motifs africains traditionnels. Parfaite pour votre café ou thé matinal, réalisée à la main avec amour.',
      price: 15000,
      stock: 12,
      category: 'Cuisine',
      images: ['assets/images/WhatsApp Image 2025-11-05 at 21.48.36.jpeg'],
      artisanId: 'art2',
      artisanName: 'Dje David',
      rating: 4.6,
      createdAt: DateTime(2024, 10, 15),
      tags: ['Tasse', 'Céramique', 'Cuisine', 'Artisanale'],
      origin: 'Grand Bassam, Côte d\'Ivoire',
    ),

    ProductModel(
      id: 'prod7',
      name: 'Carte Africaine Boussole',
      description: 'Carte artistique de l\'Afrique avec boussole intégrée. Œuvre décorative unique qui combine cartographie et art africain contemporain.',
      price: 55000,
      stock: 4,
      category: 'Décoration',
      images: ['assets/images/WhatsApp Image 2025-11-05 at 21.48.36.jpeg'],
      artisanId: 'art2',
      artisanName: 'Dje David',
      rating: 4.8,
      createdAt: DateTime(2024, 10, 18),
      tags: ['Carte', 'Boussole', 'Décoration', 'Afrique'],
      origin: 'Grand Bassam, Côte d\'Ivoire',
    ),

    // PRODUITS AVEC VIDÉO
    ProductModel(
      id: 'prod8',
      name: 'Outils de Cuisine Traditionnels',
      description: 'Ensemble complet d\'outils de cuisine africains traditionnels. Mortier et pilon artisanaux, ustensiles en bois noble pour une cuisine authentique.',
      price: 75000,
      stock: 3,
      category: 'Cuisine',
      images: ['assets/images/WhatsApp Image 2025-11-05 at 21.48.36.jpeg'],
      videoUrl: 'assets/images/WhatsApp Video 2025-11-05 at 21.48.25.mp4',
      artisanId: 'art2',
      artisanName: 'Dje David',
      rating: 4.9,
      createdAt: DateTime(2024, 10, 20),
      tags: ['Outils', 'Cuisine', 'Traditionnel', 'Mortier'],
      origin: 'Grand Bassam, Côte d\'Ivoire',
    ),

    // PRODUITS DE OUSMANE SEYNI (art3) - Sculptures coloniales et mobilier
    ProductModel(
      id: 'prod9',
      name: 'Tableau Vitre "L\'Union Fait la Force"',
      description: 'Magnifique tableau vitré représentant l\'union et la solidarité africaine. Œuvre artistique qui transmet un message d\'espoir et d\'unité.',
      price: 95000,
      stock: 2,
      category: 'Décoration',
      images: ['assets/images/WhatsApp Image 2025-11-05 at 21.48.39.jpeg'],
      artisanId: 'art3',
      artisanName: 'Ousmane Seyni',
      rating: 4.9,
      createdAt: DateTime(2024, 10, 22),
      tags: ['Tableau', 'Vitre', 'Union', 'Solidarité'],
      origin: 'Grand Bassam, Côte d\'Ivoire',
    ),

    ProductModel(
      id: 'prod10',
      name: 'Miroir Artisanal Africain',
      description: 'Miroir artisanal avec cadre sculpté représentant des motifs africains traditionnels. Pièce unique qui apporte élégance et authenticité à votre intérieur.',
      price: 65000,
      stock: 3,
      category: 'Décoration',
      images: ['assets/images/WhatsApp Image 2025-11-05 at 21.48.40.jpeg'],
      artisanId: 'art3',
      artisanName: 'Ousmane Seyni',
      rating: 4.7,
      createdAt: DateTime(2024, 10, 25),
      tags: ['Miroir', 'Artisanal', 'Cadre', 'Décoration'],
      origin: 'Grand Bassam, Côte d\'Ivoire',
    ),

    ProductModel(
      id: 'prod11',
      name: 'Sculpture Biche Élégante',
      description: 'Sculpture gracieuse représentant une biche africaine. Réalisée dans un bois noble, elle apporte une touche de nature et de sérénité à votre décoration.',
      price: 78000,
      stock: 2,
      category: 'Sculpture',
      images: ['assets/images/WhatsApp Image 2025-11-05 at 21.48.41.jpeg'],
      artisanId: 'art3',
      artisanName: 'Ousmane Seyni',
      rating: 4.8,
      createdAt: DateTime(2024, 10, 28),
      tags: ['Sculpture', 'Biche', 'Nature', 'Sérénité'],
      origin: 'Grand Bassam, Côte d\'Ivoire',
    ),

    ProductModel(
      id: 'prod12',
      name: 'Outils Personnalisés',
      description: 'Ensemble d\'outils artisanaux personnalisés. Objets utilitaires devenus œuvres d\'art, parfaits pour la décoration ou l\'usage quotidien.',
      price: 42000,
      stock: 5,
      category: 'Décoration',
      images: ['assets/images/WhatsApp Image 2025-11-05 at 21.48.42.jpeg'],
      artisanId: 'art3',
      artisanName: 'Ousmane Seyni',
      rating: 4.6,
      createdAt: DateTime(2024, 10, 30),
      tags: ['Outils', 'Personnalisés', 'Art', 'Utilitaires'],
      origin: 'Grand Bassam, Côte d\'Ivoire',
    ),

    ProductModel(
      id: 'prod13',
      name: 'Tableau Philosophique "Les Trois Signes"',
      description: '"Ne rien voir, ne rien entendre, ne rien dire pour mieux vivre". Œuvre philosophique africaine qui transmet une sagesse ancestrale sur la paix intérieure.',
      price: 68000,
      stock: 1,
      category: 'Décoration',
      images: ['assets/images/WhatsApp Image 2025-11-05 at 21.48.48.jpeg'],
      artisanId: 'art3',
      artisanName: 'Ousmane Seyni',
      rating: 4.9,
      createdAt: DateTime(2024, 11, 1),
      tags: ['Tableau', 'Philosophie', 'Sagesse', 'Paix'],
      origin: 'Grand Bassam, Côte d\'Ivoire',
    ),

    ProductModel(
      id: 'prod14',
      name: 'Bijoux Traditionnels Amalatik',
      description: 'Collier traditionnel Amalatik, bijou ancestral africain symbole de protection et de beauté. Réalisé avec des matériaux naturels authentiques.',
      price: 45000,
      stock: 4,
      category: 'Bijoux',
      images: ['assets/images/WhatsApp Image 2025-11-05 at 22.13.59.jpeg'],
      artisanId: 'art3',
      artisanName: 'Ousmane Seyni',
      rating: 4.8,
      createdAt: DateTime(2024, 11, 3),
      tags: ['Bijoux', 'Amalatik', 'Protection', 'Tradition'],
      origin: 'Grand Bassam, Côte d\'Ivoire',
    ),

    // PRODUITS DE AZOR ADAMS (art4) - Peintures
    ProductModel(
      id: 'prod15',
      name: 'Peinture "Chemin de la Vie"',
      description: 'Tableau représentant le chemin de la vie africaine, des origines à l\'avenir. Œuvre abstraite qui raconte l\'histoire du continent africain.',
      price: 125000,
      stock: 1,
      category: 'Peinture',
      images: ['assets/images/WhatsApp Image 2025-11-05 at 22.14.14.jpeg'],
      artisanId: 'art4',
      artisanName: 'Azor Adams',
      rating: 4.9,
      createdAt: DateTime(2024, 11, 5),
      tags: ['Peinture', 'Chemin de vie', 'Afrique', 'Abstrait'],
      origin: 'Grand Bassam, Côte d\'Ivoire',
    ),

    ProductModel(
      id: 'prod16',
      name: 'Portrait Femme Africaine',
      description: 'Magnifique portrait d\'une femme africaine dans le style traditionnel. Œuvre qui capture la beauté et la dignité des femmes du continent.',
      price: 95000,
      stock: 1,
      category: 'Peinture',
      images: ['assets/images/WhatsApp Image 2025-11-05 at 22.14.14.jpeg'],
      artisanId: 'art4',
      artisanName: 'Azor Adams',
      rating: 4.9,
      createdAt: DateTime(2024, 11, 7),
      tags: ['Portrait', 'Femme', 'Afrique', 'Tradition'],
      origin: 'Grand Bassam, Côte d\'Ivoire',
    ),

    // PRODUITS DIVERS
    ProductModel(
      id: 'prod17',
      name: 'Termorce Mini Artisanale',
      description: 'Petite termorce artisanale décorative. Objet traditionnel africain utilisé autrefois pour allumer les feux, aujourd\'hui pièce de collection.',
      price: 18000,
      stock: 7,
      category: 'Décoration',
      images: ['assets/images/WhatsApp Image 2025-11-05 at 21.49.03.jpeg'],
      artisanId: 'art1',
      artisanName: 'Essi Reine',
      rating: 4.5,
      createdAt: DateTime(2024, 11, 9),
      tags: ['Termorce', 'Mini', 'Traditionnel', 'Collection'],
      origin: 'Grand Bassam, Côte d\'Ivoire',
    ),

    ProductModel(
      id: 'prod18',
      name: 'Giraffe Chiffon Décorative',
      description: 'Charmante giraffe en tissu chiffon, parfaite pour décorer une chambre d\'enfant ou apporter une touche ludique à votre intérieur.',
      price: 22000,
      stock: 10,
      category: 'Décoration',
      images: ['assets/images/WhatsApp Image 2025-11-05 at 21.49.08.jpeg'],
      artisanId: 'art1',
      artisanName: 'Essi Reine',
      rating: 4.7,
      createdAt: DateTime(2024, 11, 11),
      tags: ['Giraffe', 'Chiffon', 'Décoration', 'Ludique'],
      origin: 'Grand Bassam, Côte d\'Ivoire',
    ),

    ProductModel(
      id: 'prod19',
      name: 'Support "Union Fait la Force"',
      description: 'Support décoratif avec le message "Union fait la Force". Pièce artistique qui promeut l\'unité et la solidarité africaine.',
      price: 32000,
      stock: 6,
      category: 'Décoration',
      images: ['assets/images/WhatsApp Image 2025-11-05 at 22.13.58.jpeg'],
      artisanId: 'art3',
      artisanName: 'Ousmane Seyni',
      rating: 4.8,
      createdAt: DateTime(2024, 11, 13),
      tags: ['Support', 'Union', 'Solidarité', 'Message'],
      origin: 'Grand Bassam, Côte d\'Ivoire',
    ),

    ProductModel(
      id: 'prod20',
      name: 'Collier Traditionnel Amalatik',
      description: 'Authentique collier Amalatik traditionnel. Bijou de protection ancestrale, symbole de la culture et de la spiritualité africaine.',
      price: 55000,
      stock: 3,
      category: 'Bijoux',
      images: ['assets/images/WhatsApp Image 2025-11-05 at 22.13.59.jpeg'],
      artisanId: 'art2',
      artisanName: 'Dje David',
      rating: 4.9,
      createdAt: DateTime(2024, 11, 15),
      tags: ['Collier', 'Amalatik', 'Protection', 'Spiritualité'],
      origin: 'Grand Bassam, Côte d\'Ivoire',
    ),

    // PRODUIT AVEC VIDÉO DE PRÉSENTATION
    ProductModel(
      id: 'prod21',
      name: 'Présentation Artistique Boubou Traditionnel',
      description: 'Présentation artistique et culturelle du boubou traditionnel africain. Vidéo explicative montrant l\'art et la signification de ce vêtement ancestral.',
      price: 0, // Gratuit - contenu éducatif
      stock: 999,
      category: 'Culture',
      images: ['assets/images/presentation_boubou.jpg'],
      videoUrl: 'assets/images/WhatsApp Video 2025-11-05 at 22.14.04.mp4',
      artisanId: 'art1',
      artisanName: 'Essi Reine',
      rating: 5.0,
      createdAt: DateTime(2024, 11, 17),
      tags: ['Boubou', 'Culture', 'Tradition', 'Éducation'],
      origin: 'Grand Bassam, Côte d\'Ivoire',
    ),
  ];

  // AVIS CLIENTS
  static final List<ReviewModel> reviews = [
    ReviewModel(
      id: 'rev1',
      productId: 'prod1',
      userId: 'user1',
      userName: 'Marie Dupont',
      userImage: null,
      rating: 5.0,
      comment: 'Masque absolument magnifique ! La qualité de la sculpture est exceptionnelle. Il apporte une touche authentique à ma décoration. L\'artisan a pris le temps de m\'expliquer l\'histoire culturelle derrière cette pièce.',
      images: [],
      createdAt: DateTime(2024, 11, 15),
      isVerifiedPurchase: true,
      helpfulCount: 12,
    ),
    ReviewModel(
      id: 'rev2',
      productId: 'prod2',
      userId: 'user2',
      userName: 'Jean Kouassi',
      userImage: null,
      rating: 5.0,
      comment: 'Cette sculpture "Les Colons" est une œuvre d\'art exceptionnelle. Elle raconte l\'histoire de notre continent avec beaucoup de sensibilité. La livraison était parfaite et bien protégée.',
      images: ['assets/images/review_sculpture.jpg'],
      createdAt: DateTime(2024, 11, 10),
      isVerifiedPurchase: true,
      helpfulCount: 8,
      artisanResponse: 'Merci infiniment pour votre retour positif ! Cette sculpture représente effectivement un chapitre important de notre histoire. Je suis ravi qu\'elle trouve sa place chez vous.',
      artisanResponseDate: DateTime(2024, 11, 11),
    ),
    ReviewModel(
      id: 'rev3',
      productId: 'prod3',
      userId: 'user3',
      userName: 'Sarah Johnson',
      userImage: null,
      rating: 4.5,
      comment: 'Très belle sculpture représentant la femme africaine. La finition est remarquable et le bois utilisé est de grande qualité. Petit délai de livraison mais justifié par la qualité.',
      images: [],
      createdAt: DateTime(2024, 11, 5),
      isVerifiedPurchase: true,
      helpfulCount: 15,
    ),
    ReviewModel(
      id: 'rev4',
      productId: 'prod4',
      userId: 'user4',
      userName: 'Pierre Martin',
      userImage: null,
      rating: 5.0,
      comment: 'Poupée artisanale adorable ! Parfaite pour décorer la chambre de ma fille. Les tissus traditionnels utilisés sont magnifiques. Merci pour cette pièce authentique.',
      images: ['assets/images/review_poupee.jpg'],
      createdAt: DateTime(2024, 10, 28),
      isVerifiedPurchase: true,
      helpfulCount: 6,
    ),
    ReviewModel(
      id: 'rev5',
      productId: 'prod5',
      userId: 'user5',
      userName: 'Amélie Dubois',
      userImage: null,
      rating: 4.0,
      comment: 'Joli collier traditionnel. Les perles sont bien travaillées et la couleur est superbe. Correspond parfaitement à la description. Service client très réactif.',
      images: [],
      createdAt: DateTime(2024, 10, 20),
      isVerifiedPurchase: true,
      helpfulCount: 9,
    ),
  ];

  // COMMANDES
  static final List<OrderModel> orders = [
    OrderModel(
      id: 'order001',
      buyerId: 'buy1',
      buyerName: 'Marie Dupont',
      artisanId: 'art2',
      artisanName: 'Dje David',
      items: [
        OrderItem(
          productId: 'prod2',
          productName: 'Sculpture "Les Colons"',
          productImage: 'assets/images/WhatsApp Image 2025-11-05 at 21.48.25.jpeg',
          quantity: 1,
          price: 120000,
          artisanId: 'art2',
          artisanName: 'Dje David',
        ),
      ],
      subtotal: 120000,
      deliveryFee: 5000,
      total: 125000,
      status: OrderStatus.delivered,
      paymentStatus: PaymentStatus.released,
      paymentMethod: 'Orange Money',
      transactionId: 'OM123456789',
      createdAt: DateTime(2024, 11, 1),
      confirmedAt: DateTime(2024, 11, 2),
      deliveredAt: DateTime(2024, 11, 10),
      deliveryAddress: 'Grand Bassam, Côte d\'Ivoire',
      deliveryPhone: '+225 07 00 00 10',
      trackingNumber: 'NSPK001234',
      tracking: [
        OrderTracking(
          status: OrderStatus.pending,
          message: 'Commande reçue et en attente de confirmation',
          timestamp: DateTime(2024, 11, 1, 14, 30),
        ),
        OrderTracking(
          status: OrderStatus.confirmed,
          message: 'Commande confirmée par l\'artisan',
          timestamp: DateTime(2024, 11, 2, 9, 15),
        ),
        OrderTracking(
          status: OrderStatus.preparing,
          message: 'L\'artisan prépare votre sculpture avec soin',
          timestamp: DateTime(2024, 11, 4, 11, 00),
        ),
        OrderTracking(
          status: OrderStatus.readyForPickup,
          message: 'Votre commande est prête pour l\'enlèvement',
          timestamp: DateTime(2024, 11, 6, 16, 45),
        ),
        OrderTracking(
          status: OrderStatus.inTransit,
          message: 'Votre commande est en cours de livraison',
          timestamp: DateTime(2024, 11, 8, 8, 30),
        ),
        OrderTracking(
          status: OrderStatus.delivered,
          message: 'Votre commande a été livrée avec succès',
          timestamp: DateTime(2024, 11, 10, 14, 20),
        ),
      ],
    ),
    OrderModel(
      id: 'order002',
      buyerId: 'buy1',
      buyerName: 'Marie Dupont',
      artisanId: 'art1',
      artisanName: 'Essi Reine',
      items: [
        OrderItem(
          productId: 'prod1',
          productName: 'Masque Sud Africain Traditionnel',
          productImage: 'assets/images/WhatsApp Image 2025-11-05 at 21.48.27.jpeg',
          quantity: 2,
          price: 45000,
          artisanId: 'art1',
          artisanName: 'Essi Reine',
        ),
        OrderItem(
          productId: 'prod17',
          productName: 'Termorce Mini Artisanale',
          productImage: 'assets/images/WhatsApp Image 2025-11-05 at 21.49.03.jpeg',
          quantity: 1,
          price: 18000,
          artisanId: 'art1',
          artisanName: 'Essi Reine',
        ),
      ],
      subtotal: 108000,
      deliveryFee: 3000,
      total: 111000,
      status: OrderStatus.inTransit,
      paymentStatus: PaymentStatus.inEscrow,
      paymentMethod: 'Mobile Money',
      transactionId: 'MM987654321',
      createdAt: DateTime(2024, 11, 15),
      confirmedAt: DateTime(2024, 11, 16),
      deliveryAddress: 'Abidjan, Côte d\'Ivoire',
      deliveryPhone: '+225 07 00 00 10',
      trackingNumber: 'NSPK005678',
      tracking: [
        OrderTracking(
          status: OrderStatus.pending,
          message: 'Commande reçue et en attente de confirmation',
          timestamp: DateTime(2024, 11, 15, 10, 20),
        ),
        OrderTracking(
          status: OrderStatus.confirmed,
          message: 'Commande confirmée par l\'artisan',
          timestamp: DateTime(2024, 11, 16, 14, 30),
        ),
        OrderTracking(
          status: OrderStatus.preparing,
          message: 'L\'artisan prépare vos articles avec soin',
          timestamp: DateTime(2024, 11, 18, 9, 45),
        ),
        OrderTracking(
          status: OrderStatus.readyForPickup,
          message: 'Vos articles sont prêts pour l\'enlèvement',
          timestamp: DateTime(2024, 11, 20, 16, 15),
        ),
        OrderTracking(
          status: OrderStatus.inTransit,
          message: 'Vos articles sont en cours de livraison',
          timestamp: DateTime(2024, 11, 22, 8, 00),
        ),
      ],
    ),
    OrderModel(
      id: 'order003',
      buyerId: 'buy1',
      buyerName: 'Marie Dupont',
      artisanId: 'art3',
      artisanName: 'Ousmane Seyni',
      items: [
        OrderItem(
          productId: 'prod20',
          productName: 'Collier Traditionnel Amalatik',
          productImage: 'assets/images/WhatsApp Image 2025-11-05 at 22.13.59.jpeg',
          quantity: 1,
          price: 55000,
          artisanId: 'art3',
          artisanName: 'Ousmane Seyni',
        ),
      ],
      subtotal: 55000,
      deliveryFee: 2500,
      total: 57500,
      status: OrderStatus.preparing,
      paymentStatus: PaymentStatus.inEscrow,
      paymentMethod: 'Orange Money',
      transactionId: 'OM456789123',
      createdAt: DateTime(2024, 11, 20),
      confirmedAt: DateTime(2024, 11, 21),
      deliveryAddress: 'Bouaké, Côte d\'Ivoire',
      deliveryPhone: '+225 07 00 00 10',
      tracking: [
        OrderTracking(
          status: OrderStatus.pending,
          message: 'Commande reçue et en attente de confirmation',
          timestamp: DateTime(2024, 11, 20, 16, 40),
        ),
        OrderTracking(
          status: OrderStatus.confirmed,
          message: 'Commande confirmée par l\'artisan',
          timestamp: DateTime(2024, 11, 21, 11, 25),
        ),
        OrderTracking(
          status: OrderStatus.preparing,
          message: 'L\'artisan prépare votre collier avec soin',
          timestamp: DateTime(2024, 11, 23, 13, 50),
        ),
      ],
    ),
  ];
}
