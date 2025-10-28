import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; 
import 'welcome_screen.dart'; 
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('users');  
  await Hive.openBox('favorites'); 
  runApp(const BloomifyApp());
}

class BloomifyApp extends StatelessWidget {
  const BloomifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bloomify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF96D6D),
          primary: const Color(0xFFF96D6D),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,     
          foregroundColor: Colors.black,     
          elevation: 0,                       
          centerTitle: true,                  
          titleTextStyle: TextStyle(     
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.black), 
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),

      home: const WelcomeScreen(),
    );
  }
}