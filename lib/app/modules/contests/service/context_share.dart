// reward_share_service.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class RewardShareService {
  static Future<void> showShareDialog({
    required BuildContext context,
    required String contestName,
    required String contestUrl,
    required VoidCallback onShare,
  }) async {
    bool isShared = false;
    String? statusMessage;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Share to Continue',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(dialogContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Instructions
                    const Text(
                      'Please share this contest with either:',
                      textAlign: TextAlign.start,

                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• 5 contacts on WhatsApp, or',
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 14),
                    ),
                    const Text(
                      '• Post it on one of your social media channels',
                      style: TextStyle(fontSize: 14),
                    ),
                    const Text(
                      'to continue with your submission.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 30),

                    // Social Media Icons - Row 1
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSocialButton(
                          icon: Icons.chat,
                          label: 'WhatsApp',
                          color: const Color(0xFF25D366),
                          onTap:
                              () => _shareToWhatsApp(
                                contestName,
                                contestUrl,
                                () {
                                  setState(() {
                                    isShared = true;
                                    statusMessage = null;
                                  });
                                  onShare();
                                },
                                (error) {
                                  setState(() => statusMessage = error);
                                },
                              ),
                        ),
                        _buildSocialButton(
                          icon: Icons.facebook,
                          label: 'Facebook',
                          color: const Color(0xFF1877F2),
                          onTap:
                              () => _shareToFacebook(
                                contestName,
                                contestUrl,
                                () {
                                  setState(() {
                                    isShared = true;
                                    statusMessage = null;
                                  });
                                  onShare();
                                },
                                (error) {
                                  setState(() => statusMessage = error);
                                },
                              ),
                        ),
                        _buildSocialButton(
                          icon: Icons.flutter_dash,
                          label: 'Twitter',
                          color: const Color(0xFF1DA1F2),
                          onTap:
                              () => _shareToTwitter(
                                contestName,
                                contestUrl,
                                () {
                                  setState(() {
                                    isShared = true;
                                    statusMessage = null;
                                  });
                                  onShare();
                                },
                                (error) {
                                  setState(() => statusMessage = error);
                                },
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Social Media Icons - Row 2
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSocialButton(
                          icon: Icons.linked_camera,
                          label: 'LinkedIn',
                          color: const Color(0xFF0A66C2),
                          onTap:
                              () => _shareToLinkedIn(
                                contestName,
                                contestUrl,
                                () {
                                  setState(() {
                                    isShared = true;
                                    statusMessage = null;
                                  });
                                  onShare();
                                },
                                (error) {
                                  setState(() => statusMessage = error);
                                },
                              ),
                        ),
                        _buildSocialButton(
                          icon: Icons.pin,
                          label: 'Pinterest',
                          color: const Color(0xFFE60023),
                          onTap:
                              () => _shareToPinterest(
                                contestName,
                                contestUrl,
                                () {
                                  setState(() {
                                    isShared = true;
                                    statusMessage = null;
                                  });
                                  onShare();
                                },
                                (error) {
                                  setState(() => statusMessage = error);
                                },
                              ),
                        ),
                        _buildSocialButton(
                          icon: Icons.link,
                          label: 'Copy Link',
                          color: Colors.grey,
                          onTap:
                              () => _copyLink(
                                contestName,
                                contestUrl,
                                () {
                                  setState(() {
                                    isShared = true;
                                    statusMessage = 'Link copied!';
                                  });
                                  onShare();
                                },
                                (error) {
                                  setState(() => statusMessage = error);
                                },
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Status Messages
                    if (statusMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              statusMessage!.toLowerCase().contains('error') ||
                                      statusMessage!.toLowerCase().contains(
                                        'not',
                                      ) ||
                                      statusMessage!.toLowerCase().contains(
                                        'could not',
                                      )
                                  ? Colors.red.shade50
                                  : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              statusMessage!.toLowerCase().contains('error') ||
                                      statusMessage!.toLowerCase().contains(
                                        'not',
                                      ) ||
                                      statusMessage!.toLowerCase().contains(
                                        'could not',
                                      )
                                  ? Icons.error_outline
                                  : Icons.info_outline,
                              color:
                                  statusMessage!.toLowerCase().contains(
                                            'error',
                                          ) ||
                                          statusMessage!.toLowerCase().contains(
                                            'not',
                                          ) ||
                                          statusMessage!.toLowerCase().contains(
                                            'could not',
                                          )
                                      ? Colors.red.shade700
                                      : Colors.blue.shade700,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                statusMessage!,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (statusMessage != null) const SizedBox(height: 16),

                    // Confirmation Checkbox
                    if (isShared)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Thanks for sharing! You can now close this popup and submit your answers.',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  static Future<void> _shareToWhatsApp(
    String contestName,
    String url,
    VoidCallback onSuccess,
    Function(String) onError,
  ) async {
    final message =
        '🎮 Hey! I found an exciting contest - want to try your luck?\n\n$contestName\n\n$url';

    try {
      // WhatsApp specific URL scheme for Android
      final whatsappUrl = Uri.parse(
        'whatsapp://send?text=${Uri.encodeComponent(message)}',
      );

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
        onSuccess();
      } else {
        // Fallback to web WhatsApp
        final webWhatsappUrl = Uri.parse(
          'https://wa.me/?text=${Uri.encodeComponent(message)}',
        );
        await launchUrl(webWhatsappUrl, mode: LaunchMode.externalApplication);
        onSuccess();
      }
    } catch (e) {
      onError('WhatsApp is not installed or could not be opened');
    }
  }

  static Future<void> _shareToFacebook(
    String contestName,
    String url,
    VoidCallback onSuccess,
    Function(String) onError,
  ) async {
    try {
      // For Facebook, we need to use Share Dialog via browser
      // Facebook doesn't allow pre-filled text due to policy
      // Only the URL can be shared
      final message =
          '🎮 Hey! I found an exciting contest - want to try your luck?\n\n$contestName';

      // Try different methods
      final methods = [
        // Method 1: Try native share if available (Android 10+)
        () async {
          final shareUrl = Uri.parse(
            'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(url)}&quote=${Uri.encodeComponent(message)}',
          );
          return await launchUrl(
            shareUrl,
            mode: LaunchMode.externalApplication,
          );
        },
        // Method 2: Try Facebook app
        () async {
          final fbUrl = Uri.parse(
            'fb://facewebmodal/f?href=${Uri.encodeComponent(url)}',
          );
          return await launchUrl(fbUrl);
        },
      ];

      bool success = false;
      for (var method in methods) {
        try {
          if (await method()) {
            success = true;
            break;
          }
        } catch (e) {
          continue;
        }
      }

      if (success) {
        onSuccess();
      } else {
        onError(
          'Could not open Facebook. Try copying the link and sharing manually.',
        );
      }
    } catch (e) {
      onError('Facebook sharing failed. Please try another option.');
    }
  }

  static Future<void> _shareToTwitter(
    String contestName,
    String url,
    VoidCallback onSuccess,
    Function(String) onError,
  ) async {
    final message =
        '🎮 Hey! I found an exciting contest - want to try your luck? $contestName';

    try {
      // Try Twitter app first (X app)
      final twitterAppUrl = Uri.parse(
        'twitter://post?message=${Uri.encodeComponent("$message\n$url")}',
      );

      bool launched = false;

      try {
        if (await canLaunchUrl(twitterAppUrl)) {
          launched = await launchUrl(twitterAppUrl);
        }
      } catch (e) {
        launched = false;
      }

      if (!launched) {
        // Fallback to web Twitter
        final twitterWebUrl = Uri.parse(
          'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(message)}&url=${Uri.encodeComponent(url)}',
        );
        launched = await launchUrl(
          twitterWebUrl,
          mode: LaunchMode.externalApplication,
        );
      }

      if (launched) {
        onSuccess();
      } else {
        onError('Could not open Twitter/X');
      }
    } catch (e) {
      onError('Twitter sharing failed. Please try another option.');
    }
  }

  static Future<void> _shareToLinkedIn(
    String contestName,
    String url,
    VoidCallback onSuccess,
    Function(String) onError,
  ) async {
    try {
      // LinkedIn doesn't support pre-filled text via URL
      // Only URL can be shared, user has to add text manually

      // Try LinkedIn app first
      final linkedInAppUrl = Uri.parse(
        'linkedin://shareArticle?url=${Uri.encodeComponent(url)}',
      );

      bool launched = false;

      try {
        if (await canLaunchUrl(linkedInAppUrl)) {
          launched = await launchUrl(linkedInAppUrl);
        }
      } catch (e) {
        launched = false;
      }

      if (!launched) {
        // Fallback to web LinkedIn
        final linkedInWebUrl = Uri.parse(
          'https://www.linkedin.com/sharing/share-offsite/?url=${Uri.encodeComponent(url)}',
        );
        launched = await launchUrl(
          linkedInWebUrl,
          mode: LaunchMode.externalApplication,
        );
      }

      if (launched) {
        onSuccess();
      } else {
        onError('Could not open LinkedIn');
      }
    } catch (e) {
      onError('LinkedIn sharing failed. Please try another option.');
    }
  }

  static Future<void> _shareToPinterest(
    String contestName,
    String url,
    VoidCallback onSuccess,
    Function(String) onError,
  ) async {
    try {
      final description =
          '🎮 Hey! I found an exciting contest - want to try your luck? $contestName';

      // Try Pinterest app first
      final pinterestAppUrl = Uri.parse(
        'pinterest://pin/create/button/?url=${Uri.encodeComponent(url)}&description=${Uri.encodeComponent(description)}',
      );

      bool launched = false;

      try {
        if (await canLaunchUrl(pinterestAppUrl)) {
          launched = await launchUrl(pinterestAppUrl);
        }
      } catch (e) {
        launched = false;
      }

      if (!launched) {
        // Fallback to web Pinterest
        final pinterestWebUrl = Uri.parse(
          'https://pinterest.com/pin/create/button/?url=${Uri.encodeComponent(url)}&description=${Uri.encodeComponent(description)}',
        );
        launched = await launchUrl(
          pinterestWebUrl,
          mode: LaunchMode.externalApplication,
        );
      }

      if (launched) {
        onSuccess();
      } else {
        onError('Could not open Pinterest');
      }
    } catch (e) {
      onError('Pinterest sharing failed. Please try another option.');
    }
  }

  static Future<void> _copyLink(
    String contestName,
    String url,
    VoidCallback onSuccess,
    Function(String) onError,
  ) async {
    final message =
        '🎮 Hey! I found an exciting contest - want to try your luck?\n\n$contestName\n\n$url';

    try {
      await Clipboard.setData(ClipboardData(text: message));
      onSuccess();
    } catch (e) {
      onError('Failed to copy link');
    }
  }
}
