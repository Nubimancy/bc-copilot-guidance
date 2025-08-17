# Code Review Prompts 🔍

**Ready-to-use prompts for AI-assisted BC code review and quality assurance**

## Experience-Based Prompts

### For AI Beginners 🌱

#### Basic Code Review
```
"Please review this AL code and tell me if you see any obvious problems. Explain any issues in simple terms."

[Paste your AL code here]

Expected: Simple explanations of clear issues like missing error handling, magic numbers, etc.
```

#### Pattern Checking  
```
"Compare this code to the examples in bc-copilot-guidance/core-development and tell me what could be improved."

[Paste your AL code here]

Expected: Specific references to guidance docs with improvement suggestions.
```

### For AL Experts + AI Beginners 🔧

#### Advanced Code Review
```
"Review this AL code for compliance with modern BC development patterns. Focus on:
- SOLID principles adherence
- Error handling completeness  
- Performance considerations
- Extension/upgrade safety
Reference specific patterns from bc-copilot-guidance where applicable."

[Paste your AL code here]

Expected: Expert-level analysis with specific pattern references.
```

#### Architecture Assessment
```
"Analyze this codeunit design against the SOLID principles from bc-copilot-guidance/modern-al-patterns/solid-principles.md. Identify any violations and suggest refactoring approaches."

[Paste your codeunit code here]

Expected: SOLID principle analysis with refactoring suggestions.
```

### For AI Experts + BC Beginners 🚀

#### Learning-Focused Review
```
"I'm learning BC development. Review this AL code and:
1. Explain any BC-specific patterns I should understand
2. Reference relevant sections from bc-copilot-guidance for deeper learning
3. Highlight what I did well to reinforce good practices
4. Suggest one specific improvement with explanation"

[Paste your AL code here]

Expected: Educational review with learning resources and encouragement.
```

#### Best Practice Alignment
```
"Check this code against BC best practices and explain:
- Which patterns from bc-copilot-guidance it follows correctly
- What BC-specific considerations I might have missed
- How to improve it step-by-step"

[Paste your AL code here]

Expected: Educational analysis connecting code to documented patterns.
```

### For Experts in Both 🏗️

#### Comprehensive Analysis
```
"Perform a comprehensive code review focusing on:

**Architecture:** SOLID principles, separation of concerns, extensibility
**Quality:** Error handling, validation, defensive programming  
**Performance:** Query efficiency, memory usage, transaction scope
**Maintainability:** Code clarity, documentation, testability
**Compliance:** AppSource readiness, upgrade safety, security

Reference specific sections from bc-copilot-guidance and provide prioritized improvement recommendations."

[Paste your AL code here]

Expected: Expert-level comprehensive analysis with prioritized action items.
```

---

## Specialized Review Prompts

### Error Handling Focus
```
"Review the error handling in this AL code using patterns from bc-copilot-guidance/modern-al-patterns/modern-error-handling.md. Check for:
- ErrorInfo usage instead of generic Error() calls
- Suggested actions for user recovery
- Proper error context and messaging
- Telemetry integration"

[Paste your AL code here]
```

### Performance Review
```
"Analyze this AL code for performance issues, especially:
- Database query efficiency 
- Loop optimizations
- Memory usage patterns
- Transaction scope management

Reference performance patterns from bc-copilot-guidance/core-development/performance-optimization.md"

[Paste your AL code here]
```

### Security Review
```
"Review this AL code for security considerations:
- Data access permissions
- Input validation
- SQL injection prevention  
- Sensitive data handling

Cross-reference with security patterns from bc-copilot-guidance"

[Paste your AL code here]
```

### Upgrade Safety Review
```
"Check this code for upgrade and AppSource compliance using bc-copilot-guidance/modern-al-patterns/upgrade-lifecycle-management.md:
- Proper use of obsolete attributes
- Data migration safety
- Breaking change considerations
- Extension compatibility"

[Paste your AL code here]
```

---

## Anti-Pattern Detection Prompts

### Legacy Pattern Check
```
"Scan this AL code for anti-patterns listed in bc-copilot-guidance/modern-al-patterns/anti-patterns.md. Identify any:
- God objects or excessive complexity
- Copy-paste programming
- Magic numbers or hardcoded values
- Performance anti-patterns

Suggest modern alternatives for any issues found."

[Paste your AL code here]
```

### Code Smell Detection
```
"Identify code smells in this AL code and suggest refactoring using patterns from bc-copilot-guidance:
- Long methods or complex conditionals
- Tight coupling or low cohesion
- Duplicate code or logic
- Poor naming or unclear intent"

[Paste your AL code here]
```

---

## Progressive Prompts (Building Confidence)

### Level 1: Simple Issues
```
"Look for simple issues like:
- Missing field captions
- Inconsistent naming
- Basic validation gaps
- Simple syntax improvements"
```

### Level 2: Pattern Application  
```
"Check if this code follows basic patterns from bc-copilot-guidance:
- Proper data access patterns
- Basic error handling
- Simple business logic structure"
```

### Level 3: Architecture Review
```
"Evaluate architectural decisions:
- Component responsibilities
- Interface design
- Extension patterns
- Integration approaches"
```

### Level 4: Expert Analysis
```
"Comprehensive expert review covering all aspects of professional BC development quality"
```

---

## Context Enhancement Tips

### 🎯 **Make Prompts More Effective**
- **Include business context:** "This is for customer invoice processing..."
- **Specify quality level:** "This needs to be production-ready for AppSource..."
- **Set scope boundaries:** "Focus on just the validation logic..."
- **Reference expertise:** "I'm experienced with AL but new to these patterns..."

### 🔄 **Iterative Review Pattern**
1. **First pass:** "Quick review for obvious issues"
2. **Second pass:** "Deeper analysis of specific concerns"
3. **Final pass:** "Overall architecture and maintainability"

### 🛡️ **Always Include**
```
"If you suggest changes, explain why each change improves the code and reference specific guidance from bc-copilot-guidance where applicable."
```

---

**Remember:** The best code reviews combine AI efficiency with human business judgment. Use these prompts as starting points, but always validate suggestions against your specific requirements and context! 🎯
