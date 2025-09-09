---
title: "Specialized  Review Prompts"
description: "Specialized prompts for focused  review areas including performance, security, and error handling"
area: "testing"
difficulty: "intermediate"
object_types: ["Codeunit", "Table", "Page"]
variable_types: ["JsonObject", "ErrorInfo"]
tags: ["specialized-review", "performance-review", "security-review", "error-handling-review", "focused-analysis"]
---

# Specialized  Review Prompts

## Error Handling Focus
```
"Review the error handling in this AL  using patterns from bc-copilot-guidance/modern-al-patterns/modern-error-handling.md. Check for:
- ErrorInfo usage instead of generic Error() calls
- Suggested actions for user recovery
- Proper error con and messaging
- Telemetry integration"

[Paste your AL  here]
```

## Performance Review
```
"Analyze this AL  for performance issues, especially:
- Database query efficiency 
- Loop optimizations
- Memory usage patterns
- Transaction scope management

Reference performance patterns from bc-copilot-guidance/core-development/performance-optimization.md"

[Paste your AL  here]
```

## Security Review
```
"Review this AL  for security considerations:
- Data access permissions
- Input validation
- SQL injection prevention  
- Sensitive data handling

Cross-reference with security patterns from bc-copilot-guidance"

[Paste your AL  here]
```

## Upgrade Safety Review
```
"Check this  for upgrade and AppSource compliance using bc-copilot-guidance/modern-al-patterns/upgrade-lifecycle-management.md:
- Proper use of obsolete attributes
- Data migration safety
- Breaking change considerations
- Extension compatibility"

[Paste your AL  here]
```

## Con Enhancement Guidelines

### Make Prompts More Effective
- **Include business con:** "This is for customer invoice processing..."
- **Specify quality level:** "This needs to be production-ready for AppSource..."
- **Set scope boundaries:** "Focus on just the validation logic..."
- **Reference expertise:** "I'm experienced with AL but new to these patterns..."

### Always Include
```
"If you suggest changes, explain why each change improves the  and reference specific guidance from bc-copilot-guidance where applicable."
```

