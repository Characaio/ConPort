import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class UnidadeIndicador extends StatelessWidget {
  final IconData? simbolo;
  final String texto;

  const UnidadeIndicador({required this.simbolo, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(simbolo, color: Colors.white, size: 32),
        SizedBox(width: 4.0),
        Expanded(
          child: Text(
            texto,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
