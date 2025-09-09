---
title: "Comment-Driven Development Patterns"
description: "Using strategic comments to guide AI code generation and maintain development context in Business Central"
area: "code-creation"
difficulty: "intermediate"
object_types: ["Table", "Codeunit", "Page"]
variable_types: ["JsonObject", "JsonObject"]
tags: ["comment-driven-development", "code-generation", "ai-guidance", "development-context", "strategic-comments"]
---

# Comment-Driven Development Patterns

## Strategic Comments to Guide Copilot

Use comments to provide context and guide Copilot's suggestions:

```al
// Following SharedGuidelines/Standards/naming-conventions.md for field naming
// Implementing customer rewards calculation as specified in .aidocs/implementation-plans/rewards-calculation.md
// TODO: Add error handling per SharedGuidelines/Standards/error-handling.md patterns

table 50100 "BRC Customer Rewards"
{
    // Copilot will now understand context and follow our standards
    
    fields
    {
        // Customer identification following standard patterns
        field(1; "Customer No."; Code[20])
        {
            // Copilot will suggest proper properties based on context
        }
    }
}
```

## Comment Templates for Different Scenarios

**Object Creation:**
```al
// Creating [Object Type] following CoreDevelopment/object-patterns.md
// Business requirement: [Brief description from work item]
// Integration points: [External systems or APIs]
// Error handling: Apply SharedGuidelines/Standards/error-handling.md patterns
```

**Bug Fixes:**
```al
// Bug fix for ADO work item #[ID]: [Brief description]
// Root cause: [Identified issue]
// Solution approach: [How the fix works]
// Testing: Verify against scenarios in .aidocs/implementation-plans/[plan-name].md
```

**Feature Implementation:**
```al
// Feature implementation: [Feature name]
// Based on: .aidocs/implementation-plans/[plan-name].md
// Dependencies: [List key dependencies]
// Performance considerations: [Any specific requirements]
```

