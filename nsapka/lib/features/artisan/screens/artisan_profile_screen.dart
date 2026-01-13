import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
// Assurez-vous que ces imports correspondent à votre structure de dossiers
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';

class ArtisanProfileScreen extends StatefulWidget {
  const ArtisanProfileScreen({super.key});

  @override
  State<ArtisanProfileScreen> createState() => _ArtisanProfileScreenState();
}

class _ArtisanProfileScreenState extends State<ArtisanProfileScreen> {
  // Clé pour valider le formulaire
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingImage = false;

  final ImagePicker _imagePicker = ImagePicker();
  File? _localImageFile; // Pour l'affichage immédiat

  // Contrôleurs
  final _bioController = TextEditingController();
  final _standNameController = TextEditingController();
  final _standLocationController = TextEditingController();
  final _yearsOfExperienceController = TextEditingController();
  final _newSpecialtyController = TextEditingController();
  final _newCertificationController = TextEditingController();

  List<String> _specialties = [];
  List<String> _certifications = [];
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _standNameController.dispose();
    _standLocationController.dispose();
    _yearsOfExperienceController.dispose();
    _newSpecialtyController.dispose();
    _newCertificationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final profile = await ApiService.getArtisanProfile();
      if (mounted && profile != null) {
        setState(() {
          _profile = profile;
          _bioController.text = profile['bio'] ?? '';
          _standNameController.text = profile['stand_name'] ?? '';
          _standLocationController.text = profile['stand_location'] ?? '';
          _yearsOfExperienceController.text =
              (profile['years_of_experience'] ?? 0).toString();
          _specialties = List<String>.from(profile['specialties'] ?? []);
          _certifications = List<String>.from(profile['certifications'] ?? []);
          _profileImageUrl = profile['profile_image'];
        });
      }
    } catch (e) {
      debugPrint("Erreur chargement: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Optimisation légère
      );

      if (image == null) return;

      // 1. Mise à jour immédiate de l'UI avec le fichier local
      setState(() {
        _localImageFile = File(image.path);
        _isUploadingImage = true;
      });

      // 2. Préparation pour l'envoi
      final bytes = await _localImageFile!.readAsBytes();
      final base64Image = base64Encode(bytes);
      final imageBase64Data = 'data:image/jpeg;base64,$base64Image';

      // 3. Appel API
      final imageUrl = await ApiService.uploadImage(
        imageBase64: imageBase64Data,
        type: 'profile',
      );

      if (imageUrl != null && mounted) {
        setState(() {
          _profileImageUrl = imageUrl;
          // On garde _localImageFile null ou actif selon la logique de cache voulue,
          // ici on laisse le local file pour éviter le clignotement
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erreur lors de l\'upload: $e', isError: true);
        setState(() => _localImageFile = null); // Revenir à l'état précédent
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  // --- Gestion des listes (Générique) ---
  void _addItem(List<String> list, TextEditingController controller) {
    final val = controller.text.trim();
    if (val.isNotEmpty && !list.contains(val)) {
      setState(() {
        list.add(val);
        controller.clear();
      });
    }
  }

  void _removeItem(List<String> list, String item) {
    setState(() => list.remove(item));
  }

  Future<void> _saveProfile() async {
    // Validation du formulaire avant envoi
    if (!_formKey.currentState!.validate()) {
      _showSnackBar(
        'Veuillez corriger les erreurs avant d\'enregistrer',
        isError: true,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final profile = await ApiService.updateArtisanProfile(
        bio: _bioController.text.trim(),
        standName: _standNameController.text.trim(),
        standLocation: _standLocationController.text.trim(),
        // On envoie l'image seulement si elle a changé et n'est pas déjà une URL HTTP
        profileImageBase64:
            (_localImageFile != null &&
                _profileImageUrl != null &&
                !_profileImageUrl!.startsWith('http'))
            ? _profileImageUrl
            : null,
        specialties: _specialties,
        certifications: _certifications,
        yearsOfExperience: int.tryParse(
          _yearsOfExperienceController.text.trim(),
        ),
      );

      if (profile != null && mounted) {
        _showSnackBar('Profil mis à jour avec succès ✨', isError: false);
      }
    } catch (e) {
      if (mounted) _showSnackBar('Erreur: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Ferme le clavier si on tape ailleurs
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : Form(
                key: _formKey,
                child: CustomScrollView(
                  slivers: [
                    _buildSliverAppBar(),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle("Ma Boutique", Icons.storefront),
                            const SizedBox(height: 12),
                            _buildShopInfoCard(),

                            const SizedBox(height: 24),
                            _buildSectionTitle(
                              "À propos de moi",
                              Icons.person_outline,
                            ),
                            const SizedBox(height: 12),
                            _buildBioCard(),
                            const SizedBox(height: 40),
                            _buildSaveButton(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 240.0,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      actions: [
        IconButton(
          icon: const ContainerWithBackground(icon: Icons.logout),
          onPressed: () {
            // Logique de déconnexion ici
          },
        ),
      ],
      leading: IconButton(
        icon: const ContainerWithBackground(icon: Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Décoration d'arrière-plan
            Positioned(
              right: -30,
              top: -30,
              child: Icon(
                Icons.handyman,
                size: 200,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: _pickProfileImage,
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: _getImageProvider(),
                            child:
                                (_localImageFile == null &&
                                    _profileImageUrl == null)
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: AppColors.primary,
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 4),
                              ],
                            ),
                            child: _isUploadingImage
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _profile?['name'] ?? 'Artisan',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper pour choisir la bonne source d'image
  ImageProvider? _getImageProvider() {
    if (_localImageFile != null) {
      return FileImage(_localImageFile!);
    } else if (_profileImageUrl != null &&
        _profileImageUrl!.startsWith('http')) {
      return NetworkImage(_profileImageUrl!);
    }
    return null;
  }

  Widget _buildShopInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField(
              controller: _standNameController,
              label: 'Nom de la boutique',
              icon: Icons.store_mall_directory,
              hint: 'Ex: L\'Atelier des Merveilles',
              validator: (v) => v!.isEmpty ? 'Le nom est requis' : null,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _standLocationController,
              label: 'Emplacement',
              icon: Icons.location_on,
              hint: 'Ex: Marché de Treichville, Stand 42',
              validator: (v) => v!.isEmpty ? 'L\'emplacement est requis' : null,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _yearsOfExperienceController,
              label: 'Années d\'expérience',
              icon: Icons.timer,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v!.isEmpty) return 'Requis';
                if (int.tryParse(v) == null) return 'Chiffre valide requis';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBioCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: TextFormField(
          controller: _bioController,
          maxLines: 5,
          maxLength: 500, // Limite de caractères
          decoration: InputDecoration(
            hintText: 'Racontez votre histoire, votre passion...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
        ),
      ),
    );
  }

  // Widget générique pour Tags (Spécialités & Certifications)
  Widget _buildTagsCard({
    required String title,
    required List<String> items,
    required Function(String) onRemove,
    required VoidCallback onAdd,
    Color chipColor = AppColors.primaryLight,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_circle, color: AppColors.primary),
                  tooltip: "Ajouter",
                ),
              ],
            ),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Aucun élément ajouté",
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items
                  .map(
                    (item) => Chip(
                      label: Text(item),
                      backgroundColor: chipColor.withOpacity(0.15),
                      labelStyle: const TextStyle(color: AppColors.textPrimary),
                      deleteIcon: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.grey,
                      ),
                      onDeleted: () => onRemove(item),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.secondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'ENREGISTRER LES MODIFICATIONS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _showAddDialog(
    String title,
    TextEditingController controller,
    VoidCallback onAdd,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: "Saisissez ici...",
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) {
            onAdd();
            Navigator.pop(ctx);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              onAdd();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }
}

// Widget utilitaire pour les boutons du header
class ContainerWithBackground extends StatelessWidget {
  final IconData icon;
  const ContainerWithBackground({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(8),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}
