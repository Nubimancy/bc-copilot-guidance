---
title: "Dependency Inversion Principle in AL - Code Samples"
description: "Complete code examples demonstrating Dependency Inversion Principle implementation in AL"
area: "architecture-design"
difficulty: "advanced"
object_types: ["Codeunit", "Interface", "Enum"]
variable_types: ["Record", "Interface"]
tags: ["solid-principles", "dip", "dependency-inversion", "interfaces", "dependency-injection", "samples"]
---

# Dependency Inversion Principle in AL - Code Samples

## High-Level Module with Interface Dependencies

```al
codeunit 50400 "Order Management System"
{
    /// <summary>
    /// High-level module that depends on abstractions, not concrete implementations
    /// Demonstrates proper dependency inversion
    /// </summary>
    
    var
        PaymentProcessor: Interface "IPayment Processor";
        EmailSender: Interface "IEmail Sender";
        Logger: Interface "ILogger";
        OrderValidator: Interface "IOrder Validator";
        InventoryChecker: Interface "IInventory Checker";
    
    // Dependency injection methods
    procedure SetPaymentProcessor(NewProcessor: Interface "IPayment Processor")
    begin
        PaymentProcessor := NewProcessor;
    end;
    
    procedure SetEmailSender(NewSender: Interface "IEmail Sender")
    begin
        EmailSender := NewSender;
    end;
    
    procedure SetLogger(NewLogger: Interface "ILogger")
    begin
        Logger := NewLogger;
    end;
    
    procedure SetOrderValidator(NewValidator: Interface "IOrder Validator")
    begin
        OrderValidator := NewValidator;
    end;
    
    procedure SetInventoryChecker(NewChecker: Interface "IInventory Checker")
    begin
        InventoryChecker := NewChecker;
    end;
    
    // Business logic that depends on abstractions
    procedure ProcessOrder(var SalesHeader: Record "Sales Header"): Boolean
    var
        Customer: Record Customer;
        OrderLines: Record "Sales Line";
        PaymentAmount: Decimal;
    begin
        Logger.LogInfo(StrSubstNo('Starting order processing for %1', SalesHeader."No."));
        
        // Validate order using injected validator
        if not OrderValidator.ValidateOrder(SalesHeader) then begin
            Logger.LogError(StrSubstNo('Order validation failed for %1', SalesHeader."No."));
            exit(false);
        end;
        
        // Check inventory using injected checker
        if not InventoryChecker.CheckInventoryAvailability(SalesHeader) then begin
            Logger.LogWarning(StrSubstNo('Insufficient inventory for order %1', SalesHeader."No."));
            SendInventoryWarningEmail(SalesHeader);
            exit(false);
        end;
        
        // Calculate payment amount
        SalesHeader.CalcFields("Amount Including VAT");
        PaymentAmount := SalesHeader."Amount Including VAT";
        
        // Process payment using injected processor
        if not PaymentProcessor.ProcessPayment(PaymentAmount, SalesHeader."Sell-to Customer No.") then begin
            Logger.LogError(StrSubstNo('Payment processing failed for order %1', SalesHeader."No."));
            SendPaymentFailureEmail(SalesHeader);
            exit(false);
        end;
        
        // Update order status
        SalesHeader.Status := SalesHeader.Status::Released;
        SalesHeader.Modify();
        
        // Send confirmation email using injected sender
        SendOrderConfirmationEmail(SalesHeader);
        
        Logger.LogInfo(StrSubstNo('Order %1 processed successfully', SalesHeader."No."));
        exit(true);
    end;
    
    procedure ProcessBulkOrders(var SalesHeaders: Record "Sales Header"): Integer
    var
        ProcessedCount: Integer;
        TotalCount: Integer;
    begin
        Logger.LogInfo('Starting bulk order processing');
        
        if SalesHeaders.FindSet() then begin
            repeat
                TotalCount += 1;
                if ProcessOrder(SalesHeaders) then
                    ProcessedCount += 1;
            until SalesHeaders.Next() = 0;
        end;
        
        Logger.LogInfo(StrSubstNo('Bulk processing completed: %1 of %2 orders processed', ProcessedCount, TotalCount));
        exit(ProcessedCount);
    end;
    
    local procedure SendOrderConfirmationEmail(SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        EmailBody: Text;
    begin
        if Customer.Get(SalesHeader."Sell-to Customer No.") then
            if Customer."E-Mail" <> '' then begin
                EmailBody := BuildOrderConfirmationBody(SalesHeader);
                EmailSender.SendEmail(Customer."E-Mail", 'Order Confirmation', EmailBody);
                Logger.LogInfo(StrSubstNo('Confirmation email sent for order %1', SalesHeader."No."));
            end;
    end;
    
    local procedure SendInventoryWarningEmail(SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        EmailBody: Text;
    begin
        if Customer.Get(SalesHeader."Sell-to Customer No.") then
            if Customer."E-Mail" <> '' then begin
                EmailBody := 'We apologize, but some items in your order are currently out of stock.';
                EmailSender.SendEmail(Customer."E-Mail", 'Order Status Update', EmailBody);
            end;
    end;
    
    local procedure SendPaymentFailureEmail(SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        EmailBody: Text;
    begin
        if Customer.Get(SalesHeader."Sell-to Customer No.") then
            if Customer."E-Mail" <> '' then begin
                EmailBody := 'There was an issue processing your payment. Please contact us to resolve this.';
                EmailSender.SendEmail(Customer."E-Mail", 'Payment Issue', EmailBody);
            end;
    end;
    
    local procedure BuildOrderConfirmationBody(SalesHeader: Record "Sales Header"): Text
    var
        EmailBuilder: TextBuilder;
    begin
        EmailBuilder.AppendLine(StrSubstNo('Your order %1 has been confirmed!', SalesHeader."No."));
        EmailBuilder.AppendLine(StrSubstNo('Order Date: %1', SalesHeader."Document Date"));
        SalesHeader.CalcFields("Amount Including VAT");
        EmailBuilder.AppendLine(StrSubstNo('Total Amount: %1', SalesHeader."Amount Including VAT"));
        EmailBuilder.AppendLine('Thank you for your business!');
        exit(EmailBuilder.ToText());
    end;
}
```

