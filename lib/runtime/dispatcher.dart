abstract class Dispatcher {
  Future<String> call({
    required String rule,
    required String template,
    String? args,
    required Map<String, String> context,
});
}
