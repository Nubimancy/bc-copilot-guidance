---
title: "Object Design Anti-Patterns"
description: "Common object design mistakes to avoid in AL development"
area: "architecture-design"
difficulty: "intermediate"
object_types: ["Codeunit", "Table", "Page"]
variable_types: ["Record", ]
tags: ["anti-patterns", "object-design", "god-objects", "magic-numbers", "solid-principles"]
---

# Object Design Anti-Patterns

## Overview
Object design anti-patterns are structural mistakes that violate fundamental design principles, making AL code harder to maintain, test, and extend. These patterns often emerge from rushing development or not applying proper separation of concerns.

## Key Concepts

### God Objects (Everything in One Place)
**Problem:** Violates Single Responsibility Principle, creates maintenance nightmares

God objects attempt to handle too many responsibilities in a single codeunit or table, making them extremely difficult to:
- **Maintain** - Changes in one area can break unrelated functionality
- **Test** - Too many dependencies and responsibilities to isolate
- **Understand** - Cognitive overload when trying to comprehend the object's purpose
- **Reuse** - Cannot use parts of the functionality without bringing everything

### Magic Numbers and Hardcoded Values
**Problem:** Reduces code readability and maintainability

Magic numbers are literal values that appear in code without explanation of their meaning:
- **Readability** - Other developers cannot understand the significance
- **Maintenance** - Changes require hunting through code for all occurrences
- **Testing** - Difficult to validate business rules when values are embedded
- **Flexibility** - Cannot adapt to changing business requirements

## Best Practices

### Apply Single Responsibility Principle
Each object should have one clear, focused responsibility:
- **Codeunits** - One business capability or utility function
- **Tables** - One business entity or configuration area
- **Pages** - One user interface concern or process

### Use Named Constants and Enums
Replace magic numbers and hardcoded strings with:
- **Constants** - For fixed values that might change
- **Enums** - For sets of related options
- **Configuration Tables** - For business-configurable values
- **Setup Records** - For system-wide settings

### Favor Composition Over Inheritance
Instead of creating large monolithic objects:
- **Break down** large objects into focused components
- **Compose** functionality by combining smaller objects
- **Delegate** responsibilities to appropriate specialized objects

## Common Pitfalls

### "It's Faster to Put Everything in One Place"
While initially faster, this approach creates exponential technical debt that slows future development.

### "The Business Logic Belongs Together"
Related business logic should be cohesive but not necessarily in the same object; use proper interfaces and dependencies.

### "Magic Numbers Are Self-Documenting"
Values like `10`, `50`, or `'ACTIVE'` are never self-documenting without context and explanation.

### "We Don't Have Time to Refactor"
Technical debt from god objects and magic numbers will eventually force much more expensive refactoring efforts.

## Related Topics
- [Code Structure Anti-Patterns](code-structure-anti-patterns.md)
- [Performance Anti-Patterns](performance-anti-patterns.md)
- [SOLID Principles](solid-single-responsibility.md)
