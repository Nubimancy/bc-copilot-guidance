---
title: "Event Design Principles"
description: "Design principles and best practices for creating maintainable and extensible event-driven AL code"
area: "integration"
difficulty: "intermediate"
object_types: ["Codeunit"]
variable_types: ["Variant"]
tags: ["design", "principles", "extensibility", "maintainability"]
---

# Event Design Principles

## Overview
Well-designed events form the foundation of extensible and maintainable Business Central solutions. Following consistent design principles ensures events remain useful and stable over time.

## Key Concepts

### Event Design Goals
- **Discoverability**: Events are easy to find and understand
- **Usability**: Events provide sufficient context for subscribers
- **Stability**: Event signatures remain stable across versions
- **Performance**: Events don't negatively impact system performance

### Core Design Elements
- **Meaningful Names**: Clear, descriptive event names
- **Rich Context**: Comprehensive parameter information
- **Extensible Parameters**: Future-proof parameter design
- **Documentation**: Self-documenting code patterns

## Best Practices

### 1. Use Meaningful Event Names
- Follow consistent naming conventions
- Include business context in event names
- Use verb-noun patterns (OnValidateCustomer, OnProcessOrder)
- Avoid generic or technical-only names

### 2. Provide Rich Event Context
- Pass relevant business objects as parameters
- Include both primary and related data
- Consider what subscribers will need
- Use VAR parameters for data modification scenarios

### 3. Design for Extensibility
- Use flexible parameter types when appropriate
- Consider future enhancement scenarios
- Provide extension points at logical business boundaries
- Maintain backward compatibility

## Common Pitfalls

### ❌ Avoid These Anti-Patterns:
- Generic event names without business context
- Minimal parameters that require additional lookups
- Hard-coded parameter types that limit extensibility
- Events placed at inappropriate business boundaries

### ✅ Use These Patterns Instead:
- Descriptive, business-focused event names
- Comprehensive parameter sets with context
- Flexible parameter design for future needs
- Events at natural extension points

## Related Topics
- [Integration Event Patterns](integration-event-patterns.md)
- [Business Event Patterns](business-event-patterns.md)
- [Event Testing Patterns](event-testing-patterns.md)
- [Event Driven Samples](event-driven-samples.md)
