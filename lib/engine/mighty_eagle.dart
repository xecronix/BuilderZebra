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
    var state = ParseState.echo;
    var tagType = TagType.none;
    var retval = StringBuffer();
    var buffer = StringBuffer();
    var tag = StringBuffer();

    for (int i = 0; i < template.length; i++) {
      final char = template[i];
      switch (state) {
        case ParseState.echo:
          if (char == '\\') {
            state = ParseState.maybeEscapeOpeningTag;
            buffer = StringBuffer(char);
          } else if (char == '{') {
            state = ParseState.tagOpening;
            buffer.clear();
            buffer.write(char);
          } else {
            retval.write(char);
          }
          break;
        case ParseState.maybeEscapeOpeningTag:
          if (char == '{') {
            buffer.write(char);
          } else if (buffer.length == 2 && (char == '@' || char == '=')) {
            buffer.clear();
            retval.write('{' + char);
            state = ParseState.echo;
          } else {
            buffer.write(char);
            retval.write(buffer);
            buffer.clear();
            state = ParseState.echo;
          }
          break;
        case ParseState.tagOpening:
          if (char == '=') {
            state = ParseState.tagOpen;
            buffer.clear();
            tagType = TagType.substitute;
          } else if (char == '@') {
            state = ParseState.tagOpen;
            buffer.clear();
            tagType = TagType.action;
          } else {
            retval.write(buffer);
            retval.write(char);
            buffer.clear();
          }
          break;
        case ParseState.tagOpen:
          if (tagType == TagType.substitute) {
            if (char == ' ') {
              // nothing to do.  Ignore.
            } else if (char == ':') {
              state = ParseState.tagClosing;
            } else {
              tag.write(char);
            }
          }
          else{
            // todo: TagType.action logic
          }
          break;
        case ParseState.tagClosing:
          if (tagType == TagType.substitute) {
            if (char == '}') {
              retval.write(context[tag.toString()] ?? '');
              state =  ParseState.echo;
              tag.clear();
            }
          }
          else{
            // todo write what to do when closing an action tag.
          }
          break;
      }
    }
    return retval.toString();
  }
}

enum ParseState {
  echo,
  maybeEscapeOpeningTag,
  tagOpening,
  tagOpen,
  //tagArgs,
  //tagSubtemplate,
  //maybeEscapeClosingTag,
  tagClosing,
  //error,
}

enum TagType { none, substitute, action }
