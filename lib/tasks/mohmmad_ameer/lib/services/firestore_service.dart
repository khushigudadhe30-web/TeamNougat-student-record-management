import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Future<void> addRecord(Student student) async {
    try {
      await _db
          .collection('students')
          .doc(student.rollNumber)
          .set(student.toMap());
    } catch (e) {
      //Show Error Message
      //Temp
      print("Error Adding Record: $e");
      rethrow;
    }
  }

  Stream<List<Student>> getAllRecords() {
    return _db
        .collection('students')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Student.fromMap(doc.data())).toList(),
        );
  }

  Future<Student?> getRecordByRollNumber(String rollNumber) async {
    try {
      DocumentSnapshot doc = await _db
          .collection('students')
          .doc(rollNumber)
          .get();
      if (doc.exists) {
        return Student.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      //Show Error Card
      //Temp
      print("Error fetching record by roll number: $e");
      rethrow;
    }
  }

  Future<void> updateRecord(
    String docId,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      await _db.collection('students').doc(docId).update(updatedData);
    } catch (e) {
      //Show Error Card
      //Temp
      print("Error updating record: $e");
      rethrow;
    }
  }

  Future<void> deleteRecord(String docId) async {
    try {
      await _db.collection('students').doc(docId).delete();
    } catch (e) {
      //Show Error Card
      //Temp
      print("Error deleting record: $e");
      rethrow;
    }
  }
}
