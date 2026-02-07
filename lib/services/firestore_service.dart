import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/producto_model.dart';
import '../models/cliente_model.dart';
import '../models/pedido_model.dart';

class FirestoreService {
  // Instancia principal de Firestore
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==============================================================================
  // GESTIÓN DE PRODUCTOS
  // ==============================================================================

  // Obtener lista de productos en tiempo real (Stream)
  // Ordenados por nombre para que la lista salga bonita
  Stream<List<Producto>> getProductos() {
    return _db.collection('productos').orderBy('nombre').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Producto.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Añadir un nuevo producto
  Future<void> addProducto(Producto producto) {
    return _db.collection('productos').add(producto.toMap());
  }

  // Actualizar un producto existente
  Future<void> updateProducto(Producto producto) {
    return _db.collection('productos').doc(producto.id).update(producto.toMap());
  }

  // Eliminar un producto
  Future<void> deleteProducto(String id) {
    return _db.collection('productos').doc(id).delete();
  }

  // ==============================================================================
  // GESTIÓN DE CLIENTES
  // ==============================================================================

  Stream<List<Cliente>> getClientes() {
    return _db.collection('clientes').orderBy('nombre').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Cliente.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> addCliente(Cliente cliente) {
    return _db.collection('clientes').add(cliente.toMap());
  }

  Future<void> updateCliente(Cliente cliente) {
    return _db.collection('clientes').doc(cliente.id).update(cliente.toMap());
  }

  Future<void> deleteCliente(String id) {
    return _db.collection('clientes').doc(id).delete();
  }

  // ==============================================================================
  // GESTIÓN DE PEDIDOS
  // ==============================================================================

  // Los pedidos se ordenan por fecha (el más reciente primero)
  Stream<List<Pedido>> getPedidos() {
    return _db
        .collection('pedidos')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Pedido.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> addPedido(Pedido pedido) {
    return _db.collection('pedidos').add(pedido.toMap());
  }

  Future<void> updatePedido(Pedido pedido) {
    return _db.collection('pedidos').doc(pedido.id).update(pedido.toMap());
  }

  Future<void> deletePedido(String id) {
    return _db.collection('pedidos').doc(id).delete();
  }
}