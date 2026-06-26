/// Simple data model for a student record stored in the
/// Firestore "students" collection.
class Student {
  final String? id;
  final String name;
  final String rollNumber;
  final String department;
  final String semester;
  final String cgpa;
  final String phone;
  final String email;

  Student({
    this.id,
    required this.name,
    required this.rollNumber,
    required this.department,
    required this.semester,
    required this.cgpa,
    required this.phone,
    required this.email,
  });

  factory Student.fromMap(String id, Map<String, dynamic> data) {
    return Student(
      id: id,
      name: data['name'] ?? '',
      rollNumber: data['rollNumber'] ?? '',
      department: data['department'] ?? '',
      semester: data['semester'] ?? '',
      cgpa: data['cgpa'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'rollNumber': rollNumber,
      'department': department,
      'semester': semester,
      'cgpa': cgpa,
      'phone': phone,
      'email': email,
    };
  }
}