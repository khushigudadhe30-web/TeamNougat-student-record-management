import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'add_student.dart';
import 'edit_student.dart';
import 'student_model.dart';

// Shared theme colors used across this file.
const Color kNavy = Color(0xFF071E63);
const Color kBg = Color(0xFFDFF6FF);
const Color kFieldFill = Color(0xFFCAE8F7);
const Color kCardFill = Color(0xFF89D7DE);
const Color kProfileFill = Color(0xFFC8F0F4);

AppBar buildSimpleAppBar(String title) => AppBar(
      backgroundColor: kBg,
      elevation: 0,
      foregroundColor: kNavy,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    );

BoxDecoration roundedFill(Color color, double radius) => BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
    );

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchController = TextEditingController();
  final studentsRef = FirebaseFirestore.instance.collection('students');
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    searchController.addListener(() => setState(
        () => searchQuery = searchController.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void goToAddScreen() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const AddStudentScreen()));

  void goToEditScreen(Student s) => Navigator.push(context,
      MaterialPageRoute(builder: (_) => EditStudentScreen(student: s)));

  void confirmDelete(Student s) => showDialog(
        context: context,
        builder: (dCtx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Delete Student"),
          content: Text(
              "Are you sure you want to delete ${s.name}'s record? This action cannot be undone."),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dCtx),
                child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await studentsRef.doc(s.id!).delete();
                if (dCtx.mounted) Navigator.pop(dCtx);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      drawer: buildSideMenu(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kNavy,
        onPressed: goToAddScreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Builder(
        builder: (context) => SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.menu),
                        ),
                      ),
                      Row(children: [
                        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.logout)),
                      IconButton(
                        onPressed: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const AboutScreen())),
                        icon: const Icon(Icons.info_outline),
                      ),
                    ]),
                  ],
                ),
                const SizedBox(height: 10),
                const Text("Welcome to", style: TextStyle(fontSize: 20)),
                const Text(
                  "Student Management App",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: kNavy),
                ),
                const SizedBox(height: 5),
                const Text("Simple. Fast. Efficient.",
                    style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
                const SizedBox(height: 25),

                // PROFILE CARD
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kProfileFill,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.cyan, width: 2),
                  ),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey.shade300,
                      child: const Icon(Icons.person, size: 60, color: Colors.black),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text("Hello, Professional", style: TextStyle(fontSize: 28)),
                        const Text("Teacher - NIT Patna", style: TextStyle(fontSize: 20)),
                        const SizedBox(height: 12),
                        OutlinedButton(onPressed: () {}, child: const Text("Edit Profile")),
                      ]),
                    ),
                  ]),
                ),
                const SizedBox(height: 25),

                // SEARCH BAR
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Search Students here...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: kFieldFill,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                const SizedBox(height: 20),

                // STUDENT LIST (live from Firestore)
                StreamBuilder<QuerySnapshot>(
                  stream: studentsRef.orderBy('name').snapshots(),
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text("Something went wrong: ${snap.error}"),
                      );
                    }
                    if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
                      return const Padding(
                          padding: EdgeInsets.all(30), child: CircularProgressIndicator());
                    }
                    final all = snap.data!.docs
                        .map((d) => Student.fromMap(d.id, d.data() as Map<String, dynamic>))
                        .toList();
                    final students = searchQuery.isEmpty
                        ? all
                        : all
                            .where((s) =>
                                s.name.toLowerCase().contains(searchQuery) ||
                                s.rollNumber.toLowerCase().contains(searchQuery))
                            .toList();

                    if (students.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(25),
                        width: double.infinity,
                        decoration: roundedFill(kCardFill, 18),
                        child: const Text(
                          "No students found.\nTap + to add a new record.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: roundedFill(kCardFill, 18),
                      child: Column(children: students.map(buildStudentTile).toList()),
                    );
                  },
                ),
                const SizedBox(height: 25),

                // BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildButton("Create", Icons.add_circle_outline, Colors.blue, goToAddScreen),
                    buildButton("Refresh", Icons.refresh, Colors.orange, () {
                      searchController.clear();
                      setState(() => searchQuery = "");
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text("List refreshed")));
                    }),
                    buildButton("Update", Icons.update, Colors.green, () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Tap the green edit icon on a student card to update")));
                    }),
                    buildButton("Delete", Icons.delete_outline, Colors.red, () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Tap the red delete icon on a student card to remove")));
                    }),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      )),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const StudentListScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Students"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }

  Widget buildStudentTile(Student student) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        const CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.person_outline, color: Colors.black),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(student.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text("Roll: ${student.rollNumber}  •  ${student.department}",
                style: const TextStyle(fontSize: 13)),
            Text("Sem ${student.semester}  •  CGPA ${student.cgpa}",
                style: const TextStyle(fontSize: 13)),
          ]),
        ),
        IconButton(onPressed: () => goToEditScreen(student), icon: const Icon(Icons.edit, color: Colors.green)),
        IconButton(onPressed: () => confirmDelete(student), icon: const Icon(Icons.delete, color: Colors.red)),
      ]),
    );
  }

  Widget buildButton(String text, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color, width: 2),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 12)],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

  Widget buildSideMenu() {
    return Drawer(
      backgroundColor: kBg,
      child: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            decoration: const BoxDecoration(color: kNavy),
            child: Row(children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: Icon(Icons.school, size: 30, color: kNavy),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text("Student Management App",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ]),
          ),
          const SizedBox(height: 10),
          menuTile(Icons.dashboard_outlined, "Dashboard", const DashboardScreen()),
          menuTile(Icons.badge_outlined, "Teacher Professional", const TeacherProfessionalScreen()),
          menuTile(Icons.info_outline, "Total Students", const DetailsScreen()),
        ]),
      ),
    );
  }

  Widget menuTile(IconData icon, String label, Widget screen) {
    return ListTile(
      leading: Icon(icon, color: kNavy),
      title: Text(label, style: const TextStyle(color: kNavy, fontWeight: FontWeight.w600, fontSize: 16)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
    );
  }
}

