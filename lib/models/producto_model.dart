class Producto {
  String id;
  String nombre;
  String tipo; // "depósito" o "piscina"
  double capacidad; // En litros
  double precio; // En euros

  Producto({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.capacidad,
    required this.precio,
  });

  // Método para convertir nuestros datos a un formato que Firestore entiende (Map)
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'tipo': tipo,
      'capacidad': capacidad,
      'precio': precio,
    };
  }

  // Constructor tipo 'factory' para crear un Producto desde los datos de Firestore
  factory Producto.fromMap(Map<String, dynamic> map, String documentId) {
    return Producto(
      id: documentId,
      nombre: map['nombre'] ?? '',
      tipo: map['tipo'] ?? 'depósito',
      // Nos aseguramos de convertir a double por si Firestore devuelve un int
      capacidad: (map['capacidad'] ?? 0).toDouble(),
      precio: (map['precio'] ?? 0).toDouble(),
    );
  }
}