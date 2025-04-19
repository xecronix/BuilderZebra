import 'dart:convert';

class CharStream {
  CharStream(this._input);

  final String _input;
  int _index = 0;

  String? get current => _index < _input.length ? _input[_index] : null;

  String? get next => _index + 1 < _input.length ? _input[_index + 1] : null;

  bool get hasMore => _index < _input.length;

  int get offset => _index;

  void advance({int stepCount = 1}) {
    if (stepCount < 0) {
      throw ArgumentError('advance() stepCount must be non-negative');
    }
    _index = (_index + stepCount).clamp(0, _input.length);
  }
  
  void backup({int stepCount = 1}) {
    if (stepCount < 0) {
      throw ArgumentError('backup() stepCount must be non-negative');
    }
    _index = (_index - stepCount).clamp(0, _input.length);
  }

  void rewind() {
    _index = 0;
  }

  int findNext(String str) {
    return _input.indexOf(str, _index);
  }

  int findPrevious(String str) {
    return _input.lastIndexOf(str, _index);
  }

  String? get nextNonWhitespace {
    String? char;
    while (hasMore) {
      char = current;
      if (char != null && char.trim().isNotEmpty) {
        break;
      }
      // The char must be a white space if we're here.
      // And we dont want to return a white space.
      char = null;
      advance();
    }
    return char;
  }

  String previewContext({int radius = 10}) {
    final start = (_index - radius).clamp(0, _input.length);
    final end = (_index + radius).clamp(0, _input.length);
    return _input.substring(start, end);
  }

  bool get isEscaped {
    bool retval = false;
    if (_index > 0 && _input[_index - 1] == '\\') {
      retval = true;
    }
    return retval;
  }
}
