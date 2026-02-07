class Producto {
  final String id;
  final String nombre;
  final String tipo; // 'deposito' o 'piscina'
  final double capacidad;
  final double precio;

  Producto({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.capacidad,
    required this.precio,
  });

  // Convierte un objeto Producto a un Mapa (para guardar en Firestore)
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'tipo': tipo,
      'capacidad': capacidad,
      'precio': precio,
    };
  }

  // Crea un objeto Producto desde un Mapa (al leer de Firestore)
  factory Producto.fromMap(Map<String, dynamic> map, String id) {
    return Producto(
      id: id,
      nombre: map['nombre'] ?? '',
      tipo: map['tipo'] ?? 'deposito',
      // Aseguramos que los números se lean correctamente incluso si vienen como int
      capacidad: (map['capacidad'] ?? 0).toDouble(),
      precio: (map['precio'] ?? 0).toDouble(),
    );
  }
}