## Abstraction Interfaces

```al
interface "IPayment Processor"
{
    /// <summary>
    /// Payment processing abstraction
    /// High-level modules depend on this, not concrete implementations
    /// </summary>
    procedure ProcessPayment(Amount: Decimal; CustomerNo: Code[20]): Boolean;
    procedure ValidatePaymentData(Amount: Decimal; CustomerNo: Code[20]): Boolean;
    procedure GetLastTransactionId(): Text;
    procedure RefundPayment(TransactionId: Text; Amount: Decimal): Boolean;
}

interface "IEmail Sender"
{
    /// <summary>
    /// Email sending abstraction
    /// Allows different email implementations without changing business logic
    /// </summary>
    procedure SendEmail(ToEmail: Text; Subject: Text; Body: Text): Boolean;
    procedure SendEmailWithAttachment(ToEmail: Text; Subject: Text; Body: Text; AttachmentPath: Text): Boolean;
    procedure ValidateEmailAddress(Email: Text): Boolean;
}

interface "ILogger"
{
    /// <summary>
    /// Logging abstraction
    /// Business logic doesn't need to know how logging is implemented
    /// </summary>
    procedure LogInfo(Message: Text);
    procedure LogWarning(Message: Text);
    procedure LogError(Message: Text);
    procedure LogDebug(Message: Text);
}

interface "IOrder Validator"
{
    /// <summary>
    /// Order validation abstraction
    /// Allows different validation strategies
    /// </summary>
    procedure ValidateOrder(var SalesHeader: Record "Sales Header"): Boolean;
    procedure GetValidationErrors(): List of [Text];
    procedure ValidateOrderLines(var SalesLine: Record "Sales Line"): Boolean;
}

interface "IInventory Checker"
{
    /// <summary>
    /// Inventory checking abstraction
    /// Supports different inventory management systems
    /// </summary>
    procedure CheckInventoryAvailability(var SalesHeader: Record "Sales Header"): Boolean;
    procedure ReserveInventory(var SalesLine: Record "Sales Line"): Boolean;
    procedure ReleaseInventoryReservation(var SalesLine: Record "Sales Line"): Boolean;
}
```

## Low-Level Implementation Examples

