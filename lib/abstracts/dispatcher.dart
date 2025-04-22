abstract class Dispatcher {
  Future<String> call({
    required String actionRule,
    required String template,
    String? args,
    required Map<String, String> context,
});
}
