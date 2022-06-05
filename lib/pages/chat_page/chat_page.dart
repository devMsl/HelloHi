import '../../models/message_chat.dart';
import '../../models/user_ob.dart';
import '../../utils/index.dart';
import '../login_page.dart';
import 'chat_detail_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController listScrollController = ScrollController();
  int _limit = 20;
  String _textSearch = "";
  String? currentUserId;
  late AuthProvider authProvider;
  UserOb? _myOb;
  UserOb? _userOb;
  MessageChat? msg;
  List<Map<String, String>> showChatList = [];
  bool isLoading = true;
  List chattingWithList = [];
  @override
  void initState() {
    super.initState();

    authProvider = context.read<AuthProvider>();

    if (authProvider.getUserFirebaseId()?.isNotEmpty == true) {
      currentUserId = context.read<AuthProvider>().getUserFirebaseId();
    } else {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginPage()), (route) => false);
    }

    context.read<ContactProvider>().getFirestoreStream(FirestoreConstants.pathUserCollection, _limit, _textSearch, id: currentUserId).listen((event) {
      if (event.docs.isNotEmpty) {
        _myOb = UserOb.fromDocument(event.docs.first);
        if (_myOb!.chattingWith != null) {
          chattingWithList = _myOb!.chattingWith as List;
          authProvider.getChattingWithList(chattingWithList);
          for (int u = 0; u < chattingWithList.length; u++) {
            context.read<ContactProvider>().getFirestoreStream(FirestoreConstants.pathUserCollection, _limit, _textSearch, id: chattingWithList[u]).listen((nameEvent) {
              if (nameEvent.docs.isNotEmpty) {
                _userOb = UserOb.fromDocument(nameEvent.docs.first);
                showChatList.add({'id': _userOb!.id, 'nickname': _userOb!.nickname, 'photoUrl': _userOb!.photoUrl});
                context
                    .read<ChatProvider>()
                    .getChatStream(
                        '${currentUserId!.compareTo(chattingWithList[u]) > 0 ? currentUserId! + '-' + chattingWithList[u] : chattingWithList[u] + '-' + currentUserId}', _limit)
                    .listen((messageEvent) {
                  if (messageEvent.docs.isNotEmpty) {
                    msg = MessageChat.fromDocument(messageEvent.docs[0]);
                    showChatList[u].addAll({'lastMessage': msg!.content, 'timestamp': msg!.timestamp}); //,
                    if (mounted) {
                      setState(() {});
                    }
                  }
                });
              }
            });
          }
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        }
      } else {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'chat',
        ).tr(),
      ),
      body: !isLoading
          ? Column(
              children: showChatList.map((chatItem) {
                return InkWell(
                  onTap: () {
                    context.pushed(ChatDetailPage(peerId: chatItem['id'] ?? '', peerAvatar: chatItem['photoUrl'] ?? '', peerNickname: chatItem['nickname'] ?? ''));
                  },
                  child: CardWidget(
                    child: Row(
                      children: [
                        AvatarWidget(
                          imgUrl: chatItem['photoUrl'],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chatItem['nickname'] != null ? chatItem['nickname'].toString() : '',
                                style: Theme.of(context).textTheme.headline5,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      chatItem['lastMessage'] != null ? chatItem['lastMessage'].toString() : '',
                                      style: Theme.of(context).textTheme.bodyText2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    chatItem['timestamp'] != null
                                        ? DateFormat('dd MMM kk:mm').format(DateTime.fromMillisecondsSinceEpoch(int.parse(chatItem['timestamp'].toString())))
                                        : '',
                                    style: Theme.of(context).textTheme.subtitle1,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            )
          : Center(
              child: CircularProgressIndicator(
                color: ThemeType.mainColor,
              ),
            ),
    );
  }
}
