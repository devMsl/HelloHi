import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hellohi/constants/FirestoreConstants.dart';

class ContactProvider {
  final FirebaseFirestore firebaseFirestore;

  ContactProvider({required this.firebaseFirestore});

  Stream<QuerySnapshot> getFirestoreStream(String pathCollection, int limit, String? nameSearch, {String? id}) {
    if (nameSearch?.isNotEmpty == true) {
      return firebaseFirestore.collection(pathCollection).limit(limit).where(FirestoreConstants.nickname, isEqualTo: nameSearch).snapshots();
    } else if (id?.isNotEmpty == true) {
      return firebaseFirestore.collection(pathCollection).limit(limit).where(FirestoreConstants.id, isEqualTo: id).snapshots();
    } else {
      return firebaseFirestore.collection(pathCollection).snapshots();
    }
  }
}
