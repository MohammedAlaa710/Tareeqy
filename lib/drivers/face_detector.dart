import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as services;
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

/// A face detector that detects faces in a given [InputImage].
class FaceDetector {
  static const services.MethodChannel _channel =
      services.MethodChannel('google_mlkit_face_detector');
  final FaceDetectorOptions options;
  final id = DateTime.now().microsecondsSinceEpoch.toString();
  FaceDetector({required this.options});
  Future<List<Face>> processImage(InputImage inputImage) async {
    final result = await _channel.invokeListMethod<dynamic>(
        'vision#startFaceDetector', <String, dynamic>{
      'options': options.toJson(),
      'id': id,
      'imageData': inputImage.toJson(),
    });

    final List<Face> faces = <Face>[];
    for (final dynamic json in result!) {
      faces.add(Face.fromJson(json));
    }

    return faces;
  }

  Future<void> close() =>
      _channel.invokeMethod<void>('vision#closeFaceDetector', {'id': id});
}

/// Immutable options for configuring features of [FaceDetector].
class FaceDetectorOptions {
  /// Constructor for [FaceDetectorOptions].
  /// The parameter [minFaceSize] must be between 0.0 and 1.0, inclusive.
  FaceDetectorOptions({
    this.enableClassification = false,
    this.enableLandmarks = false,
    this.enableContours = false,
    this.enableTracking = false,
    this.minFaceSize = 0.1,
    this.performanceMode = FaceDetectorMode.fast,
  })  : assert(minFaceSize >= 0.0),
        assert(minFaceSize <= 1.0);
  final bool enableClassification;

  /// Whether to detect [FaceLandmark]s.
  final bool enableLandmarks;

  /// Whether to detect [FaceContour]s.
  final bool enableContours;
  final bool enableTracking;
  final double minFaceSize;
  final FaceDetectorMode performanceMode;

  /// Returns a json representation of an instance of [FaceDetectorOptions].
  Map<String, dynamic> toJson() => {
        'enableClassification': enableClassification,
        'enableLandmarks': enableLandmarks,
        'enableContours': enableContours,
        'enableTracking': enableTracking,
        'minFaceSize': minFaceSize,
        'mode': performanceMode.name,
      };
}

class Face {
  final Rect boundingBox;
  final double? headEulerAngleX;
  final double? headEulerAngleY;
  final double? headEulerAngleZ;
  final double? leftEyeOpenProbability;
  final double? rightEyeOpenProbability;
  final double? smilingProbability;
  final int? trackingId;

  /// Gets the landmark based on the provided [FaceLandmarkType].
  final Map<FaceLandmarkType, FaceLandmark?> landmarks;

  /// Gets the contour based on the provided [FaceContourType].
  final Map<FaceContourType, FaceContour?> contours;

  Face({
    required this.boundingBox,
    required this.landmarks,
    required this.contours,
    this.headEulerAngleX,
    this.headEulerAngleY,
    this.headEulerAngleZ,
    this.leftEyeOpenProbability,
    this.rightEyeOpenProbability,
    this.smilingProbability,
    this.trackingId,
  });

  /// Returns an instance of [Face] from a given [json].
  factory Face.fromJson(Map<dynamic, dynamic> json) => Face(
        boundingBox: RectJson.fromJson(json['rect']),
        headEulerAngleX: json['headEulerAngleX'],
        headEulerAngleY: json['headEulerAngleY'],
        headEulerAngleZ: json['headEulerAngleZ'],
        leftEyeOpenProbability: json['leftEyeOpenProbability'],
        rightEyeOpenProbability: json['rightEyeOpenProbability'],
        smilingProbability: json['smilingProbability'],
        trackingId: json['trackingId'],
        landmarks: Map<FaceLandmarkType, FaceLandmark?>.fromIterables(
            FaceLandmarkType.values,
            FaceLandmarkType.values.map((FaceLandmarkType type) {
          final List<dynamic>? pos = json['landmarks'][type.name];
          return (pos == null)
              ? null
              : FaceLandmark(
                  type: type,
                  position: Point<int>(pos[0].toInt(), pos[1].toInt()),
                );
        })),
        contours: Map<FaceContourType, FaceContour?>.fromIterables(
            FaceContourType.values,
            FaceContourType.values.map((FaceContourType type) {
          /// added empty map to pass the tests
          final List<dynamic>? arr =
              (json['contours'] ?? <String, dynamic>{})[type.name];
          return (arr == null)
              ? null
              : FaceContour(
                  type: type,
                  points: arr
                      .map<Point<int>>((dynamic pos) =>
                          Point<int>(pos[0].toInt(), pos[1].toInt()))
                      .toList(),
                );
        })),
      );
}

class FaceLandmark {
  /// The [FaceLandmarkType] of this landmark.
  final FaceLandmarkType type;
  final Point<int> position;

  FaceLandmark({required this.type, required this.position});
}

class FaceContour {
  /// The [FaceContourType] of this contour.
  final FaceContourType type;

  /// Gets a 2D point [List] for contour positions.
  final List<Point<int>> points;
  FaceContour({required this.type, required this.points});
}

enum FaceDetectorMode {
  accurate,
  fast,
}

/// Available face landmarks detected by [FaceDetector].
enum FaceLandmarkType {
  bottomMouth,
  rightMouth,
  leftMouth,
  rightEye,
  leftEye,
  rightEar,
  leftEar,
  rightCheek,
  leftCheek,
  noseBase,
}

/// Available face contour types detected by [FaceDetector].
enum FaceContourType {
  face,
  leftEyebrowTop,
  leftEyebrowBottom,
  rightEyebrowTop,
  rightEyebrowBottom,
  leftEye,
  rightEye,
  upperLipTop,
  upperLipBottom,
  lowerLipTop,
  lowerLipBottom,
  noseBridge,
  noseBottom,
  leftCheek,
  rightCheek
}
