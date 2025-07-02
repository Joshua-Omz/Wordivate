class Word {
  final String id;
  final String text;
  final String pronunciation;
  final List<String> definitions;
  final List<String> examples;
  final String category;
  final String difficulty; // "beginner", "intermediate", "advanced"
  final DateTime timestamp;
  bool isFavorite;

  Word copyWith({
    String? id,
    String? text,
    String? pronunciation,
    List<String>? definitions,
    List<String>? examples,
    String? category,
    String? difficulty,
    DateTime? timestamp,
    bool? isFavorite,
  }) {
    return Word(
      id: id ?? this.id,
      text: text ?? this.text,
      pronunciation: pronunciation ?? this.pronunciation,
      definitions: definitions ?? this.definitions,
      examples: examples ?? this.examples,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Word({
    required this.id,
    required this.text,
    this.pronunciation = '',
    this.definitions = const [],
    this.examples = const [],
    this.category = '',
    this.difficulty = 'beginner',
    DateTime? timestamp,
    this.isFavorite = false,
  }) : this.timestamp = timestamp ?? DateTime.now();

  // Convert from JSON
  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] as String,
      text: json['text'] as String,
      pronunciation: json['pronunciation'] as String,
      definitions: List<String>.from(json['definitions']),
      examples: List<String>.from(json['examples']),
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      isFavorite: json['isFavorite'] as bool,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'pronunciation': pronunciation,
      'definitions': definitions,
      'examples': examples,
      'category': category,
      'difficulty': difficulty,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isFavorite': isFavorite,
    };
  }

  // Convert to Map for Firestore (referenced in firebaseCloudfire.dart)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'pronunciation': pronunciation,
      'definitions': definitions,
      'examples': examples,
      'category': category,
      'difficulty': difficulty,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isFavorite': isFavorite,
    };
  }

  // Create from Map (Firestore document)
  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'] as String,
      text: map['text'] as String,
      pronunciation: map['pronunciation'] as String? ?? '',
      definitions: List<String>.from(map['definitions'] ?? []),
      examples: List<String>.from(map['examples'] ?? []),
      category: map['category'] as String? ?? '',
      difficulty: map['difficulty'] as String? ?? 'beginner',
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
          : null,
      isFavorite: map['isFavorite'] as bool? ?? false,
    );
  }
}