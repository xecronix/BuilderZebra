// 📁 File: test/mighty_eagle_parser_test.dart

import 'package:test/test.dart';
import 'package:builderzebra/engine/mighty_eagle.dart';
import 'package:builderzebra/runtime/echo_dispatcher.dart';
import 'package:builderzebra/engine/char_stream.dart';
import 'package:builderzebra/runtime/dispatcher_factory.dart';
import 'package:builderzebra/abstracts/base_truth_binder.dart';
import 'package:builderzebra/runtime/mighty_eagle_parser_hook.dart';

// 🧠 DummyBinder just for tests
// 📁 File: test/dummy_binder.dart (or inline in your test file)

import 'package:builderzebra/abstracts/base_truth_binder.dart';

class DummyBinder implements BaseTruthBinder {
  @override
  List<String> getAllTruthNames() {
    return [];
  }

  @override
  Future<Map<String, String>> findTruth({required String truthName}) async {
    return {};
  }

  @override
  Future<List<Map<String, String>>> findChildren({
    required String truthName,
    required String childKey,
  }) async {
    return [];
  }
}

void main() {
  group('MightyEagleParser', () {
    // 🛠 Shared dummy binder and factory for all tests
    final dummyBinder = DummyBinder();
    final dummyFactory = DispatcherFactory(binder: dummyBinder);

    test('should substitute context variable', () async {
      const template = 'Hello, {=name:}!';
      final context = {'name': 'Ronald'};

      final parser = MightyEagleParser(
        template: template,
        context: context,
        dispatcher: dummyFactory.dispatch('truth')!
      );

      final output = await parser.parse();
      expect(output, equals('Hello, Ronald!'));
    });

    test('should find unclosed but open tag.', () async {
      const template = 'Hello, {@name Some template with no close}!';
      final context = {'name': 'Ronald'};
      final hook = MightyEagleParserHook();

      final parser = MightyEagleParser(
        template: template,
        context: context,
        dispatcher: dummyFactory.dispatch('truth')!,
        parserHook: hook,
      );

      await parser.parse();
      final output = hook.aggregateErrors;
      expect(output, contains('[ERROR] Found unclosed tag {@name Some template'));
    });

    test('should substitute context variable with embedded dispatcher', () async {
      const template = 'English: {@tight Hello, {=name:}!:}';
      final context = {'name': 'Ronald'};

      final parser = MightyEagleParser(
        template: template,
        context: context,
        dispatcher: dummyFactory.dispatch('truth')!
      );

      final output = await parser.parse();
      expect(output, equals('English: Hello, Ronald!'));
    });

    test('escaped pipe is handled in dispatcher args', () async {
      final parser = MightyEagleParser(
        template: '',
        context: {},
        dispatcher: dummyFactory.dispatch('truth')!
      );

      final stream = CharStream(r'foo\|bar|');
      final result = await parser.openDispatchArgs(stream: stream);
      expect(result, equals(r'foo\|bar'));
    });

    test('finds the subtemplate in a multiline template', () async {
      final parser = MightyEagleParser(
        template: '',
        context: {},
        dispatcher: dummyFactory.dispatch('truth')!
      );

      final subtemplate = '''
The canvas was boogered. I fixed it back to the 
start of the day. But I didn't capture the 
{=problem:} for the {@ rule:} substitution tag. :}
''';

      final expectedResults = '''
The canvas was boogered. I fixed it back to the 
start of the day. But I didn't capture the 
{=problem:} for the {@ rule:} substitution tag. ''';

      final stream = CharStream(subtemplate);
      final result = await parser.openSubtemplate(stream: stream);
      expect(result, equals(expectedResults));
    });
  });
}
