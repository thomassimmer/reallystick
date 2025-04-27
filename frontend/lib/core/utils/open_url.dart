import 'package:url_launcher/url_launcher.dart';

void markdownTapLinkCallback(String text, String? href, String title) async {
  if (href != null) {
    final url = Uri.parse(href);

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
    }
  }
}
