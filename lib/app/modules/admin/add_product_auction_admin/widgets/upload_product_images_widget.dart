import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tjara/app/core/utils/thems/my_colors.dart';
import 'package:tjara/app/core/widgets/container_with_border_widget.dart';

import 'package:tjara/app/modules/admin/add_product_admin/views/add_product_admin_view.dart';
import 'package:tjara/app/modules/admin/add_product_auction_admin/controllers/add_product_auction_admin_controller.dart';

class AuctionUploadProductImagesWidget extends StatelessWidget {
  const AuctionUploadProductImagesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuctionAddProductAdminController>(
      builder: (controller) {
        return ProductFieldsCardCustomWidget(
          column: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                Container(
                  height: 45.88,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFFF97316),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Upload Auction Images",
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: AppColors.white),
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
                    const Text(
                      "High-quality image can significantly impact your product's appeal. Upload clear, well-lit photos that showcase your item from different angles and perspectives.",
                      style: TextStyle(color: AppColors.adminGreyColorText),
                    ),
                    const SizedBox(height: 10),
                    controller.thumbnailFile == null
                        ? ContainerWithDottedBorderWidget(
                          onTap: () {
                            controller.pickImage(ImageSource.gallery);
                          },
                          redText: 'Upload a Image',
                          blackText: 'or drag and drop',
                        )
                        : Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                controller.thumbnailFile!,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  controller.thumbnailFile = null;
                                  controller.thumbnailId = null;
                                  controller.update();
                                },
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
                      "Auction Video",
                      style: TextStyle(
                        color: AppColors.darkLightTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "High-quality video can significantly impact your Auction's appeal. Upload clear, well-lit photos that showcase your item from different angles and perspectives.",
                      style: TextStyle(color: AppColors.adminGreyColorText),
                    ),
                    const SizedBox(height: 10),
                    controller.videoFile == null
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
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  controller.videoFile = null;
                                  controller.videoId = null;
                                  controller
                                      .update(); // Notify the widget to rebuild
                                },
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
                      "Auction Gallery Images",
                      style: TextStyle(
                        color: AppColors.darkLightTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "High-quality images can significantly impact your Auction's appeal. Upload clear, well-lit photos that showcase your item from different angles and perspectives.",
                      style: TextStyle(color: AppColors.adminGreyColorText),
                    ),
                    const SizedBox(height: 10),
                    if (controller.galleryFiles.isNotEmpty) ...[
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.galleryFiles.length,
                          padding: const EdgeInsets.all(8),
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(
                                        controller.galleryFiles[index],
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 12,
                                  child: InkWell(
                                    onTap: () {
                                      controller.galleryFiles.removeAt(index);
                                      controller.galleryFiles.removeAt(index);
                                      controller.update();
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
                    ContainerWithDottedBorderWidget(
                      onTap: () {
                        controller.pickImage(
                          ImageSource.gallery,
                          isGallery: true,
                        );
                      },
                      redText: 'Upload a file',
                      blackText: 'or drag and drop',
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
