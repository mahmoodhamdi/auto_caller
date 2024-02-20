import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:third_party_integration/hive/contacts_box.dart';
import 'package:third_party_integration/models/contact_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactListView extends StatelessWidget {
  const ContactListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts List'),
      ),
      body: FutureBuilder<List<ContactModel>>(
        future: _getSavedContacts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator()); // Show loading indicator while contacts are being fetched
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final contactModels = snapshot.data!;
            contactModels.sort(
                (a, b) => a.name.compareTo(b.name)); // Sort contacts by name
            return ListView.builder(
              itemCount: contactModels.length,
              itemBuilder: (context, index) {
                final contact = contactModels[index];
                return GestureDetector(
                  onTap: () => _makePhoneCall(contact.phoneNumber),
                  child: ListTile(
                    title: Text(contact.name),
                    subtitle: Text(contact.phoneNumber),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<ContactModel>> _getSavedContacts() async {
    final box = await ContactsBox.openBox();
    final contacts = box.values.cast<ContactModel>().toList();
    return contacts;
  }
}

Future<void> _makePhoneCall(String phoneNumber) async {
  var phoneCallStatus = await Permission.phone.request();
  var contactsStatus = await Permission.contacts.request();
  if (phoneCallStatus.isDenied) {
    await Permission.phone.request();
  }
  if (phoneCallStatus.isPermanentlyDenied) {
    openAppSettings();
  }

  if (contactsStatus.isDenied) {
    await Permission.contacts.request();
  }
  if (contactsStatus.isPermanentlyDenied) {
    openAppSettings();
  }
  if (phoneCallStatus.isGranted && contactsStatus.isGranted) {
    // Permission granted
    // You can now make a phone call
    print('Permission granted');
    // Use `Uri` to ensure that `phoneNumber` is properly URL-encoded.
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }
}

Future<void> makeAutomatedCall(String phoneNumber) async {
  const platform = MethodChannel('your_channel_name');
  try {
    await platform.invokeMethod('makeAutomatedCall', phoneNumber);
  } on PlatformException catch (e) {
    print("Failed to make automated call: '${e.message}'.");
  }
}
