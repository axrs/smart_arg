import 'dart:io';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:meta/meta.dart';
import 'package:reflectable/reflectable.dart';

import 'arguments/arguments.dart';
import 'extended_help.dart';
import 'group.dart';
import 'mirror_argument_pair.dart';
import 'parser.dart';
import 'predicates.dart';
import 'reflector.dart';
import 'smart_arg_utils.dart';
import 'string_utils.dart';

class IndexedArgument {
  final int index;
  final String name;
  final String? value;

  IndexedArgument(this.index, this.name, [this.value]);

  @override
  String toString() => '$index:$name${value != null ? '=$value' : ''}';
}

class SmartArgMetadata {
  late final Parser parser;
  final Type type;
  final Map<String?, MirrorParameterPair> values = {};
  final Map<String?, MirrorParameterPair> commands = {};
  MirrorParameterPair? defaultCommand;
  final List<IndexedArgument> arguments = [];
  final List<IndexedArgument> unknownArguments = [];

  late SmartArg runnable;
  final Set<ValidationError> errors = {};
  late List<String> extras = [];
  late List<String> rawArguments = [];

  factory SmartArgMetadata.fromRoot(SmartArg runnable) {
    var inst = SmartArgMetadata._(runnable.runtimeType);
    inst.runnable = runnable;
    inst.runnable.metadata = inst;
    return inst;
  }

  factory SmartArgMetadata.withParent(
    SmartArg parent,
    Type type,
    MirrorParameterPair mpp,
  ) {
    var inst = SmartArgMetadata._(type);
    inst.runnable = construct(parent, mpp);
    inst.runnable.metadata = inst;
    return inst;
  }

  SmartArgMetadata._(this.type) {
    var typeMirror = SmartArg.reflectable.reflectType(type);
    parser = typeMirror.metadata.firstWhere((p) => p is Parser) as Parser;
    Group? currentGroup;
    for (var mirror in walkDeclarations(typeMirror as ClassMirror)) {
      currentGroup =
          mirror.metadata.firstWhereOrNull((m) => m is Group) as Group? ??
              currentGroup;

      var parameter = mirror.metadata.firstWhereOrNull((m) => m is Argument);
      if (parameter != null) {
        var mpp = MirrorParameterPair(
          mirror as VariableMirror,
          parameter as Argument,
          currentGroup,
        );
        var props = mpp.keys(parser);
        if (parameter is Command) {
          commands[mpp.displayKey] = mpp;
          if (parameter is DefaultCommand) {
            if (isNotNull(defaultCommand)) {
              errors.add(MultipleDefaultCommandConfigurationError(type));
            }
            defaultCommand = mpp;
          }
        } else {
          for (var key in props) {
            if (values.containsKey(key)) {
              errors.add(MultipleKeyConfigurationError(key!));
            } else {
              values[key] = mpp;
            }
          }
        }
      }
    }
  }
}

class SmartArgRunnable {
  final List<SmartArgMetadata> commandPath;

  SmartArgRunnable(this.commandPath);

  SmartArg get instance => commandPath.last.runnable;

  Future<void> run() async {
    if (commandPath.any((element) => element.runnable.help)) {
      SmartArg.output.writeln(instance.usage());
      if (instance.metadata.parser.exitOnHelp) {
        exit(0);
      }
    } else if (instance.metadata.errors.isNotEmpty) {
      for (var err in instance.metadata.errors) {
        SmartArg.errorOutput.writeln(err);
      }
      exit(1);
    } else {
      for (var i in commandPath) {
        await i.runnable.preCommandExecute();
      }
      await instance.execute();
      for (var i in commandPath.reversed) {
        await i.runnable.postCommandExecute();
      }
    }
  }
}

/// Base class for the [SmartArg] parser.
///
/// Your application should extend [SmartArg], add public properties,
/// and call the [SmartArg.parse()] method on your class.
@SmartArg.reflectable
class SmartArg {
  static const reflectable = Reflector.reflector;

  /// The environment for [SmartArg] as a map from string key to string value.
  ///
  /// The map is unmodifiable, and its content is retrieved from the operating
  /// system [Platform.environment] on unless provided otherwise.
  @visibleForTesting
  Map<String, String> environment = Platform.environment;

