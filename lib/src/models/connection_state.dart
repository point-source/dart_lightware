import 'package:tcp_client_dart/tcp_client_dart.dart';

class LightwareConnectionState {
  LightwareConnectionState(this.state, {this.errorMessage = ''});

  final ConnectionState state;
  final String errorMessage;

  @override
  String toString() =>
      'LightwareConnectionState(state: $state, errorMessage: $errorMessage)';
}

enum ConnectionState {
  disconnected,
  connecting,
  connected,
  failed,
  unknown,
}

extension ToLwConnectionState on TcpConnectionState {
  ConnectionState toLightwareConnectionState() {
    return {
          TcpConnectionState.disconnected: ConnectionState.disconnected,
          TcpConnectionState.connecting: ConnectionState.connecting,
          TcpConnectionState.connected: ConnectionState.connected,
          TcpConnectionState.failed: ConnectionState.failed,
        }[this] ??
        ConnectionState.unknown;
  }
}
