💥 **YES!**  
Let's capture the true heart of the MightyEagle Language while it's fresh, precise, and powerful. 🦅🛠️

---

# 📜 **MightyEagle Template Language Rules – Draft v1**

---
## 🦅 Overview

**MightyEagle** is a lightweight, rule-driven template language designed for smart, scalable code scaffolding.  
It prioritizes **clarity**, **consistency**, and **dynamic expansion** without requiring a full parser or runtime compiler.

---

## 🧠 Core Principles

| Principle | Description |
|:----------|:------------|
| Dispatcher-based | Templates expand by invoking "dispatchers" like `if`, `each`, `echo`, etc. |
| Minimal Language | No deep expression parsing — only simple argument parsing (==, !=). |
| Explicit Markers | Dispatchers are clearly marked with `{@ ...}` syntax. |
| Raw String Safety | Templates are written in Dart raw strings (`r'...'`) to preserve formatting. |
| Context-Driven | Expansion is entirely driven by a supplied context map (e.g., name/value pairs). |

---

## 🏗 Template Syntax Rules

### 1. Dispatcher Start

| Field | Syntax |
|:------|:-------|
| Start a dispatcher | `{@dispatcher|args|template:}` |

✅ Always starts with `{@`  
✅ Ends dispatcher args with `|:`  

---

### 2. Arguments

| Dispatcher | Argument Format | Example |
|:-----------|:----------------|:--------|
| `if` | **$** prefix required | `{@if|$field==value|Template Content:}` |
| `each` | **$** prefix now recommended | `{@each|$collection|Template Content:}` |
| `echo` | No special prefix needed | `{=field:}` |

✅ Arguments are split by `|`.  
✅ **Spaces are significant** — extra spaces can cause mismatches.

---

### 3. Conditionals (`if`)

| Rule | Behavior |
|:-----|:---------|
| Comparison Operators | Only `==` and `!=` are supported. |
| LHS | Must be a `$field`. |
| RHS | Always treated as a **literal string**. |
| Quotes | Quotes around RHS values are stripped automatically. |
| Spaces | Spaces inside values matter — *trim carefully*. |
| No parsing expressions | No `>`, `<`, `>=`, `&&`, etc. (yet). |

---

### 4. Loops (`each`)

| Rule | Behavior |
|:-----|:---------|
| Argument | Should now always be `$collection` (example: `$fields`). |
| Binder | Supplies a list of maps for children. |
| Each iteration | Runs the inner template once per child. |
| Inner template | Has access to each child's fields. |

---

### 5. Echo Substitution

| Rule | Syntax | Example |
|:-----|:-------|:--------|
| Direct field substitution | `{=field:}` | Expands to the value of `field`. |
| No prefix needed | ✅ Field name is raw inside `{= :}`. |

---

## 🛡 Enforcement Notes

- Every dispatcher argument section must end with `:}`.  
- Each template body (after `|:`) expands recursively — dispatchers inside dispatchers are allowed.
- If parsing errors occur (e.g., missing `:}`, bad format), the engine should either:
  - Fail gracefully with warnings, or
  - Output as much as it can safely expand.

---

# 🚀 Example MightyEagle Template

```dart
class {=name:}Model {
  {@each|$fields|
    final {=type:}{@if|$nullable==true|?:} {=name:};
  :}
}
```

**Given Context:**

```json
{
  "name": "Person",
  "fields": [
    {"name": "id", "type": "int", "nullable": false},
    {"name": "email", "type": "String", "nullable": true}
  ]
}
```

**Expands to:**

```dart
class PersonModel {
  final int id;
  final String? email;
}
```

---

# 🎯 Future-Proofing

| Potential Feature | Status |
|:------------------|:-------|
| Complex expressions (>, <, &&, etc.) | ❌ Not supported yet |
| Function-like dispatchers (map, filter) | ❌ Not yet |
| Multiple argument dispatchers | ✅ Already compatible |
| Custom user dispatchers | 🚀 Future roadmap |

---

# 🧡 Final Thought

MightyEagle is not about **pretending to be a full programming language**.  
It’s about giving **builders** simple, sharp tools that scale **with your vision**,  
**without unnecessary complexity**.

🦅

---
