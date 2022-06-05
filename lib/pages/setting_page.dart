import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:hellohi/pages/language_page.dart';
import 'package:hellohi/providers/theme_provider.dart';

import '../utils/index.dart';
import 'edit_profile_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final User? _user = FirebaseAuth.instance.currentUser;
  CollectionReference usersCollection = FirebaseFirestore.instance.collection(FirestoreConstants.pathUserCollection);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: AppBar(
            systemOverlayStyle: Theme.of(context).brightness == Brightness.light ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
            backgroundColor: Colors.transparent,
          )),
      body: StreamBuilder<DocumentSnapshot>(
          stream: usersCollection.doc(_user?.uid).snapshots(),
          builder: (b, streamSnapshot) {
            return streamSnapshot.hasData
                ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CardWidget(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  AvatarWidget(
                                    imgUrl: streamSnapshot.data!['photoUrl'],
                                    size: 100,
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 10),
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(color: ThemeType.mainColor, borderRadius: BorderRadius.circular(10)),
                                      child: InkWell(
                                        onTap: () {
                                          context.pushed(EditProfilePage());
                                        },
                                        child: Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(streamSnapshot.data!['nickname']),
                              const SizedBox(
                                height: 30,
                              ),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                    return LanguagePage();
                                  }));
                                },
                                leading: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(color: ThemeType.mainColor, borderRadius: BorderRadius.circular(10)),
                                  child: const Icon(
                                    Icons.language,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  'Language'.tr(),
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  // color: Colors.blueGrey,
                                ),
                              ),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(color: ThemeType.mainColor, borderRadius: BorderRadius.circular(10)),
                                  child: const Icon(
                                    Icons.nightlight_round_sharp,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  'Theme',
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                                trailing: ButtonTheme(
                                  alignedDropdown: true,
                                  child: DropdownButton(
                                    items: const [
                                      DropdownMenuItem(
                                        child: Text(
                                          'Light',
                                        ),
                                        value: ThemeMode.light,
                                      ),
                                      DropdownMenuItem(
                                        child: Text(
                                          'Dark',
                                        ),
                                        value: ThemeMode.dark,
                                      ),
                                      DropdownMenuItem(
                                        child: Text(
                                          'System',
                                        ),
                                        value: ThemeMode.system,
                                      )
                                    ],
                                    underline: Container(),
                                    style: Theme.of(context).textTheme.bodyText2,
                                    value: context.read<ThemeProvider>().themeMode,
                                    onChanged: (val) {
                                      if (val == ThemeMode.light) {
                                        context.read<ThemeProvider>().changeToLight();
                                      } else if (val == ThemeMode.dark) {
                                        context.read<ThemeProvider>().changeToDark();
                                      } else {
                                        context.read<ThemeProvider>().changeToSystem();
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 1,
                      color: ThemeType.mainColor,
                    ),
                  );
          }),
    );
  }
}
