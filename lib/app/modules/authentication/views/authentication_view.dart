import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:tjara/app/modules/authentication/new/sign_in.dart';

import 'package:tjara/app/modules/authentication/controllers/authentication_controller.dart';

class AuthenticationView extends GetView<AuthenticationController> {
  const AuthenticationView({super.key});
  @override
  Widget build(BuildContext context) {
    return const LoginScreenNew();
  }
}
