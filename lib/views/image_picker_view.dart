// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:io';

import 'package:auto_caller/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
class ImagePickerView extends StatefulWidget {
  const ImagePickerView({super.key});
  @override
  _ImagePickerViewState createState() => _ImagePickerViewState();
}
class _ImagePickerViewState extends State<ImagePickerView> {
  File? _pickedImage;
  Future<void> _pickImage() async {
    var status = await Permission.photos.request();
    if (status.isDenied) {
      await Permission.photos.request();
    }
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
    if (status.isGranted) {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No image selected'),
        ));
        _pickedImage = null;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Image selected'),
        ));
        _pickedImage = File(image.path);
      }
    }
    // Implement your image picking logic here
    // For example, using image_picker package
  }

  Future<void> _saveImage() async {
    if (_pickedImage != null) {
      final box = await ImageBox.openBox();
      final imageName = p.basename(_pickedImage!.path);
      await box.put(imageName, _pickedImage!.readAsBytesSync());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Image saved successfully'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No image picked'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Picker'),
      ),
      body: Center(
        child: _pickedImage == null
            ? const Text('No image selected')
            : Image.file(_pickedImage!),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _pickImage,
            tooltip: 'Pick Image',
            child: const Icon(Icons.add_a_photo),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _saveImage,
            tooltip: 'Save Image',
            child: const Icon(Icons.save),
          ),
        ],
      ),
    );
  }
}
