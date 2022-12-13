import 'dart:async';

import 'package:dart_lightware/dart_lightware.dart';

Future<void> main() async {
  /// New lightware instance
  var lightware = Lightware('10.10.10.10');

  /// Print current connection states
  final sub = lightware.connectionState.listen(print);

  /// Get status of video input 7
  final r = await lightware.get(
    '/MEDIA/PORTS/VIDEO/STATUS/I7',
    property: 'SignalPresent',
  );

  /// Print telnet output from lightware
  for (var e in r) {
    print(e);
  }

  /// Route input 7 to output 13
  await lightware.call('/MEDIA/XP/VIDEO', 'switch', ['I7:O13']);

  // Cancel subscription
  sub.cancel();
}
