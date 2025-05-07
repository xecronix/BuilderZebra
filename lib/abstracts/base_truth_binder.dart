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

  // -----------------------------------------------------
  // Stack Support for Conditional Dispatchers
  // -----------------------------------------------------

  /// Pushes a single conditional logic unit onto the stack
  void stackPush(Map<String, Map<String, dynamic>> value) ;

  /// Pops the most recent entry off the stack (LIFO)
  Map<String, Map<String, dynamic>>? stackPop() ;

  /// Peeks at the last item in the stack without removing it
  Map<String, Map<String, dynamic>>? stackPeek() ;

  /// Dumps the full contents of the stack for debugging
  void stackDump() ;
}
