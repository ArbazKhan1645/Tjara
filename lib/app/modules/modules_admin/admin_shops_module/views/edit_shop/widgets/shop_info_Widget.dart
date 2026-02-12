import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:tjara/app/modules/modules_admin/admin_shops_module/const/appColors.dart';
import 'package:tjara/app/modules/modules_admin/admin_shops_module/views/edit_shop/controllers/edit_shop_controller.dart';
import 'package:tjara/app/modules/modules_admin/admin_shops_module/views/edit_shop/widgets/infoTextWidget.dart';
import 'package:tjara/app/modules/modules_admin/admin_shops_module/views/edit_shop/widgets/input_label_widget.dart';
import 'package:tjara/app/modules/modules_admin/admin_shops_module/views/edit_shop/widgets/profile_card.dart';
import 'package:tjara/app/modules/modules_admin/admin_shops_module/views/edit_shop/widgets/text_field_widget.dart';

class ShopInfoImagesWidget extends StatefulWidget {
  const ShopInfoImagesWidget({
    super.key,
    required this.isActive,
    required this.Balance,
    required this.shopName,
    required this.shopDescription,
    required this.shopContact,
    required this.shopId,
  });

  final isActive;
  final Balance;
  final shopName;
  final shopDescription;
  final shopContact;
  final shopId;
  @override
  State<ShopInfoImagesWidget> createState() => _ShopInfoImagesWidgetState();
}

class _ShopInfoImagesWidgetState extends State<ShopInfoImagesWidget> {
  final EditShopController controller = Get.put(EditShopController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.shopContact.value.text = widget.shopContact.toString();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Obx(
        () => Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ProfileCard(
              img: controller.pickedImages[1],
              onAvatarTap: () {
                controller.showImageSourcePicker(1);
              },
              onclose: () {},
            ),

            const SizedBox(height: 25),
            InfoTextWidget(
              balance: widget.Balance.toString(),
              uploadCover: () {
                // controller.showImageSourcePicker(2);
              },
              selectedValue: widget.isActive,
            ),
            Row(
              children: [
                Text(
                  'Shop Info',
                  style: TextStyle(
                    color: appcolors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Divider(color: appcolors.grey.withOpacity(.2)),
            const SizedBox(height: 10),
            const Inputlabel(
              label: 'Shop Name',
              helperText:
                  'Enter your full legal name as it appears on your official identification.',
              isRequired: true,
            ),
            EditInfofield(
              controller: controller.shopName.value,
              initial: widget.shopName.toString(),
            ),
            const SizedBox(height: 20),
            const Inputlabel(
              label: 'Shop Description',
              helperText:
                  'Enter your full legal name as it appears on your official identification.',
              isRequired: true,
            ),
            EditInfofield(
              controller: controller.shopDescription.value,
              initial: widget.shopDescription.toString(),
              maxlines: 8,
            ),
            const SizedBox(height: 20),
            const Inputlabel(
              label: 'Shop Contact Number (Whatsapp)',
              helperText:
                  'Enter your whatsapp number it will be shown on your store page',
              isRequired: true,
            ),
            const SizedBox(height: 20),

            IntlPhoneField(
              controller: controller.shopContact.value,
              style: TextStyle(color: appcolors.black),
              initialCountryCode: 'LB',
              disableLengthCheck: true,
              initialValue: widget.shopContact.toString(),
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),

              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              pickerDialogStyle: PickerDialogStyle(
                backgroundColor: Colors.white,

                searchFieldInputDecoration: const InputDecoration(
                  hintText: 'Search country...',
                  hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
                  // This controls the style for user input too
                  // even though it's not a direct TextStyle override
                ),
              ),
              onChanged: (phone) {
                print(phone.number);
                controller.shopContact.value.text = phone.number;
              },
            ),
            Divider(color: appcolors.grey.withOpacity(.2)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: GestureDetector(
                onTap: () {
                  controller.updateShop(widget.shopId.toString());
                },
                child: Container(
                  width: Get.width * .9,
                  height: 35,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: appcolors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Save Changes',
                      style: TextStyle(
                        color: appcolors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// Text("Shop Info Content", style: TextStyle(color: appcolors.black))