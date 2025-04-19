import 'dart:io';

import 'package:builderzebra/engine/char_stream.dart';
import 'package:builderzebra/runtime/parser_hook.dart';
import 'package:builderzebra/runtime/template_parse_exception.dart';

class MightyEagleParserHook implements ParserHook {
  final List<String> _messages = [];
  final List<String> _errorMessages = [];
  @override
  Future<void> error({
    required CharStream stream,
    required Exception exception,
  }) async {
    final offset = stream.offset;

    if (exception is TemplateParseException) {
      _errorMessages.add(
        '[BuilderZebra:${exception.name}] Error at $offset: ${exception.message}',
      );
      if (exception.name == 'openSubtemplate:nestLevel') {
        // Try to find the missing close tag.  we're looking for a missing :}
        var nestLevel = 0;
        while (stream.offset != 0) {
          final char = stream.current;
          // I don't want to call afterChar
          // 'peek' because we're walking backwards.
          final afterChar = stream.next;
          if (char == ':' && afterChar == '}') {
            if (stream.isEscaped == false) {
              nestLevel--;
            }
          } else if (char == '{' && stream.isEscaped == false) {
            if (afterChar == '@' || afterChar == '=') {
              nestLevel++;
              if (nestLevel == 1) {
                // we found our unclosed tag.
                stream.advance(stepCount: 10);
                _errorMessages.add(
                  '[ERROR] Found unclosed tag ${stream.previewContext()}',
                );
                break;
              }
            }
          }
          stream.backup();
        }
      }
    } else {
      _errorMessages.add(
        '[BuilderZebra:internal] Unexpected exception at $offset: $exception',
      );
    }

    _errorMessages.add('\n↪ Context: ...${stream.previewContext()}...');
  }

  @override
  Future<void> message({
    required CharStream stream,
    required String message,
  }) async {
    _messages.add(message);
  }

  @override
  Future<void> report({IOSink? errorStream, IOSink? messageStream}) async {
    final err = errorStream ?? stderr;
    final out = messageStream ?? stdout;

    // this instead
    if (_messages.isNotEmpty) {
      out.writeln(aggregateMessages);
    }

    if (_errorMessages.isNotEmpty) {
      err.writeln(aggregateErrors);
    }
  }

  @override
  Future<void> tattle({IOSink? errorStream, IOSink? messageStream}) =>
      report(errorStream: errorStream, messageStream: messageStream);

  String get aggregateMessages => _messages.join('\n');
  String get aggregateErrors => _errorMessages.join('\n');
  bool get hasMessages => _messages.isNotEmpty;
  bool get hasErrors => _errorMessages.isNotEmpty;
}
