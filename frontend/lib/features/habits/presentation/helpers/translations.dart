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
