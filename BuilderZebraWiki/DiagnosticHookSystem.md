
---

# 🧠 BuilderZebra Diagnostic Hook System

## 💡 Purpose
The `ParserHook` system is designed to **separate parsing from reporting**.  
It enables BuilderZebra to run **with graceful error tolerance**, while still surfacing:

- ❌ Fatal parse errors
- ⚠️ Warnings or friction indicators
- 💬 General diagnostics or log messages

The hook system also allows for **post-parsing tattle** to any `IOSink`, including `stdout`, `stderr`, or files.

---

## 🧱 Core Interface

```dart
abstract class ParserHook {
  Future<void> error({
    required CharStream stream,
    required Exception exception,
  });

  Future<void> message({
    required CharStream stream,
    required String message,
  });

  Future<void> tattle({
    IOSink? errorStream,
    IOSink? messageStream,
  });
}
```

- `error()` → Called when exceptions are caught during parsing
- `message()` → Called for normal notes or structural warnings
- `tattle()` → Called once at the end of a parse job to emit all logs

---

## 🦅 `MightyEagleParserHook` Implementation

This implementation collects all messages into memory and emits them at tattle:

```dart
final List<String> _messages = [];
final List<String> _errorMessages = [];

Future<void> error(...) {
  _errorMessages.add('[BuilderZebra:${type}] Error at ${offset}: ${message}');
  _errorMessages.add('↪ Context: ...${stream.previewContext()}...');
}

Future<void> tattle({IOSink? errorStream, IOSink? messageStream}) async {
  final err = errorStream ?? stderr;
  final out = messageStream ?? stdout;

  for (final msg in _messages) {
    out.writeln(msg);
  }

  for (final msg in _errorMessages) {
    err.writeln(msg);
  }
}
```

---

## 🚀 Usage Pattern

```dart
final hook = MightyEagleParserHook();
final parser = MightyEagleParser(
  template: input,
  context: map,
  dispatcher: dispatcher,
  errorHook: hook,
);

await parser.parse();
await hook.tattle(); // required to emit logs
```

> ✅ `tattle()` is not called automatically.  
> You must **call it explicitly** or via `finally {}` after parsing completes.

---

## ✅ Design Philosophy

- BuilderZebra **runs loose**, but **reports precisely**
- Parser **does not halt** on first error
- All feedback is routed through `ParserHook`
- Output destination is **not hardcoded** — supports test, CLI, and embedded use

---

## 🛠 Future Ideas

- `LogHook` to emit structured JSON/YAML logs
- `MemoryHook` for test assertions (`expect(hook.errors.length, equals(1))`)
- `Validation-only mode` with no template output, just diagnostics

```

---
