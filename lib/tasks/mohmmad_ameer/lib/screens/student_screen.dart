import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/firestore_service.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final GlobalKey<FormState> _searchFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _editFormKey = GlobalKey<FormState>();

  bool _recordFetched = false;
  bool _isLoading = false;
  bool _isEditing = false;
  bool _isSaving = false;
  Student? _student;
  String? _errorMessage;

  // Edit controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollNumberController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _semesterController = TextEditingController();
  final TextEditingController _cgpaController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _rollNumberController.dispose();
    _nameController.dispose();
    _departmentController.dispose();
    _semesterController.dispose();
    _cgpaController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _populateEditControllers(Student student) {
    _nameController.text = student.name;
    _departmentController.text = student.department;
    _semesterController.text = student.semester.toString();
    _cgpaController.text = student.cgpa.toString();
    _phoneController.text = student.phoneNumber;
    _emailController.text = student.email;
  }

  Future<void> _fetchRecord() async {
    if (!_searchFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final student = await _firestoreService.getRecordByRollNumber(
        _rollNumberController.text.trim(),
      );

      setState(() {
        _isLoading = false;
        if (student != null) {
          _student = student;
          _recordFetched = true;
          _isEditing = false;
          _populateEditControllers(student);
        } else {
          _errorMessage =
              'No student record found for roll number "${_rollNumberController.text.trim()}"';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching record. Please try again.';
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_editFormKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final updatedStudent = Student(
        name: _nameController.text.trim(),
        rollNumber: _student!.rollNumber,
        department: _departmentController.text.trim(),
        semester: int.parse(_semesterController.text.trim()),
        cgpa: double.parse(_cgpaController.text.trim()),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
      );

      await _firestoreService.updateRecord(
        _student!.rollNumber,
        updatedStudent.toMap(),
      );

      setState(() {
        _student = updatedStudent;
        _isEditing = false;
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Record updated successfully!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to update record. Please try again.'),
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

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _populateEditControllers(_student!);
    });
  }

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
          title: Text(
            'Student Portal',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: _recordFetched ? _buildRecordView() : _buildSearchView(),
        ),
      ),
    );
  }

  Widget _buildSearchView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration icon
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_rounded,
                size: 64,
                color: Color(0xFFFD7E14),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Find Your Record',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your roll number to view and edit your details.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Search Card
            Card(
              color: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 4,
              shadowColor: Colors.black.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _searchFormKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _rollNumberController,
                        decoration: InputDecoration(
                          labelText: 'Roll Number',
                          hintText: 'e.g., 22BCE001',
                          prefixIcon: const Icon(
                            Icons.badge_outlined,
                            color: Color(0xFFFD7E14),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFFFD7E14),
                              width: 2,
                            ),
                          ),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your roll number';
                          }
                          return null;
                        },
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.shade400,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _fetchRecord,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFD7E14),
                            foregroundColor: Colors.white,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search_rounded),
                                    SizedBox(width: 8),
                                    Text(
                                      'Fetch Record',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Phase B: Record Display & Edit ─────────────────────────────────
  Widget _buildRecordView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Student info header
          Card(
            color: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 4,
            shadowColor: Colors.black.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFD7E14).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/student.png',
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _student!.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFD7E14).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _student!.rollNumber,
                      style: const TextStyle(
                        color: Color(0xFFFD7E14),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Editable fields
          Card(
            color: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 4,
            shadowColor: Colors.black.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _editFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isEditing ? 'Edit Details' : 'Your Details',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                        ),
                        if (!_isEditing)
                          TextButton.icon(
                            onPressed: () => setState(() => _isEditing = true),
                            icon: const Icon(Icons.edit_rounded, size: 18),
                            label: const Text('Edit'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFFD7E14),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildField(
                      'Name',
                      _nameController,
                      Icons.person_outline_rounded,
                      enabled: _isEditing,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Name is required';
                        return null;
                      },
                    ),
                    _buildField(
                      'Department',
                      _departmentController,
                      Icons.business_rounded,
                      enabled: _isEditing,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Department is required';
                        return null;
                      },
                    ),
                    _buildField(
                      'Semester',
                      _semesterController,
                      Icons.calendar_today_rounded,
                      enabled: _isEditing,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Semester is required';
                        final s = int.tryParse(v.trim());
                        if (s == null || s < 1 || s > 8) return 'Enter 1-8';
                        return null;
                      },
                    ),
                    _buildField(
                      'CGPA',
                      _cgpaController,
                      Icons.star_outline_rounded,
                      enabled: _isEditing,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'CGPA is required';
                        final c = double.tryParse(v.trim());
                        if (c == null || c < 0 || c > 10)
                          return 'Enter 0.0-10.0';
                        return null;
                      },
                    ),
                    _buildField(
                      'Phone',
                      _phoneController,
                      Icons.phone_rounded,
                      enabled: _isEditing,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Phone is required';
                        if (v.trim().length < 10)
                          return 'Enter a valid phone number';
                        return null;
                      },
                    ),
                    _buildField(
                      'Email',
                      _emailController,
                      Icons.email_rounded,
                      enabled: _isEditing,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Email is required';
                        if (!v.contains('@') || !v.contains('.'))
                          return 'Enter a valid email';
                        return null;
                      },
                    ),

                    if (_isEditing) ...[
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _cancelEdit,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: BorderSide(color: Colors.grey.shade400),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _saveChanges,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFD7E14),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Save Changes',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Back to search button
          TextButton.icon(
            onPressed: () {
              setState(() {
                _recordFetched = false;
                _student = null;
                _isEditing = false;
                _rollNumberController.clear();
                _errorMessage = null;
              });
            },
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Search another roll number'),
            style: TextButton.styleFrom(foregroundColor: Colors.black54),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: enabled ? const Color(0xFFFD7E14) : Colors.grey.shade400,
          ),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFFD7E14), width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
        ),
      ),
    );
  }
}
