import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tareeqy_metro/Driver/driverService.dart';

class Camera extends StatefulWidget {
  const Camera({super.key});

  @override
  CameraState createState() => CameraState();
}

class CameraState extends State<Camera> {
  CameraController? _controller;
  bool _isTakingPhotos = false;
  Timer? _timer;
  bool _isCameraInitialized = false;

  File? _imageFile;
  ui.Image? _image;
  bool isLoading = false;
  int _faceCount = 0;
  late FaceDetector _faceDetector;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeFaceDetector();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    _faceDetector
        .close();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      var cameras = await availableCameras();
      if (cameras.isEmpty) {
        return;
      }

      try {
        _controller = CameraController(
          cameras[0],
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _controller!.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
        _toggleAutomaticCapture();
      } catch (e) {
        print("Error initializing camera: $e");
      }
    } catch (e) {
      print("Error getting available cameras: $e");
    }
  }

  void _initializeFaceDetector() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
        enableContours: true,
        enableTracking: true,
        minFaceSize: 0.1,
        performanceMode: FaceDetectorMode.fast,
      ),
    );
  }

  void _toggleAutomaticCapture() {
    if (_isTakingPhotos) {
      _timer?.cancel();
      setState(() {
        _isTakingPhotos = false;
      });
    } else {
      _captureAndProcessImage();
      _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
        if (!_isTakingPhotos) {
          timer.cancel();
          return;
        }
        _captureAndProcessImage();
      });

      setState(() {
        _isTakingPhotos = true;
      });
    }
  }

  Future<void> _captureAndProcessImage() async {
    if (!_isCameraInitialized ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return;
    }

    try {
      XFile file = await _controller!.takePicture();

      final inputImage = InputImage.fromFilePath(file.path);
      List<Face> faces = await _faceDetector.processImage(inputImage);

      setState(() {
        _imageFile = File(file.path);
        _faceCount = faces.length;
        DriverService().sendFaceCountToFirestore(_faceCount);
      });
      await _loadImage(File(file.path));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Number of faces recognized: $_faceCount')),
      );
    } catch (e) {
      print("Error taking picture: $e");
    }
  }

  Future<void> _loadImage(File file) async {
    try {
      if (!file.existsSync()) {
        return;
      }
      final data = await file.readAsBytes();

      await decodeImageFromList(data).then((value) {

        setState(() {
          _image = value;
          isLoading = false;
        });
      }).catchError((error) {
        print("Error decoding image: $error");
      });
    } catch (error) {
      print("Error loading image: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Automatic Face Detection Camera')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Automatic Face Detection Camera')),
      body: Column(
        children: [
          if (_imageFile != null)
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      _image != null
                          ? FittedBox(
                              child: SizedBox(
                                width: _image!.width.toDouble(),
                                height: _image!.height.toDouble(),
                                child: CustomPaint(
                                  painter: FacePainter(_image!),
                                ),
                              ),
                            )
                          : const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      Text(
                        'Number of faces recognized: $_faceCount',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleAutomaticCapture,
        child: Icon(_isTakingPhotos ? Icons.stop : Icons.play_arrow),
      ),
    );
  }
}

class FacePainter extends CustomPainter {
  final ui.Image image;

  FacePainter(
    this.image,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.yellow;

    canvas.drawImage(image, Offset.zero, paint);
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return image != oldDelegate.image;
  }
}
