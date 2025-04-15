import 'package:test/test.dart';
import 'package:builderzebra/engine/mighty_eagle.dart';
import 'package:builderzebra/runtime/echo_dispatcher.dart';

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
  });
}
