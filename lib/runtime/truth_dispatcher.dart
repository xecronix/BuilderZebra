// 📁 File: runtime/truth_dispatcher.dart

import 'package:builderzebra/abstracts/dispatcher.dart';
import 'package:builderzebra/abstracts/base_truth_binder.dart';
import 'package:builderzebra/runtime/dispatcher_factory.dart';

class TruthDispatcher extends Dispatcher {
  TruthDispatcher({
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
    final dispatcher = dispatcherFactory.dispatch(actionRule);
    if (dispatcher == null) {
      throw Exception('Unknown action: $actionRule');
    }

    return await dispatcher.call(
      actionRule: actionRule,
      template: template,
      args: args,
      context: context,
    );
  }
}
