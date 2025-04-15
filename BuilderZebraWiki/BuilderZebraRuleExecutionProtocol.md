# 📡 BuilderZebra Rule Execution Protocol

This document defines the protocol used by BuilderZebra to interact with external rule scripts during action tag evaluation.

---

## 🎯 Purpose

When an action tag like the following is encountered:

```text
{@ruleName:arg1:arg2:subtemplate:}
```

BuilderZebra:
1. Parses the rule name, arguments, and subtemplate
2. Writes a JSON input file
3. Shells out to the corresponding script
4. Reads the result from a plain text output file

This keeps logic externalized, platform-agnostic, and fully traceable.

---

## 🧾 Handler Contract

Every rule script **MUST** accept exactly two arguments:

```sh
rules/ruleName.dart input.json output.txt
```

- `input.json`: path to a JSON file provided by Zebra
- `output.txt`: path to a plain text file that the script must write to

---

## 📥 Input File (JSON Structure)

```json
{
  "template": "Four score and {=years:} ago",
  "context": {
    "years": "7"
  },
  "args": ["7"]
}
```

| Key        | Description                                      |
|------------|--------------------------------------------------|
| `template` | The subtemplate string between the action tag    |
| `context`  | Key-value map from BuilderZebra’s context engine |
| `args`     | Positional args extracted from the tag itself    |

---

## 📤 Output File (Text Format)

The output file must contain the fully rendered string that will replace the original tag in the template.

### Example output:
```
Four score and 1 year ago
Four score and 2 years ago
...
Four score and 7 years ago
```

### Notes:
- Output **must be UTF-8**
- No structured metadata is required—just raw text
- Newlines and whitespace are preserved

---

## ❌ What Not to Do

- Do **not** log to stdout (Zebra ignores it)
- Do **not** write anything to stderr unless it's an actual error
- Do **not** prompt for input—Zebra runs in non-interactive mode

---

## ✅ Best Practices

- Validate inputs before processing
- Return **non-zero exit code** if a failure occurs
- Keep rules idempotent and side-effect free
- Log errors to a `.zebra/log/` file if debug info is needed

---

## 🔒 Security Note

BuilderZebra assumes all rule scripts are **trusted**. Do not expose Zebra to untrusted `.dart`, `.sh`, or `.py` rule files without sandboxing.

---

## 🗂️ Optional Enhancements (Future)

- Use `.zebra/tmp/` for input/output file staging
- Auto-cleanup temp files after execution
- Rule registry (`zebra_rulespec.json`) to declare capabilities or tags

---

_Last updated: 2025-04-14_