/// Dashboard screen (reached from the side menu). Static placeholder UI.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _stats = [
    (Icons.people_alt_outlined, "Students", Colors.blue),
    (Icons.person_outline, "Teachers", Colors.green),
    (Icons.class_outlined, "Departments", Colors.orange),
    (Icons.event_note_outlined, "Attendance", Colors.purple),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: buildSimpleAppBar("Dashboard"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Overview",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kNavy)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.2,
              children: _stats.map((s) => statCard(s.$1, s.$2, s.$3)).toList(),
            ),
            const SizedBox(height: 25),
            const Text("Recent Activity",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kNavy)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: roundedFill(kCardFill, 18),
              child: const Text("No recent activity to show yet.", style: TextStyle(fontSize: 15)),
            ),
          ]),
        ),
      ),
    );
  }

  Widget statCard(IconData icon, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 15)),
      ]),
    );
  }
}

/// Teacher Professional screen. Static UI.
class TeacherProfessionalScreen extends StatelessWidget {
  const TeacherProfessionalScreen({super.key});

  static const _rows = [
    (Icons.work_outline, "Designation"),
    (Icons.school_outlined, "Qualification"),
    (Icons.timeline_outlined, "Experience"),
    (Icons.subject_outlined, "Subjects Taught"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: buildSimpleAppBar("Teacher Professional"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Teacher Profile",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kNavy)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kProfileFill,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.cyan, width: 2),
              ),
              child: Row(children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.person, size: 50, color: Colors.black),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("Faculty Name", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                    Text("Department of CSE", style: TextStyle(fontSize: 16)),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 25),
            const Text("Professional Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kNavy)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: roundedFill(kCardFill, 18),
              child: Column(children: _rows.map((r) => detailRow(r.$1, r.$2, "—")).toList()),
            ),
          ]),
        ),
      ),
    );
  }

  Widget detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(icon, color: kNavy),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

