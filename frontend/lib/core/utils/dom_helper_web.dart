import 'package:web/web.dart';

void setHtmlLang(String lang) {
  document.documentElement?.setAttribute('lang', lang);
}
