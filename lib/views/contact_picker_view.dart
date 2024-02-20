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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _pickContacts,
              child: const Text('Pick Contact', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickAllContacts,
              child: const Text('Pick All Contacts',
                  style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: 16),
            const Text(
              "Coming Soon...",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: _pickMultipleContacts,
              child: const Text('Pick Multiple Contacts',
                  style: TextStyle(fontSize: 24)),
            ),
          ],
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
          String name = contact.displayName ?? 'No Name';
          String phoneNumber = '00000000000'; // Default phone number

          if (contact.phones != null && contact.phones!.isNotEmpty) {
            phoneNumber = contact.phones!.first.value ?? '00000000000';
          }
          contactModels.add(ContactModel(
            name: name,
            phoneNumber: phoneNumber,
          ));
        }
        final box = await ContactsBox.openBox();
        box.addAll(contactModels);
        print('Selected contacts: ${contactModels[0].name}');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Contacts saved successfully'),
        ));
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ContactListView(),
          ),
        );
      } else {
        print('No contacts selected');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No contacts selected'),
        ));
      }
    }
  }

  Future<void> _pickAllContacts() async {
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
      List<ContactModel> contactModels = [];
      List<Contact> selectedContacts =
          await ContactsService.getContacts(orderByGivenName: true);
      if (selectedContacts.isNotEmpty) {
        // Save contacts
        for (var contact in selectedContacts) {
          String name = contact.displayName ?? 'No Name';
          String phoneNumber = '00000000000'; // Default phone number

          if (contact.phones != null && contact.phones!.isNotEmpty) {
            phoneNumber = contact.phones!.first.value ?? '00000000000';
          }
          contactModels.add(ContactModel(
            name: name,
            phoneNumber: phoneNumber,
          ));
        }
        final box = await ContactsBox.openBox();
        box.addAll(contactModels);
        print('Selected contacts: ${contactModels[0].name}');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Contacts saved successfully'),
        ));
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ContactListView(),
          ),
        );
      } else {
        print('No contacts selected');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No contacts selected'),
        ));
      }
    }
  }

//
  Future<void> _pickMultipleContacts() async {
    // TODO: implement _pickMultipleContacts
  }
}

class ContactListView extends StatelessWidget {
  const ContactListView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ContactModel>>(
      future: _getSavedContacts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show loading indicator while contacts are being fetched
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final contactModels = snapshot.data!;
          contactModels.sort(
              (a, b) => a.name.compareTo(b.name)); // Sort contacts by name
          return Scaffold(
            appBar: AppBar(
              title: const Text('Selected Contacts'),
            ),
            body: ListView.builder(
              itemCount: contactModels.length,
              itemBuilder: (context, index) {
                final contact = contactModels[index];
                return ListTile(
                  title: Text(contact.name),
                  subtitle: Text(contact.phoneNumber),
                );
              },
            ),
          );
        }
      },
    );
  }

  Future<List<ContactModel>> _getSavedContacts() async {
    final box = await ContactsBox.openBox();
    final contacts = box.values.cast<ContactModel>().toList();
    return contacts;
  }
}
