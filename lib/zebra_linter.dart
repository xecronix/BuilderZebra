// File: zebra_linter.dart
// Purpose: Validates BuilderZebra template strings against core grammar rules
// Usage: dart zebra_linter.dart path/to/template.txt

import 'dart:io';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart zebra_linter.dart path/to/template.txt');
    exit(1);
  }

  final file = File(args[0]);
  if (!await file.exists()) {
    print('Error: File not found: ${args[0]}');
    exit(1);
  }

  final content = await file.readAsString();
  final issues = ZebraLinter().lint(content);

  if (issues.isEmpty) {
    print('✅ Template passed all checks.');
  } else {
    print('❌ Found ${issues.length} issue(s):\n');
    for (final issue in issues) {
      print('- ${issue.message} (at offset ${issue.offset})');
    }
    exit(2);
  }
}

class ZebraLinter {
  List<LintIssue> lint(String input) {
    final issues = <LintIssue>[];
    final stack = <int>[];

    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      final peek = (i + 1 < input.length) ? input[i + 1] : null;

      // Detect opening tag
      if (char == '{' && (peek == '=' || peek == '@')) {
        stack.add(i);
        i++; // skip the = or @ (it's already part of the tag signature)
      }

      // Detect closing tag
      if (char == ':' && peek == '}') {
        if (stack.isEmpty) {
          issues.add(LintIssue(
            message: 'Unexpected closing tag :} with no matching opener',
            offset: i,
          ));
        } else {
          stack.removeLast();
        }
        i++; // skip the }
      }

      // Detect malformed substitution
      if (char == '{' && peek == '=') {
        final end = input.indexOf(':}', i);
        if (end == -1) {
          issues.add(LintIssue(
            message: 'Substitution tag missing closing :}',
            offset: i,
          ));
        }
      }

      // Detect malformed action rule with only one |
      if (char == '|' && peek != '|' && !input.substring(i).contains('|')) {
        issues.add(LintIssue(
          message: 'Unterminated dispatcher args (missing second |)',
          offset: i,
        ));
      }
    }

    for (final open in stack) {
      issues.add(LintIssue(
        message: 'Unclosed tag started here',
        offset: open,
      ));
    }

    return issues;
  }
}

class LintIssue {
  final String message;
  final int offset;
  LintIssue({required this.message, required this.offset});
}
