import 'package:test/test.dart';
import 'package:builderzebra/engine/mighty_eagle.dart';
import 'package:builderzebra/runtime/dispatcher_factory.dart';
import 'package:builderzebra/abstracts/base_truth_binder.dart';

// DummyBinder specifically for EachDispatcher tests
class DummyBinderForEach implements BaseTruthBinder {
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
  Future<Map<String, String>> findTruth({required String truthName}) async => {};

  @override
  Future<List<Map<String, String>>> findChildren({
    required String truthName,
    required String childKey,
  }) async {
    // Pretend that we have two children under the given truth
    return [
      {'name': 'Alpha'},
      {'name': 'Beta'},
    ];
  }
}

void main() {
  group('EachDispatcher', () {
    final dummyBinder = DummyBinderForEach();
    final dispatcherFactory = DispatcherFactory(binder: dummyBinder);

    test('loops over children and expands template', () async {
      const template = r'{@each|fields|Name: {=name:}\n:}';
      final context = {
        'name': 'ParentTruth', // Needed to have 'name' available for findChildren()
      };

      final parser = MightyEagleParser(
        template: template,
        context: context,
        dispatcher: dispatcherFactory.dispatch('truth')!,
      );

      final output = await parser.parse();

      // Expect it to have expanded once per child
      expect(
        output,
        equals(r'Name: Alpha\nName: Beta\n'),
      );
    });
  });
}
