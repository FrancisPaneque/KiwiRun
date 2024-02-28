import 'package:flutter/widgets.dart';
import 'Constants.dart'; // Importar las constantes del juego
import 'GameObject.dart'; // Importar la clase base de objetos del juego
import 'sprite.dart'; // Importar la clase Sprite

// Sprite para la nube
Sprite cloudSprite = Sprite()
  ..imagePath = "assets/images/cloud.png"
  ..imageWidth = 92
  ..imageHeight = 27;

// Clase que representa una nube en el juego
class Cloud extends GameObject {
  final Offset worldLocation; // Ubicación de la nube en el mundo del juego

  // Constructor de la nube
  Cloud({required this.worldLocation});

  @override
  Rect getRect(Size screenSize, double runDistance) {
    // Método para obtener el rectángulo delimitador de la nube en la pantalla
    return Rect.fromLTWH(
      (worldLocation.dx - runDistance) * worlToPixelRatio / 5, // Posición horizontal relativa de la nube
      screenSize.height / 5 - cloudSprite.imageHeight - worldLocation.dy, // Posición vertical de la nube
      cloudSprite.imageWidth.toDouble(), // Ancho del sprite de la nube
      cloudSprite.imageHeight.toDouble(), // Alto del sprite de la nube
    );
  }

  @override
  Widget render() {
    // Método para renderizar el sprite de la nube
    return Image.asset(cloudSprite.imagePath);
  }
}
