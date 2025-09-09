---
title: "Dependency Inversion Principle in AL"
description: "Apply the Dependency Inversion Principle (DIP) to AL development with interfaces and dependency injection"
area: "architecture-design"
difficulty: "advanced"
object_types: ["Codeunit", "Interface"]
variable_types: ["Record", "Interface"]
tags: ["solid-principles", "dip", "dependency-inversion", "interfaces", "dependency-injection"]
---

# Dependency Inversion Principle in AL

The Dependency Inversion Principle (DIP) states that high-level modules should not depend on low-level modules. Both should depend on abstractions. Abstractions should not depend on details; details should depend on abstractions.

## Core Concept

Instead of depending directly on concrete implementations, depend on interfaces or abstractions. This makes code more flexible, testable, and maintainable.

## AL Application: Depend on Abstractions

### High-Level Modules Depending on Interfaces

**✅ Good Example:**
```al
// High-level module depends on abstraction
codeunit 50100 "Order Management"
{
    var
        PaymentProcessor: Interface "IPayment Processor";
        EmailSender: Interface "IEmail Sender";
        Logger: Interface "ILogger";
    
    procedure SetPaymentProcessor(NewProcessor: Interface "IPayment Processor")
    begin
        PaymentProcessor := NewProcessor;
    end;
    
    procedure SetEmailSender(NewSender: Interface "IEmail Sender")
    begin
        EmailSender := NewSender;
    end;
    
    procedure ProcessOrder(var SalesHeader: Record "Sales Header")
    begin
        Logger.LogInfo('Starting order processing');
        
        if PaymentProcessor.ProcessPayment(SalesHeader."Amount", SalesHeader."Sell-to Customer No.") then begin
            EmailSender.SendEmail(GetCustomerEmail(SalesHeader), 'Order Confirmed', 'Thank you!');
            Logger.LogInfo('Order processed successfully');
        end else begin
            Logger.LogError('Payment processing failed');
        end;
    end;
}

// Low-level modules implement abstractions
codeunit 50101 "Stripe Payment Processor" implements "IPayment Processor"
{
    procedure ProcessPayment(Amount: Decimal; CustomerNo: Code[20]): Boolean
    begin
        // Stripe-specific implementation
        exit(ProcessStripePayment(Amount, CustomerNo));
    end;
    
    local procedure ProcessStripePayment(Amount: Decimal; CustomerNo: Code[20]): Boolean
    begin
        // Implementation details
        exit(true);
    end;
}
```

**❌ Avoid:**
```al
// ❌ Bad: High-level module depends on concrete implementations
codeunit 50100 "Order Management"
{
    var
        StripePaymentProcessor: Codeunit "Stripe Payment Processor"; // Concrete dependency
        SMTPEmailSender: Codeunit "SMTP Email Sender"; // Concrete dependency
    
    procedure ProcessOrder(var SalesHeader: Record "Sales Header")
    begin
        // Tightly coupled to specific implementations
        if StripePaymentProcessor.ProcessStripePayment(SalesHeader."Amount") then
            SMTPEmailSender.SendSMTPEmail('confirmed', 'Thank you!');
    end;
}
```

## Interface Definitions

Define abstractions that both high and low-level modules depend on:

```al
interface "IPayment Processor"
{
    procedure ProcessPayment(Amount: Decimal; CustomerNo: Code[20]): Boolean;
    procedure ValidatePaymentData(Amount: Decimal; CustomerNo: Code[20]): Boolean;
    procedure GetLastTransactionId(): Text;
}

interface "IEmail Sender"
{
    procedure SendEmail(ToEmail: Text; Subject: Text; Body: Text): Boolean;
    procedure ValidateEmailAddress(Email: Text): Boolean;
}

interface "ILogger"
{
    procedure LogInfo(Message: Text);
    procedure LogWarning(Message: Text);
    procedure LogError(Message: Text);
}
```

## Dependency Injection Patterns

### Constructor Injection (via Setup Methods)
```al
codeunit 50100 "Document Processor"
{
    var
        Validator: Interface "IDocument Validator";
        Publisher: Interface "IDocument Publisher";
        Archiver: Interface "IDocument Archiver";
    
    procedure Initialize(NewValidator: Interface "IDocument Validator"; NewPublisher: Interface "IDocument Publisher"; NewArchiver: Interface "IDocument Archiver")
    begin
        Validator := NewValidator;
        Publisher := NewPublisher;
        Archiver := NewArchiver;
    end;
    
    procedure ProcessDocument(DocumentNo: Code[20])
    begin
        if Validator.ValidateDocument(DocumentNo) then begin
            Publisher.PublishDocument(DocumentNo);
            Archiver.ArchiveDocument(DocumentNo);
        end;
    end;
}
```

