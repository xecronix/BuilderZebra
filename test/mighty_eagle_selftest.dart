import 'package:test/test.dart';
import 'package:builderzebra/engine/mighty_eagle.dart';
import 'package:builderzebra/runtime/dispatcher_factory.dart';
import 'package:builderzebra/abstracts/base_truth_binder.dart';

// DummyBinder specifically for Self-Test
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
  }) async {
    if (truthName == 'ParentTruth' && childKey == 'fields') {
      return [
        {'name': 'email', 'nullable': 'true'},
        {'name': 'id', 'nullable': 'false'},
      ];
    }
    if (truthName == 'SimpleTruth' && childKey == 'fields') {
      return [
        {'name': 'A'},
        {'name': 'B'},
      ];
    }
    return [];
  }
}

void main() {
  group('MightyEagle Self-Test Kit', () {
    final dummyBinder = DummyBinder();
    final dispatcherFactory = DispatcherFactory(binder: dummyBinder);

    test('Field echo', () async {
      const template = r'{=name:}';
      final context = {'name': 'Ronald'};

      final parser = MightyEagleParser(
        template: template,
        context: context,
        dispatcher: dispatcherFactory.dispatch('truth')!,
      );

      final output = await parser.parse();
      expect(output, equals('Ronald'));
    });

    test('Simple IF (true)', () async {
      const template = r'{@if|status==active|OK!:}';
      final context = {'status': 'active'};

      final parser = MightyEagleParser(
        template: template,
        context: context,
        dispatcher: dispatcherFactory.dispatch('truth')!,
      );

      final output = await parser.parse();
      expect(output, equals('OK!'));
    });

    test('IF with ELSE (false branch)', () async {
      const template = r'{@if|status==inactive|Fail!{@else:}Pass!:}';
      final context = {'status': 'active'};

      final parser = MightyEagleParser(
        template: template,
        context: context,
        dispatcher: dispatcherFactory.dispatch('truth')!,
      );

      final output = await parser.parse();
      expect(output, equals('Pass!'));
    });

    test('Simple EACH', () async {
      const template = r'{@each|fields|{=name:}\n:}';
      final context = {'name': 'SimpleTruth'};

      final parser = MightyEagleParser(
        template: template,
        context: context,
        dispatcher: dispatcherFactory.dispatch('truth')!,
      );

      final output = await parser.parse();
      expect(output, equals('A\nB\n'));
    });

    test('IF inside EACH (nullable marker)', () async {
      const template = r'{@each|fields|{=name:}{@if|nullable==true|?:}\n:}';
      final context = {'name': 'ParentTruth'};

      final parser = MightyEagleParser(
        template: template,
        context: context,
        dispatcher: dispatcherFactory.dispatch('truth')!,
      );

      final output = await parser.parse();
      expect(output, equals('email?\nid\n'));
    });
  });
}
