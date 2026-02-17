import 'package:flutter/material.dart';
import 'counter_controller.dart';

class CounterView extends StatefulWidget {
  final String username; // Wajib diisi dari LoginView

  const CounterView({
    super.key,
    required this.username,
  });

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();
  final TextEditingController _stepController = TextEditingController(text: "1");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Task 1 - Multi Step Counter")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Nilai Counter:"),
            Text(
              '${_controller.value}',
              style: const TextStyle(fontSize: 40),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _stepController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Step",
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                final step = int.tryParse(val) ?? 1;
                _controller.setStep(step);
              },
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _controller.increment();
                    });
                  },
                  child: const Text("+"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _controller.decrement();
                    });
                  },
                  child: const Text("-"),
                ),
                ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Konfirmasi Reset"),
                        content: const Text("Yakin mau reset counter?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // tutup dialog
                            },
                            child: const Text("Batal"),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _controller.reset();
                              });
                              Navigator.pop(context); // tutup dialog

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Counter berhasil direset"),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: const Text("Ya"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text("Reset"),
              ),

              ],
            ),
            const SizedBox(height: 24),
            const Text("History (5 terakhir):"),
            const SizedBox(height: 8),

            Expanded(
              child: ListView(
                children: _controller.history.map((e) {
                  Color color = Colors.black;

                  if (e.startsWith("+")) {
                    color = Colors.green;
                  } else if (e.startsWith("-")) {
                    color = Colors.red;
                  } else if (e.startsWith("Reset")) {
                    color = Colors.grey;
                  }

                  return ListTile(
                    title: Text(
                      e,
                      style: TextStyle(color: color),
                    ),
                  );
                }).toList(),
              ),
            ),


          ],
        ),
      ),
    );
  }
}
