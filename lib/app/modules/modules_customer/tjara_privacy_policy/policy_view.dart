import 'package:flutter/material.dart';
import 'package:tjara/app/modules/modules_customer/customer_dashboard/controllers/dashboard_controller.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () {
            // Navigate back to More view (index 4 in dashboard)
            DashboardController.instance.changeIndex(2);
          },
        ),
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("1. Information We Collect"),
              _buildContent(
                "We collect personal data that you voluntarily provide, including your name, email, and usage data. Automatically collected information includes IP address, browser type, and session data.",
              ),
              _buildSectionTitle("2. How We Use Your Information"),
              _buildBulletPoints([
                "To provide and maintain our service.",
                "To communicate with you, including updates and support.",
                "To improve user experience and analyze website performance.",
                "To ensure security and prevent fraud.",
                "To comply with legal obligations and enforce our terms of service.",
              ]),
              _buildSectionTitle("3. Cookies and Tracking Technologies"),
              _buildContent(
                "We use cookies and similar tracking technologies to collect data for analytics, improve functionality, and enhance user experience. You can disable cookies in your browser settings, but this may limit certain features of our site.",
              ),
              _buildSectionTitle("4. Third-Party Services"),
              _buildBulletPoints([
                "Analytics Providers: To analyze and improve our site’s performance.",
                "Payment Processors: To securely handle transactions.",
                "Hosting Services: For data storage and infrastructure.",
                "Marketing Tools: To send newsletters or promotional content (only with consent).",
              ]),
              _buildSectionTitle("5. Data Security"),
              _buildContent(
                "We implement robust security measures to protect your data. However, no method of transmission over the internet or electronic storage is 100% secure.",
              ),
              _buildSectionTitle("6. Your Rights"),
              _buildBulletPoints([
                "Access: View the data we hold about you.",
                "Correction: Update inaccurate or incomplete information.",
                "Deletion: Request deletion of your personal data.",
                "Object: Restrict how we process your data.",
              ]),
              _buildContent(
                "To exercise any of these rights, please contact us at support@example.com.",
              ),
              _buildSectionTitle("7. Changes to This Policy"),
              _buildContent(
                "We may update our Privacy Policy periodically. Any changes will be posted on this page with an updated effective date. We encourage you to review this policy regularly to stay informed about how we protect your data.",
              ),
              const SizedBox(height: 160),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        content,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }

  Widget _buildBulletPoints(List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          points
              .map(
                (point) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "• ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          point,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }
}
