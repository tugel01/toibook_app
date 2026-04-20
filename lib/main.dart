import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:toibook_app/providers/chat_provider.dart';
import 'package:toibook_app/providers/toi_provider.dart';
import 'package:toibook_app/screens/main%20screen/main_screen.dart';
import 'package:toibook_app/screens/welcome_screen.dart';
import 'package:toibook_app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const storage = FlutterSecureStorage();

  String? loggedIn;
  try {
    loggedIn = await storage.read(key: 'isLoggedIn');
  } catch (e) {
    loggedIn = 'false';
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ToiProvider()..loadTheme()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MyApp(isLoggedIn: loggedIn == 'true'),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode:
          context.watch<ToiProvider>().isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
      home: isLoggedIn ? const MainScreen() : const WelcomeScreen(),
    );
  }
}