```al
codeunit 50401 "Stripe Payment Processor" implements "IPayment Processor"
{
    /// <summary>
    /// Concrete implementation of payment processing for Stripe
    /// Low-level module that implements the abstraction
    /// </summary>
    
    var
        LastTransactionId: Text;
        StripeAPIClient: Codeunit "Stripe API Client";
    
    procedure ProcessPayment(Amount: Decimal; CustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
        PaymentToken: Text;
        StripeResponse: Text;
    begin
        if not ValidatePaymentData(Amount, CustomerNo) then
            exit(false);
            
        if not Customer.Get(CustomerNo) then
            exit(false);
            
        // Get payment token for customer
        PaymentToken := GetCustomerPaymentToken(CustomerNo);
        if PaymentToken = '' then
            exit(false);
            
        // Process payment through Stripe API
        StripeResponse := StripeAPIClient.CreateCharge(Amount, PaymentToken);
        LastTransactionId := ExtractTransactionIdFromResponse(StripeResponse);
        
        exit(LastTransactionId <> '');
    end;
    
    procedure ValidatePaymentData(Amount: Decimal; CustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
    begin
        if Amount <= 0 then
            exit(false);
            
        if not Customer.Get(CustomerNo) then
            exit(false);
            
        // Stripe-specific validation
        if Amount > 999999 then // Stripe limit
            exit(false);
            
        exit(true);
    end;
    
    procedure GetLastTransactionId(): Text
    begin
        exit(LastTransactionId);
    end;
    
    procedure RefundPayment(TransactionId: Text; Amount: Decimal): Boolean
    var
        RefundResponse: Text;
    begin
        RefundResponse := StripeAPIClient.CreateRefund(TransactionId, Amount);
        exit(RefundResponse <> '');
    end;
    
    local procedure GetCustomerPaymentToken(CustomerNo: Code[20]): Text
    var
        CustomerPaymentMethod: Record "Customer Payment Method";
    begin
        CustomerPaymentMethod.SetRange("Customer No.", CustomerNo);
        CustomerPaymentMethod.SetRange("Payment Method Type", CustomerPaymentMethod."Payment Method Type"::"Credit Card");
        if CustomerPaymentMethod.FindFirst() then
            exit(CustomerPaymentMethod."Payment Token");
        exit('');
    end;
    
    local procedure ExtractTransactionIdFromResponse(Response: Text): Text
    begin
        // Parse Stripe API response to extract transaction ID
        // Implementation would depend on actual API response format
        exit(StrSubstNo('stripe_%1', Random(999999)));
    end;
}

codeunit 50402 "PayPal Payment Processor" implements "IPayment Processor"
{
    /// <summary>
    /// Alternative implementation using PayPal
    /// Can be substituted without changing high-level business logic
    /// </summary>
    
    var
        LastTransactionId: Text;
        PayPalAPIClient: Codeunit "PayPal API Client";
    
    procedure ProcessPayment(Amount: Decimal; CustomerNo: Code[20]): Boolean
    var
        PayPalResponse: Text;
    begin
        if not ValidatePaymentData(Amount, CustomerNo) then
            exit(false);
            
        PayPalResponse := PayPalAPIClient.ExecutePayment(Amount, CustomerNo);
        LastTransactionId := ExtractPayPalTransactionId(PayPalResponse);
        
        exit(LastTransactionId <> '');
    end;
    
    procedure ValidatePaymentData(Amount: Decimal; CustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
    begin
        if Amount <= 0 then
            exit(false);
            
        if not Customer.Get(CustomerNo) then
            exit(false);
            
        // PayPal-specific validation (different limits than Stripe)
        if Amount > 10000 then // PayPal limit
            exit(false);
            
        exit(true);
    end;
    
    procedure GetLastTransactionId(): Text
    begin
        exit(LastTransactionId);
    end;
    
    procedure RefundPayment(TransactionId: Text; Amount: Decimal): Boolean
    var
        RefundResponse: Text;
    begin
        RefundResponse := PayPalAPIClient.RefundTransaction(TransactionId, Amount);
        exit(RefundResponse <> '');
    end;
    
    local procedure ExtractPayPalTransactionId(Response: Text): Text
    begin
        // Parse PayPal API response
        exit(StrSubstNo('paypal_%1', Random(999999)));
    end;
}
```

## Different Logging Implementations

