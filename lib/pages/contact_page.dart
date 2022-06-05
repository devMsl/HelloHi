import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_ob.dart';
import '../utils/index.dart';
import 'chat_page/chat_detail_page.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  late ContactProvider _contactStream;
  late AuthProvider _authProvider;
  late String currentUserId;
  int _limit = 20;
  String? _nameSearch;

  @override
  void initState() {
    super.initState();
    _contactStream = context.read<ContactProvider>();
    _authProvider = context.read<AuthProvider>();
    if (_authProvider.getUserFirebaseId()?.isNotEmpty == true) {
      currentUserId = _authProvider.getUserFirebaseId()!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('contacts').tr(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _contactStream.getFirestoreStream(FirestoreConstants.pathUserCollection, _limit, _nameSearch),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            if ((snapshot.data?.docs.length ?? 0) > 0) {
              return ListView.builder(
                itemBuilder: (context, index) => contactItem(context, snapshot.data?.docs[index]),
                itemCount: snapshot.data?.docs.length,
              );
            } else {
              return const Center(
                child: Text("No users"),
              );
            }
          } else {
            return Center(
              child: CircularProgressIndicator(
                color: ThemeType.mainColor,
              ),
            );
          }
        },
      ),
    );
  }

  Widget contactItem(BuildContext context, DocumentSnapshot? document) {
    if (document != null) {
      UserOb userOb = UserOb.fromDocument(document);
      if (userOb.id == currentUserId) {
        return const SizedBox.shrink();
      } else {
        return InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return ChatDetailPage(peerId: userOb.id, peerAvatar: userOb.photoUrl, peerNickname: userOb.nickname);
            }));
          },
          child: CardWidget(
            child: Row(
              children: [
                AvatarWidget(
                  size: 50,
                  imgUrl: userOb.photoUrl,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  userOb.nickname,
                  style: Theme.of(context).textTheme.bodyText2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }
}
