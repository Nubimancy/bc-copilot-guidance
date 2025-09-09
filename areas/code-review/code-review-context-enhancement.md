---
title: "Code Review Context Enhancement"
description: "Techniques for enhancing context and effectiveness in AI-assisted Business Central code reviews"
area: "testing"
difficulty: "intermediate"
object_types: ["Codeunit", "Table", "Page"]
variable_types: ["JsonObject", "JsonObject"]
tags: ["context-enhancement", "review-effectiveness", "iterative-review", "prompt-improvement", "quality-context"]
---

# Code Review Context Enhancement

## Make Prompts More Effective 🎯

### Business Context Integration
- **Include business context:** "This is for customer invoice processing..."
- **Specify quality level:** "This needs to be production-ready for AppSource..."
- **Set scope boundaries:** "Focus on just the validation logic..."
- **Reference expertise:** "I'm experienced with AL but new to these patterns..."

### Context Specification Patterns
```
"Review this [specific component type] for [business domain] considering:
- Business requirements: [specific requirements]
- Quality expectations: [production/development/prototype]
- Technical constraints: [performance/memory/integration]
- Team expertise: [skill levels and knowledge gaps]"
```

## Iterative Review Pattern 🔄

### Three-Pass Approach
1. **First pass:** "Quick review for obvious issues"
   - Syntax errors and basic violations
   - Simple naming and structure issues
   - Clear best practice violations

2. **Second pass:** "Deeper analysis of specific concerns"
   - Pattern compliance and architectural decisions
   - Performance and security considerations
   - Business logic correctness

3. **Final pass:** "Overall architecture and maintainability"
   - Long-term maintainability assessment
   - Extension and upgrade considerations
   - Documentation and testing adequacy

## Always Include Guidelines 🛡️

### Standard Review Footer
```
"If you suggest changes, explain why each change improves the code and reference specific guidance from bc-copilot-guidance where applicable."
```

### Quality Assurance Reminder
```
"Focus on actionable improvements that enhance:
- Code maintainability and readability
- Performance and security
- Compliance with established patterns
- Long-term extensibility and upgrade safety"
```

## Context Templates

### For New Team Members
```
"I'm new to [BC/AL/this codebase]. Please explain your suggestions in educational terms and reference learning resources where appropriate."
```

### For Legacy Code Review
```
"This is legacy code that needs modernization. Focus on incremental improvements that don't require major architectural changes."
```

### For AppSource Preparation
```
"This code needs to meet AppSource technical validation requirements. Please check against AppSource compliance patterns."
```

