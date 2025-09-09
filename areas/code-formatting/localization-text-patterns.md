---
title: "Localization Text Patterns"
description: "AL localization and multilingual text management patterns"
area: "code-formatting"
difficulty: "intermediate"
object_types: ["Table", "Page", "Codeunit"]
variable_types: []
tags: ["localization", "multilingual", "labels", "text-constants"]
---

# Localization Text Patterns

## Overview

Proper localization support is essential for global Business Central applications. This guide establishes patterns for text constants, labels, and multilingual content that enable seamless translation and cultural adaptation.

## Key Concepts

### Text Constants for User-Facing Content
All user-facing strings must use text constants or labels to support localization and enable translation into multiple languages.

### Consistent Label Naming
Use descriptive names for text constants that clearly indicate their purpose and usage context.

### StrSubstNo for Dynamic Content
Always use StrSubstNo with text constants for dynamic string construction to maintain localization compatibility.

## Best Practices

### Label Declaration Standards
Define text constants at the beginning of the object where they're used:
```al
var
    TypeMismatchErr: Label 'Field type mismatch: %1 field cannot be mapped to %2 field.';
    ProcessingMsg: Label 'Processing %1 records...';
    CompletedMsg: Label 'Process completed successfully. %1 records processed.';
```

### Format String Naming Conventions
Use consistent suffixes for different message types:
- **Error messages:** `Err` (e.g., `TypeMismatchErr`)
- **Confirmation questions:** `Qst` (e.g., `DeleteConfirmQst`)
- **Information messages:** `Msg` (e.g., `ProcessingMsg`)
- **Success messages:** `Msg` (e.g., `CompletedMsg`)

### Dynamic String Construction
Always use StrSubstNo with text constants for parameterized strings:
```al
ErrorMessage := StrSubstNo(TypeMismatchErr, Format(CustomFieldType), Format(TargetFieldType));
```

## Common Pitfalls

### Hard-coded User Strings
- **Wrong:** `Message('Customer created successfully');`
- **Right:** `Message(CustomerCreatedMsg);` with proper label declaration

### Direct String Concatenation
- **Wrong:** `Message('Error: ' + ErrorText);`
- **Right:** `Message(ErrorWithDetailsMsg, ErrorText);`

### Non-localizable Error Messages
- **Wrong:** Error messages embedded directly in code
- **Right:** All error messages defined as labels with proper parameters

### Missing Format Parameters
- **Wrong:** `Label 'Cannot process customer'` (not dynamic)
- **Right:** `Label 'Cannot process customer %1'` (supports dynamic content)

## Related Topics

- String Formatting Standards
- Code Documentation Standards
- Error Handling Principles
- User Experience Design Patterns
