---
title: "Code Documentation Standards"
description: "AL code documentation patterns for procedures, comments, and tooltips"
area: "code-formatting"
difficulty: "beginner"
object_types: ["Table", "Page", "Codeunit"]
variable_types: []
tags: ["documentation", "comments", "tooltips", "procedures"]
---

# Code Documentation Standards

## Overview

Comprehensive code documentation is essential for maintainable AL applications. This guide establishes standards for procedure documentation, inline comments, tooltips, and user-facing guidance.

## Key Concepts

### Procedure Documentation
Use XML documentation comments to describe procedure purpose, parameters, and return values for better IntelliSense and maintainability.

### User Interface Documentation
All fields, actions, and controls should have tooltips to provide context and guidance to users.

### Inline Comments
Add comments to explain complex business logic, unusual patterns, or important implementation decisions.

## Best Practices

### XML Procedure Documentation
Document all public procedures with XML comments:
```al
/// <summary>
/// Calculates the total amount for a sales document.
/// </summary>
/// <param name="DocumentType">The type of the sales document.</param>
/// <param name="DocumentNo">The number of the sales document.</param>
/// <returns>The total amount of the sales document.</returns>
procedure CalculateTotalAmount(DocumentType: Enum "Sales Document Type"; DocumentNo: Code[20]): Decimal
```

### Tooltip Standards
- **All fields should have tooltips** to provide context and guidance
- **Start field tooltips with 'Specifies'** for consistency
- **Use clear, non-technical language** that end users can understand
- **Keep tooltips concise but informative**
- **Avoid overly technical jargon**

### Business Logic Comments
Add comments to explain complex logic or business rules that aren't immediately obvious from the code structure.

## Common Pitfalls

### Missing Procedure Documentation
- **Wrong:** Procedures without XML documentation
- **Right:** All public procedures documented with `<summary>`, `<param>`, and `<returns>` tags

### Inconsistent Tooltip Format
- **Wrong:** "Customer number field" or "Enter customer"
- **Right:** "Specifies the customer number for this transaction"

### Redundant Comments
- **Wrong:** `CustomerNo := Customer."No."; // Set customer number`
- **Right:** Comments that explain WHY, not WHAT

### Technical Tooltips
- **Wrong:** "RecordRef for customer table access"
- **Right:** "Specifies which customer this record belongs to"

## Related Topics

- String Formatting Standards
- Localization Text Patterns
- User Experience Design Patterns
- AL Development Environment Setup
