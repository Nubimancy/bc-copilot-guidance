# Modern Error Handling Patterns ⚠️

**ErrorInfo, suggested actions, and user-friendly error management in AL development**

## ErrorInfo vs Traditional Error Handling

### Traditional Error Handling (Avoid)
```al
// ❌ Poor user experience - cryptic message
if Customer."Credit Limit" < Amount then
    Error('Credit limit exceeded');

// ❌ No actionable information
Customer.TestField("Payment Terms Code");

// ❌ Technical message exposed to users
if not HttpClient.Get(Url, Response) then
    Error('HTTP GET failed with status %1', Response.HttpStatusCode);
```

### Modern ErrorInfo Patterns (Use)
```al
// ✅ Rich, actionable error information
procedure ValidateCreditLimit(Customer: Record Customer; Amount: Decimal)
var
    CreditLimitError: ErrorInfo;
begin
    if Customer."Credit Limit" < Amount then begin
        CreditLimitError.Message := StrSubstNo('Credit limit of %1 exceeded. Requested amount: %2', 
                                              Customer."Credit Limit", Amount);
        CreditLimitError.DetailedMessage := 'The customer credit limit validation failed. Consider increasing the credit limit or reducing the order amount.';
        CreditLimitError.Verbosity := Verbosity::Normal;
        CreditLimitError.DataClassification := DataClassification::CustomerContent;
        
        // Add suggested actions
        CreditLimitError.AddAction('Increase Credit Limit', Codeunit::"Customer Credit Management", 'IncreaseCreditLimit');
        CreditLimitError.AddAction('Contact Credit Manager', Codeunit::"Customer Credit Management", 'ContactCreditManager');
        CreditLimitError.AddAction('Review Customer History', Codeunit::"Customer Credit Management", 'ReviewCustomerHistory');
        
        Error(CreditLimitError);
    end;
end;
```

## Progressive Error Disclosure

### User-Facing vs Technical Errors

```al
procedure ProcessPaymentWithGracefulHandling(PaymentData: Record "Payment Information")
var
    PaymentError: ErrorInfo;
    TechnicalDetails: Text;
begin
    if not TryProcessPayment(PaymentData) then begin
        TechnicalDetails := GetLastErrorText();
        
        // User-friendly message
        PaymentError.Message := 'Payment processing is temporarily unavailable.';
        
        // Technical details for administrators
        PaymentError.DetailedMessage := StrSubstNo('Payment gateway integration failed. Technical details: %1', TechnicalDetails);
        
        // Context for support
        PaymentError.CustomDimensions.Add('PaymentMethod', PaymentData."Payment Method");
        PaymentError.CustomDimensions.Add('Amount', Format(PaymentData.Amount));
        PaymentError.CustomDimensions.Add('Timestamp', Format(CurrentDateTime));
        
        // Actionable suggestions
        PaymentError.AddAction('Try Again', Codeunit::"Payment Processor", 'RetryPayment');
        PaymentError.AddAction('Use Different Payment Method', Codeunit::"Payment Processor", 'SelectAlternativeMethod');
        PaymentError.AddAction('Contact Support', Codeunit::"Payment Processor", 'ContactSupport');
        
        PaymentError.Verbosity := Verbosity::Normal;
        PaymentError.DataClassification := DataClassification::CustomerContent;
        
        Error(PaymentError);
    end;
end;
```

## Suggested Actions Pattern

### Action Implementation

```al
codeunit 50100 "Customer Credit Management"
{
    procedure IncreaseCreditLimit()
    var
        CustomerCard: Page "Customer Card";
        Customer: Record Customer;
    begin
        if Customer.Get(GetContextCustomerNo()) then begin
            Customer.SetRecFilter();
            CustomerCard.SetTableView(Customer);
            CustomerCard.RunModal();
        end;
    end;
    
    procedure ContactCreditManager()
    var
        EmailDialog: Page "Email Dialog";
        CreditManager: Text;
    begin
        CreditManager := GetCreditManagerEmail();
        if CreditManager <> '' then begin
            // Open email composition with pre-filled details
            EmailDialog.SetPredefinedContent(CreditManager, 
                'Credit Limit Review Required', 
                CreateCreditLimitEmailBody());
            EmailDialog.RunModal();
        end;
    end;
    
    procedure ReviewCustomerHistory()
    var
        CustomerLedgerEntries: Page "Customer Ledger Entries";
        Customer: Record Customer;
    begin
        if Customer.Get(GetContextCustomerNo()) then begin
            CustomerLedgerEntries.SetTableView(Customer);
            CustomerLedgerEntries.Run();
        end;
    end;
}
```

