---
title: "Code Structure Anti-Patterns"
description: "Common code organization and flow control mistakes to avoid in AL"
area: "architecture-design"
difficulty: "intermediate"
object_types: ["Codeunit", "Table"]
variable_types: ["Record", ]
tags: ["anti-patterns", "code-structure", "copy-paste", "nested-conditions", "duplication"]
---

# Code Structure Anti-Patterns

## Overview
Code structure anti-patterns are organizational and flow control mistakes that make AL code difficult to read, understand, and maintain. These patterns typically emerge from time pressure or lack of refactoring discipline.

## Key Concepts

### Copy-Paste Programming
**Problem:** Code duplication that multiplies maintenance effort and increases bug risk

Copy-paste programming occurs when developers duplicate similar logic instead of extracting reusable components:
- **Bug Multiplication** - Fixes must be applied in multiple places
- **Inconsistent Behavior** - Copied code diverges over time
- **Maintenance Overhead** - Changes require finding and updating all copies
- **Testing Complexity** - Each copy needs independent testing

### Nested IF-ELSE Pyramids (Pyramid of Doom)
**Problem:** Deep nesting that reduces readability and increases cognitive load

Pyramid of doom occurs when multiple nested conditions create deeply indented code:
- **Cognitive Overload** - Difficult to track multiple condition combinations
- **Error Prone** - Easy to miss edge cases in complex nesting
- **Hard to Test** - Exponential growth in test scenarios
- **Poor Readability** - Code becomes difficult to scan and understand

## Best Practices

### Extract Common Logic
When you find duplicated code:
- **Create Helper Methods** - Extract common logic into reusable procedures
- **Use Parameters** - Make extracted methods flexible with parameters
- **Apply DRY Principle** - "Don't Repeat Yourself" at the logic level
- **Create Utilities** - Build shared utility codeunits for cross-object logic

### Apply Guard Clauses
Instead of deep nesting, use early returns:
- **Validate Early** - Check prerequisites first and exit if not met
- **Fail Fast** - Return immediately when conditions aren't satisfied
- **Linear Flow** - Keep the main logic path at the top indentation level
- **Clear Intent** - Make error conditions explicit and obvious

### Use Boolean Logic Effectively
Simplify complex conditions:
- **Extract to Variables** - Give meaningful names to complex boolean expressions
- **Use Boolean Methods** - Create methods that return boolean values with descriptive names
- **Apply De Morgan's Laws** - Simplify negative conditions
- **Combine Related Conditions** - Group related validation logic

## Common Pitfalls

### "It's Just a Small Change"
Small duplications grow into large maintenance problems over time.

### "The Logic Is Almost the Same"
"Almost the same" often means the logic should be parameterized, not duplicated.

### "Nested IFs Are More Readable"
Deep nesting actually reduces readability by forcing readers to mentally track multiple condition combinations.

### "Guard Clauses Make Methods Longer"
Guard clauses reduce complexity even if they add lines; cognitive load is more important than line count.

## Related Topics
- [Object Design Anti-Patterns](object-design-anti-patterns.md)
- [Performance Anti-Patterns](performance-anti-patterns.md)
- [Error Handling Patterns](progressive-disclosure.md)
