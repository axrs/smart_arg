import 'dart:math';

import 'package:collection/collection.dart';
import 'package:reflectable/reflectable.dart';

import 'arguments/arguments.dart';
import 'mirror_argument_pair.dart';
import 'parser.dart';
import 'predicates.dart';
import 'smart_arg.dart';

/// Given a [parent] instance, resolve the supplied [mpp] as a pre-instantiated,
/// or newly constructed [SmartArg] object
SmartArg construct(SmartArg parent, MirrorParameterPair mpp) {
  var a = mpp.mirror;
  SmartArg? cmd;
  try {
    var instanceMirror = SmartArg.reflectable.reflect(parent);
    cmd = instanceMirror.invokeGetter(a.simpleName) as SmartArg;
  } catch (error) {
    //noop. Failed using pre-defined value, so will revert to constructing
  } finally {
    if (cmd == null) {
      // Construct the new command
      var b = a.type as ClassMirror;
      cmd = b.newInstance('', []) as SmartArg;
    }
  }
  cmd.parent = parent;
  return cmd;
}

/// Recursively walks the [classMirror] and it's associated
/// [ClassMirror.superclass] (and subsequently declared [mixin]s) to find all
/// public [VariableMirror] declarations
List<DeclarationMirror> walkDeclarations(ClassMirror classMirror) {
  ClassMirror? superMirror;
  try {
    superMirror = classMirror.superclass;
  } on NoSuchCapabilityError catch (_) {
    // A NoSuchCapabilityError is thrown when the superclass not annotated
    // with @SmartArg.reflectable
  }
  var mirrors = <DeclarationMirror>[];
  if (isNotNull(superMirror)) {
    mirrors = walkDeclarations(superMirror!);
  }
  var classVals = classMirror.declarations.values;
  return [classVals, mirrors]
      .expand((e) => e)
      .where((p) => p is VariableMirror && isFalse(p.isPrivate))
      .toList();
}

/// Walks over the raw [expandedArgs], identifying all arguments that resolve
/// to an annotated [Command] from the [root] type. Once a [Command] is found,
/// it replaces the [root] for the remainder of the processing.
///
/// For Example:
///
/// ```
/// RootSmartArg
///   - @Command Cmd cmd
///   - @Command Father father
///      - @Command Child child
/// ```
///
/// `[--verbose --arg 1]` resolves an empty path (`[ ]`).
///
/// `[--verbose cmd --arg 1 sub-cmd]` resolves a path to the Cmd as (`[ cmd ]`).
///
/// `[--verbose father --arg 1 child]` resolves a path to the Child, from the
/// Father (`[ Father, Child ]`).
List<SmartArgMetadata> resolvePath(
  SmartArgMetadata root,
  List<String> expandedArgs,
  Map<String, String> environment,
) {
  var argTerminator = root.parser.argumentTerminator;
  var mainArgs = isNull(argTerminator)
      ? expandedArgs
      : expandedArgs.takeWhile(
          (arg) => arg.toLowerCase() != argTerminator!.toLowerCase(),
        );

  var current = root;
  var path = <SmartArgMetadata>[current];
  var isNowTrailing = false;

  for (var argIndex = 0; argIndex < mainArgs.length; argIndex++) {
    var candidate = mainArgs.elementAt(argIndex);

    if ((isArgument(candidate) ||
            isShortArgument(candidate) ||
            isShortArgumentAssignment(candidate)) &&
        (current.parser.allowTrailingArguments || isFalse(isNowTrailing))) {
      var argumentParts = candidate.split('=');
      var argumentName = argumentParts.first;
      if (isLongArgument(argumentName)) {
        argumentName = argumentName.substring(2);
      }
      if (isFalse(current.values.containsKey(argumentName))) {
        // Unknown argument. Store for later
        current.unknownArguments.add(IndexedArgument(argIndex, candidate));
        continue;
      }

      // Known option
      var argConfig = current.values[argumentName]!;
      if (isFalse(argConfig.argument.needsValue)) {
        // Boolean or simple flag
        current.arguments.add(IndexedArgument(argIndex, candidate));
        current.errors.addAll(attemptValueSet(current, argumentName, ''));
        continue;
      }

      // Option expecting a value
      var hasValueViaEqual = argumentParts.length > 1;
      var value = argumentParts.skip(1).join('=');
      if (hasValueViaEqual) {
        current.arguments.add(IndexedArgument(argIndex, candidate));
        current.errors.addAll(attemptValueSet(current, argumentName, value));
      } else {
        if (argIndex >= mainArgs.length - 1) {
          current.errors.add(MissingRequiredValueError(argConfig.displayKey));
        } else {
          // Fetch the next value
          value = mainArgs.elementAt(++argIndex);
          current.arguments
              .add(IndexedArgument(argIndex - 1, candidate, value));
          current.errors.addAll(attemptValueSet(current, argumentName, value));
        }
      }
      continue;
    } else if (isFalse(current.commands.containsKey(candidate))) {
      current.unknownArguments.add(IndexedArgument(argIndex, candidate));
      isNowTrailing = true;
      continue;
    }
    // candidate is a command on the current type
    var mpp = current.commands[candidate];
    var variableName = mpp!.mirror.simpleName;
    var cm = SmartArg.reflectable.reflectType(current.type) as ClassMirror;
    var vm = cm.declarations[variableName] as VariableMirror;
    current = SmartArgMetadata.withParent(
      current.runnable,
      vm.dynamicReflectedType,
      mpp,
    );
    path.add(current);
    isNowTrailing = false;
  }
  // FIXME Set values from inherited scope
  resolveEnvVars(environment, path);

  // Add all the args that appeared AFTER the last argument as extras
  for (var cmd in path) {
    var lastIdx = cmd.arguments.lastOrNull?.index ?? -1;
    cmd.unknownArguments
        .where((a) => lastIdx < a.index || cmd.parser.allowTrailingArguments)
        .forEach((element) => cmd.extras.add(element.name));
    cmd.rawArguments = expandedArgs;
  }
  var argsAfterTerminator = expandedArgs.skip(mainArgs.length + 1).toList();
  path.last.extras.addAll(argsAfterTerminator);
  return path;
}

