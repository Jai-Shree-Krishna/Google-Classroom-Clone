// // create_class_page.dart
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class CreateClassPage extends StatelessWidget {
//
//   final TextEditingController _classNameController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Create Class')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: _classNameController,
//               decoration: InputDecoration(labelText: 'Enter Class Name'),
//             ),
//             Text('Select a Class Photo:'),
//             ElevatedButton(
//               onPressed: () async {
//                 await FirebaseFirestore.instance.collection('classes').doc().set({
//                     'className': _classNameController.text,
//                     'createdBy': FirebaseAuth.instance.currentUser?.displayName,
//                   });
//
//                 // await FirebaseFirestore.instance.collection('classes').;
//               },
//               child: Text('Create Class'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth.dart';

class CreateClassPage extends StatelessWidget {
  final TextEditingController _classNameController = TextEditingController();

  BuildContext get context => context;

  Future<void> createClass(String className) async {
    // Check if the class name already exists
    final classesCollection = FirebaseFirestore.instance.collection('classes');
    final classDoc = await classesCollection.doc(className).get();

    if (classDoc.exists) {
      // Class name already exists, show a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This class name is already taken.'),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      print("+++++++++++++++++++++++++++++++++++++++++++++++++++++");
      print(Auth().currentUser?.email);
      print('******************************************************');
      // Class name doesn't exist, create a new document
      await classesCollection.doc(className).set({
        'className': className,
        'createdBy': Auth().currentUser?.email,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Class')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _classNameController,
              decoration: InputDecoration(labelText: 'Enter Class Name'),
            ),
            Text('Select a Class Photo:'),
            ElevatedButton(
              onPressed: () async {
                String className = _classNameController.text;
                if (className.isNotEmpty) {
                  await createClass(className);
                } else {
                  // Handle empty class name
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Please enter a class name.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Create Class'),
            ),
          ],
        ),
      ),
    );
  }
}
