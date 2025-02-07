abstract class IAuthService {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password, {
    String? gender,
    int? age,
    String? mobileNumber,
    String? profileImagePath,
  });
  Future<int> verifyToken(String token);
  Future<void> logout(String token);
}
