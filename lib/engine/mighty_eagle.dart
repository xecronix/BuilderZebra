import 'dart:async';
import 'dart:developer';

import 'package:builderzebra/abstracts/dispatcher.dart';
import 'package:builderzebra/engine/char_stream.dart';
import 'package:builderzebra/abstracts/parser_hook.dart';
import 'package:builderzebra/runtime/mighty_eagle_parser_hook.dart';
import 'package:builderzebra/runtime/template_parse_exception.dart';

// Parser core inspired by MightyEagle
class MightyEagleParser {
  MightyEagleParser({
    required this.template,
    required this.context,
    required this.dispatcher,
    ParserHook? parserHook,
  }) : parserHook = parserHook ?? MightyEagleParserHook();

  final String template;
  final Map<String, String> context;
  final Dispatcher dispatcher;
  final ParserHook parserHook;
  final escChar = '\\';
  final sus = 'SUSPICIOUS';

  Future<String> parse() async {
    final output = StringBuffer();
    final stream = CharStream(template);
    try {
      output.write(await beginParse(stream: stream));
    } finally {
      await parserHook.tattle();
    }

    return output.toString();
  }

  Future<String> openSubstitutionRule({required CharStream stream}) async {
    final output = StringBuffer();
    final rule = StringBuffer();
    try {
      while (stream.hasMore) {
        final char = stream.current;
        final peek = stream.next;
        if (char == ' ' && rule.isNotEmpty) {
          if (peek == ' ' || peek == ':') {
            // Do nothing.  We ignore spaces before and after rule declarations.
          } else {
            throw TemplateParseException(
              name: 'openSubstitutionRule',
              message:
                  'Substitution rules can only have spaces after rule declarations.',
              offset: stream.offset,
            );
          }
        } else if (char == ':') {
          // the next char should be the closing brace.  If it's not
          // that's a bad template. Also, we should have some rule
          // defined by now.
          if (rule.length == 0) {
            // Is the rule defined?
            throw TemplateParseException(
              name: 'openSubstitutionRule',
              message: 'The : is not a valid rule character.',
              offset: stream.offset,
            );
          }
          if (peek != '}') {
            // Is the template valid?
            throw TemplateParseException(
              name: 'openSubstitutionRule',
              message: 'Expected } but found $peek.',
              offset: stream.offset,
            );
          }
          // we made it past the exceptions.  Let's write some data.
          final ruleData = context[rule.toString()];
          output.write(ruleData ?? '');
          stream.advance(); // move to the closing } brace
          break; // Time to leave the while loop.  We're done in here.
        } else {
          rule.write(char);
        }
        stream.advance();
      }
    } catch (e) {
      if (e is Exception) {
        await parserHook.error(stream: stream, exception: e);
      }
    }
    return output.toString();
  }

  Future<String> openActionRule({required CharStream stream}) async {
    final output = StringBuffer();
    final rule = StringBuffer();
    final dispatcherArgs = StringBuffer();
    final subTemplate = StringBuffer();
    try {
      while (stream.hasMore) {
        final char = stream.current;
        final peek = stream.next;
        if (rule.isNotEmpty) {
          if (char == ' ' || (char != null && char.trim() == '')) {
            // we didn't have any optional args
            // time to get the subtemplate.
            stream.advance();
            subTemplate.write(await openSubtemplate(stream: stream));
            // break from the while loop
            break;
          } else if (char == '|') {
            // time to get the dispatcherArg data
            stream.advance();
            dispatcherArgs.write(await openDispatchArgs(stream: stream));
            // time to get the subtemplate.
            stream.advance();
            subTemplate.write(await openSubtemplate(stream: stream));
            // break from the while loop
            break;
          } else if (char == ':') {
            // this is the case where we have an action rule without a subtemplate
            // the next char should be the closing } brace
            if (peek != '}') {
              throw TemplateParseException(
                name: 'openActionRule',
                message: 'Expected } but found $peek.',
                offset: stream.offset,
              );
            } else {
              stream.advance(); // move to the }
              break;
            }
          } else {
            rule.write(char);
          }
        } else {
          // we're not looking for args or a subtemplate
          // so this charater must be a rule
          if (char != ' ') {
            // this deals with leading spaces like {@ key:}
            rule.write(char);
          }
        }
        stream.advance();
      }

      if (rule.isNotEmpty) {
        output.write(
          await dispatcher.call(
            actionRule: rule.toString(),
            args: dispatcherArgs.toString(),
            template: subTemplate.toString(),
            context: context,
          ),
        );
      }
    } catch (e) {
      if (e is Exception) {
        await parserHook.error(stream: stream, exception: e);
      }
    }

    return output.toString();
  }

