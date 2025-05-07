// 📁 File: runtime/endif_dispatcher.dart

import 'package:builderzebra/abstracts/dispatcher.dart';
import 'package:builderzebra/abstracts/base_truth_binder.dart';
import 'package:builderzebra/runtime/dispatcher_factory.dart';

class EndIfDispatcher extends Dispatcher {
  EndIfDispatcher({
    required super.binder,
    required super.dispatcherFactory,
  });

  @override
  Future<String> call({
    required String actionRule,
    required String template, // ignored
    String? args,
    required Map<String, String> context,
  }) async {
    String? result;

    while (true) {
      final entry = binder.stackPop();
      if (entry == null) {
        throw Exception('endif reached with no matching if.');
      }

      final label = entry.keys.first;
      final payload = entry[label];
      if (payload == null) {
        throw Exception('Malformed stack entry under <$label>.');
      }

      final condition = payload['condition'] ?? '';
      final storedContext = payload['context'] ?? <String, String>{};
      final parsed = payload['parsed'] ?? '';

      var isTrue = _evaluate(condition, storedContext);
      if (label == 'else'){
        isTrue = true;
      }

      if (isTrue) {
        result = parsed;
      }

      if (label == 'if') break;
    }

    return result ?? '';
  }

  bool _evaluate(String condition, Map<String, String> context) {
    final parsed = _parseCondition(condition);
    if (parsed == null) return false;

    final field = parsed['field']!;
    final operator = parsed['operator']!;
    final expected = parsed['value']!;
    final actual = context[field] ?? '';

    switch (operator) {
      case '==': return actual == expected;
      case '!=': return actual != expected;
      default: return false;
    }
  }

  Map<String, String>? _parseCondition(String input) {
    final operators = ['==', '!='];
    for (final op in operators) {
      if (input.contains(op)) {
        final parts = input.split(op);
        if (parts.length == 2) {
          return {
            'field': parts[0].trim(),
            'operator': op,
            'value': parts[1].trim().replaceAll('"', ''),
          };
        }
      }
    }
    return null;
  }
}
