---
title: "Experience-Based  Review Prompts"
description: " review prompts tailored to different experience levels with AI and Business Central development"
area: "testing"
difficulty: "beginner"
object_types: ["Codeunit", "Table", "Page"]
variable_types: ["JsonObject"]
tags: ["experience-based-prompts", "skill-level-adaptation", "beginner-friendly", "educational-review", "progressive-learning"]
---

# Experience-Based  Review Prompts

## For AI Beginners 🌱

### Basic  Review
```
"Please review this AL  and tell me if you see any obvious problems. Explain any issues in simple terms."

[Paste your AL  here]

Expected: Simple explanations of clear issues like missing error handling, magic numbers, etc.
```

### Pattern Checking  
```
"Compare this  to the examples in bc-copilot-guidance/core-development and tell me what could be improved."

[Paste your AL  here]

Expected: Specific references to guidance docs with improvement suggestions.
```

## For AL Experts + AI Beginners 🔧

### Advanced  Review
```
"Review this AL  for compliance with modern BC development patterns. Focus on:
- SOLID principles adherence
- Error handling completeness  
- Performance considerations
- Extension/upgrade safety
Reference specific patterns from bc-copilot-guidance where applicable."

[Paste your AL  here]

Expected: Expert-level analysis with specific pattern references.
```

### Architecture Assessment
```
"Analyze this unit design against the SOLID principles from bc-copilot-guidance/modern-al-patterns/solid-principles.md. Identify any violations and suggest refactoring approaches."

[Paste your unit  here]

Expected: SOLID principle analysis with refactoring suggestions.
```

## For AI Experts + BC Beginners 🚀

### Learning-Focused Review
```
"I'm learning BC development. Review this AL  and:
1. Explain any BC-specific patterns I should understand
2. Reference relevant sections from bc-copilot-guidance for deeper learning
3. Highlight what I did well to reinforce good practices
4. Suggest one specific improvement with explanation"

[Paste your AL  here]

Expected: Educational review with learning resources and encouragement.
```

### Best Practice Alignment
```
"Check this  against BC best practices and explain:
- Which patterns from bc-copilot-guidance it follows correctly
- What BC-specific considerations I might have missed
- How to improve it step-by-step"

[Paste your AL  here]

Expected: Educational analysis connecting  to documented patterns.
```

## For Experts in Both 🏗️

### Comprehensive Analysis
```
"Perform a comprehensive  review focusing on:

**Architecture:** SOLID principles, separation of concerns, extensibility
**Quality:** Error handling, validation, defensive programming  
**Performance:** Query efficiency, memory usage, transaction scope
**Maintainability:**  clarity, documentation, testability
**Compliance:** AppSource readiness, upgrade safety, security

Reference specific sections from bc-copilot-guidance and provide prioritized improvement recommendations."

[Paste your AL  here]

Expected: Expert-level comprehensive analysis with prioritized action items.
```

