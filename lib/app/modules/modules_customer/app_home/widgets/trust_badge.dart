import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_customer/tjara_jobs/views/tjara_jobs_view.dart';

/// Temu-style Trust Badges Widget
/// Shows features like Free shipping, Delivery guarantee, Safe payments
class TrustBadgesWidget extends StatelessWidget {
  const TrustBadgesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF015c5d),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Icon on the left
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.people_alt,
                size: 30,
                color: Color(0xFF015c5d),
              ),
            ),
            const SizedBox(width: 12),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Are you looking for a job?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Find your next career adventure with us. We offer a range of positions across various industries and skill levels',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),

                      // Button on the right
                      GestureDetector(
                        onTap: () {
                          Get.to(() => const TjaraJobsView());
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFfe961a),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'View',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
