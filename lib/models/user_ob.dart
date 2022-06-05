import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hellohi/constants/FirestoreConstants.dart';

class UserOb {
  String id;
  String photoUrl;
  String nickname;
  dynamic chattingWith;

  UserOb({required this.id, required this.photoUrl, required this.nickname, this.chattingWith});

  Map<String, String> toJson() {
    return {
      FirestoreConstants.nickname: nickname,
      FirestoreConstants.photoUrl: photoUrl,
      FirestoreConstants.chattingWith: chattingWith,
    };
  }

  factory UserOb.fromDocument(DocumentSnapshot doc) {
    String photoUrl = "";
    String nickname = "";
    List<dynamic>? chattingWith;
    try {
      photoUrl = doc.get(FirestoreConstants.photoUrl);
    } catch (_) {}
    try {
      nickname = doc.get(FirestoreConstants.nickname);
    } catch (_) {}
    try {
      chattingWith = doc.get(FirestoreConstants.chattingWith);
    } catch (_) {}
    return UserOb(id: doc.id, photoUrl: photoUrl, nickname: nickname, chattingWith: chattingWith);
  }
}
