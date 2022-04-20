import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:smart_arg_fork/smart_arg_fork.dart';
import 'package:test/test.dart';

void main() {
  group('DirectoryArgument', () {
    test('emptyList', () {
      var arg = const DirectoryArgument();
      // ignore: unnecessary_type_check
      expect(arg.emptyList is List, true);

      // Make sure we can add a Directory type directly
      arg.emptyList.add(Directory('.'));
    });

    group('handleValue', () {
      test('returns directory', () {
        var arg = const DirectoryArgument();
        var value = arg.handleValue('dir', path.join('.', 'lib'));

        expect(value.path, contains('${path.separator}lib'));
      });

      group('must exist', () {
        test('exists', () {
          var arg = const DirectoryArgument(mustExist: true);
          var value = arg.handleValue('dir', path.join('.', 'lib'));

          expect(value.path, contains('${path.separator}lib'));
        });

        test('does not exists', () {
          var arg = const DirectoryArgument(mustExist: true);

          expect(
            () => arg.handleValue('dir', path.join('.', 'bad-directory-name')),
            throwsA(const TypeMatcher<DirectoryMustExistIoArgumentError>()),
          );
        });
      });
    });
  });
}
