import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/habits/domain/entities/unit.dart';
import 'package:reallystick/features/habits/presentation/helpers/translations.dart';

class MultiUnitSelectDropdown extends StatefulWidget {
  final Map<String, Unit> options;
  final List<String> initialSelectedValues;
  final String userLocale;
  final List<String> errors;
  final Function(HashSet<String>) onUnitsChanged;

  const MultiUnitSelectDropdown({
    Key? key,
    required this.options,
    this.initialSelectedValues = const [],
    required this.userLocale,
    required this.errors,
    required this.onUnitsChanged,
  }) : super(key: key);

  @override
  MultiUnitSelectDropdownState createState() => MultiUnitSelectDropdownState();
}

class MultiUnitSelectDropdownState extends State<MultiUnitSelectDropdown> {
  late HashSet<String> selectedValues;
  bool isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    selectedValues = HashSet.from(widget.initialSelectedValues);
  }

  void toggleDropdown() {
    setState(() {
      isDropdownOpen = !isDropdownOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleDropdown,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown display box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.colors.backgroundDark,
              border: Border.all(
                color: widget.errors.isNotEmpty
                    ? context.colors.alert
                    : context.colors.primary,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedValues.isNotEmpty
                      ? selectedValues
                          .map(
                            (unitId) => getRightTranslationForUnitFromJson(
                              widget.options[unitId]!.longName,
                              1,
                              widget.userLocale,
                            ),
                          )
                          .join(', ')
                      : AppLocalizations.of(context)!.selectUnits,
                ),
                Icon(
                  isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                ),
              ],
            ),
          ),

          // Dropdown menu
          if (isDropdownOpen)
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView(
                shrinkWrap: true,
                children: widget.options.values.map(
                  (option) {
                    return CheckboxListTile(
                      value: selectedValues.contains(option.id),
                      title: Text(getRightTranslationForUnitFromJson(
                        option.longName,
                        2,
                        widget.userLocale,
                      )),
                      onChanged: (bool? isChecked) {
                        setState(
                          () {
                            if (isChecked == true) {
                              selectedValues.add(option.id);
                            } else {
                              selectedValues.remove(option.id);
                            }
                          },
                        );
                        widget.onUnitsChanged(selectedValues);
                      },
                    );
                  },
                ).toList(),
              ),
            ),

          if (widget.errors.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.errors
                    .map(
                      (error) => Text(
                        error,
                        style: TextStyle(
                          color: context.colors.error,
                          fontSize: 12.0,
                        ),
                      ),
                    )
                    .toList(),
              ),
            )
        ],
      ),
    );
  }
}
