import 'package:smart_arg_fork/smart_arg_fork.dart';

import 'default_command_example.reflectable.dart';

@SmartArg.reflectable
@Parser(description: 'Runs the projects unit tests')
class UnitTestCommand extends SmartArg {
  @StringArgument(help: 'Test Suite to run')
  String? suite;

  @override
  Future<void> execute() async => print('Running ${suite ?? 'Unit'} Tests');
}

@SmartArg.reflectable
@Parser(description: 'Runs the projects integration tests')
class IntegrationTestCommand extends SmartArg {
  @BooleanArgument(help: 'Disable database connection')
  bool disableDatabase = false;

  @override
  Future<void> execute() async => print(
        'Running Integration Tests ${disableDatabase ? 'without database' : 'with database'}',
      );
}

@SmartArg.reflectable
@Parser(description: 'Runs the projects benchmark tests')
class BenchmarkTestCommand extends SmartArg {
  @IntegerArgument(help: 'Times to run')
  int times = 1;

  @override
  Future<void> execute() async => print('Running Benchmark Tests $times times');
}

@SmartArg.reflectable
@Parser(description: 'A Default Command example')
class RootCommand extends SmartArg {
  @DefaultCommand()
  late UnitTestCommand unit;

  @Command()
  late IntegrationTestCommand integration;

  @Command()
  late BenchmarkTestCommand benchmark;

  @Command()
  late BenchmarkTestCommand lateDefinedBenchmark = BenchmarkTestCommand()
    ..times = 5;

  @Command()
  BenchmarkTestCommand definedBenchmark = BenchmarkTestCommand()..times = 10;
}

Future<void> main(List<String> arguments) async {
  initializeReflectable();
  await RootCommand().parse(arguments).run();
}
