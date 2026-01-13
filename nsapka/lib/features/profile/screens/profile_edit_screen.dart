import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../../../core/data/mock_data.dart';

class ProfileEditScreen extends StatefulWidget {
  final String userId;
  final UserRole userRole;

  const ProfileEditScreen({
    super.key,
    required this.userId,
    required this.userRole,
  });

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late UserModel user;
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs de texte
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _standNameController = TextEditingController();
  final _standLocationController = TextEditingController();

  // Spécialités pour les artisans
  final List<String> availableSpecialties = [
    'Sculpture',
    'Peinture',
    'Tissage',
    'Poteries',
    'Bijoux',
    'Vêtements',
    'Instruments',
    'Décoration',
    'Artisanat alimentaire',
    'Autre'
  ];
  List<String> selectedSpecialties = [];

  @override
  void initState() {
    super.initState();
    // Charger l'utilisateur
    if (widget.userRole == UserRole.artisan) {
      user = MockData.artisans.firstWhere(
        (u) => u.id == widget.userId,
        orElse: () => MockData.artisans.first,
      );
    } else {
      user = MockData.buyers.firstWhere(
        (u) => u.id == widget.userId,
        orElse: () => MockData.buyers.first,
      );
    }

    // Initialiser les contrôleurs
    _nameController.text = user.name;
    _emailController.text = user.email;
    _phoneController.text = user.phone;
    _bioController.text = user.bio ?? '';
    _locationController.text = user.location ?? '';
    _standNameController.text = user.standName ?? '';
    _standLocationController.text = user.standLocation ?? '';
    selectedSpecialties = user.specialties ?? [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _standNameController.dispose();
    _standLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArtisan = user.role == UserRole.artisan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le profil'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Retour',
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Sauvegarder',
              style: TextStyle(
                color: AppColors.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo de profil
              _buildProfilePhoto(),

              const SizedBox(height: 24),

              // Informations générales
              _buildSectionTitle('Informations générales'),
              _buildTextField(
                controller: _nameController,
                label: 'Nom complet',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le nom est obligatoire';
                  }
                  return null;
                },
              ),

              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'L\'email est obligatoire';
                  }
                  if (!value.contains('@')) {
                    return 'Email invalide';
                  }
                  return null;
                },
              ),

              _buildTextField(
                controller: _phoneController,
                label: 'Téléphone',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le téléphone est obligatoire';
                  }
                  return null;
                },
              ),

              _buildTextField(
                controller: _locationController,
                label: 'Localisation',
                icon: Icons.location_on,
              ),

              _buildTextField(
                controller: _bioController,
                label: 'Biographie',
                icon: Icons.description,
                maxLines: 4,
                hint: 'Parlez-nous de vous, de votre parcours...',
              ),

              // Section artisan
              if (isArtisan) ...[
                const SizedBox(height: 24),
                _buildSectionTitle('Informations artisan'),

                _buildTextField(
                  controller: _standNameController,
                  label: 'Nom du stand',
                  icon: Icons.store,
                ),

                _buildTextField(
                  controller: _standLocationController,
                  label: 'Emplacement du stand',
                  icon: Icons.location_city,
                ),

                const SizedBox(height: 16),
                _buildSpecialtiesSelector(),
              ],

              const SizedBox(height: 40),

              // Bouton de sauvegarde
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textWhite,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sauvegarder les modifications',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePhoto() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.accent,
            backgroundImage: user.profileImage != null
                ? AssetImage(user.profileImage!)
                : null,
            child: user.profileImage == null
                ? Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 40,
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 3),
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt, size: 20, color: AppColors.textWhite),
                onPressed: _changeProfilePhoto,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: AppColors.surface,
        ),
      ),
    );
  }

  Widget _buildSpecialtiesSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Spécialités',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableSpecialties.map((specialty) {
            final isSelected = selectedSpecialties.contains(specialty);
            return FilterChip(
              label: Text(specialty),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedSpecialties.add(specialty);
                  } else {
                    selectedSpecialties.remove(specialty);
                  }
                });
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  void _changeProfilePhoto() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                // Implémenter la caméra
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonctionnalité à venir')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.pop(context);
                // Implémenter la galerie
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonctionnalité à venir')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // Créer un nouvel utilisateur avec les données modifiées
      final updatedUser = UserModel(
        id: user.id,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        role: user.role,
        profileImage: user.profileImage,
        bio: _bioController.text.isNotEmpty ? _bioController.text : null,
        location: _locationController.text.isNotEmpty ? _locationController.text : null,
        rating: user.rating,
        totalSales: user.totalSales,
        isVerified: user.isVerified,
        isCertified: user.isCertified,
        createdAt: user.createdAt,
        standName: _standNameController.text.isNotEmpty ? _standNameController.text : null,
        standLocation: _standLocationController.text.isNotEmpty ? _standLocationController.text : null,
        specialties: selectedSpecialties.isNotEmpty ? selectedSpecialties : null,
        qrCode: user.qrCode,
        yearsOfExperience: user.yearsOfExperience,
        certifications: user.certifications,
      );

      // Simulation de sauvegarde
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil mis à jour avec succès !'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context, updatedUser);
    }
  }
}
