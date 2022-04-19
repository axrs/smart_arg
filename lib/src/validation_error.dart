abstract class ValidationError implements Exception {
  String get message;

  @override
  String toString() => message;
}

class MultipleKeyAssignmentError extends ValidationError {
  final String key;

  MultipleKeyAssignmentError(this.key);

  @override
  String get message => '`$key` was assigned multiple times.';

  @override
  bool operator ==(Object other) =>
      other is MultipleKeyAssignmentError && hashCode == other.hashCode;

  @override
  int get hashCode => 1 + key.hashCode;
}

class MultipleKeyConfigurationError extends ValidationError {
  final String key;

  MultipleKeyConfigurationError(this.key);

  @override
  String get message => '`$key` was configured multiple times.';

  @override
  bool operator ==(Object other) =>
      other is MultipleKeyConfigurationError && hashCode == other.hashCode;

  @override
  int get hashCode => 2 + key.hashCode;
}

class MissingRequiredValueError extends ValidationError {
  final String key;

  MissingRequiredValueError(this.key);

  @override
  String get message => 'Required argument `$key` is missing.';

  @override
  bool operator ==(Object other) =>
      other is MissingRequiredValueError && hashCode == other.hashCode;

  @override
  int get hashCode => 3 + key.hashCode;
}

class NotEnoughExtrasSuppliedError extends ValidationError {
  final int minimum;
  final int actual;

  NotEnoughExtrasSuppliedError(this.minimum, this.actual);

  @override
  String get message =>
      'Expected at a minimum of $minimum values for `extras` but only $actual was supplied.';

  @override
  bool operator ==(Object other) =>
      other is NotEnoughExtrasSuppliedError && hashCode == other.hashCode;

  @override
  int get hashCode => 4 + minimum.hashCode + 5 + actual.hashCode;
}

class TooManyExtrasSuppliedError extends ValidationError {
  final int maximum;
  final int actual;

  TooManyExtrasSuppliedError(this.maximum, this.actual);

  @override
  String get message =>
      'Expected at a maximum of $maximum values for `extras` but $actual was supplied.';

  @override
  bool operator ==(Object other) =>
      other is TooManyExtrasSuppliedError && hashCode == other.hashCode;

  @override
  int get hashCode => 6 + maximum.hashCode + 7 + actual.hashCode;
}

class DefaultCommandConfigurationError extends ValidationError {
  final Type type;

  DefaultCommandConfigurationError(this.type);

  @override
  String get message => '`$type` should only have one DefaultCommand.';

  @override
  bool operator ==(Object other) =>
      other is DefaultCommandConfigurationError && hashCode == other.hashCode;

  @override
  int get hashCode => 8 + type.hashCode;
}

class DirectoryMustExistError extends ValidationError {
  final String key;
  final String value;

  DirectoryMustExistError(this.key, this.value);

  @override
  String get message => '`$key` (`$value`) should resolve to a directory that exists.';

  @override
  bool operator ==(Object other) =>
      other is DirectoryMustExistError && hashCode == other.hashCode;

  @override
  int get hashCode => 9 + key.hashCode + 10 + value.hashCode;
}

class MissingKeyConfigurationError extends ValidationError {
  final String key;

  MissingKeyConfigurationError(this.key);

  @override
  String get message => '`$key` could not be found.';

  @override
  bool operator ==(Object other) =>
      other is MissingKeyConfigurationError && hashCode == other.hashCode;

  @override
  int get hashCode => 11 + key.hashCode;
}

