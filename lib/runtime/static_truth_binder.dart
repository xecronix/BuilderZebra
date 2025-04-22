import 'package:builderzebra/abstracts/base_truth_binder.dart';

class StaticTruthBinder implements BaseTruthBinder {
  final _truths = {
    'Person': {
      'name': 'Person',
      'scope': 'private',
      'fields': [
        {'name': 'firstName', 'type': 'String', 'nullable': false},
        {'name': 'age', 'type': 'int', 'nullable': true},
      ],
    },
    'Address': {
      'name': 'Address',
      'scope': 'private',
      'fields': [
        {'name': 'street', 'type': 'String', 'nullable': false},
      ],
    },
      'Education': {
      'name': 'Education',
      'scope': 'public',
      'fields': [
        {'name': 'street', 'type': 'String', 'nullable': false},
      ],
    },
  };
  
  List<String> getAllTruthNames() => _truths.keys.toList();
  
  Future<Map<String, String>> findTruth({required String truthName}) async {
    final retval = <String, String>{};
    final truth = _truths[truthName];
    final keys = ['name', 'scope'];
    if (truth != null) {
      for (int i = 0; i < keys.length; i++) {
        retval[keys[i]] = '${truth[keys[i]] ?? ''}';
      }
    }
    return retval;
  }

  Future<List<Map<String, String>>> findFields({
    required String truthName,
  }) async {
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
