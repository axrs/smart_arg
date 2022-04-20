import 'validation_error.dart';

enum ScopeType { local, inherit }

/// Annotation class to provide additional hints on parsing a particular property.
abstract class Argument {
  /// [Argument]s defined with [ScopeType.local] are shared with all sub-commands
  /// (and sub-commands, to any level of depths). Applications can define a
  /// [ScopeType.inherited] on the top-level command, in one place, to allow end
  /// users to specify this options anywhere: not only on the top-level command
  /// but also on any of the sub-commands and nested sub-commands
  final ScopeType scope;

  /// Short version, if any, that can be used for this property.
  ///
  /// Long option will be the name of the property, the short option will be
  /// an alias of the long option.
  ///
  /// ```
  /// @Parameter(short: 'n')
  /// String name;
  /// ```
  ///
  /// With the above configuration, the `name` property can be set on the command
  /// line by using --name John, --name=John, -n John or -n=John.
  final String? short;

  /// Long key, if any, that can be used for this property.
  ///
  /// * Set to false if no long key is desired.
  /// * Leave empty to make the long key the same as the class variable.
  /// * Set to a string to use instead of the class variable name. The class
  ///   variable name will be translated from camel case to a dashed string.
  ///   i.e. multiWordParameter would translate to the command line option
  ///   --multi-word-parameter.
  final dynamic long;

  /// Description of the property to be used in the help output.
  /// If not specified, [SmartArg] will attempt to use reflection to obtain the
  /// [Parser.description] field instead.
  final String? help;

  /// Is this option required?
  ///
  /// If this is set to `true` and it is not supplied, the user will be told
  /// there is an error, will be shown the help screen and if
  /// [SmartArgApp.exitOnFailure] is set to `true`, the application will exit
  /// with the error code 1.
  final bool isRequired;

  /// Environment Variable, if any, that can be used for this property.
  final String? environmentVariable;

  const Argument({
    this.short,
    this.long,
    this.help,
    this.environmentVariable,
    bool? isRequired,
    ScopeType? scope,
  })  : isRequired = isRequired ?? false,
        scope = scope ?? ScopeType.local;

  List<String> specialKeys(String? short, String? long) {
    return [];
  }

  dynamic handleValue(String? key, dynamic value);

  bool get needsValue => true;

  List<String> get additionalHelpLines => [];
}

/// A base class that indicates an [Argument] identified by [key] was supplied
/// an invalid value
abstract class InvalidArgumentError extends ValidationError {
  String get key;
}

/// A base class that indicates an [Argument] identified by [key] was supplied
/// an invalid value that relates to an IO
abstract class InvalidIoArgumentError extends InvalidArgumentError {}

/// An Invalid Argument Error that indicates that the [DoubleArgument], or
/// [IntegerArgument], identified by [key] was assigned a [value] that is below
/// the expected [lowerBound].
class BelowLowerBoundsArgumentError extends InvalidArgumentError {
  @override
  final String key;
  final num lowerBound;
  final num value;

  BelowLowerBoundsArgumentError(this.key, this.lowerBound, this.value);

  @override
  String get message => '$key must be at least $lowerBound';

  @override
  List<Object?> get props => [key, lowerBound, value];
}

/// An Invalid Argument Error that indicates that the [DoubleArgument], or
/// [IntegerArgument], identified by [key] was assigned a [value] that is above
/// the expected [upperBound].
class AboveUpperBoundsArgumentError extends InvalidArgumentError {
  @override
  final String key;
  final num upperBound;
  final num value;

  AboveUpperBoundsArgumentError(this.key, this.upperBound, this.value);

  @override
  String get message => '$key must be at most $upperBound';

  @override
  List<Object?> get props => [key, upperBound, value];
}

/// An Invalid Argument Error that indicates that a [key] was configured for
/// multiple [Argument] definitions.
class MultipleKeyConfigurationError extends InvalidArgumentError {
  @override
  final String key;

  MultipleKeyConfigurationError(this.key);

  @override
  String get message => '`$key` was configured multiple times.';

  @override
  List<Object?> get props => [key];
}

/// An Invalid Argument Error that indicates that a [key] was assigned a value
/// multiple times.
class MultipleKeyAssignmentError extends InvalidArgumentError {
  @override
  final String key;

  MultipleKeyAssignmentError(this.key);

  @override
  String get message => '`$key` was assigned multiple times.';

  @override
  List<Object?> get props => [key];
}

/// An Invalid Argument Error that indicates that an [Annotation] identified by
/// [key] has no value, but is annotated as being required.
class MissingRequiredValueError extends InvalidArgumentError {
  @override
  final String key;

  MissingRequiredValueError(this.key);

  @override
  String get message => 'Required argument `$key` is missing.';

  @override
  List<Object?> get props => [key];
}
