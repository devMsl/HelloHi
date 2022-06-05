import 'package:hellohi/pages/chat_page/chat_page.dart';
import 'package:hellohi/pages/setting_page.dart';

import '../utils/index.dart';
import 'contact_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final bodyOptions = [
    ChatPage(),
    ContactPage(),
    SettingPage(),
  ];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: bodyOptions.elementAt(selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTapItem,
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: const Icon(CupertinoIcons.chat_bubble_2), label: tr('chat')),
          BottomNavigationBarItem(icon: const ImageIcon(AssetImage('assets/icons/contact.png')), label: tr('contacts')),
          const BottomNavigationBarItem(icon: Icon(CupertinoIcons.settings_solid), label: 'Me'),
        ],
      ),
    );
  }

  onTapItem(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
}
