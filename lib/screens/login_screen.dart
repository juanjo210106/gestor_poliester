import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false; // Para mostrar un circulito de carga

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true); // Activamos carga

    try {
      await _authService.signInWithGoogle();
      // No necesitamos navegar manualmente.
      // El 'Stream' en main.dart detectará el cambio y nos llevará a Home automáticamente.
    } catch (e) {
      // Si falla, mostramos un aviso simple
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al iniciar sesión: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false); // Desactivamos carga
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definimos el color corporativo
    const Color colorCorporativo = Color(0xFF01488E);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono o Logo simulado
              const Icon(
                Icons.water_drop, // Icono relacionado con depósitos/agua
                size: 100,
                color: colorCorporativo,
              ),
              const SizedBox(height: 20),
              
              // Título de la App
              const Text(
                'Gestor Poliéster',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colorCorporativo,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Gestión de depósitos y piscinas',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 60),

              // Botón de Login (o indicador de carga)
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // Fondo blanco
                        foregroundColor: Colors.black, // Texto negro
                        minimumSize: const Size(double.infinity, 50),
                        side: const BorderSide(color: Colors.grey), // Borde gris
                      ),
                      icon: const Icon(Icons.login, color: colorCorporativo),
                      label: const Text(
                        'Iniciar sesión con Google',
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: _handleGoogleSignIn,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}