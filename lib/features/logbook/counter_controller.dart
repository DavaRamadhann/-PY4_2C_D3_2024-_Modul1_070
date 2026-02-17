import 'package:shared_preferences/shared_preferences.dart';

class CounterController {
  int _counter = 0;
  int _step = 1;

  List<String> _history = [];

  int get value => _counter;
  int get step => _step;
  List<String> get history => List.unmodifiable(_history);

  // Key unik per user
  String _counterKey(String username) => 'last_counter_$username';
  String _historyKey(String username) => 'history_$username';
  String _stepKey(String username) => 'step_$username';

  void setStep(int newStep) {
    if (newStep > 0) {
      _step = newStep;
    }
  }

  void increment(String username) {
    _counter += _step;
    _addHistory(username, "+$_step");
    _saveAll(username);
  }

  void decrement(String username) {
    _counter -= _step;
    _addHistory(username, "-$_step");
    _saveAll(username);
  }

  void reset(String username) {
    _counter = 0;
    _addHistory(username, "Reset");
    _saveAll(username);
  }

  void _addHistory(String username, String action) {
    final time = DateTime.now().toString().substring(11, 19);
    _history.insert(0, "User $username: $action @ $time");

    if (_history.length > 5) {
      _history.removeLast();
    }
  }

  // ================== PERSISTENCE ==================

  Future<void> _saveAll(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_counterKey(username), _counter);
    await prefs.setInt(_stepKey(username), _step);
    await prefs.setStringList(_historyKey(username), _history);
  }

  Future<void> loadAll(String username) async {
    final prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt(_counterKey(username)) ?? 0;
    _step = prefs.getInt(_stepKey(username)) ?? 1;
    _history = prefs.getStringList(_historyKey(username)) ?? [];
  }
}
