import 'package:smart_arg_fork/smart_arg_fork.dart';
import 'package:test/test.dart';

void main() {
  group('StringArgument', () {
    group('handleValue', () {
      test('simple value', () {
        var arg = const StringArgument();

        expect(arg.handleValue('key', 'hello'), 'hello');
      });

      test('must be one of (valid)', () {
        var arg = const StringArgument(mustBeOneOf: ['hello', 'howdy']);
        expect(arg.handleValue('key', 'hello'), 'hello');
      });

      test('must be one of (invalid)', () {
        var arg = const StringArgument(mustBeOneOf: ['hello', 'howdy']);

        expect(
          () => arg.handleValue('key', 'cya'),
          throwsA(const TypeMatcher<NotOneOfPredefinedValuesError>()),
        );
      });
    });
  });
}
