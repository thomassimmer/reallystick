import 'package:flutter/material.dart';
import 'package:reallystick/core/ui/colors.dart';

class ColorPickerModal extends StatelessWidget {
  final void Function(AppColor selectedColor) onColorSelected;

  const ColorPickerModal({
    super.key,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: AppColor.values.map((appColor) {
            return GestureDetector(
              onTap: () => onColorSelected(appColor),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: appColor.color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black26, width: 1),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
