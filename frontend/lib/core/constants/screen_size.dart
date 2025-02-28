import 'package:flutter/material.dart';

bool checkIfLargeScreen(BuildContext context) {
  return MediaQuery.of(context).size.width >= 800;
}
