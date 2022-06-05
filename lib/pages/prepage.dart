import 'package:hellohi/pages/check_page.dart';
import 'package:hellohi/providers/theme_provider.dart';
import 'package:hellohi/utils/shared_pref.dart';

import '../utils/index.dart';

class PrePage extends StatefulWidget {
  @override
  _PrePageState createState() => _PrePageState();
}

class _PrePageState extends State<PrePage> {
  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      path: 'lang',
      supportedLocales: const [Locale('en'), Locale('my')],
      fallbackLocale: const Locale('en'),
      child: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final ThemeType _themeType = ThemeType();
  static String fontFamily = "Pyidaungsu";

  @override
  void initState() {
    super.initState();
    SharedPref.getData(key: SharedPref.language).then((lan) {
      if (lan == 'en' || lan == null || lan == '') {
        fontFamily = "Pyidaungsu";
      } else if (lan == 'my') {
        fontFamily = "Pyidaungsu";
      } else {
        fontFamily = "Pyidaungsu";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, ThemeProvider themeProvider, child) {
      return MaterialApp(
        themeMode: themeProvider.themeMode,
        theme: _themeType.lightTheme(fontFamily, context.locale),
        darkTheme: _themeType.darkTheme(fontFamily, context.locale),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: CheckPage(),
      );
    });
  }
}
