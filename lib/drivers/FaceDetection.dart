import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tareeqy_metro/drivers/driverService.dart';

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
        .close(); // Close the face detector when the widget is disposed
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    WidgetsFlutterBinding.ensureInitialized(); // Ensure plugins are initialized
    print("Inside camera initialization");
    try {
      var cameras = await availableCameras();
      print("Available cameras: $cameras");
      if (cameras.isEmpty) {
        print("No cameras available");
        return;
      }

      try {
        print("Initializing camera");
        _controller = CameraController(
          cameras[0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        print("Using camera: ${cameras[0]}");

        await _controller!.initialize();
        print("Camera initialized");
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
      // Stop taking photos
      _timer?.cancel();
      print("Automatic capture stopped");
      setState(() {
        _isTakingPhotos = false;
      });
    } else {
      // Capture image immediately and start timer
      _captureAndProcessImage();

      // Start taking photos every minute
      _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
        if (!_isTakingPhotos) {
          timer.cancel();
          print("Timer canceled");
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
      print("Camera not initialized or controller not available");
      return;
    }

    try {
      XFile file = await _controller!.takePicture();
      print("Picture captured: ${file.path}");

      final inputImage = InputImage.fromFilePath(file.path);
      List<Face> faces = await _faceDetector.processImage(inputImage);
      print("Number of faces detected: ${faces.length}");

      setState(() {
        _imageFile = File(file.path);
        _faceCount = faces.length;
        DriverService().sendFaceCountToFirestore(_faceCount);
      });
      await _loadImage(File(file.path)); // Wait for image loading to complete

      // Show message with the number of faces recognized
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Number of faces recognized: $_faceCount')),
      );
    } catch (e) {
      print("Error taking picture: $e");
    }
  }

  Future<void> _loadImage(File file) async {
    print("Loading image from file");
    try {
      print("Does the file exist ${file.existsSync()}");
      print("What's the file? ${file}");

      if (!file.existsSync()) {
        print("File does not exist: ${file.path}");
        return;
      }
      final data = await file.readAsBytes();
      print("Data: $data");

      await decodeImageFromList(data).then((value) {
        print("Data after awaiting: $data");
        print("Value after awaiting: $value");

        setState(() {
          _image = value;
          isLoading = false;
          print("Image loaded successfully");
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
    print("Painting canvas");
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
