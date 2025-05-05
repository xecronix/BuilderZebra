// 📁 File: test/runtime/zebra_truth_binder_v2_test.dart

import 'package:test/test.dart';
import 'package:builderzebra/runtime/zebra_truth_binder.dart';

void main() {
  group('ZebraTruthBinder V2 Tests', () {
    late ZebraTruthBinder binder;

    setUp(() {
      binder = ZebraTruthBinder({
        'journal_entry': {
          'name': 'journal_entry',
          'className': 'JournalEntry',
          'fields': {
            'id': { 'type': 'int', 'system': true },
            'content': { 'type': 'String' },
          }
        },
        'task_entry': {
          'name': 'task_entry',
          'className': 'TaskEntry',
          'fields': [
            { 'name': 'id', 'type': 'int', 'system': true },
            { 'name': 'description', 'type': 'String' },
          ]
        }
      });
    });

    test('findTruth injects __KEY_NAME__ correctly', () async {
      final truth = await binder.findTruth(truthName: 'journal_entry');

      expect(truth.containsKey('__KEY_NAME__'), true);
      expect(truth['__KEY_NAME__'], equals('journal_entry'));
      expect(truth['name'], equals('journal_entry'));
      expect(truth['className'], equals('JournalEntry'));
    });

    test('findChildren handles object-style fields with __KEY_NAME__ injection', () async {
      final children = await binder.findChildren(
        truthName: 'journal_entry',
        childKey: 'fields',
      );

      expect(children.length, 2);
      expect(children.first.containsKey('__KEY_NAME__'), true);
      expect(children.first['__KEY_NAME__'], equals('id'));
      expect(children.first['type'], equals('int'));
    });

    test('findChildren handles array-style fields with name property', () async {
      final children = await binder.findChildren(
        truthName: 'task_entry',
        childKey: 'fields',
      );

      expect(children.length, 2);
      expect(children.first.containsKey('name'), true);
      expect(children.first['name'], equals('id'));
      expect(children.first['type'], equals('int'));
    });

    test('findChildren mixed structure resilience', () async {
      final journalFields = await binder.findChildren(
        truthName: 'journal_entry',
        childKey: 'fields',
      );

      final taskFields = await binder.findChildren(
        truthName: 'task_entry',
        childKey: 'fields',
      );

      expect(journalFields.length, 2);
      expect(taskFields.length, 2);

      expect(journalFields.first.containsKey('__KEY_NAME__'), true);
      expect(taskFields.first.containsKey('name'), true);
    });

    test('findTruth fails gracefully on unknown truth', () async {
      final truth = await binder.findTruth(truthName: 'unknown_entry');

      expect(truth.isEmpty, true);
    });

    test('findChildren fails gracefully on unknown childKey', () async {
      final children = await binder.findChildren(
        truthName: 'journal_entry',
        childKey: 'nonexistent',
      );

      expect(children.isEmpty, true);
    });
  });
}
