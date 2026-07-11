import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/user_provider.dart';
import '../home/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
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
      TweenSequenceItem(
          tween: Tween(begin: -pi / 2, end: -pi / 2), weight: 50.0),
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
      UserCredential credential;
      if (_isRegistering) {
        credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        await credential.user!.updateDisplayName(_nameController.text.trim());
      } else {
        credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      if (!mounted) return;
      final userProvider = context.read<UserProvider>();
      userProvider.setLoggedIn(true);
      userProvider.setUserName(
          credential.user?.displayName ?? _nameController.text.trim());

      _navigateToHome();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getAuthErrorMessage(e.code);
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
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;
      context.read<UserProvider>().setLoggedIn(true);
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

  bool _validateForm() {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Completa todos los campos');
      return false;
    }
    if (!_emailController.text.contains('@')) {
      setState(() => _errorMessage = 'Correo electrónico inválido');
      return false;
    }
    if (_passwordController.text.length < 6) {
      setState(() => _errorMessage = 'La contraseña debe tener al menos 6 caracteres');
      return false;
    }
    if (_isRegistering && _nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Ingresa tu nombre');
      return false;
    }
    return true;
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No hay cuenta con este correo';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'Este correo ya está registrado';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'weak-password':
        return 'Contraseña muy débil';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera un momento';
      default:
        return 'Error de autenticación. Intenta de nuevo';
    }
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
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary, AppColors.tertiary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 3,
              ),
            ],
          ),
          child: const Icon(Icons.pets_rounded, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
          ).createShader(bounds),
          child: const Text(
            'LELOMS',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Guía del Estudiante',
          style: TextStyle(
            fontSize: 14,
            letterSpacing: 2,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildFlipCard() {
    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
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
            onPressed: () {},
            child: const Text(
              '¿Olvidaste tu contraseña?',
              style: TextStyle(color: AppColors.primary, fontSize: 12),
            ),
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

  Widget _buildErrorBanner() {
    if (_errorMessage == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthCard({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.darkCard.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 28),
          ...children,
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre completo',
          style: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _nameController,
          style: const TextStyle(color: AppColors.lightText),
          decoration: const InputDecoration(
            hintText: 'Tu nombre',
            prefixIcon:
                Icon(Icons.person_outline_rounded, color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Correo electrónico',
          style: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: AppColors.lightText),
          decoration: const InputDecoration(
            hintText: 'correo@ejemplo.com',
            prefixIcon:
                Icon(Icons.email_outlined, color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contraseña',
          style: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: AppColors.lightText),
          decoration: InputDecoration(
            hintText: 'Mínimo 6 caracteres',
            prefixIcon:
                const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.secondaryText,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: _handleGoogleSignIn,
        icon: const Icon(Icons.g_mobiledata, size: 24, color: Colors.white),
        label: const Text(
          'Continuar con Google',
          style: TextStyle(color: AppColors.lightText),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.2),
          ),
          backgroundColor: Colors.white.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.border.withValues(alpha: 0.5),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'o',
            style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.border.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isRegistering ? '¿Ya tienes cuenta? ' : '¿No tienes cuenta? ',
          style: const TextStyle(color: AppColors.secondaryText),
        ),
        TextButton(
          onPressed: _toggleMode,
          child: Text(
            _isRegistering ? 'Inicia sesión' : 'Regístrate',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: AppColors.overlay.withValues(alpha: 0.6),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text(
                'Conectando...',
                style: TextStyle(color: AppColors.lightText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