### Factory Pattern for Dependency Creation
```al
codeunit 50200 "Payment Processor Factory"
{
    procedure CreatePaymentProcessor(ProcessorType: Enum "Payment Processor Type"): Interface "IPayment Processor"
    var
        CreditCardProcessor: Codeunit "Credit Card Processor";
        BankTransferProcessor: Codeunit "Bank Transfer Processor";
        CashProcessor: Codeunit "Cash Processor";
    begin
        case ProcessorType of
            ProcessorType::"Credit Card":
                exit(CreditCardProcessor);
            ProcessorType::"Bank Transfer":
                exit(BankTransferProcessor);
            ProcessorType::Cash:
                exit(CashProcessor);
        end;
    end;
}
```

## Benefits in AL Development

1. **Testability**: Easy to inject mock implementations for testing
2. **Flexibility**: Different implementations can be used without code changes
3. **Loose Coupling**: High-level modules don't depend on implementation details
4. **Extensibility**: New implementations can be added without modifying existing code

## Common DIP Violations in AL

### 1. Direct Concrete Dependencies
```al
// ❌ Bad: Direct dependency on concrete class
codeunit 50100 "Report Generator"
{
    var
        SMTPMailer: Codeunit "SMTP Mailer"; // Concrete dependency
    
    procedure SendReport()
    begin
        SMTPMailer.SendMail('report@company.com', 'Report', 'Report attached');
    end;
}
```

### 2. Creating Dependencies Internally
```al
// ❌ Bad: Creating concrete dependencies internally
codeunit 50100 "Order Processor"
{
    procedure ProcessOrder()
    var
        PaymentProcessor: Codeunit "Credit Card Processor"; // Created internally
    begin
        // Cannot use different payment methods
        PaymentProcessor.ProcessPayment(100);
    end;
}
```

## Testing with Dependency Inversion

DIP makes testing much easier by allowing mock implementations:

```al
[Test]
procedure TestOrderProcessingWithMocks()
var
    OrderManagement: Codeunit "Order Management";
    MockPaymentProcessor: Codeunit "Mock Payment Processor";
    MockEmailSender: Codeunit "Mock Email Sender";
    SalesHeader: Record "Sales Header";
begin
    // Arrange: Inject mock dependencies
    OrderManagement.SetPaymentProcessor(MockPaymentProcessor);
    OrderManagement.SetEmailSender(MockEmailSender);
    
    // Act: Process order
    OrderManagement.ProcessOrder(SalesHeader);
    
    // Assert: Verify interactions with mocks
    Assert.IsTrue(MockPaymentProcessor.WasPaymentProcessed(), 'Payment should be processed');
    Assert.IsTrue(MockEmailSender.WasEmailSent(), 'Email should be sent');
end;
```

## Configuration and Setup

Use setup codeunits to configure dependencies:

```al
codeunit 50300 "Application Setup"
{
    procedure ConfigureOrderManagement(var OrderMgmt: Codeunit "Order Management")
    var
        PaymentFactory: Codeunit "Payment Processor Factory";
        EmailSender: Codeunit "SMTP Email Sender";
        Logger: Codeunit "File Logger";
    begin
        // Configure dependencies based on setup
        OrderMgmt.SetPaymentProcessor(PaymentFactory.CreatePaymentProcessor(GetPaymentProcessorType()));
        OrderMgmt.SetEmailSender(EmailSender);
        OrderMgmt.SetLogger(Logger);
    end;
    
    local procedure GetPaymentProcessorType(): Enum "Payment Processor Type"
    var
        Setup: Record "Payment Setup";
    begin
        Setup.Get();
        exit(Setup."Default Payment Processor");
    end;
}
```

## AI Prompting for DIP

When working with AI assistants:

```
// Good prompts for DIP compliance:
"Create interfaces for these dependencies and use dependency injection"
"Refactor this codeunit to depend on abstractions instead of concrete classes"
"Design a factory pattern for creating payment processor implementations"
"Show how to inject mock dependencies for testing this codeunit"
```

## Implementation Guidelines

1. **Identify Dependencies**: Look for direct references to concrete implementations
2. **Extract Interfaces**: Create abstractions for external dependencies
3. **Inject Dependencies**: Use constructor injection or setter methods
4. **Use Factories**: Create factories for complex dependency creation
5. **Test with Mocks**: Verify DIP compliance by testing with mock implementations

## Related Topics
- [Single Responsibility Principle](single-responsibility-principle.md)
- [Open-Closed Principle](open-closed-principle.md)
- [Liskov Substitution Principle](liskov-substitution-principle.md)
- [Interface Segregation Principle](interface-segregation-principle.md)
