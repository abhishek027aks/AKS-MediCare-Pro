import 'package:flutter/material.dart';

/// ===============================================================
/// AppSectionCard
/// ---------------------------------------------------------------
/// Reusable Material 3 Section Card
///
/// Used Across:
/// • User Management
/// • Patient Registration
/// • Doctor
/// • Pharmacy
/// • Laboratory
/// • Billing
/// • Inventory
/// • HR
/// ===============================================================
class AppSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  final Color? iconColor;
  final Color? backgroundColor;
  final Color? borderColor;

  final bool showDivider;

  const AppSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.padding,
    this.margin,
    this.iconColor,
    this.backgroundColor,
    this.borderColor,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      margin: margin ??
          const EdgeInsets.symmetric(
            vertical: 10,
          ),
      color: backgroundColor ?? theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: borderColor ??
              theme.colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: padding ??
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      theme.colorScheme.primaryContainer,
                  child: Icon(
                    icon,
                    color: iconColor ??
                        theme.colorScheme.primary,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            if (showDivider) ...[
              const SizedBox(height: 16),

              Divider(
                color: theme.colorScheme.outlineVariant,
                height: 1,
              ),

              const SizedBox(height: 20),
            ],

            child,
          ],
        ),
      ),
    );
  }
}