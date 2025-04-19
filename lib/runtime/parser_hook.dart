import 'dart:async';
import 'dart:io';

import 'package:builderzebra/engine/char_stream.dart';

abstract class ParserHook {
  Future<void> error({
    required CharStream stream,
    required Exception exception,
  });

  Future<void> message({
    required CharStream stream,
    required String message,
  });

  Future<void> flush({
    IOSink? errorStream,
    IOSink? messageStream
  });
}


