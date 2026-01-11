// lib/screens/wrapper.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:devgram/screens/auth_screen.dart';
import 'package:devgram/screens/gallery_screen.dart';

/// Widget que decide qual tela mostrar baseado no estado de autenticação
class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Aguardando conexão
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Usuário logado
        if (snapshot.hasData && snapshot.data != null) {
          return const GalleryScreen();
        }

        // Usuário não logado
        return const AuthScreen();
      },
    );
  }
}
