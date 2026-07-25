import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegister = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingXxl,
          child: Column(
            children: [
              AppSpacing.gapVerticalXxl,
              Icon(Icons.auto_awesome, size: 48, color: AppColors.primary),
              AppSpacing.gapVerticalMd,
              Text('LELOMS', style: AppTypography.headlineMedium),
              AppSpacing.gapVerticalSm,
              Text(_isRegister ? 'Creá tu cuenta' : 'Iniciar sesión',
                  style: AppTypography.bodyLarge.copyWith(color: isDark ? AppColors.secondaryText : AppColors.lightTextSecondary)),
              AppSpacing.gapVerticalXxl,
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo electrónico', prefixIcon: Icon(Icons.email_outlined)),
                keyboardType: TextInputType.emailAddress,
              ),
              AppSpacing.gapVerticalLg,
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña', prefixIcon: Icon(Icons.lock_outlined)),
                obscureText: true,
              ),
              AppSpacing.gapVerticalXxl,
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(_isRegister ? 'Crear cuenta' : 'Iniciar sesión'),
              ),
              AppSpacing.gapVerticalLg,
              TextButton(
                onPressed: () => setState(() => _isRegister = !_isRegister),
                child: Text(_isRegister ? 'Ya tengo cuenta' : 'Crear cuenta nueva'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
