import 'package:flutter/material.dart';
import 'package:tjara/app/core/widgets/filter_dialog.dart';

showdialogwidget(BuildContext context, String selectedvalue) async {
  return await showDialog(
    context: context,
    builder: (context) {
      return FilterDialog(selectedFilter: selectedvalue);
    },
  );
}
