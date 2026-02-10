import 'package:flutter/material.dart';

import 'package:tjara/app/modules/authentication/screens/login.dart';

import 'package:tjara/app/modules/authentication/screens/signup.dart';

// ========================================
// 🎯 MAIN AUTH WRAPPER (Parent Widget)
// Use this widget where you need Login/Signup switching
// ========================================
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showLogin = true; // true = Login, false = Signup

  void _switchToSignup() {
    setState(() {
      _showLogin = false;
    });
  }

  void _switchToLogin() {
    setState(() {
      _showLogin = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showLogin
        ? LoginUi(avoidNavigate: true, onSwitchToSignup: _switchToSignup)
        : SignupScreen(avoidNavigate: true, onSwitchToSignup: _switchToLogin);
  }
}
