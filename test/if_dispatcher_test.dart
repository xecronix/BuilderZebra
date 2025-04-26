import 'package:test/test.dart';
import 'package:builderzebra/engine/mighty_eagle.dart';
import 'package:builderzebra/runtime/dispatcher_factory.dart';
import 'package:builderzebra/abstracts/base_truth_binder.dart';

// DummyBinder to satisfy DispatcherFactory
class DummyBinder implements BaseTruthBinder {
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
  group('IfDispatcher', () {
    final dummyBinder = DummyBinder();
    final dispatcherFactory = DispatcherFactory(binder: dummyBinder);

    test('Simple IF (true, no else)', () async {
      const template = r'{@if|status==active|Welcome, active user!:}';
      final context = {'status': 'active'};

      final parser = MightyEagleParser(
        template: template,
        context: context,
        dispatcher: dispatcherFactory.dispatch('truth')!,
      );

      final output = await parser.parse();
      expect(output, equals('Welcome, active user!'));
    });

    test('Simple IF (false, no else)', () async {
      const template = r'{@if|status==active|Welcome, active user!:}';
      final context = {'status': 'inactive'};

      final parser = MightyEagleParser(
        template: template,
        context: context,
        dispatcher: dispatcherFactory.dispatch('truth')!,
      );

      final output = await parser.parse();
      expect(output, equals(''));
    });

    test('IF with ELSE (true branch)', () async {
      const template = r'{@if|status==active|Welcome, active user!{@else:}Please activate your account.:}';
      final context = {'status': 'active'};

      final parser = MightyEagleParser(
        template: template,
        context: context,
        dispatcher: dispatcherFactory.dispatch('truth')!,
      );

      final output = await parser.parse();
      expect(output, equals('Welcome, active user!'));
    });

    test('IF with ELSE (false branch)', () async {
      const template = r'{@if|status==active|Welcome, active user!{@else:}Please activate your account.:}';
      final context = {'status': 'inactive'};

      final parser = MightyEagleParser(
        template: template,
        context: context,
        dispatcher: dispatcherFactory.dispatch('truth')!,
      );

      final output = await parser.parse();
      expect(output, equals('Please activate your account.'));
    });

    test('Nested template inside IF', () async {
      const template = r'{@if|status==active|Welcome, {=name:}!:}';
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
