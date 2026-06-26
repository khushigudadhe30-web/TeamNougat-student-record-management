import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'student_model.dart';

class EditStudentScreen extends StatefulWidget {
  final Student student;

  const EditStudentScreen({super.key, required this.student});

  @override
  State<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController rollController;
  late TextEditingController departmentController;
  late TextEditingController semesterController;
  late TextEditingController cgpaController;
  late TextEditingController phoneController;
  late TextEditingController emailController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.student.name);
    rollController = TextEditingController(text: widget.student.rollNumber);
    departmentController =
        TextEditingController(text: widget.student.department);
    semesterController =
        TextEditingController(text: widget.student.semester);
    cgpaController = TextEditingController(text: widget.student.cgpa);
    phoneController = TextEditingController(text: widget.student.phone);
    emailController = TextEditingController(text: widget.student.email);
  }

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

  Future<void> updateStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.student.id!)
          .update({
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
          const SnackBar(content: Text("Student updated successfully")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update student: $e")),
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
          "Edit Student",
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
                    onPressed: isSaving ? null : updateStudent,
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
                            "Update Student",
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