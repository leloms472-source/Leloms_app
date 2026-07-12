import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/repositories/auth_repository.dart';
import '../../core/repositories/profile_repository.dart';
import '../../providers/user_provider.dart';
import '../../providers/sanctuary_provider.dart';
import '../../providers/study_provider.dart';
import '../../providers/achievement_provider.dart';
import '../../providers/challenge_provider.dart';
import '../../providers/shop_provider.dart';
import 'login_page.dart';
import '../home/home_page.dart';
import '../onboarding/onboarding_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  final AuthRepository _authRepo = AuthRepository();
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _subtitleFade;
  late Animation<double> _loaderFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2800),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.elasticOut)),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3, curve: Curves.easeIn)),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.6, curve: Curves.easeIn)),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 20), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.6, curve: Curves.easeOut)),
    );
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 0.75, curve: Curves.easeIn)),
    );
    _loaderFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.7, 1.0, curve: Curves.easeIn)),
    );

    _controller.forward();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 3200));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

    if (!onboardingComplete) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OnboardingPage(
            onComplete: () => _navigateToHome(),
          ),
        ),
      );
      return;
    }

    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    final session = _authRepo.currentSession;

    if (session != null) {
      final userProvider = context.read<UserProvider>();
      final profileRepo = ProfileRepository();
      final profile = await profileRepo.getProfile(session.user.id);

      if (profile != null) {
        userProvider.setProfile(profile);
      }

      if (mounted) {
        final uid = session.user.id;
        context.read<SanctuaryProvider>().loadFromServer(uid);
        context.read<StudyProvider>().loadFromServer(uid);
        context.read<AchievementProvider>().loadFromServer(uid);
        context.read<ChallengeProvider>().loadFromServer(uid);
        context.read<ShopProvider>().loadFromServer(uid);
      }
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            session != null ? const HomePage() : const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackgroundGradient(),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                _buildAnimatedLogo(),
                const SizedBox(height: 32),
                _buildAnimatedTitle(),
                const SizedBox(height: 16),
                _buildAnimatedSubtitle(),
                const Spacer(flex: 2),
                _buildAnimatedLoader(),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.dark, AppColors.darkCard, AppColors.dark], stops: [0.0, 0.5, 1.0]),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _logoFade.value,
          child: Transform.scale(
            scale: _logoScale.value,
            child: Container(
              width: 130, height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary, AppColors.tertiary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 40, spreadRadius: 8)],
              ),
              padding: const EdgeInsets.all(5),
              child: Container(
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.dark),
                child: const Icon(Icons.pets_rounded, size: 60, color: AppColors.lightText),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTitle() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _textFade.value,
          child: SlideTransition(
            position: _textSlide,
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(colors: [AppColors.primary, AppColors.secondary, AppColors.tertiary]).createShader(bounds),
              child: const Text('LELOMS', style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, letterSpacing: 8, color: Colors.white)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedSubtitle() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _subtitleFade.value,
          child: const Text('Guía del Estudiante', style: TextStyle(fontSize: 15, letterSpacing: 4, color: AppColors.secondaryText)),
        );
      },
    );
  }

  Widget _buildAnimatedLoader() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _loaderFade.value,
          child: const Column(children: [
            SizedBox(width: 36, height: 36, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary))),
            SizedBox(height: 20),
            Text('Preparando tu experiencia...', style: TextStyle(color: AppColors.secondaryText, fontSize: 12, letterSpacing: 1)),
          ]),
        );
      },
    );
  }
}
