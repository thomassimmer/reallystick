import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class VersionFetchingError implements Exception {
  final String message;
  VersionFetchingError([this.message = "Failed to fetch app version."]);

  @override
  String toString() => "VersionFetchingError: $message";
}

class StoreUrl {
  String ios;
  String android;

  StoreUrl({
    required this.ios,
    required this.android,
  });

  factory StoreUrl.fromJson(Map<String, dynamic> json) {
    return StoreUrl(
      ios: json['ios'] as String,
      android: json['android'] as String,
    );
  }
}

class VersionInfo {
  final String minVersion;
  final String latestVersion;
  final bool updateRequired;
  final String changelog;
  final StoreUrl storeUrl;

  VersionInfo({
    required this.minVersion,
    required this.latestVersion,
    required this.updateRequired,
    required this.changelog,
    required this.storeUrl,
  });

  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    return VersionInfo(
      minVersion: json['min_version'] as String,
      latestVersion: json['latest_version'] as String,
      updateRequired: json['update_required'] as bool,
      changelog: json['changelog'] as String,
      storeUrl: StoreUrl.fromJson(json['store_url'] as Map<String, dynamic>),
    );
  }
}

Future<String> getCurrentVersion() async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
}

Future<VersionInfo> checkAppVersion() async {
  final currentVersion = await getCurrentVersion();
  final baseUrl = '${dotenv.env['API_BASE_URL']}/api';
  final response = await http.get(
    Uri.parse("$baseUrl/version?current=$currentVersion"),
  );

  if (response.statusCode != 200) {
    throw VersionFetchingError("Server returned ${response.statusCode}");
  }

  final json = jsonDecode(response.body);
  return VersionInfo.fromJson(json);
}
