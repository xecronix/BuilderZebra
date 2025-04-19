// File: validator_zebra.dart
// Usage: dart validator_zebra.dart -f path/to/file.eagle

import 'dart:io';
import 'package:builderzebra/engine/mighty_eagle.dart';
import 'package:builderzebra/runtime/mighty_eagle_parser_hook.dart';
import 'package:builderzebra/runtime/dispatcher.dart';
import 'package:builderzebra/runtime/echo_dispatcher.dart';

void printUsage() {
  print('Zebra Template Validator – ${DateTime.now().year}');
  print('Usage: dart validator_zebra.dart [options]');
  print('Options:');
  print('  -f <file>         Validate a single .eagle template');
  print('  -d <directory>    Validate all .eagle files in directory');
  print('  -o <file>         Write output to this file (overwrites)');
  print('  -O <file>         Also print to stdout/stderr in addition to output file');
  print('  -h                Show this help menu');
}

Future<void> validateFile(File file, {IOSink? output}) async {
  final hook = MightyEagleParserHook();
  final template = await file.readAsString();

  final parser = MightyEagleParser(
    template: template,
    context: {}, // No substitutions
    dispatcher: EchoDispatcher(), // Do nothing dispatcher
    parserHook: hook,
  );

  await parser.parse();
  await hook.tattle(
    errorStream: output ?? stderr,
    messageStream: output ?? stdout,
  );
}

Future<void> main(List<String> args) async {
  String? filePath;
  String? directoryPath;
  String? outputPath;
  bool alsoWriteToConsole = false;

  for (int i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '-f':
        filePath = args[++i];
        break;
      case '-d':
        directoryPath = args[++i];
        break;
      case '-o':
        outputPath = args[++i];
        break;
      case '-O':
        outputPath = args[++i];
        alsoWriteToConsole = true;
        break;
      case '-h':
        printUsage();
        return;
    }
  }

  final outputFile = (outputPath != null) ? File(outputPath).openWrite() : null;

  if (filePath != null) {
    final file = File(filePath);
    if (!await file.exists()) {
      stderr.writeln('Error: File not found: $filePath');
      exit(1);
    }
    await validateFile(file, output: outputFile);
  } else if (directoryPath != null) {
    final dir = Directory(directoryPath);
    if (!await dir.exists()) {
      stderr.writeln('Error: Directory not found: $directoryPath');
      exit(1);
    }

    final eagleFiles = dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.eagle'));

    for (final file in eagleFiles) {
      stdout.writeln('\n🦅 Validating ${file.path}');
      await validateFile(file, output: alsoWriteToConsole ? null : outputFile);
    }
  } else {
    printUsage();
    exit(1);
  }

  await outputFile?.flush();
  await outputFile?.close();
}
