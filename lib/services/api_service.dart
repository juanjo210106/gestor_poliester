import 'dart:convert';
import 'dart:math'; // librería para los números aleatorios
import 'package:http/http.dart' as http;

class ApiService {
  // URL de prueba gratuita (JSONPlaceholder)
  final String _baseUrl = 'https://jsonplaceholder.typicode.com';

  // Obtener un "consejo" ALEATORIO
  Future<String> obtenerConsejoDelDia() async {
    try {
      // Generamos un número al azar del 1 al 100
      int idAleatorio = Random().nextInt(100) + 1;

      // Pedimos ese post específico a la API
      final response = await http.get(
        Uri.parse('$_baseUrl/posts/$idAleatorio'),
        headers: {
          'User-Agent': 'PostmanRuntime/7.29.0',
          'Accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Cortamos el texto si es muy largo para que quede bonito
        String texto = data['title'];
        if (texto.length > 50) texto = "${texto.substring(0, 50)}...";

        return "Consejo #$idAleatorio: $texto";
      } else {
        return "No se pudo conectar con el servidor externo.";
      }
    } catch (e) {
      return "Error de conexión: $e";
    }
  }

  Future<bool> enviarPedidoExterno(Map<String, dynamic> pedidoData) async {
    // ENVIAMOS LOS DATOS MEDIANTE POST
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(pedidoData),
      );
      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
