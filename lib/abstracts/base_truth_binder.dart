// 📁 File: abstracts/base_truth_binder.dart

abstract class BaseTruthBinder {
  /// Returns a list of all available truths
  List<String> getAllTruthNames();

  /// Returns the flattened scalar fields (name, scope, etc.) of a single truth
  Future<Map<String, String>> findTruth({
    required String truthName,
  });

  /// Returns a list of flattened children under a named collection inside a truth
  Future<List<Map<String, String>>> findChildren({
    required String truthName,
    required String childKey,   // e.g., "fields", "tags"
  });
}
