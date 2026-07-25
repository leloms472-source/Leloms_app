import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

class LelomsCat extends StatelessWidget {
  final String? message;
  final double size;

  const LelomsCat({
    super.key,
    this.message,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.pets_rounded, color: Colors.white, size: 20),
        ),
        if (message != null) ...[
          AppSpacing.gapHorizontalSm,
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(message!, style: AppTypography.bodySmall.copyWith(color: AppColors.lightText)),
            ),
          ),
        ],
      ],
    );
  }
}

class LelomsCatBanner extends StatelessWidget {
  final String greeting;
  final String message;
  final VoidCallback? onDismiss;

  const LelomsCatBanner({
    super.key,
    required this.greeting,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.secondary.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.pets_rounded, color: Colors.white, size: 22),
              ),
              AppSpacing.gapHorizontalMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(greeting, style: AppTypography.titleMedium.copyWith(
                      color: isDark ? AppColors.lightText : AppColors.lightTextPrimary,
                    )),
                    Text(message, style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.secondaryText : AppColors.lightTextSecondary,
                    )),
                  ],
                ),
              ),
              if (onDismiss != null)
                GestureDetector(
                  onTap: onDismiss,
                  child: const Icon(Icons.close_rounded, color: AppColors.secondaryText, size: 18),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