```al
codeunit 50403 "File Logger" implements "ILogger"
{
    /// <summary>
    /// File-based logging implementation
    /// Business logic doesn't need to know about file handling
    /// </summary>
    
    var
        LogFilePath: Text;
    
    procedure Initialize(FilePath: Text)
    begin
        LogFilePath := FilePath;
    end;
    
    procedure LogInfo(Message: Text)
    begin
        WriteLogEntry('INFO', Message);
    end;
    
    procedure LogWarning(Message: Text)
    begin
        WriteLogEntry('WARN', Message);
    end;
    
    procedure LogError(Message: Text)
    begin
        WriteLogEntry('ERROR', Message);
    end;
    
    procedure LogDebug(Message: Text)
    begin
        WriteLogEntry('DEBUG', Message);
    end;
    
    local procedure WriteLogEntry(Level: Text; Message: Text)
    var
        LogEntry: Text;
        OutStream: OutStream;
        LogFile: File;
    begin
        LogEntry := StrSubstNo('%1 [%2] %3', Format(CurrentDateTime), Level, Message);
        
        // Write to log file
        LogFile.Create(LogFilePath);
        LogFile.CreateOutStream(OutStream);
        OutStream.WriteLine(LogEntry);
        LogFile.Close();
    end;
}

codeunit 50404 "Database Logger" implements "ILogger"
{
    /// <summary>
    /// Database-based logging implementation
    /// Alternative to file logging without changing business logic
    /// </summary>
    
    procedure LogInfo(Message: Text)
    begin
        CreateLogEntry('INFO', Message);
    end;
    
    procedure LogWarning(Message: Text)
    begin
        CreateLogEntry('WARN', Message);
    end;
    
    procedure LogError(Message: Text)
    begin
        CreateLogEntry('ERROR', Message);
    end;
    
    procedure LogDebug(Message: Text)
    begin
        CreateLogEntry('DEBUG', Message);
    end;
    
    local procedure CreateLogEntry(Level: Text; Message: Text)
    var
        LogEntry: Record "System Log Entry";
    begin
        LogEntry.Init();
        LogEntry."Entry No." := GetNextEntryNo();
        LogEntry."Log Level" := Level;
        LogEntry.Message := CopyStr(Message, 1, MaxStrLen(LogEntry.Message));
        LogEntry."Created DateTime" := CurrentDateTime;
        LogEntry."User ID" := UserId;
        LogEntry.Insert();
    end;
    
    local procedure GetNextEntryNo(): Integer
    var
        LogEntry: Record "System Log Entry";
    begin
        LogEntry.LockTable();
        if LogEntry.FindLast() then
            exit(LogEntry."Entry No." + 1);
        exit(1);
    end;
}
```

## Dependency Injection Container

