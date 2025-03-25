import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:permission_handler/permission_handler.dart';

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

class _ARViewScreenState extends State<ARViewScreen>
    with SingleTickerProviderStateMixin {
  late ArCoreController arCoreController;
  List<ArCoreNode> placedNodes = [];
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _showInstructions = true;
  bool _hasCameraPermission = false;

  final List<Map<String, dynamic>> models = [
    {
      "name": "Plant",
      "file": "plant.glb",
      "icon": Icons.local_florist,
      "color": Colors.green,
      "description": "A beautiful indoor plant"
    },
    {
      "name": "Rose Plant",
      "file": "roseplant.glb",
      "icon": Icons.eco,
      "color": Colors.red,
      "description": "Elegant rose plant"
    },
    {
      "name": "Aloe Vera",
      "file": "aloevera.glb",
      "icon": Icons.medical_services,
      "color": Colors.teal,
      "description": "Medicinal aloe vera plant"
    },
    {
      "name": "Marigold",
      "file": "marigold.glb",
      "icon": Icons.wb_sunny,
      "color": Colors.orange,
      "description": "Bright marigold flowers"
    },
    {
      "name": "Lavender",
      "file": "lavender.glb",
      "icon": Icons.spa,
      "color": Colors.purple,
      "description": "Aromatic lavender plant"
    },
    {
      "name": "Grassbed",
      "file": "grass.glb",
      "icon": Icons.grass,
      "color": Colors.lightGreen,
      "description": "Natural grass patch"
    },
    {
      "name": "Plant Stand",
      "file": "plant_pot_stand.glb",
      "icon": Icons.table_bar,
      "color": Colors.brown,
      "description": "Stylish plant stand"
    }
  ];

  late String selectedModel;
  double scaleFactor = 0.2;

  @override
  void initState() {
    super.initState();
    selectedModel = models[0]["file"]!;
    _checkCameraPermission();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    setState(() {
      _hasCameraPermission = status.isGranted;
    });
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _hasCameraPermission = status.isGranted;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    arCoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AR Plant Viewer',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green.shade600,
                Colors.teal.shade700,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          if (_hasCameraPermission)
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
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 80,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Camera Access Required',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Please allow camera access to use AR features',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _requestCameraPermission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Grant Camera Permission',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_hasCameraPermission) ...[
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildModelSelector(),
              ),
            ),
            _buildUndoButton(),
            if (_showInstructions) _buildInstructionsOverlay(),
          ],
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select a Plant',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: models.length,
                itemBuilder: (context, index) {
                  final model = models[index];
                  final isSelected = model['file'] == selectedModel;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedModel = model['file']!;
                      });
                    },
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? model['color'].withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected ? model['color'] : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            model['icon'],
                            color: model['color'],
                            size: 32,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            model['name'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUndoButton() {
    return Positioned(
      bottom: 160,
      right: 20,
      child: FloatingActionButton(
        backgroundColor: Colors.white,
        child: Icon(Icons.undo, color: Colors.green.shade700),
        onPressed: _undoLastModel,
        elevation: 4,
      ),
    );
  }

  Widget _buildInstructionsOverlay() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    const Text(
                      'How to Use',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _showInstructions = false;
                    });
                  },
                  color: Colors.grey.shade700,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '1. Select a plant from the bottom menu\n2. Tap on the surface to place the plant\n3. Pinch to resize\n4. Use undo button to remove last plant',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ],
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
}

class ARCoreModelViewer extends StatefulWidget {
  final String modelPath;

  const ARCoreModelViewer({super.key, required this.modelPath});

  @override
  _ARCoreModelViewerState createState() => _ARCoreModelViewerState();
}

class _ARCoreModelViewerState extends State<ARCoreModelViewer> {
  ArCoreController? arCoreController;
  ArCoreNode? modelNode;
  double scale = 0.5;
  vector.Vector3 position = vector.Vector3(0, 0, -1.5);

  @override
  void dispose() {
    arCoreController?.dispose();
    super.dispose();
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    _addModel(arCoreController!);
  }

  void _addModel(ArCoreController controller) {
    modelNode = ArCoreReferenceNode(
      name: 'product_model',
      object3DFileName: widget.modelPath,
      position: position,
      scale: vector.Vector3(scale, scale, scale),
      rotation: vector.Vector4(0, 0, 0, 0),
    );

    controller.addArCoreNode(modelNode!);
  }

  void _handleScale(ScaleUpdateDetails details) {
    if (modelNode == null || arCoreController == null) return;

    setState(() {
      scale = (scale * details.scale).clamp(0.1, 2.0);
      arCoreController!.removeNode(nodeName: modelNode!.name);
      _addModel(arCoreController!);
    });
  }

  void _handlePan(DragUpdateDetails details) {
    if (modelNode == null || arCoreController == null) return;

    setState(() {
      position = vector.Vector3(
        position.x + details.delta.dx * 0.01,
        position.y - details.delta.dy * 0.01,
        position.z,
      );
      arCoreController!.removeNode(nodeName: modelNode!.name);
      _addModel(arCoreController!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Model Viewer'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GestureDetector(
        onScaleUpdate: _handleScale,
        onPanUpdate: _handlePan,
        child: ArCoreView(
          onArCoreViewCreated: _onArCoreViewCreated,
          enableTapRecognizer: true,
        ),
      ),
    );
  }
}
