import 'package:flutter/material.dart';
import 'package:conport/widgets/topbar.dart';
import 'package:conport/widgets/homemap.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Topbar(),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: Colors.green, width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: SizedBox(height: 300, child: HomeMap()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
