import 'dart:io';

class Lightware {
  Lightware(this.target, {this.port = 6107});

  InternetAddress target;
  int port;

  String _get(String path, String method) {}

  String _set(String path, String method, String values) {}

  String _call(String path, String method, String params) {}
}

class Response {
  Prefix prefix;
}

enum Prefix { success, error, readOnly }
