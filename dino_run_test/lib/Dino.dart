import 'package:flutter/material.dart';
import 'Constants.dart'; // Importación de constantes del juego
import 'GameObject.dart'; // Importación de la clase base de objetos del juego
import 'Sprite.dart'; // Importación de la clase Sprite

// Lista de sprites para la animación del dinosaurio
List<Sprite> dinos = [
  Sprite()
    ..imagePath = "assets/images/dino/dino_1.png"
    ..imageWidth = 88
    ..imageHeight = 94,
  Sprite()
    ..imagePath = "assets/images/dino/dino_2.png"
    ..imageWidth = 88
    ..imageHeight = 94,
  Sprite()
    ..imagePath = "assets/images/dino/dino_3.png"
    ..imageWidth = 88
    ..imageHeight = 94,
  Sprite()
    ..imagePath = "assets/images/dino/dino_4.png"
    ..imageWidth = 88
    ..imageHeight = 94,
  Sprite()
    ..imagePath = "assets/images/dino/dino_5.png"
    ..imageWidth = 88
    ..imageHeight = 94,
  Sprite()
    ..imagePath = "assets/images/dino/dino_6.png"
    ..imageWidth = 88
    ..imageHeight = 94,
];

// Enumeración para representar el estado del dinosaurio
enum DinoState {
  jumping,
  running,
  dead,
}

// Clase que define al dinosaurio en el juego
class Dino extends GameObject {
  Sprite currentSprite = dinos[0]; // Sprite actual del dinosaurio
  double despY = 0; // Desplazamiento vertical del dinosaurio
  double valY = 0; // Velocidad vertical del dinosaurio
  DinoState state = DinoState.running; // Estado actual del dinosaurio

  @override
  Widget render() {
    // Método para renderizar el sprite del dinosaurio
    return Image.asset(
      currentSprite.imagePath,
    );
  }

  @override
  Rect getRect(Size screenSize, double runDistance) {
    // Método para obtener el rectángulo delimitador del dinosaurio en la pantalla
    return Rect.fromLTWH(
      screenSize.width / 10,
      screenSize.height / 2 - currentSprite.imageHeight - despY,
      currentSprite.imageWidth.toDouble(),
      currentSprite.imageHeight.toDouble(),
    );
  }

  @override
  void update(Duration lastTime, Duration? elapsedTime) {
    // Método para actualizar la posición y estado del dinosaurio
    double elapsedTimeSeconds;
    try {
      // Obtener el siguiente sprite de la animación del dinosaurio
      currentSprite = dinos[(elapsedTime!.inMilliseconds / 100).floor() % 2 + 2];
    } catch (_) {
      currentSprite = dinos[0];
    }
    try {
      // Calcular el tiempo transcurrido en segundos
      elapsedTimeSeconds = (elapsedTime! - lastTime).inMilliseconds / 1000;
    } catch (_) {
      elapsedTimeSeconds = 0;
    }

    // Actualizar la posición vertical del dinosaurio según la gravedad
    despY += valY * elapsedTimeSeconds;
    if (despY <= 0) {
      // Detener el movimiento vertical si el dinosaurio toca el suelo
      despY = 0;
      valY = 0;
      state = DinoState.running;
    } else {
      // Aplicar la gravedad al movimiento vertical
      valY -= gravity * elapsedTimeSeconds;
    }
  }

  // Método para hacer que el dinosaurio salte
  void jump() {
    if (state != DinoState.jumping) {
      state = DinoState.jumping;
      valY = 750; // Establecer la velocidad de salto
    }
  }

  // Método para hacer que el dinosaurio realice un doble salto
  void doubleJump() {
    if (state != DinoState.jumping) {
      state = DinoState.jumping;
      valY = 950; // Establecer la velocidad de doble salto
    }
  }

  // Método para indicar que el dinosaurio ha muerto
  void die() {
    currentSprite = dinos[5]; // Cambiar el sprite al de muerte
    state = DinoState.dead; // Cambiar el estado a muerto
  }

  // Método para reiniciar las propiedades del dinosaurio
  void reset() {
    currentSprite = dinos[0]; // Restablecer el sprite inicial
    despY = 0; // Restablecer el desplazamiento vertical
    valY = 0; // Restablecer la velocidad vertical
    state = DinoState.running; // Restablecer el estado a corriendo
  }
}