// File: zebra_make.dart
// Usage: dart run zebra_make.dart OR ./zebra_make.exe
// To build zebra_make:
//  dart compile exe zebra_make.dart -o zebra_make.exe

import 'dart:io';

Future<void> main() async {
  // 🧱 Files to compile
  final filesToCompile = [
    'zebra_validate.dart',
    'zebra_linter.dart',
    'zebra_scaffold.dart',
   ];

  final dartExecutable = await findDartExecutable();
  final resolvedDartPath = Platform.isWindows
      ? '$dartExecutable.bat'
      : dartExecutable;

  for (final file in filesToCompile) {
    final parts = file.split('.');
    if (parts.length < 2 || parts.last != 'dart') {
      print('❌ Skipping invalid Dart file: $file');
      continue;
    }

    final baseName = parts.first;
    final outputPath = '${baseName}.exe';

    print('⚙️ Compiling $file → $outputPath ...');

    final result = await Process.run(
      resolvedDartPath,
      ['compile', 'exe', file, '-o', outputPath],
    );

    if (result.exitCode == 0) {
      print('✅ Successfully compiled: $outputPath');
    } else {
      print('❌ Failed to compile $file:\n${result.stderr}');
    }
  }
}

Future<String> findDartExecutable() async {
  try {
    final result = await Process.run(
      Platform.isWindows ? 'where' : 'which',
      ['dart'],
    );

    if (result.exitCode == 0) {
      final path = (result.stdout as String).split('\n').first.trim();
      if (await File(path).exists()) {
        return path;
      }
    }
  } catch (_) {
    // Fall back to default
  }

  print('⚠️ Warning: Could not locate full dart path, using fallback "dart"');
  return 'dart';
}
