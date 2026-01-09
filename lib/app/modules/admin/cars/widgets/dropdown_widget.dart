import 'package:flutter/material.dart';
import 'package:tjara/app/modules/samad/const/appColors.dart';

class CustomDropdown extends StatefulWidget {
  final List<String> items;
  final String initialValue;
  final String type;
  final ValueChanged<String?> onChanged;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.initialValue,
    required this.onChanged,
    required this.type,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  late String selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: appcolors.grey.withOpacity(.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: appcolors.white,
          value: selectedValue,
          icon: const Icon(Icons.arrow_drop_down),
          style: TextStyle(color: appcolors.grey.withOpacity(.8), fontSize: 12),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedValue = value;
              });
              widget.onChanged(value);
            }
          },
          items:
              widget.items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text("${widget.type}: $item"),
                );
              }).toList(),
        ),
      ),
    );
  }
}
