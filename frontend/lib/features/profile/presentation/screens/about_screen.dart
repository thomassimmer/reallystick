import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/core/presentation/widgets/custom_app_bar.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Uri githubUrl = Uri.parse('https://github.com/tatkagore');

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          AppLocalizations.of(context)!.about,
          style: context.typographies.headingSmall,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.aboutText,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () async {
                  if (await canLaunchUrl(githubUrl)) {
                    await launchUrl(githubUrl,
                        mode: LaunchMode.externalApplication,
                        webOnlyWindowName: '_blank');
                  } else {
                    throw 'Could not launch $githubUrl';
                  }
                },
                style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                        context.colors.hint.withValues(alpha: 0.1))),
                child: Image.asset(
                  'assets/images/github-logo.png',
                  width: 50,
                  height: 50,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
