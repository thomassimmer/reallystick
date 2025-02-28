import 'dart:convert';

dynamic customJsonDecode(String string) {
  return json.decode(
    utf8.decode(
      string.runes.toList(),
    ),
  );
}
