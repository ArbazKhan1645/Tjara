// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/modules/modules_admin/admin/services_admin/insert/attributes_model.dart';

class ServiceAttributesScreen extends StatefulWidget {
  const ServiceAttributesScreen({super.key});

  @override
  _ServiceAttributesScreenState createState() =>
      _ServiceAttributesScreenState();
}

class _ServiceAttributesScreenState extends State<ServiceAttributesScreen> {
  final TextEditingController _nameController = TextEditingController();
  List<ServiceAttribute> _attributes = [];
  List<ServiceAttributeItem> _parentAttributes = [];
  ServiceAttributeItem? _selectedParent;
  bool _isLoading = true;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Edit mode variables
  bool _isEditMode = false;
  ServiceAttributeItem? _editingAttribute;

  @override
  void initState() {
    super.initState();
    _fetchAttributes();
  }

  Future<void> _fetchAttributes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.libanbuy.com/api/service-attributes'),
        headers: {
          'X-Request-From': 'Application',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<ServiceAttribute> attributes = [];
        final List<ServiceAttributeItem> parentAttributes = [];

        for (var item in jsonData['service_attributes']) {
          final attribute = ServiceAttribute.fromJson(item);
          attributes.add(attribute);

          // Add to parent list if it can be a parent
          parentAttributes.addAll(
            attribute.attributeItems!.serviceAttributeItems!,
          );
        }

        setState(() {
          _attributes = attributes;
          _parentAttributes = parentAttributes;
          _isLoading = false;
        });
      } else {
        _showErrorSnackbar('Failed to load attributes');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showErrorSnackbar('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<String?> _uploadMedia(File file) async {
    try {
      final uri = Uri.parse('https://api.libanbuy.com/api/media/insert');
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'X-Request-From': 'Application',
        'Accept': 'application/json',
      });

      final stream = http.ByteStream(file.openRead());
      final length = await file.length();

      final multipartFile = http.MultipartFile(
        'media[]',
        stream,
        length,
        filename: path.basename(file.path),
      );

      request.files.add(multipartFile);

      final response = await request.send();

      if (response.statusCode == 302 || response.statusCode == 301) {
        final redirectUrl = response.headers['location'];
        if (redirectUrl != null) {
          // Handle redirect if needed
          return null;
        }
      }

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonData = jsonDecode(responseBody);
        return jsonData['media'][0]['id'];
      } else {
        _showErrorSnackbar('Failed to upload image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _showErrorSnackbar('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _submitAttribute() async {
    if (_nameController.text.isEmpty) {
      _showErrorSnackbar('Name is required');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // First upload image if selected
      String? thumbnailId;
      if (_selectedImage != null) {
        thumbnailId = await _uploadMedia(_selectedImage!);
        if (thumbnailId == null) {
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      if (_isEditMode && _editingAttribute != null) {
        // Update existing attribute
        await _updateAttribute(thumbnailId);
      } else {
        // Create new attribute
        await _createAttribute(thumbnailId);
      }
    } catch (e) {
      _showErrorSnackbar('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createAttribute(String? thumbnailId) async {
    final response = await http.post(
      Uri.parse('https://api.libanbuy.com/api/service-attribute-items/insert'),
      headers: {
        'X-Request-From': 'Application',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': _nameController.text,
        'parent_id': _selectedParent?.id,
        'thumbnail_id': thumbnailId,
        'attribute_id': _attributes[0].id,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      _showSuccessSnackbar('Attribute created successfully');
      _resetForm();
      _fetchAttributes();
    } else {
      _showErrorSnackbar('Failed to create attribute: ${response.statusCode}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateAttribute(String? thumbnailId) async {
    final response = await http.put(
      Uri.parse(
        'https://api.libanbuy.com/api/service-attribute-items/${_editingAttribute!.id}/update',
      ),
      headers: {
        'X-Request-From': 'Application',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': _nameController.text,
        'parent_id': _selectedParent?.id,
        'thumbnail_id': thumbnailId ?? _editingAttribute!.thumbnailId,
        'attribute_id': _attributes[0].id,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      _showSuccessSnackbar('Attribute updated successfully');
      _resetForm();
      _fetchAttributes();
    } else {
      _showErrorSnackbar('Failed to update attribute: ${response.statusCode}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAttribute(ServiceAttributeItem attribute) async {
    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "${attribute.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.delete(
        Uri.parse(
          'https://api.libanbuy.com/api/service-attribute-items/${attribute.id}/delete',
        ),
        headers: {
          'X-Request-From': 'Application',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _showSuccessSnackbar('Attribute deleted successfully');
        _fetchAttributes();
      } else {
        _showErrorSnackbar(
          'Failed to delete attribute: ${response.statusCode}',
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showErrorSnackbar('Error deleting attribute: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _editAttribute(ServiceAttributeItem attribute) {
    setState(() {
      _isEditMode = true;
      _editingAttribute = attribute;
      _nameController.text = attribute.name.toString();
      _selectedParent =
          _parentAttributes
              .where((parent) => parent.id == attribute.parentId)
              .firstOrNull;
      _selectedImage = null; // Reset image, user can select new one if needed
    });
  }

  void _resetForm() {
    _nameController.clear();
    setState(() {
      _selectedParent = null;
      _selectedImage = null;
      _isEditMode = false;
      _editingAttribute = null;
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    const expandedStackGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFF97316), Color(0xFFFACC15)],
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF97316),
        actions: [const AdminAppBarActionsSimple()],
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
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
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildAddAttributeWidget(),
                        _buildAttributesListWidget(),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildAddAttributeWidget() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Orange Header
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF97316),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isEditMode ? Icons.edit : Icons.add_circle_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isEditMode
                        ? 'Edit Categories Item'
                        : 'Add Categories Item',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name Field
                  const Text(
                    'Categories Item Name*',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Attribute Item Name',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Parent Categories Field
                  const Text(
                    'Parent Categories',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ServiceAttributeItem>(
                    decoration: InputDecoration(
                      hintText: 'Select Parent',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    initialValue: _selectedParent,
                    items: [
                      const DropdownMenuItem<ServiceAttributeItem>(
                        value: null,
                        child: Text('None'),
                      ),
                      ..._parentAttributes.map((attribute) {
                        return DropdownMenuItem<ServiceAttributeItem>(
                          value: attribute,
                          child: Text(attribute.name.toString()),
                        );
                      }),
                    ],
                    onChanged: (ServiceAttributeItem? value) {
                      setState(() {
                        _selectedParent = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Image Upload Section
                  const Text(
                    'Categories Item Image',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          _selectedImage != null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              )
                              : (_isEditMode &&
                                  _editingAttribute
                                          ?.thumbnail
                                          ?.media
                                          ?.localUrl !=
                                      null)
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  _editingAttribute!
                                      .thumbnail!
                                      .media!
                                      .localUrl!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              )
                              : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.landscape,
                                    color: Colors.black,
                                    size: 24,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Upload a file',
                                    style: TextStyle(
                                      color: Color(0xFF165E28),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submitAttribute,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF0D9488,
                            ), // Teal color
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            _isEditMode ? 'Update' : 'Submit',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _resetForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
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

  Widget _buildAttributesListWidget() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Text(
            //   'CATEGORIES ITEMS',
            //   style: TextStyle(
            //     fontSize: 16,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.blue,
            //   ),
            // ),
            // const SizedBox(height: 16),
            Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF97316),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Parent',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: Center(
                          child: Text(
                            'Actions',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // List items
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      _attributes[0]
                          .attributeItems
                          ?.serviceAttributeItems
                          ?.length ??
                      0,
                  itemBuilder: (context, index) {
                    final attribute =
                        _attributes[0]
                            .attributeItems
                            ?.serviceAttributeItems?[index];
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            // Image and Name
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color:
                                          attribute
                                                      ?.thumbnail
                                                      ?.media
                                                      ?.localUrl !=
                                                  null
                                              ? null
                                              : Colors.primaries[index %
                                                  Colors.primaries.length],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child:
                                        attribute?.thumbnail?.media?.localUrl !=
                                                null
                                            ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: Image.network(
                                                attribute
                                                        ?.thumbnail
                                                        ?.media
                                                        ?.localUrl ??
                                                    '',
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                            : Center(
                                              child: Text(
                                                attribute!.name
                                                        .toString()
                                                        .isNotEmpty
                                                    ? attribute.name
                                                        .toString()[0]
                                                    : '',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      attribute!.name.toString(),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Parent
                            Expanded(
                              flex: 1,
                              child: Text(
                                'None',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                            // Actions
                            SizedBox(
                              width: 100,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () => _editAttribute(attribute),
                                    tooltip: 'Edit',
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    onPressed:
                                        () => _deleteAttribute(attribute),
                                    tooltip: 'Delete',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
