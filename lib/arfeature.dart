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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(color: Colors.tealAccent.shade700),
        floatingActionButtonTheme:
        FloatingActionButtonThemeData(backgroundColor: Colors.tealAccent),
      ),
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
  List<ArCoreNode> placedNodes = [];

  final List<Map<String, String>> models = [
    {"name": "Plant", "file": "plant.glb"},
    {"name": "Rose Plant", "file": "roseplant.glb"},
    {"name": "Aloe Vera", "file": "aloevera.glb"},
    {"name": "Marigold", "file": "marigold.glb"},
    {"name": "Lavender", "file": "lavender.glb"},
    {"name": "Grassbed", "file": "grass.glb"},
    {"name": "Plant Stand", "file": "plant_pot_stand.glb"}
  ];

  late String selectedModel;
  double scaleFactor = 0.2;

  @override
  void initState() {
    super.initState();
    selectedModel = models[0]["file"]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ARCore 3D Model Viewer")),
      body: Stack(
        children: [
          GestureDetector(
            onScaleUpdate: (details) {
              setState(() {
                scaleFactor = (scaleFactor * details.scale).clamp(0.05, 1.0);
              });
            },
            child: ArCoreView(
              onArCoreViewCreated: _onArCoreViewCreated,
              enableTapRecognizer: true,
              enablePlaneRenderer: true,
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
          color: Colors.tealAccent.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black45, blurRadius: 10, spreadRadius: 2)
          ],
        ),
        child: DropdownButton<String>(
          dropdownColor: Colors.tealAccent.shade700,
          value: selectedModel,
          isExpanded: true,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
      bottom: 90,
      right: 20,
      child: FloatingActionButton(
        child: Icon(Icons.undo, color: Colors.black),
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
      placedNodes.add(node);
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
