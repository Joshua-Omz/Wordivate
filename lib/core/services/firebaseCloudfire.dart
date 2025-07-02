import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wordivate/models/word_model.dart';
import 'package:wordivate/models/categorymodel.dart';
import 'package:wordivate/models/user_profile.dart';

class FirebaseCloudService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  
  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // User document reference
  DocumentReference? get _userDoc => 
      currentUserId != null ? _usersCollection.doc(currentUserId) : null;
  
  // Words collection for current user
  CollectionReference? get _wordsCollection => 
      currentUserId != null ? _userDoc?.collection('words') : null;

  // Categories collection for current user
  CollectionReference? get _categoriesCollection => 
      currentUserId != null ? _userDoc?.collection('categories') : null;

  // PROFILE METHODS
  
  // Create new user profile after registration
  Future<void> createUserProfile(User user, {String? displayName}) async {
    final userData = UserProfile(
      uid: user.uid,
      email: user.email ?? '',
      displayName: displayName ?? user.displayName ?? user.email?.split('@')[0] ?? 'User',
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
    ).toMap();
    
    await _usersCollection.doc(user.uid).set(userData);
  }
  
  // Get user profile
  Future<UserProfile?> getUserProfile() async {
    if (currentUserId == null) return null;
    
    final doc = await _userDoc?.get();
    if (doc?.exists == true) {
      return UserProfile.fromMap(doc?.data() as Map<String, dynamic>);
    }
    return null;
  }
  
  // Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (currentUserId == null) return;
    
    // Update the lastActive timestamp
    data['lastActive'] = DateTime.now();
    
    await _userDoc?.update(data);
  }
  
  // WORDS METHODS
  
  // Get all words for current user
  Stream<List<Word>> getUserWords() {
    if (_wordsCollection == null) {
      return Stream.value([]);
    }
    
    return _wordsCollection!.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Word.fromMap(data);
      }).toList();
    });
  }
  
  // Add a new word
  Future<void> addWord(Word word) async {
    if (_wordsCollection == null) return;
    
    final wordData = word.toMap();
    await _wordsCollection!.doc(word.id).set(wordData);
  }
  
  // Update a word
  Future<void> updateWord(String wordId, Map<String, dynamic> data) async {
    if (_wordsCollection == null) return;
    
    await _wordsCollection!.doc(wordId).update(data);
  }
  
  // Delete a word
  Future<void> deleteWord(String wordId) async {
    if (_wordsCollection == null) return;
    
    await _wordsCollection!.doc(wordId).delete();
  }
  
  // CATEGORIES METHODS
  
  // Get all categories for current user
  Stream<List<Category>> getUserCategories() {
    if (_categoriesCollection == null) {
      return Stream.value([]);
    }
    
    return _categoriesCollection!.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Category.fromMap(data);
      }).toList();
    });
  }
  
  // Add a new category
  Future<void> addCategory(Category category) async {
    if (_categoriesCollection == null) return;
    
    final categoryData = category.toMap();
    await _categoriesCollection!.doc(category.id).set(categoryData);
  }
  
  // Update a category
  Future<void> updateCategory(String categoryId, Map<String, dynamic> data) async {
    if (_categoriesCollection == null) return;
    
    await _categoriesCollection!.doc(categoryId).update(data);
  }
  
  // Delete a category
  Future<void> deleteCategory(String categoryId) async {
    if (_categoriesCollection == null) return;
    
    await _categoriesCollection!.doc(categoryId).delete();
  }
  
  // USER SETTINGS
  
  // Get user settings
  Future<Map<String, dynamic>?> getUserSettings() async {
    if (currentUserId == null) return null;
    
    final doc = await _userDoc?.collection('settings').doc('preferences').get();
    if (doc?.exists == true) {
      return doc?.data() as Map<String, dynamic>;
    }
    
    // Create default settings if they don't exist
    final defaultSettings = {
      'theme': 'system',
      'notifications': true,
      'dailyWordReminder': true,
      'syncWithCloud': true,
    };
    
    await _userDoc?.collection('settings').doc('preferences').set(defaultSettings);
    return defaultSettings;
  }
  
  // Update user settings
  Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    if (currentUserId == null) return;
    
    await _userDoc?.collection('settings').doc('preferences').update(settings);
  }
  
  // USER STATS
  
  // Update user stats (e.g., words learned, streak)
  Future<void> updateUserStats(Map<String, dynamic> stats) async {
    if (currentUserId == null) return;
    
    final statsRef = _userDoc?.collection('stats').doc('activity');
    
    // Get the current stats
    final doc = await statsRef?.get();
    if (doc?.exists == true) {
      // Update existing stats
      await statsRef?.update(stats);
    } else {
      // Create new stats document
      await statsRef?.set(stats);
    }
    
    // Also update relevant fields in the user profile
    Map<String, dynamic> profileUpdates = {};
    if (stats.containsKey('wordsLearned')) {
      profileUpdates['wordsLearned'] = stats['wordsLearned'];
    }
    if (stats.containsKey('currentStreak')) {
      profileUpdates['currentStreak'] = stats['currentStreak'];
    }
    if (stats.containsKey('longestStreak')) {
      profileUpdates['longestStreak'] = stats['longestStreak'];
    }
    
    if (profileUpdates.isNotEmpty) {
      await _userDoc?.update(profileUpdates);
    }
  }
  
  // Get user stats
  Future<Map<String, dynamic>?> getUserStats() async {
    if (currentUserId == null) return null;
    
    final doc = await _userDoc?.collection('stats').doc('activity').get();
    if (doc?.exists == true) {
      return doc?.data() as Map<String, dynamic>;
    }
    
    // Create default stats if they don't exist
    final defaultStats = {
      'wordsLearned': 0,
      'currentStreak': 0,
      'longestStreak': 0,
      'lastStudyDate': DateTime.now().millisecondsSinceEpoch,
    };
    
    await _userDoc?.collection('stats').doc('activity').set(defaultStats);
    return defaultStats;
  }
}
