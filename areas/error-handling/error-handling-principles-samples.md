---
title: "Error Handling Principles - Code Samples"
description: "Code examples demonstrating core error handling principles in AL"
area: "error-handling"
difficulty: "beginner"
object_types: ["Codeunit", "Table", "Page"]
variable_types: ["ErrorInfo"]
tags: ["error-handling", "principles", "samples", "best-practices"]
---

# Error Handling Principles - Code Samples

## Principle 1: Provide Actionable Information

### ❌ Poor Error Messages (Avoid)

```al
// Cryptic message with no context
if Customer."Credit Limit" < Amount then
    Error('Credit limit exceeded');

// No actionable information
Customer.TestField("Payment Terms Code");

// Technical details exposed to end users
if not HttpClient.Get(Url, Response) then
    Error('HTTP GET failed with status %1', Response.HttpStatusCode);

// Vague validation error
if Customer.Name = '' then
    Error('Invalid customer');
```

### ✅ Clear, Actionable Error Messages (Use)

```al
// Contextual business message with specific values
if Customer."Credit Limit" < Amount then
    Error('Credit limit of %1 exceeded. Requested amount: %2. Please reduce the order amount or contact your administrator to increase the credit limit.', 
          Customer."Credit Limit", Amount);

// Helpful field validation
if Customer."Payment Terms Code" = '' then
    Error('Payment Terms Code is required. Please select a payment term from the dropdown or contact your administrator to set up payment terms.');

// User-friendly API error
if not HttpClient.Get(Url, Response) then
    Error('Unable to connect to the external service. Please check your internet connection or contact your system administrator if the problem persists.');

// Specific validation guidance
if Customer.Name = '' then
    Error('Customer Name is required. Please enter a name for this customer before saving.');
```

## Principle 2: Use Appropriate AL Mechanisms

### Error for Critical Failures

```al
procedure ValidateOrderAmount(SalesHeader: Record "Sales Header")
begin
    // Stop processing - critical business rule violation
    if SalesHeader."Total Amount" > SalesHeader."Credit Limit" then
        Error('Order amount %1 exceeds credit limit %2. Cannot process the order.', 
              SalesHeader."Total Amount", SalesHeader."Credit Limit");
end;
```

### Message for Information

```al
procedure ProcessPayment(PaymentAmount: Decimal)
begin
    // Informational - processing continues
    if PaymentAmount > 10000 then
        Message('Large payment of %1 has been processed and will require manager approval.', PaymentAmount);
        
    // Continue with payment processing...
end;
```

### Confirm for User Decisions

```al
procedure DeleteCustomer(Customer: Record Customer)
begin
    // User choice required before destructive action
    if not Confirm('Are you sure you want to delete customer %1? This action cannot be undone.', Customer.Name) then
        exit;
        
    // Proceed with deletion...
end;
```

### StrMenu for Multiple Options

```al
procedure HandleDuplicateCustomer(ExistingCustomer: Record Customer; NewCustomerName: Text[100])
var
    Selection: Integer;
begin
    // User chooses from multiple valid options
    Selection := StrMenu('Update existing customer,Create new customer with different name,Cancel operation', 1, 
                        'A customer named "%1" already exists. How would you like to proceed?', NewCustomerName);
    
    case Selection of
        1: UpdateExistingCustomer(ExistingCustomer);
        2: RequestNewCustomerName();
        3: exit;
    end;
end;
```

## Principle 3: Layer Error Information

### Basic ErrorInfo Pattern

```al
procedure ValidateCustomerData(Customer: Record Customer)
var
    ValidationError: ErrorInfo;
begin
    if Customer."Credit Limit" <= 0 then begin
        ValidationError.Message := 'Invalid credit limit for customer ' + Customer.Name;
        ValidationError.DetailedMessage := 'Credit limit must be greater than zero. Current value: ' + Format(Customer."Credit Limit");
        ValidationError.AddAction('Open Customer Card', Codeunit::"Customer Management", 'OpenCustomerCard');
        Error(ValidationError);
    end;
end;
```

### Complex Validation with Context

```al
procedure ValidateOrderTotals(SalesHeader: Record "Sales Header")
var
    OrderError: ErrorInfo;
    Customer: Record Customer;
begin
    Customer.Get(SalesHeader."Sell-to Customer No.");
    
    if SalesHeader."Amount Including VAT" > Customer."Credit Limit" then begin
        OrderError.Message := StrSubstNo('Order total %1 exceeds customer credit limit', 
                                        SalesHeader."Amount Including VAT");
        OrderError.DetailedMessage := StrSubstNo('Customer %1 has a credit limit of %2. ' +
                                                 'The current order total is %3. ' +
                                                 'Please reduce the order amount or request a credit limit increase.',
                                                 Customer.Name, Customer."Credit Limit", 
                                                 SalesHeader."Amount Including VAT");
        OrderError.AddAction('Adjust Order Lines', Codeunit::"Sales Order Management", 'AdjustOrderLines');
        OrderError.AddAction('Request Credit Increase', Codeunit::"Credit Management", 'RequestCreditIncrease');
        Error(OrderError);
    end;
end;
```

## Principle 4: Context-Aware Messages

### End User Messages

```al
// Focus on business impact and resolution
if Item.Inventory < RequestedQuantity then
    Error('Not enough %1 in stock. Available: %2, Requested: %3. Please reduce the quantity or check with the warehouse team.',
          Item.Description, Item.Inventory, RequestedQuantity);
```

### Administrator Messages

```al
// Include system context and configuration guidance
if not IsServiceConnected() then
    Error('External service connection failed. Please check the service configuration in the Extension Settings page or contact your system administrator.');
```

### Developer Messages

```al
// Technical details for troubleshooting
#if DEBUG
    Error('API call failed. Endpoint: %1, Status Code: %2, Response: %3', 
          ApiEndpoint, StatusCode, ResponseText);
#else
    Error('External service is temporarily unavailable. Please try again later.');
#endif
```

## Testing Error Messages

### Test Error Scenarios

```al
[Test]
procedure TestCreditLimitValidation()
var
    Customer: Record Customer;
    SalesHeader: Record "Sales Header";
begin
    // Arrange
    CreateCustomerWithCreditLimit(Customer, 1000);
    CreateSalesOrderWithAmount(SalesHeader, Customer."No.", 1500);
    
    // Act & Assert
    asserterror ValidateOrder(SalesHeader);
    Assert.ExpectedError(StrSubstNo('Order total %1 exceeds customer credit limit', 1500));
end;
```

### Verify Error Information

```al
[Test]
procedure TestErrorInfoDetails()
var
    Customer: Record Customer;
    CaughtErrorInfo: ErrorInfo;
begin
    // Arrange
    CreateInvalidCustomer(Customer);
    
    // Act
    ClearLastError();
    asserterror ValidateCustomerData(Customer);
    CaughtErrorInfo := GetLastErrorObject();
    
    // Assert
    Assert.IsTrue(CaughtErrorInfo.Message.Contains('Invalid credit limit'), 'Error message should mention credit limit');
    Assert.IsTrue(CaughtErrorInfo.DetailedMessage <> '', 'Detailed message should be provided');
end;
```
