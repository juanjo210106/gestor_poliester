import 'package:cloud_firestore/cloud_firestore.dart';

class Pedido {
  final String id;
  final String clienteId;
  final String productoId;
  final DateTime fecha;
  final String estado; // Ejemplo: "pendiente", "entregado"

  Pedido({
    required this.id,
    required this.clienteId,
    required this.productoId,
    required this.fecha,
    required this.estado,
  });

  // Convertir a Mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'productoId': productoId,
      'fecha': Timestamp.fromDate(fecha), // Convertimos DateTime a Timestamp de Firestore
      'estado': estado,
    };
  }

  // Crear objeto desde Firestore
  factory Pedido.fromMap(Map<String, dynamic> map, String id) {
    return Pedido(
      id: id,
      clienteId: map['clienteId'] ?? '',
      productoId: map['productoId'] ?? '',
      // Convertimos Timestamp de Firestore de vuelta a DateTime
      // Si por error no hay fecha, ponemos la fecha actual
      fecha: (map['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estado: map['estado'] ?? 'pendiente',
    );
  }
}