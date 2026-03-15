import 'package:hive/hive.dart';

class AuthLocalService {
  static final Box usersBox = Hive.box('users');

  static Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    final existingUserKey = usersBox.keys.cast<dynamic>().firstWhere((key) {
      final user = usersBox.get(key);
      return user != null &&
          user['email']?.toString().toLowerCase() == normalizedEmail;
    }, orElse: () => null);

    if (existingUserKey != null) {
      return 'Email already exists';
    }

    await usersBox.add({
      'name': name.trim(),
      'email': normalizedEmail,
      'password': password,
      'createdAt': DateTime.now().toIso8601String(),
    });

    return null;
  }

  static bool login({required String email, required String password}) {
    final normalizedEmail = email.trim().toLowerCase();

    for (final key in usersBox.keys) {
      final user = usersBox.get(key);
      if (user != null &&
          user['email']?.toString().toLowerCase() == normalizedEmail &&
          user['password']?.toString() == password) {
        return true;
      }
    }
    return false;
  }
}
