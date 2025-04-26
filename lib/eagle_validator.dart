// File: validator_zebra.dart
// Usage: dart validator_zebra.dart -f path/to/file.eagle

import 'dart:io';
import 'package:builderzebra/engine/mighty_eagle.dart';
import 'package:builderzebra/runtime/dispatcher_factory.dart';
import 'package:builderzebra/runtime/mighty_eagle_parser_hook.dart';
import 'package:builderzebra/abstracts/dispatcher.dart';
import 'package:builderzebra/runtime/echo_dispatcher.dart';
import 'package:builderzebra/runtime/dispatcher_factory.dart';
import 'package:builderzebra/runtime/zebra_truth_binder.dart';

void printUsage() {
  print('Zebra Template Validator – ${DateTime.now().year}');
  print('Usage: dart validator_zebra.dart [options]');
  print('Options:');
  print('  -f <file>         Validate a single .eagle template');
  print('  -d <directory>    Validate all .eagle files in directory');
  print('  -o <file>         Write output to this file (overwrites)');
  print(
    '  -O <file>         Also print to stdout/stderr in addition to output file',
  );
  print('  -h                Show this help menu');
}

Future<void> validateFile(
  File file, {
  IOSink? output,
  bool writeToConsole = true,
}) async {
  MightyEagleParserHook hook;
  final template = await file.readAsString();

  if (output == null) {
    // parameter validation.  Don't send me writeToConsol false
    // without sending me some place else to write.
    writeToConsole = true;
  }

  if (writeToConsole) {
    // OK.  I get it.  We're going to write to the console.
    // easy. Just use the default constructor. 
    hook = MightyEagleParserHook();
  } else {
    // Got it! Squelch the console and send validation results
    // to some other IOSink.  NP.
    hook = MightyEagleParserHook(
      defaultErrorOutStream: output,
      defaultMessageOutStream: output,
    );
  }

  final binder=ZebraTruthBinder({});
  final dispatcher = DispatcherFactory(binder: binder).dispatch('echo');
  if (dispatcher == null){
    throw ("DispatcherFactory Couldn't build EchoDispatcher");
  }
  final parser = MightyEagleParser(
    template: template,
    context: {}, // No substitutions
    dispatcher: dispatcher,
    parserHook: hook,
  );

  await parser.parse();
  if(writeToConsole && output != null){
    // Oh... I see you wanted both an IOSink and console
    // output.  So, earlier I sent the data to the 
    // console, now I'll send it to the some other IOSink. 

    await hook.tattle(
      errorStream: output,
      messageStream: output);
    }
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
