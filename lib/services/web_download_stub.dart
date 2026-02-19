import 'dart:typed_data';

void downloadBytes(Uint8List bytes, String fileName, {String? mimeType}) {
  // No-op on non-web platforms.
}

void openUrl(String url, {String? target}) {
  // No-op on non-web platforms.
}

String getBrowserUserAgent() {
  return '';
}

String? getLocalStorageValue(String key) {
  return null;
}

void setLocalStorageValue(String key, String value) {}

bool matchMediaQuery(String query) {
  return false;
}