import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin_plus/ar_flutter_plugin_plus.dart';
//import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:ar_flutter_plugin_plus/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_location_manager.dart';

import 'package:ar_flutter_plugin_plus/datatypes/node_types.dart';
//import 'package:ar_flutter_plugin_plus/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_plus/models/ar_node.dart';





class ARViewer extends StatefulWidget {
  final String imageUrl;

  const ARViewer({super.key, required this.imageUrl});

  @override
  State<ARViewer> createState() => _ARViewerState();
}

class _ARViewerState extends State<ARViewer> {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AR View")),
      body: ARView(
        onARViewCreated: onARViewCreated,
      ),
    );
  }

  Future<void> onARViewCreated(
  ARSessionManager sessionManager,
  ARObjectManager objectManager,
  ARAnchorManager anchorManager,
  ARLocationManager locationManager,
) async {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;

    await arSessionManager.onInitialize(
  showFeaturePoints: false,
  showPlanes: true,
  customPlaneTexturePath: null,
  showWorldOrigin: false,
  handleTaps: false,
);


    // place flat plane + texture
    var node = ARNode(
      type: NodeType.localGLTF2,
      uri: "assets/models/plane.glb",
    );

    await arObjectManager.addNode(node);
  }
}
