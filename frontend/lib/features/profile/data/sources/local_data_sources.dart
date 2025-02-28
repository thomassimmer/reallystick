import 'dart:async';

import 'package:flutter/services.dart';
import 'package:reallystick/core/constants/json_decode.dart';
import 'package:reallystick/features/profile/data/models/country.dart';

class ProfileLocalDataSource {
  ProfileLocalDataSource();

  Future<List<Country>> loadCountries() async {
    final String response =
        await rootBundle.loadString('assets/ressources/countries.json');

    final List<dynamic> jsonList = customJsonDecode(response) as List<dynamic>;
    final List<Country> countries =
        jsonList.map((json) => Country.fromJson(json)).toList();

    return countries;
  }
}
