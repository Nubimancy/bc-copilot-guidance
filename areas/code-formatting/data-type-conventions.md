---
title: "Data Type Conventions"
description: "AL data type standards and enum usage patterns"
area: "code-formatting"
difficulty: "intermediate"
object_types: ["Table", "Page", "Codeunit"]
variable_types: ["Enum", "Record"]
tags: ["data-types", "enums", "options", "conventions"]
---

# Data Type Conventions

## Overview

Proper data type selection is critical for maintainable, extensible AL code. This guide establishes standards for data type usage, with emphasis on modern enum patterns over deprecated option types.

## Key Concepts

### Enum-First Approach
Always use enums instead of the deprecated option data type for new development. Enums provide better extensibility, type safety, and code clarity.

### Option Type Deprecation
The option data type is deprecated and should only be used in specific legacy compatibility scenarios.

### Type Safety Standards
Choose data types that provide compile-time safety and clear semantic meaning for the data being represented.

## Best Practices

### Always Use Enums Instead of Options
```al
// Preferred: Use enum
enum 50100 "Document Status"
{
    Extensible = true;
    
    value(0; Open) { Caption = 'Open'; }
    value(1; "Pending Approval") { Caption = 'Pending Approval'; }
    value(2; Approved) { Caption = 'Approved'; }
    value(3; Rejected) { Caption = 'Rejected'; }
}
```

### Enum Design Principles
- **Always make extensible** unless there's a specific reason not to
- **Include blank value when appropriate** (`value(0; " ")`)
- **Use clear, descriptive captions**
- **Follow consistent value numbering**

### Acceptable Option Type Exceptions
Only two acceptable uses remain for option data types:

1. **Calling existing procedures with option parameters**
2. **Event subscribers with option parameters**

## Common Pitfalls

### Using Options for New Code
- **Wrong:** `Status: Option " ",Open,Approved,Rejected;`
- **Right:** `Status: Enum "Document Status";`

### Non-Extensible Enums
- **Wrong:** `enum 50100 "Status" { Extensible = false; }`
- **Right:** `enum 50100 "Status" { Extensible = true; }`

### Missing Blank Values
For optional enum fields, include a blank option:
- **Missing:** Starting directly with value(1; ...)
- **Right:** Starting with `value(0; " ") { Caption = ' '; }`

### Inconsistent Naming
- **Wrong:** Mixed caption styles (`open`, `Approved`, "pending approval"`)
- **Right:** Consistent PascalCase with proper spacing

## Related Topics

- Object Naming Conventions
- Code Structure Anti-Patterns  
- AL Extension Model Patterns
- AppSource Compliance Standards
