// The Student class is a blueprint for our data. 

// Firestore stores data as Maps (key-value pairs). 

// This class converts between Flutter's Student objects and Firestore's Maps. 

  

class Student { 

  final String? id;        // Firestore auto-generates this; null before first save 

  final String name; 

  final String rollNumber; 

  final String department; 

  final String semester; 

  final String cgpa; 

  final String phone; 

  final String email; 

  

  Student({ 

    this.id,               // Optional — not needed when creating a new student 

    required this.name, 

    required this.rollNumber, 

    required this.department, 

    required this.semester, 

    required this.cgpa, 

    required this.phone, 

    required this.email, 

  }); 

  

  // Dart Object → Firestore Map  (used when saving/updating) 

  // We don't include 'id' — Firestore manages document IDs separately 

  Map<String, dynamic> toMap() => { 

    'name': name, 

    'rollNumber': rollNumber, 

    'department': department, 

    'semester': semester, 

    'cgpa': cgpa, 

    'phone': phone, 

    'email': email, 

  }; 

  

  // Firestore Map → Dart Object  (used when reading) 

  // 'factory' constructor is used to create objects from Maps 

  // '?? ''' means: if the Firestore value is null, use empty string as default 

  factory Student.fromMap(Map<String, dynamic> map, String id) => Student( 

    id: id, 

    name: map['name'] ?? '', 

    rollNumber: map['rollNumber'] ?? '', 

    department: map['department'] ?? '', 

    semester: map['semester'] ?? '', 

    cgpa: map['cgpa'] ?? '', 

    phone: map['phone'] ?? '', 

    email: map['email'] ?? '', 

  ); 

} 