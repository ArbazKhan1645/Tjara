// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/models/posts/posts_model.dart';

import 'package:tjara/app/modules/modules_admin/admin/services_admin/insert/attributes_model.dart';

class InsertStoryScreen extends StatefulWidget {
  final PostModel? existingPost; // For edit mode
  final bool isEditMode;

  const InsertStoryScreen({
    super.key,
    this.existingPost,
    this.isEditMode = false,
  });

  @override
  State<InsertStoryScreen> createState() => _InsertStoryScreenState();
}

class _InsertStoryScreenState extends State<InsertStoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _linkController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _salePriceController = TextEditingController();

  // Selection values
  ServiceAttributeItem? _selectedCategory;

  final List<String> _selectedTags = [];

  // Media IDs
  String? thumbnailId;
  String? videoId;
  List<String> galleryIds = [];

  // Media files
  File? thumbnailFile;
  File? videoFile;
  List<File> galleryFiles = [];

  // Form sections expanded state
  final bool _serviceInfoExpanded = true;
  final bool _uploadServiceExpanded = true;

  // Loading state
  bool _isLoading = false;

  // Status toggle
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  void _initializeFormData() {
    if (widget.isEditMode && widget.existingPost != null) {
      final post = widget.existingPost!;
      _nameController.text = post.name ?? '';

      thumbnailId = post.thumbnailId;
      videoId = post.video?.media?.id;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subtitleController.dispose();
    _linkController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _salePriceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, {bool isGallery = false}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final File file = File(pickedFile.path);

        setState(() {
          if (isGallery) {
            galleryFiles.add(file);
            _uploadMedia([file]).then((mediaIds) {
              if (mediaIds.isNotEmpty) {
                galleryIds.addAll(mediaIds);
              }
            });
          } else {
            thumbnailFile = file;
            _uploadMedia([file]).then((mediaIds) {
              if (mediaIds.isNotEmpty) {
                thumbnailId = mediaIds.first;
              }
            });
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _pickVideo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        final File file = File(pickedFile.path);

        setState(() {
          videoFile = file;
        });

        final List<String> mediaIds = await _uploadMedia([file]);
        if (mediaIds.isNotEmpty) {
          videoId = mediaIds.first;
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking video: $e')));
    }
  }

  Future<String> uploadMedia(
    List<File> files, {
    String? directory,
    int? width,
    int? height,
  }) async {
    final uri = Uri.parse('https://api.libanbuy.com/api/media/insert');

    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'X-Request-From': 'Application',
      'Accept': 'application/json',
      'Content-Type': 'multipart/form-data',
    });

    // Add media files
    for (var file in files) {
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();

      final multipartFile = http.MultipartFile(
        'media[]',
        stream,
        length,
        filename: path.basename(file.path),
      );

      request.files.add(multipartFile);
    }

    // Add optional parameters
    if (directory != null) {
      request.fields['directory'] = directory;
    }

    if (width != null) {
      request.fields['width'] = width.toString();
    }

    if (height != null) {
      request.fields['height'] = height.toString();
    }

    // Send request and allow redirects
    final response = await request.send();

    // Handle redirect manually
    if (response.statusCode == 302 || response.statusCode == 301) {
      final redirectUrl = response.headers['location'];
      if (redirectUrl != null) {
        return await uploadMedia(
          files,
          directory: directory,
          width: width,
          height: height,
        );
      }
    }

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonData = jsonDecode(responseBody);

      return jsonData['media'][0]['id'];
    } else {
      return 'Failed to upload media. Status code: ${response.statusCode} Response body: ${await response.stream.bytesToString()}';
    }
  }

  Future<List<String>> _uploadMedia(
    List<File> files, {
    String? directory,
    int? width,
    int? height,
  }) async {
    final List<String> mediaIds = [];
    final String id = await uploadMedia(
      files,
      directory: directory,
      width: width,
      height: height,
    );
    if (!id.contains('Failed to upload media')) {
      mediaIds.add(id);
    }
    return mediaIds;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (thumbnailId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a thumbnail image')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic> body = {
        'name': _nameController.text,
        'post_type': 'shop_stories',
        'thumbnail_id': thumbnailId,
        'is_featured': true,
      };

      // Add optional fields if they have values
      if (_subtitleController.text.isNotEmpty) {
        body['subtitle'] = _subtitleController.text;
      }

      if (_linkController.text.isNotEmpty) {
        body['link'] = _linkController.text;
      }

      if (_descriptionController.text.isNotEmpty) {
        body['description'] = _descriptionController.text;
      }

      if (_priceController.text.isNotEmpty) {
        body['price'] = _priceController.text;
      }

      if (_salePriceController.text.isNotEmpty) {
        body['sale_price'] = _salePriceController.text;
      }

      // Add gallery images if any
      if (galleryIds.isNotEmpty) {
        body['gallery'] = galleryIds;
      }

      // Add video if any
      if (videoId != null) {
        body['video_id'] = videoId;
      }

      // Add categories if any
      if (_selectedCategory != null) {
        body['categories'] = [_selectedCategory!.id];
      }

      // Add tags if any
      if (_selectedTags.isNotEmpty) {
        body['tags'] = _selectedTags;
      }

      // Determine URL based on mode
      String url;
      http.Response response;

      if (widget.isEditMode && widget.existingPost?.id != null) {
        url =
            'https://api.libanbuy.com/api/posts/${widget.existingPost!.id}/update';
        // Use PUT for edit
        response = await http.put(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'shop-id': '0000c539-9857-3456-bc53-2bbdc1474f1a',
            'X-Request-From': 'Application',
          },
          body: jsonEncode(body),
        );
      } else {
        url = 'https://api.libanbuy.com/api/posts/insert/';
        // Use POST for create
        response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'shop-id': '0000c539-9857-3456-bc53-2bbdc1474f1a',
            'X-Request-From': 'Application',
          },
          body: jsonEncode(body),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final successMessage =
            widget.isEditMode
                ? 'Story updated successfully'
                : 'Story created successfully';

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(successMessage)));

        // Navigate back or to stories list
        Navigator.of(context).pop(true);
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage =
            widget.isEditMode
                ? 'Failed to update Story'
                : 'Failed to create Story';

        if (errorData != null && errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const expandedStackGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFF97316), Color(0xFFFACC15)],
    );

    final String screenTitle =
        widget.isEditMode ? 'Edit Story' : 'Create Story';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF97316),
        actions: [const AdminAppBarActionsSimple()],
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(screenTitle, style: const TextStyle(color: Colors.white)),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    decoration: const BoxDecoration(
                      gradient: expandedStackGradient,
                    ),
                  ),
                  // Content
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Upload Story Section
                          _buildSectionContainer('Upload Story', [
                            _buildMediaUpload(
                              label: 'Story Video',
                              isRequired: true,
                              helperText:
                                  'High Quality video can significantly impact your story\'s appeal.',
                              file: videoFile,
                              onUpload: _pickVideo,
                              isVideo: true,
                              mediaId: videoId,
                            ),
                            const SizedBox(height: 24),
                            _buildMediaUpload(
                              label: 'Story Thumbnail',
                              isRequired: true,
                              helperText:
                                  'High Quality thumbnail can significantly impact your story\'s appeal.',
                              file: thumbnailFile,
                              onUpload: () => _pickImage(ImageSource.gallery),
                              mediaId: thumbnailId,
                            ),
                          ]),
                          const SizedBox(height: 16),

                          // Information Section
                          _buildSectionContainer('Information', [
                            _buildTextField(
                              label: 'Story Title',
                              controller: _nameController,
                              isRequired: true,
                              hintText: 'Story name',
                              helperText:
                                  'Enter the unique title of your story.',
                            ),
                            const SizedBox(height: 24),
                            _buildTextField(
                              label: 'Story Sub Title',
                              controller: _subtitleController,
                              isRequired: true,
                              hintText: 'Story Sub Title',
                              helperText:
                                  'Enter the Descriptive/subtitle of your story. Make it descriptive and easy to remember for customers.',
                            ),
                            const SizedBox(height: 24),
                            _buildTextField(
                              label: 'Story Link',
                              controller: _linkController,
                              isRequired: true,
                              hintText: 'Story Link',
                              helperText:
                                  'Add the link where you want the story to redirect users.',
                            ),
                          ]),
                          const SizedBox(height: 16),

                          // Story Management Section
                          _buildSectionContainer('Story Management', [
                            _buildStatusToggle(),
                          ]),
                          const SizedBox(height: 32),

                          // Submit Button
                          ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF97316),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 32,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              _isLoading
                                  ? (widget.isEditMode
                                      ? 'Updating...'
                                      : 'Saving...')
                                  : (widget.isEditMode
                                      ? 'Update Story'
                                      : 'Save Story'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildSectionContainer(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - Separate container with padding from all sides
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF97316),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool isRequired,
    String? hintText,
    String? helperText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFF97316),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              filled: true,
              fillColor: Colors.transparent,
            ),
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator:
                isRequired
                    ? (value) {
                      if (value == null || value.isEmpty) {
                        return '$label is required';
                      }
                      return null;
                    }
                    : null,
          ),
        ),
      ],
    );
  }

  Widget _buildMediaUpload({
    required String label,
    required bool isRequired,
    required String helperText,
    required File? file,
    required VoidCallback onUpload,
    bool isVideo = false,
    String? mediaId,
  }) {
    // Show existing media if in edit mode and no new file selected
    final bool hasExistingMedia =
        widget.isEditMode && mediaId != null && file == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          helperText,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onUpload,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                file == null && !hasExistingMedia
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.upload_file,
                            size: 32,
                            color: Color(0xFFF97316),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Upload a file',
                            style: TextStyle(
                              color: Color(0xFFF97316),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                    : hasExistingMedia
                    ? Stack(
                      alignment: Alignment.center,
                      children: [
                        if (isVideo) ...[
                          Icon(
                            Icons.video_library,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const Text(
                            'Existing Video',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ] else ...[
                          Icon(Icons.image, size: 64, color: Colors.grey[400]),
                          const Text(
                            'Existing Image',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                        Positioned(
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Tap to replace',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                if (isVideo) {
                                  videoFile = null;
                                  videoId = null;
                                } else {
                                  thumbnailFile = null;
                                  thumbnailId = null;
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    )
                    : isVideo
                    ? Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.video_library,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const Text(
                          'Video Selected',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                videoFile = null;
                                videoId = null;
                              });
                            },
                          ),
                        ),
                      ],
                    )
                    : Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(file!, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                thumbnailFile = null;
                                thumbnailId = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildGalleryUpload({
    required String label,
    required bool isRequired,
    required String helperText,
    required List<File> files,
    required VoidCallback onUpload,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          helperText,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              if (files.isNotEmpty ||
                  (widget.isEditMode && galleryIds.isNotEmpty)) ...[
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        files.length +
                        (widget.isEditMode ? galleryIds.length : 0),
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      // Show existing gallery items first (in edit mode)
                      if (widget.isEditMode && index < galleryIds.length) {
                        return Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[200],
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image,
                                      color: Colors.grey[400],
                                      size: 32,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Existing',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 12,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    galleryIds.removeAt(index);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      // Show new uploaded files
                      final int fileIndex =
                          index - (widget.isEditMode ? galleryIds.length : 0);
                      return Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(files[fileIndex]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 12,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  galleryFiles.removeAt(fileIndex);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
              InkWell(
                onTap: onUpload,
                child: Container(
                  height:
                      files.isEmpty &&
                              (!widget.isEditMode || galleryIds.isEmpty)
                          ? 150
                          : 80,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.upload_file,
                        size: 32,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload a file or drag and drop',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Banner Status',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose the Status that best reflects the availability of this banner for customers.',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _isActive ? const Color(0xFFF97316) : Colors.grey[600],
                ),
              ),
              Switch(
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
                activeThumbColor: const Color(0xFFF97316),
                activeTrackColor: const Color(0xFFF97316).withOpacity(0.3),
                inactiveThumbColor: Colors.grey[400],
                inactiveTrackColor: Colors.grey[200],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
