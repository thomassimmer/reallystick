import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:reallystick/core/app.dart';
import 'package:reallystick/core/service_locator.dart';
import 'package:reallystick/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );  

  setupServiceLocator();
  runApp(ReallyStickApp());
} 
