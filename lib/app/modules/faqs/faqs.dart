import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tjara/app/models/posts/posts_model.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

// Controller
class HelpCenterController extends GetxController {
  var faqs = <PostModel>[].obs;
  var isLoading = false.obs;
  var isDeleting = false.obs;

  final String baseUrl = 'https://api.libanbuy.com/api';

  @override
  void onInit() {
    super.onInit();
    fetchFAQs();
  }

  Future<void> fetchFAQs() async {
    try {
      isLoading.value = true;

      final response = await http.get(
        Uri.parse(
          '$baseUrl/posts?with=thumbnail,shop&filterByColumns[filterJoin]=AND&filterByColumns[columns][0][column]=status&filterByColumns[columns][0][operator]=%3D&filterByColumns[columns][0][value]=active&filterByColumns[columns][1][column]=post_type&filterByColumns[columns][1][operator]=%3D&filterByColumns[columns][1][value]=faqs',
        ),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-Request-From': 'Application',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['posts'] != null) {
          final List<dynamic> faqList = data['posts']['data'];
          faqs.value = faqList.map((json) => PostModel.fromJson(json)).toList();
        } else {
          faqs.value = [];
        }
      } else {
        throw Exception('Failed to load FAQs: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading FAQs: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }

  Future<void> sendEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    await launchUrl(launchUri);
  }

  Future<void> openLocation() async {}
}

// Main Screen
class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final HelpCenterController controller = Get.put(HelpCenterController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        // appBar: AppBar(
        //   backgroundColor: Colors.white,
        //   elevation: 1,
        //   leading: IconButton(
        //     icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
        //     onPressed: () {
        //       // Navigate back to More view (index 4 in dashboard)
        //       DashboardController.instance.changeIndex(4);
        //     },
        //   ),
        //   title: Text(
        //     'Help Center',
        //     style: TextStyle(
        //       color: Colors.grey[800],
        //       fontSize: 20,
        //       fontWeight: FontWeight.bold,
        //     ),
        //   ),
        //   centerTitle: false,
        // ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Help Center',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 24),

              // Contact Cards
              _buildContactCard(
                icon: Icons.email_outlined,
                iconColor: Colors.green,
                title: 'Email Us',
                subtitle: 'support@tjara.com',
                onTap: () => controller.sendEmail('support@tjara.com'),
              ),
              const SizedBox(height: 16),

              _buildContactCard(
                icon: Icons.phone_outlined,
                iconColor: Colors.green,
                title: 'Call Us',
                subtitle: '81915454',
                description: 'Mon - Fri, 9:00 AM - 6:00 PM',
                onTap: () => controller.makePhoneCall('81915454'),
              ),
              const SizedBox(height: 16),

              _buildContactCard(
                icon: Icons.location_on_outlined,
                iconColor: Colors.green,
                title: 'Visit Us',
                subtitle: '76G8+R62 Al-Sahil center',
                description: 'Tyre, Lebanon',
                onTap: () => controller.openLocation(),
              ),
              const SizedBox(height: 32),

              // FAQs Section
              Text(
                'FAQs',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),

              // FAQ List
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ),
                  );
                }

                if (controller.faqs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.help_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No FAQs available',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please try again later',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children:
                      controller.faqs.map((faq) => _buildFAQCard(faq)).toList(),
                );
              }),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFAQCard(PostModel faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.red, size: 16),
          ),
          title: Text(
            faq.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                faq.description.replaceAll(
                  RegExp(r'<[^>]*>'),
                  '',
                ), // Remove HTML tags
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
