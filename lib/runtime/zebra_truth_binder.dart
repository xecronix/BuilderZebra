// 📁 File: runtime/zebra_truth_binder.dart

import 'package:builderzebra/abstracts/base_truth_binder.dart';

class ZebraTruthBinder implements BaseTruthBinder {
  ZebraTruthBinder(this._truths);

  final Map<String, dynamic> _truths;

  @override
  List<String> getAllTruthNames() =>
      _truths.keys.where((k) => k != '__meta__').toList();

  @override
  Future<Map<String, String>> findTruth({required String truthName}) async {
    final truth = _truths[truthName];
    final result = <String, String>{};

    if (truth != null && truth is Map<String, dynamic>) {
      for (final entry in truth.entries) {
        if (entry.value is! List && entry.value is! Map) {
          result[entry.key] = '${entry.value ?? ''}';
        }
      }
      // Inject __KEY_NAME__ if needed
      result['__KEY_NAME__'] = truthName;
    }

    return result;
  }

  @override
  Future<List<Map<String, String>>> findChildren({
    required String truthName,
    required String childKey,
  }) async {
    final result = <Map<String, String>>[];
    final truth = _truths[truthName];

    if (truth != null && truth[childKey] != null) {
      final child = truth[childKey];

      if (child is List) {
        // Existing behavior: list of objects
        for (final item in child) {
          if (item is Map<String, dynamic>) {
            final flatItem = <String, String>{};
            for (final entry in item.entries) {
              flatItem[entry.key] = '${entry.value ?? ''}';
            }
            result.add(flatItem);
          }
        }
      } else if (child is Map<String, dynamic>) {
        // NEW behavior: object of objects
        for (final entry in child.entries) {
          if (entry.value is Map<String, dynamic>) {
            final flatItem = <String, String>{'__KEY_NAME__': entry.key};
            for (final field in entry.value.entries) {
              flatItem[field.key] = '${field.value ?? ''}';
            }
            result.add(flatItem);
          }
        }
      }
    }

    return result;
  }

  // -----------------------------------------------------
  // Stack Support for Conditional Dispatchers
  // -----------------------------------------------------

  final List<Map<String, Map<String, dynamic>>> _logicStack = [];

  /// Pushes a single conditional logic unit onto the stack
  @override 
  void stackPush(Map<String, Map<String, dynamic>> value) {
    _logicStack.add(value);
  }

  /// Pops the most recent entry off the stack (LIFO)
  @override
  Map<String, Map<String, dynamic>>? stackPop() {
    if (_logicStack.isEmpty) return null;
    return _logicStack.removeLast();
  }

  /// Peeks at the last item in the stack without removing it
  @override
  Map<String, Map<String, dynamic>>? stackPeek() {
    if (_logicStack.isEmpty) return null;
    return _logicStack.last;
  }

  /// Dumps the full contents of the stack for debugging
  @override
  void stackDump() {
    if (_logicStack.isEmpty) {
      print('[BZ Stack] (empty)');
    } else {
      print('[BZ Stack] ${_logicStack.length} entries:');
      for (var i = 0; i < _logicStack.length; i++) {
        final entry = _logicStack[i];
        final label = entry.keys.first;
        final content = entry[label];
        print('  [$i] <$label>: $content');
      }
    }
  }
}
