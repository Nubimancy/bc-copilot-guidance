---
title: "Prompt Workflow Integration"
description: "Integration of AI prompting with Business Central development workflow phases and processes"
area: "project-workflow"
difficulty: "intermediate"
object_types: ["Codeunit", "Table", "Page"]
variable_types: ["JsonObject", "JsonObject"]
tags: ["workflow-integration", "prompt-integration", "development-phases", "ai-workflow", "process-automation"]
---

# Prompt Workflow Integration

## Integration with Development Workflow

### During Planning Phase
Use prompts to help create and refine implementation plans based on work item requirements.

**Planning Phase Prompts:**
```
"Help me break down ADO work item #[ID] into technical tasks, referencing our development patterns and identifying dependencies"

"Create an implementation plan for [feature] that considers our architecture patterns and integration requirements"
```

### During Development Phase
Use prompts with implementation plan context to generate consistent, high-quality code.

**Development Phase Prompts:**
```
"Generate the [object type] based on the implementation plan in .aidocs/implementation-plans/[plan-name].md"

"Implement the business logic for [feature] following the technical design and our coding standards"
```

### During Review Phase
Use prompts to help validate code against standards and identify potential improvements.

**Review Phase Prompts:**
```
"Review this code against our standards in SharedGuidelines/Standards/ and suggest improvements"

"Validate this implementation against the requirements in .aidocs/implementation-plans/[plan-name].md"
```

### During Testing Phase
Use prompts to generate comprehensive test cases and validate implementation completeness.

**Testing Phase Prompts:**
```
"Generate test cases for [functionality] covering the scenarios defined in the implementation plan"

"Create automated tests following TestingValidation/testing-strategy.md for this implementation"
```

## Workflow-Specific Context Building

### Pre-Development Context
- Work item requirements and acceptance criteria
- Technical constraints and dependencies
- Architecture and design decisions
- Performance and quality requirements

### Development Context
- Implementation plan specifications
- Coding standards and patterns
- Integration requirements
- Error handling and validation needs

### Post-Development Context
- Testing requirements and scenarios
- Documentation and maintenance needs
- Deployment and configuration considerations
- Monitoring and troubleshooting requirements

