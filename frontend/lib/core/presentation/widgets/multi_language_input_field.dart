import 'package:flutter/material.dart';
import 'package:reallystick/core/constants/locales.dart';
import 'package:reallystick/core/presentation/widgets/custom_text_field.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class MultiLanguageInputField extends StatefulWidget {
  final Map<String, String> initialTranslations;
  final Function(Map<String, String>) onTranslationsChanged;
  final String label;
  final Map<String, String?> errors;
  final String userLocale;
  final bool multiline;

  const MultiLanguageInputField({
    super.key,
    required this.initialTranslations,
    required this.onTranslationsChanged,
    required this.label,
    required this.errors,
    required this.userLocale,
    required this.multiline,
  });

  @override
  State<MultiLanguageInputField> createState() =>
      _MultiLanguageInputFieldState();
}

class _MultiLanguageInputFieldState extends State<MultiLanguageInputField> {
  Map<String, TextEditingController> controllers = {};
  List<String> activeLanguages = [];

  @override
  void initState() {
    super.initState();

    controllers = {};
    activeLanguages = [];

    // Automatically show the current locale input

    if (widget.initialTranslations.isNotEmpty) {
      for (var entry in widget.initialTranslations.entries) {
        _addLanguage(entry.key, initialText: entry.value);
      }
    } else {
      _addLanguage(widget.userLocale);
    }
  }

  void _addLanguage(String languageCode, {String initialText = ''}) {
    if (!controllers.containsKey(languageCode)) {
      controllers[languageCode] = TextEditingController(text: initialText);
      activeLanguages.add(languageCode);
    }
  }

  void _removeLanguage(String languageCode) {
    controllers[languageCode]?.dispose();
    controllers.remove(languageCode);
    activeLanguages.remove(languageCode);
    _notifyChange();
    setState(() {});
  }

  void _notifyChange() {
    Map<String, String> updatedTranslations = {};

    // We need to return a map with at least a key so that can display a
    // missing translation error.

    for (var entry in controllers.entries) {
      if (entry.value.text.isNotEmpty || updatedTranslations.isEmpty) {
        updatedTranslations[entry.key] = entry.value.text;
      }
    }

    widget.onTranslationsChanged(updatedTranslations);
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableLanguages = locales
        .where((locale) => !activeLanguages.contains(locale['code']))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label),
        const SizedBox(height: 16),
        ...activeLanguages.map((langCode) {
          final langLabel = locales
              .firstWhere((l) => l['code'] == langCode)['name']
              .toString();
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: controllers[langCode]!,
                    label: AppLocalizations.of(context)!
                        .translationForLanguage(langLabel),
                    onChanged: (_) => _notifyChange(),
                    errorText: widget.errors[langCode],
                    maxLines: widget.multiline ? null : 1,
                    minLines: widget.multiline ? 3 : 1,
                    keyboardType: widget.multiline
                        ? TextInputType.multiline
                        : TextInputType.text,
                  ),
                ),
                if (activeLanguages.length > 1)
                  IconButton(
                    icon: Icon(Icons.close),
                    tooltip: AppLocalizations.of(context)!.delete,
                    onPressed: () => _removeLanguage(langCode),
                  ),
              ],
            ),
          );
        }),
        if (availableLanguages.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  hint: Text(
                    AppLocalizations.of(context)!
                        .selectLanguageToAddTranslation,
                    style: context.typographies.captionSmall,
                  ),
                  items: availableLanguages
                      .map(
                        (locale) => DropdownMenuItem<String>(
                          value: locale['code'],
                          child: Text(locale['name']!),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _addLanguage(value!);
                    });
                  },
                  isExpanded: true,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  padding: EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
