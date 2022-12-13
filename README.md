A dart library for controlling lightware devices over a network socket

## Features

- Persistent connection which can auto-reconnect when dropped or failed
- Commands are sent and matched with IDs to allow async send/receive
- Supports multiline receive

### Supported commands
[x] Get
[x] Set
[x] Call
[x] Man

## Usage

```dart
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

```

## Additional information

Issues and feature requests can be filed [here][2].

Library was created according to the [Lightware API documentation][3]

[1]: https://pub.dev/packages/dart_lightware
[2]: https://github.com/point-source/dart_lightware/issues
[3]: https://lightware.com/pub/media/lightware/filedownloader/file/White-Paper/Lightware_s_Open_API_Environment_v3.pdf

