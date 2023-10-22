import 'package:flutter/material.dart';
import 'package:jobs/screens/main_page.dart';
import 'package:jobs/screens/register_screen.dart';
import 'package:jobs/themeProvider/theme_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      themeMode: ThemeMode.system,
      theme: MyThemes.lightTheme,
      darkTheme: MyThemes.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const RegisterScreen(),
    );
  }
}

