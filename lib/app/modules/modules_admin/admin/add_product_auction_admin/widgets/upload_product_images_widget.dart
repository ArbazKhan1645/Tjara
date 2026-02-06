import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_auction_admin/controllers/add_product_auction_admin_controller.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_auction_admin/widgets/auction_admin_theme.dart';

class AuctionUploadProductImagesWidget extends StatelessWidget {
  const AuctionUploadProductImagesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuctionAddProductAdminController>(
      builder: (controller) {
        return AuctionFormCard(
          title: 'Auction Media',
          icon: Icons.photo_library_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Feature Image Section
              _FeatureImageSection(controller: controller),
              const SizedBox(height: AuctionAdminTheme.spacingXl),

              // Video Section
              _VideoSection(controller: controller),
              const SizedBox(height: AuctionAdminTheme.spacingXl),

              // Gallery Section
              _GallerySection(controller: controller),
            ],
          ),
        );
      },
    );
  }
}

/// Feature Image Section Widget
class _FeatureImageSection extends StatelessWidget {
  final AuctionAddProductAdminController controller;

  const _FeatureImageSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final hasImage = controller.thumbnailFile != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel(
          label: 'Feature Image',
          isRequired: true,
          description:
              'High-quality images significantly impact your auction\'s appeal. Upload a clear, well-lit photo that showcases your item.',
        ),
        if (hasImage)
          _ImagePreview(
            imageFile: controller.thumbnailFile!,
            onRemove: () {
              controller.thumbnailFile = null;
              controller.thumbnailId = null;
              controller.update();
            },
          )
        else
          _UploadButton(
            icon: Icons.add_photo_alternate_rounded,
            label: 'Upload Feature Image',
            sublabel: 'PNG, JPG up to 5MB',
            onTap: () => controller.pickImage(ImageSource.gallery),
          ),
      ],
    );
  }
}

/// Video Section Widget
class _VideoSection extends StatelessWidget {
  final AuctionAddProductAdminController controller;

  const _VideoSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final hasVideo = controller.videoFile != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel(
          label: 'Auction Video',
          description:
              'A video walkthrough can showcase your item from all angles. Upload a clear, well-lit video (max 10MB).',
        ),
        if (hasVideo)
          _VideoPreview(
            onRemove: () {
              controller.videoFile = null;
              controller.videoId = null;
              controller.update();
            },
          )
        else
          _UploadButton(
            icon: Icons.videocam_rounded,
            label: 'Upload Video',
            sublabel: 'MP4, MOV up to 10MB',
            onTap: () => controller.pickVideo(),
          ),
      ],
    );
  }
}

/// Gallery Section Widget
class _GallerySection extends StatelessWidget {
  final AuctionAddProductAdminController controller;

  const _GallerySection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final galleryFiles = controller.galleryFiles;
    final hasGalleryImages = galleryFiles.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel(
          label: 'Gallery Images',
          description:
              'Add multiple images to showcase your item from different angles and perspectives.',
        ),
        if (hasGalleryImages) ...[
          _GalleryGrid(
            files: galleryFiles,
            onRemove: (index) {
              if (index < galleryFiles.length) {
                controller.galleryFiles.removeAt(index);
                if (index < controller.galleryIds.length) {
                  controller.galleryIds.removeAt(index);
                }
                controller.update();
              }
            },
          ),
          const SizedBox(height: AuctionAdminTheme.spacingMd),
        ],
        _UploadButton(
          icon: Icons.add_photo_alternate_outlined,
          label: hasGalleryImages ? 'Add More Images' : 'Upload Gallery Images',
          sublabel: 'PNG, JPG up to 5MB each',
          onTap: () => controller.pickImage(
            ImageSource.gallery,
            isGallery: true,
          ),
          isCompact: hasGalleryImages,
        ),
      ],
    );
  }
}

/// Image Preview Widget
class _ImagePreview extends StatelessWidget {
  final dynamic imageFile;
  final VoidCallback onRemove;

