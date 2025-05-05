💥 **Absolutely!**  
Let’s build a **real, professional** BuilderZebra documentation page for `scaffold.json` — ready for your wiki.

This will be clean, complete, and production-quality.

---

# 📜 BuilderZebra Documentation: `scaffold.json`

> 🦓 **BuilderZebra Wiki** → **Configuration Reference** → **scaffold.json**

---

# 🧠 What is `scaffold.json`?

`scaffold.json` controls **what** BuilderZebra builds, **how** it builds it, and **where** the output goes.

✅ No hardcoded logic.  
✅ No manual file wiring.  
✅ 100% template-driven.

---

# 🏗️ Basic Structure

```json
{
  "scaffold": {
    "OutputName1": {
      "template": "your_template.eagle",
      "output": "relative/output/path/",
      "outputFilePattern": "filename_pattern.js",
      "truths": ["optional", "whitelist"],
      "excludeTruths": ["optional", "blacklist"]
    },
    "OutputName2": {
      ...
    }
  }
}
```

| Key | Meaning |
|:----|:--------|
| `template` | Path to the MightyEagle template (relative to `/zebra/eagles/`). |
| `output` | Target output directory (relative to project root). |
| `outputFilePattern` | Dynamic filename pattern (e.g., `%{truth.name}_model.dart`). |
| `overwrite` | `never` — never overwrite existing files. |
| `truths` | Optional list of truths to **only** scaffold (whitelist). |
| `excludeTruths` | Optional list of truths to **exclude** from scaffolding (blacklist). |

---

# 🧩 Field-by-Field Explanation

### `template`
- Relative to `/zebra/eagles/`.
- Example: `"model.eagle"` or `"controller.eagle"`

---

### `output`
- Folder where generated files should go.
- Example: `"temp/lib/core/models/"`

---

### `outputFilePattern`
- How the filenames are dynamically built.
- Supported placeholders:
  - `%{truth.name}` → inserts truth’s lowercase name
- Example: `"temp/lib/core/models/%{truth.name}_model.dart"`

---

### `overwrite`
| Option | Meaning |
|:-------|:--------|
| `"never"` | Only create file if it does not exist. |

✅ Use `"never"` for **hand-edited** files like human wrappers.  


---

### `truths`
- Optional.
- If present, **only scaffold** these listed truths.
- Example:

```json
"truths": ["journal", "todo_entry", "status"]
```

---

### `excludeTruths`
- Optional.
- If present, **exclude** these truths from scaffold run.
- Example:

```json
"excludeTruths": ["__meta__", "archive"]
```

---

# 📚 Full Example: Minimal `scaffold.json`

```json
{
  "scaffold": {
    "Model": {
      "template": "base_model.eagle",
      "output": "generated/base_models/",
      "outputFilePattern": "%{truth.name}_model.dart",
    },
    "ModelWrapper": {
      "template": "model_wrapper.eagle",
      "output": "lib/core/models/",
      "outputFilePattern": "%{truth.name}_model.dart",
      "overwrite": "never"
    }
  }
}
```

✅ Here, every truth gets:
- A **base model** (always regenerated)  
- A **wrapper model** (created once)

---

# 📚 Full Example: Advanced `scaffold.json` with Whitelist and Blacklist

```json
{
  "scaffold": {
    "CoreModels": {
      "template": "base_model.eagle",
      "output": "generated/core_models/",
      "outputFilePattern": "%{truth.name}_model.dart",
      "truths": ["journal", "todo_entry", "tag"], 
      "excludeTruths": ["todo_tag"]
    },
    "CoreControllers": {
      "template": "controller.eagle",
      "output": "lib/core/controllers/",
      "outputFilePattern": "%{truth.name}_controller.dart",
    }
  }
}
```

| Field | Meaning |
|:------|:--------|
| `"truths"` defined | Only `journal`, `todo_entry`, and `tag` are scaffolded |
| `"excludeTruths"` defined | Even inside whitelist, exclude `todo_tag` |
| `"overwrite"` set differently per output | Models and controllers handled independently |

---

# 🧠 Important Behavior Details

| Behavior | Notes |
|:---------|:------|
| If both `truths` and `excludeTruths` are present | **Whitelist first**, then **Blacklist** filters. |
| If neither is present | All truths from `truths.json` are scaffolded. |
| Paths are **relative** | Output is relative to project root, not absolute. |
| Overwrite is **per output group** | Customize safety individually for models, controllers, DAOs, etc.

---

# 🛡️ Best Practices for `scaffold.json`

| Tip | Reason |
|:----|:-------|
| Use `"never"` for human-edited code | Like wrapper models, user controllers |
| Start simple | Add `truths` and `excludeTruths` only when needed |
| Group related scaffolds | Models → `core/models/`, Controllers → `core/controllers/`, etc.
| Validate regularly | Run `builder_zebra validate` to catch template or truth errors fast |

---

# 🚀  
**Once `scaffold.json` is in place:**  
- `dart builder_zebra.dart` builds all outputs.  
- `dart builder_zebra.dart validate` checks templates without writing.

BuilderZebra will do the rest. 🦓🛠️

---
