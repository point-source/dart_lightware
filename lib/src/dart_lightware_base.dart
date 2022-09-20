class Lightware {
  Lightware(this.host, {this.port = 6107});

  final String host;
  final int port;

  String _get(String path, String method) {}

  String _set(String path, String method, String values) {}

  String _call(String path, String method, String params) {}
}

class Response {
  Prefix prefix;
}

enum Prefix { success, error, readOnly }
