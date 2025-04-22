// 📁 File: builderzebra_model_scaffold.dart

// 🧠 Goal: Scaffold source code files from `.zebra` schema using `.eagle` templates.
// Truths are template data. Everything else is program (BuilderZebra) control.

// ✅ Target Outputs: model, controller, dao, dto, test

// ---
// Template Engine Features Required:
// - {=var:} substitution (direct lookup)
// - {@each|target| ... } dispatcher-based looping (e.g., for fields)
// - {@rule|value|:} conditional inserts and logic blocks
// - {@truth|name| ... :} top-level entrypoint for truth-based rendering (automatically injected)
// ---

// 📝 Sample Schema (.zebra):
/*
{
  "builderOptions": {
    "overwriteExistingFiles": false
  },
  "outputTypes": [
    {
      "type": "Model", // used to generate class names and constructors
      "template": "templates/model.eagle",
      "output": "lib/core/models/",
      "outputFilePattern": "${truth.name}_model.dart",
      "truths": ["Person", "Address", "Education"]
    },
    {
      "type": "Controller",
      "template": "templates/controller.eagle",
      "output": "lib/core/controllers/",
      "outputFilePattern": "${truth.name}_controller.dart",
      "truths": ["Person"]
    },
    {
      "type": "Dao",
      "template": "templates/dao.eagle",
      "output": "lib/core/data/",
      "outputFilePattern": "${truth.name}_dao.dart",
      "truths": ["Person", "Address", "Education"]
    }
  ],
  "truths": [
    {
      "name": "Person", // used to generate class names and constructors
      "fields": [
        { "name": "firstName", "type": "String", "nullable": false },
        { "name": "age", "type": "int", "nullable": true }
      ]
    }
  ]
}
*/

// 🦓 Sample Template Snippet (.eagle):
/*
class {=name:} {
	{@fields final {=type:}{@nullable|?|:} {=name:};
	:}
}
*/

// 📁 Output (example for model): lib/core/models/person_model.dart
/*
class Person {
  final String firstName;
  final int? age;
}
*/

// This canvas is the working spec for the BuilderZebra CLI scaffolder:
// 1. Reads `.zebra` schema
// 2. Loads all templates listed in `outputTypes`
// 3. For each truth listed in each outputType, injects it via `@truth|...| ... :}` block automatically
// 4. Writes output to resolved destinations using `outputFilePattern`

// 🧠 Note:
// - Templates no longer need to hardcode `@truth|Name| ...` — the engine injects the correct context
// - `outputFilePattern` resolves with variables like `$truth.name`
// - Action tags like {@snake_name:} are not implemented yet

// Next Step → Implement `zebra_scaffold.dart` CLI tool with:
// - Schema + Template loader
// - Dispatcher engine with `@truth`, `@fields`, `@nullable` support
// - File generator with pattern-based output resolution
