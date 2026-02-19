import 'dart:html' as html;
import 'dart:typed_data';

void downloadBytes(Uint8List bytes, String fileName, {String? mimeType}) {
  final blob = html.Blob([bytes], mimeType ?? 'application/octet-stream');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..style.display = 'none'
    ..download = fileName;
  html.document.body?.children.add(anchor);
  anchor.click();
  html.document.body?.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}

void openUrl(String url, {String? target}) {
  html.window.open(url, target ?? '_blank');
}

String getBrowserUserAgent() {
  return html.window.navigator.userAgent;
}

String? getLocalStorageValue(String key) {
  return html.window.localStorage[key];
}

void setLocalStorageValue(String key, String value) {
  html.window.localStorage[key] = value;
}

bool matchMediaQuery(String query) {
  return html.window.matchMedia(query).matches;
}