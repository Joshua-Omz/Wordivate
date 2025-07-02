import 'package:firebase_auth/firebase_auth.dart';  

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Stream<User?> get userStream => _auth.authStateChanges(); 

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  } 

  Future<UserCredential> signUpWithEmailAndPassword(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  } 

  Future<void> signOut() async {
    await _auth.signOut();
  } 

  User? get currentUser => _auth.currentUser; 
}

