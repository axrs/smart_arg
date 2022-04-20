import 'dart:io';

import 'package:path/path.dart' as path;

import '../predicates.dart';
import 'argument.dart';

class DirectoryArgument extends Argument {
  /// If supplied, must this `Directory` property actually exist on disk?
  ///
  /// If the value is `true` and the directory does *not* exist, then the user
  /// will be told there is an error, will be shown the help screen and if
  /// [SmartArgApp.exitOnFailure] is set to `true`, the application will exit
  /// with the error code 1.
  final bool mustExist;

  const DirectoryArgument({
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
  Directory handleValue(String? key, dynamic value) {
    var normalizedAbsolutePath = path.normalize(path.absolute(value as String));
    var result = Directory(normalizedAbsolutePath);
    if (mustExist && isFalse(result.existsSync())) {
      throw DirectoryMustExistIoArgumentError(key!, normalizedAbsolutePath);
    }
    return result;
  }

  List<Directory> get emptyList => [];
}

/// An IO Argument Error that indicates that the [DirectoryArgument] identified
/// by [key] was assigned a [path] that could does not exist.
class DirectoryMustExistIoArgumentError extends InvalidIoArgumentError {
  @override
  final String key;
  final String path;

  DirectoryMustExistIoArgumentError(this.key, this.path);

  @override
  String get message =>
      'The path for `$key` should resolve to a directory that exists.';

  @override
  List<Object?> get props => [key, path];
}
