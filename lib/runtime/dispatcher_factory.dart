// 📁 File: runtime/dispatcher_factory.dart

import 'package:builderzebra/abstracts/dispatcher.dart';
import 'package:builderzebra/runtime/if_dispatcher.dart';
import 'package:builderzebra/runtime/each_dispatcher.dart';
import 'package:builderzebra/runtime/truth_dispatcher.dart';
import 'package:builderzebra/runtime/echo_dispatcher.dart';
import 'package:builderzebra/abstracts/base_truth_binder.dart';

class DispatcherFactory {
  const DispatcherFactory({required this.binder});

  final BaseTruthBinder binder;

  Dispatcher? dispatch(String actionRule) {
    switch (actionRule) {
      case 'if':
        return IfDispatcher(
          binder: binder,
          dispatcherFactory: this,
        );
      case 'each':
        return EachDispatcher(
          binder: binder,
          dispatcherFactory: this,
        );
      case 'truth':
       return TruthDispatcher(
          binder: binder,
          dispatcherFactory: this,
       );
       case 'echo':
       return EchoDispatcher(
          binder: binder,
          dispatcherFactory: this,
       );
      default:
        return null;
    }
  }
}
