import 'package:equatable/equatable.dart';

abstract class ValidationError extends Equatable implements Exception {
  String get message;

  @override
  String toString() => message;
}

abstract class ArgumentConfigurationError extends ValidationError {}
