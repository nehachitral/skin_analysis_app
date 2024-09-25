import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(SkinAnalysisApp());

class SkinAnalysisApp extends StatelessWidget {
  const SkinAnalysisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skin Analysis App',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false; // Track loading state

  Future<void> _getImage() async {
    // Request camera and storage permissions
    if (await _requestPermissions()) {
      try {
        setState(() {
          _isLoading = true; // Show loading indicator
        });

        final pickedFile = await _picker.pickImage(source: ImageSource.camera);

        if (pickedFile != null) {
          setState(() {
            _image = File(pickedFile.path);
          });
          // After capturing, run TensorFlow Lite model here
          _analyzeSkin(_image);
        } else {
          _showError("No image selected.");
        }
      } catch (e) {
        _showError("Error picking image: $e");
      } finally {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  Future<bool> _requestPermissions() async {
    var cameraStatus = await Permission.camera.status;
    var storageStatus = await Permission.storage.status;

    if (!cameraStatus.isGranted) {
      await Permission.camera.request();
    }
    if (!storageStatus.isGranted) {
      await Permission.storage.request();
    }

    return await Permission.camera.isGranted &&
        await Permission.storage.isGranted;
  }

  void _analyzeSkin(File? image) {
    // Call TensorFlow Lite model here using the `tflite` plugin
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello, Kidut'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator() // Show loading indicator
                : (_image != null
                    ? Image.file(_image!, height: 300, width: 300)
                    : Container(
                        height: 300, width: 300, color: Colors.grey[300])),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getImage,
              child: const Text('Take a Scan'),
            ),
            const SizedBox(height: 20),
            // Results or other UI components can be added here
            const Text("Skin Results"),
          ],
        ),
      ),
    );
  }
}
