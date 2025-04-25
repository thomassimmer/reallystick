import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:reallystick/core/app.dart';
import 'package:reallystick/core/backend_unavailable_app.dart';
import 'package:reallystick/core/service_locator.dart';
import 'package:reallystick/core/update_app.dart';
import 'package:reallystick/core/utils/check_version.dart';
import 'package:reallystick/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  late final VersionInfo versionInfo;

  try {
    versionInfo = await checkAppVersion();
  } on VersionFetchingError catch (_) {
    runApp(
      BackendUnavailableApp(
        onRetry: () {
          // Restart the app logic
          main();
        },
      ),
    );
    return;
  }

  if (versionInfo.updateRequired) {
    runApp(UpdateApp(versionInfo: versionInfo));
    return;
  }

  setupServiceLocator();
  runApp(ReallyStickApp());
}
