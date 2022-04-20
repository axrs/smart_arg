import 'dart:io';

import 'package:path/path.dart' as path;

import '../predicates.dart';
import 'argument.dart';

class FileArgument extends Argument {
  /// If supplied, must this `File` property actually exist on disk?
  ///
  /// If the value is `true` and the file does *not* exist, then the user will
  /// be told there is an error, will be shown the help screen and if
  /// [SmartArgApp.exitOnFailure] is set to `true`, the application will exit
  /// with the error code 1.
  final bool mustExist;

  const FileArgument({
    String? short,
    dynamic long,
    String? help,
    bool? isRequired,
    ScopeType? scope,
    this.mustExist = false,
    String? environmentVariable,
  }) : super(
          short: short,
          long: long,
          help: help,
          isRequired: isRequired,
          scope: scope,
          environmentVariable: environmentVariable,
        );

  @override
  File handleValue(String? key, dynamic value) {
    var normalizedAbsolutePath = path.normalize(path.absolute(value as String));
    var result = File(normalizedAbsolutePath);
    if (mustExist && isFalse(result.existsSync())) {
      throw FileMustExistIoArgumentError(key!, normalizedAbsolutePath);
    }
    return result;
  }

  List<File> get emptyList => [];
}

/// An IO Argument Error that indicates that the [FileArgument] identified
/// by [key] was assigned a [path] that could does not exist.
class FileMustExistIoArgumentError extends InvalidIoArgumentError {
  @override
  final String key;
  final String path;

  FileMustExistIoArgumentError(this.key, this.path);

  @override
  String get message =>
      'The path for `$key` should resolve to a file that exists.';

  @override
  List<Object?> get props => [key, path];
}
