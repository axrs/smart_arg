import 'validation_error.dart';
import 'argument.dart';

class Command extends Argument {
  const Command({
    String? short,
    dynamic long,
    String? help,
  }) : super(
          short: short,
          long: long,
          help: help,
        );

  @override
  void handleValue(String? key, value) {}
}

class DefaultCommand extends Command {
  const DefaultCommand({
    String? short,
    dynamic long,
    String? help,
  }) : super(
          short: short,
          long: long,
          help: help,
        );
}

/// A Validation Error that indicates that multiple [DefaultCommand] arguments
/// were identified for the class of [type]
class MultipleDefaultCommandConfigurationError
    extends ArgumentConfigurationError {
  final Type type;

  MultipleDefaultCommandConfigurationError(this.type);

  @override
  String get message => '`$type` should only have one DefaultCommand.';

  @override
  List<Object?> get props => [type];
}