## Collectible Error Patterns

### Multiple Validation Errors

```al
procedure ValidateOrderData(var SalesHeader: Record "Sales Header")
var
    ValidationErrors: List of [ErrorInfo];
    ValidationError: ErrorInfo;
    CustomerValidation: Codeunit "Customer Validation";
    ItemValidation: Codeunit "Item Validation";
begin
    // Collect all validation errors instead of failing on first
    CollectCustomerValidationErrors(SalesHeader, ValidationErrors);
    CollectItemValidationErrors(SalesHeader, ValidationErrors);
    CollectPaymentValidationErrors(SalesHeader, ValidationErrors);
    
    if ValidationErrors.Count > 0 then begin
        // Create summary error with all issues
        ValidationError.Message := StrSubstNo('%1 validation errors found. Please review and correct:', ValidationErrors.Count);
        ValidationError.DetailedMessage := BuildValidationSummary(ValidationErrors);
        
        // Add actions to fix common issues
        ValidationError.AddAction('Open Customer Card', Codeunit::"Order Validation Actions", 'OpenCustomerCard');
        ValidationError.AddAction('Validate All Items', Codeunit::"Order Validation Actions", 'ValidateItems');
        ValidationError.AddAction('Review Order', Codeunit::"Order Validation Actions", 'ReviewOrder');
        
        ValidationError.Verbosity := Verbosity::Normal;
        ValidationError.DataClassification := DataClassification::CustomerContent;
        
        Error(ValidationError);
    end;
end;

local procedure CollectCustomerValidationErrors(SalesHeader: Record "Sales Header"; var ErrorList: List of [ErrorInfo])
var
    CustomerError: ErrorInfo;
    Customer: Record Customer;
begin
    if not Customer.Get(SalesHeader."Sell-to Customer No.") then begin
        CustomerError.Message := StrSubstNo('Customer %1 not found', SalesHeader."Sell-to Customer No.");
        CustomerError.DetailedMessage := 'The specified customer does not exist in the system.';
        ErrorList.Add(CustomerError);
    end else begin
        if Customer.Blocked <> Customer.Blocked::" " then begin
            CustomerError.Message := StrSubstNo('Customer %1 is blocked', Customer."No.");
            CustomerError.DetailedMessage := StrSubstNo('Customer is blocked with reason: %1', Customer.Blocked);
            ErrorList.Add(CustomerError);
        end;
    end;
end;
```

## Telemetry Integration

### Error Tracking for Continuous Improvement

```al
procedure LogErrorForTelemetry(ErrorInfo: ErrorInfo; Context: Text)
var
    TelemetryCustomDimensions: Dictionary of [Text, Text];
begin
    // Build telemetry context
    TelemetryCustomDimensions.Add('ErrorMessage', ErrorInfo.Message);
    TelemetryCustomDimensions.Add('ErrorVerbosity', Format(ErrorInfo.Verbosity));
    TelemetryCustomDimensions.Add('Context', Context);
    TelemetryCustomDimensions.Add('UserId', UserId);
    TelemetryCustomDimensions.Add('CompanyName', CompanyName);
    
    // Add custom dimensions from ErrorInfo
    if ErrorInfo.CustomDimensions.Count > 0 then
        foreach var Key in ErrorInfo.CustomDimensions.Keys do
            TelemetryCustomDimensions.Add(Key, ErrorInfo.CustomDimensions.Get(Key));
    
    // Log for analysis
    Session.LogMessage('ErrorOccurred', ErrorInfo.Message, Verbosity::Error,
                      DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher,
                      TelemetryCustomDimensions);
end;
```

## Context-Aware Error Messages

### Dynamic Error Context

