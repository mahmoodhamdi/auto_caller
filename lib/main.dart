import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:third_party_integration/models/contact_model.dart';
import 'package:third_party_integration/views/automated_call_view.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:third_party_integration/views/schedule_call_view.dart';

void main() async {
  // Initialize Hive

  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  Hive.registerAdapter(ContactModelAdapter());
  await AndroidAlarmManager.initialize();

   // Additional initialization code...
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Third Party Integration',
      home: ScheduleCallsView(),
    );
  }
}
