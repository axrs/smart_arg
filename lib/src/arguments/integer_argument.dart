import 'argument.dart';

class IntegerArgument extends Argument {
  /// Minimum number allowed, if any.
  final int? minimum;

  /// Maximum number allowed, if any.
  final int? maximum;

  const IntegerArgument({
    String? short,
    dynamic long,
    String? help,
    bool? isRequired,
    ScopeType? scope,
    this.minimum,
    this.maximum,
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
  int? handleValue(String? key, dynamic value) {
    var result = int.tryParse(value as String);

    if (minimum != null && result! < minimum!) {
      throw BelowLowerBoundsArgumentError(key!, minimum!, result);
    }

    if (maximum != null && result! > maximum!) {
      throw AboveUpperBoundsArgumentError(key!, maximum!, result);
    }

    return result;
  }

  List<int> get emptyList => [];
}
