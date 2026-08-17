class UserModel {
    final String id;
    final String name;
    final String email;
    final String role;
    final String tenantId;

    UserModel({
        required this.id,
        required this.name,
        required this.email,
        required this.role,
        required this.tenantId,
    });

    factory UserModel.fromJson(Map<String, dynamic> json) {
        return UserModel(
            id: json['id'],
            name: json['name'],
            email: json['email'],
            role: json['role'],
            tenantId: json['tenantId'],
        );
    }
}

class LoginResponse {
    final String accessToken;
    final String refreshToken;
    final UserModel user;

    LoginResponse({
        required this.accessToken,
        required this.refreshToken,
        required this.user,
    });

    factory LoginResponse.fromJson(Map<String, dynamic> json) {
        return LoginResponse(
            accessToken: json['accessToken'],
            refreshToken: json['refreshToken'],
            user: UserModel.fromJson(json['user']),
        );
    }
    
}