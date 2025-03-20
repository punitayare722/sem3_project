import 'package:flutter/material.dart';
import 'package:arcore/home.dart';

final Color darkGreen = Color(0xFF006400); // Dark Green
final Color darkBlue = Color(0xFF00008B); // Dark Blue

void main() async {
  runApp(const SmartGardenApp());
}

class SmartGardenApp extends StatelessWidget {
  const SmartGardenApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Garden Management System',
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'Roboto',
        ),
        home: HomePage());
  }
}
/*
main arcode


import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ARViewScreen(),
    );
  }
}

class ARViewScreen extends StatefulWidget {
  @override
  _ARViewScreenState createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  late ArCoreController arCoreController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ARCore 3D Model")),
      body: ArCoreView(
        onArCoreViewCreated: _onArCoreViewCreated,
        enableTapRecognizer: true,
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    arCoreController.onPlaneTap = _onPlaneTap;
  }

  void _onPlaneTap(List<ArCoreHitTestResult> hits) {
    if (hits.isNotEmpty) {
      final hit = hits.first;
      final node = ArCoreReferenceNode(
        name: "Model",
        objectUrl: "file:///android_asset/plant.glb", // Correct path for assets inside Android project
        position: hit.pose.translation,
        rotation: hit.pose.rotation,
        scale: vector.Vector3(0.2, 0.2, 0.2),
      );
      arCoreController.addArCoreNodeWithAnchor(node);
    }
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ARViewScreen(),
    );
  }
}

class ARViewScreen extends StatefulWidget {
  @override
  _ARViewScreenState createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  late ArCoreController arCoreController;
  ArCoreReferenceNode? modelNode;
  vector.Vector3 modelPosition = vector.Vector3.zero();
  double modelScale = 0.2; // Default scale

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ARCore 3D Model")),
      body: GestureDetector(
        onScaleUpdate: (details) {
          setState(() {
            // Adjust position (dragging)
            modelPosition.x += details.focalPointDelta.dx * 0.0005;
            modelPosition.y -= details.focalPointDelta.dy * 0.0005;

            // Adjust scale (pinch to zoom)
            modelScale = (details.scale * 0.2).clamp(0.05, 1.5); // Prevent extreme sizes

            _updateModel();
          });
        },
        child: ArCoreView(
          onArCoreViewCreated: _onArCoreViewCreated,
          enableTapRecognizer: true,
        ),
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    arCoreController.onPlaneTap = _onPlaneTap;
  }

  void _onPlaneTap(List<ArCoreHitTestResult> hits) {
    if (hits.isNotEmpty) {
      final hit = hits.first;
      modelPosition = hit.pose.translation; // Set model's initial position
      _addModel();
    }
  }

  void _addModel() {
    if (modelNode != null) {
      arCoreController.removeNode(nodeName: modelNode!.name);
    }

    modelNode = ArCoreReferenceNode(
      name: "PlantModel",
      objectUrl: "file:///android_asset/plant.glb",
      position: modelPosition,
      rotation: vector.Vector4(0, 0, 0, 1),
      scale: vector.Vector3.all(modelScale),
    );

    arCoreController.addArCoreNodeWithAnchor(modelNode!);
  }

  void _updateModel() {
    if (modelNode != null) {
      arCoreController.removeNode(nodeName: modelNode!.name);
      _addModel();  // Re-add the model with updated position and scale
    }
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }
}

multiple plant model
import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ARViewScreen(),
    );
  }
}

class ARViewScreen extends StatefulWidget {
  @override
  _ARViewScreenState createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  late ArCoreController arCoreController;

  // List of available models
  final List<Map<String, String>> models = [
    {"name": "Plant", "file": "plant.glb"},
    {"name": "Rose Plant", "file": "roseplant.glb"},
    {"name": "Aloe Vera", "file": "aloevera.glb"},
    {"name": "Mari Gold", "file": "marigold.glb"},
    {"name": "Lavender", "file": "lavender.glb"},
    {"name": "Grassbed", "file": "grass.glb"},
    {"name": "Plant stand", "file": "plant_pot_stand.glb"}
  ];

  late String selectedModel;
  double scaleFactor = 0.2; // Default scale

  @override
  void initState() {
    super.initState();
    selectedModel = models[0]["file"]!; // Default selection
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ARCore 3D Model")),
      body: Stack(
        children: [
          GestureDetector(
            onScaleUpdate: (ScaleUpdateDetails details) {
              setState(() {
                scaleFactor = (scaleFactor * details.scale)
                    .clamp(0.05, 1.0); // Limit scale between 0.05 and 1.0
              });
            },
            child: ArCoreView(
              onArCoreViewCreated: _onArCoreViewCreated,
              enableTapRecognizer: true,
            ),
          ),
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                value: selectedModel,
                isExpanded: true,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedModel = newValue;
                    });
                  }
                },
                items: models.map((model) {
                  return DropdownMenuItem<String>(
                    value: model["file"]!,
                    child: Text(model["name"]!),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    arCoreController.onPlaneTap = _onPlaneTap;
  }

  void _onPlaneTap(List<ArCoreHitTestResult> hits) {
    if (hits.isNotEmpty) {
      final hit = hits.first;
      final node = ArCoreReferenceNode(
        name: "SelectedModel",
        objectUrl: "file:///android_asset/$selectedModel",
        position: hit.pose.translation,
        rotation: hit.pose.rotation,
        scale: vector.Vector3(scaleFactor, scaleFactor, scaleFactor),
      );
      arCoreController.addArCoreNodeWithAnchor(node);
    }
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }
}



multiple with undo






import 'package:flutter/material.dart';

import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';

import 'package:vector_math/vector_math_64.dart' as vector;



void main() {

  runApp(MyApp());

}



class MyApp extends StatelessWidget {

  @override

  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      home: ARViewScreen(),

    );

  }

}



class ARViewScreen extends StatefulWidget {

  @override

  _ARViewScreenState createState() => _ARViewScreenState();

}



class _ARViewScreenState extends State<ARViewScreen> {

  late ArCoreController arCoreController;

  List<ArCoreNode> placedNodes = []; // Store placed models



  // List of available models

  final List<Map<String, String>> models = [

    {"name": "Plant", "file": "plant.glb"},

    {"name": "Rose Plant", "file": "roseplant.glb"},

    {"name": "Aloe Vera", "file": "aloevera.glb"},

    {"name": "Mari Gold", "file": "marigold.glb"},

    {"name": "Lavender", "file": "lavender.glb"},

    {"name": "Grassbed", "file": "grass.glb"},

    {"name": "Plant stand", "file": "plant_pot_stand.glb"}

  ];



  late String selectedModel;

  double scaleFactor = 0.2; // Default scale



  @override

  void initState() {

    super.initState();

    selectedModel = models[0]["file"]!; // Default selection

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: Text("ARCore 3D Model")),

      body: Stack(

        children: [

          GestureDetector(

            onScaleUpdate: (ScaleUpdateDetails details) {

              setState(() {

                scaleFactor = (scaleFactor * details.scale)

                    .clamp(0.05, 1.0); // Limit scale between 0.05 and 1.0

              });

            },

            child: ArCoreView(

              onArCoreViewCreated: _onArCoreViewCreated,

              enableTapRecognizer: true,

              enablePlaneRenderer: true, // Show detected surfaces

            ),

          ),

          _buildModelSelector(),

          _buildUndoButton(),

        ],

      ),

    );

  }



  Widget _buildModelSelector() {

    return Positioned(

      bottom: 20,

      left: 10,

      right: 10,

      child: Container(

        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        decoration: BoxDecoration(

          color: Colors.white.withOpacity(0.8),

          borderRadius: BorderRadius.circular(12),

        ),

        child: DropdownButton<String>(

          value: selectedModel,

          isExpanded: true,

          onChanged: (String? newValue) {

            if (newValue != null) {

              setState(() {

                selectedModel = newValue;

              });

            }

          },

          items: models.map((model) {

            return DropdownMenuItem<String>(

              value: model["file"]!,

              child: Text(model["name"]!),

            );

          }).toList(),

        ),

      ),

    );

  }



  Widget _buildUndoButton() {

    return Positioned(

      bottom: 80,

      right: 20,

      child: FloatingActionButton(

        backgroundColor: Colors.red,

        child: Icon(Icons.undo, color: Colors.white),

        onPressed: _undoLastModel,

      ),

    );

  }



  void _onArCoreViewCreated(ArCoreController controller) {

    arCoreController = controller;

    arCoreController.onPlaneTap = _onPlaneTap;

  }



  void _onPlaneTap(List<ArCoreHitTestResult> hits) {

    if (hits.isNotEmpty) {

      // Select the most stable plane hit

      hits.sort((a, b) => a.distance.compareTo(b.distance));

      final hit = hits.first;



      final node = ArCoreReferenceNode(

        name: "Model_${placedNodes.length}",

        objectUrl: "file:///android_asset/$selectedModel",

        position: hit.pose.translation,

        rotation: hit.pose.rotation,

        scale: vector.Vector3(scaleFactor, scaleFactor, scaleFactor),

      );



      arCoreController.addArCoreNodeWithAnchor(node);

      placedNodes.add(node); // Track placed models

    }

  }



  void _undoLastModel() {

    if (placedNodes.isNotEmpty) {

      final lastNode = placedNodes.removeLast();

      arCoreController.removeNode(nodeName: lastNode.name);

    }

  }



  @override

  void dispose() {

    arCoreController.dispose();

    super.dispose();

  }

}

*/
