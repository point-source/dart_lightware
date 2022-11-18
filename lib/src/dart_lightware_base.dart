import 'dart:async';
import 'dart:io';

import 'package:dart_lightware/src/models/connection_state.dart';
import 'package:tcp_client_dart/tcp_client_dart.dart';

class Lightware {
  Lightware(this.host, {this.port = 6107});

  final String host;
  final int port;

  TcpClient? _client;

  final StreamController<LightwareConnectionState> _stateCtrl =
      StreamController();

  Stream<LightwareConnectionState> get connectionState => _stateCtrl.stream;

  String _error = '';

  Future<TcpClient> get client async {
    return runZonedGuarded(
      () async {
        if (_client == null) {
          _client = await TcpClient.connectPersistent(
            host,
            port,
            terminatorString: '\r\n',
          );

          _client!.stringStream
              .listen(_handleEvent, onError: (e) => _error = e.toString());

          _client!.connectionStream.listen((event) {
            _stateCtrl.add(LightwareConnectionState(
              event.toLightwareConnectionState(),
              errorMessage: _error,
            ));
          });
        }

        return _client!;
      },
      (e, s) async {
        _stateCtrl.add(LightwareConnectionState(
          ConnectionState.failed,
          errorMessage: e.toString(),
        ));
        await disconnect();
      },
    )!;
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
    _error = '';
  }

  /// Sends a raw command string to the Lightware device and returns
  /// any responses as a list of strings (signature and brackets removed)
  Future<List<String>> sendRaw(String command) async {
    final signature = _getSignature();
    final completer = Completer<List<String>>();
    _requests[signature] = completer;
    try {
      (await client).send('$signature#$command');
    } on SocketException catch (e) {
      if (e.osError?.errorCode == 54) {
        // Connection reset by peer
        await disconnect();
        (await client).send('$signature#$command');
      } else {
        rethrow;
      }
    }

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
    for (var e in _requests.values) {
      e.completeError(
        'Connection was closed before the request could be completed.',
      );
    }
    _requests.clear();
    _requestCount = 0;
    _responseCache.clear();
    _client = null;
  }
}
