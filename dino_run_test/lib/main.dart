import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Cactus.dart';
import 'Cloud.dart';
import 'CreditosPage.dart';
import 'Dino.dart';
import 'GameObject.dart';
import 'Ground.dart';
import 'Constants.dart';

void main() {
  runApp(const MyApp());
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return const MaterialApp(
      title: 'Flutter Dino',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Agregar la imagen encima del botón
            Image.asset(
              'assets/images/dino/dino_1.png',
              height: 150, // Ajusta la altura según tus necesidades
            ),
            const SizedBox(height: 20), // Espacio entre la imagen y el botón
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MyHomePage()),
                );
              },
              child: const Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  Dino dino = Dino();
  double runVelocity = initialVelocity;
  double runDistance = 0;
  late int highScore; // Variable para almacenar el high score

  // Controladores de texto para las configuraciones de física
  TextEditingController gravityController =
      TextEditingController(text: gravity.toString());
  TextEditingController accelerationController =
      TextEditingController(text: acceleration.toString());
  TextEditingController jumpVelocityController =
      TextEditingController(text: jumpVelocity.toString());
  TextEditingController runVelocityController =
      TextEditingController(text: initialVelocity.toString());
  TextEditingController dayNightOffestController =
      TextEditingController(text: dayNightOffest.toString());

  late AnimationController worldController;
  Duration lastUpdateCall = const Duration();

  // Listas de objetos del juego
  List<Cactus> cacti = [Cactus(worldLocation: const Offset(200, 0))];

  List<Ground> ground = [
    Ground(worldLocation: const Offset(0, 0)),
    Ground(worldLocation: Offset(groundSprite.imageWidth / 10, 0))
  ];

  List<Cloud> clouds = [
    Cloud(worldLocation: const Offset(100, 20)),
    Cloud(worldLocation: const Offset(200, 10)),
    Cloud(worldLocation: const Offset(350, -10)),
  ];

  @override
  void initState() {
    super.initState();
    worldController =
        AnimationController(vsync: this, duration: const Duration(days: 99));
    worldController.addListener(_update);
    // worldController.forward();
    _die();

    // Recuperar el high score al inicio
    obtenerHighScore().then((value) {
      setState(() {
        highScore = value;
      });
    });
  }

  void _die() {
    setState(() {
      worldController.stop();
      dino.die();
    });
  }

  void _newGame() {
    setState(() {
      highScore = max(highScore, runDistance.toInt());
      runDistance = 0;
      runVelocity = initialVelocity;
      dino.state = DinoState.running;
      dino.despY = 0;
      worldController.reset();
      // Generar nuevos obstáculos, suelo y nubes
      cacti = [
        Cactus(worldLocation: const Offset(200, 0)),
        Cactus(worldLocation: const Offset(300, 0)),
        Cactus(worldLocation: const Offset(450, 0)),
      ];

      ground = [
        Ground(worldLocation: const Offset(0, 0)),
        Ground(worldLocation: Offset(groundSprite.imageWidth / 10, 0))
      ];

      clouds = [
        Cloud(worldLocation: const Offset(100, 20)),
        Cloud(worldLocation: const Offset(200, 10)),
        Cloud(worldLocation: const Offset(350, -15)),
        Cloud(worldLocation: const Offset(500, 10)),
        Cloud(worldLocation: const Offset(550, -10)),
      ];

      // Guardar el high score actualizado
      guardarHighScore(highScore);

      worldController.forward();
    });
  }

  _update() {
    try {
      double elapsedTimeSeconds;
      dino.update(lastUpdateCall, worldController.lastElapsedDuration);
      try {
        elapsedTimeSeconds =
            (worldController.lastElapsedDuration! - lastUpdateCall)
                    .inMilliseconds /
                1000;
      } catch (_) {
        elapsedTimeSeconds = 0;
      }

      runDistance += runVelocity * elapsedTimeSeconds;
      if (runDistance < 0) runDistance = 0;
      runVelocity += acceleration * elapsedTimeSeconds;

      Size screenSize = MediaQuery.of(context).size;

      Rect dinoRect = dino.getRect(screenSize, runDistance);
      for (Cactus cactus in cacti) {
        Rect obstacleRect = cactus.getRect(screenSize, runDistance);
        if (dinoRect.overlaps(obstacleRect.deflate(20))) {
          _die();
        }

        if (obstacleRect.right < 0) {
          setState(() {
            cacti.remove(cactus);
            cacti.add(Cactus(
                worldLocation: Offset(
                    runDistance +
                        Random().nextInt(100) +
                        MediaQuery.of(context).size.width / worlToPixelRatio,
                    0)));
          });
        }
      }

      for (Ground groundlet in ground) {
        if (groundlet.getRect(screenSize, runDistance).right < 0) {
          setState(() {
            ground.remove(groundlet);
            ground.add(
              Ground(
                worldLocation: Offset(
                  ground.last.worldLocation.dx + groundSprite.imageWidth / 10,
                  0,
                ),
              ),
            );
          });
        }
      }

      for (Cloud cloud in clouds) {
        if (cloud.getRect(screenSize, runDistance).right < 0) {
          setState(() {
            clouds.remove(cloud);
            clouds.add(
              Cloud(
                worldLocation: Offset(
                  clouds.last.worldLocation.dx +
                      Random().nextInt(200) +
                      MediaQuery.of(context).size.width / worlToPixelRatio,
                  Random().nextInt(50) - 25.0,
                ),
              ),
            );
          });
        }
      }

      lastUpdateCall = worldController.lastElapsedDuration!;
    } catch (e) {
      //
    }
  }

  // Función para guardar el high score en SharedPreferences
  void guardarHighScore(int valor) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('high_score', valor);
  }

  // Función para recuperar el high score de SharedPreferences
  Future<int> obtenerHighScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int miEntero =
        prefs.getInt('high_score') ?? 0; // Si no hay valor, se establece en 0
    return miEntero;
  }

  @override
  void dispose() {
    gravityController.dispose();
    accelerationController.dispose();
    jumpVelocityController.dispose();
    runVelocityController.dispose();
    dayNightOffestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    List<Widget> children = [];

    // Añadir objetos del juego a la lista de widgets
    for (GameObject object in [...clouds, ...ground, ...cacti, dino]) {
      children.add(
        AnimatedBuilder(
          animation: worldController,
          builder: (context, _) {
            Rect objectRect = object.getRect(screenSize, runDistance);
            return Positioned(
              left: objectRect.left,
              top: objectRect.top,
              width: objectRect.width,
              height: objectRect.height,
              child: object.render(),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _die();
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Change Physics"),
                    actions: [
                      // Configuración de la física del juego para el usuario
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 25,
                          width: 280,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Gravity:"),
                              SizedBox(
                                height: 25,
                                width: 75,
                                child: TextField(
                                  controller: gravityController,
                                  key: UniqueKey(),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 25,
                          width: 280,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Acceleration:"),
                              SizedBox(
                                height: 25,
                                width: 75,
                                child: TextField(
                                  controller: accelerationController,
                                  key: UniqueKey(),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 25,
                          width: 280,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Initial Velocity:"),
                              SizedBox(
                                height: 25,
                                width: 75,
                                child: TextField(
                                  controller: runVelocityController,
                                  key: UniqueKey(),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 25,
                          width: 280,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Jump Velocity:"),
                              SizedBox(
                                height: 25,
                                width: 75,
                                child: TextField(
                                  controller: jumpVelocityController,
                                  key: UniqueKey(),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 25,
                          width: 280,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Day-Night Offset:"),
                              SizedBox(
                                height: 25,
                                width: 75,
                                child: TextField(
                                  controller: dayNightOffestController,
                                  key: UniqueKey(),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          gravity = int.parse(gravityController.text);
                          acceleration =
                              double.parse(accelerationController.text);
                          initialVelocity =
                              double.parse(runVelocityController.text);
                          jumpVelocity =
                              double.parse(jumpVelocityController.text);
                          dayNightOffest =
                              int.parse(dayNightOffestController.text);
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Done",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text('Créditos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreditosPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 5000),
        color: (runDistance ~/ dayNightOffest) % 2 == 0
            ? Colors.white
            : Colors.black,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (dino.state != DinoState.dead) {
              dino.jump();
            }
            if (dino.state == DinoState.dead) {
              _newGame();
            }
          },
          onDoubleTap: () {
            if (dino.state != DinoState.dead) {
              dino.doubleJump();
            }
            if (dino.state == DinoState.dead) {
              _newGame();
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              ...children,
              // Mostrar el puntaje actual y el puntaje más alto
              AnimatedBuilder(
                animation: worldController,
                builder: (context, _) {
                  return Positioned(
                    left: screenSize.width / 2 - 30,
                    top: 100,
                    child: Text(
                      'Score: ${runDistance.toInt()}',
                      style: TextStyle(
                          color: (runDistance ~/ dayNightOffest) % 2 == 0
                              ? Colors.black
                              : Colors.white,
                          fontFamily: "Pixelify_Sans"),
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: worldController,
                builder: (context, _) {
                  return Positioned(
                    left: screenSize.width / 2 - 50,
                    top: 120,
                    child: Text(
                      'High Score: $highScore', // Actualiza el texto con el valor de highScore
                      style: TextStyle(
                          color: (runDistance ~/ dayNightOffest) % 2 == 0
                              ? Colors.black
                              : Colors.white,
                          fontFamily: "Pixelify_Sans"),
                    ),
                  );
                },
              ),
              // Botón para matar al dinosaurio forzosamente
              Positioned(
                bottom: 20,
                child: TextButton(
                  onPressed: () {
                    _die();
                  },
                  child: const Text(
                    "Force Kill Dino",
                    style: TextStyle(
                        color: Colors.red, fontFamily: "Pixelify_Sans"),
                  ),
                ),
              ),
              // Créditos del creador del juego
              const Positioned(
                bottom: 10,
                child: Text(
                  "By Francisco Jose Paneque Jurado",
                  style: TextStyle(
                      color: Color.fromARGB(255, 119, 119, 119),
                      fontFamily: "Pixelify_Sans"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