```al
procedure ValidateInventoryWithContext(ItemNo: Code[20]; Quantity: Decimal; LocationCode: Code[10])
var
    Item: Record Item;
    ItemLedgerEntry: Record "Item Ledger Entry";
    InventoryError: ErrorInfo;
    AvailableQty: Decimal;
    Context: Text;
begin
    if not Item.Get(ItemNo) then begin
        InventoryError.Message := StrSubstNo('Item %1 not found', ItemNo);
        Error(InventoryError);
    end;
    
    Item.CalcFields(Inventory);
    AvailableQty := Item.Inventory;
    
    if AvailableQty < Quantity then begin
        // Build contextual error message
        Context := StrSubstNo('Available: %1, Requested: %2, Location: %3', 
                             AvailableQty, Quantity, LocationCode);
        
        InventoryError.Message := 'Insufficient inventory available';
        InventoryError.DetailedMessage := StrSubstNo('Cannot fulfill request for %1 units of item %2. %3', 
                                                     Quantity, ItemNo, Context);
        
        // Add context-specific actions
        if AvailableQty > 0 then
            InventoryError.AddAction('Reduce Quantity to Available', Codeunit::"Inventory Actions", 'ReduceToAvailable');
            
        InventoryError.AddAction('Check Other Locations', Codeunit::"Inventory Actions", 'CheckOtherLocations');
        InventoryError.AddAction('Create Purchase Order', Codeunit::"Inventory Actions", 'CreatePurchaseOrder');
        
        // Add telemetry context
        InventoryError.CustomDimensions.Add('ItemNo', ItemNo);
        InventoryError.CustomDimensions.Add('RequestedQty', Format(Quantity));
        InventoryError.CustomDimensions.Add('AvailableQty', Format(AvailableQty));
        InventoryError.CustomDimensions.Add('LocationCode', LocationCode);
        
        Error(InventoryError);
    end;
end;
```

## AI Prompting for Better Error Handling

### Effective Error Handling Prompts

```al
// Good prompts for Copilot:
"Create ErrorInfo with suggested actions for inventory validation failure"
"Convert this TestField call to use ErrorInfo with user-friendly message"
"Add telemetry logging to this error handling pattern"
"Create collectible validation errors for order processing"
```

### Error Message Improvement Prompts
```al
// Ask Copilot to improve error messages:
"Make this error message more user-friendly and actionable"
"Add suggested actions for this validation error"
"Convert this technical error to progressive disclosure pattern"
```

## Testing Error Handling

### Testing ErrorInfo Patterns

```al
[Test]
procedure TestCreditLimitErrorInfo()
var
    Customer: Record Customer;
    CreditValidator: Codeunit "Credit Limit Validator";
    ErrorInfo: ErrorInfo;
begin
    // Setup customer with limited credit
    Customer.Init();
    Customer."No." := 'TEST001';
    Customer."Credit Limit" := 1000;
    Customer.Insert();
    
    // Test error collection
    asserterror CreditValidator.ValidateCreditLimit(Customer, 1500);
    
    // Verify ErrorInfo was used (not basic Error)
    ErrorInfo := GetLastErrorObject();
    Assert.IsTrue(ErrorInfo.Message <> '', 'ErrorInfo message should be populated');
    Assert.IsTrue(ErrorInfo.DetailedMessage <> '', 'Detailed message should be provided');
    Assert.AreEqual(3, ErrorInfo.Actions.Count, 'Should have 3 suggested actions');
end;
```

## Error Handling Best Practices

### 1. Always Provide Context
```al
// ✅ Good - Provides business context
Error('Cannot post sales order %1 because customer %2 has exceeded credit limit of %3', 
      OrderNo, CustomerNo, CreditLimit);

// ❌ Avoid - Generic message
Error('Validation failed');
```

### 2. Include Recovery Actions
```al
// ✅ Good - Tells user what they can do
ErrorInfo.AddAction('Increase Credit Limit', Codeunit::Actions, 'IncreaseCreditLimit');
ErrorInfo.AddAction('Split Order', Codeunit::Actions, 'SplitOrder');

// ❌ Avoid - No guidance for resolution
Error('Credit limit exceeded');
```

### 3. Use Progressive Disclosure
```al
// ✅ Good - Simple message, detailed technical info available
ErrorInfo.Message := 'Payment processing failed';
ErrorInfo.DetailedMessage := 'Gateway returned HTTP 502: Bad Gateway. Connection timeout after 30 seconds.';
```

### 4. Add Telemetry for Analysis
```al
// ✅ Good - Track errors for improvement
ErrorInfo.CustomDimensions.Add('ErrorSource', 'PaymentProcessing');
ErrorInfo.CustomDimensions.Add('PaymentMethod', PaymentMethod);
LogErrorForTelemetry(ErrorInfo, 'Payment Gateway Integration');
```

---

**Modern error handling creates better user experiences and provides actionable guidance for problem resolution!** 🎯
