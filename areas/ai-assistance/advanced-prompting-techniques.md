---
title: "Advanced Prompting Techniques for Business Central AI"
description: "Advanced multi-step and contextual refinement techniques for effective AI prompting in Business Central development"
area: "ai-assistance"
difficulty: "advanced"
object_types: ["Codeunit", "Table", "Page"]
variable_types: ["JsonObject"]
tags: ["advanced-prompting", "multi-step-prompting", "contextual-refinement", "ai-techniques", "prompt-strategies"]
---

# Advanced Prompting Techniques

## Multi-Step Prompting

**Step 1 - Context Building:**
```
"I'm working on ADO work item #123 for customer loyalty points. Please review the requirements and help me understand what AL objects I'll need to create, referencing our patterns in CoreDevelopment/object-patterns.md"
```

**Step 2 - Implementation Planning:**
```
"Based on our discussion, help me create the implementation plan using .aidocs/templates/feature-implementation-plan.md, focusing on the table structure and business logic requirements"
```

**Step 3 - Code Generation:**
```
"Using the implementation plan we just created, generate the Customer Rewards table following our naming conventions and including proper error handling"
```

## Contextual Refinement

**Initial Request:**
```
"Create a posting routine for customer rewards points"
```

**Refined Request:**
```
"Create a posting routine for customer rewards points that follows our error handling patterns from SharedGuidelines/Standards/error-handling.md, integrates with the standard Business Central posting framework, and includes the validation logic specified in .aidocs/implementation-plans/loyalty-posting.md"
```

## Advanced Strategy Patterns

### Iterative Development Approach
1. **Context Establishment**: Build understanding through guided questions
2. **Requirements Clarification**: Refine specifications with technical constraints
3. **Implementation Guidance**: Generate code with full context awareness
4. **Quality Validation**: Review against established patterns and standards

### Context Layering Technique
- **Foundation Layer**: Business requirements and work item context
- **Technical Layer**: Development patterns and coding standards
- **Integration Layer**: System dependencies and external interfaces
- **Quality Layer**: Testing requirements and validation criteria

