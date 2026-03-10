import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_view.dart';
import 'models/log_model.dart';
import 'log_controller.dart';
import '../../services/mongo_service.dart';
import '../../helpers/log_helper.dart';
import '../../services/access_control_service.dart';
import 'log_editor_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class LogView extends StatefulWidget {
  final dynamic currentUser;

  const LogView({super.key, required this.currentUser});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  late final LogController _controller;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = "";
  bool _isLoading = false;
  bool _isOffline = false;
  StreamSubscription<dynamic>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _controller = LogController();
    Future.microtask(() => _initDatabase());

    // Listener Koneksi
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((dynamic result) {
      bool isNowOffline = _checkIfOffline(result);
      
      // Jika dari offline menjadi online lagi
      if (_isOffline && !isNowOffline) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text("Terhubung kembali! Mensinkronkan data..."), backgroundColor: Colors.green),
           );
         }
         Future.microtask(() => _initDatabase());
      }
      
      if (mounted) {
        setState(() => _isOffline = isNowOffline);
      }
    });
  }

  bool _checkIfOffline(dynamic result) {
    if (result is List) {
      return result.contains(ConnectivityResult.none) || result.isEmpty;
    } else {
      return result == ConnectivityResult.none;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Mechanical':
        return Colors.greenAccent;
      case 'Electronic':
        return Colors.blueAccent;
      case 'Software':
        return Colors.deepPurpleAccent;
      case 'Umum':
      default:
        return Colors.white70;
    }
  }

  Future<void> _initDatabase() async {
    setState(() => _isLoading = true);
    try {
      try {
        await MongoService().connect().timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw Exception(
            "Koneksi Cloud Timeout. Mode Offline Diaktifkan.",
          ),
        );
      } catch (e) {
        // Abaikan pelemparan error koneksi UI di sini karena Banner Offline sudah mengurusnya.
      }

      await _controller.loadLogs(widget.currentUser['teamId']);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Masalah: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A38).withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        title: const Text(
          "Tutup Jurnal?",
          style: TextStyle(color: Colors.white, fontFamily: 'Serif'),
        ),
        content: const Text(
          "Apakah Anda ingin menyimpan pena dan keluar?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Lanjut Menulis",
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('username');
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginView()),
              );
            },
            child: const Text(
              "Tutup Buku",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _goToEditor({LogModel? log, int? index}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogEditorPage(
          log: log,
          index: index,
          controller: _controller,
          currentUser: widget.currentUser,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Logbook (${widget.currentUser['role']})",
          style: const TextStyle(
            fontFamily: 'Serif',
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: Colors.white,
          ),
        ),
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
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF203A43),
                  Color(0xFF2C5364),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                if (_isOffline)
                  Container(
                    width: double.infinity,
                    color: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Center(
                      child: Text(
                        "⚠ Anda sedang dalam Mode Offline",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Cari kenangan...",
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ValueListenableBuilder<List<LogModel>>(
                    valueListenable: _controller.logsNotifier,
                    builder: (context, logs, child) {
                      if (_isLoading) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Membuka Catatan...",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final filteredLogs = logs.where((log) {
                        final bool matchesSearch = log.title
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase());
                        
                        final bool isOwner = log.authorId == widget.currentUser['uid'];
                        // Gatekeeper Read Access check
                        final bool canSee = AccessControlService.canPerform(
                          widget.currentUser['role'], 
                          AccessControlService.actionRead, 
                          isOwner: isOwner, 
                          isPublic: log.isPublic
                        );

                        return matchesSearch && canSee;
                      }).toList();

                      if (filteredLogs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.cloud_off,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Belum ada catatan di tim ini.",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _goToEditor(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(
                                    0.2,
                                  ),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text("Buat Catatan Pertama"),
                              ),
                            ],
                          ),
                        );
                      }

                      // Using ListView
                      return RefreshIndicator(
                        onRefresh: () => _controller.loadLogs(widget.currentUser['teamId']),
                        color: Colors.blueAccent,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                          itemCount: filteredLogs.length,
                          itemBuilder: (context, index) {
                            final log = filteredLogs[index];
                            final originalIndex = logs.indexOf(log);

                            final bool isOwner = log.authorId == widget.currentUser['uid'];
                            final bool canDelete = AccessControlService.canPerform(widget.currentUser['role'], AccessControlService.actionDelete, isOwner: isOwner);
                            final bool canEdit = AccessControlService.canPerform(widget.currentUser['role'], AccessControlService.actionUpdate, isOwner: isOwner);

                            Widget listTile = ListTile(
                              contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(log.category).withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: _getCategoryColor(log.category)),
                                  ),
                                  child: Icon(
                                    log.id != null ? Icons.cloud_done : Icons.cloud_upload_outlined,
                                    color: _getCategoryColor(log.category),
                                  ),
                                ),
                                title: Wrap(
                                  spacing: 8,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                     Text(
                                       log.title,
                                       style: const TextStyle(
                                         fontWeight: FontWeight.bold,
                                         color: Colors.white,
                                         fontSize: 16,
                                       ),
                                     ),
                                     Container(
                                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                       decoration: BoxDecoration(
                                         color: _getCategoryColor(log.category).withOpacity(0.15),
                                         borderRadius: BorderRadius.circular(8),
                                       ),
                                       child: Text(
                                         log.category,
                                         style: TextStyle(
                                           color: _getCategoryColor(log.category),
                                           fontSize: 10,
                                           fontWeight: FontWeight.bold,
                                         ),
                                       ),
                                     ),
                                  ]
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      log.date,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      log.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Icon(
                                          log.isPublic ? Icons.public : Icons.lock,
                                          size: 14,
                                          color: Colors.white.withOpacity(0.5),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          log.isPublic ? "Public" : "Private",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white.withOpacity(0.5),
                                          ),
                                        ),
                                        const Spacer(),
                                      ],
                                    ),
                                  ],
                                ),
                                onTap: canEdit ? () => _goToEditor(log: log, index: originalIndex) : null,
                            );

                            Widget container = Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _getCategoryColor(log.category).withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: listTile,
                            );

                            if (canDelete) {
                              return Dismissible(
                                key: Key(log.id?.toString() ?? log.hashCode.toString()),
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
                                      content: const Text("Catatan ini akan dihapus selamanya.", style: TextStyle(color: Colors.white70)),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal", style: TextStyle(color: Colors.white54))),
                                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Hapus", style: TextStyle(color: Colors.redAccent))),
                                      ],
                                    ),
                                  );
                                },
                                onDismissed: (direction) {
                                  _controller.removeLog(originalIndex);
                                },
                                child: container,
                              );
                            }

                            return container;

                          },
                        ),
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
        onPressed: () => _goToEditor(),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F2027),
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.create_rounded),
      ),
    );
  }
}
