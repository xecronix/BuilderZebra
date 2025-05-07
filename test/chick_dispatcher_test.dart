import 'dart:io';
import 'package:test/test.dart';
import 'package:builderzebra/engine/mighty_eagle.dart';
import 'package:builderzebra/runtime/dispatcher_factory.dart';
import 'package:builderzebra/abstracts/base_truth_binder.dart';
import 'package:builderzebra/runtime/zebra_truth_binder.dart';


void main() {
  group('chick_dispatcher', () {
    const chickName = 'test';
    const chickPath = 'zebra/chicks/$chickName.eagle';
    const chickContent = 'Hello from the test chick!';

    late Map<String, String> context;
    final dummyBinder = ZebraTruthBinder(Map<String, String>());
    final dispatcherFactory = DispatcherFactory(binder: dummyBinder);

    setUp(() async {
      context = <String, String>{};

      // Ensure the chick file exists
      final file = File(chickPath);
      await file.create(recursive: true);
      await file.writeAsString(chickContent);
    });

    tearDown(() async {
      final file = File(chickPath);
      if (await file.exists()) {
        await file.delete();
      }
    });

    test('loads and renders a chick', () async {
      final template = '''{@chick|$chickName|:}''';

      final parser = MightyEagleParser(
        template: template,
        context: context,
        dispatcher: dispatcherFactory.dispatch('truth')!,
      );

      final output = await parser.parse();
      expect(output.trim(), equals(chickContent));
    });
  });
}
