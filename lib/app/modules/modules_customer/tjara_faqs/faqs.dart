import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
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

  Future<void> openLocation() async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir//Tjara.com+76G8%2BR62,+Al-Sahili+center+Tyre+Lebanon/@33.2770174,35.2155233,16z',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
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
              const SizedBox(height: 16),

              // Map Section
              GestureDetector(
                onTap: () => controller.openLocation(),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      AbsorbPointer(
                        child: FlutterMap(
                          options: const MapOptions(
                            initialCenter: LatLng(33.2770174, 35.2155233),
                            initialZoom: 15.5,
                            interactionOptions: InteractionOptions(
                              flags: InteractiveFlag.none,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.tjara.app',
                            ),
                            const MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(33.2770174, 35.2155233),
                                  width: 40,
                                  height: 40,
                                  child: Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Bottom overlay with address
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Tjara.com - Al-Sahili Center',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    Text(
                                      'Tyre, Lebanon',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.directions,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Directions',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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

// ========================================
// Dashboard Help Center Screen (Tabbed)
// ========================================
class DashboardHelpCenterScreen extends StatefulWidget {
  const DashboardHelpCenterScreen({super.key});

  @override
  State<DashboardHelpCenterScreen> createState() =>
      _DashboardHelpCenterScreenState();
}

class _DashboardHelpCenterScreenState extends State<DashboardHelpCenterScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final HelpCenterController controller = Get.put(HelpCenterController());
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      controller.stopAllVideos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180,
              floating: false,
              pinned: true,
              backgroundColor: Colors.teal,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF00897B), Color(0xFF004D40)],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.support_agent_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Help Center',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'We\'re here to help you',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(52),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.teal[700],
                    unselectedLabelColor: Colors.grey[500],
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                    indicatorColor: Colors.teal,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.quiz_outlined, size: 20),
                        text: 'FAQs',
                      ),
                      Tab(
                        icon: Icon(Icons.info_outline, size: 20),
                        text: 'Details',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [_buildFAQsTab(), _buildDetailsTab()],
        ),
      ),
    );
  }

  // ── FAQs Tab ──
  Widget _buildFAQsTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(48),
            child: CircularProgressIndicator(
              color: Colors.teal,
              strokeWidth: 3,
            ),
          ),
        );
      }

      if (controller.faqs.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.help_outline_rounded,
                    size: 56,
                    color: Colors.teal[300],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'No FAQs available',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please check back later',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        itemCount: controller.faqs.length,
        itemBuilder: (context, index) {
          final faq = controller.faqs[index];
          return FAQVideoCard(
            key: ValueKey(faq.id),
            faq: faq,
            controller: controller,
          );
        },
      );
    });
  }

  // ── Details Tab ──
  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact section title
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              'Get in Touch',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),

          // Contact cards in a row
          Row(
            children: [
              Expanded(
                child: _buildDetailContactCard(
                  icon: Icons.email_outlined,
                  title: 'Email Us',
                  subtitle: 'support@tjara.com',
                  onTap: () => controller.sendEmail('support@tjara.com'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDetailContactCard(
                  icon: Icons.phone_outlined,
                  title: 'Call Us',
                  subtitle: '81915454',
                  onTap: () => controller.makePhoneCall('81915454'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Visit us card (full width)
          _buildDetailContactCard(
            icon: Icons.location_on_outlined,
            title: 'Visit Us',
            subtitle: '76G8+R62 Al-Sahil center, Tyre, Lebanon',
            onTap: () => controller.openLocation(),
            fullWidth: true,
          ),
          const SizedBox(height: 20),

          // Map section title
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Our Location',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),

          // Map
          GestureDetector(
            onTap: () => controller.openLocation(),
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  AbsorbPointer(
                    child: FlutterMap(
                      options: const MapOptions(
                        initialCenter: LatLng(33.2770174, 35.2155233),
                        initialZoom: 15.5,
                        interactionOptions: InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.tjara.app',
                        ),
                        const MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(33.2770174, 35.2155233),
                              width: 40,
                              height: 40,
                              child: Icon(
                                Icons.location_on,
                                color: Colors.teal,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Tjara.com - Al-Sahili Center',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Tyre, Lebanon',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.directions,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Directions',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDetailContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool fullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              fullWidth ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.teal, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: Colors.teal[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: fullWidth ? TextAlign.start : TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoursRow(String day, String hours) {
    final isClosed = hours == 'Closed';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(day, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color:
                isClosed
                    ? Colors.red.withValues(alpha: 0.08)
                    : Colors.teal.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            hours,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isClosed ? Colors.red[400] : Colors.teal[700],
            ),
          ),
        ),
      ],
    );
  }
}
