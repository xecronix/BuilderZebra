import 'package:builderzebra/runtime/mighty_eagle_parser_hook.dart';
import 'package:test/test.dart';
import 'package:builderzebra/engine/mighty_eagle.dart';
import 'package:builderzebra/runtime/echo_dispatcher.dart';
import 'package:builderzebra/engine/mighty_eagle.dart';
import 'package:builderzebra/engine/char_stream.dart';

void main() {
  group('MightyEagleParser', () {
    test('should substitute context variable', () async {
      const template = 'Hello, {=name:}!';
      final context = {'name': 'Ronald'};

      final parser = MightyEagleParser(
        template: template,
        context: context,
        dispatcher: EchoDispatcher(),
      );

      final output = await parser.parse();
      expect(output, equals('Hello, Ronald!'));
    });

    test('Should find unclosed but open tag.', () async {
      const template = 'Hello, {@name Some template with no close}!';
      final context = {'name': 'Ronald'};
      final hook = MightyEagleParserHook();

      final parser = MightyEagleParser(
        template: template,
        context: context,
        dispatcher: EchoDispatcher(),
        parserHook: hook
      );
      await parser.parse();
      final output = hook.aggregateErrors;
      expect(output, contains('[ERROR] Found unclosed tag {@name Some template'));
    });

    test('should substitute context variable', () async {
      const template = 'English: {@greeting Hello, {=name:}:}!';
      final context = {'name': 'Ronald'};

      final parser = MightyEagleParser(
        template: template,
        context: context,
        dispatcher: EchoDispatcher(),
      );

      final output = await parser.parse();
      expect(output, equals('English: Hello, Ronald!'));
    });

    test('escaped pipe is handled in dispatcher args', () async {
      final parser = MightyEagleParser(
        template: '',
        context: {},
        dispatcher: EchoDispatcher());

      final stream = CharStream(r'foo\|bar|');
      final result = await parser.openDispatchArgs(stream: stream);
      expect(result, equals(r'foo\|bar'));
    });

    test('finds the subtemplate in a multiline template ', () async {

      final parser = MightyEagleParser(
        template: '',
        context: {},
        dispatcher: EchoDispatcher());

      final subtemplate = '''The canvas was boogered.  I fixed it back to the 
start of the day.  But I didn't capture the 
{=problem:} for the {@ rule:} substitution tag. :}
''';
      final expectedResults ='''The canvas was boogered.  I fixed it back to the 
start of the day.  But I didn't capture the 
{=problem:} for the {@ rule:} substitution tag. ''';
      final stream = CharStream(subtemplate);
      final result = await parser.openSubtemplate(stream: stream);
      expect(result, equals(expectedResults));
    });

    
  });
}
