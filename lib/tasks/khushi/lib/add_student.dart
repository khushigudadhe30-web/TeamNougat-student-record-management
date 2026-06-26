import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final rollController = TextEditingController();
  final departmentController = TextEditingController();
  final semesterController = TextEditingController();
  final cgpaController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  bool isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    rollController.dispose();
    departmentController.dispose();
    semesterController.dispose();
    cgpaController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('students').add({
        'name': nameController.text.trim(),
        'rollNumber': rollController.text.trim(),
        'department': departmentController.text.trim(),
        'semester': semesterController.text.trim(),
        'cgpa': cgpaController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Student added successfully")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add student: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFF6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDFF6FF),
        elevation: 0,
        foregroundColor: const Color(0xFF071E63),
        title: const Text(
          "Add Student",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                buildTextField(
                  controller: nameController,
                  label: "Name",
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter the student's name";
                    }
                    return null;
                  },
                ),
                buildTextField(
                  controller: rollController,
                  label: "Roll Number",
                  icon: Icons.tag,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter the roll number";
                    }
                    return null;
                  },
                ),
                buildTextField(
                  controller: departmentController,
                  label: "Department",
                  icon: Icons.school_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter the department";
                    }
                    return null;
                  },
                ),
                buildTextField(
                  controller: semesterController,
                  label: "Semester",
                  icon: Icons.calendar_today_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter the semester";
                    }
                    final sem = int.tryParse(value.trim());
                    if (sem == null || sem < 1 || sem > 12) {
                      return "Enter a valid semester (1-12)";
                    }
                    return null;
                  },
                ),
                buildTextField(
                  controller: cgpaController,
                  label: "CGPA",
                  icon: Icons.star_border,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter the CGPA";
                    }
                    final cgpa = double.tryParse(value.trim());
                    if (cgpa == null || cgpa < 0 || cgpa > 10) {
                      return "Enter a valid CGPA (0-10)";
                    }
                    return null;
                  },
                ),
                buildTextField(
                  controller: phoneController,
                  label: "Phone Number",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter the phone number";
                    }
                    if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
                      return "Enter a valid 10-digit phone number";
                    }
                    return null;
                  },
                ),
                buildTextField(
                  controller: emailController,
                  label: "Email",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter the email";
                    }
                    final emailRegex =
                        RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
                    if (!emailRegex.hasMatch(value.trim())) {
                      return "Enter a valid email address";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF071E63),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: isSaving ? null : saveStudent,
                    child: isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Add Student",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: const Color(0xFFCAE8F7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}