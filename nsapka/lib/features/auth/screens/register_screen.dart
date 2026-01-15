import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  final String userType;

  const RegisterScreen({super.key, required this.userType});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // MODIFICATION : Séparation Nom et Prénom
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();

  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _locationController = TextEditingController();

  // Champs spécifiques artisan
  final _standNameController = TextEditingController();
  final _standLocationController = TextEditingController();
  final _bioController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _isLoading = false; // Ajout d'un état de chargement local

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _locationController.dispose();
    _standNameController.dispose();
    _standLocationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArtisan = widget.userType == 'artisan';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isArtisan ? 'registration_artisan'.tr() : 'registration_buyer'.tr(),
        ),
        backgroundColor: isArtisan ? AppColors.secondary : AppColors.primary,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // En-tête
                _buildHeader(isArtisan),

                const SizedBox(height: 32),

                // --- NOUVEAUX CHAMPS NOM & PRÉNOM ---
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _lastNameController,
                        label: 'last_name'.tr(),
                        icon: Icons.person,
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'required'.tr()
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _firstNameController,
                        label: 'first_name'.tr(),
                        icon: Icons.person_outline,
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'required'.tr()
                            : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  controller: _emailController,
                  label: 'email'.tr(),
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'required'.tr();
                    if (!value.contains('@')) return 'Email invalide';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  controller: _phoneController,
                  label: 'phone'.tr(),
                  hint: 'phone_or_email_hint'.tr(),
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'required'.tr() : null,
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  controller: _locationController,
                  label: 'city'.tr(),
                  icon: Icons.location_on,
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'required'.tr() : null,
                ),

                // Champs spécifiques artisan
                if (isArtisan) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'artisan_info'.tr(),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _standNameController,
                    label: 'stand_name'.tr(),
                    icon: Icons.store,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'required'.tr()
                        : null,
                  ),

                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _standLocationController,
                    label: 'stand_location'.tr(),
                    icon: Icons.pin_drop,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'required'.tr()
                        : null,
                  ),

                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _bioController,
                    label: 'bio'.tr(),
                    icon: Icons.description,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'required'.tr();
                      if (value.length < 10) return 'Minimum 10 caractères';
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 16),

                _buildTextField(
                  controller: _passwordController,
                  label: 'password'.tr(),
                  icon: Icons.lock,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'required'.tr();
                    if (value.length < 6) return 'Min 6 caractères';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'confirm_password'.tr(),
                  icon: Icons.lock_outline,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text)
                      return 'passwords_not_match'.tr();
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                CheckboxListTile(
                  value: _acceptTerms,
                  onChanged: (value) =>
                      setState(() => _acceptTerms = value ?? false),
                  title: Text(
                    'terms_of_service'.tr(),
                    style: const TextStyle(fontSize: 13),
                  ),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: isArtisan
                      ? AppColors.secondary
                      : AppColors.primary,
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: (_acceptTerms && !_isLoading) ? _register : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isArtisan
                        ? AppColors.secondary
                        : AppColors.primary,
                    foregroundColor: AppColors.textWhite,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'register'.tr().toUpperCase(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Déjà un compte ? '),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'login'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isArtisan
                              ? AppColors.secondary
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isArtisan) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isArtisan
                  ? [AppColors.secondary, AppColors.accent]
                  : [AppColors.primary, AppColors.secondary],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            isArtisan ? Icons.palette : Icons.shopping_bag,
            size: 40,
            color: AppColors.textWhite,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isArtisan ? 'Devenir Artisan Vendeur' : 'Créer un compte Acheteur',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    // Vérification manuelle supplémentaire
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les mots de passe ne correspondent pas'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final role = widget.userType == 'artisan'
          ? UserRole.artisan
          : UserRole.buyer;

      // MODIFICATION ICI : On combine Nom et Prénom pour l'envoyer à l'API
      // L'ApiService attend un champ 'name'.
      final String fullName =
          "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}";

      final result = await ApiService.register(
        name: fullName,
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        passwordConfirm: _confirmPasswordController.text,
        location: _locationController.text.trim(),
        role: role,
        standName: widget.userType == 'artisan'
            ? _standNameController.text.trim()
            : null,
        standLocation: widget.userType == 'artisan'
            ? _standLocationController.text.trim()
            : null,
        bio: widget.userType == 'artisan' ? _bioController.text.trim() : null,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.success && result.user != null) {
        // Succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compte créé avec succès ! 🚀'),
            backgroundColor: AppColors.success,
          ),
        );

        // Redirection
        final route = AuthService.getRouteForRole(result.user!.role);

        Navigator.pushNamedAndRemoveUntil(
          context,
          route,
          (route) => false,
          arguments: {'isVisitorMode': false},
        );
      } else {
        // Erreur API
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Erreur lors de l\'inscription'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur inattendue: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
