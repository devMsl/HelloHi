import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hellohi/models/message_chat.dart';
import 'package:hellohi/widgets/full_photo_widget.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/index.dart';
import '../login_page.dart';

class ChatDetailPage extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String peerNickname;

  ChatDetailPage({Key? key, required this.peerId, required this.peerAvatar, required this.peerNickname}) : super(key: key);
  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final FocusNode focusNode = FocusNode();
  final TextEditingController textEditingController = TextEditingController();

  ScrollController listScrollController = ScrollController();

  List<String> peerList = [];
  List<QueryDocumentSnapshot> messageList = [];
  List<File> imageList = [];

  int _limit = 20;

  String groupChatId = '';
  String? currentUserId;
  String imageUrl = "";

  bool isShowSticker = false;
  bool isLoading = false;

  File? imageFile;

  late ChatProvider chatProvider;
  late AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    chatProvider = context.read<ChatProvider>();
    authProvider = context.read<AuthProvider>();
    focusNode.addListener(onFocusChange);

    readLocal();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  void readLocal() {
    if (authProvider.getUserFirebaseId()?.isNotEmpty == true) {
      currentUserId = authProvider.getUserFirebaseId()!;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
    if (currentUserId!.compareTo(widget.peerId) > 0) {
      groupChatId = '$currentUserId-${widget.peerId}';
    } else {
      groupChatId = '${widget.peerId}-$currentUserId';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.white : Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.peerNickname,
        ),
        bottom: PreferredSize(
          child: Container(
            color: ThemeType.mainColor.withOpacity(0.5),
            height: 1,
          ),
          preferredSize: Size.fromHeight(1),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [buildMessageList(), isShowSticker ? buildSticker() : Container(), buildInput()],
          ),
          Positioned(
            child: isLoading ? LoadingWidget() : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget buildMessageList() {
    return Flexible(
      child: groupChatId.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
              stream: context.read<ChatProvider>().getChatStream(groupChatId, _limit),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  messageList = snapshot.data!.docs;
                  if (messageList.isNotEmpty) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemBuilder: (context, index) => buildItem(index, snapshot.data?.docs[index]),
                      itemCount: snapshot.data?.docs.length,
                      reverse: true,
                      controller: listScrollController,
                    );
                  } else {
                    return const Center(child: Text("No message here yet..."));
                  }
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      color: ThemeType.mainColor,
                    ),
                  );
                }
              },
            )
          : Center(
              child: CircularProgressIndicator(
                color: ThemeType.mainColor,
              ),
            ),
    );
  }

  Widget buildInput() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          if (imageFile != null)
            Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    imageFile!,
                    width: 90,
                    height: 90,
                    fit: BoxFit.fill,
                  ),
                  clipBehavior: Clip.hardEdge,
                ),
                Positioned.fill(
                  top: -70,
                  right: -90,
                  child: IconButton(
                    icon: Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      setState(() {
                        imageFile = null;
                      });
                    },
                  ),
                )
              ],
            ),
          Row(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(left: 5),
                child: IconButton(
                  icon: Icon(Icons.image, color: ThemeType.mainColor),
                  onPressed: pickImage,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.face,
                  color: ThemeType.mainColor,
                ),
                onPressed: getSticker,
              ),

              // Edit text
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                  child: TextField(
                    enabled: imageFile == null ? true : false,
                    style: Theme.of(context).textTheme.bodyText2,
                    onSubmitted: (value) {
                      onSendMessage(textEditingController.text, TypeMessage.text);
                    },
                    controller: textEditingController,
                    decoration: InputDecoration.collapsed(
                      hintText: 'Type your message...',
                      hintStyle: Theme.of(context).textTheme.bodyText2,
                    ),
                    focusNode: focusNode,
                  ),
                ),
              ),

              // Button send message
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: IconButton(
                  icon: Icon(Icons.send, color: ThemeType.mainColor),
                  onPressed: () {
                    setState(() {});
                    if (imageFile != null) {
                      isLoading = true;
                      uploadFile(imageFile!).whenComplete(() {
                        imageFile = null;
                      });
                    } else {
                      onSendMessage(textEditingController.text, TypeMessage.text);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      width: double.infinity,
      height: imageFile != null ? 170 : 70,
      decoration: BoxDecoration(border: const Border(top: BorderSide(color: Colors.grey, width: 0.5)), color: Theme.of(context).cardColor),
    );
  }

  // Future getImage() async {
  //   await FilePickerCross.importMultipleFromStorage(type: FileTypeCross.image).then((value) {
  //     if (value.isNotEmpty) {
  //       for (var d in value) {
  //         imageList.add(File(d.path!));
  //       }
  //       setState(() {
  //         isLoading = true;
  //       });
  //     }
  //   });
  // }

  Future pickImage() async {
    ImagePicker imagePicker = ImagePicker();
    await imagePicker.getImage(source: ImageSource.gallery).then((image) {
      if (image != null) {
        imageFile = File(image.path);
        setState(() {});
      }
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  Future uploadFile(File image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    UploadTask uploadTask = chatProvider.uploadFile(image, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, TypeMessage.image);
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  void onSendMessage(String text, int type) {
    if (text.trim().isNotEmpty) {
      textEditingController.clear();
      chatProvider.sendMessage(
        text,
        type,
        groupChatId,
        currentUserId!,
        widget.peerId,
      );
      chatProvider.updateDataFirestore(FirestoreConstants.pathUserCollection, currentUserId!, peerId: widget.peerId);
    }
  }

  Widget buildItem(int index, DocumentSnapshot? document) {
    if (document != null) {
      MessageChat messageChat = MessageChat.fromDocument(document);
      if (messageChat.idFrom == currentUserId) {
        // Right (my message)
        return Row(
          children: <Widget>[
            messageChat.type == TypeMessage.text
                ? Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      child: Text(messageChat.content, style: const TextStyle(fontSize: 14, color: Colors.white)),
                      decoration: BoxDecoration(
                          color: ThemeType.mainColor,
                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), topRight: Radius.circular(10), topLeft: Radius.circular(10))),
                      margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 10 : 5, right: 5, left: 70),
                    ),
                  )
                : messageChat.type == TypeMessage.image
                    ? Container(
                        width: 200,
                        height: 200,
                        child: InkWell(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                                fit: BoxFit.fill,
                                maxHeightDiskCache: 400,
                                maxWidthDiskCache: 400,
                                imageUrl: messageChat.content,
                                errorWidget: (context, string, _) {
                                  return Container(
                                    color: Colors.grey,
                                  );
                                },
                                placeholder: (context, string) {
                                  return Container(
                                    color: Colors.grey,
                                  );
                                }),
                            clipBehavior: Clip.hardEdge,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullPhotoWidget(
                                  url: messageChat.content,
                                ),
                              ),
                            );
                          },
                        ),
                        margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 10 : 5, right: 5),
                      )
                    // Sticker
                    : Container(
                        child: Image.asset(
                          'assets/stickers/${messageChat.content}.gif',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20 : 10, right: 10),
                      ),
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        );
      } else {
        // Left (peer message)
        return Container(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  isLastMessageLeft(index)
                      ? Material(
                          child: Image.network(
                            widget.peerAvatar,
                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: ThemeType.mainColor,
                                  value: loadingProgress.expectedTotalBytes != null && loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, object, stackTrace) {
                              return const Icon(
                                Icons.account_circle,
                                size: 35,
                                color: Colors.grey,
                              );
                            },
                            width: 35,
                            height: 35,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(18),
                          ),
                          clipBehavior: Clip.hardEdge,
                        )
                      : Container(width: 35),
                  messageChat.type == TypeMessage.text
                      ? Flexible(
                          child: Container(
                            child: Text(
                              messageChat.content,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(bottomRight: Radius.circular(10), topRight: Radius.circular(10), topLeft: Radius.circular(10)),
                              color: ThemeType.mainColor.withOpacity(0.15),
                            ),
                            margin: const EdgeInsets.only(left: 10, right: 70),
                          ),
                        )
                      : messageChat.type == TypeMessage.image
                          ? Container(
                              width: 200,
                              height: 200,
                              child: InkWell(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                      fit: BoxFit.fill,
                                      maxHeightDiskCache: 400,
                                      maxWidthDiskCache: 400,
                                      imageUrl: messageChat.content,
                                      errorWidget: (context, string, _) {
                                        return Container(
                                          color: Colors.grey,
                                        );
                                      },
                                      placeholder: (context, string) {
                                        return Container(
                                          color: Colors.grey,
                                        );
                                      }),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullPhotoWidget(url: messageChat.content),
                                    ),
                                  );
                                },
                              ),
                              margin: const EdgeInsets.only(left: 10),
                            )
                          : Container(
                              child: Image.asset(
                                'assets/stickers/${messageChat.content}.gif',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 10 : 5, right: 5),
                            ),
                ],
              ),

              // Time
              isLastMessageLeft(index)
                  ? Container(
                      child: Text(
                        DateFormat('dd MMM kk:mm').format(DateTime.fromMillisecondsSinceEpoch(int.parse(messageChat.timestamp))),
                        style: const TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                      margin: const EdgeInsets.only(left: 50, top: 5, bottom: 5),
                    )
                  : const SizedBox.shrink()
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          margin: const EdgeInsets.only(bottom: 10),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget buildSticker() {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () => onSendMessage('gif1', TypeMessage.sticker),
                  child: Image.asset(
                    'assets/stickers/gif1.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('gif2', TypeMessage.sticker),
                  child: Image.asset(
                    'assets/stickers/gif2.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('gif3', TypeMessage.sticker),
                  child: Image.asset(
                    'assets/stickers/gif3.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () => onSendMessage('gif4', TypeMessage.sticker),
                  child: Image.asset(
                    'assets/stickers/gif4.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('gif5', TypeMessage.sticker),
                  child: Image.asset(
                    'assets/stickers/gif5.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('gif6', TypeMessage.sticker),
                  child: Image.asset(
                    'assets/stickers/gif6.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () => onSendMessage('gif7', TypeMessage.sticker),
                  child: Image.asset(
                    'assets/stickers/gif7.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('gif8', TypeMessage.sticker),
                  child: Image.asset(
                    'assets/stickers/gif8.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            )
          ],
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        ),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.black, width: 0.5)), color: Colors.white),
        padding: const EdgeInsets.all(5),
        // height: 180,
      ),
    );
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 && messageList[index - 1].get(FirestoreConstants.idFrom) == currentUserId) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 && messageList[index - 1].get(FirestoreConstants.idFrom) != currentUserId) || index == 0) {
      return true;
    } else {
      return false;
    }
  }
}
