class LogModel {
  final String title;
  final String description;
  final String category;
  final DateTime timestamp;

  LogModel({
    required this.title,
    required this.description,
    required this.category,
    required this.timestamp,
  });

  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Pribadi', 
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}