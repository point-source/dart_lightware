import 'package:dart_lightware/dart_lightware.dart';
import 'package:test/test.dart';

void main() {
  group('Init: ', () {
    final lightware = Lightware('10.10.10.10');

    test('Instance', () {
      expect(lightware, isA<Lightware>());
    });
  });
}
