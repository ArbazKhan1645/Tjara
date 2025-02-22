import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/authentication/controllers/device_activation_controller.dart';
import 'package:tjara/app/modules/authentication/dialogs/contact_us.dart';
import 'package:tjara/app/modules/authentication/dialogs/signUpaccount.dart';

class LoginUi extends StatefulWidget {
  const LoginUi({super.key});

  @override
  State<LoginUi> createState() => _LoginUiState();
}

class _LoginUiState extends State<LoginUi> {
  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: GetBuilder<DeviceActivationController>(
            init: DeviceActivationController(),
            builder: (controller) {
              return Container(
                height: 500,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 40, right: 40, top: 30),
                  child: Form(
                    key: controller.formKey,
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
                        CustomTextfield(controller: controller.emailController),
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
                        CustomTextfield(
                            controller: controller.passwordController),
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
                        ButtonW(
                          isloading: controller.isLoggingIn.value,
                          txt: 'Login',
                          onTap: () async {
                            await controller.onLogin(context);
                          },
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
                            isloading: false,
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
            }));
  }
}
