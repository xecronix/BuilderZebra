# 🧩 BuilderZebra Templating Syntax Specification

This document defines the templating syntax for BuilderZebra, including how substitution and action tags are parsed, resolved, and rendered.

---

## 🧠 Tag Types

BuilderZebra supports two types of tags:

| Tag Type       | Example                         | Purpose                                       |
|----------------|----------------------------------|-----------------------------------------------|
| Substitution   | `{=field:}`                     | Resolves value from the context map           |
| Action         | `{@rule:subtemplate:}`          | Calls an external script to process content   |

---

## ✨ Substitution Tags

### Format:
```text
{=key:}
```

### Behavior:
- Looks up `key` in the context map.
- Replaces the tag with the resolved value.

### Example:
```text
Hello {=name:}!
```
Given context:
```json
{ "name": "Ronald" }
```
Output:
```text
Hello Ronald!
```

---

## 🚀 Action Tags

### Format Variants:
```text
{@rule:subtemplate:}              # no arguments
{@rule:arg1:arg2:subtemplate:}    # positional arguments before subtemplate
```

### Components:
- **rule**: The name of the rule script (e.g., `rules/rule.dart`)
- **args**: Optional positional arguments (space-free, colon-separated)
- **subtemplate**: The body passed to the rule, raw

### Behavior:
1. Zebra recognizes `{@rule:...:}`
2. Captures arguments and the subtemplate
3. Passes both to `rules/rule.dart` or equivalent script
4. Shells out using:
   ```bash
   rules/rule.dart arg1 arg2
   ```
5. Sends subtemplate (and context map) via stdin or environment
6. Replaces the entire tag block with the result from the rule

### Example 1: No args
```text
{@echo:Hello {=name:}:}
```
Resolves inner substitution, then passes:
```json
{
  "template": "Hello Ronald",
  "context": { "name": "Ronald" },
  "args": []
}
```

### Example 2: With args
```text
{@repeat:7:Four score and {=years:} ago:}
```
Resolves context, then sends to `repeat.dart`:
```json
{
  "template": "Four score and {=years:} ago",
  "context": { "years": "1" },
  "args": ["7"]
}
```
Output:
```text
Four score and 1 year ago
Four score and 2 years ago
...
Four score and 7 years ago
```

---

## 📜 Escaping and Edge Cases

- To output literal `{=...:}` or `{@...:}`, use escaping (future spec)
- Zebra will support future block tags using the same action syntax:
```text
{@loop:entries:}{=entry.name:}{/loop}
```

---

## 🧪 Nesting Behavior

Tags can be nested. Zebra resolves **inner substitution tags first**, then passes the final subtemplate to the action rule.

### Example:
```text
{@thing:Four score and {=years:} ago:}
```
- Resolves `{=years:}` → `seven`
- Resulting template: `Four score and seven ago`
- Sent to `rules/thing.dart`

---

## ✅ Summary

BuilderZebra templates are designed to:
- Be **human-readable**
- Support **composable behavior**
- Separate **intent** (template) from **implementation** (rules)
- Allow **extensibility** via shellable rule scripts

Use `{=...:}` for simple value replacement.
Use `{@...:}` when it’s time to get smart.

---

_Last updated: 2025-04-14_

