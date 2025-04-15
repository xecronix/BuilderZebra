import 'package:builderzebra/runtime/dispatcher.dart';

class EchoDispatcher implements Dispatcher {
  @override
  Future<String> call(
    String rule,
    String subtemplate,
    List<String> args,
    Map<String, dynamic> context,
  ) async {
    return subtemplate;
  }
}
