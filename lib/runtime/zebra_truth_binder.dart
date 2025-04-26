// 📁 File: runtime/zebra_truth_binder.dart

import 'package:builderzebra/abstracts/base_truth_binder.dart';

class ZebraTruthBinder implements BaseTruthBinder {
  ZebraTruthBinder(this._truths);

  final Map<String, dynamic> _truths;

  @override
  List<String> getAllTruthNames() => _truths.keys
      .where((k) => k != '__meta__')
      .toList();

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

    if (truth != null && truth[childKey] is List) {
      for (final item in truth[childKey]) {
        if (item is Map<String, dynamic>) {
          final flatItem = <String, String>{};
          for (final entry in item.entries) {
            flatItem[entry.key] = '${entry.value ?? ''}';
          }
          result.add(flatItem);
        }
      }
    }

    return result;
  }
}