void resolveEnvVars(
  Map<String, String> environment,
  List<SmartArgMetadata> commandPath,
) {
  for (var cmd in commandPath) {
    for (var mpp in cmd.values.values) {
      var argumentName = mpp.displayKey;
      var envVar = mpp.argument.environmentVariable;
      if (isFalse(mpp.isSet) && isNotBlank(envVar)) {
        var envVarValue = environment[envVar];
        if (isNotBlank(envVarValue)) {
          cmd.errors.addAll(
            attemptValueSet(cmd, argumentName, envVarValue!.trim()),
          );
        }
      }
    }
  }
}

/// Expands any clustered short arguments `-abc` into separate values
/// [`-a`, `-b`, `-c`]
List<String> expandClusteredShortArguments(List<String> arguments) {
  var result = <String>[];
  for (var arg in arguments) {
    if (isClusteredShortArguments(arg)) {
      var individualArgs = arg.split('').skip(1).map((v) => '-$v').toList();
      result.addAll(individualArgs);
    } else {
      result.add(arg);
    }
  }
  return result;
}

/// Attempts to set the value of [cmd.reflectable.argumentName] to the supplied
/// value.
///
/// If unsuccessful, the a List of [Error]s is returned.
List<ValidationError> attemptValueSet(
  SmartArgMetadata cmd,
  String? argumentName,
  dynamic value,
) {
  var errors = <ValidationError>[];
  var instanceMirror = SmartArg.reflectable.reflect(cmd.runnable);
  var argumentConfiguration = cmd.values[argumentName]!;
  try {
    value = argumentConfiguration.argument.handleValue(argumentName, value);
  } on ValidationError catch (ex) {
    errors.add(ex);
    return errors;
  }

  // Try setting it as a list first
  dynamic instanceValue;
  try {
    instanceValue = instanceMirror.invokeGetter(
      argumentConfiguration.mirror.simpleName,
    );
  } on ValidationError catch (ex) {
    errors.add(ex);
  } catch (error) {
    if (error.runtimeType.toString() != 'LateError') {
      rethrow;
    }
  }

  // There is no way of determining if a class variable is a list or not through
  // introspection, therefore we try to add the value as a list, or append to the
  // list first. If that fails, we assume it is not a list :-/
  if (isNull(instanceValue)) {
    try {
      instanceValue = (argumentConfiguration.argument as dynamic).emptyList;
      (instanceValue as List).add(value);

      instanceMirror.invokeSetter(
        argumentConfiguration.mirror.simpleName,
        instanceValue,
      );
      argumentConfiguration.confirmSet();
    } on ValidationError catch (ex) {
      errors.add(ex);
    } catch (_) {
      // Adding as a list failed, so it must not be a list. Let's set it
      // as a normal value.
      instanceMirror.invokeSetter(
        argumentConfiguration.mirror.simpleName,
        value,
      );
      argumentConfiguration.confirmSet();
    }
  } else {
    try {
      // Since we can not determine if the instanceValue is a list or not...
      //
      // Just try the .first method to see if it exists. We don't really care
      // about the value, we just want to execute at least two methods on
      // the instance value to do as good of a job as we can to determine if
      // the type is a List or not.
      //
      // .first is the first method, .add will be the second
      var _ = (instanceValue as List).first;
      instanceValue.add(value);
      argumentConfiguration.confirmSet();
    } on ValidationError catch (ex) {
      errors.add(ex);
    } catch (_) {
      if (argumentConfiguration.isSet) {
        errors.add(
          MultipleKeyAssignmentError(argumentConfiguration.displayKey),
        );
      }

      // Adding as a list failed, so it must not be a list. Let's set it
      // as a normal value.
      instanceMirror.invokeSetter(
        argumentConfiguration.mirror.simpleName,
        value,
      );
      argumentConfiguration.confirmSet();
    }
  }
  return errors;
}

String? argumentHelp(MirrorParameterPair mpp) {
  return mpp.argument.help ??
      (mpp.mirror.type.metadata.firstWhereOrNull((m) => m.runtimeType == Parser)
              as Parser?)
          ?.description;
}
