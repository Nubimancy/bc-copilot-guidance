---
title: "Effective Prompt Writing Patterns for Business Central"
description: "Patterns and techniques for writing effective prompts to get optimal AI assistance in Business Central development"
area: "ai-assistance"
difficulty: "intermediate"
object_types: ["Table", "Codeunit", "Page"]
variable_types: []
tags: ["prompt-writing", "effective-prompts", "ai-education", "quality-prompts", "development-guidance"]
---

# Effective Prompt Writing Patterns

<!-- AI_TRIGGER: When developer writes prompts, proactively suggest prompting improvements and educational guidance -->
<!-- COPILOT_GUIDANCE: This guide teaches intelligent prompting with comprehensive educational patterns -->

## Writing Effective Prompts

### Good Prompts - Specific and Conual

**❌ Bad Examples:**
```
"Create a table"
"Fix this "
"Add tests"
```

**✅ Good Examples:**
```
"Create a Business Central table for Customer Rewards following our naming conventions in SharedGuidelines/Standards/naming-conventions.md, with fields for Customer No., Points Balance, and Tier Level"

"This AL unit violates our error handling patterns from SharedGuidelines/Standards/error-handling.md. Please refactor to use proper Error() calls and include user-friendly messages"

"Create unit tests for this Customer Rewards calculation following TestingValidation/testing-strategy.md, including boundary conditions and error scenarios"
```

## Prompt Quality Checklist

Before submitting a prompt, verify:

- [ ] **Specific Con**: References specific files, work items, or requirements
- [ ] **Standard References**: Mentions relevant guideline documents
- [ ] **Business Con**: Includes purpose and business requirements
- [ ] **Technical Requirements**: Specifies patterns, conventions, or constraints
- [ ] **Implementation Con**: References .aidocs plans if available
- [ ] **Quality Expectations**: Mentions testing, error handling, or performance needs

## Repository Con Integration

**Reference Specific Guideline Files:**
- "Following CoreDevelopment/object-patterns.md..."
- "According to SharedGuidelines/Standards/naming-conventions.md..."
- "Using the patterns from TestingValidation/testing-strategy.md..."

**Mention Implementation Plans:**
- "Based on .aidocs/implementation-plans/customer-rewards-feature.md..."
- "Following the technical analysis from .aidocs/implementation-plans/posting-bug-fix.md..."

**Include Business Con:**
- "For our Business Central AppSource extension that..."
- "In this customer-specific PTE that handles..."
- "For the loyalty points module described in..."
