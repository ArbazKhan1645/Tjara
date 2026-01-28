import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/models/jobs/jobs_model.dart';
import 'package:tjara/app/modules/modules_customer/tjara_jobs/views/tjara_jobs_view.dart';
import 'package:tjara/app/modules/modules_customer/tjara_jobs/widgets/apply.dart';

class JobDetailScreen extends StatelessWidget {
  final Job job;

  const JobDetailScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFFfda730),
        title: const Text(
          'Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildJobHeader(), const SizedBox(height: 100)],
        ),
      ),
      floatingActionButton: _buildApplyButton(),
    );
  }

  Widget _buildApplyButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        MaterialButton(
          onPressed: () {
            Get.to(() => JobApplicationScreen(jobId: job.id, job: job));
          },
          color: const Color(0xFFfda730),
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: const Text(
            'Apply',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJobHeader() {
    final imageUrl =
        job.thumbnail.media?.optimizedMediaUrl ?? job.thumbnail.media?.url;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            Get.to(() => JobDetailScreen(job: job));
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CachedImageWidget(imageUrl: imageUrl ?? ''),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${job.country.name}, ${job.city.name}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100, // Light grey background
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${job.country.currencyCode}${job.salary} ',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCE7EA), // Light pink background
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Full Time',
                        style: TextStyle(
                          color: Color(0xFFD11F42), // Dark pink text
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  child: Html(
                    data: job.description,
                    style: {
                      "body": Style(
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                        fontSize: FontSize(14),
                      ),
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Posted on: ${DateFormat('MMM dd, yyyy').format(job.createdAt)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
