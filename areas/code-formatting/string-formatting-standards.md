---
title: "String Formatting Standards"
description: "AL string formatting patterns using text constants and localization"
area: "code-formatting"
difficulty: "beginner"
object_types: ["Table", "Page", "Codeunit"]
variable_types: []
tags: ["strings", "formatting", "localization", "text-constants"]
---

# String Formatting Standards

## Overview

Proper string formatting is essential for maintainable, localizable AL code. This guide establishes standards for using text constants, placeholders, and formatting patterns that support internationalization.

## Key Concepts

### Text Constants Over Hard-coded Strings
Always use text constants for string formatting instead of hard-coded strings to support localization and maintainability.

### Placeholder-Based Formatting
Use numbered placeholders (%1, %2, etc.) in labels with StrSubstNo for dynamic string construction.

### Localization Support
All user-facing strings must use text constants or labels to enable localization for multiple markets.

## Best Practices

### Text Constant Declaration
Define text constants at the beginning of the object where they are used:
```al
var
    CustomerCreatedMsg: Label 'Customer %1 has been created.';
    ErrorMsg: Label 'Cannot delete %1 %2 because it has %3 entries.';
    TypeMismatchErr: Label 'Field type mismatch: %1 field cannot be mapped to %2 field.';
```

### String Formatting with StrSubstNo
Use StrSubstNo with text constants for dynamic strings:
```al
Message(CustomerCreatedMsg, Customer."No.");
ErrorMessage := StrSubstNo(TypeMismatchErr, Format(CustomFieldType), Format(TargetFieldType));
```

### Consistent Naming Conventions
Format text constant names with descriptive suffixes:
- **Error messages:** `ErrorMsg`, `TypeMismatchErr`
- **Confirmation dialogs:** `ConfirmQst`, `DeleteConfirmQst`  
- **Information messages:** `InfoMsg`, `ProcessingMsg`
- **Success messages:** `SuccessMsg`, `CompletedMsg`

## Common Pitfalls

### Hard-coded String Concatenation
- **Wrong:** `Message('Customer ' + Customer."No." + ' has been created.');`
- **Right:** `Message(CustomerCreatedMsg, Customer."No.");`

### Missing Placeholders
- **Wrong:** `ErrorMsg: Label 'Cannot delete item.';` (not dynamic)
- **Right:** `ErrorMsg: Label 'Cannot delete %1 %2 because it has %3 entries.';`

### Inconsistent Naming
- **Wrong:** Mixed naming (`Msg1`, `Error2`, `MessageText`)
- **Right:** Consistent patterns (`CustomerCreatedMsg`, `ItemDeletedMsg`)

### Direct String Usage
- **Wrong:** `if Confirm('Do you want to continue?') then`
- **Right:** `if Confirm(ContinueQst) then` (with `ContinueQst: Label 'Do you want to continue?';`)

## Related Topics

- Code Documentation Standards
- Localization Text Patterns
- Error Handling Principles
- AL Development Environment Setup
