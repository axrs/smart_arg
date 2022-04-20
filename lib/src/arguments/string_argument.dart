import 'argument.dart';

class StringArgument extends Argument {
  /// Parameter must be one of the items in the list.
  final List<String> mustBeOneOf;

  const StringArgument({
    String? short,
    dynamic long,
    String? help,
    bool? isRequired,
    ScopeType? scope,
    this.mustBeOneOf = const [],
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
  dynamic handleValue(String? key, dynamic value) {
    if (mustBeOneOf.isNotEmpty && mustBeOneOf.contains(value) == false) {
      throw NotOneOfPredefinedValuesError(key!, mustBeOneOf, value as String);
    }
    return value;
  }

  @override
  List<String> get additionalHelpLines {
    var result = <String>[];
    if (mustBeOneOf.isNotEmpty) {
      var oneOfList = mustBeOneOf.join(', ');
      result.add('must be one of $oneOfList');
    }
    return result;
  }

  List<String> get emptyList => [];
}

/// An Invalid Argument Error that indicates that the [StringArgument]
/// identified by [key] was assigned a [value] that is outside the pre-defined
/// [StringArgument.mustBeOneOf] [values]
class NotOneOfPredefinedValuesError extends InvalidArgumentError {
  @override
  final String key;
  final List<String> values;
  final String value;

  NotOneOfPredefinedValuesError(this.key, this.values, this.value);

  @override
  String get message => '`$key` must be one of ${values.join(', ')}';

  @override
  List<Object?> get props => [key, value, values];
}
