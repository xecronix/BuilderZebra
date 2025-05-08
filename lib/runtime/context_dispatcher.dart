// 📁 File: runtime/context_dispatcher.dart

import 'package:builderzebra/abstracts/dispatcher.dart';
import 'package:builderzebra/abstracts/base_truth_binder.dart';
import 'package:builderzebra/runtime/dispatcher_factory.dart';
import 'package:builderzebra/engine/mighty_eagle.dart';

class ContextDispatcher extends Dispatcher {
  ContextDispatcher({required super.binder, required super.dispatcherFactory});

  @override
  Future<String> call({
    required String actionRule,
    required String template,
    String? args,
    required Map<String, String> context,
  }) async {
    final buffer = StringBuffer();

    void visit(String prefix, dynamic value) {
      if (value is Map) {
        for (final entry in value.entries) {
          final key = entry.key.toString();
          final newPath = "$prefix['$key']";
          visit(newPath, entry.value);
        }
      } else if (value is List) {
        for (var i = 0; i < value.length; i++) {
          final newPath = "$prefix[$i]";
          visit(newPath, value[i]);
        }
      } else {
        buffer.writeln('$prefix = $value');
      }
    }

    for (final entry in context.entries) {
      visit("context['${entry.key}']", entry.value);
    }

    return buffer.toString();
  }
}
