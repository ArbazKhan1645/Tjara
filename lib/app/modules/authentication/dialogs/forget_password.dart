import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/authentication/controllers/device_activation_controller.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallDevice = screenSize.width < 400;
    final isMediumDevice = screenSize.width < 600;

    return Material(
      color: Colors.transparent,
      child: GetBuilder<DeviceActivationController>(
        init: DeviceActivationController(),
        builder: (controller) {
          return Center(
            child: Container(
              // Responsive height calculation
              height: _getContainerHeight(screenSize),
              margin: EdgeInsets.all(isSmallDevice ? 12 : 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(isSmallDevice ? 16 : 24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with icon, title, and close button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.lock_outline,
                                    size: 24,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(width: isSmallDevice ? 8 : 12),
                                Flexible(
                                  child: Text(
                                    "Forget Password",
                                    style: TextStyle(
                                      fontSize: isSmallDevice ? 16 : 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFfda730),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: isSmallDevice ? 12 : 20),

                      // Instruction text
                      Text(
                        "Please enter your email or phone number to recover or set your password.",
                        style: TextStyle(
                          fontSize: isSmallDevice ? 12 : 14,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),

                      SizedBox(height: isSmallDevice ? 16 : 24),

                      // Email/Phone label
                      Text(
                        "Email or Phone",
                        style: TextStyle(
                          fontSize: isSmallDevice ? 12 : 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Input field
                      TextFormField(
                        controller: controller.forgetEmailController,
                        decoration: InputDecoration(
                          hintText: "Email or Phone",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: isSmallDevice ? 12 : 14,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isSmallDevice ? 12 : 16,
                            vertical: isSmallDevice ? 12 : 16,
                          ),
                        ),
                      ),

                      SizedBox(height: isSmallDevice ? 12 : 20),

                      // Send button
                      SizedBox(
                        width: double.infinity,
                        height: isSmallDevice ? 44 : 50,
                        child: ElevatedButton(
                          onPressed:
                              controller.isLoggingIn.value
                                  ? null
                                  : () async {
                                    await controller.forgetPassword(context);
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFfda730),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              controller.isLoggingIn.value
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : Text(
                                    "SEND",
                                    style: TextStyle(
                                      fontSize: isSmallDevice ? 14 : 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Calculate container height based on screen size
  double _getContainerHeight(Size screenSize) {
    if (screenSize.height < 600) {
      return screenSize.height * 0.5;
    } else if (screenSize.height < 800) {
      return screenSize.height * 0.45;
    } else {
      return screenSize.height * 0.4;
    }
  }
}