  @visibleForTesting
  static Stdout output = stdout;

  @visibleForTesting
  static Stdout errorOutput = stderr;

  //
  // Public API
  //
  @HelpArgument()
  late bool help = false;

  /// List of extras supplied on the command line.
  ///
  /// Extras are anything supplied on the command line that was not an option.
  List<String> get extras => metadata.extras;

  /// The Parent [SmartArg] instance for the current subcommand.
  SmartArg? parent;

  late SmartArgMetadata metadata = SmartArgMetadata.fromRoot(this);

  void onError(String message) {
    if (metadata.parser.exitOnFailure) {
      errorOutput.writeln(message);
      if (metadata.parser.printUsageOnExitFailure) {
        output.writeln();
        output.writeln(usage());
      }
      exit(1);
    }
  }

  /// Return a string telling the user how to use your application from the command line.
  String usage() {
    var lines = <String?>[];

    if (isNotNull(metadata.parser.description)) {
      lines.add(metadata.parser.description);
      lines.add('');
    }

    var helpKeys = <String>[];
    var helpGroups = <Group?>[];
    var helpDescriptions = <List<String>>[];

    if (metadata.values.isNotEmpty) {
      for (var mpp in metadata.values.values.toSet()) {
        var keys = <String?>[];

        keys.addAll(
          mpp.keys(metadata.parser).map((v) => v!.startsWith('-') ? v : '--$v'),
        );
        helpKeys.add(keys.join(', '));
        helpGroups.add(mpp.group);

        var helpLines = <String>[mpp.argument.help ?? 'no help available'];

        if (mpp.argument.isRequired) {
          helpLines.add('[REQUIRED]');
        }

        var envVar = mpp.argument.environmentVariable;
        if (isNotBlank(envVar)) {
          helpLines.add('[Environment Variable: \$$envVar]');
        }

        helpLines.addAll(mpp.argument.additionalHelpLines);
        helpDescriptions.add(helpLines);
      }
    }

    const lineIndent = 2;
    const lineWidth = 80 - lineIndent;
    var linePrefix = ' ' * lineIndent;
    const optionColumnWidth = 25;
    const helpLineWidth = lineWidth - optionColumnWidth;

    {
      void trailingHelp(Group? group) {
        if (isNotNull(group?.afterHelp)) {
          lines.add('');
          lines.add(
            indent(
              hardWrap(group!.afterHelp!, lineWidth - lineIndent),
              lineIndent,
            ),
          );
        }
      }

      Group? currentGroup;

      for (var i = 0; i < helpKeys.length; i++) {
        var thisGroup = helpGroups[i];

        if (thisGroup != currentGroup) {
          trailingHelp(currentGroup);

          if (isNotNull(currentGroup)) {
            lines.add('');
          }

          lines.add(thisGroup!.name);

          if (isNotNull(thisGroup.beforeHelp)) {
            lines.add(
              indent(
                hardWrap(thisGroup.beforeHelp!, lineWidth - lineIndent),
                lineIndent,
              ),
            );
            lines.add('');
          }
        }

        var keyDisplay = linePrefix + helpKeys[i];

        var thisHelpDescriptions = helpDescriptions[i].join('\n');
        thisHelpDescriptions = hardWrap(thisHelpDescriptions, helpLineWidth);
        thisHelpDescriptions = indent(thisHelpDescriptions, optionColumnWidth);

        if (keyDisplay.length <= optionColumnWidth - 1) {
          thisHelpDescriptions = thisHelpDescriptions.replaceRange(
            0,
            keyDisplay.length,
            keyDisplay,
          );
        } else {
          lines.add(keyDisplay);
        }

        lines.add(thisHelpDescriptions);

        currentGroup = helpGroups[i] ?? currentGroup;
      }

      trailingHelp(currentGroup);
    }

    if (metadata.commands.isNotEmpty) {
      lines.add('');
      lines.add('COMMANDS');
      List<MirrorParameterPair>.from(metadata.commands.values)
          .sortedBy((mpp) => mpp.displayKey)
          .forEach((mpp) {
        var commandDisplay = '$linePrefix${mpp.displayKey}';
        var suffix = (mpp.argument is DefaultCommand) ? '\n[DEFAULT]' : '';
        var commandHelp = hardWrap(
          '${argumentHelp(mpp) ?? ''}$suffix',
          helpLineWidth,
        );
        commandHelp = indent(commandHelp, optionColumnWidth);
        if (commandDisplay.length <= optionColumnWidth - 1) {
          commandHelp = commandHelp.replaceRange(
            0,
            commandDisplay.length,
            commandDisplay,
          );
        } else {
          lines.add(commandDisplay);
        }
        lines.add(commandHelp);
      });
    }

    for (var eh in metadata.parser.extendedHelp ?? <ExtendedHelp>[]) {
      if (isNull(eh.help)) {
        throw StateError('Help.help must be set');
      }

      lines.add('');

      if (isNotNull(eh.header)) {
        lines.add(hardWrap(eh.header!, lineWidth));
        lines.add(
          indent(hardWrap(eh.help!, lineWidth - lineIndent), lineIndent),
        );
      } else {
        lines.add(hardWrap(eh.help!, lineWidth));
      }
    }

    return lines.join('\n');
  }

