---
title: "Common Prompt Patterns for Business Central AI"
description: "Reusable prompt templates and patterns for common Business Central development scenarios"
area: "ai-assistance"
difficulty: "beginner"
object_types: ["Table", "Codeunit", "Page", "Report"]
variable_types: []
tags: ["prompt-templates", "common-patterns", "development-scenarios", "ai-prompts", "reusable-templates"]
---

# Common Prompt Patterns

## For Object Creation
```
"Create a [Object Type] for [Business Purpose] following:
- Naming conventions: SharedGuidelines/Standards/naming-conventions.md
- Object patterns: CoreDevelopment/object-patterns.md
- Requirements from: .aidocs/implementation-plans/[plan-name].md
- Include [specific requirements]"
```

## For  Refactoring
```
"Refactor this [ type] to:
- Follow error handling patterns: SharedGuidelines/Standards/error-handling.md
- Apply performance optimizations: PerformanceOptimization/optimization-guide.md
- Meet the requirements in: .aidocs/implementation-plans/[plan-name].md
- Maintain compatibility with [existing features]"
```

## For Testing
```
"Create tests for [functionality] following:
- Testing strategy: TestingValidation/testing-strategy.md
- Test data patterns: TestingValidation/test-data-patterns.md
- Test scenarios from: .aidocs/implementation-plans/[plan-name].md
- Include [specific test cases]"
```

## For Documentation
```
"Generate documentation for [component] including:
- Technical specifications from: .aidocs/implementation-plans/[plan-name].md
- Usage examples following: SharedGuidelines/documentation-standards.md
- Integration points with [related systems]
- Maintenance and troubleshooting guidance"
```

## For Performance Analysis
```
"Analyze performance of [/process] considering:
- Performance patterns: PerformanceOptimization/optimization-guide.md
- Benchmarking requirements from: [specific requirements]
- Resource constraints: [memory/CPU/database limitations]
- Optimization opportunities: [specific areas to focus]"
```
