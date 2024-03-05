// ignore: file_names
import 'package:flutter/material.dart';

class CreditosPage extends StatelessWidget {
  const CreditosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créditos'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Desarrollado por:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Francisco José Paneque Jurado',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Herramientas:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'GoogleFonts, GitHub, SharedPreferences...',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(height: 20),
            
          ],
        ),
      ),
    );
  }
}