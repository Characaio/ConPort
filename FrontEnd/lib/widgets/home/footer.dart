import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:conport/core/navigation/page_loader.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: colors.onSurface.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _FooterItem(icon: Symbols.home, text: "Início", onTap: () {}),
          _FooterItem(
            icon: Symbols.flag,
            text: "Missões",
            onTap: () => PageLoader.go(context, PageLoader.missions),
          ),
          _FooterItem(icon: Symbols.school, text: "Aprender", onTap: () =>PageLoader.go(context,PageLoader.educacao,
          ),
          ),
        ],
      ),
    );
  }
}

class _FooterItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _FooterItem({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: colors.onSurface),
            const SizedBox(height: 2),
            Text(text, style: TextStyle(color: colors.onSurface, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
