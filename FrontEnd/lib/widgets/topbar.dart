import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:conport/core/navigation/page_loader.dart';
import 'package:conport/widgets/notifications.dart';

class Topbar extends StatelessWidget {
  final bool hasLogo;
  final bool hasReturn;
  final bool showSettings;
  final String? text;

  const Topbar({
    super.key,
    required this.hasLogo,
    required this.hasReturn,
    this.showSettings = false,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (hasLogo) ...[
          Image(image: AssetImage('assets/images/ConportLogo.png'), width: 48),
        ],
        if (hasReturn)
          IconButton(
            icon: Icon(Symbols.arrow_left_alt),
            onPressed: () {
              PageLoader.back(context);
            },
          ),

        if (text != null && text!.isNotEmpty)
          Text(text!, style: const TextStyle(fontSize: 20.0)),
        const Spacer(),
        IconButton(
          onPressed: () => mostrarNotificacoes(context),
          icon: Icon(Symbols.notifications, size: 24, weight: 1000),
        ),
        IconButton(
          onPressed: () {
            PageLoader.go(
              context,
              showSettings ? PageLoader.settingsPage : PageLoader.profile,
            );
          },
          icon: Icon(
            showSettings ? Symbols.settings : Symbols.account_circle,
            size: showSettings ? 27 : 32,
            weight: 1000.0,
            fill: showSettings ? 0 : 1,
          ),
        ),
      ],
    );
  }
}
