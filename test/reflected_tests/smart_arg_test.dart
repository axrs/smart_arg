import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:smart_arg_fork/smart_arg_fork.dart';
import 'package:smart_arg_fork/src/validation_error.dart';
import 'package:test/test.dart';

import 'smart_arg_test.reflectable.dart';

@SmartArg.reflectable
@Parser(
  exitOnFailure: false,
  description: 'app-description',
  extendedHelp: [
    ExtendedHelp('This is some help', header: 'extended-help'),
    ExtendedHelp('Non-indented help'),
  ],
)
class TestSimple extends SmartArg {
  @BooleanArgument(isNegateable: true, help: 'bvalue-help')
  bool? bvalue;

  @IntegerArgument(short: 'i')
  int? ivalue;

  @DoubleArgument(isRequired: true)
  double? dvalue;

  @StringArgument()
  String? svalue;

  @FileArgument()
  File? fvalue;

  @DirectoryArgument()
  Directory? dirvalue;

  @StringArgument()
  String? checkingCamelToDash;
}

@SmartArg.reflectable
@Parser(exitOnFailure: false)
class TestMultipleShortArgsSameKey extends SmartArg {
  @IntegerArgument(short: 'a')
  int? abc;

  @IntegerArgument(short: 'a')
  int? xyz;
}

@SmartArg.reflectable
@Parser(exitOnFailure: false)
class TestMultipleLongArgsSameKey extends SmartArg {
  @IntegerArgument(long: 'abc')
  int? abc;

  @IntegerArgument(long: 'abc')
  int? xyz;
}

@SmartArg.reflectable
@Parser(exitOnFailure: false, minimumExtras: 1, maximumExtras: 3)
class TestMinimumMaximumExtras extends SmartArg {
  @IntegerArgument()
  int? a;
}

@SmartArg.reflectable
@Parser(exitOnFailure: false)
class TestFileDirectoryMustExist extends SmartArg {
  @FileArgument(mustExist: true)
  late File file;

  @DirectoryArgument(mustExist: true)
  late Directory directory;
}

@SmartArg.reflectable
@Parser(exitOnFailure: false)
class TestShortAndLongSameKey extends SmartArg {
  @IntegerArgument(short: 'a')
  int? abc;

  @IntegerArgument()
  int? a; // This is the same as the short for 'abc'
}

@SmartArg.reflectable
@Parser(exitOnFailure: false)
class TestMultipleLineArgumentHelp extends SmartArg {
  @BooleanArgument(short: 'a', help: 'Silly help message', isRequired: true)
  bool? thisIsAReallyLongParameterNameThatWillCauseWordWrapping;

  @BooleanArgument(short: 'b', help: 'Another help message here')
  bool? moreReasonableName;
}

@SmartArg.reflectable
@Parser(exitOnFailure: false)
class TestLongKeyHandling extends SmartArg {
  @StringArgument(long: 'over-ride-long-item-name')
  String? longItem;

  @StringArgument(long: false, short: 'n')
  String? itemWithNoLong;
}

@SmartArg.reflectable
@Parser(exitOnFailure: false)
class TestMustBeOneOf extends SmartArg {
  @StringArgument(mustBeOneOf: ['hello', 'howdy', 'goodbye', 'cya'])
  String? greeting;
}

@SmartArg.reflectable
@Parser(exitOnFailure: false, strict: true)
class TestParserStrict extends SmartArg {
  @IntegerArgument(short: 'n')
  int? nono;

  @BooleanArgument(long: 'say-hello')
  bool? shouldSayHello;
}

@SmartArg.reflectable
@Parser(exitOnFailure: false)
class TestIntegerDoubleMinMax extends SmartArg {
  @IntegerArgument(minimum: 1, maximum: 5)
  int? intValue;

  @DoubleArgument(minimum: 1.5, maximum: 4.5)
  double? doubleValue;
}

@SmartArg.reflectable
@Parser(exitOnFailure: false)
class TestMultiple extends SmartArg {
  @StringArgument()
  late List<String> names;

  @StringArgument()
  String? name;
}

@SmartArg.reflectable
@Parser(exitOnFailure: false)
class TestHelpArgument extends SmartArg {}

@SmartArg.reflectable
@Parser(exitOnFailure: false)
class TestInvalidShortKeyName extends SmartArg {
  @StringArgument(short: '-n')
  String? name;
}

