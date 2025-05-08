import 'dart:io';
import 'package:test/test.dart';

void main() {
  test('All documentation files must be finalized (no FIXME::)', () {
    final docDir = Directory('docs');
    final offendingFiles = <String>[];

    for (var file in docDir.listSync(recursive: true)) {
      if (file is File && file.path.endsWith('.md')) {
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          if (lines[i].contains('FIXME::')) {
            offendingFiles.add('${file.path} (line ${i + 1}): ${lines[i]}');
          }
        }
      }
    }

    if (offendingFiles.isNotEmpty) {
      fail('FIXME:: found in the following documentation files:\n\n' +
           offendingFiles.join('\n'));
    }
  });
}