```al
codeunit 50405 "Dependency Container"
{
    /// <summary>
    /// Container for managing dependency injection
    /// Centralizes configuration of implementations
    /// </summary>
    
    procedure ConfigureOrderManagementSystem(): Codeunit "Order Management System"
    var
        OrderManager: Codeunit "Order Management System";
        PaymentProcessorType: Enum "Payment Processor Type";
        LoggerType: Enum "Logger Type";
        EmailSenderType: Enum "Email Sender Type";
    begin
        // Get configuration from setup
        GetConfigurationSettings(PaymentProcessorType, LoggerType, EmailSenderType);
        
        // Configure dependencies based on settings
        OrderManager.SetPaymentProcessor(CreatePaymentProcessor(PaymentProcessorType));
        OrderManager.SetLogger(CreateLogger(LoggerType));
        OrderManager.SetEmailSender(CreateEmailSender(EmailSenderType));
        OrderManager.SetOrderValidator(CreateOrderValidator());
        OrderManager.SetInventoryChecker(CreateInventoryChecker());
        
        exit(OrderManager);
    end;
    
    local procedure CreatePaymentProcessor(ProcessorType: Enum "Payment Processor Type"): Interface "IPayment Processor"
    var
        StripeProcessor: Codeunit "Stripe Payment Processor";
        PayPalProcessor: Codeunit "PayPal Payment Processor";
        BankTransferProcessor: Codeunit "Bank Transfer Processor";
    begin
        case ProcessorType of
            ProcessorType::Stripe:
                exit(StripeProcessor);
            ProcessorType::PayPal:
                exit(PayPalProcessor);
            ProcessorType::"Bank Transfer":
                exit(BankTransferProcessor);
            else
                exit(StripeProcessor); // Default
        end;
    end;
    
    local procedure CreateLogger(LoggerType: Enum "Logger Type"): Interface "ILogger"
    var
        FileLogger: Codeunit "File Logger";
        DatabaseLogger: Codeunit "Database Logger";
        EventLogger: Codeunit "Event Logger";
    begin
        case LoggerType of
            LoggerType::File:
                exit(FileLogger);
            LoggerType::Database:
                exit(DatabaseLogger);
            LoggerType::EventLog:
                exit(EventLogger);
            else
                exit(DatabaseLogger); // Default
        end;
    end;
    
    local procedure CreateEmailSender(SenderType: Enum "Email Sender Type"): Interface "IEmail Sender"
    var
        SMTPSender: Codeunit "SMTP Email Sender";
        GraphSender: Codeunit "Microsoft Graph Email Sender";
        ExchangeSender: Codeunit "Exchange Email Sender";
    begin
        case SenderType of
            SenderType::SMTP:
                exit(SMTPSender);
            SenderType::"Microsoft Graph":
                exit(GraphSender);
            SenderType::Exchange:
                exit(ExchangeSender);
            else
                exit(SMTPSender); // Default
        end;
    end;
    
    local procedure CreateOrderValidator(): Interface "IOrder Validator"
    var
        StandardValidator: Codeunit "Standard Order Validator";
    begin
        exit(StandardValidator);
    end;
    
    local procedure CreateInventoryChecker(): Interface "IInventory Checker"
    var
        StandardChecker: Codeunit "Standard Inventory Checker";
    begin
        exit(StandardChecker);
    end;
    
    local procedure GetConfigurationSettings(var PaymentProcessorType: Enum "Payment Processor Type"; var LoggerType: Enum "Logger Type"; var EmailSenderType: Enum "Email Sender Type")
    var
        SystemSetup: Record "Order Processing Setup";
    begin
        if SystemSetup.Get() then begin
            PaymentProcessorType := SystemSetup."Payment Processor Type";
            LoggerType := SystemSetup."Logger Type";
            EmailSenderType := SystemSetup."Email Sender Type";
        end else begin
            // Default configuration
            PaymentProcessorType := PaymentProcessorType::Stripe;
            LoggerType := LoggerType::Database;
            EmailSenderType := EmailSenderType::SMTP;
        end;
    end;
}
```

## Usage Example with Dependency Injection

```al
codeunit 50406 "Order Processing Manager"
{
    /// <summary>
    /// Demonstrates how to use dependency-injected components
    /// High-level orchestration without concrete dependencies
    /// </summary>
    
    procedure ProcessOrdersForToday(): Integer
    var
        SalesHeader: Record "Sales Header";
        OrderManager: Codeunit "Order Management System";
        DependencyContainer: Codeunit "Dependency Container";
        ProcessedCount: Integer;
    begin
        // Get fully configured order management system
        OrderManager := DependencyContainer.ConfigureOrderManagementSystem();
        
        // Find today's orders
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("Document Date", Today);
        SalesHeader.SetRange(Status, SalesHeader.Status::Open);
        
        // Process orders using injected dependencies
        ProcessedCount := OrderManager.ProcessBulkOrders(SalesHeader);
        
        exit(ProcessedCount);
    end;
    
    procedure ProcessSpecificOrder(OrderNo: Code[20]): Boolean
    var
        SalesHeader: Record "Sales Header";
        OrderManager: Codeunit "Order Management System";
        DependencyContainer: Codeunit "Dependency Container";
    begin
        if not SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo) then
            exit(false);
            
        // Get configured system
        OrderManager := DependencyContainer.ConfigureOrderManagementSystem();
        
        // Process single order
        exit(OrderManager.ProcessOrder(SalesHeader));
    end;
}
```

## Testing with Mock Dependencies

