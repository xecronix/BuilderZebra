class TemplateParseException implements Exception {

  TemplateParseException({
    required this.name,
    required this.message,
    this.offset,
  });
  final String name;     // e.g. 'substitution', 'nesting', 'args'
  final String message;
  final int? offset;

  @override
  String toString() =>
      offset != null ? '$name error at $offset: $message' : '$name error: $message';
}
