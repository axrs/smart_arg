bool isFalse(dynamic value) => value == false;

bool isNull(dynamic value) => value == null;

bool isNotNull(dynamic value) => isFalse(isNull(value));

bool isNotBlank(String? value) => isNotNull(value) && value!.trim().isNotEmpty;

/// Returns `true` if the supplied [value] is considered to be a `short` argument
bool isShortArgument(String value) =>
    isFalse(isLongArgument(value)) &&
    value.startsWith('-')
    // Single character
    &&
    value.length == 2;

bool isShortArgumentAssignment(String value) {
  var isPotentialShortArgument =
      value.startsWith('-') && isFalse(value.startsWith('--'));
  var isLongerThanShort = value.length > 2;
  var isAssignment = isLongerThanShort && value.substring(2, 3) == '=';
  return isPotentialShortArgument && isLongerThanShort && isAssignment;
}

/// Returns `true` if the supplied [value] is considered to be a `long` argument
bool isLongArgument(String value) => value.startsWith('--') && value.length > 2;

/// Returns `true` if the supplied [value] is either a `long` or a `short` argument
bool isArgument(String value) =>
    isLongArgument(value) || isShortArgument(value);

/// Returns `true` if the supplied [value] is a series of short arguments.
bool isClusteredShortArguments(String value) {
  var isPotentialShortArgument =
      value.startsWith('-') && isFalse(value.startsWith('--'));
  var isLongerThanShort = value.length > 2;
  var isAssignment = isLongerThanShort && value.substring(2, 3) == '=';
  return isPotentialShortArgument && isLongerThanShort && isFalse(isAssignment);
}
