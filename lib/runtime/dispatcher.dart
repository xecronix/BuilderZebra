abstract class Dispatcher {
  Future<String> call(
    String rule,
    String subtemplate,
    List<String> args,
    Map<String, dynamic> context,
  );
}
