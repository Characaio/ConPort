import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:conport/core/navigation/page_loader.dart';

class Topbar extends StatelessWidget {
  final bool hasLogo;
  final bool hasReturn;
  final String text;

  Topbar({required this.hasLogo, required this.hasReturn, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        if (hasLogo) ...[
          Image(image: AssetImage('assets/images/ConportLogo.png'), width: 48),
          Text(
            "Conport",
            style: TextStyle(
              color: colors.primary,
              fontSize: 24.0,
              fontWeight: FontWeight.w600,
              fontFamily: 'Quicksand',
            ),
          ),
        ],
        if (hasReturn)
          IconButton(
            icon: Icon(Symbols.arrow_left_alt),
            onPressed: () {
              PageLoader.back(context);
            },
          ),

        if (text != "") Text(text, style: TextStyle(fontSize: 20.0)),
        const Spacer(),
        Icon(
          Symbols.local_fire_department,
          color: Colors.orange,
          size: 32,
          weight: 500.0,
        ),
        const SizedBox(width: 8.0),
        Text(
          "14",
          style: TextStyle(
            color: Colors.orange,
            fontSize: 20.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        IconButton(
          onPressed: () {
            PageLoader.go(context, PageLoader.profile);
          },
          icon: Icon(Symbols.account_circle, size: 32, weight: 1000.0, fill: 1),
        ),
      ],
    );
  }
}
