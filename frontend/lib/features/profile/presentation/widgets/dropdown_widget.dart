import 'package:flutter/material.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class DropdownWidget {
  static show(
    BuildContext context, {
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    final dropdownItems = [
      DropdownMenuItem<String>(
        value: null,
        child: Text(
          AppLocalizations.of(context)!.noAnswer,
        ),
      ),
      ...items
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        value: value,
        icon: Icon(Icons.arrow_drop_down),
        style: TextStyle(color: context.colors.text, fontSize: 16),
        items: dropdownItems,
        onChanged: onChanged,
        isExpanded: true,
      ),
    );
  }
}