  Future<String> openSubtemplate({required CharStream stream}) async {
    final output = StringBuffer();
    var nestLevel = 1;
    try {
      while (stream.hasMore) {
        final char = stream.current;
        final peek = stream.next;
        // lets see if this is an open tag.
        if (char == '{' && (peek == '=' || peek == '@')) {
          // it is an open tag so nestLevel goes up
          if (stream.isEscaped == false) {
            nestLevel++;
          }
          output.write('$char$peek');
          // advance the stream since we just dealt with the next char (aka peek)
          stream.advance();
        } else if (char == ':' && peek == '}') {
          // this is a closing tag.  So there is extra consideration here.
          if (stream.isEscaped == false) {
            nestLevel--;
          }
          if (nestLevel == 0) {
            // We found the closing tag that caused us to be in
            // this method in the first place.  We don't really
            // want to write it to the sub template.  so, we'll
            // advace the stream and get out of the while loop.
            stream.advance(); // move to the }
            break;
          } else {
            // This is a closing tag, but not the one we're looking
            // for.  It's part of the subtemplate. Write it to
            // and advance the stream since we're dealing with the
            // peek character now.
            output.write('$char$peek');
            stream.advance();
          }
        } else {
          // Just regular old template data
          output.write(char);
        }
        // if we had found the closing tag we would have bailed on this
        // loop.  Since we're here, we must not have found it yet. Advance
        // the stream and keep looking.
        stream.advance();
      }

      if (nestLevel != 0) {
        throw TemplateParseException(
          name: 'openSubtemplate:nestLevel',
          message: 'Looked for a subtemplate but didn\'t find matching :}',
          offset: stream.offset,
        );
      }
    } catch (e) {
      if (e is Exception) {
        await parserHook.error(stream: stream, exception: e);
      }
    }

    return output.toString();
  }

  Future<String> openDispatchArgs({required CharStream stream}) async {
    final output = StringBuffer();
    final previewText = stream.previewContext();

    while (stream.hasMore) {
      final char = stream.current;
      final peek = stream.next;
      if (char == escChar && peek == '|') {
        output.write('$char$peek');
        stream.advance(); // advance to the | since we've dealt with it.
      } else if (char == '|') {
        break;
      } else if (char == ':' && peek == '}') {
        throw FormatException(
          'Unexpected end of dispatcher args near `$previewText` — likely malformed '
          'tag. Full context: ${stream.previewContext()}'
        );

      } else {
        output.write(char);
      }
      stream.advance();
    }
    return output.toString();
  }

  Future<String> beginParse({required CharStream stream}) async {
    final output = StringBuffer();
    while (stream.hasMore) {
      final char = stream.current;
      final peek = stream.next;
      if (char == escChar && peek == '{') {
        // looks like we're trying to escape an opening tag.
        output.write('$escChar$peek');
        stream.advance();
      } else if (char == '{' && (peek == '=' || peek == '@')) {
        // a rule is opening. Let's figure out which type
        // and send it to the method to handle it.
        stream.advance(); // move the stream to the type identifier.
        if (stream.current == '=') {
          stream.advance(); // move the stream past the type identifier.
          output.write(await openSubstitutionRule(stream: stream));
        } else {
          stream.advance(); // move the stream past the type identifier.
          output.write(await openActionRule(stream: stream));
        }
      } else {
        output.write(char);
      }
      stream.advance();
    }
    return output.toString();
  }
}