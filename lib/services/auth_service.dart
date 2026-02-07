import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Instancias de Firebase Auth y Google Sign In
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream que notifica cambios en el estado de autenticación (Login/Logout)
  // Esto nos servirá para redirigir automáticamente al usuario
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Obtener el usuario actual (si existe)
  User? get currentUser => _auth.currentUser;

  // Método para Iniciar Sesión con Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Iniciar el flujo interactivo de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      // Si el usuario cancela la ventana emergente, devolvemos null
      if (googleUser == null) return null;

      // 2. Obtener los detalles de autenticación (tokens)
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Crear una credencial nueva para Firebase usando los tokens de Google
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Iniciar sesión en Firebase con esa credencial
      return await _auth.signInWithCredential(credential);
      
    } catch (e) {
      print("Error en el login de Google: $e");
      return null;
    }
  }

  // Método para Cerrar Sesión
  Future<void> signOut() async {
    // Es importante cerrar sesión en ambos servicios
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}