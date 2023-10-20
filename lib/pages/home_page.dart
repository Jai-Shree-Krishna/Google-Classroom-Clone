import 'package:classroomcloneproject/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:classroomcloneproject/pages/create_class_page.dart';
import 'package:classroomcloneproject/pages/join_class_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = FirebaseAuth.instance.currentUser;

  void initState() {
    super.initState();

    if(Auth().currentUser == Null) {
      Navigator.pop(context);
    }
  }

  Future<void> signOut() async {
    // Your sign-out code
    await Auth().signOut();
    print('-------------sign out ------------');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          PopupMenuButton<int>(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateClassPage()),
                    );
                  },
                  child: Text('Create Class'),
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => JoinClassPage()),
                    );
                  },
                  child: Text('Join Class'),
                ),
              ),
              PopupMenuItem(
                value: 3,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle "Sign Out" option
                    signOut();
                  },
                  child: Text('Sign Out'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: ClassListPage(),
    );
  }
}

// class ClassListPage extends StatelessWidget {
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance.collection('classes').snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return Center(child: CircularProgressIndicator());
//           }
//
//           List<QueryDocumentSnapshot> classDocuments = snapshot.data!.docs;
//
//           // print('=============================================******************==================');
//           // print(classDocuments);
//           // print('=========================================********************======================');
//           if (classDocuments.isEmpty) {
//             return Center(child: Text('No classes available.'));
//           }
//
//           // return ListView.builder(
//           //   itemCount: classDocuments.length,
//           //   itemBuilder: (context, index) {
//           //     Map<String, dynamic> data = classDocuments[index].data() as Map<String, dynamic>;
//           //     String className = data['className'];
//           //     String createdBy = data['createdBy'];
//           //     return Container(
//           //       child: Column(
//           //         children: [
//           //
//           //         Text(className),
//           //         Text(createdBy),
//           //         // SizedBox.fromSize(20/)
//           //         ],
//           //       ),
//           //       // You can add other class details here
//           //     );
//           //   },
//           // );
//
//           return ListView.separated(
//             itemCount: classDocuments.length,
//             separatorBuilder: (context, index) => Divider(),
//             itemBuilder: (context, index) {
//               Map<String, dynamic> data = classDocuments[index].data() as Map<String, dynamic>;
//               String className = data['className'];
//               String createdBy = data['createdBy'];
//               return ListTile(
//                 title: Text(
//                   className,
//                   style: TextStyle(
//                     fontSize: 18.0,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 subtitle: Text('Teacher: ${createdBy}'),
//                 trailing: PopupMenuButton(
//                   icon: Icon(Icons.more_vert),
//                   itemBuilder: (context) {
//                     return <PopupMenuEntry>[
//                       PopupMenuItem(
//                         value: 'unenroll',
//                         child: Text('Unenroll'),
//                       ),
//                     ];
//                   },
//                   onSelected: (value) {
//                     if (value == 'unenroll') {
//                       // Handle the "Unenroll" action here
//                       // You can add your logic to unenroll the student from the class
//                       // For example, show a confirmation dialog and process the unenrollment.
//                       // Navigator.push(
//                       //   context,
//                       //   MaterialPageRoute(
//                       //     builder: (context) => UnenrollPage(currentClass),
//                       //   ),
//                       // );
//                     }
//                   },
//                 ),
//                 onTap: () {
//                   // Navigate to a new page when the ListTile is tapped
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ClassDetailsPage(new Class(className, createdBy)),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

class ClassListPage extends StatelessWidget {
  Future<List<String>> getEnrolledClasses(String userEmail) async{
    List<String> enrolledClasses = [];

    String? emailId = Auth().currentUser!.email;
    print(emailId);

    Map<String, dynamic>? data;
    await FirebaseFirestore.instance.collection('User').doc(emailId).get().then((doc)=> {
      if(doc.exists) {
        // print(doc.data()),
        data = doc.data(),


        if(data?['enrolledCLasses'] != null) {
          enrolledClasses = data?['enrolledClasses'],
          // print(data?['enrolledCLasses']),
        }
      }
    });

    print(enrolledClasses.length);
    return enrolledClasses;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(child: Text('Please sign in to view your enrolled classes.'));
    }

    String userEmail = user.email!;
    Future<List<String>> enrolledClassesFuture = getEnrolledClasses(userEmail);

