// 📁 File: abstracts/dispatcher.dart

import 'package:builderzebra/abstracts/base_truth_binder.dart';
import 'package:builderzebra/runtime/dispatcher_factory.dart';

abstract class Dispatcher {
  const Dispatcher({
    required this.binder,
    required this.dispatcherFactory,
  });

  final BaseTruthBinder binder;
  final DispatcherFactory dispatcherFactory;

  Future<String> call({
    required String actionRule,
    required String template,
    String? args,
    required Map<String, String> context,
  });
}
