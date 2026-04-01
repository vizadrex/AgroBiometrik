import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  CameraController? get controller => _controller;

  Future<void> initialize() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await _controller!.initialize();
    } else {
      throw Exception('No cameras found');
    }
  }

  Future<void> startImageStream(Function(CameraImage) onImage) async {
    if (_controller != null && _controller!.value.isInitialized) {}
  }

  Future<XFile?> takePicture() async {
    if (_controller != null && _controller!.value.isInitialized) {
      return await _controller!.takePicture();
    }
    return null;
  }

  Future<void> stopImageStream() async {
    if (_controller != null && _controller!.value.isStreamingImages) {
      await _controller!.stopImageStream();
    }
  }

  void dispose() {
    _controller?.dispose();
  }
}
