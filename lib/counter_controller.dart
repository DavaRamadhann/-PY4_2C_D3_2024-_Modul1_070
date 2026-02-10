class CounterController {
  int _counter = 0;
  int _step = 1;

  final List<String> _history = [];

  int get value => _counter;
  int get step => _step;

  List<String> get history => List.unmodifiable(_history);

  void setStep(int newStep) {
    if (newStep > 0) {
      _step = newStep;
    }
  }

  void increment() {
    _counter += _step;
    _addHistory("+$_step");
  }

  void decrement() {
    _counter -= _step;
    _addHistory("-$_step");
  }

  void reset() {
    _counter = 0;
    _addHistory("Reset");
  }

  void _addHistory(String action) {
    final time = DateTime.now().toString().substring(11, 19);
    _history.insert(0, "$action @ $time");

    if (_history.length > 5) {
      _history.removeLast();
    }
  }
}
