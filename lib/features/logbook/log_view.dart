import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Pastikan package ini ada di pubspec.yaml
import '../auth/login_view.dart'; // Import halaman login
import 'models/log_model.dart';
import 'log_controller.dart';

class LogView extends StatefulWidget {
  const LogView({super.key});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final LogController _controller = LogController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // --- LOGIC: LOGOUT ---
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Tutup dialog
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog dulu
              await _performLogout();
            },
            child: const Text("Ya, Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    // 1. Hapus data session (Username/Token) dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username'); // Sesuaikan dengan key yang kamu pakai di Login
    // await prefs.clear(); // Gunakan ini jika ingin menghapus SEMUA data aplikasi

    // 2. Navigasi kembali ke LoginView dan hapus history route sebelumnya
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
    );
  }

  // --- LOGIC: CRUD DIALOG ---
  void _showLogDialog({LogModel? existingLog, int? index}) {
    _titleController.text = existingLog?.title ?? "";
    _descController.text = existingLog?.description ?? "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existingLog == null ? "Tambah Log" : "Edit Log"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Judul"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(labelText: "Deskripsi"),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isEmpty || _descController.text.isEmpty) return;

                if (existingLog == null) {
                  _controller.addLog(_titleController.text, _descController.text);
                } else {
                  _controller.updateLog(index!, _titleController.text, _descController.text);
                }

                _titleController.clear();
                _descController.clear();
                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Logbook App"),
        actions: [
          // TOMBOL LOGOUT DI APPBAR
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutDialog,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: ValueListenableBuilder<List<LogModel>>(
        valueListenable: _controller.logsNotifier,
        builder: (context, logs, child) {
          if (logs.isEmpty) {
            return const Center(child: Text("Belum ada catatan logbook."));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.note),
                  ),
                  title: Text(
                    log.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${log.description}\n${DateFormat('dd MMM yyyy, HH:mm').format(log.timestamp)}",
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showLogDialog(existingLog: log, index: index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _controller.deleteLog(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLogDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}