import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:tjara/app/modules/dialogs/contact_us.dart';
import 'package:tjara/app/modules/dialogs/signUpaccount.dart';

class LoginUi extends StatelessWidget {
  const LoginUi({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: 500,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 40, right: 40, top: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Login to your account",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Email Address",
                style: TextStyle(color: Colors.black),
              ),
              const SizedBox(
                height: 5,
              ),
              const Textfield(),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Password",
                style: TextStyle(color: Colors.black),
              ),
              const SizedBox(
                height: 5,
              ),
              const Textfield(),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Reset Password",
                style: TextStyle(color: Colors.green),
              ),
              const SizedBox(
                height: 10,
              ),
              const ButtonW(
                txt: 'Login',
                color: Colors.red,
                bordercolor: Colors.red,
                txtcolor: Colors.white,
              ),
              const SizedBox(
                height: 10,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Do you have account?",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  Get.back();
                  showContactDialog(context, Registration());
                },
                child: ButtonW(
                  txt: 'Create Account',
                  color: Colors.white,
                  bordercolor: Colors.red.shade100,
                  txtcolor: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
