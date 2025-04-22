import 'package:builderzebra/abstracts/dispatcher.dart';
import 'package:builderzebra/engine/mighty_eagle.dart';

class EchoDispatcher implements Dispatcher {
  @override
  Future<String> call({
    required String actionRule,
    required String template,
    String? args,
    required Map<String, String> context,
  }) async {
    final me = MightyEagleParser(context:context, template:template, dispatcher: this);
    return await me.parse();
  }
}
