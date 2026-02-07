class Cliente {
  final String id;
  final String nombre;
  final String email;
  final String telefono;

  Cliente({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
  });

  // Convertir a Mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
    };
  }

  // Crear objeto desde Firestore
  factory Cliente.fromMap(Map<String, dynamic> map, String id) {
    return Cliente(
      id: id,
      nombre: map['nombre'] ?? '',
      email: map['email'] ?? '',
      telefono: map['telefono'] ?? '',
    );
  }
}