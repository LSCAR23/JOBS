import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jobs/screens/login_screen.dart';
import 'package:jobs/screens/main_screen.dart';
import 'package:jobs/screens/register_screen.dart';
import 'package:jobs/splash_screen/splash_screen.dart';
import 'package:jobs/themeProvider/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
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
      home: const SplashScreen(),
    );
  }
}

