// ignore_for_file: deprecated_member_use, file_names

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tareeqy_metro/drivers/driverService.dart';

class Camera extends StatefulWidget {
  const Camera({super.key});

  @override
  CameraState createState() => CameraState();
}

class CameraState extends State<Camera> {
  File? _imageFile;
  List<Face>? _faces;
  bool isLoading = false;
  ui.Image? _image;
  final picker = ImagePicker();
  int _faceCount = 0; // Variable to hold the count of faces

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _getImage,
        child: const Icon(Icons.add_a_photo),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _imageFile == null
              ? const Center(child: Text('No image selected'))
              : Center(
                  child: _image == null
                      ? const CircularProgressIndicator()
                      : FittedBox(
                          child: SizedBox(
                            width: _image!.width.toDouble(),
                            height: _image!.height.toDouble(),
                            child: CustomPaint(
                              painter: FacePainter(_image!, _faces!),
                            ),
                          ),
                        ),
                ),
    );
  }



Future<void> _getImage() async {
  print("hi from Get image function");

  // Request camera permission
  var status = await Permission.camera.status;
  print("status camera " + status.name) ; 
  if (!status.isGranted) {
    print("hi from if not gramted1");
    status = await Permission.camera.request();
    if (!status.isGranted) {
      print("hi from if not gramted2");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission is required to take photos')),
      );
      return;
    }
  }
print("hi after the permission");
  final pickedFile = await picker.pickImage(source: ImageSource.camera);
  if (pickedFile == null) return;
  print("hi after picked file isn't null");

  setState(() {
    isLoading = true;
  });

  final inputImage = InputImage.fromFile(File(pickedFile.path));
  final faceDetector = GoogleMlKit.vision.faceDetector();
  List<Face> faces = await faceDetector.processImage(inputImage);

  if (mounted) {
    setState(() {
      _imageFile = File(pickedFile.path);
      _faces = faces;
      _faceCount = faces.length; // Update face count
    DriverService().sendFaceCountToFirestore(_faceCount);
      _loadImage(File(pickedFile.path));
    });

    // Show message with the number of faces recognized
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Number of faces recognized: $_faceCount')),
    );

    // Save face count to Firestore
  }
}


  Future<void> _loadImage(File file) async {
    final data = await file.readAsBytes();
    await decodeImageFromList(data).then((value) => setState(() {
          _image = value;
          isLoading = false;
        }));
  }
}

class FacePainter extends CustomPainter {
  final ui.Image image;
  final List<Face> faces;
  final List<Rect> rects = [];

  FacePainter(this.image, this.faces) {
    for (var i = 0; i < faces.length; i++) {
      rects.add(faces[i].boundingBox);
    }
  }

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.yellow;

    canvas.drawImage(image, Offset.zero, Paint());
    for (var i = 0; i < faces.length; i++) {
      canvas.drawRect(rects[i], paint);
    }
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return image != oldDelegate.image || faces != oldDelegate.faces;
  }
}