import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentOptionsDialog extends StatelessWidget {
  const PaymentOptionsDialog({
    super.key,
    required this.onPaymentMethodTap,
    required this.shown,
  });
  final Function(String) onPaymentMethodTap;
  final bool shown;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with back button
                    Stack(
                      children: [
                        if (shown)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () {
                                Get.back();
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Center(
                            child: Text(
                              'Safe Payment Options',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Commitment statement
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                        children: [
                          TextSpan(text: '• '),
                          TextSpan(
                            text:
                                'Tjara is committed to protecting your payment information.',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text:
                                ' We follow PCI DSS standards, use strong encryption, and perform regular reviews of its system to protect your privacy.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Payment methods section
                    const Text(
                      '1. Payment methods',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Payment method icons grid
                    PaymentMethodsGrid(
                      onPaymentMethodTap: (String methodName) {
                        // Handle payment method selection
                        // Get.snackbar(
                        //   'Payment Method Selected',
                        //   'You selected $methodName',
                        //   backgroundColor: Colors.green,
                        //   colorText: Colors.white,
                        //   duration: const Duration(seconds: 2),
                        // );
                      },
                    ),
                    const SizedBox(height: 30),

                    // Security certifications
                    const Text(
                      'Security Certifications',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Security certification icons grid
                    SecurityCertificationsGrid(
                      onCertificationTap: (String certificationName) {
                        // Handle security certification tap
                        // Get.snackbar(
                        //   'Security Info',
                        //   'Learn more about $certificationName security',
                        //   backgroundColor: Colors.blue,
                        //   colorText: Colors.white,
                        //   duration: const Duration(seconds: 2),
                        // );
                      },
                    ),
                    const SizedBox(height: 30),

                    // Second payment options title
                    const Text(
                      'Safe Payment Options',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Package safety
                    const Text(
                      '• Package safety',
                      style: TextStyle(fontSize: 16, color: Colors.green),
                    ),
                    const Text(
                      'Full refund for your damaged or lost package.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(
                      height: 20,
                    ), // Extra space for the WhatsApp button
                    const Text(
                      '• Delivery guaranteed',
                      style: TextStyle(fontSize: 16, color: Colors.green),
                    ),
                    const Text(
                      'Accurate and precise order tracking.',
                      style: TextStyle(fontSize: 16),
                    ),
                    if (shown)
                      const SizedBox(
                        height: 80,
                      ), // Extra space for the WhatsApp button
                  ],
                ),
              ),
            ),
            if (shown)
              // WhatsApp button - Now functional
              Positioned(
                bottom: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    // Handle WhatsApp chat functionality
                    onPaymentMethodTap('WhatsApp');
                    // You can add actual WhatsApp functionality here
                    // For example: launch('https://wa.me/yourphonenumber');
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Color(0xFF25D366), // WhatsApp green
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.chat, color: Colors.white, size: 30),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PaymentMethodsGrid extends StatelessWidget {
  final Function(String) onPaymentMethodTap;

  const PaymentMethodsGrid({super.key, required this.onPaymentMethodTap});

  @override
  Widget build(BuildContext context) {
    // List of payment methods with their image URLs
    final List<Map<String, String>> paymentMethods = [
      {
        'name': 'PayPal',
        'url':
            'https://www.paypalobjects.com/webstatic/mktg/logo/pp_cc_mark_37x23.jpg',
      },
      {
        'name': 'Visa',
        'url':
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Visa_Inc._logo.svg/2560px-Visa_Inc._logo.svg.png',
      },
      {
        'name': 'Mastercard',
        'url':
            'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Mastercard-logo.svg/1280px-Mastercard-logo.svg.png',
      },
      {
        'name': 'American Express',
        'url':
            'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/American_Express_logo_%282018%29.svg/1200px-American_Express_logo_%282018%29.svg.png',
      },
      {
        'name': 'Discover',
        'url':
            'https://images.icon-icons.com/2341/PNG/512/discover_payment_method_card_icon_142741.png',
      },
      {
        'name': 'Diners Club',
        'url':
            'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a6/Diners_Club_Logo3.svg/1200px-Diners_Club_Logo3.svg.png',
      },
      {
        'name': 'Maestro',
        'url':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrCfthPMfzebkdHlukDOW30YChCav5euj7fQ&s',
      },
      {
        'name': 'JCB',
        'url':
            'https://upload.wikimedia.org/wikipedia/commons/thumb/4/40/JCB_logo.svg/1200px-JCB_logo.svg.png',
      },
      {
        'name': 'Apple Pay',
        'url':
            'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/Apple_Pay_logo.svg/1200px-Apple_Pay_logo.svg.png',
      },
      {
        'name': 'Clearpay',
        'url':
            'https://woocommerce.com/wp-content/uploads/2021/06/fb-clearpay-v1@2x.png',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.2, // Adjusted for better text visibility
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: paymentMethods.length,
      itemBuilder: (context, index) {
        return PaymentMethodCard(
          name: paymentMethods[index]['name']!,
          imageUrl: paymentMethods[index]['url']!,
          onTap: () => onPaymentMethodTap(paymentMethods[index]['name']!),
        );
      },
    );
  }
}

class SecurityCertificationsGrid extends StatelessWidget {
  final Function(String) onCertificationTap;

  const SecurityCertificationsGrid({
    super.key,
    required this.onCertificationTap,
  });

  @override
  Widget build(BuildContext context) {
    // List of security certifications with their image URLs
    final List<Map<String, String>> securityCertifications = [
      {
        'name': 'PCI DSS',
        'url':
            'https://www.pngfind.com/pngs/m/106-1067556_pci-dss-certification-logo-hd-png-download.png',
      },
      {
        'name': 'Visa Secure',
        'url':
            'https://bd.visa.com/dam/VCOM/global/pay-with-visa/images/visa-secure-logo-800x450.png',
      },
      {
        'name': 'Mastercard SecureCode',
        'url':
            'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Mastercard-logo.svg/1280px-Mastercard-logo.svg.png',
      },
      {
        'name': 'SafeKey',
        'url':
            'https://www.americanexpress.com/content/dam/amex/ca/en/security/SafeKey/SafeKeyPage_SafeKeyLogo.png',
      },
      {
        'name': 'ProtectBuy',
        'url':
            'https://www.netcetera.com/dam/jcr:110ea424-aaea-482d-a146-51039d9c226b/20190816-Diners-Discover-ProtectBuy-logos.png',
      },
      {
        'name': 'JCB J/Secure',
        'url':
            'https://upload.wikimedia.org/wikipedia/commons/thumb/4/40/JCB_logo.svg/1200px-JCB_logo.svg.png',
      },
      {
        'name': 'TrustedSite',
        'url':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS746oaFT4aL-aWfY6DFHZBv1AJ3VSF-mGx8g&s',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.2, // Adjusted for better text visibility
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: securityCertifications.length,
      itemBuilder: (context, index) {
        return PaymentMethodCard(
          name: securityCertifications[index]['name']!,
          imageUrl: securityCertifications[index]['url']!,
          onTap:
              () => onCertificationTap(securityCertifications[index]['name']!),
        );
      },
    );
  }
}

class PaymentMethodCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final VoidCallback onTap;

  const PaymentMethodCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.credit_card,
                    color: Colors.grey.shade400,
                    size: 24,
                  );
                },
              ),
            ),
            const SizedBox(height: 2),
            Expanded(
              flex: 1,
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
