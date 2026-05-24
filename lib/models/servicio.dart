class Servicio {
  final int id;
  final String nombre;
  final String descripcion;
  final int duracionMinutos;
  final double precio;
  final bool activo;

  Servicio({required this.id, required this.nombre, required this.descripcion, required this.duracionMinutos, required this.precio, required this.activo});

  factory Servicio.fromMap(Map<String, dynamic> json) {
    final precioVal = json['precio'];
    double precioDouble = 0.0;
    if (precioVal != null) {
      if (precioVal is num) {
        precioDouble = precioVal.toDouble();
      } else {
        precioDouble = double.tryParse('$precioVal') ?? 0.0;
      }
    }

    return Servicio(
      id: (json['id'] as num).toInt(),
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      duracionMinutos: (json['duracionMinutos'] as num?)?.toInt() ?? 30,
      precio: precioDouble,
      activo: json['activo'] ?? true,
    );
  }
}
