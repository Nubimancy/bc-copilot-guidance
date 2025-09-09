---
title: "Table Field Validation Patterns"
description: "Essential patterns for field-level validation in AL tables"
area: "code-creation"
difficulty: "beginner"
object_types: ["Table"]
variable_types: ["Record"]
tags: ["validation", "fields", "data-integrity"]
---

# Table Field Validation Patterns

## Overview
Field-level validation ensures data integrity at the database level through proper field definitions, constraints, and validation triggers.

## Key Concepts

### Field Properties for Validation
- **NotBlank**: Prevents empty values for required fields
- **MinValue/MaxValue**: Numeric range validation
- **TableRelation**: Enforces referential integrity
- **DataClassification**: Proper data handling compliance

### Validation Triggers
- **OnValidate()**: Executes when field value changes
- **OnLookup()**: Custom lookup behavior
- **OnAssistEdit()**: Custom assistance functionality

## Best Practices

### 1. Use Declarative Validation First
```al
field(2; "Rating Score"; Integer)
{
    Caption = 'Rating Score';
    ToolTip = 'Specifies the rating score from 1 to 5.';
    DataClassification = CustomerContent;
    MinValue = 1;           // Declarative range validation
    MaxValue = 5;
}
```

### 2. Implement Custom Validation Procedures
```al
local procedure ValidateCustomerExists()
var
    Customer: Record Customer;
begin
    if "Customer No." <> '' then begin
        if not Customer.Get("Customer No.") then
            Error('Customer %1 does not exist.', "Customer No.");
    end;
end;
```

### 3. Meaningful Field Captions and ToolTips
- **Caption**: User-friendly field name
- **ToolTip**: Starts with "Specifies" and explains field purpose
- **DataClassification**: Required for privacy compliance

## Common Pitfalls

### ❌ Avoid These Patterns:
- Missing NotBlank on required fields
- Generic error messages without context
- Complex validation logic directly in OnValidate()
- Missing DataClassification properties

### ✅ Use These Patterns Instead:
- Dedicated validation procedures for complex logic
- Descriptive error messages with field values
- Proper field constraints using built-in properties
- Complete metadata (Caption, ToolTip, DataClassification)

## Related Topics
- [Table Business Rules](table-business-rules.md)
- [Table Design Patterns](table-design-patterns.md)
- [Table Validation Samples](table-validation-samples.md)
