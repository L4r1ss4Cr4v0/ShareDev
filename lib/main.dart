import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_config.dart';
import 'screens/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeFirebase();

  runApp(const ShareDevApp());
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: FirebaseConfig.current,
    );
  } catch (e, stackTrace) {
    debugPrint('Erro ao inicializar Firebase');
    debugPrint('$e');
    debugPrint('$stackTrace');
  }
}

class ShareDevApp extends StatelessWidget {
  const ShareDevApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShareDev',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.purple,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
      ),
      home: const Wrapper(),
    );
  }
}
