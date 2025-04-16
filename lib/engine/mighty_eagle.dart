import 'dart:developer';

import 'package:builderzebra/runtime/dispatcher.dart';

// Parser core inspired by MightyEagle
class MightyEagleParser {
  MightyEagleParser({
    required this.template,
    required this.context,
    required this.dispatcher,
  });
  final String template;
  final Map<String, String> context;
  final Dispatcher dispatcher;

  Future<String> parse() async {
    final output = StringBuffer();
    final stream = _CharStream(template);
    final escapeChar = '\\';
    var state = ParseState.echo;
    var buffer = StringBuffer();
    var tag = StringBuffer();
    var subTemplate = StringBuffer();
    var dispatcherArg = StringBuffer();
    var nestLevel = 0;

    while (stream.hasMore) {
      final char = stream.current;
      final peek = stream.next;

      switch (state) {
        case ParseState.echo:
          if (char == escapeChar) {
            if (peek == '{') {
              state = ParseState.maybeEscapeOpeningTag;
            }
          } else if (char == '{') {
            if (peek == '=' || peek == '@') {
              state = ParseState.tagOpening;
            } else {
              output.write(char);
            }
          } else {
            output.write(char);
          }
          break;
        case ParseState.maybeEscapeOpeningTag:
          output.write('$escapeChar$char');
          state = ParseState.echo;
          break;
        case ParseState.tagOpening:
          if (char == '=') {
            state = ParseState.substitutionTagOpen;
          } else if (char == '@') {
            state = ParseState.actionTagOpen;
          } else {
            throw const FormatException(
              'ParseState.tagOpening Might Eagle ended up in code thought to be unreachable.',
            );
          }
          break;
        case ParseState.substitutionTagOpen:
          if (char == ' ') {
            // Do nothing. Spaces have no meaning in a substitution tag
            // We could end up with weird tags though if someone did this:
            // {= Something With Spaces :}  == SomethingWithSpaces
          } else if (char == ':') {
            if (peek == '}') {
              state = ParseState.substitutionTagClosing;
            } else {
              throw FormatException(
                'ParseState.substitutionTagOpen Expected "}" but got $peek',
              );
            }
          } else {
            tag.write(char);
          }
          break;

        case ParseState.actionTagOpen:
          if (char == ' ' && tag.length == 0) {
            // Do nothing.  We're ignoring leading whitespace
          } else if (tag.length > 0) {
            if (char == ' ') {
              state = ParseState.subTemplate;
              nestLevel = 1;
            } else if (char == '|') {
              state = ParseState.dispatcherArgs;
            } else if (char == ':') {
              if (peek == '}') {
                state = ParseState.actionTagClosing;
              } else {
                throw FormatException(
                  'ParseState.actionTagOpen: Expected } but found $peek',
                );
              }
            } else {
              tag.write(char);
            }
          } else {
            tag.write(char);
          }
          break;
        case ParseState.dispatcherArgs:
          if (char == escapeChar) {
            if (peek == '|') {
              dispatcherArg.write(peek);
              stream.advance();
            } else {
              dispatcherArg.write(char);
            }
          } else if (char == '|') {
            state = ParseState.subTemplate;
            nestLevel = 1;
          } else {
            dispatcherArg.write(char);
          }
          break;

        case ParseState.subTemplate:
          if (char == '{' && (peek == '=' || peek == '@')) {
            nestLevel++;
          } else if (char == ':' && peek == '}') { 
            // Detect closing delimiter for both substitution and action tags
            nestLevel--;
          }
          if (nestLevel == 0) {
            state = ParseState.actionTagClosing;
          } else {
            subTemplate.write(char);
          }
          break;

        case ParseState.substitutionTagClosing:
          output.write(context[tag.toString()] ?? '');
          tag.clear();
          state = ParseState.echo;
          break;
        case ParseState.actionTagClosing:
          output.write(
            await dispatcher.call(
              context: context,
              rule: tag.toString(),
              template: subTemplate.toString(),
              args: dispatcherArg.toString(),
            ),
          );
          subTemplate.clear();
          tag.clear();
          dispatcherArg.clear();
          state = ParseState.echo;
          break;
      }

      stream.advance();
    }

    return output.toString();
  }
}

class _CharStream {
  _CharStream(this._input);

  final String _input;
  int _index = 0;

  String? get current => _index < _input.length ? _input[_index] : null;

  String? get next => _index + 1 < _input.length ? _input[_index + 1] : null;

  bool get hasMore => _index < _input.length;

  void advance() => _index++;
}

enum ParseState {
  echo,
  maybeEscapeOpeningTag,
  tagOpening,
  substitutionTagOpen,
  actionTagOpen,
  substitutionTagClosing,
  actionTagClosing,
  dispatcherArgs,
  subTemplate,
  //maybeEscapeClosingTag,
  //error,
}

