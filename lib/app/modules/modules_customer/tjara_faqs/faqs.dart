import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tjara/app/models/posts/posts_model.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

// Controller
class HelpCenterController extends GetxController {
  var faqs = <PostModel>[].obs;
  var isLoading = false.obs;
  var isDeleting = false.obs;

  // Track currently playing FAQ ID - only one video can play at a time
  var currentlyPlayingFaqId = Rxn<String>();

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
          '$baseUrl/posts?with=thumbnail,shop,video&filterByColumns[filterJoin]=AND&filterByColumns[columns][0][column]=status&filterByColumns[columns][0][operator]=%3D&filterByColumns[columns][0][value]=active&filterByColumns[columns][1][column]=post_type&filterByColumns[columns][1][operator]=%3D&filterByColumns[columns][1][value]=faqs',
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

  // Set currently playing FAQ - stops other videos
  void setCurrentlyPlaying(String? faqId) {
    currentlyPlayingFaqId.value = faqId;
  }

  // Stop all videos
  void stopAllVideos() {
    currentlyPlayingFaqId.value = null;
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

class _HelpCenterScreenState extends State<HelpCenterScreen>
    with WidgetsBindingObserver {
  final HelpCenterController controller = Get.put(HelpCenterController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Stop all videos when app is minimized/paused
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      controller.stopAllVideos();
    }
  }

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
                      child: LinearProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
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
                      controller.faqs
                          .map(
                            (faq) => FAQVideoCard(
                              key: ValueKey(faq.id),
                              faq: faq,
                              controller: controller,
                            ),
                          )
                          .toList(),
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
}

// FAQ Card with Video Player
class FAQVideoCard extends StatefulWidget {
  final PostModel faq;
  final HelpCenterController controller;

  const FAQVideoCard({super.key, required this.faq, required this.controller});

  @override
  State<FAQVideoCard> createState() => _FAQVideoCardState();
}

class _FAQVideoCardState extends State<FAQVideoCard> {
  VideoPlayerController? _videoController;
  bool _isExpanded = false;
  bool _isVideoInitialized = false;
  bool _isVideoLoading = false;
  bool _hasError = false;

  // Extract video URL from description HTML if video property is null
  String? _extractVideoUrlFromDescription(String description) {
    // Match src attribute in <source> tags (for video inside source tag)
    final RegExp sourceRegex = RegExp(
      r'<source[^>]+src="([^"]+\.mp4)"',
      caseSensitive: false,
    );
    final sourceMatch = sourceRegex.firstMatch(description);
    if (sourceMatch != null) {
      return sourceMatch.group(1);
    }

    // Also try matching video src directly
    final RegExp videoSrcRegex = RegExp(
      r'<video[^>]+src="([^"]+\.mp4)"',
      caseSensitive: false,
    );
    final videoMatch = videoSrcRegex.firstMatch(description);
    if (videoMatch != null) {
      return videoMatch.group(1);
    }

    // Try matching any .mp4 URL in the description
    final RegExp mp4UrlRegex = RegExp(
      r'(https?://[^\s"<>]+\.mp4)',
      caseSensitive: false,
    );
    final mp4Match = mp4UrlRegex.firstMatch(description);
    if (mp4Match != null) {
      return mp4Match.group(1);
    }

    return null;
  }

  String? get _videoUrl {
    // First try video property
    final videoPropertyUrl =
        widget.faq.video?.media?.url ??
        widget.faq.video?.media?.cdnUrl ??
        widget.faq.video?.media?.localUrl ??
        widget.faq.video?.media?.optimizedMediaCdnUrl ??
        widget.faq.video?.media?.optimizedMediaUrl;

    if (videoPropertyUrl != null && videoPropertyUrl.isNotEmpty) {
      return videoPropertyUrl;
    }

    // If video property is null, try extracting from description
    return _extractVideoUrlFromDescription(widget.faq.description);
  }

  bool get _hasVideo => _videoUrl != null && _videoUrl!.isNotEmpty;

