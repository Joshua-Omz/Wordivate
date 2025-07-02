class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final DateTime lastActive;
  final String? photoUrl;
  final int wordsLearned;
  final int currentStreak;
  final int longestStreak;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
    required this.lastActive,
    this.photoUrl,
    this.wordsLearned = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
  });

  // Create a copy with updated fields
  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? lastActive,
    String? photoUrl,
    int? wordsLearned,
    int? currentStreak,
    int? longestStreak,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      photoUrl: photoUrl ?? this.photoUrl,
      wordsLearned: wordsLearned ?? this.wordsLearned,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastActive': lastActive.millisecondsSinceEpoch,
      'photoUrl': photoUrl,
      'wordsLearned': wordsLearned,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
    };
  }

  // Create from Map (Firestore document)
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      lastActive: DateTime.fromMillisecondsSinceEpoch(map['lastActive'] as int),
      photoUrl: map['photoUrl'] as String?,
      wordsLearned: map['wordsLearned'] as int? ?? 0,
      currentStreak: map['currentStreak'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
    );
  }
}
