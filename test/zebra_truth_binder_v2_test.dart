// 📁 File: test/zebra_truth_binder_v2_test.dart

import 'package:test/test.dart';
import 'package:builderzebra/runtime/zebra_truth_binder.dart';

void main() {
  group('ZebraTruthBinder V2 - Hydration and Object Field Tests', () {
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
        }
      });
    });

    test('findTruth injects __KEY_NAME__ dynamically', () async {
      final truth = await binder.findTruth(truthName: 'journal_entry');

      expect(truth.containsKey('__KEY_NAME__'), true,
          reason: 'findTruth must inject __KEY_NAME__');
      expect(truth['__KEY_NAME__'], equals('journal_entry'));
      expect(truth['name'], equals('journal_entry'));
      expect(truth['className'], equals('JournalEntry'));
    });

    test('findChildren correctly hydrates fields from object map', () async {
      final children = await binder.findChildren(
        truthName: 'journal_entry',
        childKey: 'fields',
      );

      expect(children.length, 2, reason: 'Should find 2 fields');

      final idField = children.firstWhere((field) => field['__KEY_NAME__'] == 'id', orElse: () => {});
      final contentField = children.firstWhere((field) => field['__KEY_NAME__'] == 'content', orElse: () => {});

      expect(idField.isNotEmpty, true, reason: 'id field must be found');
      expect(contentField.isNotEmpty, true, reason: 'content field must be found');

      expect(idField['type'], equals('int'));
      expect(contentField['type'], equals('String'));
    });
  });
}
