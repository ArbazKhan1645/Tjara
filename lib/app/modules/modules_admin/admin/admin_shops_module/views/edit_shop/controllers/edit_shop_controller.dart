import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tjara/app/modules/modules_admin/admin/admin_shops_module/const/app_urls.dart';
import 'package:path/path.dart' as path;

class EditShopController extends GetxController {
  var selectedIndex = 0.obs;

  final List<String> titles = [
    'Shop Info',
    'Shipping Settings',
    'Shop Meta Settings',
  ];

  var shopName = TextEditingController().obs;
  var shopDescription = TextEditingController().obs;
  var shopContact = TextEditingController().obs;

  final List<IconData> icons = [
    Icons.storefront_outlined,
    Icons.local_shipping_outlined,
    Icons.settings_outlined,
  ];
  final List<String> statusOptions = ['active', 'Inactive'];
  var selectedStatus = 'active'.obs;

  final ImagePicker _picker = ImagePicker();

  // List to hold images for 3 placeholders
  RxList<XFile?> pickedImages = <XFile?>[null, null, null].obs;

  void showImageSourcePicker(int index) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera, index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage(ImageSource source, int index) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null && index < pickedImages.length) {
      pickedImages[index] = image;
      pickedImages.refresh(); // Force UI update
    }
  }

  Future<void> updateShop(String shopId) async {
    // final String token = 'your_token_here'; // If using auth
    // final String url = 'https://yourapi.com/api/shop/123'; // Replace with actual endpoint
    try {
      final Map<String, dynamic> requestBody = {
        "name": shopName.value.text.toString(),
        "status": selectedStatus.value.toString(),
        "description": shopDescription.value.text.toString(),
        "meta": {
          "phone": [shopContact.value.text.toString()], // must be an array!
        },
      };
      final res = await uploadSingleImage(1);
      if (res == null) {
        return;
      }

      final response = await http.put(
        Uri.parse("${AppUrl.baseURL}//shops/$shopId/update"),
        headers: {
          'Content-Type': 'application/json',
          'X-Request-From': 'Application',
          'shop-id': shopId, // remove if not needed
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 201) {
        print(" Shop updated successfully!");
      } else {
        print(" Failed to update shop: ${response.body}");
      }
    } catch (e) {
      print("error $e");
    }
  }

  String mediaId = '';
  Future uploadSingleImage(int index) async {
    // Ensure image is selected at the index
    final xfile = pickedImages[index];
    if (xfile == null) {
      print(" No image selected at index $index.");
      return null;
    }

    // Convert to File
    final file = File(xfile.path);

    try {
      mediaId = await uploadMedia(
        [file], // your API expects a List<File>
        directory: "shop_banners", // optional
        width: 800, // optional
        height: 600, // optional
      );

      print("✅ Uploaded image at index $index — Media ID: $mediaId");
    } catch (e) {
      print(" Upload failed for image at index $index: $e");
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
}
