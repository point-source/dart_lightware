import 'dart:async';

import 'package:tcp_client_dart/tcp_client_dart.dart';

class Lightware {
  Lightware(this.host, {this.port = 6107});

  final String host;
  final int port;

  TcpClient? _client;

  Future<TcpClient> get client async {
    if (_client == null) {
      _client = await TcpClient.connect(
        host,
        port,
        terminatorString: '\r\n',
        connectionType: TcpConnectionType.persistent,
      );

      _client!.stringStream.listen(_handleEvent);
    }

    return _client!;
  }

  int _requestCount = 0;

  /// The signature is a four-digit-long hexadecimal value that can be optionally placed before
  /// every command to keep a command and the corresponding responses together as a group.
  String _getSignature() {
    if (_requestCount == 65535) _requestCount = 0;

    return (_requestCount++).toRadixString(16).padLeft(4, '0').toUpperCase();
  }

  final Map<String, Completer<List<String>>> _requests = {};

  final List<String> _responseCache = [];

  void _handleEvent(String event) {
    if (event.startsWith('{')) {
      _responseCache.clear();
    } else if (event.startsWith('}')) {
      final signature = _responseCache.removeAt(0).substring(1, 5);
      _requests.remove(signature)?.complete(_responseCache.toList());
      _responseCache.clear();

      return;
    }
    _responseCache.add(event);
  }

  /// Sends a raw command string to the Lightware device and returns
  /// any responses as a list of strings (signature and brackets removed)
  Future<List<String>> sendRaw(String command) async {
    final signature = _getSignature();
    final completer = Completer<List<String>>();
    _requests[signature] = completer;
    (await client).send('$signature#$command');

    return await completer.future;
  }

  Future<List<String>> get(String path, {String property = ''}) async {
    final command = property.isEmpty ? 'GET $path' : 'GET $path.$property';

    return await sendRaw(command);
  }

  Future<List<String>> set(String path, String property, String values) async {
    final command = 'SET $path.$property=$values';

    return await sendRaw(command);
  }

  Future<List<String>> call(
    String path,
    String method,
    List<String> params,
  ) async {
    final command = 'CALL $path:$method(${params.join(";")})';

    return await sendRaw(command);
  }

  Future<List<String>> man(String path, String property) async {
    final command = property.isEmpty ? 'MAN $path' : 'MAN $path.$property';

    return await sendRaw(command);
  }

  Future<void> disconnect() async {
    await _client?.close();
    _requests.clear();
    _requestCount = 0;
    _responseCache.clear();
    _client = null;
  }
}
