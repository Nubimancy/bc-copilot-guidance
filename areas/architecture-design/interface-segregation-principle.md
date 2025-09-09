---
title: "Interface Segregation Principle in AL"
description: "Apply the Interface Segregation Principle (ISP) to AL development with focused interfaces"
area: "architecture-design"
difficulty: "intermediate"
object_types: ["Interface", "Codeunit"]
variable_types: ["Record", ]
tags: ["solid-principles", "isp", "interface-segregation", "interfaces", "focused-design"]
---

# Interface Segregation Principle in AL

The Interface Segregation Principle (ISP) states that no client should be forced to depend on methods it does not use. In AL, this means creating small, focused interfaces rather than large, monolithic ones.

## Core Concept

Many specific interfaces are better than one general-purpose interface. Clients should only need to know about the methods that are of interest to them.

## AL Application: Focused Interfaces

### Small, Focused Interfaces

**✅ Good Example:**
```al
// Small, focused interfaces
interface "ICustomer Validator"
{
    procedure ValidateCustomer(var Customer: Record Customer): Boolean;
}

interface "IEmail Sender"  
{
    procedure SendEmail(ToEmail: Text; Subject: Text; Body: Text): Boolean;
}

interface "IReport Generator"
{
    procedure GenerateReport(ReportType: Text; Parameters: Text): Boolean;
}

// Implement only what you need
codeunit 50100 "Basic Customer Validator" implements "ICustomer Validator"
{
    procedure ValidateCustomer(var Customer: Record Customer): Boolean
    begin
        // Only validation logic needed
        exit(Customer."No." <> '');
    end;
}
```

**❌ Avoid:**
```al
// Fat interface forces unnecessary implementation
interface "ICustomer Everything"
{
    procedure ValidateCustomer(var Customer: Record Customer): Boolean;
    procedure SendEmail(ToEmail: Text; Subject: Text; Body: Text): Boolean;
    procedure GenerateReport(CustomerNo: Code[20]): Boolean;
    procedure ProcessPayment(Amount: Decimal): Boolean;
    procedure BackupData(): Boolean;
    procedure SendSMS(PhoneNo: Text; Message: Text): Boolean;
    // Too many unrelated methods
}
```

## Interface Composition

Instead of fat interfaces, compose multiple focused interfaces:

```al
// Focused interfaces that can be combined
interface "IValidation"
{
    procedure Validate(): Boolean;
    procedure GetValidationErrors(): List of [Text];
}

interface "IProcessing"
{
    procedure Process(): Boolean;
}

interface "INotification"
{
    procedure NotifySuccess();
    procedure NotifyFailure(ErrorMessage: Text);
}

// Compose interfaces as needed
codeunit 50100 "Order Processor" implements "IValidation", "IProcessing", "INotification"
{
    // Implement only relevant methods
}
```

## Benefits in AL Development

1. **Reduced Dependencies**: Objects only depend on methods they actually use
2. **Easier Implementation**: Smaller interfaces are easier to implement correctly
3. **Better Testing**: Focused interfaces can be mocked more easily
4. **Flexible Composition**: Mix and match interfaces as needed

## Common ISP Violations in AL

### 1. Kitchen Sink Interfaces
```al
// ❌ Bad: Too many unrelated responsibilities
interface "IBusinessObject"
{
    procedure Create(): Boolean;
    procedure Read(): Boolean;
    procedure Update(): Boolean;
    procedure Delete(): Boolean;
    procedure Validate(): Boolean;
    procedure SendEmail(): Boolean;
    procedure GenerateReport(): Boolean;
    procedure ProcessPayment(): Boolean;
    procedure BackupData(): Boolean;
}
```

### 2. Forcing Unused Methods
```al
// ❌ Bad: Read-only implementations forced to implement write methods
interface "IDataAccess"
{
    procedure ReadData(): Boolean;
    procedure WriteData(): Boolean;
    procedure DeleteData(): Boolean;
}

// Read-only implementation forced to implement unused methods
codeunit 50100 "Report Data Reader" implements "IDataAccess"
{
    procedure ReadData(): Boolean
    begin
        // Actual implementation
        exit(true);
    end;
    
    procedure WriteData(): Boolean
    begin
        // ❌ Forced to implement but not used
        Error('Write operations not supported');
    end;
    
    procedure DeleteData(): Boolean
    begin
        // ❌ Forced to implement but not used
        Error('Delete operations not supported');
    end;
}
```

## Refactoring to ISP Compliance

### Before: Fat Interface
```al
interface "IDocumentManager"
{
    procedure CreateDocument(): Boolean;
    procedure ValidateDocument(): Boolean;
    procedure PrintDocument(): Boolean;
    procedure EmailDocument(): Boolean;
    procedure ArchiveDocument(): Boolean;
}
```

### After: Segregated Interfaces
```al
interface "IDocumentCreator"
{
    procedure CreateDocument(): Boolean;
}

interface "IDocumentValidator"
{
    procedure ValidateDocument(): Boolean;
}

interface "IDocumentPublisher"
{
    procedure PrintDocument(): Boolean;
    procedure EmailDocument(): Boolean;
}

interface "IDocumentArchiver"
{
    procedure ArchiveDocument(): Boolean;
}
```

## Interface Design Guidelines

### 1. Single Purpose
Each interface should have one clear purpose:
```al
// ✅ Good: Single purpose
interface "IEmailValidator"
{
    procedure IsValidEmail(Email: Text): Boolean;
    procedure GetValidationMessage(): Text;
}
```

### 2. Client-Focused Design
Design interfaces based on client needs, not provider capabilities:
```al
// Design based on what clients need to do
interface "IOrderValidator"
{
    procedure ValidateOrderHeader(var SalesHeader: Record "Sales Header"): Boolean;
    procedure ValidateOrderLines(var SalesLine: Record "Sales Line"): Boolean;
}
```

### 3. Cohesive Methods
Group related methods together:
```al
// ✅ Good: Cohesive payment methods
interface "IPaymentProcessor"
{
    procedure ProcessPayment(Amount: Decimal): Boolean;
    procedure ValidatePaymentData(): Boolean;
    procedure GetTransactionId(): Text;
}
```

## Testing ISP Compliance

Create focused tests for each interface:
```al
[Test]
procedure TestEmailValidatorOnly()
var
    EmailValidator: Interface "IEmailValidator";
begin
    // Test only email validation functionality
    Assert.IsTrue(EmailValidator.IsValidEmail('test@example.com'), 'Should validate correct email');
    Assert.IsFalse(EmailValidator.IsValidEmail('invalid-email'), 'Should reject invalid email');
end;
```

## AI Prompting for ISP

When working with AI assistants:

```
// Good prompts for ISP compliance:
"Create focused interfaces for customer validation, avoiding unrelated methods"
"Split this large interface into smaller, single-purpose interfaces"
"Design an interface that only handles payment validation, not processing"
```

## Related Topics
- [Single Responsibility Principle](single-responsibility-principle.md)
- [Open-Closed Principle](open-closed-principle.md)
- [Liskov Substitution Principle](liskov-substitution-principle.md)
- [Dependency Inversion Principle](dependency-inversion-principle.md)
