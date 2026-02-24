import 'package:flutter/material.dart';
import 'log_controller.dart';
import 'models/log_model.dart';

class DailyLoggerView extends StatefulWidget {
  const DailyLoggerView({super.key});

  @override
  State<DailyLoggerView> createState() => _DailyLoggerViewState();
}

class _DailyLoggerViewState extends State<DailyLoggerView> {
  final LogController _controller = LogController();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  void _showAddLogDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Catatan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "Judul"),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(hintText: "Deskripsi"),
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
              if (_titleController.text.isEmpty ||
                  _descController.text.isEmpty) {
                return;
              }

              setState(() {
                _controller.addLog(
                  _titleController.text,
                  _descController.text,
                );
              });

              _titleController.clear();
              _descController.clear();
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _showEditLogDialog(int index, LogModel log) {
    _titleController.text = log.title;
    _descController.text = log.description;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Catatan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _titleController),
            TextField(controller: _descController),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _controller.updateLog(
                  index,
                  _titleController.text,
                  _descController.text,
                );
              });

              _titleController.clear();
              _descController.clear();
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Logger"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLogDialog,
        child: const Icon(Icons.add),
      ),
      body: _controller.logs.isEmpty
          ? const Center(child: Text("Belum ada catatan."))
          : ListView.builder(
              itemCount: _controller.logs.length,
              itemBuilder: (context, index) {
                final log = _controller.logs[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(log.title),
                    subtitle: Text(log.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditLogDialog(index, log),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _controller.removeLog(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}