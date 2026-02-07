import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';

void main() async {
  // 1. Aseguramos que el motor de Flutter esté listo antes de usar plugins
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializamos Firebase
  // IMPORTANTE: Como no usamos firebase_options.dart,
  // Flutter buscará automáticamente el archivo google-services.json en Android
  // y GoogleService-Info.plist en iOS.
  await Firebase.initializeApp();

  // 3. Arrancamos la App
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor Poliéster',
      debugShowCheckedModeBanner: false, // Quita la etiqueta "Debug" de la esquina
      
      // CONFIGURACIÓN DEL TEMA (Visual)
      theme: ThemeData(
        // Color base definido en los requisitos
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF01488E), 
          primary: const Color(0xFF01488E),
        ),
        useMaterial3: true, // Diseño moderno de Flutter
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),

      // GESTOR DE NAVEGACIÓN (Auth Gate)
      // Este StreamBuilder escucha constantemente si hay alguien logueado.
      home: StreamBuilder<User?>(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          // Si Firebase está intentando conectar, mostramos carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Si hay datos en el snapshot, es que hay un usuario logueado -> Vamos a Home
          if (snapshot.hasData) {
            return const HomeScreen();
          }

          // Si no hay datos, es que no hay sesión -> Vamos a Login
          return const LoginScreen();
        },
      ),
    );
  }
}