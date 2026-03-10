class LoginController {
  final Map<String, Map<String, dynamic>> _users = {
    'dava': {
      'password': '123',
      'uid': 'user-dava',
      'role': 'Ketua',
      'teamId': 'tim-alpha',
    },
    'budi': {
      'password': '123',
      'uid': 'user-budi',
      'role': 'Anggota',
      'teamId': 'tim-alpha',
    },
    'tono': {
      'password': '123',
      'uid': 'user-tono',
      'role': 'Anggota',
      'teamId': 'tim-beta',
    },
  };

  Map<String, dynamic>? login(String username, String password) {
    if (!_users.containsKey(username)) return null;
    if (_users[username]!['password'] == password) {
      return _users[username];
    }
    return null;
  }
}
