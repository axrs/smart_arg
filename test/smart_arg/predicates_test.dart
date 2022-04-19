import 'package:smart_arg_fork/src/predicates.dart' as p;
import 'package:test/test.dart';

void main() {
  group('predicates', () {
    test('isFalse', () {
      expect(p.isFalse(false), isTrue);
      expect(p.isFalse(true), isFalse);
      expect(p.isFalse(null), isFalse);
    });

    test('isNull', () {
      expect(p.isNull(false), isFalse);
      expect(p.isNull(true), isFalse);
      expect(p.isNull(null), isTrue);
      expect(p.isNull(<String>[]), isFalse);
      expect(p.isNull(123), isFalse);
    });

    test('isNotNull', () {
      expect(p.isNotNull(false), isTrue);
      expect(p.isNotNull(true), isTrue);
      expect(p.isNotNull(null), isFalse);
      expect(p.isNotNull(<String>[]), isTrue);
      expect(p.isNotNull(123), isTrue);
    });

    test('isNotBlank', () {
      expect(p.isNotBlank(''), isFalse);
      expect(p.isNotBlank(' \n'), isFalse);
      expect(p.isNotBlank(null), isFalse);
      expect(p.isNotBlank('hello '), isTrue);
    });
  });
}
