import 'package:cloud_firestore/cloud_firestore.dart';

class Pedido {
  String id;
  String clienteId;
  String productoId;
  DateTime fecha;
  String estado; // Ej: "Pendiente", "En proceso", "Finalizado"

  Pedido({
    required this.id,
    required this.clienteId,
    required this.productoId,
    required this.fecha,
    required this.estado,
  });

  // Convertir a Map para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'productoId': productoId,
      'fecha': Timestamp.fromDate(fecha), // Firestore usa Timestamp
      'estado': estado,
    };
  }

  // Crear objeto Pedido desde Firestore
  factory Pedido.fromMap(Map<String, dynamic> map, String documentId) {
    return Pedido(
      id: documentId,
      clienteId: map['clienteId'] ?? '',
      productoId: map['productoId'] ?? '',
      // Si hay fecha la convertimos, si no, usamos la fecha actual por seguridad
      fecha: map['fecha'] != null 
          ? (map['fecha'] as Timestamp).toDate() 
          : DateTime.now(),
      estado: map['estado'] ?? 'Pendiente',
    );
  }
}