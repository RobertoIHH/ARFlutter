import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math' as math;

class ARCameraView extends StatefulWidget {
  final String modelUrl;
  final String modelName;

  const ARCameraView({
    super.key,
    required this.modelUrl,
    required this.modelName,
  });

  @override
  State<ARCameraView> createState() => _ARCameraViewState();
}

class _ARCameraViewState extends State<ARCameraView>
    with TickerProviderStateMixin {

  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool isInitialized = false;
  bool permissionGranted = false;

  // Posición y rotación del modelo AR
  double modelX = 0.5;
  double modelY = 0.5;
  double modelScale = 0.3;
  double modelRotation = 0.0;

  // Controles de animación
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  // Sensores
  double _gyroX = 0;
  double _gyroY = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _requestPermissions();
    _initializeSensors();
  }

  void _initializeAnimation() {
    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _floatAnimation = Tween<double>(
      begin: -0.02,
      end: 0.02,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
    _floatController.repeat(reverse: true);
  }

  void _initializeSensors() {
    gyroscopeEventStream().listen((GyroscopeEvent event) {
      if (mounted) {
        setState(() {
          _gyroX += event.x * 0.02;
          _gyroY += event.y * 0.02;
          _gyroX = _gyroX.clamp(-0.2, 0.2);
          _gyroY = _gyroY.clamp(-0.2, 0.2);
        });
      }
    });
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      await _initializeCamera();
    }
    setState(() {
      permissionGranted = status.isGranted;
    });
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras!.isNotEmpty) {
        _cameraController = CameraController(
          cameras![0],
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        setState(() {
          isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      setState(() {
        isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('AR: ${widget.modelName}'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetModelPosition,
            tooltip: 'Reset Position',
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showSettings,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: !permissionGranted
          ? _buildPermissionDenied()
          : !isInitialized
          ? _buildLoadingScreen()
          : _buildARView(),
    );
  }

  Widget _buildPermissionDenied() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.grey],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(0.2),
                ),
                child: const Icon(
                    Icons.camera_alt_outlined,
                    size: 64,
                    color: Colors.red
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Permiso de Cámara Requerido',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Para usar la realidad aumentada necesitamos acceso a tu cámara',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _requestPermissions,
                icon: const Icon(Icons.camera_enhance),
                label: const Text('Conceder Permisos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.blue],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                color: Colors.blue,
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Inicializando Cámara AR...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Preparando experiencia de realidad aumentada',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildARView() {
    return Stack(
      children: [
        // Vista de cámara en tiempo real
        Positioned.fill(
          child: _cameraController != null && _cameraController!.value.isInitialized
              ? CameraPreview(_cameraController!)
              : Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.grey, Colors.black],
                center: Alignment.center,
                radius: 1.0,
              ),
            ),
            child: const Center(
              child: Text(
                'Modo AR Simulado',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),

        // Overlay del modelo 3D AR - CON GESTUREDETECTOR CORREGIDO
        AnimatedBuilder(
          animation: _floatAnimation,
          builder: (context, child) {
            return Positioned(
              left: (MediaQuery.of(context).size.width * modelX) - 100 + (_gyroY * 30),
              top: (MediaQuery.of(context).size.height * modelY) - 100 + (_gyroX * 30) + (_floatAnimation.value * 20),
              child: GestureDetector(
                onTap: _rotateModel,
                onPanUpdate: (details) {
                  setState(() {
                    modelX += details.delta.dx / MediaQuery.of(context).size.width;
                    modelY += details.delta.dy / MediaQuery.of(context).size.height;
                    modelX = modelX.clamp(0.1, 0.9);
                    modelY = modelY.clamp(0.1, 0.9);
                  });
                },
                child: Transform.scale(
                  scale: modelScale,
                  child: Transform.rotate(
                    angle: modelRotation + (_floatAnimation.value * 0.1),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyan.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 60,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: ModelViewer(
                          backgroundColor: const Color(0x00000000), // Transparente
                          src: widget.modelUrl,
                          alt: widget.modelName,
                          autoRotate: true,
                          autoRotateDelay: 0,
                          rotationPerSecond: '30deg',
                          cameraControls: true,
                          disableZoom: false,
                          loading: Loading.eager,
                          reveal: Reveal.auto,
                          // Configuración adicional para mejor rendimiento
                          ar: true,
                          arModes: const ['webxr', 'scene-viewer', 'quick-look'],
                          iosSrc: widget.modelUrl,
                          // Manejo de errores
                          onWebViewCreated: (controller) {
                            debugPrint('ModelViewer WebView created');
                          },
                          // JavaScript adicional para depuración
                          javascriptChannels: {
                            JavascriptChannel(
                              'ModelViewerLogger',
                              onMessageReceived: (message) {
                                debugPrint('ModelViewer: ${message.message}');
                              },
                            ),
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Indicadores de planos AR
        ...List.generate(6, (index) => _buildARPlaneIndicator(index)),

        // Panel de información AR
        _buildInstructionsPanel(),

        // Toque para colocar modelo
        Positioned.fill(
          child: GestureDetector(
            onTapUp: (details) {
              setState(() {
                modelX = details.globalPosition.dx / MediaQuery.of(context).size.width;
                modelY = details.globalPosition.dy / MediaQuery.of(context).size.height;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildARPlaneIndicator(int index) {
    final random = math.Random(index + 42);
    final x = 0.15 + (random.nextDouble() * 0.7);
    final y = 0.25 + (random.nextDouble() * 0.5);

    return Positioned(
      left: MediaQuery.of(context).size.width * x,
      top: MediaQuery.of(context).size.height * y,
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          final offset = math.sin((_floatController.value * 2 * math.pi) + (index * 0.8)) * 8;
          final opacity = 0.3 + (math.sin((_floatController.value * 2 * math.pi) + index) * 0.2).abs();

          return Transform.translate(
            offset: Offset(0, offset),
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.cyan,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan.withOpacity(0.6),
                      blurRadius: 15,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInstructionsPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.black.withOpacity(0.6),
              Colors.transparent,
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.withOpacity(0.5)),
                ),
                child: Text(
                  'AR Mode: ${widget.modelName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInstructionItem(Icons.touch_app, 'Toca para\ncolocar'),
                  _buildInstructionItem(Icons.open_with, 'Arrastra\nmodelo'),
                  _buildInstructionItem(Icons.rotate_right, 'Toca modelo\npara rotar'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem(IconData icon, String text) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 4),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void _rotateModel() {
    setState(() {
      modelRotation += math.pi / 3; // Rotar 60 grados
    });

    // Feedback háptico si está disponible
    // HapticFeedback.lightImpact();
  }

  void _resetModelPosition() {
    setState(() {
      modelX = 0.5;
      modelY = 0.5;
      modelScale = 0.3;
      modelRotation = 0.0;
      _gyroX = 0;
      _gyroY = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✨ Modelo reiniciado'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Colors.grey],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white54,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                '⚙️ Configuración AR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Scale controls
              _buildSettingSlider(
                'Tamaño del Modelo',
                modelScale,
                0.1,
                1.0,
                    (value) => setState(() => modelScale = value),
                '${(modelScale * 100).round()}%',
              ),
              const SizedBox(height: 20),

              // Quick actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() => modelScale = 0.2);
                      },
                      icon: const Icon(Icons.zoom_out),
                      label: const Text('Pequeño'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() => modelScale = 0.8);
                      },
                      icon: const Icon(Icons.zoom_in),
                      label: const Text('Grande'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _resetModelPosition();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reiniciar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Cerrar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingSlider(
      String title,
      double value,
      double min,
      double max,
      Function(double) onChanged,
      String displayValue,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.5)),
              ),
              child: Text(
                displayValue,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.blue,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
            thumbColor: Colors.blue,
            overlayColor: Colors.blue.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
