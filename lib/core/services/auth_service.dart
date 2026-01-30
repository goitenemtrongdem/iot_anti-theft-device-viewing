import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /* ===================== SIGN UP ===================== */

  /// Sign up bằng email & password + gửi mail verify
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user!.sendEmailVerification();
    return credential;
  }

Future<void> saveUserProfile({
  required String fullName,
  required String address,
  required String dateOfBirth,
  required String citizenNumber,
}) async {
  final user = _auth.currentUser;
  if (user == null) {
    throw Exception('User not logged in');
  }

  await _firestore.collection('users').doc(user.uid).set({
    'fullname': fullName,
    'address': address,
    'dateOfBirth': dateOfBirth,
    'citizenNumber': citizenNumber,
    'profileCompleted': true,
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}

  /* ===================== EMAIL VERIFY ===================== */

  /// Kiểm tra email đã verify chưa
  Future<bool> isEmailVerified() async {
    User? user = _auth.currentUser;
    if (user == null) return false;

    await user.reload();
    user = _auth.currentUser;

    return user?.emailVerified ?? false;
  }

  /* ===================== SAVE DATABASE ===================== */

  /// Lưu user vào Firestore (chỉ gọi khi verify thành công)
  Future<void> saveUserToDatabase() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'email': user.email,
      'fullname': '',
      'address': '',
      'avatarUrl': '',
      'citizenNumber': '',
      'dateOfBirth': '',
      'fcmTokens': [],
      'sosNumbers': [],
      'createdAt': FieldValue.serverTimestamp(),
      'lastSignIn': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /* ===================== FLOW GỘP (OPTIONAL) ===================== */

  /// Kiểm tra verify + lưu DB (gọi ở nút "Next")
  Future<bool> checkEmailVerifiedAndSave() async {
    final verified = await isEmailVerified();
    if (verified) {
      await saveUserToDatabase();
      return true;
    }
    return false;
  }

  /// SIGN IN
Future<void> signInWithEmail({
  required String email,
  required String password,
}) async {
  await _auth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
}

/// SEND RESET PASSWORD EMAIL
Future<void> sendResetPasswordEmail(String email) async {
  await _auth.sendPasswordResetEmail(email: email);
}
}

