import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_events.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  // Map of flag emojis to locale codes
  static const Map<String, String> flags = {
    "🇬🇧": "en",
    "🇫🇷": "fr",
    "🇪🇸": "es",
    "🇵🇹": "pt",
    "🇮🇹": "it",
    "🇩🇪": "de",
    "🇷🇺": "ru",
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children: flags.entries.map((entry) {
        final emoji = entry.key;
        final locale = entry.value;
        return GestureDetector(
          onTap: () {
            BlocProvider.of<ProfileBloc>(context).add(
              UnauthenticatedUserChangedLanguage(locale: locale),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        );
      }).toList(),
    );
  }
}
