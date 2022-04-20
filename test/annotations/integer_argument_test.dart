import 'package:smart_arg_fork/smart_arg_fork.dart';
import 'package:test/test.dart';

void main() {
  group('IntegerArgument', () {
    group('handleValue', () {
      test('simple value', () {
        var arg = const IntegerArgument();

        expect(arg.handleValue('key', '300'), 300);
      });

      group('minimum/maximum', () {
        test('in range', () {
          var arg = const IntegerArgument(minimum: 100, maximum: 500);
          expect(arg.handleValue('key', '300'), 300);
        });

        test('too low', () {
          var arg = const IntegerArgument(minimum: 100, maximum: 500);

          expect(
            () => arg.handleValue('key', '95'),
            throwsA(const TypeMatcher<BelowLowerBoundsArgumentError>()),
          );
        });

        test('too high', () {
          var arg = const IntegerArgument(minimum: 100, maximum: 500);

          expect(
            () => arg.handleValue('key', '505'),
            throwsA(const TypeMatcher<AboveUpperBoundsArgumentError>()),
          );
        });
      });
    });
  });
}
