import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'add_student.dart';
import 'edit_student.dart';
import 'student_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController = TextEditingController();

  final CollectionReference studentsRef =
      FirebaseFirestore.instance.collection('students');

  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void goToAddScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddStudentScreen()),
    );
  }

  void goToEditScreen(Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditStudentScreen(student: student)),
    );
  }

  void confirmDelete(Student student) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Delete Student"),
          content: Text(
            "Are you sure you want to delete ${student.name}'s record? "
            "This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await studentsRef.doc(student.id!).delete();
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFF6FF),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF071E63),
        onPressed: goToAddScreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [

                /// TOP BAR

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [

                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.menu),
                    ),

                    Row(
                      children: [

                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.notifications_none,
                          ),
                        ),

                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.logout,
                          ),
                        ),

                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.info_outline,
                          ),
                        ),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 10),

                const Text(
                  "Welcome to",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),

                const Text(
                  "Student Management App",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF071E63),
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  "Simple. Fast. Efficient.",
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 25),

                /// PROFILE CARD

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8F0F4),
                    borderRadius:
                        BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.cyan,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [

                      CircleAvatar(
                        radius: 45,
                        backgroundColor:
                            Colors.grey.shade300,
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            const Text(
                              "Hello, Khushi",
                              style: TextStyle(
                                fontSize: 28,
                              ),
                            ),

                            const Text(
                              "CSE - NIT Patna",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),

                            const SizedBox(height: 12),

                            OutlinedButton(
                              onPressed: () {},
                              child: const Text(
                                "Edit Profile",
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                /// SEARCH BAR

                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText:
                        "Search Students here...",
                    prefixIcon:
                        const Icon(Icons.search),
                    filled: true,
                    fillColor:
                        const Color(0xFFCAE8F7),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// STUDENT LIST (live from Firestore)

                StreamBuilder<QuerySnapshot>(
                  stream: studentsRef.orderBy('name').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          "Something went wrong: ${snapshot.error}",
                        ),
                      );
                    }

                    if (snapshot.connectionState ==
                            ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.all(30),
                        child: CircularProgressIndicator(),
                      );
                    }

                    final allStudents = snapshot.data!.docs
                        .map((doc) => Student.fromMap(
                              doc.id,
                              doc.data() as Map<String, dynamic>,
                            ))
                        .toList();

                    final students = searchQuery.isEmpty
                        ? allStudents
                        : allStudents.where((s) {
                            return s.name
                                    .toLowerCase()
                                    .contains(searchQuery) ||
                                s.rollNumber
                                    .toLowerCase()
                                    .contains(searchQuery);
                          }).toList();

                    if (students.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(25),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF89D7DE),
                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                        child: const Text(
                          "No students found.\nTap + to add a new record.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF89D7DE),
                        borderRadius:
                            BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: students
                            .map((student) => buildStudentTile(student))
                            .toList(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 25),

                /// BUTTONS

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [

                    buildButton(
                      "Create",
                      Icons.add_circle_outline,
                      Colors.blue,
                      goToAddScreen,
                    ),

                    buildButton(
                      "Refresh",
                      Icons.refresh,
                      Colors.orange,
                      () {
                        searchController.clear();
                        setState(() => searchQuery = "");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("List refreshed"),
                          ),
                        );
                      },
                    ),

                    buildButton(
                      "Update",
                      Icons.update,
                      Colors.green,
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Tap the green edit icon on a student card to update",
                            ),
                          ),
                        );
                      },
                    ),

                    buildButton(
                      "Delete",
                      Icons.delete_outline,
                      Colors.red,
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Tap the red delete icon on a student card to remove",
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Students",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }

  Widget buildStudentTile(Student student) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [

          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person_outline,
              color: Colors.black,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Roll: ${student.rollNumber}  •  ${student.department}",
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  "Sem ${student.semester}  •  CGPA ${student.cgpa}",
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () => goToEditScreen(student),
            icon: const Icon(Icons.edit, color: Colors.green),
          ),

          IconButton(
            onPressed: () => confirmDelete(student),
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget buildButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: color,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
            )
          ],
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [

            Icon(
              icon,
              color: color,
            ),

            const SizedBox(height: 4),

            Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}