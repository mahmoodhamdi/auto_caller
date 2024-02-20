// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:third_party_integration/hive/contacts_box.dart';
import 'package:third_party_integration/models/contact_model.dart';

class ContactPickerView extends StatefulWidget {
  const ContactPickerView({Key? key}) : super(key: key);

  @override
  _ContactPickerViewState createState() => _ContactPickerViewState();
}

class _ContactPickerViewState extends State<ContactPickerView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Picker'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _pickContacts,
          child: const Text('Pick Contacts'),
        ),
      ),
    );
  }

  Future<void> _pickContacts() async {
    var status = await Permission.contacts.request();
    if (status.isDenied) {
      await Permission.contacts.request();
    }
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
    if (status.isGranted) {
      print('Permission granted');

      // Get contacts
      List<Contact> selectedContacts = [];
      List<ContactModel> contactModels = [];
      Contact? contact = await ContactsService.openDeviceContactPicker();

      if (contact != null) {
        selectedContacts.add(contact);
      }
      if (selectedContacts.isNotEmpty) {
        // Save contacts
        for (var contact in selectedContacts) {
          contactModels.add(ContactModel(
            name: contact.displayName!,
            phoneNumber: contact.phones!.first.value!,
          ));
        }
        final box = await ContactsBox.openBox();
        box.addAll(contactModels);
        print('Selected contacts: ${contactModels[0].name}');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Contacts saved successfully'),
        ));
      } else {
        print('No contacts selected');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No contacts selected'),
        ));
      }
    }
  }
}