```al
codeunit 50407 "Mock Payment Processor" implements "IPayment Processor"
{
    /// <summary>
    /// Mock implementation for testing
    /// Demonstrates how DIP enables easy testing
    /// </summary>
    
    var
        PaymentProcessed: Boolean;
        PaymentAmount: Decimal;
        CustomerNo: Code[20];
        ShouldFail: Boolean;
        LastTransactionId: Text;
    
    // Test setup methods
    procedure SetShouldFail(Fail: Boolean)
    begin
        ShouldFail := Fail;
    end;
    
    procedure GetPaymentDetails(var Amount: Decimal; var Customer: Code[20])
    begin
        Amount := PaymentAmount;
        Customer := CustomerNo;
    end;
    
    procedure WasPaymentProcessed(): Boolean
    begin
        exit(PaymentProcessed);
    end;
    
    // Interface implementation
    procedure ProcessPayment(Amount: Decimal; Customer: Code[20]): Boolean
    begin
        PaymentAmount := Amount;
        CustomerNo := Customer;
        PaymentProcessed := true;
        LastTransactionId := StrSubstNo('MOCK_%1', Random(9999));
        exit(not ShouldFail);
    end;
    
    procedure ValidatePaymentData(Amount: Decimal; Customer: Code[20]): Boolean
    begin
        exit((Amount > 0) and (Customer <> ''));
    end;
    
    procedure GetLastTransactionId(): Text
    begin
        exit(LastTransactionId);
    end;
    
    procedure RefundPayment(TransactionId: Text; Amount: Decimal): Boolean
    begin
        exit(not ShouldFail);
    end;
}

[Test]
codeunit 50408 "Order Management Tests"
{
    /// <summary>
    /// Tests demonstrating benefits of dependency inversion
    /// Easy to test because dependencies can be mocked
    /// </summary>
    
    [Test]
    procedure TestSuccessfulOrderProcessing()
    var
        OrderManager: Codeunit "Order Management System";
        MockPayment: Codeunit "Mock Payment Processor";
        MockEmail: Codeunit "Mock Email Sender";
        MockLogger: Codeunit "Mock Logger";
        MockValidator: Codeunit "Mock Order Validator";
        MockInventory: Codeunit "Mock Inventory Checker";
        SalesHeader: Record "Sales Header";
        ProcessedAmount: Decimal;
        ProcessedCustomer: Code[20];
    begin
        // Arrange: Set up mocks
        MockPayment.SetShouldFail(false);
        MockValidator.SetValidationResult(true);
        MockInventory.SetInventoryAvailable(true);
        
        // Inject mock dependencies
        OrderManager.SetPaymentProcessor(MockPayment);
        OrderManager.SetEmailSender(MockEmail);
        OrderManager.SetLogger(MockLogger);
        OrderManager.SetOrderValidator(MockValidator);
        OrderManager.SetInventoryChecker(MockInventory);
        
        // Create test order
        CreateTestOrder(SalesHeader);
        
        // Act: Process order
        Assert.IsTrue(OrderManager.ProcessOrder(SalesHeader), 'Order processing should succeed');
        
        // Assert: Verify interactions
        Assert.IsTrue(MockPayment.WasPaymentProcessed(), 'Payment should be processed');
        
        MockPayment.GetPaymentDetails(ProcessedAmount, ProcessedCustomer);
        SalesHeader.CalcFields("Amount Including VAT");
        Assert.AreEqual(SalesHeader."Amount Including VAT", ProcessedAmount, 'Payment amount should match order amount');
        Assert.AreEqual(SalesHeader."Sell-to Customer No.", ProcessedCustomer, 'Customer should match');
    end;
    
    [Test]
    procedure TestOrderProcessingWithPaymentFailure()
    var
        OrderManager: Codeunit "Order Management System";
        MockPayment: Codeunit "Mock Payment Processor";
        MockValidator: Codeunit "Mock Order Validator";
        MockInventory: Codeunit "Mock Inventory Checker";
        SalesHeader: Record "Sales Header";
    begin
        // Arrange: Set up payment to fail
        MockPayment.SetShouldFail(true);
        MockValidator.SetValidationResult(true);
        MockInventory.SetInventoryAvailable(true);
        
        // Inject dependencies
        OrderManager.SetPaymentProcessor(MockPayment);
        OrderManager.SetOrderValidator(MockValidator);
        OrderManager.SetInventoryChecker(MockInventory);
        
        CreateTestOrder(SalesHeader);
        
        // Act & Assert: Order processing should fail due to payment failure
        Assert.IsFalse(OrderManager.ProcessOrder(SalesHeader), 'Order processing should fail when payment fails');
    end;
    
    local procedure CreateTestOrder(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := 'TEST001';
        SalesHeader."Sell-to Customer No." := '10000';
        SalesHeader."Document Date" := Today;
        SalesHeader."Amount Including VAT" := 1000;
        // Additional test data setup as needed
    end;
}
```

## Related Topics
- [Dependency Inversion Principle](dependency-inversion-principle.md)
- [Single Responsibility Principle](single-responsibility-principle.md)
- [Interface Segregation Principle](interface-segregation-principle.md)
