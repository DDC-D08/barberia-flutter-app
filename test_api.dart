import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8080',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5)
  ));

  try {
    print('Intentando conectar al backend en localhost:8080...');
    final response = await dio.post('/api/auth/login', data: {
      'email': 'admin@barberia.com',
      'password': 'admin123'
    });
    print('Exito! Status code: ${response.statusCode}');
    print('Data: ${response.data}');
  } on DioException catch (e) {
    print('DioException caught:');
    print(e.toString());
    if (e.response != null) {
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');
    } else {
      print('Network error or connection refused.');
    }
  } catch (e) {
    print('Error: $e');
  }
}
