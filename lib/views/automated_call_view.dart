import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AutomatedCallView extends StatelessWidget {
  static const platform = MethodChannel('automated_call_channel');

  const AutomatedCallView({super.key});

  Future<void> makeAutomatedCall(String phoneNumber) async {
    try {
      await platform
          .invokeMethod('makeAutomatedCall', {'phoneNumber': phoneNumber});
    } on PlatformException catch (e) {
      print("Failed to make automated call: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController phoneNumberController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Automated Call Example'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text('Enter phone number:'),
              const SizedBox(height: 16),
              TextField(
            maxLength: 11,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.phone,
                controller: phoneNumberController,
                decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  prefixIcon: Icon(Icons.phone),
                  prefixIconColor: Colors.blue,
                  prefixIconConstraints: BoxConstraints(minWidth: 32),
                labelText: 'Phone Number',
                ),
                onSubmitted: (value) {
                  makeAutomatedCall(phoneNumberController.text);
                  print(phoneNumberController.text);
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => makeAutomatedCall(
                    phoneNumberController.text), // Example phone number
                child: const Text('Make Automated Call'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
