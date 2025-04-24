// 📁 File: base_truth_binder.dart

abstract class BaseTruthBinder {
  List<String> getAllTruthNames();

  Future<Map<String, String>> findTruth({required String truthName});

  Future<List<Map<String, String>>> findFields({required String truthName});
}