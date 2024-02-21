// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class ScheduleCallsView extends StatefulWidget {
  const ScheduleCallsView({Key? key}) : super(key: key);

  @override
  _ScheduleCallsViewState createState() => _ScheduleCallsViewState();
}

class _ScheduleCallsViewState extends State<ScheduleCallsView> {
  late TextEditingController _phoneNumberController;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _phoneNumberController = TextEditingController();
    _selectedTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _scheduleCall() async {
    //check premissions first
    var status = await Permission.backgroundRefresh.request();
    if (status.isDenied) {
      await Permission.backgroundRefresh.request();
    }
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
    // var backgroundStatus = await Permission.activityRecognition.request();
    // if (backgroundStatus.isDenied) {
    //   await Permission.activityRecognition.request();
    // }
    // if (backgroundStatus.isPermanentlyDenied) {
    //   openAppSettings();
    // }
    // var locationStatus = await Permission.location.request();
    // if (locationStatus.isDenied) {
    //   await Permission.location.request();
    // }
    // if (locationStatus.isPermanentlyDenied) {
    //   openAppSettings();
    // }
    // var alarmStatus = await Permission.criticalAlerts.request();
    // if (alarmStatus.isDenied) {
    //   await Permission.criticalAlerts.request();
    // }
    // if (alarmStatus.isPermanentlyDenied) {
    //   openAppSettings();
    // }
    // var ignoreBatteryOptimizationStatus =
    //     await Permission.ignoreBatteryOptimizations.request();
    // if (ignoreBatteryOptimizationStatus.isDenied) {
    //   await Permission.ignoreBatteryOptimizations.request();
    // }
    // if (ignoreBatteryOptimizationStatus.isPermanentlyDenied) {
    //   openAppSettings();
    // }



    // var callStatus = await Permission.phone.request();

    // if (callStatus.isDenied) {
    //   await Permission.phone.request();
    // }
    // if (callStatus.isPermanentlyDenied) {
    //   openAppSettings();
    // }
    // Schedule the call
    final String phoneNumber = _phoneNumberController.text;
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a phone number'),
        ),
      );
      print('Please enter a phone number');
      return;
    }

    final DateTime now = DateTime.now();
    final DateTime scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    try {
      await AndroidAlarmManager.periodic(
        const Duration(days: 1), // Repeat daily
        0, // Alarm ID
        makeAutomatedCall,
        startAt: scheduledTime,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
        allowWhileIdle: true, // Allow execution even when app is in idle state
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Call scheduled successfully'),
        ),
      );
      print('Call scheduled successfully');
    } catch (e) {
      // Handle error
      print('Error scheduling call: $e');
    }
  }

  Future<void> makeAutomatedCall(int alarmId) async {
    // Make the automated call
    print('Making automated call with ID: $alarmId');
    final String phoneNumber = _phoneNumberController.text;
    const platform = MethodChannel('automated_call_channel');
    try {
      await platform
          .invokeMethod('makeAutomatedCall', {'phoneNumber': phoneNumber});
    } on PlatformException catch (e) {
      print("Failed to make automated call: '${e.message}'.");
    }
  }

  Future<void> _showTimePicker() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Calls'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Phone Number:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _showTimePicker,
              child: Text(
                'Select Time: ${_selectedTime.format(context)}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _scheduleCall,
              child: const Text(
                'Schedule Automated Call',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
