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
  Future<Map<String, String>> findTruth({required String truthName}) async => {};

  @override
  Future<List<Map<String, String>>> findChildren({
    required String truthName,
    required String childKey,
  }) async => [];
}

void main() {
  group('WhenDispatcher', () {
    final dummyBinder = DummyBinder();
    final dispatcherFactory = DispatcherFactory(binder: dummyBinder);

    test('Simple When (true)', () async {
      const template = r'{@when|status==active|Welcome, active user!:}';
      final context = {'status': 'active'};

      final parser = MightyEagleParser(
        template: template,
        context: context,
        dispatcher: dispatcherFactory.dispatch('truth')!,
      );

      final output = await parser.parse();
      expect(output, equals('Welcome, active user!'));
    });

    test('Simple when(false)', () async {
      const template = r'{@when|status==active|Welcome, active user!:}';
      final context = {'status': 'inactive'};

      final parser = MightyEagleParser(
        template: template,
        context: context,
        dispatcher: dispatcherFactory.dispatch('truth')!,
      );

      final output = await parser.parse();
      expect(output, equals(''));
    });

    test('Nested template inside when', () async {
      const template = r'{@when|status==active|Welcome, {=name:}!:}';
      final context = {'status': 'active', 'name': 'Ronald'};

      final parser = MightyEagleParser(
        template: template,
        context: context,
        dispatcher: dispatcherFactory.dispatch('truth')!,
      );

      final output = await parser.parse();
      expect(output, equals('Welcome, Ronald!'));
    });
  });
}
