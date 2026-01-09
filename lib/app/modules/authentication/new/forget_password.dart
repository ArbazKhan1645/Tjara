import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showPasswordRecoveryDialog(BuildContext context) {
  final controller = Get.put(PasswordRecoveryController());
  controller.currentStage.value = RecoveryStage.emailInput;
  Get.dialog(
    Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: GetBuilder<PasswordRecoveryController>(
        builder: (_) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _buildCurrentStage(controller),
          );
        },
      ),
    ),
    barrierDismissible: false,
  );
}

Widget _buildCurrentStage(PasswordRecoveryController controller) {
  switch (controller.currentStage.value) {
    case RecoveryStage.emailInput:
      return EmailInputDialog(key: UniqueKey());
    case RecoveryStage.verifyCode:
      return VerifyCodeDialog(key: UniqueKey());
    case RecoveryStage.success:
      return SuccessDialog(key: UniqueKey());
    case RecoveryStage.resetPassword:
      return ResetPasswordDialog(key: UniqueKey());
  }
}

class PasswordRecoveryController extends GetxController {
  final Rx<RecoveryStage> currentStage = RecoveryStage.emailInput.obs;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final RxString digit1 = '8'.obs;
  final RxString digit2 = '8'.obs;
  final RxString digit3 = '9'.obs;
  final RxString digit4 = '0'.obs;

  void goToVerifyCode() {
    currentStage.value = RecoveryStage.verifyCode;
    update();
  }

  void goToSuccessStage() {
    currentStage.value = RecoveryStage.success;
    update();
  }

  void goToResetPassword() {
    currentStage.value = RecoveryStage.resetPassword;
    update();
  }

  void goToEmailInput() {
    currentStage.value = RecoveryStage.emailInput;
    update();
  }

  String get formattedTime {
    return '${2}:${2.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    emailController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

enum RecoveryStage { emailInput, verifyCode, success, resetPassword }

class EmailInputDialog extends StatelessWidget {
  const EmailInputDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PasswordRecoveryController>();

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.lock_outline, color: Colors.grey[700]),
                  const SizedBox(width: 10),
                  const Text(
                    'Forgot Password?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Get.back(),
                splashRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Please enter your email or phone number to recover or set your password.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 15),
          const Text(
            'Email or Phone',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller.emailController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              hintText: '+44 000 000 0000',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.goToVerifyCode(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff7CB293),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Send', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(icon, color: color),
        label: Text(text),
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: const BorderSide(color: Colors.grey),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class VerifyCodeDialog extends StatelessWidget {
  const VerifyCodeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PasswordRecoveryController>();

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.phone_android_outlined),
                  SizedBox(width: 10),
                  Text(
                    'Check your phone',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Get.back(),
                splashRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            "We've sent the code to your phone",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDigitBox(controller.digit1.value),
              _buildDigitBox(controller.digit2.value),
              _buildDigitBox(controller.digit3.value),
              _buildDigitBox(controller.digit4.value),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Don't receive the code? ",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'Click here',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.goToSuccessStage(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff7CB293),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Send', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Code expires in ${controller.formattedTime}',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitBox(String digit) {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xff7CB293).withOpacity(0.30),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        digit,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class SuccessDialog extends StatelessWidget {
  const SuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PasswordRecoveryController>();

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Get.back(),
                splashRadius: 20,
              ),
            ],
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F2EE),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.celebration_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Congratulations!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text(
            'Password Recovered',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Your password has been recovered! Would you like to log in or reset your password?',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff7CB293),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Login', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => controller.goToResetPassword(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Reset password',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ResetPasswordDialog extends StatelessWidget {
  const ResetPasswordDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PasswordRecoveryController>();

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.key_outlined),
                  SizedBox(width: 10),
                  Text(
                    'Reset your password',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Get.back(),
                splashRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Please enter your new password',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 15),
          const Text(
            'Password',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller.newPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              hintText: '••••••••',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              suffixIcon: Icon(Icons.visibility_off, color: Colors.grey[400]),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Confirm Password',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller.confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              hintText: '12345678',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              suffixIcon: Icon(Icons.visibility, color: Colors.grey[400]),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xff7CB293),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              const Text(
                'Your Password must contain:',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 30),
            child: Text(
              'At least 8 characters',
              style: TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.grey[400], size: 16),
              ),
              const SizedBox(width: 10),
              const Text(
                'Contains a number',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff7CB293),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Done', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
