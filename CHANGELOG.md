## 3.0.1

- Fix:
  - Invocation order of `before*` and `after*` command lifecycle callbacks
 
## 3.0.0

- Breaking:
  - Converted `SmartArg.parse` and `SmartArgCommand.execute` to be async

## 2.4.0

- Added:
  - Support for using extended classes of `SmartArg` to be added as `@Command`s to other `SmartArg` classes.

## 2.3.0

- Added:
    - Support for parsing and validating `@EnumArgument`s

## 2.2.0

- Added:
    - Help text for `Command`s can be specified as either `@Command(help: '')` or within the implementations `@Parser(description: '')`.

## 2.1.1

- Fixed:
    - Changed Help output to:
        - Use a maximum of 80 columns
        - Keep a consistent Command/Argument column width of 25 (introducing a linebreak on overflow)
        - Sort commands by displayKey
- Style:
    - Updated linting rules to help enforce more consitency

## 2.1.0

- Added:
    - Support for SmartArg Argument inheritance defined in super classes or via mixins
    - Support for SubCommands, including before/after command callback invocation
    - Nullable `parent` property to `SmartArg` and `SmartArgCommand` instances

## 2.0.0

- Breaking:
    - Upgraded for Null Type Safety. Requires minimum Dart version `2.12.0`
    - Upgraded reflectable to `3.0.4`
- Added:
    - Extra methods to `SmartArg` for handling lifecycle operations. Useful for DI instantiation
        - `beforeCommandParse`
        - `beforeCommandExecute`
        - `afterCommandExecute`
    - Support for reading arguments from Environment Variables if not provided during parsing
- Fixed:
    - Linter warnings
    - Allow properties of classes extending `SmartArg` to not require an `Argument` annotation
- Miscellaneous:
    - Upgraded dev_dependencies
        - test to `^1.18.2`
        - build_runner to `^2.1.4`
        - build_test to `^2.1.4`
    - Replaced pandantic with lints `^1.0.1`

## 1.1.2

- Updated dependencies pedantic, test, path, build_runner, build_test and reflectable
- Fixed new linting errors "unnecessary_brace_in_string_interps"

## 1.1.1

- Fixed linting errors from dartanalyzer
- Updated reflectable to 2.2.1

## 1.1.0

- Moved from dart:mirrors to source generation using reflectable

## 1.0.0+1

- Updated description in pubspec.yaml due to pub.dev Maintenance suggestions.

## 1.0.0

- Initial version
