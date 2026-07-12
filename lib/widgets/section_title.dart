import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionTitle({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    if (trailing != null) {
      return Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.lightText,
            ),
          ),
          const Spacer(),
          trailing!,
        ],
      );
    }
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.lightText,
      ),
    );
  }
}
