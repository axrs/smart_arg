import 'package:collection/collection.dart';
import 'package:recase/recase.dart';

import 'argument.dart';
import 'predicates.dart';

class EnumArgument<T> extends Argument {
  /// Gets the supplied Enum values
  ///
  /// Note: It would be ideal to use reflectables to get this value for us.
  /// This is possible, using (reflectType(T) as ClassMirror).invokeGetter(#values)...
  /// While this worked for the unit tests, it failed during an actual build and run
  final List<T> values;

  const EnumArgument({
    required this.values,
    String? short,
    dynamic long,
    String? help,
    bool? isRequired,
    ScopeType? scope,
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
    var val = _findFirstValue(value);
    if (isNull(val)) {
      var valids = _validArgs();
      throw ArgumentError('$key must be one of $valids');
    }
    return val;
  }

  /// Finds the first Enum value which matches the supplied value.
  /// Enumeration values are compared by using camelCase names
  T? _findFirstValue(dynamic val) {
    return values.firstWhereOrNull(
      (T element) =>
          element.toString().split('.')[1].camelCase ==
          val.toString().camelCase,
    );
  }

  /// Returns an iterable of Enum values represented in param-case
  Iterable<String> _validArgs() {
    return values.map((T e) => e.toString().split('.')[1].paramCase);
  }

  @override
  List<String> get additionalHelpLines {
    // Local type is needed, otherwise result winds up being a
    // List<dynamic> which is incompatible with the return type.
    // Therefore, ignore the suggestion from dartanalyzer
    //
    // ignore: omit_local_variable_types
    List<String> result = [];
    var oneOfList = _validArgs().join(', ');
    result.add('must be one of $oneOfList');
    return result;
  }
}
