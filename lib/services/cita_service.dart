import 'package:dio/dio.dart';

import 'api_client.dart' as api_client;

class CitaService {
  final Dio _dio;

  CitaService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: api_client.ApiClient().dio.options.baseUrl,
                headers: const {'Content-Type': 'application/json'},
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            );

  Future<Map<String, dynamic>> agendarCita({
    required String nombreCliente,
    required String fecha,
    required String hora,
    required String servicio,
  }) async {
    final barberoId = await _obtenerBarberoPredeterminado();

    final response = await _dio.post(
      '/citas',
      data: {
        'barberId': barberoId,
        'clientName': nombreCliente,
        'clientPhone': '',
        'service': servicio,
        'date': fecha,
        'startTime': hora,
        'duration': 30,
      },
    );

    final body = response.data;
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return body;
    }

    if (body is Map) {
      return Map<String, dynamic>.from(body);
    }

    return <String, dynamic>{};
  }

  Future<int> _obtenerBarberoPredeterminado() async {
    final response = await _dio.get('/barberos');
    final barberos = api_client.normalizeArrayResponse<dynamic>(response.data);

    if (barberos.isEmpty) {
      throw Exception('No hay barberos disponibles para agendar la cita');
    }

    final primero = barberos.first;
    if (primero is Map<String, dynamic>) {
      final id = primero['id'];
      if (id is num) {
        return id.toInt();
      }
      return int.parse('$id');
    }

    if (primero is Map) {
      final id = primero['id'];
      if (id is num) {
        return id.toInt();
      }
      return int.parse('$id');
    }

    throw Exception('No se pudo obtener un barbero válido');
  }
}
