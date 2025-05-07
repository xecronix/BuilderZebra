// 📁 File: runtime/dispatcher_factory.dart
import 'package:builderzebra/abstracts/base_truth_binder.dart';
import 'package:builderzebra/abstracts/dispatcher.dart';
import 'package:builderzebra/runtime/when_dispatcher.dart';
import 'package:builderzebra/runtime/each_dispatcher.dart';
import 'package:builderzebra/runtime/tight_dispatcher.dart';
import 'package:builderzebra/runtime/truth_dispatcher.dart';
import 'package:builderzebra/runtime/echo_dispatcher.dart';
import 'package:builderzebra/runtime/line_dispatcher.dart';
import 'package:builderzebra/runtime/chick_dispatcher.dart';
import 'package:builderzebra/runtime/if_dispatcher.dart';
import 'package:builderzebra/runtime/endif_dispatcher.dart';
import 'package:builderzebra/runtime/elseif_dispatcher.dart';
import 'package:builderzebra/runtime/else_dispatcher.dart';

class DispatcherFactory {
  const DispatcherFactory({required this.binder});

  final BaseTruthBinder binder;

  Dispatcher? dispatch(String actionRule) {
    switch (actionRule) {
      case 'when':
        return WhenDispatcher(binder: binder, dispatcherFactory: this);
      case 'if':
        return IfDispatcher(binder: binder, dispatcherFactory: this);
      case 'elseif':
        return ElseIfDispatcher(binder: binder, dispatcherFactory: this);
      case 'else':
        return ElseDispatcher(binder: binder, dispatcherFactory: this);
      case 'endif':
        return EndIfDispatcher(binder: binder, dispatcherFactory: this);
      case 'line':
        return LineDispatcher(binder: binder, dispatcherFactory: this);
      case 'tight':
        return TightDispatcher(binder: binder, dispatcherFactory: this);
      case 'chick':
        return ChickDispatcher(binder: binder, dispatcherFactory: this);
      case 'each':
        return EachDispatcher(binder: binder, dispatcherFactory: this);
      case 'truth':
        return TruthDispatcher(binder: binder, dispatcherFactory: this);
      case 'echo':
        return EchoDispatcher(binder: binder, dispatcherFactory: this);
      default:
        return null;
    }
  }
}
