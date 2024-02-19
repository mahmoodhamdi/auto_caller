// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';

import 'package:auto_caller/hive/video_box.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
class VideoPickerView extends StatefulWidget {
  const VideoPickerView({Key? key}) : super(key: key);

  @override
  _VideoPickerViewState createState() => _VideoPickerViewState();
}

class _VideoPickerViewState extends State<VideoPickerView> {
  File? _pickedVideo;
  VideoPlayerController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
Future<void> _pickVideo() async {
    var status = await Permission.videos.request();
    if (status.isDenied) {
      await Permission.videos.request();
    }
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
    if (status.isGranted) {
      final video = await ImagePicker().pickVideo(source: ImageSource.gallery);
      if (video == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No video selected'),
        ));
        _pickedVideo = null;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Video selected'),
        ));
        _pickedVideo = File(video.path);
        _controller = VideoPlayerController.file(_pickedVideo!)
          ..initialize().then((_) {
            setState(() {
              _controller!.play(); // Start playing the video
            });
          });
      }
    }
  }

Future<void> _saveVideo() async {
    if (_pickedVideo != null) {
      final box = await VideoBox.openBox();
      final videoName = p.basename(_pickedVideo!.path);
      await box.put(videoName, _pickedVideo!.readAsBytesSync());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Video saved successfully'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No video picked'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Picker'),
      ),
      body: Center(
        child: _pickedVideo == null
            ? const Text('No video selected')
            : _controller != null && _controller!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  )
                : const CircularProgressIndicator(),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _pickVideo,
            tooltip: 'Pick Video',
            child: const Icon(Icons.video_call),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _saveVideo,
            tooltip: 'Save video',
            child: const Icon(Icons.save),
          ),
        ],
      ),
    );
  }
}
