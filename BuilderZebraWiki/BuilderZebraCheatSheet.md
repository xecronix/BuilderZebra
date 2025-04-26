🔥 **YES! Let's rip it out clean and fast.**  
You’ll have a tight, builder-focused **MightyEagle Cheatsheet** ready to glance at any time 🛠️🧠.

---

# 📜 **MightyEagle Template Language – Builder Cheatsheet**

---

# 🦅 Core Syntax

| Use | Format |
|:----|:-------|
| Start dispatcher | `{@dispatcher|args|template:}` |
| End dispatcher args | Always close with `|:` |
| Echo field value | `{=field:}` |

---

# 🛠 Dispatcher Quick Rules

| Dispatcher | Notes |
|:-----------|:------|
| `if` | Condition format: `$field==value` or `$field!=value` |
| `each` | Loop format: `$collection` (prefix `$` required) |
| `echo` | Just `{=field:}` — no `$`, `%`, or `@` needed inside `{= :}` |

---

# 🧠 Conditions (Inside `{if}`)

- **Spaces matter** — no extra spaces around `==` or values.
- **Quotes are optional** — but quotes around values will be stripped.
- **Comparison is literal** — `"active"` ≠ `" active "` (no forgiveness).

✅ Always trim your values carefully.

---

# 🏗 Best Practices

| Practice | Why |
|:---------|:----|
| Always use `$` prefix in `{if}` and `{each}` args | ✅ Consistent, predictable, safer |
| Always close dispatcher args with `:}` | ✅ Required for MightyEagle to parse correctly |
| Keep dispatcher names lowercase | ✅ Consistency with `if`, `each`, `echo`, etc. |
| Use raw strings (`r'...'`) for templates in Dart | ✅ Safer handling of `{}`, `\`, and other characters |
| Use `\\n` for manual newlines if needed | ✅ In raw strings, `\n` is literal unless escaped |
| Keep template bodies lightweight | ✅ Faster parsing, easier debugging |
| Prefer explicit field mapping (e.g., `name`, `type`) in context | ✅ Cleaner template writing |
| Keep field and key names identical where needed (e.g., `"Person"` key matches `"name": "Person"`) | ✅ Avoids bugs in type naming, file generation |
| Test small templates before scaling up | ✅ Find parsing issues early |
| Document dispatchers and fields expected | ✅ Easier for future you (or teammates) |

---

# 🚀 Quick Examples

| Use Case | Example |
|:---------|:--------|
| Class Header | `class {=name:}Model {` |
| Field Declaration | `final {=type:}{@if|$nullable==true|?:} {=name:};` |
| Loop Over Fields | `{@each|$fields|...:}` |
| Simple Condition | `{@if|$status==active|It's active!:}` |
| Else Condition | `{@if|$status==active|Active!{@else:}Inactive!:}` |

---

# 🦓 Ultra-Short Mind Map

```
{=field:} → Insert value
{@dispatcher|args|template:} → Dispatcher
$variable → Required prefix for if/each
Spaces matter → Be clean!
Quotes stripped automatically
Always close args with |
```

✅ If you remember **this little box**, you can build almost anything with MightyEagle. 🦅

---

# 🎯  
**Save this cheatsheet** next to your `MightyEagleParser.md` or stick it into your Obsidian quick reference folder.  

Next time you're coding templates, you’ll be **10x faster**. 🚀

---

