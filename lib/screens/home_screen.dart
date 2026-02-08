import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart'; // Importamos el nuevo servicio
import 'productos_screen.dart';
import 'clientes_screen.dart';
import 'pedidos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService(); // Instancia del servicio API
  
  // Variable para guardar el consejo
  String _consejo = "Cargando consejo externo...";

  @override
  void initState() {
    super.initState();
    _cargarConsejo();
  }

  void _cargarConsejo() async {
    String consejoRecibido = await _apiService.obtenerConsejoDelDia();
    setState(() {
      _consejo = consejoRecibido;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color colorCorporativo = Color(0xFF01488E);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestor Poliéster'),
        backgroundColor: colorCorporativo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- PARTE DE LECTURA WEBSERVICE ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.amber),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _consejo, 
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // -----------------------------------

            const Text(
              'Menú Principal',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            _MenuButton(
              icon: Icons.inventory_2,
              title: 'Productos',
              color: Colors.blue.shade700,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductosScreen())),
            ),
            const SizedBox(height: 16),

            _MenuButton(
              icon: Icons.people,
              title: 'Clientes',
              color: Colors.green.shade700,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientesScreen())),
            ),
            const SizedBox(height: 16),

            _MenuButton(
              icon: Icons.shopping_cart,
              title: 'Pedidos',
              color: Colors.orange.shade800,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PedidosScreen())),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget auxiliar del botón (Igual que antes)
class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton({required this.icon, required this.title, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(width: 20),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}