  SmartArgRunnable parse(List<String> arguments) {
    var expandedArguments = expandClusteredShortArguments(arguments);
    var commandPath = resolvePath(
      SmartArgMetadata.fromRoot(this),
      expandedArguments,
      environment,
    );
    for (var cmd in commandPath) {
      cmd.runnable.validate();
    }
    return SmartArgRunnable(commandPath);
  }

  void validate() {
    // Check to see if we have any required arguments missing
    var isMissing = <String>[];

    for (var mpp in metadata.values.values) {
      var argumentName = mpp.displayKey;
      var envVar = mpp.argument.environmentVariable;
      if (isFalse(mpp.isSet) && isNotBlank(envVar)) {
        var envVarValue = environment[envVar];
        if (isNotBlank(envVarValue)) {
          metadata.errors.addAll(
            attemptValueSet(metadata, argumentName, envVarValue!.trim()),
          );
        }
      }

      if (mpp.argument.isRequired && isFalse(mpp.isSet)) {
        isMissing.add(mpp.displayKey);
      }
    }

    for (var missing in isMissing) {
      metadata.errors.add(MissingRequiredValueError(missing));
    }

    var parser = metadata.parser;
    var extrasLength = extras.length;
    if (parser.minimumExtras != null && extrasLength < parser.minimumExtras!) {
      metadata.errors.add(
        NotEnoughExtrasSuppliedError(parser.minimumExtras!, extrasLength),
      );
    } else if (parser.maximumExtras != null &&
        extrasLength > parser.maximumExtras!) {
      metadata.errors.add(
        TooManyExtrasSuppliedError(parser.maximumExtras!, extrasLength),
      );
    }
  }

  /// Awaited before a [SmartArg] is executed
  Future<void> preCommandExecute() => Future.value();

  /// Awaited after a [SmartArg] is executed
  Future<void> postCommandExecute() => Future.value();

  Future<void> execute() async {
    var rawArguments = metadata.rawArguments;
    if (isNotNull(metadata.defaultCommand)) {
      await construct(this, metadata.defaultCommand!).parse(rawArguments).run();
    } else {
      onError(
        'Implementation not defined: ${rawArguments.isEmpty ? '<no arguments provided>' : rawArguments.join(' ')}',
      );
    }
  }
}

/// A [ValidationError] that indicates that not enough extra arguments were
/// provided to a [SmartArg] instance.
class NotEnoughExtrasSuppliedError extends ValidationError {
  final int minimum;
  final int actual;

  NotEnoughExtrasSuppliedError(this.minimum, this.actual);

  @override
  String get message =>
      'Expected at a minimum of $minimum values for `extras` but only $actual was supplied.';

  @override
  List<Object?> get props => [minimum, actual];
}

/// A [ValidationError] that indicates that too many extra arguments were
/// provided to a [SmartArg] instance
class TooManyExtrasSuppliedError extends ValidationError {
  final int maximum;
  final int actual;

  TooManyExtrasSuppliedError(this.maximum, this.actual);

  @override
  String get message =>
      'Expected at a maximum of $maximum values for `extras` but $actual was supplied.';

  @override
  List<Object?> get props => [maximum, actual];
}
