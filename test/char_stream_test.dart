// File: test/char_stream_test.dart

import 'package:test/test.dart';
import 'package:builderzebra/engine/char_stream.dart';

void main() {
  group('CharStream', () {
    test('advance() moves index forward by 1', () {
      final stream = CharStream('abc');
      stream.advance();
      expect(stream.offset, equals(1));
      expect(stream.current, equals('b'));
    });

    test('advance(n) moves index forward by n', () {
      final stream = CharStream('abcdef');
      stream.advance(stepCount: 3);
      expect(stream.offset, equals(3));
      expect(stream.current, equals('d'));
    });

    test('backup() resets to 0', () {
      final stream = CharStream('xyz');
      stream.advance(stepCount: 2);
      stream.backup(stepCount: 2);
      expect(stream.offset, equals(0));
      expect(stream.current, equals('x'));
    });

    test('rewind() moves index back to beginning', () {
      final stream = CharStream('123456');
      stream.advance(stepCount: 5);
      stream.rewind();
      expect(stream.offset, equals(0));
    });

    test('backup() moves index back by 1 if > 0', () {
      final stream = CharStream('hello');
      stream.advance();
      stream.backup();
      expect(stream.offset, equals(0));
    });

    test('backup() does nothing if index is 0', () {
      final stream = CharStream('abc');
      stream.backup();
      expect(stream.offset, equals(0));
    });

    test('findNext() finds correct forward match', () {
      final stream = CharStream('abc def ghi');
      final index = stream.findNext('def');
      expect(index, equals(4));
    });

    test('findPrevious() finds correct backward match', () {
      final stream = CharStream('one two one');
      stream.advance(stepCount: 10);
      final index = stream.findPrevious('one');
      expect(index, equals(8));
    });

    test('nextNonWhitespace returns first non-space char', () {
      final stream = CharStream('   \t\nx');
      final char = stream.nextNonWhitespace;
      expect(char, equals('x'));
      expect(stream.current, equals('x')); // Stream should be positioned at 'x'
    });

    test('current and next getters return expected characters', () {
      final stream = CharStream('yo');
      expect(stream.current, equals('y'));
      expect(stream.next, equals('o'));
    });

    test('previewContext returns surrounding text', () {
      final stream = CharStream('abcdefghijklmnopqrstuvwxyz');
      stream.advance(stepCount: 10); // 'k'
      final context = stream.previewContext(radius: 3);
      expect(context, contains('hij'));
      expect(context, contains('klm'));
      expect(context, hasLength(6));
    });

    test('isEscaped returns true when char is preceded by \\', () {
      final stream = CharStream(r'abc\{def');
      stream.advance(stepCount: 4); // lands on '{'
      expect(stream.current, equals('{'));
      expect(stream.isEscaped, isTrue);
    });
  });
}
