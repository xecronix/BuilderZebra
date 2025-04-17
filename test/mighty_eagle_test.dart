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
      const template = 'English: {@greeting Hello, {=name:}:}!';
      final context = {'name': 'Ronald'};

      final parser = MightyEagleParser(
        template: template,
        context: context,
        dispatcher: EchoDispatcher());

      final stream = CharStream(r'foo\|bar|');
      final result = await parser.openDispatchArgs(stream: stream);
      expect(result, equals(r'foo\|bar'));
    });
  });
}
