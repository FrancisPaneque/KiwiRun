import 'package:flutter/widgets.dart';
import 'Constants.dart'; // Importar las constantes del juego
import 'GameObject.dart'; // Importar la clase base de objetos del juego
import 'sprite.dart'; // Importar la clase Sprite

// Sprite para el suelo
Sprite groundSprite = Sprite()
  ..imagePath = "assets/images/ground.png"
  ..imageWidth = 2399
  ..imageHeight = 24;

// Clase que representa el suelo en el juego
class Ground extends GameObject {
  final Offset worldLocation; // Ubicación del suelo en el mundo del juego

  // Constructor del suelo
  Ground({required this.worldLocation});

  @override
  Rect getRect(Size screenSize, double runDistance) {
    // Método para obtener el rectángulo delimitador del suelo en la pantalla
    return Rect.fromLTWH(
      (worldLocation.dx - runDistance) * worlToPixelRatio, // Posición horizontal relativa del suelo
      screenSize.height / 2 - groundSprite.imageHeight, // Posición vertical del suelo
      groundSprite.imageWidth.toDouble(), // Ancho del sprite del suelo
      groundSprite.imageHeight.toDouble(), // Alto del sprite del suelo
    );
  }

  @override
  Widget render() {
    // Método para renderizar el sprite del suelo
    return Image.asset(groundSprite.imagePath);
  }
}