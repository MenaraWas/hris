import 'package:dio/dio.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/storage/secure_storage.dart';
import '../domain/auth_model.dart';

class AuthRepository {
    final Dio _dio = DioClient.instance;

    Future<LoginResponse> login({
        required String email, 
        required String password,
        required String slug, 
    })async {
        try {
            final response = await _dio.post(
                ApiEndpoints.login,
                data: {
                    'email': email,
                    'password': password,
                    'slug': slug,
                },
            );

            final loginResponse = LoginResponse.fromJson(response.data['data']);

            // simpan token dan data user ke secure storage
            await SecureStorage.saveAccessToken(loginResponse.accessToken);
            await SecureStorage.saveRefreshToken(loginResponse.refreshToken);
            await SecureStorage.saveUserData(
                userId: loginResponse.user.id,
                tenantId: loginResponse.user.tenantId,
                role: loginResponse.user.role,
                name: loginResponse.user.name,
                email: loginResponse.user.email,
            );

            return loginResponse;
        } on DioException catch (e) {
            final message = e.response?.data['message'] ?? 'Terjadi Kesalahan';
            throw Exception(message);
        }
    }

    Future<void> logout() async {
        try {
            await _dio.post(ApiEndpoints.logout);
        } catch (_) {
            
        } finally {
            await SecureStorage.clearAll();
        }
    }
}