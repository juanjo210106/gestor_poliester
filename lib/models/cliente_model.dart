class Cliente {
  String id;
  String nombre;
  String email;
  String telefono;

  Cliente({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
  });

  // Convertir a Map para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
    };
  }

  // Crear objeto Cliente desde Firestore
  factory Cliente.fromMap(Map<String, dynamic> map, String documentId) {
    return Cliente(
      id: documentId,
      nombre: map['nombre'] ?? '',
      email: map['email'] ?? '',
      telefono: map['telefono'] ?? '',
    );
  }
}