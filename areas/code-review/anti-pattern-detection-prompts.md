---
title: "Anti-Pattern Detection Prompts for  Review"
description: "Specialized prompts for detecting and addressing anti-patterns in Business Central  reviews"
area: "testing"
difficulty: "intermediate"
object_types: ["Codeunit", "Table", "Page"]
variable_types: ["JsonObject"]
tags: ["anti-patterns", "-smells", "refactoring-prompts", "quality-assessment", "maintainability-review"]
---

# Anti-Pattern Detection Prompts

## Legacy Pattern Check
```
"Scan this AL  for anti-patterns listed in bc-copilot-guidance/modern-al-patterns/anti-patterns.md. Identify any:
- God objects or excessive complexity
- Copy-paste programming
- Magic numbers or hardd values
- Performance anti-patterns

Suggest modern alternatives for any issues found."

[Paste your AL  here]
```

##  Smell Detection
```
"Identify  smells in this AL  and suggest refactoring using patterns from bc-copilot-guidance:
- Long methods or complex conditionals
- Tight coupling or low cohesion
- Duplicate  or logic
- Poor naming or unclear intent"

[Paste your AL  here]
```

## Refactoring Opportunity Analysis
```
"Analyze this AL  for refactoring opportunities:
- Extract method candidates
- Class responsibility violations
- Interface segregation opportunities
- Dependency inversion improvements

Reference specific refactoring patterns from bc-copilot-guidance."

[Paste your AL  here]
```

## Maintainability Assessment
```
"Evaluate this 's maintainability:
-  complexity and readability
- Documentation adequacy
- Test coverage implications
- Future extension points

Suggest improvements for long-term maintainability."

[Paste your AL  here]
```

