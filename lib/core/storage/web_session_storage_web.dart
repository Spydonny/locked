import 'dart:html' as html;

Future<String?> readWebSession(String key) async {
  return html.window.localStorage[key];
}

Future<void> writeWebSession(String key, String value) async {
  html.window.localStorage[key] = value;
}

Future<void> clearWebSession(String key) async {
  html.window.localStorage.remove(key);
}
