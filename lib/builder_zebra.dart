// 📁 File: builder_zebra.dart

import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:builderzebra/runtime/zebra_truth_binder.dart'; // Static TruthBinder implementation
import 'package:builderzebra/engine/mighty_eagle.dart';
import 'package:builderzebra/runtime/truth_dispatcher.dart';
import 'package:builderzebra/runtime/dispatcher_factory.dart';

void main(List<String> args) async {
  // Dispatch init and validate commands
  if (args.isNotEmpty) {
    switch (args.first) {
      case 'init':
        final templateName = args.length > 1 ? args[1] : 'default';
        await runInit(templateName);
        return;
      case 'validate':
        await runValidate();
        return;
    }
  }

  final root = Directory.current.path;
  //final root = 'C:/dev/builderzebra/lib';
  final zebraJson = File(p.join(root, 'zebra', 'zebra.json'));
  final scaffoldJson = File(p.join(root, 'zebra', 'scaffold.json'));
  final truthsJson = File(p.join(root, 'zebra', 'truths.json'));

  if (!await zebraJson.exists() || !await scaffoldJson.exists()) {
    print(
      '⚠️  Missing zebra.json or scaffold.json. Run `builder_zebra init` first.',
    );
    return;
  }

  final programControl = jsonDecode(await zebraJson.readAsString());
  final scaffold = jsonDecode(await scaffoldJson.readAsString());
  final truthData = jsonDecode(await truthsJson.readAsString());

  String resolveOutputFilePattern(String pattern, Map<String, String> context) {
    return pattern.replaceAll(
      '%{truth.name}',
      context['name']?.toLowerCase() ?? '',
    );
  }

  final scaffoldMap = scaffold['scaffold'];
  final binder = ZebraTruthBinder(truthData);
  final dispatcherFactory = new DispatcherFactory(binder: binder);
  final dispatcher = dispatcherFactory.dispatch('truth');
  if (dispatcher == null) {
    throw ("DispatcherFactory tried to build a TruthDispatcher but couldn't");
  }

  for (final outputName in scaffoldMap.keys) {
    final outputConfig = scaffoldMap[outputName] as Map<String, dynamic>;

    final outputDir = outputConfig['output'] as String;
    final pattern = outputConfig['outputFilePattern'] as String;
    final List<String> configuredTruths =
        (outputConfig['truths'] as List?)?.cast<String>() ??
        binder.getAllTruthNames();

    final List<String> excludedTruths =
        (outputConfig['excludeTruths'] as List?)?.cast<String>() ?? [];

    final truths =
        configuredTruths
            .where((truth) => !excludedTruths.contains(truth))
            .toList();

    final templatePath = outputConfig['template'] as String;
    final template =
        await File(p.join(root, 'zebra/eagles', templatePath)).readAsString();
    var rendered = '';
    for (final truthName in truths) {
      final context = await binder.findTruth(truthName: truthName);

      final parser = MightyEagleParser(
        template: template,
        context: context,
        dispatcher: dispatcher,
      );

      rendered = await parser.parse();

      final fileName = resolveOutputFilePattern(pattern, context);
      final targetPath = p.join(root, outputDir, fileName);

      await Directory(outputDir).create(recursive: true);

      final file = File(targetPath);
      final shouldWrite =
          outputConfig['overwrite'] != 'never' || !await file.exists();

      if (shouldWrite) {
        print('📝 Writing file: $targetPath');
        await file.writeAsString(rendered);
      } else {
        print('⏭️ Skipped $targetPath (overwrite = never)');
      }
    }
  }
}

Future<void> runValidate() async {
  final root = Directory.current.path;
  final scaffold = File(p.join(root, 'zebra', 'scaffold.json'));
  final truths = File(p.join(root, 'zebra', 'truths.json'));
  final zebraConfig = File(p.join(root, 'zebra', 'zebra.json'));

  if (!await scaffold.exists() || !await truths.exists()) {
    print(
      '⚠️  Missing scaffold.json or truths.json. Run `builder_zebra init` first.',
    );
    return;
  }

  final programControl = jsonDecode(await zebraConfig.readAsString());
  final scaffoldData = jsonDecode(await scaffold.readAsString());
  final truthData = jsonDecode(await truths.readAsString());

  final scaffoldMap = scaffoldData['scaffold'] as Map<String, dynamic>;
  final binder = ZebraTruthBinder(truthData);
  final dispatcherFactory = new DispatcherFactory(binder: binder);
  final dispatcher = dispatcherFactory.dispatch('truth');

  print('🔍 Running BuilderZebra in validation mode...');

  for (final outputName in scaffoldMap.keys) {
    final outputConfig = scaffoldMap[outputName] as Map<String, dynamic>;
    final pattern = outputConfig['outputFilePattern'] as String;
    final truths = outputConfig['truths'] as List;
    final templatePath = outputConfig['template'] as String;

    final templateFile = File(p.join(root, 'zebra/eagles', templatePath));
    if (!await templateFile.exists()) {
      print('❌ Missing template: $templatePath');
      continue;
    }

    final template = await templateFile.readAsString();

    for (final truthName in truths) {
      if (!truthData.containsKey(truthName)) {
        print('❌ Truth `$truthName` not found in truths.json');
        continue;
      }

      if (template != null && dispatcher != null) {
        final context = await binder.findTruth(truthName: truthName);
        final parser = MightyEagleParser(
          template: template,
          context: context,
          dispatcher: dispatcher,
        );

        final rendered = await parser.parse();
        print('✅ Rendered output for $truthName in $outputName:\n$rendered');
      } else {
        throw ("Tried to build and parse but couldn't.  Null checks failed");
      }
    }
  }
}

Future<void> runInit(String templateName) async {
  final zebraHome = Platform.environment['BUILDER_ZEBRA_HOME'];
  if (zebraHome == null) {
    print('❌ BUILDER_ZEBRA_HOME environment variable is not set.');
    return;
  }

  final templateSource = Directory(
    p.join(zebraHome, 'project_scaffolds', templateName),
  );
  final targetZebraDir = Directory('zebra');

  if (!await templateSource.exists()) {
    print('❌ Template "$templateName" does not exist at $templateSource');
    return;
  }

  await targetZebraDir.create(recursive: true);

  await for (final entity in templateSource.list(recursive: true)) {
    final relative = p.relative(entity.path, from: templateSource.path);
    final targetPath = p.join(targetZebraDir.path, relative);

    if (entity is File) {
      await File(entity.path).copy(targetPath);
    } else if (entity is Directory) {
      await Directory(targetPath).create(recursive: true);
    }
  }

  print('✅ Project scaffold "$templateName" copied to ./zebra');
}
