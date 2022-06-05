import 'package:flutter/material.dart';

class ThemeType {
  static Color mainColor = const Color(0xff915F78);
  ThemeData lightTheme(String str, Locale locale) {
    return ThemeData(
      iconTheme: IconThemeData(color: mainColor),
      appBarTheme: AppBarTheme(color: Colors.white, elevation: 0, titleTextStyle: TextStyle(color: mainColor), iconTheme: IconThemeData(color: mainColor)),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: Colors.white, unselectedItemColor: Colors.black45, selectedItemColor: mainColor),
      scaffoldBackgroundColor: Colors.blueGrey.shade50,
      primaryColor: mainColor,
      textTheme: TextTheme(
        caption: TextStyle(
          fontSize: 14,
          color: mainColor,
          fontFamily: str,
          fontWeight: FontWeight.w600,
          locale: locale,
        ),
        headline1: TextStyle(
          fontSize: 17,
          color: Colors.white,
          fontFamily: str,
          fontWeight: FontWeight.w600,
          locale: locale,
        ),
        headline2: TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontFamily: str,
          locale: locale,
        ),
        headline3: TextStyle(fontSize: 17, color: Colors.black, fontFamily: str, fontWeight: FontWeight.bold, locale: locale),
        headline4: TextStyle(fontSize: 17, color: Colors.black87, fontFamily: str, fontWeight: FontWeight.w600, locale: locale),
        headline5: TextStyle(fontSize: 15, color: Colors.black87, fontFamily: str, fontWeight: FontWeight.bold, locale: locale),
        headline6: TextStyle(fontSize: 14, color: Colors.white, fontFamily: str, locale: locale),
        bodyText1: TextStyle(fontSize: 14, color: Colors.black87, fontFamily: str, locale: locale),
        bodyText2: TextStyle(
          fontSize: 14,
          color: Colors.black,
          fontFamily: str,
          locale: locale,
        ),
        subtitle1: TextStyle(fontSize: 12, color: Colors.black45, fontFamily: str, locale: locale),
        subtitle2: TextStyle(fontSize: 14, color: Colors.black45, fontWeight: FontWeight.bold, fontFamily: str, locale: locale), //decoration: TextDecoration.lineThrough
      ),
    );
  }

  static Color backgroundDarkColor = const Color(0xff1E2D40);
  var darkColor = const Color(0xff273B53);

  ThemeData darkTheme(String str, Locale locale) {
    return ThemeData(
      canvasColor: darkColor,
      appBarTheme: AppBarTheme(elevation: 0, titleTextStyle: TextStyle(color: mainColor), iconTheme: IconThemeData(color: mainColor)),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: backgroundDarkColor, selectedItemColor: mainColor, unselectedItemColor: Colors.white38),
      cardColor: backgroundDarkColor,
      scaffoldBackgroundColor: darkColor,
      dialogBackgroundColor: backgroundDarkColor,
      primaryColor: mainColor,
      brightness: Brightness.dark,
      textTheme: TextTheme(
        caption: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600, fontFamily: str, locale: locale),
        headline1: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.w600, fontFamily: str, locale: locale),
        headline2: TextStyle(fontSize: 12, color: Colors.white, fontFamily: str, locale: locale),
        headline3: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: str, locale: locale),
        headline4: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w600, fontFamily: str, locale: locale),
        headline5: TextStyle(fontSize: 14, color: Color(0xff915F78), fontWeight: FontWeight.w600, fontFamily: str, locale: locale),
        headline6: TextStyle(fontSize: 15, color: Colors.white, fontFamily: str, locale: locale),
        bodyText1: TextStyle(fontSize: 14, color: Colors.white, fontFamily: str, locale: locale),
        bodyText2: TextStyle(fontSize: 14, color: Colors.white70, fontFamily: str, locale: locale),
        subtitle1: TextStyle(fontSize: 14, color: Colors.white60, fontFamily: str, locale: locale),
      ),
    );
  }
}
