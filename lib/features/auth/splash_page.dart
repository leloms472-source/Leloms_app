import 'package:flutter/material.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  static const String _backgroundUrl = 
      'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=1080';
  
  static const String _logoUrl = 
      'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=200';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _navigateToLogin();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
  }

  Future<void> _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.6),
              BlendMode.darken,
            ),
            child: Image.network(
              _backgroundUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(color: const Color(0xFF0B1020));
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(color: const Color(0xFF0B1020));
              },
            ),
          ),
          
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFFEC4899), Color(0xFFF97316)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withValues(alpha: 0.5),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF0B1020),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              _logoUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF6366F1),
                                    strokeWidth: 2,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.auto_stories_rounded,
                                  size: 70,
                                  color: Color(0xFF6366F1),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFFEC4899), Color(0xFFF97316)],
                        ).createShader(bounds),
                        child: const Text(
                          'LELOMS',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 6,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      const Text(
                        'Guía del Estudiante',
                        style: TextStyle(
                          fontSize: 16,
                          letterSpacing: 3,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 60),
                      
                      const Column(
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Cargando tu experiencia...',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
