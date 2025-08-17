---
applyTo: '**/*.al'
---

# Copilot Prompting Strategies - AI-Enhanced Prompting Education

<!-- AI_TRIGGER: When developer writes prompts, proactively suggest prompting improvements and educational guidance -->
<!-- COPILOT_GUIDANCE: This guide teaches intelligent prompting with comprehensive educational patterns -->

## How to Use This Guide with Copilot

<!-- AI_INSTRUCTION: When developers write prompts, proactively:
1. Suggest prompt improvements and enhanced context
2. Provide educational guidance on better prompting techniques
3. Recommend DevOps integration and quality considerations
4. Offer alternative prompting approaches for better results
-->

### Self-Improving Prompting Framework

<!-- PROMPT_EDUCATION: 
WEAK: "Help with prompting"
BETTER: "Teach me advanced prompting strategies for AL development with contextual examples, DevOps integration patterns, and progressive skill-building techniques"
EDUCATIONAL_NOTE: "Enhanced prompts for prompting guidance specify the domain (AL development), request examples (contextual), include workflow integration (DevOps patterns), and focus on learning (progressive skill-building). This creates a comprehensive prompting education experience."
-->

## Writing Effective Prompts

<!-- AI_TRIGGER: When showing prompt examples, suggest DevOps integration and quality considerations -->
<!-- PROACTIVE_SUGGEST: During prompting education -> Suggest comprehensive context and workflow integration -->

### Good Prompts - Specific and Contextual

**❌ Bad Examples:**
```
"Create a table"
"Fix this code"
"Add tests"
```

**✅ Good Examples:**
```
"Create a Business Central table for Customer Rewards following our naming conventions in SharedGuidelines/Standards/naming-conventions.md, with fields for Customer No., Points Balance, and Tier Level"

"This AL codeunit violates our error handling patterns from SharedGuidelines/Standards/error-handling.md. Please refactor to use proper Error() calls and include user-friendly messages"

"Create unit tests for this Customer Rewards calculation following TestingValidation/testing-strategy.md, including boundary conditions and error scenarios"
```

### Using Repository Context

**Reference Specific Guideline Files:**
- "Following CoreDevelopment/object-patterns.md..."
- "According to SharedGuidelines/Standards/naming-conventions.md..."
- "Using the patterns from TestingValidation/testing-strategy.md..."

**Mention Implementation Plans:**
- "Based on .aidocs/implementation-plans/customer-rewards-feature.md..."
- "Following the technical analysis from .aidocs/implementation-plans/posting-bug-fix.md..."

**Include Business Context:**
- "For our Business Central AppSource extension that..."
- "In this customer-specific PTE that handles..."
- "For the loyalty points module described in..."

## Leveraging .aidocs Templates

### Implementation Planning Prompts

**Feature Development:**
```
"Help me create a feature implementation plan using .aidocs/templates/feature-implementation-plan.md for [ADO Work Item #123]. I need to implement customer loyalty points tracking."
```

**Bug Fix Planning:**
```
"Using the bugfix template in .aidocs/templates/, help me plan the fix for the posting routine error described in ADO work item #456."
```

### Context-Rich Development

**Using Implementation Plans:**
```
"Based on the implementation plan in .aidocs/implementation-plans/loyalty-points-feature.md, generate the table structure for storing customer reward points, following our established patterns."

"Using the technical analysis from .aidocs/implementation-plans/posting-bug-fix.md, help me refactor this posting codeunit to handle the edge case identified."
```

## Comment-Driven Development

### Strategic Comments to Guide Copilot

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

### Comment Templates for Different Scenarios

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

## Advanced Prompting Techniques

### Multi-Step Prompting

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

### Contextual Refinement

**Initial Request:**
```
"Create a posting routine for customer rewards points"
```

**Refined Request:**
```
"Create a posting routine for customer rewards points that follows our error handling patterns from SharedGuidelines/Standards/error-handling.md, integrates with the standard Business Central posting framework, and includes the validation logic specified in .aidocs/implementation-plans/loyalty-posting.md"
```

## Common Prompt Patterns

### For Object Creation
```
"Create a [Object Type] for [Business Purpose] following:
- Naming conventions: SharedGuidelines/Standards/naming-conventions.md
- Object patterns: CoreDevelopment/object-patterns.md
- Requirements from: .aidocs/implementation-plans/[plan-name].md
- Include [specific requirements]"
```

### For Code Refactoring
```
"Refactor this [code type] to:
- Follow error handling patterns: SharedGuidelines/Standards/error-handling.md
- Apply performance optimizations: PerformanceOptimization/optimization-guide.md
- Meet the requirements in: .aidocs/implementation-plans/[plan-name].md
- Maintain compatibility with [existing features]"
```

### For Testing
```
"Create tests for [functionality] following:
- Testing strategy: TestingValidation/testing-strategy.md
- Test data patterns: TestingValidation/test-data-patterns.md
- Test scenarios from: .aidocs/implementation-plans/[plan-name].md
- Include [specific test cases]"
```

## Prompt Quality Checklist

Before submitting a prompt, verify:

- [ ] **Specific Context**: References specific files, work items, or requirements
- [ ] **Standard References**: Mentions relevant guideline documents
- [ ] **Business Context**: Includes purpose and business requirements
- [ ] **Technical Requirements**: Specifies patterns, conventions, or constraints
- [ ] **Implementation Context**: References .aidocs plans if available
- [ ] **Quality Expectations**: Mentions testing, error handling, or performance needs

## Integration with Development Workflow

### During Planning Phase
Use prompts to help create and refine implementation plans based on work item requirements.

### During Development Phase
Use prompts with implementation plan context to generate consistent, high-quality code.

### During Review Phase
Use prompts to help validate code against standards and identify potential improvements.

### During Testing Phase
Use prompts to generate comprehensive test cases and validate implementation completeness.
