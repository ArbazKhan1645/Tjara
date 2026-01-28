import 'package:flutter/material.dart';
import 'package:tjara/app/models/chat_messages/insert_chat.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart';
import 'package:tjara/app/modules/authentication/dialogs/contact_us.dart';
import 'package:tjara/app/modules/authentication/dialogs/login.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tjara/app/core/utils/thems/theme.dart';

class CustomerServiceDialog extends StatelessWidget {
  final String phoneNumber;
  final String? whatsappCode;
  final String? whatsapp;
  final String productid;

  const CustomerServiceDialog({
    super.key,
    required this.phoneNumber,
    this.whatsapp,
    required this.productid,
    this.whatsappCode,
  });

  void _makeCall() async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _openWhatsApp() async {
    print('WhatsApp button tapped');

    // Format the phone number properly for WhatsApp
    String formatWhatsApp = '';
    if (whatsapp == null ||
        whatsapp.toString() == 'null' ||
        whatsapp.toString().isEmpty) {
      formatWhatsApp = phoneNumber;
    } else {
      formatWhatsApp = (whatsappCode ?? '') + whatsapp.toString();
    }

    // Remove any non-digit characters
    final formattedNumber = formatWhatsApp.replaceAll(RegExp(r'\D'), '').trim();
    print('Formatted WhatsApp number: $formattedNumber');

    try {
      // Method 1: Direct app launch with different approach
      final Uri whatsappUri = Uri.parse(
        'whatsapp://send?phone=$formattedNumber',
      );

      // Use launchUrl directly without checking canLaunchUrl first
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

      // Method 2: Try web URL with external browser
      final Uri webUri = Uri.parse('https://wa.me/$formattedNumber');
      launched = await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      ).catchError((error) {
        print('Web URL launch failed: $error');
        return false;
      });

      if (launched) {
        print('WhatsApp web launched successfully');
        return;
      }

      // Method 3: Try SMS-based approach
      final Uri smsUri = Uri.parse('sms:$formattedNumber');
      launched = await launchUrl(
        smsUri,
        mode: LaunchMode.externalApplication,
      ).catchError((error) {
        print('SMS launch failed: $error');
        return false;
      });

      if (launched) {
        print('SMS app launched as fallback');
        return;
      }

      print('All launch methods failed');
      _showErrorSnackBar(
        'WhatsApp could not be opened. Please check if WhatsApp is installed.',
      );
    } catch (e) {
      print('Exception in _openWhatsApp: $e');
      _showErrorSnackBar('Error opening WhatsApp: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    // You'll need to pass BuildContext or use a GlobalKey for ScaffoldMessenger
    // For now, just print the error
    print('Error: $message');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Customer Service',
                    style: defaultTextStyle.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Our customer service team is always here if you need help',
                    textAlign: TextAlign.center,
                    style: defaultTextStyle.copyWith(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _actionButton(
                    icon: Icons.chat_bubble,
                    label: 'WhatsApp',
                    color: const Color(0xFFF97316), // WhatsApp green
                    onTap: _openWhatsApp,
                  ),
                  const SizedBox(height: 16),
                  _actionButton(
                    icon: Icons.call,
                    label: 'Call',
                    color: const Color(0xFF0D9488), // Teal
                    onTap: _makeCall,
                  ),
                  const SizedBox(height: 16),
                  _actionButton(
                    icon: Icons.chat,
                    label: 'Live Chat',
                    color: const Color(0xFFF97316), // Teal
                    onTap: () {
                      final LoginResponse? usercurrent =
                          AuthService.instance.authCustomer;
                      if (usercurrent?.user == null) {
                        showContactDialog(context, const LoginUi());
                      } else {
                        startChatWithProduct(productid, context);
                      }
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            // Close Button
            Positioned(
              top: -10,
              right: -10,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: 16,
                    child: Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: defaultTextStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showCustomerServiceDialog(
  BuildContext context,
  String phoneNumber,
  String productid,
  String? whatsAppCode,
  String whatsapp,
) {
  showDialog(
    context: context,
    builder:
        (context) => CustomerServiceDialog(
          whatsapp: whatsapp,
          phoneNumber: phoneNumber,
          whatsappCode: whatsAppCode,
          productid: productid,
        ),
  );
}

class CustomerService {
  CustomerService._(); // private constructor

  /// 📞 Call Service
  static Future<void> makeCall(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  /// 💬 WhatsApp Service
  static Future<void> openWhatsApp({
    required String phoneNumber,
    String? whatsapp,
    String? whatsappCode,
  }) async {
    String formatWhatsApp = '';

    if (whatsapp == null || whatsapp.isEmpty) {
      formatWhatsApp = phoneNumber;
    } else {
      formatWhatsApp = (whatsappCode ?? '') + whatsapp;
    }

    final formattedNumber = formatWhatsApp.replaceAll(RegExp(r'\D'), '').trim();

    try {
      final Uri whatsappUri = Uri.parse(
        'whatsapp://send?phone=$formattedNumber',
      );

      bool launched = await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      ).catchError((_) => false);

      if (launched) return;

      final Uri webUri = Uri.parse('https://wa.me/$formattedNumber');

      launched = await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      ).catchError((_) => false);

      if (launched) return;

      final Uri smsUri = Uri.parse('sms:$formattedNumber');
      await launchUrl(smsUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('WhatsApp Error: $e');
    }
  }

  /// 🟢 Live Chat Service
  static void startLiveChat({
    required BuildContext context,
    required String productId,
  }) {
    final LoginResponse? usercurrent = AuthService.instance.authCustomer;

    if (usercurrent?.user == null) {
      showContactDialog(context, const LoginUi());
    } else {
      startChatWithProduct(productId, context);
    }
  }
}
