// 📁 File: runtime/dispatcher_factory.dart

import 'package:builderzebra/abstracts/dispatcher.dart';
import 'package:builderzebra/runtime/if_dispatcher.dart';
import 'package:builderzebra/runtime/each_dispatcher.dart';
import 'package:builderzebra/runtime/tight_dispatcher.dart';
import 'package:builderzebra/runtime/truth_dispatcher.dart';
import 'package:builderzebra/runtime/echo_dispatcher.dart';
import 'package:builderzebra/runtime/if_preserve_space_dispatcher.dart';
import 'package:builderzebra/runtime/each_preserve_space_dispatcher.dart';
import 'package:builderzebra/runtime/line_dispatcher.dart';
import 'package:builderzebra/runtime/chick_dispatcher.dart';
import 'package:builderzebra/abstracts/base_truth_binder.dart';

class DispatcherFactory {
  const DispatcherFactory({required this.binder});

  final BaseTruthBinder binder;

  Dispatcher? dispatch(String actionRule) {
    switch (actionRule) {
      case 'if':
        return IfDispatcher(binder: binder, dispatcherFactory: this);
      case '^if':
        return IfPreserveSpaceDispatcher(binder: binder, dispatcherFactory: this);
      case 'line':
        return LineDispatcher(binder: binder, dispatcherFactory: this);
      case 'tight':
        return TightDispatcher(binder: binder, dispatcherFactory: this);
      case 'chick':
        return ChickDispatcher(binder: binder, dispatcherFactory: this);
      case 'each':
        return EachDispatcher(binder: binder, dispatcherFactory: this);
      case '^each':
        return EachPreserveSpaceDispatcher(binder: binder, dispatcherFactory: this);
      case 'truth':
        return TruthDispatcher(binder: binder, dispatcherFactory: this);
      case 'echo':
        return EchoDispatcher(binder: binder, dispatcherFactory: this);
      default:
        return null;
    }
  }
}
