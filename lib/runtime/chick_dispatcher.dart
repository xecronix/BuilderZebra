// 📁 File: runtime/echo_dispatcher.dart

import 'package:builderzebra/abstracts/dispatcher.dart';
import 'package:builderzebra/abstracts/base_truth_binder.dart';
import 'package:builderzebra/runtime/dispatcher_factory.dart';
import 'package:builderzebra/engine/mighty_eagle.dart';
import 'dart:io';

class ChickDispatcher extends Dispatcher {
  ChickDispatcher({
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

    final filePath = 'zebra/chicks/$args.eagle';

    if (!await File(filePath).exists()) {
      throw Exception('Chick not found: $filePath');
    }

    final chickContent = await File(filePath).readAsString();

    final parser = MightyEagleParser(
      template: chickContent,
      context: context,
      dispatcher: dispatcher,
    );

    var retval =  await parser.parse();
    return retval;
  }
}
