---
title: "Code Optimization Patterns"
description: "AL performance optimization and clean code practices"
area: "code-formatting"
difficulty: "intermediate"
object_types: ["Table", "Codeunit", "Page"]
variable_types: ["Record", "RecordRef"]
tags: ["performance", "optimization", "clean-code", "variables"]
---

# Code Optimization Patterns

## Overview

Code optimization in AL involves both performance improvements and maintainability enhancements. This guide establishes patterns for efficient record processing, variable management, and performance-focused coding practices.

## Key Concepts

### Record Processing Optimization
Use efficient patterns for record iteration and data access to minimize database roundtrips and improve application performance.

### Variable Cleanup
Remove unused variables and organize variable declarations for better code maintainability and reduced memory usage.

### Performance-First Patterns
Structure code to minimize resource consumption while maintaining readability and functionality.

## Best Practices

### Efficient Record Iteration
Use FindSet() with Repeat-Until for looping through multiple records:
```al
if SalesLine.FindSet() then
    repeat
        // Process each record
    until SalesLine.Next() = 0;
```

### Pre-filtering Record Sets
Use SetRange/SetFilter before Find operations to limit record sets:
```al
Customer.SetRange("Country/Region Code", 'US');
Customer.SetRange("Customer Posting Group", 'RETAIL');
if Customer.FindSet() then
    // Process filtered records
```

### Variable Organization
- **Remove unused variables** completely from declarations
- **Order variables by complexity** (Record types first, then simple types)
- **Use meaningful names** that indicate purpose and scope

## Common Pitfalls

### Inefficient Record Processing
- **Wrong:** Using Find('-') and Next() for large record sets
- **Right:** Using FindSet() and repeat-until loops

### Unused Variable Declarations
- **Wrong:** Declaring variables that are never used in the code
- **Right:** Clean variable declarations with only necessary variables

### Unfiltered Database Access
- **Wrong:** Processing all records then filtering in code
- **Right:** Pre-filtering with SetRange/SetFilter before database access

### Nested Database Loops
- **Wrong:** Nested loops that cause N+1 query problems
- **Right:** Batch processing or temporary table patterns

## Related Topics

- Database Query Optimization
- SetLoadFields Basic Patterns
- Performance Anti-Patterns
- Bulk Processing Patterns
