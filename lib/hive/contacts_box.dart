
import 'package:hive/hive.dart';

class ContactsBox {
  static const String _boxName = 'contacts';

  static Future<Box> openBox() async {
    return await Hive.openBox(_boxName);
  }
}
