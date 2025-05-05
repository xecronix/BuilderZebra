// 📁 File: runtime/if_dispatcher.dart

import 'package:builderzebra/abstracts/dispatcher.dart';
import 'package:builderzebra/abstracts/base_truth_binder.dart';
import 'package:builderzebra/runtime/dispatcher_factory.dart';
import 'package:builderzebra/engine/mighty_eagle.dart';

class IfPreserveSpaceDispatcher extends Dispatcher {
  IfPreserveSpaceDispatcher({
    required super.binder,
    required super.dispatcherFactory,
  });

  @override
  Future<String> call({
    required String actionRule,
    required String template,
    String? args,
    required Map<String, String> context,
  }) async {
    final condition = args?.trim();
    if (condition == null || condition.isEmpty) {
      return '';
    }

    final parsed = _parseCondition(condition);
    if (parsed == null) {
      return '';
    }

    final variable = parsed['field']!;
    final operator = parsed['operator']!;
    final expectedValue = parsed['value']!;

    final actualValue = context[variable] ?? '';

    bool conditionMet = false;
    switch (operator) {
      case '==':
        conditionMet = actualValue == expectedValue;
        break;
      case '!=':
        conditionMet = actualValue != expectedValue;
        break;
      default:
        return '';
    }

    final parts = template.split(RegExp(r'\{\@else\:\}'));

    final selectedTemplate = (conditionMet ? parts.first : (parts.length > 1 ? parts[1] : ''));

    if (selectedTemplate.isEmpty) {
      return '';
    }

    final dispatcher = dispatcherFactory.dispatch('truth');
    if (dispatcher == null) {
      throw Exception('DispatcherFactory could not create a "truth" dispatcher.');
    }

    final parser = MightyEagleParser(
      template: selectedTemplate,
      context: context,
      dispatcher: dispatcher,
    );

    return await parser.parse();
  }

  Map<String, String>? _parseCondition(String input) {
    final operators = ['==', '!='];
    for (final op in operators) {
      if (input.contains(op)) {
        final parts = input.split(op);
        if (parts.length == 2) {
          final field = parts[0].trim(); // 🚀 NO $ CHECK ANYMORE
          final value = parts[1].trim().replaceAll('"', '');
          return {
            'field': field,
            'operator': op,
            'value': value,
          };
        }
      }
    }
    return null;
  }
}
