---
title: "Single Responsibility Principle in AL"
description: "Apply the Single Responsibility Principle (SRP) to AL development for better maintainability"
area: "architecture-design"
difficulty: "intermediate"
object_types: ["Codeunit", "Table", "Page"]
variable_types: ["Record"]
tags: ["solid-principles", "srp", "single-responsibility", "architecture", "best-practices"]
---

# Single Responsibility Principle in AL

The Single Responsibility Principle (SRP) states that a class should have only one reason to change. In AL development, this applies to all object types - each should have a single, well-defined purpose.

## Core Concept

Each AL object should have one responsibility and encapsulate only the functionality related to that responsibility. This makes code more maintainable, testable, and easier to understand.

## AL Application: One Purpose Per Object

### Codeunit Responsibilities

**✅ Good Example:**
```al
// Each codeunit has a single, clear responsibility
codeunit 50100 "Customer Validation"
{
    // Only handles customer data validation
    procedure ValidateCustomerData(var Customer: Record Customer): Boolean
    procedure ValidatePostingGroup(PostingGroupCode: Code[20]): Boolean  
    procedure ValidateVATRegistration(VATRegNo: Text[20]): Boolean
}

codeunit 50101 "Customer Notification"
{
    // Only handles customer notifications
    procedure SendWelcomeEmail(CustomerNo: Code[20])
    procedure SendPaymentReminder(CustomerNo: Code[20]; Amount: Decimal)
}
```

**❌ Avoid:**
```al
// Violates SRP - handles validation, notification, and reporting
codeunit 50100 "Customer Everything"
{
    procedure ValidateAndNotifyAndReport(var Customer: Record Customer)
    // Too many responsibilities in one place
}
```

### Table Responsibilities

Tables should focus on data structure and basic validation:

**✅ Good:**
```al
table 50100 "Customer Category"
{
    // Focused on customer categorization data
    fields
    {
        field(1; "Code"; Code[10]) { }
        field(2; "Description"; Text[50]) { }
        field(3; "Discount %"; Decimal) { }
    }
    
    // Only basic validation related to this data
    trigger OnInsert()
    begin
        TestField(Code);
        TestField(Description);
    end;
}
```

### Page Responsibilities

Pages should focus on presentation and basic user interaction:

**✅ Good:**
```al
page 50100 "Customer Category List"
{
    // Only responsible for displaying customer categories
    PageType = List;
    SourceTable = "Customer Category";
    
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; "Code") { }
                field("Description"; Description) { }
            }
        }
    }
}
```

## Benefits in AL Development

1. **Easier Maintenance**: Changes to one functionality don't affect others
2. **Better Testing**: Each object can be tested in isolation
3. **Improved Readability**: Clear purpose makes code self-documenting
4. **Reduced Coupling**: Objects depend on fewer other components

## AI Prompting for SRP

When working with AI assistants, use specific prompts that focus on single responsibilities:

```
// Instead of broad requests:
"Create a customer management system"

// Use specific, focused requests:
"Create a codeunit that only handles customer credit limit validation"
"Create a separate codeunit for customer email notifications"
"Create a table extension for storing customer preferences only"
```

## Common SRP Violations in AL

1. **Multi-purpose Codeunits**: Combining validation, processing, and reporting
2. **Overloaded Tables**: Adding fields that don't belong to the core entity
3. **Complex Pages**: Mixing data entry, validation, and business logic
4. **Helper Objects**: Utility objects that do "everything"

## Refactoring to SRP

When you identify SRP violations:

1. Identify distinct responsibilities
2. Create separate objects for each responsibility
3. Use dependency injection or events for communication
4. Update calling code to use the new structure

## Related Topics
- [Open-Closed Principle](open-closed-principle.md)
- [Interface Segregation Principle](interface-segregation-principle.md)
- [Dependency Inversion Principle](dependency-inversion-principle.md)
