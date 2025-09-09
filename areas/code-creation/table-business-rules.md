---
title: "Table Business Rules Enforcement"
description: "Advanced patterns for implementing business logic validation in AL tables"
area: "code-creation" 
difficulty: "intermediate"
object_types: ["Table"]
variable_types: ["Record", "RecordRef"]
tags: ["business-rules", "validation", "logic"]
---

# Table Business Rules Enforcement

## Overview
Business rules go beyond field validation to enforce complex organizational policies, cross-field validation, and data consistency requirements.

## Key Concepts

### Business Rule Categories
- **Data Consistency**: Ensuring related fields align properly
- **Business Policies**: Enforcing organizational rules and constraints
- **Workflow Rules**: Validation based on record state or process stage
- **Cross-Record Validation**: Rules that span multiple records or tables

### Implementation Patterns
- **OnInsert/OnModify/OnDelete**: Record-level validation triggers
- **Centralized Validation Procedures**: Reusable business rule enforcement
- **Conditional Validation**: Rules that apply under specific conditions

## Best Practices

### 1. Centralized Business Rule Validation
```al
local procedure ValidateBusinessRules()
begin
    ValidateRatingBusinessLogic();
    ValidateCustomerStatus();
    ValidateRatingHistory();
end;
```

### 2. Cross-Field Validation
- Validate field relationships and dependencies
- Ensure data consistency across related fields
- Implement conditional validation based on field states

### 3. State-Based Validation
- Different rules for different record states
- Workflow-aware validation logic
- Status-dependent field requirements

### 4. Performance-Conscious Validation
- Minimize database calls in validation
- Use SetLoadFields for selective data loading
- Cache frequently accessed validation data

## Common Pitfalls

### ❌ Avoid These Patterns:
- Validation logic scattered across multiple triggers
- Heavy database operations in validation procedures
- Inconsistent error message formatting
- Validation that doesn't account for record state

### ✅ Use These Patterns Instead:
- Centralized validation procedures
- Efficient data access patterns
- Consistent error handling and messaging
- Context-aware validation logic

## Related Topics
- [Table Field Validation](table-field-validation.md)
- [Table Design Patterns](table-design-patterns.md)
- [Table Validation Samples](table-validation-samples.md)
