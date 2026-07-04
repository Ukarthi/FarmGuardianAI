import 'package:firebase_auth/firebase_auth.dart';
import '../core/mock_data.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _state = FarmState();

  // Get current user ID
  String? get currentUid => _auth.currentUser?.uid;

  // Stream user auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign In with email & password
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _state.saveLog('AuthService', 'Operator ${email} authenticated successfully.', 'info');
      return credential;
    } on FirebaseAuthException catch (e) {
      _state.saveLog('AuthService', 'Login failed: ${e.message}', 'error');
      rethrow;
    }
  }

  // Register farm operator account
  Future<UserCredential?> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _state.saveLog('AuthService', 'New operator account registered: ${email}.', 'info');
      return credential;
    } on FirebaseAuthException catch (e) {
      _state.saveLog('AuthService', 'Registration failed: ${e.message}', 'error');
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      final email = _auth.currentUser?.email;
      await _auth.signOut();
      _state.saveLog('AuthService', 'Operator ${email} logged out.', 'info');
    } catch (e) {
      _state.saveLog('AuthService', 'Sign out error: $e', 'error');
    }
  }
}
