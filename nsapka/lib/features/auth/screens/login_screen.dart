import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/api_service.dart'; // Pour AuthResult
import '../../../core/models/user_model.dart';
import '../../../core/utils/favorites_manager.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final String userType; // 'buyer' ou 'artisan'

  const LoginScreen({super.key, this.userType = 'buyer'});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController =
      TextEditingController(); // Sert pour Email OU Téléphone
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  // _isLogin est true par défaut car c'est un écran de Login.
  final bool _isLogin = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // 1. Indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );

      try {
        // 2. Appel API via AuthService (CORRECTION ICI)
        final result = await AuthService.login(
          phone: _phoneController.text
              .trim(), // On utilise 'phone' comme nom de paramètre
          password: _passwordController.text,
        );

        // 3. Fermer le chargement
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        // 4. Gestion du résultat
        if (result.success && result.user != null) {
          // Charger les favoris après connexion réussie
          if (result.user!.role == UserRole.buyer) {
            await FavoritesManager.loadFavorites();
          }

          // Déterminer la route selon le rôle (Acheteur ou Artisan)
          final route = AuthService.getRouteForRole(result.user!.role);

          if (context.mounted) {
            // Navigation et suppression de l'historique pour empêcher le retour au login
            Navigator.of(context).pushNamedAndRemoveUntil(
              route,
              (route) => false,
              arguments: {'isVisitorMode': false},
            );
          }
        } else {
          // Erreur
          if (context.mounted) {
            final errorMessage = result.error ?? 'Erreur de connexion';

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                action: errorMessage.toLowerCase().contains('compte')
                    ? SnackBarAction(
                        label: 'Créer un compte',
                        textColor: Colors.white,
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/register',
                          arguments: {'userType': widget.userType},
                        ),
                      )
                    : null,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          // S'assurer de fermer le dialog si crash
          Navigator.of(
            context,
          ).popUntil((route) => route.settings.name != null);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildUserTypeBadge(),
                  const SizedBox(height: 30),
                  _buildForm(),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                  const SizedBox(height: 16),
                  _buildRegisterLink(),
                  const SizedBox(height: 24),
                  _buildDivider(),
                  const SizedBox(height: 24),
                  _buildDemoButton(),
                  const SizedBox(height: 10),
                  _buildBackButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.lock_person, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          'welcome_back'.tr(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '${"connect_to_space".tr()} ${widget.userType == 'artisan' ? 'artisan_space'.tr() : 'buyer_space'.tr()}',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUserTypeBadge() {
    final isArtisan = widget.userType == 'artisan';
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: (isArtisan ? AppColors.secondary : AppColors.primary)
              .withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (isArtisan ? AppColors.secondary : AppColors.primary)
                .withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isArtisan ? Icons.handyman : Icons.shopping_bag,
              color: isArtisan ? AppColors.secondary : AppColors.primary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              widget.userType == 'artisan'
                  ? 'artisan_space'.tr()
                  : 'buyer_space'.tr(),
              style: TextStyle(
                color: isArtisan ? AppColors.secondary : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.emailAddress, // Accepte email ou tel
            decoration: InputDecoration(
              labelText: 'phone_or_email'.tr(),
              hintText: 'phone_or_email_hint'.tr(),
              prefixIcon: const Icon(Icons.person_outline),
            ),
            validator: (value) =>
                (value == null || value.isEmpty) ? 'required'.tr() : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'password'.tr(),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: _togglePasswordVisibility,
              ),
            ),
            validator: (value) =>
                (value == null || value.length < 4) ? 'required'.tr() : null,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ForgotPasswordScreen(),
                ),
              ),
              child: Text(
                'forgot_password'.tr(),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.userType == 'artisan'
              ? AppColors.secondary
              : AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'sign_in'.tr().toUpperCase(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('no_account'.tr()),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            '/register',
            arguments: {'userType': widget.userType},
          ),
          child: Text(
            'register'.tr(),
            style: TextStyle(
              color: widget.userType == 'artisan'
                  ? AppColors.secondary
                  : AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "OU",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildDemoButton() {
    return TextButton(
      onPressed: () {
        // Redirection Mode Démo sans API
        final route = widget.userType == 'artisan'
            ? '/artisan-home'
            : '/buyer-home';
        Navigator.of(
          context,
        ).pushReplacementNamed(route, arguments: {'isVisitorMode': true});
      },
      child: const Text(
        "🎭 Continuer en mode invité (Démo)",
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildBackButton() {
    return TextButton.icon(
      onPressed: () => Navigator.of(context).pop(),
      icon: const Icon(Icons.arrow_back, size: 16, color: Colors.grey),
      label: const Text(
        "Retour à l'accueil",
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
