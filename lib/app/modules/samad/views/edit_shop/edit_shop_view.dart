import 'package:flutter/material.dart';
import 'package:tjara/app/modules/samad/const/appColors.dart';
import 'package:tjara/app/modules/samad/views/edit_shop/widgets/settings_widget.dart';


class EditShopView extends StatefulWidget {
  const EditShopView({
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
  State<EditShopView> createState() => _EditShopViewState();
}

class _EditShopViewState extends State<EditShopView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appcolors.white,
      appBar: AppBar(
        backgroundColor: appcolors.appbarColor,
        title: const Text('Edit Shops', style: TextStyle(color: Colors.white)),
        centerTitle: false,
      ),
      body: Center(
        child: SettingsMenu(
          shopId: widget.shopId,
          Balance: widget.Balance,
          shopName: widget.shopName,
          shopDescription: widget.shopDescription,
          shopContact: widget.shopContact,
          isActive: widget.isActive,
          // Balance: widget.Balance,
        ),
      ),
    );
  }
}
