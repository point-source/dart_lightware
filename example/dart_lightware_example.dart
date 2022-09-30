import 'package:dart_lightware/dart_lightware.dart';

Future<void> main() async {
  var lightware = Lightware('10.10.8.106');

  final r = await lightware.get(
    '/MEDIA/PORTS/VIDEO/STATUS/I7',
    property: 'SignalPresent',
  );

  r.forEach(print);

  final c = await lightware.call('/MEDIA/XP/VIDEO', 'switch', ['I7:O13']);

  c.forEach(print);
}
