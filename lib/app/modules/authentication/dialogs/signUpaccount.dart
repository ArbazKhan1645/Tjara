import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/authentication/controllers/device_activation_controller.dart';
import 'package:tjara/app/modules/authentication/dialogs/contact_us.dart';
import 'package:tjara/app/modules/authentication/dialogs/login.dart';

class Registration extends StatelessWidget {
  const Registration({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: GetBuilder<DeviceActivationController>(
            init: DeviceActivationController(),
            builder: (controller) {
              return Container(
                height: 650,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Register your account",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Register as:",
                          style: TextStyle(color: Colors.black),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            CustomerCircularCheckbox(
                              backgroundcolor: Colors.red.shade700,
                              innerbackcolor: Colors.white,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text(
                              "Seller",
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            CustomerCircularCheckbox(
                              backgroundcolor: Colors.white,
                              innerbackcolor: Colors.red.shade700,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text(
                              "Customer",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "First Name ",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 15),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    CustomTextfield(
                                        controller:
                                            controller.firstNameController),
                                  ],
                                ),
                              ),
                            )),
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Last Name ",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 15),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    CustomTextfield(
                                        controller:
                                            controller.lastNameController)
                                  ],
                                ),
                              ),
                            )),
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
                        CustomTextfield(
                            controller: controller.signupemailController),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Phone",
                          style: TextStyle(color: Colors.black),
                        ),
                        CustomTextfield(controller: controller.phoneController),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Password",
                          style: TextStyle(color: Colors.black),
                        ),
                        CustomTextfield(
                            controller: controller.sinuppasswordController),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Referrel Code",
                          style: TextStyle(color: Colors.black),
                        ),
                        CustomTextfield(controller: TextEditingController()),
                        const SizedBox(height: 30),
                        ButtonW(
                          onTap: () async {
                            await controller.onregister(context);
                          },
                          isloading: false,
                          txt: 'Register',
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
                            showContactDialog(context, LoginUi());
                          },
                          child: ButtonW(
                            isloading: false,
                            txt: 'Login',
                            color: Colors.white,
                            bordercolor: Colors.red.shade100,
                            txtcolor: Colors.red,
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        )
                      ],
                    ),
                  ),
                ),
              );
            }));
  }
}

class CustomTextfield extends StatelessWidget {
  const CustomTextfield({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter text',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field cannot be empty';
            }
            if (value.length < 3) {
              return 'Must be at least 3 characters';
            }
            return null;
          },
        ));
  }
}

class ButtonW extends StatelessWidget {
  const ButtonW(
      {super.key,
      required this.txt,
      required this.color,
      required this.bordercolor,
      required this.isloading,
      required this.txtcolor,
      this.onTap});
  final String txt;
  final Color color;
  final bool isloading;
  final Color bordercolor;
  final void Function()? onTap;
  final Color txtcolor;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration:
            BoxDecoration(color: color, border: Border.all(color: bordercolor)),
        child: Center(
          child: isloading
              ? CircularProgressIndicator(color: Colors.white)
              : Text(
                  txt,
                  style: TextStyle(color: txtcolor, fontSize: 15),
                ),
        ),
      ),
    );
  }
}

class CustomerCircularCheckbox extends StatelessWidget {
  const CustomerCircularCheckbox({
    super.key,
    required this.backgroundcolor,
    required this.innerbackcolor,
  });
  final Color backgroundcolor;
  final Color innerbackcolor;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade200)),
      child: Container(
        height: 22,
        width: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundcolor,
        ),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Container(
            height: 15,
            width: 15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: innerbackcolor,
            ),
          ),
        ),
      ),
    );
  }
}
