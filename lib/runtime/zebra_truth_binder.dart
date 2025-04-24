// 📁 File: zebra_truth_binder.dart

import 'package:builderzebra/abstracts/base_truth_binder.dart';

class ZebraTruthBinder implements BaseTruthBinder {
  final Map<String, dynamic> _truths;

  ZebraTruthBinder(this._truths);

  @override
  List<String> getAllTruthNames() => _truths.keys.toList();

  @override
  Future<Map<String, String>> findTruth({required String truthName}) async {
    final retval = <String, String>{};
    final truth = _truths[truthName];
    final keys = ['name', 'scope'];
    if (truth != null) {
      for (final key in keys) {
        retval[key] = '${truth[key] ?? ''}';
      }
    }
    return retval;
  }

  @override
  Future<List<Map<String, String>>> findFields({required String truthName}) async {
    final retval = <Map<String, String>>[];
    final truth = _truths[truthName];

    if (truth != null && truth['fields'] is List) {
      final fields = truth['fields'] as List;
      for (final field in fields) {
        if (field is Map) {
          retval.add(_flattenField(field));
        }
      }
    }
    return retval;
  }

  Map<String, String> _flattenField(Map field) {
    final keys = ['name', 'type', 'nullable', 'default'];
    final result = <String, String>{};
    for (final key in keys) {
      result[key] = '${field[key] ?? ''}';
    }
    return result;
  }
}
