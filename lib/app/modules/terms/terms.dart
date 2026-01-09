import 'package:flutter/material.dart';
import 'package:tjara/app/modules/dashboard/controllers/dashboard_controller.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
          'Terms of Service',
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
              _buildSectionTitle("1. Acceptance of Terms"),
              _buildContent(
                "By accessing or using our website, you confirm that you have read, understood, and agreed to be bound by these Terms of Service, as well as any applicable laws and regulations. We reserve the right to update or modify these terms at any time without prior notice.",
              ),
              _buildSectionTitle("2. Use of Services"),
              _buildBulletPoints([
                "You must be at least 18 years old or have legal parental/guardian consent to use our services.",
                "You agree to use our website for lawful purposes only and not for any illegal or unauthorized activities.",
                "You must not attempt to interfere with the operation or functionality of our website.",
                "All content you submit or share must not infringe on any third-party rights, including intellectual property.",
              ]),
              _buildSectionTitle("3. User Accounts"),
              _buildBulletPoints([
                "You are responsible for maintaining the confidentiality of your account credentials.",
                "You agree to provide accurate and up-to-date information during registration.",
                "We reserve the right to suspend or terminate accounts that violate these terms.",
              ]),
              _buildSectionTitle("4. Intellectual Property"),
              _buildContent(
                "All content on this website, including text, graphics, logos, images, and software, is the property of our company or our licensors and is protected by applicable copyright and trademark laws.",
              ),
              _buildBulletPoints([
                "You may not copy, reproduce, distribute, or create derivative works from our content without prior written consent.",
                "Unauthorized use of our intellectual property may result in legal action.",
              ]),
              _buildSectionTitle("5. Limitations of Liability"),
              _buildContent(
                "To the maximum extent permitted by law, we will not be liable for any direct, indirect, incidental, consequential, or punitive damages arising out of your use of our services. This includes but is not limited to loss of data, business interruption, or personal injury.",
              ),
              _buildSectionTitle("6. Third-Party Links"),
              _buildContent(
                "Our website may contain links to third-party websites or services that are not under our control. We are not responsible for the content, privacy policies, or practices of any third-party sites.",
              ),
              _buildSectionTitle("7. Termination"),
              _buildContent(
                "We reserve the right to suspend or terminate your access to our services at any time without notice if we believe you have violated these Terms of Service. Upon termination, your right to use our services will cease immediately.",
              ),
              _buildSectionTitle("8. Indemnification"),
              _buildContent(
                "You agree to defend, indemnify, and hold us harmless from any claims, liabilities, damages, losses, or expenses (including legal fees) arising out of your use of our services or any breach of these terms.",
              ),
              _buildSectionTitle("9. Changes to These Terms"),
              _buildContent(
                "We may revise these Terms of Service at any time. When we do, we will update the effective date at the top of this page. Continued use of our website after such changes constitutes your acceptance of the updated terms.",
              ),
              _buildSectionTitle("10. Governing Law"),
              _buildContent(
                "These Terms of Service are governed by and construed in accordance with the laws of [Your Country/State], without regard to its conflict of law provisions. Any disputes arising from these terms will be subject to the exclusive jurisdiction of the courts in [Your Location].",
              ),
              const SizedBox(height: 80),
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
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
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
