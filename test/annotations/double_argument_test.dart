import 'package:smart_arg_fork/smart_arg_fork.dart';
import 'package:test/test.dart';

void main() {
  group('DoubleArgument', () {
    group('handleValue', () {
      test('simple value', () {
        var arg = const DoubleArgument();

        expect(arg.handleValue('key', '300'), 300);
      });

      group('minimum/maximum', () {
        test('in range', () {
          var arg = const DoubleArgument(minimum: 99.9, maximum: 499.9);
          expect(arg.handleValue('key', '300.0'), 300.0);
        });

        test('too low', () {
          var arg = const DoubleArgument(minimum: 99.9, maximum: 499.9);

          expect(
            () => arg.handleValue('key', '99.8'),
            throwsA(const TypeMatcher<BelowLowerBoundsArgumentError>()),
          );
        });

        test('too high', () {
          var arg = const DoubleArgument(minimum: 99.9, maximum: 499.9);

          expect(
            () => arg.handleValue('key', '499.91'),
            throwsA(const TypeMatcher<AboveUpperBoundsArgumentError>()),
          );
        });
      });
    });
  });
}
