import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  bool _isFlipped = false;
  late AnimationController _controller;
  late Animation<double> _frontRotation;
  late Animation<double> _backRotation;

  // Colores reutilizables para evitar warnings
  static const Color _bgColor = Color(0xFF0B1020);
  static const Color _cardBg = Color(0x99000000); // Negro con 60% opacidad
  static const Color _textPrimary = Color(0xFFE2E8F0);
  static const Color _textSecondary = Color(0xFF94A3B8);
  static const Color _accent = Color(0xFF818CF8);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _frontRotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 90.0), weight: 50.0),
      TweenSequenceItem(tween: Tween(begin: 90.0, end: 90.0), weight: 50.0),
    ]).animate(_controller);
    
    _backRotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: -90.0, end: -90.0), weight: 50.0),
      TweenSequenceItem(tween: Tween(begin: -90.0, end: 0.0), weight: 50.0),
    ]).animate(_controller);
  }

  void _toggleCard() {
    setState(() {
      _isFlipped = !_isFlipped;
      if (_isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // TODO: Reemplazar con tu imagen de fondo
          // Image.asset('assets/background.jpg', fit: BoxFit.cover),
          
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                // TODO: Reemplazar con tu logo
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                  ),
                  child: const Icon(Icons.pets_rounded, size: 60, color: Colors.white70),
                ),
                const SizedBox(height: 20),
                const Text('LELOMS', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4, color: _textPrimary)),
                const Text('Guía del estudiante', style: TextStyle(fontSize: 16, color: _textSecondary, letterSpacing: 2)),
                const Spacer(),
                
                GestureDetector(
                  onTap: _toggleCard,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    height: 320,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Transform(
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateY(_frontRotation.value * 3.14159 / 180),
                              alignment: FractionalOffset.center,
                              child: Opacity(
                                opacity: _controller.value < 0.5 ? 1.0 : 0.0,
                                child: _buildFrontCard(),
                              ),
                            );
                          },
                        ),
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Transform(
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateY(_backRotation.value * 3.14159 / 180),
                              alignment: FractionalOffset.center,
                              child: Opacity(
                                opacity: _controller.value >= 0.5 ? 1.0 : 0.0,
                                child: _buildBackCard(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrontCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Bienvenido', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _textPrimary)),
          const SizedBox(height: 16),
          const Text(
            'Tu carrera al\nalcance de una\nlágrima',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic, color: Color(0xFFCBD5E1)),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('¿No tienes cuenta? ', style: TextStyle(color: _textSecondary)),
              TextButton(
                onPressed: _toggleCard,
                child: const Text('Regístrate', style: TextStyle(color: _accent, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Crear Cuenta', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _textPrimary)),
          const SizedBox(height: 24),
          _buildSocialButton(Icons.g_mobiledata, 'Registrarme con Google', const Color(0xFFDB4437)),
          const SizedBox(height: 12),
          _buildSocialButton(Icons.apple, 'Registrarme con Apple', Colors.white),
          const SizedBox(height: 12),
          _buildSocialButton(Icons.facebook, 'Registrarme con Facebook', const Color(0xFF4267B2)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('¿Ya tienes cuenta? ', style: TextStyle(color: _textSecondary)),
              TextButton(
                onPressed: _toggleCard,
                child: const Text('Inicia sesión', style: TextStyle(color: _accent, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String text, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, color: color),
        label: Text(text, style: const TextStyle(color: _textPrimary)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withValues(alpha: 0.5)),
          backgroundColor: color.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
