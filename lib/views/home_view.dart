// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              var status = await Permission.photos.status;
              print(status);

              if (status.isDenied) {
              await Permission.photos.request();
                print(status);
              }
              if (status.isPermanentlyDenied) {
                showAlertDialog(context);
              }
            },
            child: const Text('Call'),
          )
        ],
      ),
    );
  }
}

Future<void> getLostData(BuildContext context) async {
  XFile? image = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxHeight: 500,
    maxWidth: 500,
    imageQuality: 90,
    requestFullMetadata: true,
  );
}

showAlertDialog(context) => showCupertinoDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('Permission Denied'),
          content: const Text('Allow this app to access photos?'),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Settings'),
              onPressed: () => openAppSettings(),
            ),
          ],
        ));
void showConfirmationDialog(
    {required BuildContext context,
    required String message,
    required VoidCallback onYes,
    required VoidCallback onNo}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirmation'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => onYes(),
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () => onNo(),
            child: const Text('No'),
          ),
        ],
      );
    },
  );
}
