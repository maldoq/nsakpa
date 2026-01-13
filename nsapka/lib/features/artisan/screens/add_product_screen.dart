import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  String _selectedCategory = 'Sculptures';
  bool _isLimitedEdition = false;
  bool _isRecordingVoice = false;
  List<String> _selectedImages = []; // URLs des images uploadées
  List<File> _selectedImageFiles = []; // Fichiers locaux pour affichage
  bool _isSaving = false;
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _categories = [
    'Sculptures',
    'Peintures',
    'Textiles',
    'Bijoux',
    'Poterie',
    'Vannerie',
    'Autres',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _toggleVoiceRecording() {
    setState(() {
      _isRecordingVoice = !_isRecordingVoice;
    });
    // TODO: Implémenter l'enregistrement vocal
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 70, // Optimisation pour éviter les paylods trop lourds
      );

      if (images.isEmpty) return;

      setState(() {
        _isSaving = true;
      });

      final List<String> base64Images = [];

      for (final image in images) {
        final file = File(image.path);

        // 1. Conversion en Base64 pour l'envoi API
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);

        // Format standard pour les API REST (data:image/jpeg;base64,...)
        // Le backend devra parser cette chaîne.
        final imageHeader =
            'data:image/${image.path.split('.').last};base64,$base64String';

        base64Images.add(imageHeader);

        // Ajout au fichier local pour l'affichage immédiat dans l'UI
        _selectedImageFiles.add(file);
      }

      setState(() {
        // On stocke les chaines Base64 pour l'envoi final
        _selectedImages.addAll(base64Images);
        _isSaving = false;
      });
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur image: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    // Validation des images
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter au moins une photo'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // APPEL RÉEL AU BACKEND
      await ApiService.createProduct(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        stock: int.parse(_stockController.text.trim()),
        category: _selectedCategory, // Le backend s'occupera du formatage
        images: _selectedImages, // Envoi des Base64
        isLimitedEdition: _isLimitedEdition,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Produit publié avec succès ! 🚀"),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true); // Retour avec succès
      }
    } catch (e) {
      // Gestion des erreurs réelles du serveur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur serveur: ${e.toString().replaceAll('Exception:', '')}',
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.addProduct),
        backgroundColor: AppColors.secondary,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog();
            },
            tooltip: AppStrings.needHelp,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section d'aide pour artisans
              _buildHelpBanner(),

              const SizedBox(height: 24),

              // Photos du produit
              _buildPhotoSection(),

              const SizedBox(height: 24),

              // Nom du produit
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: AppStrings.productName,
                  hintText: "Ex: Masque Baoulé",
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.fieldRequired;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Description avec option vocale
              _buildDescriptionField(),

              const SizedBox(height: 16),

              // Catégorie
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: AppStrings.productCategory,
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Prix et Stock
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: AppStrings.productPrice,
                        hintText: "15000",
                        prefixIcon: Icon(Icons.attach_money),
                        suffixText: "FCFA",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.fieldRequired;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: AppStrings.productStock,
                        hintText: "10",
                        prefixIcon: Icon(Icons.inventory),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.fieldRequired;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Édition limitée
              _buildLimitedEditionSwitch(),

              const SizedBox(height: 32),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(AppStrings.cancel),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.textWhite,
                                ),
                              ),
                            )
                          : const Text(
                              AppStrings.save,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.info.withOpacity(0.1),
            AppColors.info.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.info, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.needHelp,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Utilisez la saisie vocale ou contactez un agent",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.support_agent, color: AppColors.info),
            onPressed: () {
              // TODO: Contacter un agent communautaire
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.productPhotos,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Bouton d'ajout de photo
              _buildAddPhotoButton(),

              // Photos sélectionnées
              ..._selectedImages.map((image) => _buildPhotoItem(image)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.sand,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 40, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              "Ajouter",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoItem(String imageUrl) {
    final index = _selectedImages.indexOf(imageUrl);
    final file = index < _selectedImageFiles.length
        ? _selectedImageFiles[index]
        : null;

    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: file != null
                ? Image.file(file, width: 120, height: 120, fit: BoxFit.cover)
                : imageUrl.startsWith('http')
                ? Image.network(
                    imageUrl,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 120,
                        color: AppColors.border,
                        child: const Icon(Icons.image),
                      );
                    },
                  )
                : Container(
                    width: 120,
                    height: 120,
                    color: AppColors.border,
                    child: const Icon(Icons.image),
                  ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  final idx = _selectedImages.indexOf(imageUrl);
                  _selectedImages.removeAt(idx);
                  if (idx < _selectedImageFiles.length) {
                    _selectedImageFiles.removeAt(idx);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.textWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: AppStrings.productDescription,
            hintText: "Décrivez votre produit...",
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 60),
              child: Icon(Icons.description),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: IconButton(
                icon: Icon(
                  _isRecordingVoice ? Icons.stop : Icons.mic,
                  color: _isRecordingVoice
                      ? AppColors.error
                      : AppColors.primary,
                ),
                onPressed: _toggleVoiceRecording,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppStrings.fieldRequired;
            }
            return null;
          },
        ),
        if (_isRecordingVoice)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Enregistrement en cours...",
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLimitedEditionSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isLimitedEdition
            ? AppColors.accent.withOpacity(0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isLimitedEdition ? AppColors.accent : AppColors.border,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.star,
            color: _isLimitedEdition ? AppColors.accent : AppColors.textLight,
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.limitedEdition,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _isLimitedEdition
                        ? AppColors.accent
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Produit unique ou en quantité limitée",
                  style: TextStyle(fontSize: 12, color: AppColors.textLight),
                ),
              ],
            ),
          ),
          Switch(
            value: _isLimitedEdition,
            onChanged: (value) {
              setState(() {
                _isLimitedEdition = value;
              });
            },
            activeColor: AppColors.accent,
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.help, color: AppColors.info),
            const SizedBox(width: 12),
            const Text(AppStrings.needHelp),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem(
              icon: Icons.mic,
              title: "Saisie vocale",
              description: "Cliquez sur le micro pour dicter votre description",
            ),
            const SizedBox(height: 16),
            _buildHelpItem(
              icon: Icons.photo_camera,
              title: "Photos",
              description: "Ajoutez 3-5 photos de votre produit",
            ),
            const SizedBox(height: 16),
            _buildHelpItem(
              icon: Icons.support_agent,
              title: "Agent communautaire",
              description: "Contactez un agent pour vous aider",
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Compris"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Contacter un agent
            },
            child: const Text(AppStrings.contactCommunityAgent),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: AppColors.textLight),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
