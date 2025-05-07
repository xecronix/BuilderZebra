import 'package:test/test.dart';
import 'package:builderzebra/engine/mighty_eagle.dart';
import 'package:builderzebra/runtime/dispatcher_factory.dart';
import 'package:builderzebra/abstracts/base_truth_binder.dart';
import 'package:builderzebra/runtime/zebra_truth_binder.dart';

void main() {
  group('tight_dispatcher_escape', () {
    late Map<String, String> context;
    final dummyBinder = ZebraTruthBinder(Map<String, String>());
    final dispatcherFactory = DispatcherFactory(binder: dummyBinder);

    setUp(() {
      context = <String, String>{};
    });

    test('renders escaped syntax as literal text', () async {
      final template = '{@echo {@chick|some_chick|:}:}';

      final parser = MightyEagleParser(
        template: template,
        context: context,
        dispatcher: dispatcherFactory.dispatch('truth')!,
      );

      final output = await parser.parse();

      final expected = '''{@chick|some_chick|:}''';

      expect(output.trim(), equals(expected.trim()));
    });
  });
}
