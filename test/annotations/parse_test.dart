import 'package:smart_arg_fork/smart_arg_fork.dart';
import 'package:test/test.dart';

void main() {
  group('Parser', () {
    test('Parser', () {
      var app = Parser();
      expect(app, isNotNull);
    });
  });
}
