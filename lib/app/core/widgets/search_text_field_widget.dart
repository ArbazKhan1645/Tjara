import 'package:flutter/material.dart';

class SearchTextFieldWidget extends StatelessWidget {
  final String searchBy;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final String searchByStaticText;

  const SearchTextFieldWidget({
    super.key,
    this.searchBy = 'ID',
    this.onChanged,
    this.controller,
    this.searchByStaticText = 'Search By :'
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        isCollapsed: true,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 0),
          child: Icon(Icons.search, color: Colors.grey[500]),
        ),
        isDense: true,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        hintText: '$searchByStaticText $searchBy...',
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}