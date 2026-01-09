import 'package:flutter/material.dart';


void showEditVerifyDropdown({
  required BuildContext context,
  required Offset position,
  required VoidCallback onEdit,
  required VoidCallback onVerify,
}) {
  showMenu(
    color: Colors.white,
    context: context,
    position: RelativeRect.fromLTRB(position.dx, position.dy, 0, 0),
    items: [
      PopupMenuItem(
        child: ListTile(
          leading: const Icon(Icons.check_circle_outlined),
          title: const Text('Edit'),
          onTap: () {
            Navigator.pop(context);
            onEdit();
          },
        ),
      ),
      PopupMenuItem(
        child: ListTile(
          leading: const Icon(Icons.check_circle_outlined),
          title: const Text('Verify'),
          onTap: () {
            Navigator.pop(context);
            onVerify();
          },
        ),
      ),
    ],
  );
}
