import 'package:smart_arg_fork/smart_arg_fork.dart';

import 'advanced_command_example.reflectable.dart';

/// A basic mixin for adding a Docker Image argument to each [SmartArg] extension
@SmartArg.reflectable
mixin DockerImageArg {
  @StringArgument(help: 'Docker Image')
  String? image = 'dart:stable';
}

@SmartArg.reflectable
@Parser(description: 'Pulls a Docker Image')
class DockerPullCommand extends SmartArgCommand with DockerImageArg {
  @override
  Future<void> execute(SmartArg parentArguments) async {
    print('\$ docker pull $image');
  }
}

@SmartArg.reflectable
@Parser(description: 'Runs a Docker Image')
class DockerRunCommand extends SmartArgCommand with DockerImageArg {
  @BooleanArgument(help: 'Pull image before running')
  bool pull = false;

  @override
  Future<void> execute(SmartArg parentArguments) async {
    print('\$ docker run${pull ? ' --pull' : ''} $image');
  }
}

enum Status { running, stopped, all }

@SmartArg.reflectable
@Parser(description: 'Lists Docker Images')
class DockerListCommand extends SmartArgCommand with DockerImageArg {
  @EnumArgument<Status>(
    help: 'Docker Image Status',
    values: Status.values,
  )
  late Status status = Status.all;

  @override
  Future<void> execute(SmartArg parentArguments) async {
    print('\$ docker ps --status $status');
  }
}

@SmartArg.reflectable
@Parser(
  description: 'Example of using mixins to reduce argument declarations',
)
class Args extends SmartArg {
  @BooleanArgument(short: 'v', help: 'Verbose mode')
  bool? verbose;

  @Command()
  DockerPullCommand? pull;

  @Command()
  DockerRunCommand? run;

  @Command()
  DockerListCommand? list;
}

void main(List<String> arguments) async {
  initializeReflectable();
  var args = Args();
  await args.parse(arguments);
}
