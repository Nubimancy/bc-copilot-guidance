# SOLID Principles in AL Development 🔧

**Adapting SOLID principles for Business Central AL development constraints and capabilities**

## Single Responsibility Principle (SRP)

### AL Application: One Purpose Per Object

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

### AI Prompting for SRP
```
// When creating codeunits, use specific prompts:
"Create a codeunit that only handles customer credit limit validation"
"Create a separate codeunit for customer email notifications"
```

## Open/Closed Principle (OCP)

### AL Application: Extension Through Events

**✅ Good Example:**
```al
// Base codeunit is closed for modification, open for extension
codeunit 50100 "Sales Order Processing"
{
    procedure ProcessOrder(var SalesHeader: Record "Sales Header")
    begin
        ValidateOrderData(SalesHeader);
        OnBeforeProcessOrder(SalesHeader); // Extension point
        
        // Core processing logic
        CreateOrderEntries(SalesHeader);
        
        OnAfterProcessOrder(SalesHeader); // Extension point
    end;
    
    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessOrder(var SalesHeader: Record "Sales Header")
    begin
    end;
    
    [IntegrationEvent(false, false)]  
    local procedure OnAfterProcessOrder(var SalesHeader: Record "Sales Header")
    begin
    end;
}
```

**Extension Usage:**
```al
// Extend behavior without modifying original code
codeunit 50101 "Custom Order Processing"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Order Processing", 
                     'OnBeforeProcessOrder', '', false, false)]
    local procedure OnBeforeProcessOrder(var SalesHeader: Record "Sales Header")
    begin
        // Add custom validation or logic
        ValidateCustomBusinessRules(SalesHeader);
    end;
}
```

## Liskov Substitution Principle (LSP)

### AL Application: Interface Consistency

**✅ Good Example:**
```al
// Base interface defines contract
codeunit 50100 "Payment Processor" implements "IPayment Processor"
{
    procedure ProcessPayment(Amount: Decimal; CustomerNo: Code[20]): Boolean
    begin
        // Base implementation
        exit(true);
    end;
    
    procedure ValidatePayment(Amount: Decimal): Boolean  
    begin
        // Base validation
        exit(Amount > 0);
    end;
}

// Specialized implementations maintain interface contract
codeunit 50101 "Credit Card Processor" implements "IPayment Processor"
{
    procedure ProcessPayment(Amount: Decimal; CustomerNo: Code[20]): Boolean
    begin
        // Credit card specific processing
        // Still returns Boolean as expected
        exit(ProcessCreditCardPayment(Amount, CustomerNo));
    end;
    
    procedure ValidatePayment(Amount: Decimal): Boolean
    begin
        // Enhanced validation but maintains contract
        exit((Amount > 0) and (Amount <= GetCreditLimit(CustomerNo)));
    end;
}
```

## Interface Segregation Principle (ISP)

### AL Application: Focused Interfaces

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

// Implement only what you need
codeunit 50100 "Basic Customer Validator" implements "ICustomer Validator"
{
    procedure ValidateCustomer(var Customer: Record Customer): Boolean
    begin
        // Only validation logic needed
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
    // Too many unrelated methods
}
```

## Dependency Inversion Principle (DIP)

### AL Application: Depend on Abstractions

**✅ Good Example:**
```al
// High-level module depends on abstraction
codeunit 50100 "Order Management"
{
    var
        PaymentProcessor: Interface "IPayment Processor";
        EmailSender: Interface "IEmail Sender";
    
    procedure SetPaymentProcessor(NewProcessor: Interface "IPayment Processor")
    begin
        PaymentProcessor := NewProcessor;
    end;
    
    procedure ProcessOrder(var SalesHeader: Record "Sales Header")
    begin
        if PaymentProcessor.ProcessPayment(SalesHeader."Amount", SalesHeader."Sell-to Customer No.") then
            EmailSender.SendEmail(GetCustomerEmail(), 'Order Confirmed', 'Thank you!');
    end;
}

// Low-level modules implement abstractions
codeunit 50101 "Stripe Payment Processor" implements "IPayment Processor"
{
    procedure ProcessPayment(Amount: Decimal; CustomerNo: Code[20]): Boolean
    begin
        // Stripe-specific implementation
    end;
}
```

## AI Prompting for SOLID Code

### Effective Prompts for Better Architecture

```al
// Instead of: "Create a customer management system"
// Use: "Create a codeunit that only validates customer credit limits, 
//      with events for extensibility"

// Instead of: "Add payment processing to order management"  
// Use: "Create an interface for payment processing and implement 
//      dependency injection in the order management codeunit"
```

### Copilot Enhancement Patterns

**When working with existing code:**
1. Ask Copilot to identify SRP violations: "Does this codeunit have multiple responsibilities?"
2. Request interface extraction: "Extract an interface from this codeunit for better testability"
3. Suggest event points: "Where should I add integration events for extensibility?"

## Testing SOLID Code

**Benefits for Testing:**
```al
// SOLID code is inherently more testable
[Test]
procedure TestPaymentProcessing()
var
    OrderMgmt: Codeunit "Order Management";
    MockPaymentProcessor: Codeunit "Mock Payment Processor";
begin
    // Dependency injection makes testing easier
    OrderMgmt.SetPaymentProcessor(MockPaymentProcessor);
    
    // Test specific behavior without external dependencies
    OrderMgmt.ProcessOrder(SalesHeader);
    
    Assert.IsTrue(MockPaymentProcessor.WasPaymentProcessed(), 'Payment should be processed');
end;
```

## Implementation Guidelines

### Start Small
1. **Begin with SRP** - Make each object do one thing well
2. **Add Events** - Enable extension points in core logic
3. **Extract Interfaces** - Create contracts for key abstractions
4. **Use Dependency Injection** - Make dependencies explicit and testable

### AI-Assisted Refactoring
- Use Copilot to identify code smells and suggest SOLID improvements
- Ask for interface extraction from existing codeunits
- Request event-driven refactoring suggestions
- Generate test code that validates SOLID principles

---

**Remember: SOLID principles make AL code more maintainable, testable, and extensible - perfect for modern Business Central development!** 🚀
