import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? leading;
  final Widget? trailing;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    const Color bgCard = Color(0xFF2A313B);
    const Color primaryText = Color(0xFFEDF9FF);
    const Color secondaryText = Color(0xFFAEBBC8);
    const Color accentPrimary = Color(0xFF6C5BFF);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container with subtle glow
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accentPrimary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: accentPrimary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: 32,
                color: accentPrimary,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: secondaryText,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Yellow accent bar
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.yellowAccent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