@SmartArg.reflectable
@Parser(exitOnFailure: false)
class TestInvalidLongKeyName extends SmartArg {
  @StringArgument(long: '-n')
  String? name;
}

@SmartArg.reflectable
@Parser(exitOnFailure: false)
class TestArgumentTerminatorDefault extends SmartArg {
  @StringArgument()
  String? name;

  @StringArgument()
  String? other;
}

@SmartArg.reflectable
@Parser(exitOnFailure: false, argumentTerminator: null)
class TestArgumentTerminatorNull extends SmartArg {
  @StringArgument()
  String? name;

  @StringArgument()
  String? other;
}

@SmartArg.reflectable
@Parser(exitOnFailure: false, argumentTerminator: '--args')
class TestArgumentTerminatorSet extends SmartArg {
  @StringArgument()
  String? name;

  @StringArgument()
  String? other;
}

@SmartArg.reflectable
@Parser(exitOnFailure: false, allowTrailingArguments: false)
class TestDisallowTrailingArguments extends SmartArg {
  @StringArgument()
  String? name;

  @StringArgument()
  String? other;
}

@SmartArg.reflectable
@Parser(exitOnFailure: false)
class TestAllowTrailingArguments extends SmartArg {
  @StringArgument()
  String? name;

  @StringArgument()
  String? other;
}

@SmartArg.reflectable
@Parser(exitOnFailure: false)
class TestStackedBooleanArguments extends SmartArg {
  @BooleanArgument(short: 'a')
  bool avalue = false;

  @BooleanArgument(short: 'b')
  bool bvalue = false;

  @BooleanArgument(short: 'c')
  bool cvalue = false;

  @BooleanArgument(short: 'd')
  bool dvalue = false;
}

@SmartArg.reflectable
@Parser(exitOnFailure: false)
class TestNoKey extends SmartArg {
  @StringArgument(long: false)
  String? long;
}

@SmartArg.reflectable
@Parser(exitOnFailure: false)
class TestWithDefaultValue extends SmartArg {
  @StringArgument()
  String long = 'hello';
}

@SmartArg.reflectable
@Parser(exitOnFailure: false)
class TestWithEnvironmentValue extends SmartArg {
  @StringArgument(environmentVariable: 'TEST_HELLO')
  String long = 'hello';
}

@SmartArg.reflectable
@Parser(exitOnFailure: false)
class TestWithNonAnnotationValue extends SmartArg {
  @StringArgument()
  String long = 'hello';

  final String noAnnotation = 'Not Reflected';
  String eagerProperty = 'Eager';
  late String lateProperty = '$eagerProperty should be late';
}

@SmartArg.reflectable
@Parser(exitOnFailure: false, extendedHelp: [ExtendedHelp(null)])
class TestBadExtendedHelp extends SmartArg {}

@SmartArg.reflectable
@Parser(exitOnFailure: false, description: 'A unit test example')
class TestArgumentGroups extends SmartArg {
  @Group(
    name: 'PERSONALIZATION',
    beforeHelp: 'Before personalization arguments',
    afterHelp: 'After personalization arguments',
  )
  @StringArgument(help: 'Name of person to say hello to')
  String? name;

  @StringArgument(help: 'Greeting to use when greeting the person')
  String? greeting;

  @Group(name: 'CONFIGURATION')
  @IntegerArgument(help: 'How many times do you wish to greet the person?')
  int count = 1;
}

@SmartArg.reflectable
class BaseArg extends SmartArg {
  @IntegerArgument(help: 'A integer value, added via the BaseArg class')
  int? baseValue;
}

@SmartArg.reflectable
//Explicit `class` declaration keyword for tests. `mixin` keyword should be preferred
class StringMixin {
  @StringArgument(help: 'A string value, added via the StringMixin class')
  String? stringValue;
}

@SmartArg.reflectable
mixin DoubleMixin {
  @DoubleArgument(help: 'A double value, added via the DoubleMixin class')
  double? doubleValue;
}

@SmartArg.reflectable
@Parser(exitOnFailure: false)
class ChildExtension extends BaseArg with DoubleMixin, StringMixin {
  @BooleanArgument(help: 'A boolean value, added via the ChildExtension class')
  bool? childValue;
}

