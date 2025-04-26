# 🦓 BuilderZebra Parser Overview

> *"You didn’t treat the stream as a pointer. You treated it like a mental position — and your code reflects the thought process, not just the mechanics."*  
> — Orion

---

## 🧠 Philosophy

BuilderZebra's parser is not just code. It is a **mental model** of how templated language can be parsed with **reliability and clarity**. Every rule and method follows a core principle:

> **"Never move past the last character you've dealt with."**

This ensures:
- Consistent stream advancement
- Predictable behavior at every parse step
- No skipped characters or infinite loops
- Safe lookahead using `.next` without ambiguity

The parser doesn’t guess. It *derives*. It expects input to be well-formed and is designed to **fail loudly and early** when the structure breaks.

---

## 🏗️ High-Level Architecture

The parser consumes a **string template** and produces an output string, resolving tags using:
- A **context** map (key-value substitution)
- A **dispatcher** (for dynamic rule execution)
- A **stream pointer** (`CharStream`) to walk the input one character at a time

All parsing is done **without a state machine**. Instead, the logic is structured around **method-specific responsibilities**, each one advancing the stream only after it has "dealt with" the character(s) involved.

---

### 🧩 Supported Tag Syntax (BuilderZebra)

| Tag Type               | Format Example                              | Notes                                                  |
|------------------------|----------------------------------------------|--------------------------------------------------------|
| Substitution Tag       | `{=key:}`                                    | Simple substitution from context                       |
| Action Rule Only       | `{@rule subtemplate:}`                       | No args, just rule and content                         |
| Action + Empty Args    | `{@rule||subtemplate:}`                      | Explicit empty args                                    |
| Action + Args          | `{@rule|arg1| subtemplate:}`                 | Dispatcher arg + subtemplate                           |
| Escaped Opening Brace  | `\{`                                         | Outputs `{`, not a tag                                 |
| Subtemplate With Fake End | `{@rule|arg subtemplate:}|:}`            | Inner `:}` is valid literal, outer `:}` closes tag     |

---

🚫 **Not Valid**: `{@rule|arg subtemplate:}` ← Mixing dispatcher args and content without second pipe

---

## 🧠 Core Methods

### `parse()`
Entry point. Initializes the stream and passes control to `beginParse()` (formerly `echo()`).

### `beginParse(CharStream)`
Main loop. Walks the stream character-by-character, handling substitution tags, action rules, and raw content.

### `openSubstitutionRule(CharStream)`
Consumes `{=key:}` style tags. Looks up `key` in context and replaces it with its value.

### `openActionRule(CharStream)`
Consumes action tags starting with `{@`. May include:
- Dispatcher args using `|`
- Subtemplate content (possibly nested)
- Terminates at matching `:}` with controlled nesting

### `openDispatchArgs(CharStream)`
Reads characters until it hits an unescaped `|`. Escaped pipes (`\|`) are preserved.

### `openSubtemplate(CharStream)`
Handles everything between tag openers and the matching `:}`.  
Uses `nestLevel` tracking to ensure nested tags are parsed correctly.  
Does not consume the closing tag — it leaves the stream **at** the closing brace for the parent method to handle.

---

## 🧠 Stream Handling Contract

BuilderZebra enforces a **strict stream discipline**:

- Each method must **start** with the stream on the first character of interest.
- Each method must **end** with the stream **on the last character it dealt with**.
- The parent or loop will handle the final `advance()`.

This leads to the golden rule:
> **"Never move past the last character you’ve dealt with."**

Think of `stream.advance()` not as “next step,” but as **`stream.catchUp()`** — it realigns the stream with your mental processing of the data.

---

## 🛠️ How to Make Safe Changes

1. **Honor the contract.**  
   Always leave the stream on the last consumed character. Don’t skip past without a reason.

2. **Understand nesting.**  
   Any new tag that supports nesting must increase `nestLevel` on open and decrease it on close.

3. **Avoid double-advance.**  
   Don't `advance()` inside a helper *and* again after calling it. Only one place should move the stream forward for each character processed.

4. **Logically structure your tags.**  
   Each tag processor should:
   - Extract meaning
   - Write to output
   - Move the stream
   - Return cleanly

5. **Write tests for malformed inputs.**  
   Zebra fails *loud and early* when given malformed templates like `{=key}`, `{@rule`, or missing closers.

---

## 🧪 Example Template

### Template:
