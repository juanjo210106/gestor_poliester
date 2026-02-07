import 'package:flutter/material.dart';
import '../services/auth_service.dart';
// Importamos las pantallas a las que vamos a navegar
// (Se crearán en los siguientes pasos, ignora los errores rojos por ahora)
import 'productos_screen.dart';
import 'clientes_screen.dart';
import 'pedidos_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    const Color colorCorporativo = Color(0xFF01488E);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestor Poliéster'),
        backgroundColor: colorCorporativo,
        foregroundColor: Colors.white, // Texto blanco
        actions: [
          // Botón de Cerrar Sesión
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await authService.signOut();
              // Al cerrar sesión, main.dart detectará el cambio y mostrará el Login
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Menú Principal',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Botón para ir a Productos
            _MenuButton(
              icon: Icons.inventory_2,
              title: 'Productos',
              color: Colors.blue.shade700,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductosScreen()),
                );
              },
            ),
            const SizedBox(height: 16),

            // Botón para ir a Clientes
            _MenuButton(
              icon: Icons.people,
              title: 'Clientes',
              color: Colors.green.shade700,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ClientesScreen()),
                );
              },
            ),
            const SizedBox(height: 16),

            // Botón para ir a Pedidos
            _MenuButton(
              icon: Icons.shopping_cart,
              title: 'Pedidos',
              color: Colors.orange.shade800,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PedidosScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Widget auxiliar para no repetir código en los botones del menú
class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

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
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const Spacer(), // Empuja la flecha hacia la derecha
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}