import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://10.255.255.1:8080', // Simulate unreachable IP / wrong network alias
    connectTimeout: const Duration(seconds: 2),
    receiveTimeout: const Duration(seconds: 2)
  ));

  try {
    print('Intentando conectar al backend en 10.255.255.1:8080 (Simulando emulador)...');
    final response = await dio.post('/api/auth/login', data: {
      'email': 'admin@barberia.com',
      'password': 'admin123'
    });
    print('Exito! Status code: ${response.statusCode}');
  } on DioException catch (e) {
    print('DioException caught:');
    print(e.toString());
  }
}
