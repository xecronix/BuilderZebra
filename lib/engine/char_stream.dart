class CharStream {
  CharStream(this._input);

  final String _input;
  int _index = 0;

  String? get current => _index < _input.length ? _input[_index] : null;

  String? get next => _index + 1 < _input.length ? _input[_index + 1] : null;

  bool get hasMore => _index < _input.length;

  void advance() => _index++;
}