import 'package:flutter/material.dart';
import 'package:tjara/app/modules/modules_admin/admin_shops_module/const/appColors.dart';
import 'package:tjara/app/modules/modules_admin/admin_shops_module/views/shops/widgets/drop_down_widget.dart';

Widget tableCellWidget({required String text, TextStyle? style}) {
  return Expanded(
    child: Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: Colors.white),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: style ?? const TextStyle(fontSize: 14, color: Colors.black),
      ),
    ),
  );
}

Widget tableCellWithStatus({
  required String text,
  TextStyle? style,
  required int status,
}) {
  return Expanded(
    child: Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: style ?? const TextStyle(fontSize: 14, color: Colors.black),
          ),
          const SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: appcolors.yellow),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                status == 0 ? "Not Verified" : "Verified",
                textAlign: TextAlign.center,
                style:
                    style ?? TextStyle(fontSize: 14, color: appcolors.yellow),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget tableCellMultiWidgets({
  required String text,
  required String email,
  required String phone,
  TextStyle? style,
}) {
  return Expanded(
    child: Container(
      height: 85,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      alignment: Alignment.bottomLeft,
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            textAlign: TextAlign.left,
            style: style ?? const TextStyle(fontSize: 14, color: Colors.black),
          ),
          Text(
            email,
            textAlign: TextAlign.left,
            style: style ?? TextStyle(fontSize: 10, color: appcolors.grey),
          ),
          Text(
            phone,
            textAlign: TextAlign.left,
            style: style ?? TextStyle(fontSize: 10, color: appcolors.grey),
          ),
        ],
      ),
    ),
  );
}

Widget tableIconWidget({
  required BuildContext context,
  required String text,
  required VoidCallback onEdit,
  required VoidCallback onVerify,
}) {
  return Expanded(
    child: Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(color: Colors.white),
      child: Center(
        child: Builder(
          builder: (innerContext) {
            return IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                final RenderBox button =
                    innerContext.findRenderObject() as RenderBox;
                final RenderBox overlay =
                    Overlay.of(context).context.findRenderObject() as RenderBox;

                final Offset position = button.localToGlobal(
                  button.size.bottomRight(Offset.zero),
                  ancestor: overlay,
                );

                showEditVerifyDropdown(
                  context: context,
                  position: position,
                  onEdit: onEdit,
                  onVerify: onVerify,
                );
              },
            );
          },
        ),
      ),
    ),
  );
}
