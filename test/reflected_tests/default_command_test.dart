import 'package:smart_arg_fork/smart_arg_fork.dart';
import 'package:test/test.dart';

import 'default_command_test.reflectable.dart';

@SmartArg.reflectable
@Parser(
  description: 'Runs the projects unit tests',
  exitOnHelp: false,
)
class UnitTestCommand extends SmartArg {
  @StringArgument(help: 'Test Suite to run')
  String? suite;

  @override
  Future<void> execute() async =>
      SmartArg.output('Running ${suite ?? 'Unit'} Tests');
}

@SmartArg.reflectable
@Parser(
  description: 'Runs the projects integration tests',
  exitOnHelp: false,
)
class IntegrationTestCommand extends SmartArg {
  @BooleanArgument(help: 'Disable database connection')
  bool disableDatabase = false;

  @override
  Future<void> execute() async => SmartArg.output(
        'Running Integration Tests ${disableDatabase ? 'without database' : 'with database'}',
      );
}

@SmartArg.reflectable
@Parser(
  description: 'Runs the projects benchmark tests',
  exitOnHelp: false,
)
class BenchmarkTestCommand extends SmartArg {
  @IntegerArgument(help: 'Times to run')
  int times = 1;

  @override
  Future<void> execute() async =>
      SmartArg.output('Running Benchmark Tests $times times');
}

@SmartArg.reflectable
@Parser(
  description: 'A Default Command example',
  exitOnHelp: false,
)
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

void main() {
  initializeReflectable();

  group('DefaultCommand', () {
    late RootCommand cmd;
    var output = <String>[];

    setUp(() {
      SmartArg.output = (Object? s) {
        if (s is String) {
          output.add(s);
        }
      };
      output = [];
      cmd = RootCommand();
    });

    tearDown(() {
      SmartArg.output = print;
    });

    group('help', () {
      test('shows root level help', () async {
        await cmd.parse(['--help']).run();

        expect(output.first, startsWith('A Default Command example'));
        var fullOutput = output.join('');
        expect(fullOutput, contains('Runs the projects benchmark tests'));
        expect(fullOutput, contains('Runs the projects integration tests'));
        expect(fullOutput, contains('Runs the projects unit tests'));
      });

      test('shows sub-command help', () async {
        await cmd.parse(['integration', '--help']).run();

        expect(output.first, startsWith('Runs the projects integration tests'));
        var fullOutput = output.join('');
        expect(fullOutput, contains('Disable database connection'));
      });
    });

    group('executes the command annotated with @DefaultCommand', () {
      test('without args', () async {
        await cmd.parse([]).run();

        expect(output.first, startsWith('Running Unit Tests'));
      });

      test('forwarding args', () async {
        await cmd.parse(['--suite', 'a-suite']).run();

        expect(output.first, startsWith('Running a-suite Tests'));
      });

      test('with help reverts back to root command help', () async {
        await cmd.parse(['--suite', 'a-suite', '--help']).run();

        expect(output.first, startsWith('A Default Command example'));
      });
    });

    group('allows other command execution still', () {
      group('unit', () {
        test('no args', () async {
          await cmd.parse(['unit']).run();

          expect(output.first, startsWith('Running Unit Tests'));
        });

        test('suite', () async {
          await cmd.parse(['--suite', 'a-suite']).run();

          expect(output.first, startsWith('Running a-suite Tests'));
        });
      });

      group('benchmark', () {
        test('no args', () async {
          await cmd.parse(['benchmark']).run();

          expect(output.first, startsWith('Running Benchmark Tests 1 times'));
        });

        test('suite', () async {
          await cmd.parse(['benchmark', '--times', '8']).run();

          expect(output.first, startsWith('Running Benchmark Tests 8 times'));
        });
      });
    });

    group('commands can be predefined', () {
      test('with pre-defined args', () async {
        await cmd.parse(['defined-benchmark']).run();

        expect(output.first, startsWith('Running Benchmark Tests 10 times'));
      });

      test('override args', () async {
        await cmd.parse(['defined-benchmark', '--times', '200']).run();

        expect(output.first, startsWith('Running Benchmark Tests 200 times'));
      });
    });

    group('commands can be predefined as late', () {
      test('with pre-defined args', () async {
        await cmd.parse(['late-defined-benchmark']).run();

        expect(output.first, startsWith('Running Benchmark Tests 5 times'));
      });

      test('override args', () async {
        await cmd.parse(['late-defined-benchmark', '--times', '100']).run();

        expect(output.first, startsWith('Running Benchmark Tests 100 times'));
      });
    });
  });
}
