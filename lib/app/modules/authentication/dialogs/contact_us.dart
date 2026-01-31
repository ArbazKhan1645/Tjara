import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/utils/helpers/alerts.dart';
import 'package:tjara/app/services/websettings_service/websetting_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactFormDialog extends StatefulWidget {
  const ContactFormDialog({super.key});

  @override
  State<ContactFormDialog> createState() => _ContactFormDialogState();
}

class _ContactFormDialogState extends State<ContactFormDialog> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  void _submitForm() {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _messageController.text.isEmpty) {
      NotificationHelper.showError(context, 'Error', 'Please fill all fields');
    } else {
      NotificationHelper.showSuccess(
        context,
        'Success',
        'Form submitted successfully!',
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: 700,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Contact Us",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField("Full Name", controller: _nameController),
            const SizedBox(height: 12),
            _buildTextField("Phone Number", controller: _phoneController),
            const SizedBox(height: 12),
            _buildTextField("Email Address", controller: _emailController),
            const SizedBox(height: 12),
            _buildTextField(
              "Message",
              controller: _messageController,
              maxLines: 5,
            ),
            const SizedBox(height: 12),
            _buildSubmitButton(),
            const SizedBox(height: 12),
            _buildOption(
              'WhatsApp',
              Icons.chat_bubble,
              Colors.green,
              _openWhatsApp,
              isWhatsapp: true,
            ),
          ],
        ),
      ),
    );
  }

  void _openWhatsApp() async {
    // Format the phone number properly for WhatsApp
    final WebsiteOptionsService optionsService =
        Get.find<WebsiteOptionsService>();

    // Ensure website options are loaded
    if (optionsService.websiteOptions == null) {
      await optionsService.fetchWebsiteOptions();
    }

    final String? categoriesIds =
        optionsService.websiteOptions?.websiteWhatsappNumber;

    String formatWhatsApp = '';
    if (categoriesIds.toString() == 'null' ||
        categoriesIds.toString().isEmpty) {
      formatWhatsApp = '+$categoriesIds';
    } else {
      formatWhatsApp = '+$categoriesIds';
    }
    final formattedNumber = formatWhatsApp.replaceAll(RegExp(r'\D'), '').trim();

    try {
      // Method 1: Direct app launch without checking canLaunchUrl first
      final Uri whatsappUri = Uri.parse(
        'whatsapp://send?phone=$formattedNumber',
      );

      bool launched = await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      ).catchError((error) {
        print('WhatsApp app launch failed: $error');
        return false;
      });

      if (launched) {
        print('WhatsApp app launched successfully');
        return;
      }

      // Method 2: Try web URL with external browser (using wa.me instead of api.whatsapp.com)
      final Uri webUri = Uri.parse('https://wa.me/$formattedNumber');
      launched = await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      ).catchError((error) {
        print('WhatsApp web launch failed: $error');
        return false;
      });

      if (launched) {
        print('WhatsApp web launched successfully');
        return;
      }

      // Method 3: Fallback to original API URL
      final Uri apiUri = Uri.parse(
        'https://api.whatsapp.com/send?phone=$formattedNumber',
      );
      launched = await launchUrl(
        apiUri,
        mode: LaunchMode.externalApplication,
      ).catchError((error) {
        print('API URL launch failed: $error');
        return false;
      });

      if (launched) {
        print('WhatsApp API URL launched successfully');
        return;
      }

      print('All WhatsApp launch methods failed');
      debugPrint('Could not launch WhatsApp - all methods failed');

      // Show user-friendly error message if you have access to context
      // You can uncomment this if you have BuildContext available
      /*
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('WhatsApp could not be opened. Please check if WhatsApp is installed.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    */
    } catch (e) {
      print('Exception in _openWhatsApp: $e');
      debugPrint('WhatsApp launch error: $e');
      // Show error message to user
    }
  }

  Widget _buildOption(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isWhatsapp = false,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(0.2),
            child:
                isWhatsapp
                    ? Image.asset('assets/icons/whatsapp.png')
                    : Icon(icon, size: 30, color: color),
          ),
        ),
        const SizedBox(height: 5),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTextField(
    String hint, {
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Column(
      children: [
        const SizedBox(height: 4),
        Material(
          color: const Color(0xffF97316),
          borderRadius: BorderRadius.circular(11),
          child: MaterialButton(
            height: 52,
            minWidth: double.infinity,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onPressed: _submitForm,
            child: const Text("Submit", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

Future<Future<Object?>> showContactDialog(
  BuildContext context,
  Widget widget, {
  bool barrierDismissible = true,
}) async {
  return showGeneralDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: '',
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(alignment: Alignment.center, child: widget);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      );
    },
  );
}
