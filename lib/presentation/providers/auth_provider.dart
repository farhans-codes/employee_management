import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _token;
  LoginUser? _loginUser;
  UserModel? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  String? get token => _token;
  LoginUser? get loginUser => _loginUser;
  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _auth.currentUser != null;

  // Initialize auth state - call this on app start
  Future<void> init() async {
    if (_auth.currentUser != null && _userProfile == null) {
      await fetchProfile();
    }
  }

  // Login with Firebase
  Future<bool> login(String employeeId, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Map employeeId to email for Firebase Auth
      final email = "${employeeId.trim().toLowerCase()}@employee.com";

      UserCredential userCredential;
      try {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          // For demo purposes, auto-create the two main users if they don't exist
          if ((employeeId == 'L3T2077' && password == 'password123') ||
              (employeeId == 'L3T2088' && password == 'password456')) {
            userCredential = await _auth.createUserWithEmailAndPassword(
              email: email,
              password: password,
            );
            // Initialize their profile in Firestore
            await _initializeMockProfile(employeeId, userCredential.user!.uid);
          } else {
            throw 'Invalid Employee ID or Password';
          }
        } else {
          rethrow;
        }
      }

      _token = await userCredential.user?.getIdToken();

      // Fetch profile to populate loginUser and userProfile
      await fetchProfile();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Initialize a new profile for mock users
  Future<void> _initializeMockProfile(String employeeId, String uid) async {
    final bool isKaniz = employeeId == 'L3T2077';

    final userData = {
      'employee_id': employeeId,
      'name': isKaniz ? 'Kaniz Fatima' : 'Rahim Uddin',
      'designation': isKaniz ? 'Senior Executive' : 'Software Engineer',
      'role': isKaniz ? 'Senior Executive' : 'Software Engineer',
      'department': 'Operations',
      'location': 'Dhaka, Bangladesh',
      'profile_image': isKaniz
          ? 'https://ui-avatars.com/api/?name=Kaniz+Fatima&background=0D8ABC&color=fff&size=150'
          : 'https://ui-avatars.com/api/?name=Rahim+Uddin&background=5D4037&color=fff&size=150',
      'personal_details': {
        'joining_date': '2024-01-01',
        'confirmation_date': '2024-04-01',
        'service_length': '1 Year',
      },
    };

    await _firestore.collection('users').doc(uid).set(userData);
  }

  // Fetch user profile from Firestore
  Future<void> fetchProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _userProfile = UserModel.fromJson(data);
        _loginUser = LoginUser(
          id: _userProfile!.employeeId,
          name: _userProfile!.name,
          role: data['role'] ?? _userProfile!.designation,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Profile fetch error: $e');
    }
  }

  // Logout from Firebase
  Future<void> logout() async {
    await _auth.signOut();
    _token = null;
    _loginUser = null;
    _userProfile = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
