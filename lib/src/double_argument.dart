import 'argument.dart';

class DoubleArgument extends Argument {
  /// Minimum number allowed, if any.
  final double? minimum;

  /// Maximum number allowed, if any.
  final double? maximum;

  const DoubleArgument({
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
  double? handleValue(String? key, dynamic value) {
    var result = double.tryParse(value as String);

    if (minimum != null && result! < minimum!) {
      throw ArgumentError('$key must be at least $minimum');
    }

    if (maximum != null && result! > maximum!) {
      throw ArgumentError('$key must be at most $maximum');
    }

    return result;
  }

  List<double> get emptyList => [];
}
