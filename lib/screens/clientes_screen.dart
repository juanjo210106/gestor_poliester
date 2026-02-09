import 'package:flutter/material.dart';
import '../models/cliente_model.dart';
import '../services/firestore_service.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  
  // Variables para filtros y orden
  final TextEditingController _searchController = TextEditingController();
  String _busqueda = '';
  bool _ordenAscendente = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Formulario para añadir/editar clientes
void _mostrarFormulario({Cliente? cliente}) {
  final _nombreController = TextEditingController(text: cliente?.nombre ?? '');
  final _emailController = TextEditingController(text: cliente?.email ?? '');
  final _telefonoController = TextEditingController(text: cliente?.telefono ?? '');
  
  // 1. CREAMOS LA LLAVE DEL FORMULARIO
  final _formKey = GlobalKey<FormState>(); 

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(cliente == null ? 'Nuevo Cliente' : 'Editar Cliente'),
        content: SingleChildScrollView(
          // 2. ENVOLVEMOS TODO EN UN WIDGET FORM
          child: Form( 
            key: _formKey, // Asignamos la llave
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  // 3. AÑADIMOS EL VALIDADOR (Esta es la lógica que hace salir lo rojo)
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese un nombre'; // <--- MENSAJE DE ERROR
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese un email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _telefonoController,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese un teléfono';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // 4. PREGUNTAMOS A LA LLAVE SI TODO ESTÁ BIEN
              if (_formKey.currentState!.validate()) {
                // Solo si devuelve TRUE (todo válido), guardamos
                final nuevoCliente = Cliente(
                  id: cliente?.id ?? '',
                  nombre: _nombreController.text,
                  email: _emailController.text,
                  telefono: _telefonoController.text,
                );

                if (cliente == null) {
                  _firestoreService.addCliente(nuevoCliente);
                } else {
                  _firestoreService.updateCliente(nuevoCliente);
                }
                Navigator.of(context).pop();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // BARRA DE BÚSQUEDA Y ORDENACIÓN
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar por nombre...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      // Actualizamos el estado cada vez que se escribe para filtrar en tiempo real
                      setState(() => _busqueda = val.toLowerCase());
                    },
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(_ordenAscendente ? Icons.sort_by_alpha : Icons.sort_by_alpha, color: Colors.green),
                  // Icono visualmente distinto si invertimos orden (opcional)
                  selectedIcon: const Icon(Icons.text_rotation_down),
                  onPressed: () => setState(() => _ordenAscendente = !_ordenAscendente),
                  tooltip: 'Ordenar A-Z / Z-A',
                ),
              ],
            ),
          ),

          // LISTA DE CLIENTES
          Expanded(
            child: StreamBuilder<List<Cliente>>(
              stream: _firestoreService.getClientes(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text('Error al cargar'));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                var clientes = snapshot.data!;

                // 1. Aplicar Filtro (Buscador)
                if (_busqueda.isNotEmpty) {
                  clientes = clientes.where((c) => 
                    c.nombre.toLowerCase().contains(_busqueda)
                  ).toList();
                }

                // 2. Aplicar Ordenación (Alfabética)
                clientes.sort((a, b) {
                  int comp = a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
                  return _ordenAscendente ? comp : -comp;
                });

                if (clientes.isEmpty) {
                  return const Center(child: Text('No se encontraron clientes'));
                }

                return ListView.builder(
                  itemCount: clientes.length,
                  itemBuilder: (context, index) {
                    final cliente = clientes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: Text(
                            cliente.nombre.isNotEmpty ? cliente.nombre[0].toUpperCase() : '?',
                            style: TextStyle(color: Colors.green.shade800),
                          ),
                        ),
                        title: Text(cliente.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (cliente.email.isNotEmpty)
                              Text('✉ ${cliente.email}', style: const TextStyle(fontSize: 12)),
                            if (cliente.telefono.isNotEmpty)
                              Text('📞 ${cliente.telefono}', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => _mostrarFormulario(cliente: cliente),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _firestoreService.deleteCliente(cliente.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.shade700,
        child: const Icon(Icons.add),
        onPressed: () => _mostrarFormulario(),
      ),
    );
  }
}