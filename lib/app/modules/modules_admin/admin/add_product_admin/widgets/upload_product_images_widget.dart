import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/utils/thems/my_colors.dart';
import 'package:tjara/app/core/widgets/container_with_border_widget.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/controllers/add_product_admin_controller.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/views/add_product_admin_view.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/widgets/admin_ui_components.dart';

class UploadProductImagesWidget extends StatelessWidget {
  const UploadProductImagesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddProductAdminController>(
      builder: (controller) {
        return ProductFieldsCardCustomWidget(
          column: SizedBox(
            child: Column(
              children: [
                Container(
                  height: 45.88,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AdminTheme.primaryColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Upload ${controller.selectedProductgroup.value} Images",
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Column(
                  children: [
                    const Row(
                      children: [
                        Text(
                          "Feature Image",
                          style: TextStyle(
                            color: AppColors.darkLightTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "*",
                          style: TextStyle(
                            color: AppColors.red,
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "High-quality image can significantly impact your ${controller.selectedProductgroup.value}'s appeal. Upload clear, well-lit photos that showcase your item from different angles and perspectives. You can crop the image after selection.",
                      style: const TextStyle(
                        color: AppColors.adminGreyColorText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    controller.thumbnailFile == null &&
                            controller.thumbnailUrl == null
                        ? ContainerWithDottedBorderWidget(
                          onTap: () {
                            // Show image source selection dialog
                            controller.showImageSourceDialog(isGallery: false);
                          },
                          redText: 'Upload an Image',
                          blackText: 'or drag and drop (tap to crop)',
                        )
                        : Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child:
                                  controller.thumbnailFile != null
                                      ? Image.file(
                                        controller.thumbnailFile!,
                                        fit: BoxFit.fill,

                                        width: double.infinity,
                                      )
                                      : Image.network(
                                        controller.thumbnailUrl!,
                                        fit: BoxFit.fill,

                                        width: double.infinity,
                                      ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    controller.removeThumbnail();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                  ],
                ),
                const SizedBox(height: 25),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Product Video",
                      style: TextStyle(
                        color: AppColors.darkLightTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "High-quality video can significantly impact your product's appeal. Upload clear, well-lit videos that showcase your item from different angles and perspectives.",
                      style: TextStyle(color: AppColors.adminGreyColorText),
                    ),
                    const SizedBox(height: 10),
                    controller.videoFile == null && controller.videoUrl == null
                        ? ContainerWithDottedBorderWidget(
                          onTap: () {
                            controller.pickVideo();
                          },
                          redText: 'Upload a file',
                          blackText: 'or drag and drop(Max video size 10MB)',
                        )
                        : Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[200],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.video_library,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const Text(
                                    'Video Selected',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    controller.removeVideo();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                  ],
                ),
                const SizedBox(height: 25),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Product Gallery Images",
                      style: TextStyle(
                        color: AppColors.darkLightTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "High-quality images can significantly impact your product's appeal. Upload clear, well-lit photos that showcase your item from different angles and perspectives. You can crop each image after selection.",
                      style: TextStyle(color: AppColors.adminGreyColorText),
                    ),
                    const SizedBox(height: 10),
                    if (controller.galleryFiles.isNotEmpty ||
                        controller.galleryUrls.isNotEmpty) ...[
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount:
                              controller.galleryFiles.length +
                              controller.galleryUrls.length,
                          padding: const EdgeInsets.all(8),
                          itemBuilder: (context, index) {
                            final bool isFile =
                                index < controller.galleryFiles.length;
                            final int urlIndex =
                                index - controller.galleryFiles.length;

                            return Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image:
                                          isFile
                                              ? FileImage(
                                                controller.galleryFiles[index],
                                              )
                                              : NetworkImage(
                                                    controller
                                                        .galleryUrls[urlIndex],
                                                  )
                                                  as ImageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 12,
                                  child: InkWell(
                                    onTap: () {
                                      if (isFile) {
                                        controller.removeGalleryImage(
                                          index,
                                          isUrl: false,
                                        );
                                      } else {
                                        controller.removeGalleryImage(
                                          urlIndex,
                                          isUrl: true,
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
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
                    ContainerWithDottedBorderWidget(
                      onTap: () {
                        // Show image source selection dialog for gallery
                        controller.showImageSourceDialog(isGallery: true);
                      },
                      redText: 'Upload an Image',
                      blackText: 'or drag and drop (tap to crop)',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
