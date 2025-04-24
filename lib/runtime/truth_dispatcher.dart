import 'package:builderzebra/abstracts/base_truth_binder.dart';
import 'package:builderzebra/abstracts/dispatcher.dart';
import 'package:builderzebra/engine/mighty_eagle.dart';
import 'package:builderzebra/runtime/fields_dispatcher.dart';
class TruthDispatcher implements Dispatcher {
  TruthDispatcher({required this.binder}) {
    _actionDispatchers['fields'] = FieldsDispatcher(binder: binder);
  }
  BaseTruthBinder binder;
  final Map<String, dynamic> _actionDispatchers = <String, dynamic>{};

  @override
  Future<String> call({
    required String actionRule,
    required String template,
    String? args,
    required Map<String, String> context,
  }) async {
    final dispatcher = _actionDispatchers[actionRule];
    return await dispatcher.call(
      actionRule: actionRule,
      template: template,
      args: args,
      context: context,
    );
  }
}
