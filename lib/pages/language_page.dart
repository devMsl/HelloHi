import '../utils/index.dart';
import '../utils/shared_pref.dart';

class LanguagePage extends StatefulWidget {
  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String changeEn = "";
  String changeUni = "";

  void changeLanMark() {
    SharedPref.getData(key: SharedPref.language).then((rv) {
      if (rv == "en") {
        setState(() {
          changeEn = rv.toString();
          changeUni = "";
          selectedRadio = 1;
        });
      }
      if (rv == "my") {
        setState(() {
          changeUni = rv.toString();
          changeEn = "";
          selectedRadio = 2;
        });
      }
    });
  }

  int selectedRadio = 1;

  @override
  void initState() {
    super.initState();

    changeLanMark();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Language').tr(),
        ),
        body: CardWidget(
          child: ListView(
            children: <Widget>[
              RadioListTile<int>(
                  title: Text(
                    "English",
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  value: 1,
                  groupValue: selectedRadio,
                  activeColor: ThemeType.mainColor,
                  onChanged: (v) {
                    setState(() {
                      selectedRadio = v!;
                    });
                    SharedPref.setData(key: SharedPref.language, value: 'en');
                    context.setLocale(const Locale('en'));
                  }),
              RadioListTile<int>(
                  title: Text(
                    "မြန်မာ(unicode)",
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  value: 3,
                  groupValue: selectedRadio,
                  activeColor: ThemeType.mainColor,
                  onChanged: (v) {
                    setState(() {
                      selectedRadio = v!;
                    });
                    SharedPref.setData(key: SharedPref.language, value: 'my');
                    context.setLocale(const Locale('my'));
                  }),
            ],
          ),
        ));
  }
}
