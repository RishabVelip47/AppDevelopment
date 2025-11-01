import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? getCurrentUser() => _auth.currentUser;

  Future<void> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      rethrow;
    }
  }

  // ✅ Google Sign-In (Web + Mobile)
  Future<void> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // 🔹 Provide your Web Client ID explicitly
        final googleSignIn = GoogleSignIn(
          clientId: "422624538509-0k36vu7h517pfv2iidnu9j4uvd5evuu9.apps.googleusercontent.com", // e.g., 1234567890-abcxyz.apps.googleusercontent.com
        );

        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) throw Exception('Google sign-in cancelled');

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _auth.signInWithCredential(credential);
      } else {
        // 🔹 Normal Google sign-in for Android/iOS
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) throw Exception('Google sign-in cancelled');

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  // ✅ Phone Authentication (only on mobile)
  Future<void> signInWithPhone(String phoneNumber, Function(String) codeSentCallback) async {
    if (kIsWeb) {
      throw Exception('Phone authentication is not supported on web. Please use email or Google sign-in.');
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw Exception(e.message);
      },
      codeSent: (String verificationId, int? resendToken) {
        codeSentCallback(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      timeout: const Duration(seconds: 60),
    );
  }

  Future<void> verifyOTP(String verificationId, String otp) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }
}
