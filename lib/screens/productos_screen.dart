import 'package:flutter/material.dart';
import '../models/producto_model.dart';
import '../services/firestore_service.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  
  // Variables para el control de filtros y orden
  String _filtroTipo = 'Todos'; // Todos, depósito, piscina
  bool _ordenAscendente = true;

  // Método para mostrar el formulario de añadir/editar
  void _mostrarFormulario({Producto? producto}) {
    final nombreController = TextEditingController(text: producto?.nombre ?? '');
    final capacidadController = TextEditingController(text: producto?.capacidad.toString() ?? '');
    final precioController = TextEditingController(text: producto?.precio.toString() ?? '');
    String tipoSeleccionado = producto?.tipo ?? 'depósito';

    showDialog(
      context: context,
      builder: (context) {
        // Usamos StatefulBuilder para que el Dropdown se actualice dentro del diálogo
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(producto == null ? 'Nuevo Producto' : 'Editar Producto'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreController,
                      decoration: const InputDecoration(labelText: 'Nombre del modelo'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: tipoSeleccionado,
                      items: ['depósito', 'piscina'].map((tipo) {
                        return DropdownMenuItem(value: tipo, child: Text(tipo.toUpperCase()));
                      }).toList(),
                      onChanged: (val) => setStateDialog(() => tipoSeleccionado = val!),
                      decoration: const InputDecoration(labelText: 'Tipo'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: capacidadController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Capacidad (Litros)'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: precioController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Precio (€)'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Validar y guardar
                    if (nombreController.text.isEmpty) return;

                    final nuevoProducto = Producto(
                      id: producto?.id ?? '', // Si es nuevo, el ID se ignora al añadir
                      nombre: nombreController.text,
                      tipo: tipoSeleccionado,
                      capacidad: double.tryParse(capacidadController.text) ?? 0,
                      precio: double.tryParse(precioController.text) ?? 0,
                    );

                    if (producto == null) {
                      _firestoreService.addProducto(nuevoProducto);
                    } else {
                      _firestoreService.updateProducto(nuevoProducto);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // BARRA DE FILTROS Y ORDENACIÓN
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Filtro por Tipo
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _filtroTipo,
                    items: ['Todos', 'depósito', 'piscina'].map((val) {
                      return DropdownMenuItem(value: val, child: Text(val.toUpperCase()));
                    }).toList(),
                    onChanged: (val) => setState(() => _filtroTipo = val!),
                  ),
                ),
                const SizedBox(width: 10),
                // Botón de Ordenar
                IconButton(
                  icon: Icon(_ordenAscendente ? Icons.arrow_upward : Icons.arrow_downward),
                  onPressed: () => setState(() => _ordenAscendente = !_ordenAscendente),
                  tooltip: 'Ordenar por precio',
                ),
              ],
            ),
          ),

          // LISTA DE PRODUCTOS
          Expanded(
            child: StreamBuilder<List<Producto>>(
              stream: _firestoreService.getProductos(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text('Error al cargar'));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                var productos = snapshot.data!;

                // 1. Aplicar Filtro
                if (_filtroTipo != 'Todos') {
                  productos = productos.where((p) => p.tipo == _filtroTipo).toList();
                }

                // 2. Aplicar Ordenación (por Precio)
                productos.sort((a, b) {
                  int comp = a.precio.compareTo(b.precio);
                  return _ordenAscendente ? comp : -comp;
                });

                if (productos.isEmpty) {
                  return const Center(child: Text('No hay productos registrados'));
                }

                return ListView.builder(
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final prod = productos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: Icon(
                          prod.tipo == 'piscina' ? Icons.pool : Icons.water_damage,
                          color: Colors.blue,
                        ),
                        title: Text(prod.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${prod.capacidad.toStringAsFixed(0)} L  |  ${prod.precio} €'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => _mostrarFormulario(producto: prod),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // Confirmar borrado
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('¿Eliminar?'),
                                    content: const Text('Esta acción no se puede deshacer.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _firestoreService.deleteProducto(prod.id);
                                          Navigator.pop(ctx);
                                        },
                                        child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
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
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.add),
        onPressed: () => _mostrarFormulario(),
      ),
    );
  }
}