/// Details screen (from the side menu). Shows total student count, live from Firestore.
class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentsRef = FirebaseFirestore.instance.collection('students');
    return Scaffold(
      backgroundColor: kBg,
      appBar: buildSimpleAppBar("Total Students"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Total Students",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kNavy)),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: studentsRef.snapshots(),
              builder: (context, snap) {
                final count = snap.hasData ? snap.data!.docs.length.toString() : "—";
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: kProfileFill,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.cyan, width: 2),
                  ),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: roundedFill(kNavy, 16),
                      child: const Icon(Icons.people_alt, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text("Total Number of Students", style: TextStyle(fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(count,
                          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: kNavy)),
                    ]),
                  ]),
                );
              },
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: roundedFill(kCardFill, 18),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("About", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(height: 6),
                Text(
                  "This section shows a live summary of student records stored in the app. "
                  "More details can be added here over time.",
                  style: TextStyle(fontSize: 14),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Student List screen (shown when "Students" bottom-nav item is tapped).
/// Full list of all students, same card style/theme as the Home screen.
class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final searchController = TextEditingController();
  final studentsRef = FirebaseFirestore.instance.collection('students');
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    searchController.addListener(() => setState(
        () => searchQuery = searchController.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void goToAddScreen() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const AddStudentScreen()));

  void goToEditScreen(Student s) => Navigator.push(context,
      MaterialPageRoute(builder: (_) => EditStudentScreen(student: s)));

  void confirmDelete(Student s) => showDialog(
        context: context,
        builder: (dCtx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Delete Student"),
          content: Text(
              "Are you sure you want to delete ${s.name}'s record? This action cannot be undone."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await studentsRef.doc(s.id!).delete();
                if (dCtx.mounted) Navigator.pop(dCtx);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: buildSimpleAppBar("All Students"),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kNavy,
        onPressed: goToAddScreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search Students here...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: kFieldFill,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: studentsRef.orderBy('name').snapshots(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text("Something went wrong: ${snap.error}"));
                }
                if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
                  return const Padding(
                      padding: EdgeInsets.all(30), child: CircularProgressIndicator());
                }
                final all = snap.data!.docs
                    .map((d) => Student.fromMap(d.id, d.data() as Map<String, dynamic>))
                    .toList();
                final students = searchQuery.isEmpty
                    ? all
                    : all
                        .where((s) =>
                            s.name.toLowerCase().contains(searchQuery) ||
                            s.rollNumber.toLowerCase().contains(searchQuery))
                        .toList();

                if (students.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(25),
                    width: double.infinity,
                    decoration: roundedFill(kCardFill, 18),
                    child: const Text(
                      "No students found.\nTap + to add a new record.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: roundedFill(kCardFill, 18),
                  child: Column(children: students.map(buildStudentTile).toList()),
                );
              },
            ),
            const SizedBox(height: 30),
          ]),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) Navigator.pop(context);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Students"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }

  Widget buildStudentTile(Student student) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        const CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.person_outline, color: Colors.black),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(student.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text("Roll: ${student.rollNumber}  •  ${student.department}",
                style: const TextStyle(fontSize: 13)),
            Text("Sem ${student.semester}  •  CGPA ${student.cgpa}",
                style: const TextStyle(fontSize: 13)),
          ]),
        ),
        IconButton(onPressed: () => goToEditScreen(student), icon: const Icon(Icons.edit, color: Colors.green)),
        IconButton(onPressed: () => confirmDelete(student), icon: const Icon(Icons.delete, color: Colors.red)),
      ]),
    );
  }
}

/// About screen (opened from the info icon in the top-right of Home).
/// Explains what the app does, in the same theme as the rest of the app.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _features = [
    (Icons.add_circle_outline, "Create", "Add a new student record in just one tap."),
    (Icons.update, "Update", "Edit any student's details anytime."),
    (Icons.refresh, "Refresh", "Reload the list instantly to see the latest records."),
    (Icons.delete_outline, "Delete", "Remove a student's record in a single click."),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: buildSimpleAppBar("About"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: kProfileFill,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.cyan, width: 2),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: roundedFill(kNavy, 16),
                  child: const Icon(Icons.school, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    "Student Management App",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kNavy),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: roundedFill(kCardFill, 18),
              child: const Text(
                "This is a Student Management App in which you can keep the records of "
                "students along with their details efficiently. You can create, update, refresh, "
                "and delete a student's record anytime you want — all with just one click."
                "It includes the menu bar in the top-left corner having dashboard to check recent activity and overview"
                " then teacher professional with all deatails of the teacher and"
                " the total students which shows the total number of students in the app."
                "The student section in the bottom navigation bar displays the list of all registered students.",
                style: TextStyle(fontSize: 15, height: 1.4),
              ),
            ),
            const SizedBox(height: 22),
            const Text("What you can do",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kNavy)),
            const SizedBox(height: 12),
            ..._features.map((f) => featureRow(f.$1, f.$2, f.$3)),
          ]),
        ),
      ),
    );
  }

  Widget featureRow(IconData icon, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        Icon(icon, color: kNavy, size: 26),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text(desc, style: const TextStyle(fontSize: 13)),
          ]),
        ),
      ]),
    );
  }
}
