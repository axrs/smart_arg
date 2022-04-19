import 'package:smart_arg_fork/smart_arg_fork.dart';

import 'scope_example.reflectable.dart';

@SmartArg.reflectable
@Parser(description: 'Runs the projects unit tests')
class SubCommand3 extends SubCommand1 {
  @StringArgument(help: 'Test Suite to run')
  String? suite;

  @override
  Future<void> execute() async => print('SubCommand3');
}

@SmartArg.reflectable
@Parser(description: 'Runs the projects integration tests')
class SubCommand2 extends SmartArg {
  @Command()
  late SubCommand3 sub3;

  @override
  Future<void> execute() async => print('SubCommand2');
}

@SmartArg.reflectable
@Parser(description: 'Runs the projects benchmark tests')
class SubCommand1 extends SmartArg {
  @Command()
  late SubCommand2 sub2;

  @override
  Future<void> execute() async => print('Subcommand1');
}

@SmartArg.reflectable
@Parser(description: 'A Default Command example')
class RootCommand extends SmartArg {
  @BooleanArgument(help: 'Verbose Output', scope: ScopeType.inherit)
  bool verbose = false;

  @StringArgument(help: 'A String value')
  String? x;

  @StringArgument(help: 'A String value')
  List<String>? y;

  @override
  Future<void> preCommandExecute() async {
    print('Verbose: $verbose');
  }

  @Command()
  late SubCommand1 sub1;

  @Command()
  late SubCommand1 sub1Late = SubCommand3();

  @Command()
  SubCommand1 sub1Eager = SubCommand3();
}

Future<void> main(List<String> arguments) async {
  initializeReflectable();
  var args = RootCommand();
  await args.parse(arguments).run();
}
