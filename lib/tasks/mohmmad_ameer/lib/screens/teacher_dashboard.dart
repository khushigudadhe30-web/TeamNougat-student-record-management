import 'package:flutter/material.dart';
import 'dart:async';
import '../models/student.dart';
import '../services/firestore_service.dart';
import '../widgets/delete_confirmation_dialog.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  List<Student> _students = [];
  List<Student> _filteredStudents = [];
  StreamSubscription? _subscription;

  // Search
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // Inline edit tracking
  String? _editingRollNumber; // Which card is being edited (null = none)
  final TextEditingController _editNameController = TextEditingController();
  final TextEditingController _editDeptController = TextEditingController();
  final TextEditingController _editSemController = TextEditingController();
  final TextEditingController _editCgpaController = TextEditingController();
  final TextEditingController _editPhoneController = TextEditingController();
  final TextEditingController _editEmailController = TextEditingController();
  final GlobalKey<FormState> _editFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _listenToStudents();
    _searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _searchController.dispose();
    _editNameController.dispose();
    _editDeptController.dispose();
    _editSemController.dispose();
    _editCgpaController.dispose();
    _editPhoneController.dispose();
    _editEmailController.dispose();
    super.dispose();
  }

  void _listenToStudents() {
    _subscription = _firestoreService.getAllRecords().listen((students) {
      setState(() {
        _students = students;
        _filterStudents();
      });
    });
  }

  void _filterStudents() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredStudents = List.from(_students);
      } else {
        _filteredStudents = _students.where((s) {
          return s.name.toLowerCase().contains(query) ||
              s.rollNumber.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  // ─── Inline Edit ──────────────────────────────────────────────────────

  void _startEditing(Student student) {
    setState(() {
      _editingRollNumber = student.rollNumber;
      _editNameController.text = student.name;
      _editDeptController.text = student.department;
      _editSemController.text = student.semester.toString();
      _editCgpaController.text = student.cgpa.toString();
      _editPhoneController.text = student.phoneNumber;
      _editEmailController.text = student.email;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingRollNumber = null;
    });
  }

  Future<void> _saveEditing(Student original) async {
    if (!_editFormKey.currentState!.validate()) return;

    try {
      final updated = Student(
        name: _editNameController.text.trim(),
        rollNumber: original.rollNumber,
        department: _editDeptController.text.trim(),
        semester: int.parse(_editSemController.text.trim()),
        cgpa: double.parse(_editCgpaController.text.trim()),
        phoneNumber: _editPhoneController.text.trim(),
        email: _editEmailController.text.trim(),
      );

      await _firestoreService.updateRecord(
        original.rollNumber,
        updated.toMap(),
      );

      setState(() => _editingRollNumber = null);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${updated.name}\'s record updated!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to update. Please try again.'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  // ─── Delete ───────────────────────────────────────────────────────────

  Future<void> _deleteStudent(Student student) async {
    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      studentName: student.name,
      rollNumber: student.rollNumber,
    );

    if (confirmed == true) {
      try {
        await _firestoreService.deleteRecord(student.rollNumber);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${student.name}\'s record deleted.'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to delete. Please try again.'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    }
  }

  // ─── Add Student ──────────────────────────────────────────────────────

  void _showAddStudentDialog() {
    final addFormKey = GlobalKey<FormState>();
    final nameC = TextEditingController();
    final rollC = TextEditingController();
    final deptC = TextEditingController();
    final semC = TextEditingController();
    final cgpaC = TextEditingController();
    final phoneC = TextEditingController();
    final emailC = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: addFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Add New Student',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildAddField(
                    'Name',
                    nameC,
                    Icons.person_outline_rounded,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      return null;
                    },
                  ),
                  _buildAddField(
                    'Roll Number',
                    rollC,
                    Icons.badge_outlined,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      return null;
                    },
                  ),
                  _buildAddField(
                    'Department',
                    deptC,
                    Icons.business_rounded,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      return null;
                    },
                  ),
                  _buildAddField(
                    'Semester',
                    semC,
                    Icons.calendar_today_rounded,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final s = int.tryParse(v.trim());
                      if (s == null || s < 1 || s > 8) return 'Enter 1-8';
                      return null;
                    },
                  ),
                  _buildAddField(
                    'CGPA',
                    cgpaC,
                    Icons.star_outline_rounded,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final c = double.tryParse(v.trim());
                      if (c == null || c < 0 || c > 10) return '0.0 - 10.0';
                      return null;
                    },
                  ),
                  _buildAddField(
                    'Phone',
                    phoneC,
                    Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (v.trim().length < 10) return 'Invalid phone';
                      return null;
                    },
                  ),
                  _buildAddField(
                    'Email',
                    emailC,
                    Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (!v.contains('@') || !v.contains('.'))
                        return 'Invalid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (addFormKey.currentState!.validate()) {
                          final student = Student(
                            name: nameC.text.trim(),
                            rollNumber: rollC.text.trim(),
                            department: deptC.text.trim(),
                            semester: int.parse(semC.text.trim()),
                            cgpa: double.parse(cgpaC.text.trim()),
                            phoneNumber: phoneC.text.trim(),
                            email: emailC.text.trim(),
                          );
                          try {
                            await _firestoreService.addRecord(student);
                            if (ctx.mounted) Navigator.of(ctx).pop();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${student.name} added!'),
                                  backgroundColor: Colors.green.shade600,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Failed to add student.'),
                                  backgroundColor: Colors.red.shade600,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFD7E14),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Add Student',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFFFD7E14)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFFD7E14), width: 2),
          ),
        ),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 247, 243, 244),
            Color.fromARGB(255, 222, 222, 224),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search by name or roll no...',
                    border: InputBorder.none,
                  ),
                )
              : Text(
                  'Teacher Dashboard',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                _isSearching ? Icons.close_rounded : Icons.search_rounded,
                color: Colors.black87,
              ),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                  }
                });
              },
            ),
          ],
        ),
        body: _filteredStudents.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchController.text.isNotEmpty
                          ? 'No students match your search.'
                          : 'No students yet.\nTap + to add one!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: _filteredStudents.length,
                itemBuilder: (context, index) {
                  final student = _filteredStudents[index];
                  final isEditing = _editingRollNumber == student.rollNumber;
                  return _buildStudentCard(student, isEditing);
                },
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddStudentDialog,
          backgroundColor: const Color(0xFFFD7E14),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'Add Student',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // ─── Student Card ─────────────────────────────────────────────────────

  Widget _buildStudentCard(Student student, bool isEditing) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: isEditing ? _buildEditMode(student) : _buildDisplayMode(student),
      ),
    );
  }

  // ─── Display Mode ─────────────────────────────────────────────────────

  Widget _buildDisplayMode(Student student) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row with name + roll number
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFD7E14).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Color(0xFFFD7E14),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFD7E14).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      student.rollNumber,
                      style: const TextStyle(
                        color: Color(0xFFFD7E14),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),

        // Details grid
        _buildDetailRow(
          Icons.business_rounded,
          'Department',
          student.department,
        ),
        _buildDetailRow(
          Icons.calendar_today_rounded,
          'Semester',
          student.semester.toString(),
        ),
        _buildDetailRow(
          Icons.star_outline_rounded,
          'CGPA',
          student.cgpa.toString(),
        ),
        _buildDetailRow(Icons.phone_rounded, 'Phone', student.phoneNumber),
        _buildDetailRow(Icons.email_rounded, 'Email', student.email),

        const SizedBox(height: 16),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _startEditing(student),
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Edit'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFD7E14),
                  side: const BorderSide(color: Color(0xFFFD7E14)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _deleteStudent(student),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Delete'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade500,
                  side: BorderSide(color: Colors.red.shade500),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Edit Mode ────────────────────────────────────────────────────────

  Widget _buildEditMode(Student student) {
    return Form(
      key: _editFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit_rounded,
                  color: Colors.blue.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Editing Record',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      student.rollNumber,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Editable fields
          _buildEditField(
            'Name',
            _editNameController,
            Icons.person_outline_rounded,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              return null;
            },
          ),
          _buildEditField(
            'Department',
            _editDeptController,
            Icons.business_rounded,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              return null;
            },
          ),
          _buildEditField(
            'Semester',
            _editSemController,
            Icons.calendar_today_rounded,
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              final s = int.tryParse(v.trim());
              if (s == null || s < 1 || s > 8) return '1-8';
              return null;
            },
          ),
          _buildEditField(
            'CGPA',
            _editCgpaController,
            Icons.star_outline_rounded,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              final c = double.tryParse(v.trim());
              if (c == null || c < 0 || c > 10) return '0-10';
              return null;
            },
          ),
          _buildEditField(
            'Phone',
            _editPhoneController,
            Icons.phone_rounded,
            keyboardType: TextInputType.phone,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              if (v.trim().length < 10) return 'Invalid';
              return null;
            },
          ),
          _buildEditField(
            'Email',
            _editEmailController,
            Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              if (!v.contains('@') || !v.contains('.')) return 'Invalid';
              return null;
            },
          ),

          const SizedBox(height: 8),

          // Save / Cancel buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _cancelEditing,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black54,
                    side: BorderSide(color: Colors.grey.shade400),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _saveEditing(student),
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFD7E14),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          prefixIcon: Icon(icon, color: const Color(0xFFFD7E14), size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFFD7E14), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
