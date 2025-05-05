// 📁 File: runtime/echo_dispatcher.dart

import 'package:builderzebra/abstracts/dispatcher.dart';
import 'package:builderzebra/abstracts/base_truth_binder.dart';
import 'package:builderzebra/runtime/dispatcher_factory.dart';
import 'package:builderzebra/engine/mighty_eagle.dart';

class LineDispatcher extends Dispatcher {
  LineDispatcher({
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

    final dispatcher = dispatcherFactory.dispatch('truth');
    if (dispatcher == null) {
      throw Exception('DispatcherFactory could not create a "truth" dispatcher.');
    }

    final parser = MightyEagleParser(
      template: template,
      context: context,
      dispatcher: dispatcher,
    );

    var retval =  await parser.parse();
    retval = retval.replaceAll(RegExp(r'[\r\n]+'), ''); // strip new lines and carriage returns.
    retval = retval.replaceAll(RegExp(r'\s+'), ' ');
    return retval;
  }
}
