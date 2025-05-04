import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reallystick/core/presentation/widgets/app_logo.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/core/ui/themes/dark.dart';
import 'package:reallystick/core/ui/themes/light.dart';
import 'package:reallystick/core/utils/dom_helper.dart';
import 'package:reallystick/features/auth/presentation/widgets/background.dart';
import 'package:reallystick/i18n/app_localizations.dart';
import 'package:universal_io/io.dart';

class BackendUnavailableApp extends StatelessWidget {
  final VoidCallback onRetry;

  const BackendUnavailableApp({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    String localeString = Platform.localeName;
    List<String> parts = localeString.split(RegExp('[-_]'));
    Locale locale = Locale(parts[0]);

    if (kIsWeb) {
      setHtmlLang(locale.toString());
    }

    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    ThemeData themeData = brightness == Brightness.dark
        ? DarkAppTheme().themeData
        : LightAppTheme().themeData;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      theme: themeData,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: _BackendUnavailableScreen(onRetry: onRetry),
    );
  }
}

class _BackendUnavailableScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const _BackendUnavailableScreen({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          Background(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppLogo(size: 100),
                  const SizedBox(height: 40),
                  Text(
                    loc.noConnection,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: context.styles.buttonMedium,
                    onPressed: onRetry,
                    child: Text(loc.retry),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
