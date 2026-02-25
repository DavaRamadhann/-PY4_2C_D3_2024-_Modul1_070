import 'dart:ui'; // Penting untuk efek Blur
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_view.dart';
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
  final TextEditingController _searchController = TextEditingController();

  // State untuk Search dan Kategori
  String _searchQuery = "";
  String _selectedCategory = "Pribadi";
  final List<String> _categories = ["Pribadi", "Pekerjaan", "Urgent"];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- HELPER WARNA KATEGORI (Disesuaikan dengan Tema Gelap) ---
  Color _getCategoryBadgeColor(String category) {
    switch (category) {
      case 'Urgent': return Colors.redAccent.shade100;
      case 'Pekerjaan': return Colors.lightBlueAccent.shade100;
      default: return Colors.tealAccent.shade100;
    }
  }

  // --- LOGOUT DIALOG ---
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A38).withOpacity(0.9), // Glassy dark
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.1))),
        title: const Text("Tutup Jurnal?", style: TextStyle(color: Colors.white, fontFamily: 'Serif')),
        content: const Text("Apakah Anda ingin menyimpan pena dan keluar?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Lanjut Menulis", style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('username');
              if (!mounted) return;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginView()));
            },
            child: const Text("Tutup Buku", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  // --- INPUT/EDIT DIALOG ---
  void _showLogDialog({LogModel? existingLog, int? index}) {
    _titleController.text = existingLog?.title ?? "";
    _descController.text = existingLog?.description ?? "";
    _selectedCategory = existingLog?.category ?? "Pribadi";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: AlertDialog(
                backgroundColor: const Color(0xFF0F2027).withOpacity(0.8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.white.withOpacity(0.2))),
                title: Text(
                  existingLog == null ? "Halaman Baru" : "Edit Tulisan",
                  style: const TextStyle(color: Colors.white, fontFamily: 'Serif', fontWeight: FontWeight.bold),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Judul",
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Isi Cerita",
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      dropdownColor: const Color(0xFF1E2A38),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Kategori",
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)), borderRadius: BorderRadius.circular(10)),
                      ),
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (newValue) => setState(() => _selectedCategory = newValue!),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal", style: TextStyle(color: Colors.white54))),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      if (_titleController.text.isEmpty || _descController.text.isEmpty) return;
                      if (existingLog == null) {
                        _controller.addLog(_titleController.text, _descController.text, _selectedCategory);
                      } else {
                        _controller.updateLog(index!, _titleController.text, _descController.text, _selectedCategory);
                      }
                      _titleController.clear();
                      _descController.clear();
                      Navigator.pop(context);
                    },
                    child: const Text("Simpan"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Journal Entries", style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.bold, letterSpacing: 1)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app_rounded, color: Colors.white70),
            onPressed: _showLogoutDialog,
            tooltip: "Logout",
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. BACKGROUND GRADIENT (Sama dengan Login)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F2027), // Deep Dark Blue
                  Color(0xFF203A43), // Mid Dark
                  Color(0xFF2C5364), // Lighter Blue/Teal hint
                ],
              ),
            ),
          ),

          // 2. ORNAMEN BACKGROUND
          Positioned(
            top: 100,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.tealAccent.withOpacity(0.1),
                boxShadow: [BoxShadow(color: Colors.tealAccent.withOpacity(0.2), blurRadius: 100, spreadRadius: 20)],
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: -30,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withOpacity(0.1),
                boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.15), blurRadius: 100, spreadRadius: 20)],
              ),
            ),
          ),

          // 3. KONTEN UTAMA
          SafeArea(
            child: Column(
              children: [
                // SEARCH BAR GLASSMORPHISM
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _searchQuery = value),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Cari kenangan...",
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1), // Transparan
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ),
                ),

                // LIST LOGBOOK
                Expanded(
                  child: ValueListenableBuilder<List<LogModel>>(
                    valueListenable: _controller.logsNotifier,
                    builder: (context, logs, child) {
                      final filteredLogs = logs.where((log) =>
                          log.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

                      // EMPTY STATE
                      if (filteredLogs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history_edu_rounded, size: 80, color: Colors.white.withOpacity(0.2)),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty ? "Halaman ini masih kosong." : "Tidak ditemukan.",
                                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 16),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 80), // Bottom padding for FAB
                        itemCount: filteredLogs.length,
                        itemBuilder: (context, index) {
                          final log = filteredLogs[index];
                          final originalIndex = logs.indexOf(log);

                          return Dismissible(
                            key: Key(log.timestamp.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              margin: const EdgeInsets.only(bottom: 15),
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: const Color(0xFF1E2A38),
                                  title: const Text("Hapus?", style: TextStyle(color: Colors.white)),
                                  content: const Text("Kenangan ini akan dihapus selamanya.", style: TextStyle(color: Colors.white70)),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal", style: TextStyle(color: Colors.white54))),
                                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Hapus", style: TextStyle(color: Colors.redAccent))),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (direction) {
                              final deletedLog = log;
                              final deletedIndex = originalIndex;
                              _controller.deleteLog(originalIndex);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text("Catatan dihapus"),
                                  backgroundColor: const Color(0xFF203A43),
                                  action: SnackBarAction(
                                    label: "UNDO",
                                    textColor: Colors.tealAccent,
                                    onPressed: () => _controller.undoDelete(deletedIndex, deletedLog),
                                  ),
                                ),
                              );
                            },
                            // CARD ITEM DESIGN
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05), // Ultra transparent
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.bookmark_border_rounded,
                                    color: _getCategoryBadgeColor(log.category),
                                  ),
                                ),
                                title: Text(
                                  log.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 6),
                                    Text(
                                      log.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.white.withOpacity(0.6)),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Icon(Icons.access_time_rounded, size: 12, color: Colors.white.withOpacity(0.4)),
                                        const SizedBox(width: 4),
                                        Text(
                                          DateFormat('dd MMM, HH:mm').format(log.timestamp),
                                          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4)),
                                        ),
                                        const Spacer(),
                                        // Category Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: _getCategoryBadgeColor(log.category).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: _getCategoryBadgeColor(log.category).withOpacity(0.3)),
                                          ),
                                          child: Text(
                                            log.category.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: _getCategoryBadgeColor(log.category),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                onTap: () => _showLogDialog(existingLog: log, index: originalIndex),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLogDialog(),
        backgroundColor: Colors.white, // Putih kontras
        foregroundColor: const Color(0xFF0F2027), // Icon gelap
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.create_rounded),
      ),
    );
  }
}