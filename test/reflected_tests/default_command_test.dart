import 'dart:io' as io;

import 'package:mocktail/mocktail.dart';
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
      SmartArg.output.writeln('Running ${suite ?? 'Unit'} Tests');
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
  Future<void> execute() async => SmartArg.output.writeln(
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
      SmartArg.output.writeln('Running Benchmark Tests $times times');
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

class MockStdout extends Mock implements io.Stdout {
  final List<String> written = [];

  @override
  void writeln([Object? object = '']) {
    if (object is String){
      written.add(object);
    }
  }
}

void main() {
  initializeReflectable();

  group('DefaultCommand', () {
    late RootCommand cmd;
    late MockStdout stdout;
    late MockStdout stderr;

    setUp(() {
      stdout = MockStdout();
      stderr = MockStdout();
      SmartArg.output = stdout;
      SmartArg.errorOutput = stderr;
      cmd = RootCommand();
    });

    tearDown(() {
      SmartArg.errorOutput = io.stderr;
      SmartArg.output = io.stdout;
    });

    group('help', () {
      test('shows root level help', () async {
        await cmd.parse(['--help']).run();

        expect(stdout.written.first, startsWith('A Default Command example'));
        var fullOutput = stdout.written.join('');
        expect(fullOutput, contains('Runs the projects benchmark tests'));
        expect(fullOutput, contains('Runs the projects integration tests'));
        expect(fullOutput, contains('Runs the projects unit tests'));
      });

      test('shows sub-command help', () async {
        await cmd.parse(['integration', '--help']).run();

        expect(stdout.written.first, startsWith('Runs the projects integration tests'));
        var fullOutput = stdout.written.join('');
        expect(fullOutput, contains('Disable database connection'));
      });
    });

    group('executes the command annotated with @DefaultCommand', () {
      test('without args', () async {
        await cmd.parse([]).run();

        expect(stdout.written.first, startsWith('Running Unit Tests'));
      });

      test('forwarding args', () async {
        await cmd.parse(['--suite', 'a-suite']).run();

        expect(stdout.written.first, startsWith('Running a-suite Tests'));
      });

      test('with help reverts back to root command help', () async {
        await cmd.parse(['--suite', 'a-suite', '--help']).run();

        expect(stdout.written.first, startsWith('A Default Command example'));
      });
    });

    group('allows other command execution still', () {
      group('unit', () {
        test('no args', () async {
          await cmd.parse(['unit']).run();

          expect(stdout.written.first, startsWith('Running Unit Tests'));
        });

        test('suite', () async {
          await cmd.parse(['--suite', 'a-suite']).run();

          expect(stdout.written.first, startsWith('Running a-suite Tests'));
        });
      });

      group('benchmark', () {
        test('no args', () async {
          await cmd.parse(['benchmark']).run();

          expect(stdout.written.first, startsWith('Running Benchmark Tests 1 times'));
        });

        test('suite', () async {
          await cmd.parse(['benchmark', '--times', '8']).run();

          expect(stdout.written.first, startsWith('Running Benchmark Tests 8 times'));
        });
      });
    });

    group('commands can be predefined', () {
      test('with pre-defined args', () async {
        await cmd.parse(['defined-benchmark']).run();

        expect(stdout.written.first, startsWith('Running Benchmark Tests 10 times'));
      });

      test('override args', () async {
        await cmd.parse(['defined-benchmark', '--times', '200']).run();

        expect(stdout.written.first, startsWith('Running Benchmark Tests 200 times'));
      });
    });

    group('commands can be predefined as late', () {
      test('with pre-defined args', () async {
        await cmd.parse(['late-defined-benchmark']).run();

        expect(stdout.written.first, startsWith('Running Benchmark Tests 5 times'));
      });

      test('override args', () async {
        await cmd.parse(['late-defined-benchmark', '--times', '100']).run();

        expect(stdout.written.first, startsWith('Running Benchmark Tests 100 times'));
      });
    });
  });
}
