import 'package:test/test.dart';
import 'package:builderzebra/engine/mighty_eagle.dart';
import 'package:builderzebra/runtime/dispatcher_factory.dart';
import 'package:builderzebra/runtime/zebra_truth_binder.dart';


void main() {
  group('line_dispatcher', () {
    late Map<String, String> context;
    final dummyBinder = ZebraTruthBinder(Map<String, String>());
    final dispatcherFactory = DispatcherFactory(binder: dummyBinder);

    setUp(() {
      context = <String, String>{};
    });

    test('removes newlines and carriage returns', () async {
      final template = '''{@line
This


is a add a EOL    space here --> 
test.
:}''';

      final parser = MightyEagleParser(
        template: template,
        context: context,
        dispatcher: dispatcherFactory.dispatch('truth')!,
      );

      final output = await parser.parse();
      expect(output, equals('Thisis a add a EOL space here --> test.'));
    });

    test('handles empty input', () async {
      final template = '''{@line




:}''';

      final parser = MightyEagleParser(
        template: template,
        context: context,
        dispatcher: dispatcherFactory.dispatch('truth')!,
      );

      final output = await parser.parse();
      expect(output, equals(''));
    });
  });
}
