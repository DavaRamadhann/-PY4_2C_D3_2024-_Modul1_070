import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:logbook_app_070/features/logbook/models/log_model.dart';
import 'package:logbook_app_070/features/logbook/log_controller.dart';

class LogEditorPage extends StatefulWidget {
  final LogModel? log;
  final int? index;
  final LogController controller;
  final dynamic currentUser;

  const LogEditorPage({
    super.key,
    this.log,
    this.index,
    required this.controller,
    required this.currentUser,
  });

  @override
  State<LogEditorPage> createState() => _LogEditorPageState();
}

class _LogEditorPageState extends State<LogEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  bool _isPublic = false;
  String _category = 'Umum';
  
  final List<String> _categories = ['Umum', 'Mechanical', 'Electronic', 'Software'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.log?.title ?? '');
    _descController = TextEditingController(text: widget.log?.description ?? '');
    _isPublic = widget.log?.isPublic ?? false;
    _category = widget.log?.category ?? 'Umum';

    // Pastikan kategori ada di pilihan, jika tidak fallback ke Umum
    if (!_categories.contains(_category)) {
      _category = 'Umum';
    }

    _descController.addListener(() {
      setState(() {});
    });
  }

  void _save() {
    if (widget.log == null) {
      widget.controller.addLog(
        title: _titleController.text,
        description: _descController.text,
        authorId: widget.currentUser['uid'],
        teamId: widget.currentUser['teamId'],
        isPublic: _isPublic,
        category: _category,
      );
    } else {
      widget.controller.updateLog(
        index: widget.index!,
        title: _titleController.text,
        description: _descController.text,
        isPublic: _isPublic,
        category: _category,
      );
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: Text(widget.log == null ? "Catatan Baru" : "Edit Catatan"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Editor"),
              Tab(text: "Pratinjau"),
            ],
            indicatorColor: Colors.tealAccent,
            labelColor: Colors.tealAccent,
            unselectedLabelColor: Colors.white54,
          ),
          actions: [
            IconButton(icon: const Icon(Icons.save), onPressed: _save)
          ],
        ),
        body: TabBarView(
          children: [
            // Tab 1: Editor
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Judul",
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _category,
                    dropdownColor: const Color(0xFF1E2A38),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Kategori Bidang",
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                    items: _categories.map((String cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _category = newValue;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Jadikan Publik?", style: TextStyle(color: Colors.white70)),
                      Switch(
                        value: _isPublic,
                        activeColor: Colors.tealAccent,
                        onChanged: (val) {
                          setState(() {
                            _isPublic = val;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _descController,
                        maxLines: null,
                        expands: true,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          hintText: "Tulis laporan dengan format Markdown...",
                          hintStyle: TextStyle(color: Colors.white30),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Tab 2: Markdown Preview
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF121212),
              child: Markdown(
                data: _descController.text,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(color: Colors.white70),
                  h1: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  h2: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold),
                  code: const TextStyle(backgroundColor: Colors.black45, color: Colors.greenAccent),
                  codeblockDecoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
