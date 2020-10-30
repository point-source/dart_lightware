A dart package for communicating with lightware products via LW3.

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

## Usage

A simple usage example:

```dart
import 'package:lightware/lightware.dart';

main() {
  var target = InternetAddress('10.0.0.1');
  var lw = new Lightware(target);
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://example.com/issues/replaceme
