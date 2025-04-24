import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.termsOfUse),
      ),
      body: Markdown(
        selectable: true,
        data: AppLocalizations.of(context)!.termsOfUseMarkdown,
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          p: const TextStyle(fontSize: 14),
          h1: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          h2: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          pPadding: const EdgeInsets.only(bottom: 16),
          h1Padding: const EdgeInsets.symmetric(vertical: 16),
          h2Padding: const EdgeInsets.symmetric(vertical: 16),
          h3Padding: const EdgeInsets.symmetric(vertical: 8),
          h4Padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        padding: const EdgeInsets.all(32),
      ),
    );
  }
}
