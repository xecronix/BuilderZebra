import 'package:builderzebra/abstracts/dispatcher.dart';
import 'package:builderzebra/abstracts/base_truth_binder.dart';
import 'package:builderzebra/engine/mighty_eagle.dart';


class FieldsDispatcher implements Dispatcher {
  FieldsDispatcher({required this.binder});
  BaseTruthBinder binder;

  @override
  Future<String> call({
    required String actionRule,
    required String template,
    String? args,
    required Map<String, String> context,
  }) async {
    StringBuffer retval = StringBuffer();
    final fields = await binder.findFields(truthName: context['name'] ?? '__NULL__');
    for (final field in fields){
      final me = MightyEagleParser(context:field, template:template, dispatcher: this);
      retval.write(await me.parse());
    }
    return retval.toString();
  }
}
