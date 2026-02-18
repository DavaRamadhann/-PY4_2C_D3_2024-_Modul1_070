import 'package:flutter/material.dart';
import 'package:logbook_app_070/features/logbook/counter_controller.dart';
import 'package:logbook_app_070/features/onboarding/onboarding_view.dart';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ===== Welcome Banner (UX) =====
  String _getWelcomeMessage(String username) {
    final hour = DateTime.now().hour;

    String greet;
    if (hour >= 6 && hour < 11) {
      greet = "Selamat Pagi";
    } else if (hour >= 11 && hour < 15) {
      greet = "Selamat Siang";
    } else if (hour >= 15 && hour < 18) {
      greet = "Selamat Sore";
    } else {
      greet = "Selamat Malam";
    }

    return "$greet, $username 👋";
  }

  Future<void> _loadData() async {
    await _controller.loadAll(widget.username);
    _stepController.text = _controller.step.toString();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Logbook: ${widget.username}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Konfirmasi Logout"),
                    content: const Text("Yakin mau keluar?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Batal"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OnboardingView(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          "Keluar",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ===== Welcome Banner (dipakai di UI) =====
            Text(
              _getWelcomeMessage(widget.username),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

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
                setState(() {
                  _controller.setStep(step);
                });
              },
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _controller.increment(widget.username);
                    });
                  },
                  child: const Text("+"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _controller.decrement(widget.username);
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
                                Navigator.pop(context);
                              },
                              child: const Text("Batal"),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _controller.reset(widget.username);
                                });
                                Navigator.pop(context);

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
              child: _controller.history.isEmpty
                  ? const Center(child: Text("Belum ada aktivitas"))
                  : ListView(
                      children: _controller.history.map((e) {
                        Color color = Colors.black;

                        if (e.contains("+")) {
                          color = Colors.green;
                        } else if (e.contains("-")) {
                          color = Colors.red;
                        } else if (e.contains("Reset")) {
                          color = Colors.grey;
                        }

                        return ListTile(
                          leading: const Icon(Icons.history),
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