String? whatExecuted;

void main() {
  initializeReflectable();

  group('argument parsing/assignment', () {
    test('basic arguments', () {
      var args = TestSimple();

      args.parse([
        '--bvalue',
        '--ivalue',
        '500',
        '--dvalue',
        '12.625',
        '--svalue',
        'hello',
        '--fvalue',
        'hello.txt',
        '--dirvalue',
        '.',
        '--checking-camel-to-dash',
        'yes-it-works',
        'extra1',
        'extra2',
      ]);

      expect(args.bvalue, true);
      expect(args.ivalue, 500);
      expect(args.dvalue, 12.625);
      expect(args.svalue, 'hello');
      expect(args.fvalue is File, true);
      expect(args.dirvalue is Directory, true);
      expect(args.checkingCamelToDash, 'yes-it-works');
      expect(args.extras, ['extra1', 'extra2']);
    });

    test('--no-bvalue', () {
      var args = TestSimple();

      args.parse(['--no-bvalue', '--dvalue=10.0']);

      expect(args.bvalue, isFalse);
    });

    test('short key', () {
      var args = TestSimple();

      args.parse(['-i', '300', '--dvalue=10.0']);

      expect(args.ivalue, 300);
    });

    test('stacked boolean flags', () {
      var args = TestStackedBooleanArguments();

      args.parse(['-ab', '-c']);

      expect(args.avalue, true);
      expect(args.bvalue, true);
      expect(args.cvalue, true);
      expect(args.dvalue, false);
    });

    test('long key with equal', () {
      var args = TestSimple();
      args.parse(['--ivalue=450', '--dvalue=55.5', '--svalue=John']);

      expect(args.ivalue, 450);
      expect(args.dvalue, 55.5);
      expect(args.svalue, 'John');
    });

    group('default value', () {
      test('default value exists if no argument given', () {
        var args = TestWithDefaultValue();

        args.parse([]);

        expect(args.long, 'hello');
      });

      test('value supplied overrides default value', () {
        var args = TestWithDefaultValue();

        args.parse(['--long', 'goodbye']);

        expect(args.long, 'goodbye');
      });
    });

    group('environment value', () {
      var environmentValue = 'Hello from the Environment';
      var environment = <String, String>{'TEST_HELLO': environmentValue};

      test('default value exists if no value found in environment', () {
        var args = TestWithEnvironmentValue()..environment = {};

        args.parse([]);

        expect(args.long, 'hello');
      });

      test('environment variable supplied overrides default value', () {
        var args = TestWithEnvironmentValue()..environment = environment;

        args.parse([]);

        expect(args.long, environmentValue);
      });

      test('value supplied overrides environment value', () {
        var args = TestWithEnvironmentValue()..environment = environment;

        args.parse(['--long', 'goodbye']);

        expect(args.long, 'goodbye');
      });
    });

    group('non-annotated values', () {
      test('can exist within a command', () {
        var args = TestWithNonAnnotationValue();

        args.parse([]);

        expect(args.long, 'hello');
        expect(args.lateProperty, 'Eager should be late');
        expect(args.noAnnotation, 'Not Reflected');
      });

      test('properties can be late for lazy evaluation', () {
        var args = TestWithNonAnnotationValue();

        args.parse([]);

        expect(args.eagerProperty, 'Eager');
        args.eagerProperty = 'Now Late';
        expect(args.lateProperty, 'Now Late should be late');
        args.eagerProperty = 'Back to Eager';
        expect(args.lateProperty, 'Now Late should be late');
      });
    });

    group('list handling', () {
      test('allow', () {
        var args = TestMultiple();

        args.parse(['--names=John', '--names', 'Jack']);

        expect(args.names[0], 'John');
        expect(args.names[1], 'Jack');
      });

      test('disallow but supply multiple', () {
        var args = TestMultiple();

        args.parse(['--name=John', '--name=Jack']);

        expect(args.metadata.errors, [MultipleKeyAssignmentError('name')]);
      });
    });

    test('invalid argument is caught', () {
      var args = TestSimple();

      args.parse(['--dvalue=55.5', '--invalid']);

      expect(args.metadata.errors, []);
    });

    test('not supplying argument', () {
      var args = TestSimple();

      args.parse(['--dvalue']);

      expect(args.metadata.errors, [MissingRequiredValueError('dvalue')]);
    });

    test('missing a required argument throws an error', () {
      var args = TestSimple();

      args.parse([]);

      expect(args.metadata.errors, [MissingRequiredValueError('dvalue')]);
    });

    test('same argument being supplied multiple times', () {
      var args = TestSimple();

      args.parse(['--dvalue=5.5', '--dvalue=5.5']);

      expect(args.metadata.errors, [MultipleKeyAssignmentError('dvalue')]);
    });

    group('must be one of', () {
      test('works', () {
        var args = TestMustBeOneOf();

        args.parse(['--greeting=hello']);

        expect(args.greeting, 'hello');
      });

      test('catches invalid value', () {
        var args = TestMustBeOneOf();

        args.parse(['--greeting=later']);

        expect(args.metadata.errors, []);
      });
    });

    group('integer parameter', () {
      test('works', () {
        var args = TestIntegerDoubleMinMax();

        args.parse(['--int-value=2']);
      });

      test('throws an error when below the range', () {
        var args = TestIntegerDoubleMinMax();

        args.parse(['--int-value=0']);

        expect(args.metadata.errors, []);
      });

      test('throws an error when above the range', () {
        var args = TestIntegerDoubleMinMax();

        args.parse(['--int-value=100']);

        expect(args.metadata.errors, []);
      });
    });

    group('double parameter', () {
      test('works', () {
        var args = TestIntegerDoubleMinMax();

        args.parse(['--double-value=2.5']);

        expect(args.doubleValue, 2.5);
      });

      test('throws an error when below the range', () {
        var args = TestIntegerDoubleMinMax();

        args.parse(['--double-value=1.1']);

        expect(args.metadata.errors, []);
      });

      test('throws an error when above the range', () {
        try {
          var args = TestIntegerDoubleMinMax();

          args.parse(['--double-value=4.6']);

          fail('a double below the maximum did not throw an exception');
        } on ArgumentError {
          expect(1, 1);
        }
      });
    });

    test('not enough extras', () {
      var args = TestMinimumMaximumExtras();

      args.parse([]);

      expect(args.metadata.errors, [NotEnoughExtrasSuppliedError(1, 0)]);
    });

    test('enough extras', () {
      var args = TestMinimumMaximumExtras();

      args.parse(['extra1']);

      expect(args.extras.length, 1);
    });

    test('too many extras', () {
      var args = TestMinimumMaximumExtras();

      args.parse(['extra1', 'extra2', 'extra3', 'extra4']);

      expect(args.metadata.errors, [TooManyExtrasSuppliedError(3, 4)]);
    });

    group('trailing arguments', () {
      test('by default allows', () {
        var args = TestAllowTrailingArguments();

        args.parse(['--name=John', 'hello.txt', '--other=Jack']);

        expect(args.name, 'John');
        expect(args.other, 'Jack');
        expect(args.extras, ['hello.txt']);
      });

      test('when turned off trailing arguments become extras', () {
        var args = TestDisallowTrailingArguments();

        args.parse(['--name=John', 'hello.txt', '--other=Jack']);

        expect(args.name, 'John');
        expect(args.other, null);
        expect(args.extras.length, 2);
        expect(args.extras.contains('hello.txt'), true);
        expect(args.extras.contains('--other=Jack'), true);
      });
    });

    group('file must exist', () {
      test('file that does not exist', () {
        try {
          var args = TestFileDirectoryMustExist();

          args.parse(['--file=.${path.separator}file-that-does-not-exist.txt']);

          fail('file that does not exist did not throw an exception');
        } on ArgumentError {
          expect(1, 1);
        }
      });

      test('file that exists', () {
        var args = TestFileDirectoryMustExist();
        args.parse(['--file=.${path.separator}pubspec.yaml']);
        expect(args.file.path, contains('pubspec.yaml'));
      });
    });

    group('argumentTerminator', () {
      test('default', () {
        var args = TestArgumentTerminatorDefault();

        args.parse(['--name=John', '--', '--other=Jack', 'Doe']);

        expect(args.name, 'John');
        expect(args.other, null);
        expect(args.extras.length, 2);
        expect(args.extras.contains('--other=Jack'), true);
        expect(args.extras.contains('Doe'), true);
      });

      test('set to null but try to use', () {
        var args = TestArgumentTerminatorNull();

        args.parse(['--name=John', '--', '--other=Jack', 'Doe']);

        expect(args.name, 'John');
        expect(args.other, 'Jack');
        expect(args.extras, ['--', 'Doe']);
      });

      test('null terminator without use', () {
        var args = TestArgumentTerminatorDefault();

        args.parse(['--name=John', '--other=Jack', 'Doe']);

        expect(args.name, 'John');
        expect(args.other, 'Jack');
        expect(args.extras.length, 1);
        expect(args.extras.contains('Doe'), true);
      });

      test('set to --args', () {
        var args = TestArgumentTerminatorSet();

        args.parse(['--name=John', '--args', '--other=Jack', 'Doe']);

        expect(args.name, 'John');
        expect(args.other, null);
        expect(args.extras.length, 2);
        expect(args.extras.contains('--other=Jack'), true);
        expect(args.extras.contains('Doe'), true);
      });

      test('set to --args but using mixed case for argument terminator', () {
        var args = TestArgumentTerminatorSet();

        args.parse(['--name=John', '--ArGS', '--other=Jack', 'Doe']);

        expect(args.name, 'John');
        expect(args.other, null);
        expect(args.extras.length, 2);
        expect(args.extras.contains('--other=Jack'), true);
        expect(args.extras.contains('Doe'), true);
      });

      test('set to --args but not used', () {
        var args = TestArgumentTerminatorSet();

        args.parse(['--name=John', '--other=Jack', 'Doe']);

        expect(args.name, 'John');
        expect(args.other, 'Jack');
        expect(args.extras.length, 1);
        expect(args.extras.contains('Doe'), true);
      });
    });

    test('invalid short name parameter', () {
      try {
        var args = TestInvalidShortKeyName();

        args.parse([]).run();

        fail('invalid short name did not throw an exception');
      } on StateError {
        expect(1, 1);
      }
    });

    test('invalid long name parameter', () {
      try {
        var args = TestInvalidLongKeyName();

        args.parse([]).run();

        fail('invalid long name did not throw an exception');
      } on StateError {
        expect(1, 1);
      }
    });

    test('short and long parameters with the same name', () {
      var args = TestShortAndLongSameKey();
      args.parse(['-a=5', '--a=10']).run();
      expect(args.abc, 5);
      expect(args.a, 10);
    });

    group('strict setting on', () {
      test('has no long option when one was not specified', () {
        var args = TestParserStrict();

        args.parse(['--nono=12']);

        expect(args.metadata.errors, []);
      });

      test('short option for non-long option works', () {
        var args = TestParserStrict();

        args.parse(['-n=12']);

        expect(args.nono, 12);
      });

      test('long option added works', () {
        var args = TestParserStrict();

        args.parse(['--say-hello']);

        expect(args.shouldSayHello, true);
      });
    });

    group('long argument override', () {
      test('long item can be overridden', () {
        var args = TestLongKeyHandling();
        expect(args.usage().contains('over-ride-long-item-name'), true);
        expect(args.usage().contains('longItem'), false);
      });

      test('long item does not display', () {
        var args = TestLongKeyHandling();

        args.parse([]).run();

        expect(args.usage().contains('-n'), true);
        expect(args.usage().contains('itemWithNoLong'), false);
        expect(args.usage().contains('item-with-no-long'), false);
      });

      test('some argument must exist', () {
        try {
          var args = TestNoKey();
          args.parse([]);
          fail('no key at all should have thrown an exception');
        } on StateError {
          expect(1, 1);
        }
      });
    });

    group('directory must exist', () {
      test('directory that does not exist', () {
        var args = TestFileDirectoryMustExist();

        args.parse(
          ['--directory=.${path.separator}directory-that-does-not-exist'],
        );

        expect(args.metadata.errors, hasLength(1));
        var err = args.metadata.errors.first as DirectoryMustExistError;
        expect(err.key, 'directory');
        expect(err.value, contains('directory-that-does-not-exist'));
      });

      test('directory that exists', () {
        var args = TestFileDirectoryMustExist();

        args.parse(['--directory=.${path.separator}lib']);

        expect(args.directory.path, contains('lib'));
      });
    });
  });

  group('bad configuration', () {
    test('same short argument multiple times', () {
      var args = TestMultipleShortArgsSameKey();

      args.parse([]);

      expect(args.metadata.errors, [MultipleKeyConfigurationError('-a')]);
    });

    test('same long argument multiple times', () {
      var args = TestMultipleLongArgsSameKey();

      args.parse([]);

      expect(args.metadata.errors, [MultipleKeyConfigurationError('abc')]);
    });
  });

  group('help generation', () {
    test('help contains app description', () {
      var args = TestSimple();
      expect(args.usage(), contains('app-description'));
    });

    test('help contains extended help', () {
      var args = TestSimple();
      var usage = args.usage();

      expect(usage, contains('extended-help'));
      expect(usage, contains('  This is some help'));
      expect(usage, contains('Non-indented help'));
    });

    test('help contains short key for ivalue', () {
      var args = TestSimple();
      expect(args.usage(), contains('-i,'));
    });

    test('help contains long key for ivalue', () {
      var args = TestSimple();
      expect(args.usage(), contains('--ivalue'));
    });

    test('help contains [REQUIRED] for --dvalue', () {
      var args = TestSimple();
      expect(args.usage(), contains('[REQUIRED]'));
    });

    test('help contains must be one of', () {
      var args = TestMustBeOneOf();
      expect(args.usage(), contains('must be one of'));
    });

    test('help contains dashed long key for checkingCamelToDash', () {
      var args = TestSimple();
      expect(args.usage(), contains('--checking-camel-to-dash'));
    });

    test('parameter wrapping', () {
      var args = TestMultipleLineArgumentHelp();
      expect(args.usage(), matches(RegExp(r'.*\n\s+Silly help message')));
      expect(args.usage(), matches(RegExp(r'.*\n\s+\[REQUIRED\]')));
    });

    test('help is off by default', () {
      var args = TestHelpArgument();
      expect(args.help, false);
    });

    test('help works with -?', () {
      var args = TestHelpArgument();
      args.parse(['-?']);
      expect(args.help, true);
    });

    test('help works with -h', () {
      var args = TestHelpArgument();
      args.parse(['-h']);
      expect(args.help, true);
    });

    test('help works with --help', () {
      var args = TestHelpArgument();

      args.parse(['--help']);

      expect(args.help, true);
    });

    test('help ignores parameters after help flag', () {
      var args = TestHelpArgument();

      args.parse(['-?', '--bad-argument1', '-b', 'hello']);

      expect(args.help, true);
      expect(args.extras.contains('--bad-argument1'), true);
      expect(args.extras.contains('-b'), true);
      expect(args.extras.contains('hello'), true);
    });

    test('extended help with null throws an error', () {
      try {
        var args = TestBadExtendedHelp();
        args.usage();

        fail('with no extended help it should have thrown an exception');
      } on StateError {
        expect(1, 1);
      }
    });

    test('grouping works', () {
      var args = TestArgumentGroups();
      var help = args.usage();

      expect(help, contains('PERSONALIZATION'));
      expect(help, contains('  Before personalization arguments'));
      expect(help, contains('  After personalization arguments'));
      expect(help, contains('CONFIGURATION'));
    });
  });

  group('inherited and mixin parsing/assignment', () {
    test('basic arguments', () {
      var args = ChildExtension();

      args.parse([
        '--child-value', //
        '--string-value', 'hello', //
        '--double-value', '222.22', //
        '--base-value', '321', //
      ]);

      expect(args.childValue, true);
      expect(args.stringValue, 'hello');
      expect(args.doubleValue, 222.22);
      expect(args.baseValue, 321);
      expect(args.help, false);
    });

    test('with deeply nested help', () {
      var args = ChildExtension();

      args.parse([
        '--double-value', '222.22', //
        '--base-value', '321', //
        '--help'
      ]);

      expect(args.childValue, null);
      expect(args.doubleValue, 222.22);
      expect(args.baseValue, 321);
      expect(args.help, true);
    });

    test('usage doc', () {
      var args = ChildExtension();
      var help = args.usage();

      expect(
        help,
        contains('A boolean value, added via the ChildExtension class'),
      );
      expect(help, contains('A string value, added via the StringMixin class'));
      expect(help, contains('A double value, added via the DoubleMixin class'));
      expect(help, contains('A integer value, added via the BaseArg class'));
      expect(help, contains('Show help'));
    });
  });
}
