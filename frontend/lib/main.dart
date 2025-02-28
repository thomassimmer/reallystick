import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:reallystick/core/app.dart';
import 'package:reallystick/core/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  setupServiceLocator();
  runApp(ReallyStickApp());
}
