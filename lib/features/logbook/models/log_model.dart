class LogModel {
  final String title;
  final String description;
  final String timestamp;

  LogModel({
    required this.title,
    required this.description,
    required this.timestamp,
  });

  // Opsional (belum wajib di Task 2, tapi aman buat lanjut Task 4 nanti)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'timestamp': timestamp,
    };
  }

  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      title: map['title'],
      description: map['description'],
      timestamp: map['timestamp'],
    );
  }
}