    return FutureBuilder<List<String>>(
      future: enrolledClassesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<String> enrolledClasses = snapshot.data!;
          print(enrolledClasses);
          return ListView.separated(
            itemCount: enrolledClasses.length,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              String className = enrolledClasses[index];
              String createdBy = ''; // Replace with the correct Firestore query.

              return ListTile(
                title: Text(
                  className,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text('Teacher: $createdBy'),
                trailing: PopupMenuButton(
                  icon: Icon(Icons.more_vert),
                  itemBuilder: (context) {
                    return <PopupMenuEntry>[
                      PopupMenuItem(
                        value: 'unenroll',
                        child: Text('Unenroll'),
                      ),
                    ];
                  },
                  onSelected: (value) {
                    if (value == 'unenroll') {
                      // Handle the "Unenroll" action here
                      // You can add your logic to unenroll the student from the class
                    }
                  },
                ),
                onTap: () {
                  // Navigate to a new page when the ListTile is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClassDetailsPage(className as Class),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}

// class ClassListPage extends StatelessWidget {
//
//   Future<List<String>> getEnrolledClasses(String userEmail) async {
//     List<String> enrolledClasses = [];
//
//     CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
//
//     QuerySnapshot querySnapshot = await usersCollection.where('email', isEqualTo: userEmail).get();
//
//     if (querySnapshot.docs.isNotEmpty) {
//       var userDocument = querySnapshot.docs[0].data();
//       if (userDocument['enrolledClasses'] != null) {
//         enrolledClasses = List<String>.from(userDocument['enrolledClasses']);
//       }
//     }
//
//     return enrolledClasses;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//
//     if (user == null) {
//       return Center(child: Text('Please sign in to view your enrolled classes.'));
//     }
//
//     String userEmail = user.email!;
//     Future<List<String>> enrolledClassesFuture = getEnrolledClasses(userEmail);
//
//     return FutureBuilder<List<String>>(
//       future: enrolledClassesFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         } else {
//           List<String> enrolledClasses = snapshot.data!;
//
//           return  ListView.separated(
// itemCount: enrolledClasses.length,
// separatorBuilder: (context, index) => Divider(),
// itemBuilder: (context, index) {
// Map<String, dynamic> data = enrolledClasses[index].data() as Map<String, dynamic>;
// String className = data['className'];
// String createdBy = data['createdBy'];
// return ListTile(
// title: Text(
// className,
// style: TextStyle(
// fontSize: 18.0,
// fontWeight: FontWeight.bold,
// ),
// ),
// subtitle: Text('Teacher: ${createdBy}'),
// trailing: PopupMenuButton(
// icon: Icon(Icons.more_vert),
// itemBuilder: (context) {
// return <PopupMenuEntry>[
// PopupMenuItem(
// value: 'unenroll',
// child: Text('Unenroll'),
// ),
// ];
// },
// onSelected: (value) {
// if (value == 'unenroll') {
// // Handle the "Unenroll" action here
// // You can add your logic to unenroll the student from the class
// // For example, show a confirmation dialog and process the unenrollment.
// // Navigator.push(
// //   context,
// //   MaterialPageRoute(
// //     builder: (context) => UnenrollPage(currentClass),
// //   ),
// // );
// }
// },
// ),
// onTap: () {
// // Navigate to a new page when the ListTile is tapped
// Navigator.push(
// context,
// MaterialPageRoute(
// builder: (context) => ClassDetailsPage(new Class(className, createdBy)),
// ),
// );
// },
// );
// },
// );
//         }
//       },
//     );
//   }
// }




class Class {
  final String name;
  final String teacher;

  Class(this.name, this.teacher);
}

class ClassDetailsPage extends StatefulWidget {
  final Class currentClass;

  ClassDetailsPage(this.currentClass);

  @override
  _ClassDetailsPageState createState() => _ClassDetailsPageState();
}

class _ClassDetailsPageState extends State<ClassDetailsPage> {
  int _currentIndex = 0;
  PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onBottomNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.currentClass.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          StreamSection(),
          ClassSection(title: 'Classwork'),
          PeopleSection(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavBarTap,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Stream',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Classwork',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'People',
          ),
        ],
      ),
    );
  }
}


class ClassSection extends StatelessWidget {
  final String title;

  ClassSection({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class StreamSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildAnnouncementCard(
          'Important Announcement',
          'There will be a quiz on Monday. Be prepared!',
        ),
        _buildAssignmentCard(
          'Assignment 1',
          'Complete the exercises on pages 10-15.',
        ),
        _buildMaterialCard(
          'Study Materials',
          'Download the PDF notes for this week.',
        ),
        _buildPDFCard(
          'Sample PDF',
          'Sample PDF Document',
          'https://example.com/sample.pdf', // Replace with the actual PDF URL
        ),
      ],
    );
  }

  Widget _buildAnnouncementCard(String title, String content) {
    return Card(
      elevation: 3.0,
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(content),
      ),
    );
  }

  Widget _buildAssignmentCard(String title, String content) {
    return Card(
      elevation: 3.0,
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(content),
      ),
    );
  }

  Widget _buildMaterialCard(String title, String content) {
    return Card(
      elevation: 3.0,
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(content),
      ),
    );
  }

  Widget _buildPDFCard(String title, String description, String pdfUrl) {
    return Card(
      elevation: 3.0,
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        onTap: () {
          // Implement opening PDF here (e.g., using a PDF viewer package)
          // You can use the pdfUrl to load and display the PDF.
          // Replace this with your PDF viewing logic.
        },
      ),
    );
  }
}

class PeopleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildTeacherRow('Teacher 1', 'teacher1@example.com'),
        _buildTeacherRow('Teacher 2', 'teacher2@example.com'),
        _buildTeacherRow('Teacher 3', 'teacher3@example.com'),
        _buildClassmatesRow('Classmate 1', 'classmate1@example.com'),
        _buildClassmatesRow('Classmate 2', 'classmate2@example.com'),
        _buildClassmatesRow('Classmate 3', 'classmate3@example.com'),
        _buildClassmatesRow('Classmate 4', 'classmate4@example.com'),
        _buildClassmatesRow('Classmate 5', 'classmate5@example.com'),
      ],
    );
  }

  Widget _buildTeacherRow(String teacherName, String email) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue,
        child: Icon(Icons.person),
      ),
      title: Text(teacherName),
      subtitle: Row(
        children: [
          Icon(Icons.email),
          SizedBox(width: 4.0),
          Text(email),
        ],
      ),
    );
  }

  Widget _buildClassmatesRow(String studentName, String email) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.green,
        child: Icon(Icons.person),
      ),
      title: Text(studentName),
      subtitle: Row(
        children: [
          Icon(Icons.email),
          SizedBox(width: 4.0),
          Text(email),
        ],
      ),
    );
  }
}