import 'package:test/test.dart';
import 'package:builderzebra/engine/mighty_eagle.dart';
import 'package:builderzebra/runtime/dispatcher_factory.dart';
import 'package:builderzebra/abstracts/base_truth_binder.dart';

// DummyBinder to satisfy DispatcherFactory
class DummyBinder implements BaseTruthBinder {
  /// Pushes a single conditional logic unit onto the stack
  @override
  void stackPush(Map<String, Map<String, dynamic>> value) {}

  /// Pops the most recent entry off the stack (LIFO)
  @override
  Map<String, Map<String, dynamic>>? stackPop() {}

  /// Peeks at the last item in the stack without removing it
  @override
  Map<String, Map<String, dynamic>>? stackPeek() {}

  /// Dumps the full contents of the stack for debugging
  @override
  void stackDump() {}

  @override
  List<String> getAllTruthNames() => [];

  @override
  Future<Map<String, String>> findTruth({required String truthName}) async =>
      {};

  @override
  Future<List<Map<String, String>>> findChildren({
    required String truthName,
    required String childKey,
  }) async => [];
}

void main() {
  group('ContextDispatcher', () {
    final dummyBinder = DummyBinder();
    final dispatcherFactory = DispatcherFactory(binder: dummyBinder);

    test("Ensure the ContextDispatcher is registered", () async {
      final dispatcher = dispatcherFactory.dispatch('context');
      expect(dispatcher, isNotNull);
    });
    
    test('ContextDispatcher prints access paths and values', () async {
      const template = r'{@context:}';
      final context = {
        'foo': 'bar',
        'nested.a': '1',
        'nested.b.c': 'true',
        'items[0].wagon': 'red',
        'items[1].ball': 'round',
      };

      final parser = MightyEagleParser(
        template: template,
        context: context,
        dispatcher: dispatcherFactory.dispatch('context')!,
      );

      final output = await parser.parse();

      expect(output, contains("context['foo'] = bar"));
      expect(output, contains("context['nested.a'] = 1"));
      expect(output, contains("context['nested.b.c'] = true"));
      expect(output, contains("context['items[0].wagon'] = red"));
      expect(output, contains("context['items[1].ball'] = round"));
    });
  });
}
