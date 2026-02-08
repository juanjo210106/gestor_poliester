import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Para obtener nombres por ID
import 'package:intl/intl.dart'; // Para formatear fechas bonita
import '../models/pedido_model.dart';
import '../models/cliente_model.dart';
import '../models/producto_model.dart';
import '../services/firestore_service.dart';
import '../services/api_service.dart';

class PedidosScreen extends StatefulWidget {
  const PedidosScreen({super.key});

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final ApiService _apiService = ApiService();

  // Método para mostrar el formulario de Pedidos
  // Es async porque necesitamos esperar a cargar clientes y productos antes de mostrar el diálogo
  void _mostrarFormulario({Pedido? pedido}) async {
    // 1. Obtenemos las listas actuales de Clientes y Productos
    // Usamos .first para convertir el Stream en un solo dato (Future)
    final List<Cliente> clientes = await _firestoreService.getClientes().first;
    final List<Producto> productos = await _firestoreService
        .getProductos()
        .first;

    if (!mounted)
      return; // Comprobación de seguridad por si cambias de pantalla

    if (clientes.isEmpty || productos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registra primero Clientes y Productos para poder crear pedidos.',
          ),
        ),
      );
      return;
    }

    // 2. Preparamos valores iniciales
    // Si editamos, usamos los del pedido. Si es nuevo, usamos el primero de la lista.
    String selectedClienteId = pedido?.clienteId ?? clientes.first.id;
    String selectedProductoId = pedido?.productoId ?? productos.first.id;
    String selectedEstado = pedido?.estado ?? 'Pendiente';

    // Verificación extra: si el ID guardado ya no existe (se borró el cliente), volvemos al primero
    if (!clientes.any((c) => c.id == selectedClienteId))
      selectedClienteId = clientes.first.id;
    if (!productos.any((p) => p.id == selectedProductoId))
      selectedProductoId = productos.first.id;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(pedido == null ? 'Nuevo Pedido' : 'Editar Pedido'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // SELECTOR DE CLIENTE
                    DropdownButtonFormField<String>(
                      value: selectedClienteId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Cliente',
                        icon: Icon(Icons.person),
                      ),
                      items: clientes.map((c) {
                        return DropdownMenuItem(
                          value: c.id,
                          child: Text(
                            c.nombre,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setStateDialog(() => selectedClienteId = val!),
                    ),
                    const SizedBox(height: 15),

                    // SELECTOR DE PRODUCTO
                    DropdownButtonFormField<String>(
                      value: selectedProductoId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Producto',
                        icon: Icon(Icons.inventory_2),
                      ),
                      items: productos.map((p) {
                        return DropdownMenuItem(
                          value: p.id,
                          child: Text(
                            '${p.nombre} (${p.tipo})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setStateDialog(() => selectedProductoId = val!),
                    ),
                    const SizedBox(height: 15),

                    // SELECTOR DE ESTADO
                    DropdownButtonFormField<String>(
                      value: selectedEstado,
                      decoration: const InputDecoration(
                        labelText: 'Estado',
                        icon: Icon(Icons.info),
                      ),
                      items:
                          ['Pendiente', 'En proceso', 'Entregado', 'Cancelado']
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                      onChanged: (val) =>
                          setStateDialog(() => selectedEstado = val!),
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
                    final nuevoPedido = Pedido(
                      id: pedido?.id ?? '',
                      clienteId: selectedClienteId,
                      productoId: selectedProductoId,
                      fecha:
                          pedido?.fecha ??
                          DateTime.now(), // Mantiene fecha original o pone hoy
                      estado: selectedEstado,
                    );

                    if (pedido == null) {
                      _firestoreService.addPedido(nuevoPedido);
                    } else {
                      _firestoreService.updatePedido(nuevoPedido);
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
        title: const Text('Pedidos'),
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Pedido>>(
        stream: _firestoreService.getPedidos(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text('Error al cargar'));
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final pedidos = snapshot.data!;

          if (pedidos.isEmpty) {
            return const Center(child: Text('No hay pedidos registrados'));
          }

          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              // Usamos la librería intl para que la fecha se vea bien (ej: 25/10/2023 14:30)
              final fechaFormateada = DateFormat(
                'dd/MM/yyyy HH:mm',
              ).format(pedido.fecha);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    title: Text(
                      'Pedido: $fechaFormateada',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          'Estado: ${pedido.estado}',
                          style: TextStyle(
                            color: pedido.estado == 'Pendiente'
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                        const Divider(),
                        // Aquí usamos widgets especiales para buscar el nombre real
                        _NombreCliente(clienteId: pedido.clienteId),
                        _NombreProducto(productoId: pedido.productoId),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // BOTÓN DE PUBLICACIÓN WEBSERVICE
                        IconButton(
                          icon: const Icon(
                            Icons.cloud_upload,
                            color: Colors.blue,
                          ),
                          tooltip: 'Enviar a ERP Externo',
                          onPressed: () async {
                            // Mostramos carga
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Enviando datos a servidor externo...',
                                ),
                              ),
                            );

                            // 1. Creamos una copia de los datos para no romper nada
                            Map<String, dynamic> datosParaEnviar = Map.from(
                              pedido.toMap(),
                            );

                            // 2. Convertimos la fecha 'rara' de Firebase a texto simple (ISO 8601)
                            // NOTA: 'fecha' en tu modelo es DateTime, así que lo convertimos a String aquí
                            datosParaEnviar['fecha'] = pedido.fecha
                                .toIso8601String();

                            // 3. Enviamos los datos limpios
                            bool exito = await _apiService.enviarPedidoExterno(
                              datosParaEnviar,
                            );

                            if (!mounted) return;
                            if (exito) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    '✅ ¡Pedido sincronizado con la nube!',
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('❌ Error al sincronizar'),
                                ),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _mostrarFormulario(pedido: pedido),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _firestoreService.deletePedido(pedido.id),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange.shade800,
        child: const Icon(Icons.add),
        onPressed: () => _mostrarFormulario(),
      ),
    );
  }
}

// ============================================================================
// WIDGETS AUXILIARES
// Estos widgets pequeños buscan un documento por ID para mostrar el nombre
// ============================================================================

class _NombreCliente extends StatelessWidget {
  final String clienteId;
  const _NombreCliente({required this.clienteId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('clientes')
          .doc(clienteId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Text('Cargando cliente...');
        final data = snapshot.data!.data() as Map<String, dynamic>?;
        return Text('👤 Cliente: ${data?['nombre'] ?? 'No encontrado'}');
      },
    );
  }
}

class _NombreProducto extends StatelessWidget {
  final String productoId;
  const _NombreProducto({required this.productoId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('productos')
          .doc(productoId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Text('Cargando producto...');
        final data = snapshot.data!.data() as Map<String, dynamic>?;
        return Text('📦 Producto: ${data?['nombre'] ?? 'No encontrado'}');
      },
    );
  }
}
