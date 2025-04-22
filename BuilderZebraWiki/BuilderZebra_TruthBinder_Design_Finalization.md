✅ Here's your finalized markdown:  
**BuilderZebra – TruthBinder Design Finalization — 2025_04_21**

---

```markdown
# 🧠 BuilderZebra – TruthBinder Design Finalization — 2025_04_21

## ✅ Breakthrough Summary

Today, BuilderZebra locked in the role and structure of the `TruthBinder` — an abstraction that **removes all friction** from the parser/dispatcher relationship by providing both:

- Contextually relevant data
- In a format the parser expects: `Map<String, String>`

---

## 🧱 Problem Recap

- The parser needs flat, stringified context maps
- The source of truth (`truths`) is nested JSON or Dart objects
- Dispatchers were carrying the burden of shape awareness

This created **friction** — especially when using loops like `@each` or `@member_vars`.

---

## 🧠 Realization

> The `TruthBinder` shouldn’t just retrieve data.  
> It should **transform data into parser-ready context**.

This gives us clean separation:

- **Data Shape Awareness** → `TruthBinder`
- **Render Behavior** → `Dispatcher`
- **Substitution Logic** → `Parser`

---

## ✅ Finalized Role of TruthBinder

```dart
abstract class TruthBinder {
  // Returns parser-ready field context for a given truth
  Future<List<Map<String, String>>> findFieldsForTruth(String truthName);

  // Returns the top-level context for a truth (e.g., its name, type, etc.)
  Future<Map<String, String>> getFlattenedTruth(String truthName);
}
```

---

## ✅ Final Flow — Fully Aligned with Past Architecture

```dart
final fields = await binder.findFieldsForTruth("Person");
for (final fieldContext in fields) {
  final rendered = await parser.parse(template: fieldBlock, context: fieldContext);
  // use or accumulate `rendered` output
}
```

> This matches how Ronald implemented this *years ago* — using a DB-backed system with the same core logic flow.

---

## 💡 Why This Solves Everything

| Concern                        | Solved By                    |
|-------------------------------|------------------------------|
| Nested data structure         | Binder handles flattening    |
| Consistent parser contract    | Always receives flat maps    |
| Future schema changes         | Isolated in binder logic     |
| Dispatcher clarity            | Focused purely on intent     |
| Parser purity                 | Stateless, composable, testable |

---

## 🚀 Forward Path

- Implement `JsonTruthBinder` using current `.json` file shape
- Use `getFlattenedTruth()` when injecting a top-level context
- Use `findFieldsForTruth()` for loop-like action tags
- Pass binder to all dispatchers that need scoped access

---

## 🧠 Final Insight

> “The dispatcher doesn’t know where the truth lives.  
> The binder makes it look like it was always in the right shape.”

BuilderZebra now has a complete, friction-free architecture for truth resolution.
```

Let me know when you’re ready to implement `JsonTruthBinder`, or want this added to the wiki archive. This one’s a core document.