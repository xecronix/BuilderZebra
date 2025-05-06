// 📁 File: runtime/each_dispatcher.dart

import 'package:builderzebra/abstracts/dispatcher.dart';
import 'package:builderzebra/abstracts/base_truth_binder.dart';
import 'package:builderzebra/runtime/dispatcher_factory.dart';
import 'package:builderzebra/engine/mighty_eagle.dart';

class EachDispatcher extends Dispatcher {
  EachDispatcher({required super.binder, required super.dispatcherFactory});

  @override
  Future<String> call({
    required String actionRule,
    required String template,
    String? args,
    required Map<String, String> context,
  }) async {
    final truthName = context['name'];
    if (truthName == null || args == null) return '';

    // Parse collection key and filter conditions from args
    final (collection, filters) = _parseArgs(args);
    final buffer = StringBuffer();

    final children = await binder.findChildren(
      truthName: truthName,
      childKey: collection,
    );

    // Apply filters if any exist
    final filteredChildren =
        filters.isEmpty
            ? children
            : children.where((child) => _passesAnyFilter(child, filters));

    var i = 0;
    for (final child in filteredChildren) {
      final dispatcher = dispatcherFactory.dispatch('truth');
      if (dispatcher == null) {
        throw Exception(
          'DispatcherFactory could not create a "truth" dispatcher.',
        );
      }

      child['each.index'] = i.toString();
      child['each.listNumber'] = (i + 1).toString(); // 1-based number (for display)
      child['each.first'] = (i == 0).toString();
      child['each.last'] = (i == filteredChildren.length - 1).toString();
      i++;

      final parser = MightyEagleParser(
        template: template,
        context: child,
        dispatcher: dispatcher,
      );

      final data = await parser.parse();
      if (data.trim().isNotEmpty) {
        buffer.write(data);
      }
    }
    final data = buffer.toString();
    return data.trimRight();
  }

  // === 🔧 FILTERING LOGIC STARTS HERE ===

  /// Splits args into a collection key and a list of filter conditions
  (String collection, List<FilterCondition> filters) _parseArgs(String args) {
    final parts = args.split(':');
    final collection = parts[0].trim();

    final filters =
        parts.length > 1
            ? parts.sublist(1).map((raw) {
              final condition = _parseCondition(raw.trim());
              if (condition != null) return condition;
              throw Exception('Invalid filter condition: $raw');
            }).toList()
            : <FilterCondition>[];

    return (collection, filters);
  }

  /// Parses strings like `isKey==true` or `type!="DateTime"`
  FilterCondition? _parseCondition(String input) {
    final operators = ['==', '!='];
    for (final op in operators) {
      if (input.contains(op)) {
        final parts = input.split(op);
        if (parts.length == 2) {
          final field = parts[0].trim();
          final value = parts[1].trim().replaceAll('"', '');
          return FilterCondition(field, op, value);
        }
      }
    }
    return null;
  }

  /// Returns true if any filter matches the field map
  bool _passesAnyFilter(
    Map<String, dynamic> field,
    List<FilterCondition> filters,
  ) {
    for (final filter in filters) {
      final value = field[filter.field]?.toString() ?? '';
      final match = switch (filter.operator) {
        '==' => value == filter.value,
        '!=' => value != filter.value,
        _ => false,
      };

      if (match) return true;
    }
    return false;
  }
}

/// Represents a single filter like `field == value`
class FilterCondition {
  final String field;
  final String operator; // '==' or '!='
  final String value;

  FilterCondition(this.field, this.operator, this.value);
}
