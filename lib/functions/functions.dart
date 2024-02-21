import 'package:flutter/services.dart';
 const platform = MethodChannel('automated_call_channel');
Future<void> makeAutomatedCall(String phoneNumber) async {
  try {
    await platform
        .invokeMethod('makeAutomatedCall', {'phoneNumber': phoneNumber});
  } on PlatformException catch (e) {
    print("Failed to make automated call: '${e.message}'.");
  }
}
