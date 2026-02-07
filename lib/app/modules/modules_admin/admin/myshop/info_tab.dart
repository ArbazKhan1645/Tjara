// shop_info_tab.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tjara/app/modules/modules_admin/admin/myshop/controller.dart';

class ShopInfoTab extends StatelessWidget {
  const ShopInfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    final MyShopController controller = Get.find<MyShopController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shop Name Field
          _buildTextField(
            label: 'Shop Name',
            required: true,
            controller: controller.nameController,
            hint: 'Enter your shop name',
          ),
          const SizedBox(height: 20),

          // Shop Description Field
          _buildTextField(
            label: 'Shop Description',
            required: true,
            controller: controller.descriptionController,
            hint: 'Enter shop description',
            maxLines: 4,
          ),
          const SizedBox(height: 20),

          // Contact Number Field
          _buildTextField(
            label: 'Shop Contact Number (WhatsApp)',
            required: true,
            controller: controller.phoneController,
            hint: '+1 (443) 604-7384',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),

          // Status Dropdown
          _buildStatusDropdown(controller),
          const SizedBox(height: 20),

          // Image Upload Section
          Row(
            children: [
              Expanded(
                child: _buildImageUpload(
                  title: 'Thumbnail',
                  imageUrl: controller.thumbnailUrl,
                  isUploading: controller.isUploadingThumbnail,
                  onTap: controller.pickThumbnailImage,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildImageUpload(
                  title: 'Banner',
                  imageUrl: controller.bannerUrl,
                  isUploading: controller.isUploadingBanner,
                  onTap: controller.pickBannerImage,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Save Button
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed:
                    controller.isUpdating.value ? null : controller.updateShop,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    controller.isUpdating.value
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE91E63)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown(MyShopController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: controller.selectedStatus.value,
              isExpanded: true,
              underline: const SizedBox(),
              icon: const Icon(Icons.keyboard_arrow_down),
              items:
                  ['active', 'inactive', 'pending'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color:
                                  value == 'active'
                                      ? Colors.green
                                      : value == 'inactive'
                                      ? Colors.red
                                      : Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(value.toUpperCase()),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.selectedStatus.value = newValue;
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUpload({
    required String title,
    required RxString imageUrl,
    required RxBool isUploading,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => GestureDetector(
            onTap: isUploading.value ? null : onTap,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.grey[300]!,
                  style: BorderStyle.solid,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  isUploading.value
                      ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFE91E63),
                          ),
                        ),
                      )
                      : imageUrl.value.isNotEmpty
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          imageUrl.value,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildUploadPlaceholder(title);
                          },
                        ),
                      )
                      : _buildUploadPlaceholder(title),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadPlaceholder(String title) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_upload_outlined, size: 32, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text(
          'Upload $title',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
