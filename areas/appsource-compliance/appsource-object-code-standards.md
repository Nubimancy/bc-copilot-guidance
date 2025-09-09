---
title: "AppSource Object and Code Standards"
description: "Object naming conventions, code quality standards, and compliance requirements for AppSource publishing"
area: "appsource-compliance"
difficulty: "intermediate"
object_types: ["Table", "Page", "Codeunit", "PermissionSet"]
variable_types: ["Record", "ErrorInfo"]
tags: ["appsource", "naming-conventions", "code-quality", "permissions", "compliance"]
---

# AppSource Object and Code Standards

## Object Naming Requirements

### Consistent Prefix Usage
All custom objects must use a consistent prefix to avoid conflicts with other extensions:

- **Tables**: `[PREFIX] Table Name` (e.g., "BRC Customer Loyalty Card")
- **Pages**: `[PREFIX] Page Name` (e.g., "BRC Customer Loyalty List")
- **Codeunits**: `[PREFIX] Codeunit Name` (e.g., "BRC Loyalty Management")
- **Reports**: `[PREFIX] Report Name` (e.g., "BRC Loyalty Points Report")

### Object ID Range Management
- Use assigned ID ranges from Partner Center
- Maintain consistent numbering within your range
- Document object ID assignments for team coordination
- Reserve ranges for future development

## Code Quality Standards

### Data Classification Requirements
Every field must have appropriate data classification:

```al
field(2; "Customer No."; Code[20])
{
    Caption = 'Customer No.';
    ToolTip = 'Specifies the customer associated with this loyalty card.';
    DataClassification = CustomerContent; // Required for AppSource
    TableRelation = Customer."No.";
}
```

### ToolTip Documentation
All fields and actions must include descriptive ToolTips:
- Explain the field's purpose and business context
- Provide guidance on proper values or formats
- Use consistent language and terminology
- Follow Microsoft's ToolTip guidelines

### Error Handling Standards

#### User-Friendly Error Messages
Replace generic errors with helpful, actionable messages:

```al
trigger OnValidate()
begin
    if not CustomerExists("Customer No.") then
        Error('Customer %1 does not exist. Please verify the customer number.', "Customer No.");
end;
```

#### ErrorInfo Implementation
For complex scenarios, use ErrorInfo for enhanced user experience:

```al
local procedure ValidateCardNumber()
var
    ErrorInfo: ErrorInfo;
begin
    if CardNumberExists("Card No.") then begin
        ErrorInfo.Title := 'Duplicate Card Number';
        ErrorInfo.Message := StrSubstNo('Card number %1 is already in use.', "Card No.");
        ErrorInfo.DetailedMessage := 'Each loyalty card must have a unique card number. Please choose a different number.';
        ErrorInfo.AddAction('Generate New Number', Codeunit::"Card Number Generator", 'GenerateUniqueNumber');
        Error(ErrorInfo);
    end;
end;
```

## Permission Set Compliance

### Assignable Permission Sets
Create properly structured permission sets for your functionality:

```al
permissionset 50100 "BRC LOYALTY MGT"
{
    Caption = 'Customer Loyalty Management';
    Assignable = true; // Required for AppSource extensions
    
    Permissions = 
        tabledata "BRC Customer Loyalty Card" = RIMD,
        tabledata "BRC Loyalty Transaction" = RIMD,
        table "BRC Customer Loyalty Card" = X,
        table "BRC Loyalty Transaction" = X,
        page "BRC Customer Loyalty Card" = X,
        page "BRC Customer Loyalty List" = X,
        codeunit "BRC Loyalty Management" = X;
}
```

### Permission Principles
- Grant minimum required permissions only
- Use descriptive permission set names and captions
- Group related permissions logically
- Test functionality with assigned permission sets only

## Validation and Testing Standards

### Input Validation
Implement comprehensive validation for all user inputs:

- **Range Validation**: Ensure numeric values are within acceptable ranges
- **Format Validation**: Verify text fields follow required patterns
- **Relationship Validation**: Check foreign key relationships exist
- **Business Rule Validation**: Enforce business logic constraints

### Performance Considerations
- Use SetLoadFields for large record sets
- Implement proper indexes for frequently queried fields
- Avoid unnecessary calculations in table triggers
- Use temporary tables for complex processing

## Code Organization Standards

### Procedure Documentation
Document all public procedures with XML comments:

```al
/// <summary>
/// Updates the loyalty points balance for a customer
/// </summary>
/// <param name="CustomerNo">The customer number to update</param>
/// <param name="PointsToAdd">Number of points to add (can be negative for deductions)</param>
/// <returns>True if update was successful</returns>
procedure UpdateLoyaltyPoints(CustomerNo: Code[20]; PointsToAdd: Integer): Boolean
```

### Consistent Formatting
- Use consistent indentation (4 spaces recommended)
- Follow AL language formatting conventions
- Use meaningful variable and procedure names
- Group related procedures together

### Error Handling Patterns
- Always validate input parameters
- Provide clear error messages with context
- Use consistent error handling patterns across the extension
- Log important errors for troubleshooting
