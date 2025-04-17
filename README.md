# 🦓 BuilderZebra

> **Generic tools solve generic problems.**  
> **The problem is, there is no such thing as a generic problem.**  
> — BuilderZebra Prime Directive

---

## ✨ What is BuilderZebra?

**BuilderZebra** is a smart, rule-driven scaffolding engine made for **builders**, not boilerplate.  
It doesn’t assume your codebase is generic. It assumes **you aren’t.**

BuilderZebra helps you:

- Scaffold from a single source of truth (`datatruth.json`)
- Apply architecture-specific rules and decisions across your stack (`rules/`)
- Use executable, interpreted scripts for logic injection (not compiled callbacks)
- Remember what you’ve already built and how you wanted it to work (`decisions.json`)
- Adapt your structure over time without rewrites or rewiring

BuilderZebra doesn’t generate your whole app.
It scaffolds **just enough** to get your work moving—and then gets the hell out of the way.

---

## 🧠 Philosophy

- **Problems are unique. Always.**
- **Builders know best. Always.**
- Tools must respect **context**, **intent**, and **judgment**.
- Assumptions must be replaceable with **rules**.
- Builders should never repeat themselves twice. If they do, it’s time to write a rule.
- **If you modify a generated file by hand, it's a signal.**  
  **A signal that a rule is missing, broken, or unclear.**  
  **Every manual touch is a clue on how to teach the tool to be smarter next time.**

---

## 🔄 Dual Perspectives

### From the **Builder's Point of View**
- I have a specific job to do (a model, a UI form, a DAO)
- I want to define the structure once and reuse it
- I want to iterate fast with templates I control
- If I change the output, I want Zebra to remember that next time

### From the **Architect's Point of View**
- Tools should not make assumptions without asking
- The tool must evolve by design
- All dynamic behavior should live outside the binary
- Shelling out to interpretable scripts (e.g., Dart, Bash, Python) enables speed and clarity
- State and structure must live in plain-text files, editable and portable

---

## 📂 Directory Structure

```plaintext
working_directory/
├── templates/         # File structure blueprints
│   ├── model.tpl
│   ├── dao.tpl
│   └── dto.tpl
│
├── data/              # Builder-defined truth and evolving memory
│   ├── datatruth.json     # Describes the problem (schema, fields, generation targets)
│   └── decisions.json      # Stores post-generation preferences & history
│
├── rules/             # Executable files that decide behavior (shell-out)
│   ├── model.dart
│   ├── dao.dart
│   └── dto.sh
```

---

## 🤜 Core Concepts

| Concept           | Description                                                     |
|-------------------|-----------------------------------------------------------------|
| `datatruth.json`  | Builder-defined schema and structure for all output             |
| `decisions.json`  | Zebra's memory of your preferences and overrides                |
| Templates         | The raw text-based blueprint used to generate files             |
| Rules             | Executable scripts that handle the decision logic for each type |
| Feedback Loop     | If you change something manually, Zebra can ask to remember it  |

---

## 🛠 Example Workflow

```sh
# Generate a model from schema
zebra scaffold create model data/datatruth.json journal

# Generate additional artifacts
zebra scaffold create dto data/datatruth.json journal
zebra scaffold create dao data/datatruth.json journal

# Regenerate all known targets
zebra scaffold generate all
```

---

## 🧾 Sample `datatruth.json`

```json
{
  "journal": {
    "description": "User-written journal entries",
    "fields": {
      "id": { "type": "int", "primary": true },
      "content": { "type": "string", "required": true },
      "createdAt": { "type": "DateTime" },
      "endDate": { "type": "DateTime?" }
    },
    "generate": ["model", "dto", "dao"]
  }
}
```

---

## 🔎 Sample `decisions.json`

```json
{
  "journal": {
    "outputPath": "lib/core/models",
    "rulesApplied": ["exclude_audit_fields", "use_soft_delete"]
  },
  "defaults": {
    "dto": {
      "excludeFields": ["createdAt", "updatedAt"]
    }
  }
}
```

---

## 🔧 Sample Rules (`rules/model.dart`)

```dart
void main(List<String> args) {
  final modelName = args[0];
  // Read data/datatruth.json and emit values for template context
  // Or handle special logic for transformations
  print(jsonEncode({
    "className": modelName,
    "fields": [/* structured field list */]
  }));
}
```

> Zebra shells out to these rule scripts with arguments and expects stdout as JSON.

---

## 🧱 BuilderZebra is Not...

- ❌ A framework
- ❌ A magic code generator
- ❌ A replacement for judgment

It’s a **scaffold engine with memory**, designed for builders who see the world through intent and nuance—not checkboxes and defaults.

---

## 💬 In the Words of the Builder

> “Does the product reflect what I meant?”

This project doesn’t aim to be universal.  
It aims to be **right**—for **you**, in **this moment**, with **these constraint