  // Clean description text - remove video elements, media containers, and HTML tags
  String _cleanDescription(String description) {
    String cleaned = description;

    // Remove video tags with all content (including source tags inside)
    cleaned = cleaned.replaceAll(
      RegExp(r'<video[^>]*>.*?</video>', dotAll: true),
      '',
    );

    // Remove standalone source tags
    cleaned = cleaned.replaceAll(RegExp(r'<source[^>]*>'), '');

    // Remove "Your browser does not support the video tag." text
    cleaned = cleaned.replaceAll(
      RegExp(
        r'Your browser does not support the video tag\.',
        caseSensitive: false,
      ),
      '',
    );

    // Remove all HTML tags but keep text content
    cleaned = cleaned.replaceAll(RegExp(r'<[^>]*>'), '');

    // Decode HTML entities
    cleaned = cleaned
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"');

    // Clean up extra whitespace and newlines
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    // Trim the result
    return cleaned.trim();
  }

  @override
  void dispose() {
    _disposeVideoController();
    super.dispose();
  }

  void _disposeVideoController() {
    if (_videoController != null) {
      _videoController!.pause();
      _videoController!.dispose();
      _videoController = null;
      _isVideoInitialized = false;
    }
  }

  Future<void> _initializeVideo() async {
    if (!_hasVideo || _isVideoInitialized || _isVideoLoading) return;

    setState(() {
      _isVideoLoading = true;
      _hasError = false;
    });

    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(_videoUrl!),
      );
      await _videoController!.initialize();

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
          _isVideoLoading = false;
        });

        // Auto-play when initialized and expanded
        if (_isExpanded) {
          _playVideo();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVideoLoading = false;
          _hasError = true;
        });
      }
    }
  }

  void _playVideo() {
    if (_videoController != null && _isVideoInitialized) {
      // Stop other videos first
      widget.controller.setCurrentlyPlaying(widget.faq.id);
      _videoController!.play();
    }
  }

  void _pauseVideo() {
    if (_videoController != null) {
      _videoController!.pause();
      if (widget.controller.currentlyPlayingFaqId.value == widget.faq.id) {
        widget.controller.setCurrentlyPlaying(null);
      }
    }
  }

  void _onExpansionChanged(bool expanded) {
    setState(() {
      _isExpanded = expanded;
    });

    if (expanded && _hasVideo) {
      if (!_isVideoInitialized) {
        _initializeVideo();
      } else {
        _playVideo();
      }
    } else {
      _pauseVideo();
    }
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    // Pause video if less than 50% visible
    if (info.visibleFraction < 0.5 && _isExpanded) {
      _disposeVideoController();
    } else {
      _initializeVideo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('faq-video-${widget.faq.id}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: Obx(() {
        // Listen for changes in currently playing FAQ
        final currentlyPlaying = widget.controller.currentlyPlayingFaqId.value;

        // If another FAQ started playing, pause this one
        if (currentlyPlaying != null &&
            currentlyPlaying != widget.faq.id &&
            _videoController != null &&
            _videoController!.value.isPlaying) {
          _videoController!.pause();
        }

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
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              onExpansionChanged: _onExpansionChanged,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _hasVideo ? Icons.play_circle_outline : Icons.arrow_back,
                  color: Colors.red,
                  size: 16,
                ),
              ),
              title: Text(
                widget.faq.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
              children: [
                // Video Player Section
                if (_hasVideo) ...[
                  _buildVideoPlayer(),
                  const SizedBox(height: 12),
                ],
                // Answer Text
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _cleanDescription(widget.faq.description),
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
      }),
    );
  }

  Widget _buildVideoPlayer() {
    if (_isVideoLoading) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    if (_hasError) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.grey[600], size: 40),
              const SizedBox(height: 8),
              Text(
                'Failed to load video',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  _disposeVideoController();
                  _initializeVideo();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isVideoInitialized || _videoController == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_videoController!),
            // Play/Pause overlay
            GestureDetector(
              onTap: () {
                if (_videoController!.value.isPlaying) {
                  _pauseVideo();
                } else {
                  _playVideo();
                }
                setState(() {});
              },
              child: Container(
                color: Colors.transparent,
                child: AnimatedOpacity(
                  opacity: _videoController!.value.isPlaying ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
            // Progress indicator
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _videoController!,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Colors.red,
                  bufferedColor: Colors.grey,
                  backgroundColor: Colors.black26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
