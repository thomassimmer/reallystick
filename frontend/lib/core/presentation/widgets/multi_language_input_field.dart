import 'package:flutter/material.dart';
import 'package:reallystick/core/constants/locales.dart';
import 'package:reallystick/core/presentation/widgets/custom_text_field.dart';

class MultiLanguageInputField extends StatefulWidget {
  final Map<String, String> initialTranslations;
  final Function(Map<String, String>) onTranslationsChanged;
  final String label;
  final Map<String, String?> errors;

  const MultiLanguageInputField({
    Key? key,
    required this.initialTranslations,
    required this.onTranslationsChanged,
    required this.label,
    required this.errors,
  }) : super(key: key);

  @override
  MultiLanguageInputFieldState createState() => MultiLanguageInputFieldState();
}

class MultiLanguageInputFieldState extends State<MultiLanguageInputField> {
  late Map<String, TextEditingController> controllers;

  @override
  void initState() {
    super.initState();

    // Initialize TextEditingControllers for each language code
    controllers = {
      for (var locale in locales)
        locale['code']!: TextEditingController(
          text: widget.initialTranslations[locale['code']] ?? '',
        ),
    };
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged(String languageCode, String value) {
    final updatedTranslations = {
      for (var entry in controllers.entries)
        if (entry.value.text.isNotEmpty) entry.key: entry.value.text,
    };

    // Call the callback with the updated map
    widget.onTranslationsChanged(updatedTranslations);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.label),
        SizedBox(height: 8),
        ...locales.map(
          (locale) {
            var languageCode = locale['code']!;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: CustomTextField(
                controller: controllers[languageCode]!,
                label: 'Translation (${languageCode.toUpperCase()})',
                onChanged: (value) => _onTextChanged(languageCode, value),
                errorText: widget.errors[languageCode],
              ),
            );
          },
        ).toList()
      ],
    );
  }
}
