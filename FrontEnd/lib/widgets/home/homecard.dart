import 'package:flutter/material.dart';
import 'package:conport/core/navigation/page_loader.dart';
import 'package:conport/core/theme/app_theme.dart';

class HomeCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final String? pagina;
  final VoidCallback? onTap;

  HomeCard({
    required this.icon,
    required this.text,
    required this.color,
    this.pagina,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap:
            onTap ??
            () {
              if (pagina != null) PageLoader.go(context, pagina!);
            },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 5),
                color: colors.shadow.withValues(alpha: 0.22),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsetsGeometry.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(96),
                    color: colors.surface,
                  ),
                  child: Icon(
                    icon,
                    color: colors.onSurface,
                    size: 20,
                    weight: 700,
                  ),
                ),
                Text(
                  text,
                  style: TextStyle(color: appColors.onAccent, fontSize: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
