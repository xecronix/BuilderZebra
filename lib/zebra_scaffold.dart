// 📁 File: zebra_scaffold.dart

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:builderzebra/runtime/static_truth_binder.dart'; // Static TruthBinder implementation
import 'package:builderzebra/engine/mighty_eagle.dart';
import 'package:builderzebra/runtime/truth_dispatcher.dart';

void main(List<String> args) async {
  final fullPath = 'C:/dev/builderzebra/lib/';
  final programControl = {
    'builderOptions': {'overwriteExistingFiles': true},
    'outputs': {
      'Model': {
        'template': '${fullPath}temp/templates/model.eagle',
        'output': '${fullPath}temp/lib/core/models/',
        'outputFilePattern': '%{truth.name}_model.dart',
        'truths': ['Person', 'Address', 'Education'],
      },
      'Controller': {
        'template': '${fullPath}temp/templates/controller.eagle',
        'output': '${fullPath}temp/lib/core/controllers/',
        'outputFilePattern': '%{truth.name}_controller.dart',
        'truths': ['Person'],
      },
      'Dao': {
        'template': '${fullPath}temp/templates/dao.eagle',
        'output': '${fullPath}temp/lib/core/data/',
        'outputFilePattern': '%{truth.name}_dao.dart',
        'truths': ['Person', 'Address', 'Education'],
      },
    },
  };

  String resolveOutputFilePattern(String pattern, Map<String, String> context) {
    return pattern.replaceAll('%{truth.name}', context['name']?.toLowerCase() ?? '');
  }

  final outputs = programControl['outputs'] as Map<String, dynamic>;
  final binder = StaticTruthBinder();
  final dispatcher = TruthDispatcher(binder: binder);

  for (final outputName in outputs.keys) {
    final outputConfig = outputs[outputName] as Map<String, dynamic>;

    final outputDir = outputConfig['output'] as String;
    final pattern = outputConfig['outputFilePattern'] as String;
    final truths = outputConfig['truths'] as List;
    final templatePath = outputConfig['template'] as String;
    final template = await File(templatePath).readAsString();

    for (final truthName in truths) {
      final context = await binder.findTruth(truthName: truthName);

      final parser = MightyEagleParser(
        template: template,
        context: context,
        dispatcher: dispatcher,
      );

      final rendered = await parser.parse();

      final fileName = resolveOutputFilePattern(pattern, context);
      final fullPath = p.join(outputDir, fileName);

      await Directory(outputDir).create(recursive: true);

      final file = File(fullPath);
      await file.writeAsString(rendered);
    }
  }
}
