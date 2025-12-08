import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Needed for Widget/State classes
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _phoneController = TextEditingController();
  final _opController = TextEditingController();
  bool _otpSent = false;

  bool _loadingPhone = false;
  bool _loadingGoogle = false;
  bool _loadingApple = false; // Note: Used in variables but not implemented in snippet

  String? _error;

  void _setError(Object e) {
    setState(() {
      if (e is AuthException) {
        _error = e.message;
      } else {
        debugPrint(e.toString());
        _error = 'Something went wrong';
      }
    });
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() {
        _error = 'Enter Phone Number';
      });
      return;
    }
    setState(() {
      _loadingPhone = true;
      _error = null;
    });
    try {
      await supabase.auth.signInWithOtp(phone: phone, channel: OtpChannel.sms);
      setState(() {
        _otpSent = true;
      });
    } catch (e) {
      _setError(e);
    } finally {
      setState(() {
        _loadingPhone = false;
      });
    }
  } // FIXED: Added closing brace for _sendOtp

  Future<void> _verifyOtp() async {
    final phone = _phoneController.text.trim();
    final token = _opController.text.trim();

    setState(() {
      _loadingPhone = true;
      _error = null;
    });
    try {
      await supabase.auth.verifyOTP(
        type: OtpType.sms,
        token: token,
        phone: phone,
      );
    } catch (e) {
      _setError(e);
    } finally {
      setState(() {
        _loadingPhone = false;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loadingGoogle = true;
    });

    try {
      // 1. Web specific flow (Supabase handles this directly)
      if (kIsWeb) {
        await supabase.auth.signInWithOAuth(OAuthProvider.google);
        return;
      }

      // 2. Native flow (Android/iOS) - NEW v7 IMPLEMENTATION
      final googleSignIn = GoogleSignIn.instance;

      // Initialize the plugin (New in v7)
      // IMPORTANT: serverClientId is required for Android to get the idToken
      // This refers to the 'Web client ID' from Google Cloud Console
      await googleSignIn.initialize(
        serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
      );

      // Authenticate user (Replaces .signIn() in v7)
      final googleUser = await googleSignIn.authenticate(scopeHint: ['email']);

      // 3. Retrieve Tokens (Note: .authentication is now synchronous in v7)
      final googleAuth = googleUser.authentication;
      final accessToken = await googleAuth;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'No ID Token found. Ensure serverClientId is set correctly in .env.';
      }

      // 4. Exchange tokens with Supabase
      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        // accessToken: accessToken,
      );

    } catch (e) {
      _setError(e);
    } finally {
      setState(() {
        _loadingGoogle = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
