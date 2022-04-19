import 'package:smart_arg_fork/smart_arg_fork.dart';

import 'command_example.reflectable.dart';

@SmartArg.reflectable
@Parser(description: 'get file from remote server')
class GetCommand extends SmartArg {
  @BooleanArgument(help: 'Should the file be removed after downloaded?')
  late bool removeAfterGet = false;

  @override
  Future<void> execute() async {
    print('Getting file...');
    if (removeAfterGet == true) {
      print('Removing file on remote server (not really)');
    }
  }
}

@SmartArg.reflectable
@Parser(description: 'put file onto remote server')
class PutCommand extends SmartArg {
  @BooleanArgument(help: 'Should the file be removed locally after downloaded?')
  late bool removeAfterPut = false;

  @override
  Future<void> execute() async {
    if ((parent as Args).verbose) {
      print('Verbose is on');
    } else {
      print('Verbose is off');
    }

    print('Putting file...');

    if (removeAfterPut == true) {
      print('Removing file on local disk (not really)');
    }
  }
}

@SmartArg.reflectable
@Parser(
  description: 'Example using commands',
  extendedHelp: [
    ExtendedHelp(
      'This is some text below the command listing',
      header: 'EXTENDED HELP',
    )
  ],
  printUsageOnExitFailure: true,
)
class Args extends SmartArg {
  @BooleanArgument(short: 'v', help: 'Verbose mode')
  late bool verbose = false;

  @Command(help: 'Get a file from the remote server')
  late GetCommand get;

  @Command(help: 'Put a file on the remote server')
  late PutCommand put;

// As there is no @DefaultCommand, and we have NOT overridden the
// `Future<void> execute()` method, an `Implementation not defined` error will
// be printed, followed by the usage and the process will exit with code 0
}

Future<void> main(List<String> arguments) async {
  initializeReflectable();
  await Args().parse(arguments).run();
}
