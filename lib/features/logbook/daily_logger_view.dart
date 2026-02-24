import 'package:flutter/material.dart';
import 'package:logbook_app_070/features/logbook/log_model.dart';
import 'package:intl/intl.dart';

class DailyLoggerView extends StatefulWidget {
  const DailyLoggerView({super.key});

  @override
  State<DailyLoggerView> createState() => _DailyLoggerViewState();
}

class _DailyLoggerViewState extends State<DailyLoggerView> {
  final List<LogModel> _logs = [];

  void _showLogDialog({LogModel? existingLog, int? index}) {
    final titleController = TextEditingController(text: existingLog?.title ?? "");
    final descController = TextEditingController(text: existingLog?.description ?? "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existingLog == null ? "Tambah Log Baru" : "Edit Log"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
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
                final title = titleController.text.trim();
                final desc = descController.text.trim();

                if (title.isEmpty || desc.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Title dan Description harus diisi!")),
                  );
                  return;
                }

                setState(() {
                  if (existingLog == null) {
                    // Tambah baru
                    _logs.add(LogModel(
                      title: title,
                      description: desc,
                      timestamp: DateTime.now(),
                    ));
                  } else {
                    // Edit yang sudah ada
                    _logs[index!] = LogModel(
                      title: title,
                      description: desc,
                      timestamp: DateTime.now(), // Update timestamp atau biarkan yang lama
                    );
                  }
                });

                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  void _deleteLog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Hapus Log"),
          content: const Text("Apakah Anda yakin ingin menghapus log ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _logs.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: const Text(
                "Hapus",
                style: TextStyle(color: Colors.red),
              ),
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
        title: const Text("The Daily Logger"),
      ),
      body: _logs.isEmpty
          ? const Center(
              child: Text(
                "Belum ada log. Tekan + untuk menambah.",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  elevation: 2,
                  child: ListTile(
                    title: Text(
                      log.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(log.description),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('dd MMM yyyy, HH:mm').format(log.timestamp),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
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
                          onPressed: () => _deleteLog(index),
                        ),
                      ],
                    ),
                  ),
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
