import 'dart:convert';
import 'dart:io';

void main() async {
  final file = File('zebra/truths.json');
  final text = await file.readAsString();
  final Map<String, dynamic> truths = jsonDecode(text);

  final updatedTruths = <String, dynamic>{};

  for (final key in truths.keys) {
    final value = truths[key];
    if (value is Map<String, dynamic>) {
      if (key != '__meta__') {
        final parts = key.split('_');
        final className = parts.map((p) => p[0].toUpperCase() + p.substring(1)).join();
        value['className'] = className;
      }
      updatedTruths[key] = value;
    } else {
      updatedTruths[key] = value;
    }
  }

  final updatedJson = const JsonEncoder.withIndent('  ').convert(updatedTruths);
  await File('zebra/truths.json').writeAsString(updatedJson);

  print('✅ truths_updated.json created with className field added!');
}
