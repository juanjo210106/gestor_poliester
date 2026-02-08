// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // URL de prueba gratuita (JSONPlaceholder)
  final String _baseUrl = 'https://jsonplaceholder.typicode.com';

  // 1. LECTURA (GET): Obtener un "consejo de gestión" externo
  // (Simulamos que leemos un mensaje de una API externa)
  Future<String> obtenerConsejoDelDia() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/posts/1'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Devolvemos el título como si fuera un consejo
        return "Consejo externo: ${data['title']}";
      } else {
        return "No se pudo conectar con el servidor externo.";
      }
    } catch (e) {
      return "Error de conexión: $e";
    }
  }

  // 2. ESCRITURA (POST): Enviar datos a un servidor externo
  // (Simulamos subir un pedido a la contabilidad central)
  Future<bool> enviarPedidoExterno(Map<String, dynamic> pedidoData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(pedidoData),
      );

      // El código 201 significa "Creado" en HTTP
      if (response.statusCode == 201) {
        print("Respuesta del servidor: ${response.body}");
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error al enviar: $e");
      return false;
    }
  }
}