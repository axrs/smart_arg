// ignore_for_file: deprecated_member_use_from_same_package

import 'package:smart_arg_fork/smart_arg_fork.dart';
import 'package:test/test.dart';

import 'command_parsing_test.reflectable.dart';

String? whatExecuted;

@SmartArg.reflectable
@Parser(exitOnFailure: false, description: 'put command')
class PutCommand extends SmartArg {
  @StringArgument()
  String? filename;

  @override
  Future<void> execute() async {
    whatExecuted = 'put-command: $filename';
  }
}

@SmartArg.reflectable
@Parser(exitOnFailure: false, description: 'Get a file from a remote host')
class GetCommand extends SmartArg {
  @StringArgument()
  String? filename;

  @override
  Future<void> execute() async {
    whatExecuted = 'get-command: $filename';
  }
}

@SmartArg.reflectable
@Parser(exitOnFailure: false)
class TestSimpleCommand extends SmartArg {
  @BooleanArgument(short: 'v')
  bool? verbose;

  @Command(help: 'Put a file on a remote host')
  PutCommand? put;

  @Command()
  GetCommand? get;

  List<String> hookOrder = [];

  @override
  Future<void> preCommandExecute() async {
    hookOrder.add('preCommandExecute');
  }

  @override
  Future<void> postCommandExecute() async {
    hookOrder.add('postCommandExecute');
  }
}

List<String> subcommandHookOrder = [];

@SmartArg.reflectable
@Parser(exitOnFailure: false, description: 'The Child Command')
class ChildCommand extends SmartArg {
  @StringArgument()
  String? aValue;

  @Command()
  late ChildCommand child;

  @override
  Future<void> execute() async {
    whatExecuted = 'ChildCommand: $aValue';
    subcommandHookOrder.add('ChildExecute');
  }

  @override
  Future<void> preCommandExecute() async {
    subcommandHookOrder.add('preChildCommandExecute');
  }

  @override
  Future<void> postCommandExecute() async {
    subcommandHookOrder.add('postChildCommandExecute');
  }
}

@SmartArg.reflectable
@Parser(exitOnFailure: false, description: 'The Father Command')
class FatherCommand extends SmartArg {
  @StringArgument()
  String? aValue;

  @Command()
  late ChildCommand child;

  @override
  Future<void> execute() async {
    whatExecuted = 'FatherCommand: $aValue';
    subcommandHookOrder.add('FatherExecute');
  }

  @override
  Future<void> preCommandExecute() async {
    subcommandHookOrder.add('preFatherCommandExecute');
  }

  @override
  Future<void> postCommandExecute() async {
    subcommandHookOrder.add('postFatherCommandExecute');
  }
}

@SmartArg.reflectable
@Parser(exitOnFailure: false, description: 'The Parent Command')
class GrandFatherCommand extends SmartArg {
  @Command()
  late ChildCommand child;

  @Command()
  late FatherCommand father;

  @StringArgument()
  String? aValue;

  @Command()
  late GrandFatherCommand grandFather;

  @override
  Future<void> preCommandExecute() async {
    subcommandHookOrder.add('preGrandFatherCommandExecute');
  }

  @override
  Future<void> postCommandExecute() async {
    subcommandHookOrder.add('postGrandFatherCommandExecute');
  }
}

void main() {
  initializeReflectable();

  group('parsing', () {
    group('commands', () {
      setUp(() {
        whatExecuted = null;
      });

      test('calls hooks', () async {
        var cmd = TestSimpleCommand();
        await cmd.parse(['get', '--filename=download.txt']).run();
        expect(cmd.verbose, null);
        expect(whatExecuted, 'get-command: download.txt');
        expect(cmd.hookOrder, [
          'preCommandExecute',
          'postCommandExecute'
        ]);
      });

      test('executes with no arguments', () async {
        var args = TestSimpleCommand();
        await args.parse([]).run();
        expect(args.verbose, null);
      });

      test('executes with a command', () async {
        var args = TestSimpleCommand();
        await args.parse(['-v', 'put', '--filename=upload.txt']).run();
        expect(args.verbose, true);
        expect(whatExecuted, 'put-command: upload.txt');
      });

      test('executes with another command', () async {
        var args = TestSimpleCommand();
        await args.parse(['-v', 'get', '--filename=download.txt']).run();
        expect(args.verbose, true);
        expect(whatExecuted, 'get-command: download.txt');
      });

      test('help appears', () {
        var args = TestSimpleCommand();
        var help = args.usage();

        expect(help.contains('COMMANDS'), true);
        expect(help.contains('  get'), true);
        expect(help.contains('  put'), true);
        expect(help.contains('Get a file'), true); //From Parser description
        expect(help.contains('Put a file'), true); //From Command.Help
      });
    });

    group('subcommands', () {
      setUp(() {
        whatExecuted = null;
        subcommandHookOrder = [];
      });

      test('First Subcommand', () async {
        await GrandFatherCommand().parse(['father', '--a-value=beta']).run();
        expect(whatExecuted, 'FatherCommand: beta');
        expect(subcommandHookOrder, [
          'preGrandFatherCommandExecute',
          'preFatherCommandExecute',
          'FatherExecute',
          'postFatherCommandExecute',
          'postGrandFatherCommandExecute'
        ]);
      });

      test('Second subcommand', () async {
        await GrandFatherCommand()
            .parse(['father', 'child', '--a-value=charlie']).run();
        expect(whatExecuted, 'ChildCommand: charlie');
        expect(subcommandHookOrder, [
          'preGrandFatherCommandExecute',
          'preFatherCommandExecute',
          'preChildCommandExecute',
          'ChildExecute',
          'postChildCommandExecute',
          'postFatherCommandExecute',
          'postGrandFatherCommandExecute'
        ]);
      });

      test('Triply Nested subcommand', () async {
        await GrandFatherCommand()
            .parse(['father', 'child', 'child', '--a-value=delta']).run();
        expect(whatExecuted, 'ChildCommand: delta');
        expect(subcommandHookOrder, [
          'preGrandFatherCommandExecute',
          'preFatherCommandExecute',
          'preChildCommandExecute',
          'preChildCommandExecute',
          'ChildExecute',
          'postChildCommandExecute',
          'postChildCommandExecute',
          'postFatherCommandExecute',
          'postGrandFatherCommandExecute',
        ]);
      });

      test('Arguments beyond commands are executed as the last known command',
          () async {
        await GrandFatherCommand().parse(['father', 'child']).run();
        expect(whatExecuted, 'ChildCommand: null');
        expect(subcommandHookOrder, [
          'preGrandFatherCommandExecute',
          'preFatherCommandExecute',
          'preChildCommandExecute',
          'ChildExecute',
          'postChildCommandExecute',
          'postFatherCommandExecute',
          'postGrandFatherCommandExecute'
        ]);
      });

      test('Nested SmartArg as Command', () async {
        await GrandFatherCommand()
            .parse(['grand-father', 'father', '--a-value=beta']).run();
        expect(whatExecuted, 'FatherCommand: beta');
        expect(subcommandHookOrder, [
          'preGrandFatherCommandExecute',
          'preGrandFatherCommandExecute',
          'preFatherCommandExecute',
          'FatherExecute',
          'postFatherCommandExecute',
          'postGrandFatherCommandExecute',
          'postGrandFatherCommandExecute'
        ]);
      });
    });
  });
}
