import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toibook_app/providers/toi_provider.dart';
import 'package:toibook_app/screens/welcome_screen.dart';
import 'package:toibook_app/theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ToiProvider()),
        // You can add an AuthProvider here later too!
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.light, // This matches your copied code
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const WelcomeScreen(),
    );
  }
}
