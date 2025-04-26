// 📁 File: runtime/each_dispatcher.dart

import 'package:builderzebra/abstracts/dispatcher.dart';
import 'package:builderzebra/abstracts/base_truth_binder.dart';
import 'package:builderzebra/runtime/dispatcher_factory.dart';
import 'package:builderzebra/engine/mighty_eagle.dart';

class EachDispatcher extends Dispatcher {
  EachDispatcher({
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
    final truthName = context['name'];
    if (truthName == null || args == null) return '';

    final buffer = StringBuffer();
    final children = await binder.findChildren(
      truthName: truthName,
      childKey: args,
    );

    for (final child in children) {
      // 🔥 Get a fresh dispatcher for each child context
      final dispatcher = dispatcherFactory.dispatch('truth');
      if (dispatcher == null) {
        throw Exception('DispatcherFactory could not create a "truth" dispatcher.');
      }

      final parser = MightyEagleParser(
        template: template,
        context: child,
        dispatcher: dispatcher,
      );
      buffer.write(await parser.parse());
    }

    return buffer.toString();
  }
}
