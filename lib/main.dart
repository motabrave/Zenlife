import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_scaffold.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AnGiacApp());
}

class AnGiacApp extends StatelessWidget {
  const AnGiacApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      colorSchemeSeed: const Color(0xFF6C63FF),
      brightness: Brightness.light,
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'Zenlife',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme),
        appBarTheme: const AppBarTheme(
          centerTitle: true,),
      ),
      home: const MainScaffold(),
    );
  }
}
