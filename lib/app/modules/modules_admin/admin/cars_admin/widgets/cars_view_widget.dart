import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:tjara/app/core/utils/thems/my_colors.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/core/widgets/admin_header_animated_background_widget.dart';
import 'package:tjara/app/core/widgets/admin_sliver_app_bar_widget.dart';
import 'package:tjara/app/core/widgets/search_text_field_widget.dart';
import 'package:tjara/app/core/widgets/sort_by_widget.dart';
import 'package:tjara/app/modules/modules_admin/admin/cars_admin/widgets/products_list_widget.dart';
import 'package:tjara/app/services/dashbopard_services/admin_cars_service.dart';

class CarsViewWidget extends StatelessWidget {
  final bool isAppBarExpanded;
  final AdminCarsService adminProductsService;
  const CarsViewWidget({
    super.key,
    required this.isAppBarExpanded,
    required this.adminProductsService,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        AdminSliverAppBarWidget(
          title: 'Dashboard',
          isAppBarExpanded: isAppBarExpanded,
          actions: const [AdminAppBarActions()],
        ),
        SliverToBoxAdapter(
          child: Stack(
            children: [
              AdminHeaderAnimatedBackgroundWidget(
                isAppBarExpanded: isAppBarExpanded,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cars',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 15),
                          SearchTextFieldWidget(
                            searchBy: 'Title',
                            onChanged: (value) {
                              debugPrint('Searching for: $value');
                            },
                          ),
                          const SizedBox(height: 10),
                          SearchTextFieldWidget(
                            searchBy: 'ID',
                            onChanged: (value) {
                              debugPrint('Searching for: $value');
                            },
                          ),
                          const SizedBox(height: 10),
                          SearchTextFieldWidget(
                            searchBy: 'Sku',
                            onChanged: (value) {},
                          ),
                          const SizedBox(height: 20),
                          const SortByWidget(),
                          const SizedBox(height: 10),
                          const SortByWidget(),
                          const SizedBox(height: 10),
                          const SortByWidget(),
                          const SizedBox(height: 10),
                          const SortByWidget(),
                          const SizedBox(height: 10),
                          PopupActionButton(
                            label: 'Export',
                            icon: Icons.download,
                            onSelected: (MenuItem menuItem) {},
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                    AdminCarsList(adminProductsService: adminProductsService),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PopupActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final void Function(MenuItem menuItem) onSelected;

  const PopupActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MenuItem>(
      position: PopupMenuPosition.under,
      color: Colors.white,
      icon: ReusableContainerWithIcon(label: label, icon: icon),
      onSelected: onSelected,
      offset: const Offset(1, 0),
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<MenuItem>>[
          PopupMenuItem<MenuItem>(
            value: MenuItem.XLSV,
            child: Container(
              color: Colors.white,
              child: const Row(
                children: [
                  Icon(
                    Icons.file_present,
                    color: AppColors.adminGreyColorText,
                    size: 16,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Excel (XLSX)',
                    style: TextStyle(color: AppColors.adminGreyColorText),
                  ),
                ],
              ),
            ),
          ),
          const PopupMenuItem<MenuItem>(
            value: MenuItem.CSV,
            child: Row(
              children: [
                Icon(
                  Icons.file_present,
                  color: AppColors.adminGreyColorText,
                  size: 16,
                ),
                SizedBox(width: 10),
                Text(
                  'CSV',
                  style: TextStyle(color: AppColors.adminGreyColorText),
                ),
              ],
            ),
          ),
        ];
      },
    );
  }
}

enum MenuItem { XLSV, CSV }

class ReusableContainerWithIcon extends StatelessWidget {
  final String label;
  final IconData icon;
  final Widget? trailingIcon;
  final Color containerBorderColor;
  final List<Color> containerGradientColors;

  const ReusableContainerWithIcon({
    super.key,
    required this.label,
    required this.icon,
    this.trailingIcon = const Icon(
      Icons.keyboard_arrow_down_rounded,
      color: Colors.black,
    ),
    this.containerBorderColor = Colors.grey,
    this.containerGradientColors = const [Colors.white, Colors.white],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: containerGradientColors,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 1, color: containerBorderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.black),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(color: Colors.black)),
              ],
            ),
            trailingIcon ?? Container(),
          ],
        ),
      ),
    );
  }
}

class OrderColumnWidget extends StatelessWidget {
  final String label;
  final String value;
  final CrossAxisAlignment crossAxisAlignment;
  final Color textColor;
  final bool hasIcon;
  final IconData icon;
  final Color iconColor;
  final String hasImage;
  final TextAlign textAlign;

  const OrderColumnWidget({
    super.key,
    required this.label,
    required this.value,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.textColor = Colors.black,
    this.hasIcon = false,
    this.icon = Icons.open_in_new,
    this.iconColor = Colors.red,
    this.hasImage = '',
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey), maxLines: 2),
        if (hasImage.isEmpty)
          SizedBox(
            height: 50,
            width: 100,
            child: Row(
              children: [
                if (hasIcon) Icon(icon, size: 16, color: iconColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(color: textColor),
                    maxLines: 2,
                    textAlign: textAlign,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        if (hasImage.isNotEmpty)
          CachedNetworkImage(
            imageUrl: value,
            height: 50,
            width: 50,
            fit: BoxFit.cover,
            placeholder:
                (context, url) => SizedBox(
                  height: 50,
                  width: 50,
                  child: Image.asset('assets/icons/logo.png'),
                ),
            errorWidget:
                (context, url, error) => SizedBox(
                  height: 50,
                  width: 50,
                  child: Image.asset('assets/icons/logo.png'),
                ),
          ),
      ],
    );
  }
}
