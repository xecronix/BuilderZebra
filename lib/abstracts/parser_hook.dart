import 'dart:async';
import 'dart:io';

import 'package:builderzebra/engine/char_stream.dart';

abstract class ParserHook {
  ParserHook({IOSink? defaultMessageOutStream, IOSink? defaultErrorOutStream})
  : defaultErrorOutStream=defaultErrorOutStream ?? stderr,
  defaultMessageOutStream=defaultMessageOutStream ?? stdout;

  final IOSink? defaultMessageOutStream;
  final IOSink? defaultErrorOutStream;
  
  Future<void> error({
    required CharStream stream,
    required Exception exception,
  });

  Future<void> message({required CharStream stream, required String message});

  Future<void> report({IOSink? errorStream, IOSink? messageStream});
  Future<void> tattle({IOSink? errorStream, IOSink? messageStream}) =>
      report(errorStream: errorStream, messageStream: messageStream);
}
