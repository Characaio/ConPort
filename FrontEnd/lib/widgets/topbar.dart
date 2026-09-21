import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class Topbar extends StatelessWidget {
  const Topbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image(image: AssetImage('assets/images/ConportLogo.png'), width: 48),
        Text(
          "Conport",
          style: TextStyle(
            color: Colors.green,
            fontSize: 24.0,
            fontWeight: FontWeight.w600,
            fontFamily: 'Quicksand',
          ),
        ),
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
          onPressed: () {},
          icon: Icon(Symbols.account_circle, size: 32, weight: 1000.0, fill: 1),
        ),
      ],
    );
  }
}
