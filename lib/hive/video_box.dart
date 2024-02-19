import 'package:hive/hive.dart';

class VideoBox {
  static const String _boxName = 'videos';

  static Future<Box> openBox() async {
    return await Hive.openBox(_boxName);
  }
}
