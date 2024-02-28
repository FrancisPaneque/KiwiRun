import 'dart:math';
import 'package:flutter/widgets.dart';
import 'Constants.dart'; // Importar las constantes del juego
import 'GameObject.dart'; // Importar la clase base de objetos del juego
import 'sprite.dart'; // Importar la clase Sprite

// Lista de sprites para los cactus
List<Sprite> cacti = [
  Sprite()
    ..imagePath = "assets/images/cacti/cacti_group.png"
    ..imageWidth = 104
    ..imageHeight = 100,
  Sprite()
    ..imagePath = "assets/images/cacti/cacti_large_1.png"
    ..imageWidth = 50
    ..imageHeight = 100,
  Sprite()
    ..imagePath = "assets/images/cacti/cacti_large_2.png"
    ..imageWidth = 98
    ..imageHeight = 100,
  Sprite()
    ..imagePath = "assets/images/cacti/cacti_small_1.png"
    ..imageWidth = 34
    ..imageHeight = 70,
  Sprite()
    ..imagePath = "assets/images/cacti/cacti_small_2.png"
    ..imageWidth = 68
    ..imageHeight = 70,
  Sprite()
    ..imagePath = "assets/images/cacti/cacti_small_3.png"
    ..imageWidth = 107
    ..imageHeight = 70,
];

// Clase que representa un cactus en el juego
class Cactus extends GameObject {
  final Sprite sprite; // Sprite del cactus
  final Offset worldLocation; // Ubicación del cactus en el mundo del juego

  // Constructor del cactus
  Cactus({required this.worldLocation})
      : sprite = cacti[Random().nextInt(cacti.length)]; // Seleccionar un sprite aleatorio para el cactus

  @override
  Rect getRect(Size screenSize, double runDistance) {
    // Método para obtener el rectángulo delimitador del cactus en la pantalla
    return Rect.fromLTWH(
      (worldLocation.dx - runDistance) * worlToPixelRatio, // Posición horizontal relativa del cactus
      screenSize.height / 2 - sprite.imageHeight, // Posición vertical del cactus
      sprite.imageWidth.toDouble(), // Ancho del sprite del cactus
      sprite.imageHeight.toDouble(), // Alto del sprite del cactus
    );
  }

  @override
  Widget render() {
    // Método para renderizar el sprite del cactus
    return Image.asset(sprite.imagePath);
  }
}