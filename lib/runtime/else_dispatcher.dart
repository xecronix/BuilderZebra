// 📁 File: runtime/if_dispatcher.dart

import 'package:builderzebra/abstracts/dispatcher.dart';
import 'package:builderzebra/abstracts/base_truth_binder.dart';
import 'package:builderzebra/runtime/dispatcher_factory.dart';
import 'package:builderzebra/engine/mighty_eagle.dart';

class ElseDispatcher extends Dispatcher {
  ElseDispatcher({
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

    final parsedResult = await parser.parse();

    binder.stackPush({
      'else': {
        'condition': '1==1', // always true
        'context': Map<String, String>.from(context),
        'parsed': parsedResult,
      }
    });

    return ''; // no output yet — EndIf will decide which to render
  }

}
