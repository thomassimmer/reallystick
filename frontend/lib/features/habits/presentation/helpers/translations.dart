/// Helper function to select the habit short name based on the priority.
String getRightTranslationFromJson(
    Map<String, String> translationMap, String? userLocale) {
  // Priority:
  // 1. User's locale (if available)
  // 2. English ("en")
  // 3. First language in the map
  // 4. Fallback message
  if (userLocale != null && translationMap.containsKey(userLocale)) {
    return translationMap[userLocale]!;
  } else if (translationMap.containsKey("en")) {
    return translationMap["en"]!;
  } else if (translationMap.isNotEmpty) {
    return translationMap.values.first;
  } else {
    return "Missing translation";
  }
}

String _getPluralizationKey(int number) {
  // Determine the pluralization key based on the duration
  if (number == 1) {
    return "one";
  } else if (number < 5) {
    return "few";
  } else {
    return "many";
  }
}

/// Helper function to select the unit name based on the priority and number of elements.
String getRightTranslationForUnitFromJson(
    Map<String, Map<String, String>> translationMap,
    int numberOfElement,
    String? userLocale) {
  // Determine the pluralization key based on the number of elements
  String pluralizationKey = _getPluralizationKey(numberOfElement);

  // Priority:
  // 1. User's locale (if available)
  // 2. English ("en")
  // 3. First language in the map
  // 4. Fallback message
  if (userLocale != null && translationMap.containsKey(userLocale)) {
    final userTranslations = translationMap[userLocale]!;
    if (userTranslations.containsKey(pluralizationKey)) {
      return userTranslations[pluralizationKey]!;
    }

    if (userTranslations.containsKey("other")) {
      return userTranslations["other"]!;
    }
  }

  if (translationMap.containsKey("en")) {
    final englishTranslations = translationMap["en"]!;
    if (englishTranslations.containsKey(pluralizationKey)) {
      return englishTranslations[pluralizationKey]!;
    }

    if (englishTranslations.containsKey("other")) {
      return englishTranslations["other"]!;
    }
  }

  if (translationMap.isNotEmpty) {
    final firstLanguageTranslations = translationMap.values.first;
    if (firstLanguageTranslations.containsKey(pluralizationKey)) {
      return firstLanguageTranslations[pluralizationKey]!;
    }

    if (firstLanguageTranslations.containsKey("other")) {
      return firstLanguageTranslations["other"]!;
    }
  }

  return "Missing translation";
}
