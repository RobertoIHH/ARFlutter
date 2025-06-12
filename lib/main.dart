import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'ar_camera_view.dart'; // Agregar esta línea

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR 3D Viewer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ARViewerHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ARViewerHomePage extends StatefulWidget {
  const ARViewerHomePage({super.key});

  @override
  State<ARViewerHomePage> createState() => _ARViewerHomePageState();
}

class _ARViewerHomePageState extends State<ARViewerHomePage> {
  String selectedModel = 'https://modelviewer.dev/shared-assets/models/Astronaut.glb';

  final List<Map<String, String>> models = [
    {
      'name': '🚀 Astronauta',
      'url': 'https://modelviewer.dev/shared-assets/models/Astronaut.glb'
    },
    {
      'name': '🤖 Robot Expresivo',
      'url': 'https://modelviewer.dev/shared-assets/models/RobotExpressive.glb'
    },
    {
      'name': '🏎️ Ferrari',
      'url': 'https://modelviewer.dev/shared-assets/models/ferrari.glb'
    },
    {
      'name': '🪑 Damaged Helmet',
      'url': 'https://modelviewer.dev/shared-assets/models/DamagedHelmet.glb'
    },
  ];

  String get selectedModelName {
    return models.firstWhere((model) => model['url'] == selectedModel)['name'] ?? 'Modelo 3D';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          'AR 3D Model Viewer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: Column(
        children: [
          // Panel de selección de modelos
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[50]!, Colors.indigo[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.view_in_ar, color: Colors.indigo[700], size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Selecciona tu modelo 3D:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.indigo[200]!),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedModel,
                    underline: Container(),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.indigo[700]),
                    items: models.map((model) {
                      return DropdownMenuItem<String>(
                        value: model['url'],
                        child: Text(
                          model['name']!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedModel = newValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Botón para AR con cámara
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ARCameraView(
                      modelUrl: selectedModel,
                      modelName: selectedModelName,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.camera_alt, size: 28),
              label: const Text(
                'ABRIR AR CON CÁMARA',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Visor 3D tradicional
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ModelViewer(
                  backgroundColor: const Color(0xFFEEEEEE),
                  src: selectedModel,
                  alt: "Modelo 3D interactivo",
                  ar: true,
                  autoRotate: true,
                  iosSrc: selectedModel,
                  disableZoom: false,
                  cameraControls: true,
                  arModes: const ['webxr', 'scene-viewer', 'quick-look'],
                  autoPlay: true,
                ),
              ),
            ),
          ),

          // Panel de información
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[50]!, Colors.teal[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.tips_and_updates_outlined,
                        color: Colors.green[700], size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Dos formas de usar AR:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🔴 BOTÓN ROJO: AR con cámara en tiempo real'),
                    Text('📱 VISOR 3D: Toca "AR" para AR del sistema'),
                    Text('• Arrastra para rotar el modelo'),
                    Text('• Pellizca para hacer zoom'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
