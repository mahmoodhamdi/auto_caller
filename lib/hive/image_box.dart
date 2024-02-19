import 'package:hive/hive.dart';

class ImageBox {
  static const String _boxName = 'images';

  static Future<Box> openBox() async {
    return await Hive.openBox(_boxName);
  }
}
