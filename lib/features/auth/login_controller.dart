class LoginController {
  // Database sederhana: multiple users
  final Map<String, String> _users = {
    'admin': '123',
    'budi': '456',
  };

  bool login(String username, String password) {
    if (!_users.containsKey(username)) return false;
    return _users[username] == password;
  }
}
