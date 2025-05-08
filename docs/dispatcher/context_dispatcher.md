
# @context ContextDispatcher

⚠️ **CO-MANAGED FILE**

This file is auto-generated and should be updated manually if logic changes.

---

## Purpose

`@context` is intended for debugging. It renders the current template context to the output using Dart-style access paths.

---

## Usage

### 📦 Context

```json
{
  "foo": "bar",
  "nested.a": "1",
  "nested.b.c": "true",
  "items[0].wagon": "red",
  "items[1].ball": "round"
}
````

### 📄 Template

```text
{@context:}
```

### 🧾 Output

```text
context['foo'] = bar
context['nested.a'] = 1
context['nested.b.c'] = true
context['items[0].wagon'] = red
context['items[1].ball'] = round
```

