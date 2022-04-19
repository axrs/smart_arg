import 'package:smart_arg_fork/smart_arg_fork.dart';

import 'readme_example.reflectable.dart';

@SmartArg.reflectable
@Parser(description: 'Hello World application')
class Args extends SmartArg {
  @StringArgument(
    help: 'Name of person to say hello to',
    //Environment Variable will be used if defined and not otherwise specified
    environmentVariable: 'GREETING_NAME',
  )
  String name = 'World'; // Default to World

  @StringArgument(
    help: 'Message to say to person',
    mustBeOneOf: ['Hello', 'Goodbye'],
    environmentVariable: 'GREETING_TYPE',
  )
  String greeting = 'Hello'; // Default to Hello

  @IntegerArgument(
    help: 'Number of times to greet the person',
    isRequired: true,
    minimum: 1,
    maximum: 100,
    environmentVariable: 'GREETING_COUNT',
  )
  late int count;
}

Future<void> main(List<String> arguments) async {
  initializeReflectable();
  var args = Args();
  await args.parse(arguments).run();
  for (var i = 0; i < args.count; i++) {
    print('${args.greeting}, ${args.name}!');
  }
}
