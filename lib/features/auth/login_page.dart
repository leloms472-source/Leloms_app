import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/repositories/auth_repository.dart';
import '../../core/repositories/profile_repository_impl.dart';
import '../../core/models/profile_model.dart';
import '../../providers/profile_provider.dart';
import '../../providers/sanctuary_provider.dart';
import '../../providers/study_provider.dart';
import '../../providers/achievement_provider.dart';
import '../../providers/challenge_provider.dart';
import '../../providers/shop_provider.dart';
import '../home/home_page.dart';
import '../../widgets/loading_overlay.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final AuthRepository _authRepo = AuthRepository();
  bool _isRegistering = false;
  late AnimationController _flipController;
  late Animation<double> _frontRotation;
  late Animation<double> _backRotation;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _frontRotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: pi / 2), weight: 50.0),
      TweenSequenceItem(tween: Tween(begin: pi / 2, end: pi / 2), weight: 50.0),
    ]).animate(_flipController);

    _backRotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: -pi / 2, end: -pi / 2), weight: 50.0),
      TweenSequenceItem(tween: Tween(begin: -pi / 2, end: 0.0), weight: 50.0),
    ]).animate(_flipController);
  }

  void _toggleMode() {
    setState(() {
      _isRegistering = !_isRegistering;
      _errorMessage = null;
      if (_isRegistering) {
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
    });
  }

  Future<void> _handleEmailAuth() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isRegistering) {
        await _authRepo.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
          name: _nameController.text.trim(),
        );
      } else {
        await _authRepo.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }

      if (!mounted) return;
      await _loadUserData();

      _navigateToHome();
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = _getAuthErrorMessage(e.message);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de autenticación. Intenta de nuevo.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authRepo.signInWithGoogle();

      if (!mounted) return;
      await _loadUserData();

      _navigateToHome();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al iniciar con Google. Intenta de nuevo.';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserData() async {
    final user = _authRepo.currentUser;
    if (user == null) return;

    final userProvider = context.read<ProfileProvider>();
    final profileRepo = ProfileRepository();
    final profile = await profileRepo.getProfile(user.id);

    if (profile != null) {
      userProvider.setProfile(profile);
    } else {
      final newProfile = ProfileModel(
        id: user.id,
        fullName: user.userMetadata?['name'] as String? ?? 'Estudiante',
      );
      await profileRepo.createProfile(newProfile);
      userProvider.setProfile(newProfile);
    }

    if (mounted) {
      final uid = user.id;
      context.read<SanctuaryProvider>().loadFromServer(uid);
      context.read<StudyProvider>().loadFromServer(uid);
      context.read<AchievementProvider>().loadFromServer(uid);
      context.read<ChallengeProvider>().loadFromServer(uid);
      context.read<ShopProvider>().loadFromServer(uid);
    }
  }

  bool _validateForm() {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Completa todos los campos');
      return false;
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      setState(() => _errorMessage = 'Correo electrónico inválido');
      return false;
    }
    if (_passwordController.text.length < 8) {
      setState(() => _errorMessage = 'La contraseña debe tener al menos 8 caracteres');
      return false;
    }
    if (_isRegistering && _nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Ingresa tu nombre');
      return false;
    }
    return true;
  }

  String _getAuthErrorMessage(String code) {
    final lower = code.toLowerCase();
    if (lower.contains('user not found') || lower.contains('not found')) {
      return 'No hay cuenta con este correo';
    }
    if (lower.contains('wrong password') || lower.contains('invalid password') || lower.contains('invalid_credentials')) {
      return 'Contraseña incorrecta';
    }
    if (lower.contains('already exists') || lower.contains('already registered') || lower.contains('email already')) {
      return 'Este correo ya está registrado';
    }
    if (lower.contains('invalid email')) {
      return 'Correo electrónico inválido';
    }
    if (lower.contains('weak password')) {
      return 'Contraseña muy débil';
    }
    if (lower.contains('rate limit') || lower.contains('too many')) {
      return 'Demasiados intentos. Espera un momento';
    }
    return code;
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomePage(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildLogo(),
                  const SizedBox(height: 40),
                  _buildFlipCard(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          if (_isLoading) const LoadingOverlay(message: 'Conectando...'),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 90, height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary, AppColors.tertiary],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 3)],
          ),
          child: const Icon(Icons.pets_rounded, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(colors: [AppColors.primary, AppColors.secondary]).createShader(bounds),
          child: const Text('LELOMS', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 4, color: Colors.white)),
        ),
        const SizedBox(height: 4),
        const Text('Guía del Estudiante', style: TextStyle(fontSize: 14, letterSpacing: 2, color: AppColors.secondaryText)),
      ],
    );
  }

  Widget _buildFlipCard() {
    return SizedBox(
      height: 380,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _flipController,
            builder: (context, child) {
              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_frontRotation.value),
                alignment: FractionalOffset.center,
                child: _flipController.value < 0.5
                    ? _buildLoginCard()
                    : Opacity(opacity: 0, child: _buildLoginCard()),
              );
            },
          ),
          AnimatedBuilder(
            animation: _flipController,
            builder: (context, child) {
              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_backRotation.value),
                alignment: FractionalOffset.center,
                child: _flipController.value >= 0.5
                    ? _buildRegisterCard()
                    : Opacity(opacity: 0, child: _buildRegisterCard()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard() {
    return _buildAuthCard(
      title: 'Iniciar Sesión',
      subtitle: 'Accede a tu cuenta de LELOMS',
      children: [
        _buildErrorBanner(),
        _buildEmailField(),
        const SizedBox(height: 16),
        _buildPasswordField(),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => _handleForgotPassword(),
            child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(color: AppColors.primary, fontSize: 12)),
          ),
        ),
        const SizedBox(height: 16),
        _buildPrimaryButton('Iniciar Sesión', _handleEmailAuth),
        const SizedBox(height: 16),
        _buildDivider(),
        const SizedBox(height: 16),
        _buildGoogleButton(),
        const SizedBox(height: 20),
        _buildToggleText(),
      ],
    );
  }

  Widget _buildRegisterCard() {
    return _buildAuthCard(
      title: 'Crear Cuenta',
      subtitle: 'Únete a la comunidad LELOMS',
      children: [
        _buildErrorBanner(),
        _buildNameField(),
        const SizedBox(height: 16),
        _buildEmailField(),
        const SizedBox(height: 16),
        _buildPasswordField(),
        const SizedBox(height: 24),
        _buildPrimaryButton('Crear Cuenta', _handleEmailAuth),
        const SizedBox(height: 16),
        _buildDivider(),
        const SizedBox(height: 16),
        _buildGoogleButton(),
        const SizedBox(height: 20),
        _buildToggleText(),
      ],
    );
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      setState(() => _errorMessage = 'Ingresa un correo válido primero');
      return;
    }
    try {
      await _authRepo.resetPassword(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Correo de recuperación enviado'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Error al enviar correo de recuperación');
      }
    }
  }

  Widget _buildErrorBanner() {
    if (_errorMessage == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(_errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 13))),
        ]),
      ),
    );
  }

  Widget _buildAuthCard({required String title, required String subtitle, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.darkCard.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 30, spreadRadius: 5)],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.lightText)),
        const SizedBox(height: 8),
        Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.secondaryText)),
        const SizedBox(height: 28),
        ...children,
      ]),
    );
  }

  Widget _buildNameField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Nombre completo', style: TextStyle(color: AppColors.secondaryText, fontSize: 12, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      TextField(
        controller: _nameController,
        style: const TextStyle(color: AppColors.lightText),
        decoration: const InputDecoration(hintText: 'Tu nombre', prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.primary)),
      ),
    ]);
  }

  Widget _buildEmailField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Correo electrónico', style: TextStyle(color: AppColors.secondaryText, fontSize: 12, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: AppColors.lightText),
        decoration: const InputDecoration(hintText: 'correo@ejemplo.com', prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary)),
      ),
    ]);
  }

  Widget _buildPasswordField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Contraseña', style: TextStyle(color: AppColors.secondaryText, fontSize: 12, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: const TextStyle(color: AppColors.lightText),
        decoration: InputDecoration(
          hintText: 'Mínimo 8 caracteres',
          prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.secondaryText),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ),
    ]);
  }

  Widget _buildPrimaryButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity, height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity, height: 50,
      child: OutlinedButton.icon(
        onPressed: _handleGoogleSignIn,
        icon: const Icon(Icons.g_mobiledata, size: 24, color: Colors.white),
        label: const Text('Continuar con Google', style: TextStyle(color: AppColors.lightText)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          backgroundColor: Colors.white.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(children: [
      Expanded(child: Container(height: 1, color: AppColors.border.withValues(alpha: 0.5))),
      const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('o', style: TextStyle(color: AppColors.secondaryText, fontSize: 13))),
      Expanded(child: Container(height: 1, color: AppColors.border.withValues(alpha: 0.5))),
    ]);
  }

  Widget _buildToggleText() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(_isRegistering ? '¿Ya tienes cuenta? ' : '¿No tienes cuenta? ', style: const TextStyle(color: AppColors.secondaryText)),
      TextButton(
        onPressed: _toggleMode,
        child: Text(_isRegistering ? 'Inicia sesión' : 'Regístrate', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
      ),
    ]);
  }
}
