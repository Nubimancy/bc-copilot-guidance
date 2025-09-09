---
title: "Integration Event Patterns"
description: "Implementation patterns for AL integration events in Business Central extensions"
area: "integration"
difficulty: "intermediate"
object_types: ["Codeunit", "Table"]
variable_types: ["Record"]
tags: ["events", "integration", "extensibility", "before-after"]
---

# Integration Event Patterns

## Overview
Integration events provide extension points in standard Business Central objects, allowing custom code to hook into business processes without modifying the base application.

## Key Concepts

### Integration Event Types
- **OnBefore Events**: Execute before standard logic, allow modification
- **OnAfter Events**: Execute after standard logic, for additional processing
- **OnValidate Events**: Execute during field validation
- **OnInsert/OnModify/OnDelete Events**: Execute during record operations

### Event Declaration Patterns
- **Publisher**: Declares the event in the original codeunit/table
- **Subscriber**: Implements the event handler in extension code
- **Parameter Passing**: Handles data flow between publisher and subscriber

## Best Practices

### 1. Use OnBefore Events for Modification
- Modify field values or record data
- Add validation logic
- Prevent standard processing with error handling
- Pass modified data back via VAR parameters

### 2. Use OnAfter Events for Additional Processing
- Log operations or audit trails
- Send notifications or external updates
- Perform calculations based on completed operations
- Avoid modifying the original record context

### 3. Design for Extensibility
- Use meaningful parameter names
- Provide sufficient context in event parameters
- Consider future extension scenarios
- Document event purpose and usage

## Common Pitfalls

### ❌ Avoid These Anti-Patterns:
- Heavy processing in OnBefore events (performance impact)
- Modifying records in OnAfter events (data consistency issues)
- Generic parameter names without context
- Events without proper error handling

### ✅ Use These Patterns Instead:
- Lightweight validation in OnBefore events
- Separate processing logic in OnAfter events
- Descriptive parameter names with context
- Proper exception handling in event subscribers

## Related Topics
- [Business Event Patterns](business-event-patterns.md)
- [Event Design Principles](event-design-principles.md)
- [Event Testing Patterns](event-testing-patterns.md)
- [Event Driven Samples](event-driven-samples.md)
