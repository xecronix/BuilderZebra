✅ Here is your BuilderZebra design meeting summary markdown:

---

```markdown
# 🧩 BuilderZebra Design Meeting Summary — 2025_04_21

## 📅 Context

This meeting was called to reflect on BuilderZebra’s data flow model and architectural tension between the parser, dispatcher, and future data sources. The parser is already solid — this session focused entirely on improving the **Builder tool** that feeds it.

---

## 🧠 Key Realizations

### 1. The Parser Should Not Pull Data
> "I feel too much friction in asking the parser to know how to ask anything for data. It needs to be told what the data is."

✅ This affirms that:
- Parser remains stateless and scope-aware
- Parser is given what it needs — it doesn’t ask for more

---

### 2. Dispatchers Must Be Both Context & Data Aware
If the parser is dumb, **dispatchers must become smart**:
- A dispatcher needs both:
  - The scoped **context**
  - The scoped **data fragment** it's meant to interpret

---

### 3. JSON May Be Temporary — SQLite Is a Likely Future
It became clear today that:
- A rigid structure is required for generic tags like `@each` or `@if`
- Validation will be a must
- JSON may not provide the long-term ergonomics BuilderZebra deserves

✅ A future phase could transition to:
```text
SQLite → JSON → Parser
```

---

### 4. Data Should Be Accessed via a "Service" Layer
To prepare for future changes and reduce friction today:
- Introduce a **data service abstraction**
- Dispatchers query this service using:
  - Current context
  - Requested path (e.g., `'truth.fields'`)
- The service can be:
  - A mock
  - A JSON reader
  - Later: a SQLite-backed source

This mirrors what was done with Hooks:
> "The parser didn’t manage errors well — so we introduced a hook layer to standardize messaging."

Now, data access gets the same treatment.

---

## 🔮 Forward Path

| Layer        | New Responsibility                     |
|--------------|-----------------------------------------|
| Parser       | Accepts context and renders templates   |
| Dispatcher   | Interprets tags using data + context    |
| DataService  | Retrieves scoped fragments (pluggable)  |
| JSON         | Current truth source                    |
| SQLite       | Future truth source (via data service)  |

---

## 🧠 Final Insight

> "If change is probable, plan for it today."

BuilderZebra’s next step is not a rewrite — it’s an **interface**:  
Build the data service abstraction now, and future-proof all of it.
```
