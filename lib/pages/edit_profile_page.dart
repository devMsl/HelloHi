import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/index.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController? nicknameController;

  late AuthProvider authProvider;
  late ChatProvider chatProvider;

  File? avatarImageFile;

  String id = '';
  String nickname = '';
  String photoUrl = '';

  bool isLoading = false;

  List chatList = [];

  @override
  void initState() {
    super.initState();
    authProvider = context.read<AuthProvider>();
    chatProvider = context.read<ChatProvider>();
    nicknameController = TextEditingController();
    readLocalData();
  }

  void readLocalData() {
    id = authProvider.getPref(FirestoreConstants.id) ?? '';
    nickname = authProvider.getPref(FirestoreConstants.nickname) ?? '';
    photoUrl = authProvider.getPref(FirestoreConstants.photoUrl) ?? '';
    chatList = authProvider.chattingWithList;
    nicknameController!.text = nickname;
    setState(() {});
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    await imagePicker.getImage(source: ImageSource.gallery).then((image) {
      if (image != null) {
        avatarImageFile = File(image.path);
        setState(() {});
      }
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  Future uploadFile() async {
    isLoading = true;
    String fileName = id;
    if (avatarImageFile != null) {
      UploadTask uploadTask = chatProvider.uploadFile(avatarImageFile!, fileName);
      try {
        TaskSnapshot snapshot = await uploadTask;
        photoUrl = await snapshot.ref.getDownloadURL();
        Map<String, dynamic> uploadMap = {
          FirestoreConstants.nickname: nickname,
          FirestoreConstants.id: id,
          FirestoreConstants.photoUrl: photoUrl,
          FirestoreConstants.chattingWith: FieldValue.arrayUnion(chatList)
        };
        chatProvider.updateProfileDataFirestore(FirestoreConstants.pathUserCollection, id, uploadMap).then((data) async {
          await authProvider.setPref(FirestoreConstants.photoUrl, photoUrl);
          await authProvider.setPref(FirestoreConstants.nickname, nickname);
          Fluttertoast.showToast(msg: "Upload success");
        }).catchError((err) {
          Fluttertoast.showToast(msg: err.toString());
        }).then((value) => context.backed());
      } on FirebaseException catch (e) {
        Fluttertoast.showToast(msg: e.message ?? e.toString());
      }
    } else {
      try {
        Map<String, dynamic> uploadMap = {
          FirestoreConstants.nickname: nickname,
          FirestoreConstants.id: id,
          FirestoreConstants.photoUrl: photoUrl,
          FirestoreConstants.chattingWith: FieldValue.arrayUnion(chatList)
        };
        chatProvider.updateProfileDataFirestore(FirestoreConstants.pathUserCollection, id, uploadMap).then((data) async {
          await authProvider.setPref(FirestoreConstants.photoUrl, photoUrl);
          await authProvider.setPref(FirestoreConstants.nickname, nickname);

          Fluttertoast.showToast(msg: "Upload success");
        }).whenComplete(() {
          context.backed();
        }).catchError((err) {
          Fluttertoast.showToast(msg: err.toString());
        });
      } on FirebaseException catch (e) {
        Fluttertoast.showToast(msg: e.message ?? e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'edit_profile',
        ).tr(),
      ),
      body: SingleChildScrollView(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: ThemeType.mainColor,
                ),
              )
            : CardWidget(
                child: Column(
                  children: [
                    InkWell(
                      onTap: getImage,
                      child: avatarImageFile == null
                          ? photoUrl != ''
                              ? AvatarWidget(
                                  imgUrl: photoUrl,
                                  size: 100,
                                )
                              : Icon(
                                  Icons.account_circle,
                                  size: 90,
                                  color: ThemeType.mainColor,
                                )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(90),
                              child: Image.file(
                                avatarImageFile!,
                                height: 90,
                                width: 90,
                                fit: BoxFit.fill,
                              ),
                            ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Nickname',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      style: Theme.of(context).textTheme.bodyText2,
                      decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: ThemeType.mainColor.withOpacity(0.15)),
                      controller: nicknameController,
                      onChanged: (value) {
                        nickname = value;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextButton(
                      onPressed: uploadFile,
                      child: Text(
                        'Update',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      style: TextButton.styleFrom(backgroundColor: ThemeType.mainColor, foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