  const _ImagePreview({
    required this.imageFile,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
        border: Border.all(color: AuctionAdminTheme.accent),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd - 1),
            child: Image.file(
              imageFile,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(AuctionAdminTheme.radiusMd - 1),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
          // Remove button
          Positioned(
            top: AuctionAdminTheme.spacingSm,
            right: AuctionAdminTheme.spacingSm,
            child: Material(
              color: AuctionAdminTheme.error,
              borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
              child: InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
                child: const Padding(
                  padding: EdgeInsets.all(AuctionAdminTheme.spacingSm),
                  child: Icon(
                    Icons.delete_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
          // Success indicator
          Positioned(
            bottom: AuctionAdminTheme.spacingMd,
            left: AuctionAdminTheme.spacingMd,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AuctionAdminTheme.spacingMd,
                vertical: AuctionAdminTheme.spacingXs,
              ),
              decoration: BoxDecoration(
                color: AuctionAdminTheme.success,
                borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Image uploaded',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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
}

/// Video Preview Widget
class _VideoPreview extends StatelessWidget {
  final VoidCallback onRemove;

  const _VideoPreview({required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AuctionAdminTheme.spacingXl),
      decoration: BoxDecoration(
        color: AuctionAdminTheme.surfaceSecondary,
        borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
        border: Border.all(color: AuctionAdminTheme.accent),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AuctionAdminTheme.spacingLg),
            decoration: BoxDecoration(
              color: AuctionAdminTheme.accentLight,
              borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
            ),
            child: const Icon(
              Icons.videocam_rounded,
              color: AuctionAdminTheme.accent,
              size: 32,
            ),
          ),
          const SizedBox(width: AuctionAdminTheme.spacingLg),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Video uploaded',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AuctionAdminTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Ready to be published with your auction',
                  style: TextStyle(
                    fontSize: 13,
                    color: AuctionAdminTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: AuctionAdminTheme.errorLight,
            borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
            child: InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
              child: const Padding(
                padding: EdgeInsets.all(AuctionAdminTheme.spacingSm),
                child: Icon(
                  Icons.delete_rounded,
                  color: AuctionAdminTheme.error,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gallery Grid Widget
class _GalleryGrid extends StatelessWidget {
  final List<dynamic> files;
  final Function(int index) onRemove;

  const _GalleryGrid({
    required this.files,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: files.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AuctionAdminTheme.spacingMd),
        itemBuilder: (context, index) {
          return _GalleryItem(
            file: files[index],
            index: index,
            onRemove: () => onRemove(index),
          );
        },
      ),
    );
  }
}

/// Gallery Item Widget
class _GalleryItem extends StatelessWidget {
  final dynamic file;
  final int index;
  final VoidCallback onRemove;

  const _GalleryItem({
    required this.file,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
        border: Border.all(color: AuctionAdminTheme.border),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd - 1),
            child: Image.file(
              file,
              width: 110,
              height: 110,
              fit: BoxFit.cover,
            ),
          ),
          // Index badge
          Positioned(
            bottom: AuctionAdminTheme.spacingXs,
            left: AuctionAdminTheme.spacingXs,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AuctionAdminTheme.spacingSm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Remove button
          Positioned(
            top: AuctionAdminTheme.spacingXs,
            right: AuctionAdminTheme.spacingXs,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
              child: InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    color: AuctionAdminTheme.error,
                    size: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Upload Button Widget
class _UploadButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback onTap;
  final bool isCompact;

  const _UploadButton({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AuctionAdminTheme.spacingLg,
              vertical: AuctionAdminTheme.spacingMd,
            ),
            decoration: BoxDecoration(
              color: AuctionAdminTheme.accentLight,
              borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
              border: Border.all(color: AuctionAdminTheme.accent),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: AuctionAdminTheme.accent,
                  size: 20,
                ),
                const SizedBox(width: AuctionAdminTheme.spacingSm),
                Text(
                  label,
                  style: const TextStyle(
                    color: AuctionAdminTheme.accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AuctionAdminTheme.spacingXl),
          decoration: BoxDecoration(
            color: AuctionAdminTheme.surfaceSecondary,
            borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
            border: Border.all(
              color: AuctionAdminTheme.border,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AuctionAdminTheme.spacingLg),
                decoration: const BoxDecoration(
                  color: AuctionAdminTheme.accentLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: AuctionAdminTheme.accent,
                ),
              ),
              const SizedBox(height: AuctionAdminTheme.spacingMd),
              Text(
                label,
                style: const TextStyle(
                  color: AuctionAdminTheme.accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: AuctionAdminTheme.spacingXs),
              Text(
                sublabel,
                style: const TextStyle(
                  color: AuctionAdminTheme.textTertiary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
