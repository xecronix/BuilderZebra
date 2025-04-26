💥 Awesome!  
Let’s build a **tight**, **ready-to-paste** BuilderZebra `scaffold.json` **cheat sheet** 🛠️🦅

---

# 📋 **BuilderZebra Scaffold.json Cheat Sheet**

---

# 🛠️ Basic Structure

```json
{
  "scaffold": {
    "OutputName": {
      "template": "template_name.eagle",
      "output": "path/to/output/",
      "outputFilePattern": "%{truth.name}_suffix.ext",
      "overwrite": "always", // or "never"
      "truths": ["optional", "truth", "whitelist"],
      "excludeTruths": ["optional", "truth", "blacklist"]
    }
  }
}
```

---

# 📚 Fields Explained

| Field | Meaning |
|:------|:--------|
| `template` | Template file inside `zebra/eagles/` (e.g., `base_model.eagle`). |
| `output` | Folder to write generated files (relative to project root). |
| `outputFilePattern` | Filename template (e.g., `%{truth.name}_model.dart`). |
| `overwrite` | `"always"` (replace) or `"never"` (only create if missing). |
| `truths` | (Optional) List of truths to include (whitelist). |
| `excludeTruths` | (Optional) List of truths to exclude (blacklist). |

---

# 🧩 Behavior Rules

| Situation | Behavior |
|:----------|:---------|
| `truths` present | Only build listed truths. |
| `excludeTruths` present | Exclude listed truths from build. |
| Both present | Whitelist first → then filter out blacklist. |
| Neither present | Build all available truths. |

---

# 📜 Mini Examples

✅ **Simple build everything**

```json
"Model": {
  "template": "base_model.eagle",
  "output": "generated/base_models/",
  "outputFilePattern": "%{truth.name}_model.dart",
  "overwrite": "always"
}
```

---

✅ **Build selected truths only**

```json
"Model": {
  "template": "base_model.eagle",
  "output": "generated/base_models/",
  "outputFilePattern": "%{truth.name}_model.dart",
  "overwrite": "always",
  "truths": ["journal", "todo_entry"]
}
```

---

✅ **Build everything except some truths**

```json
"Model": {
  "template": "base_model.eagle",
  "output": "generated/base_models/",
  "outputFilePattern": "%{truth.name}_model.dart",
  "overwrite": "always",
  "excludeTruths": ["__meta__", "archive"]
}
```

---

✅ **Protect human files**

```json
"ModelWrapper": {
  "template": "model_wrapper.eagle",
  "output": "lib/core/models/",
  "outputFilePattern": "%{truth.name}_model.dart",
  "overwrite": "never"
}
```

---

# 🚀 Commands

| Command | Action |
|:--------|:-------|
| `dart builder_zebra.dart` | Build all outputs. |
| `dart builder_zebra.dart validate` | Validate templates without writing files. |

---

# 🛡️ Pro Tips

- Use `"never"` for human-edited code (wrappers, custom classes).
- Keep paths clean and organized by feature (e.g., models, controllers, daos).
- Validate often to catch issues early.

---

