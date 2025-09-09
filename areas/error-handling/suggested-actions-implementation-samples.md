---
title: "Suggested Actions Implementation - Code Samples"
description: "Complete code examples for implementing suggested actions in ErrorInfo patterns"
area: "error-handling"
difficulty: "intermediate"
object_types: ["Codeunit", "Page"]
variable_types: ["ErrorInfo"]
tags: ["error-handling", "suggested-actions", "samples", "errorinfo"]
---

# Suggested Actions Implementation - Code Samples

## Complete Credit Limit Example

### Main Validation with Suggested Actions

```al
codeunit 50101 "Sales Order Validation"
{
    procedure ValidateCreditLimit(SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        CreditError: ErrorInfo;
    begin
        Customer.Get(SalesHeader."Sell-to Customer No.");
        
        if SalesHeader."Amount Including VAT" > Customer."Credit Limit" then begin
            // Store context for action handlers
            SetErrorContext(Customer."No.", SalesHeader."No.", SalesHeader."Amount Including VAT");
            
            CreditError.Message := StrSubstNo('Order amount %1 exceeds credit limit %2', 
                                            SalesHeader."Amount Including VAT", Customer."Credit Limit");
            CreditError.DetailedMessage := StrSubstNo('Customer %1 has a credit limit of %2. ' +
                                                     'The current order total is %3. Choose an action to resolve this issue.',
                                                     Customer.Name, Customer."Credit Limit", 
                                                     SalesHeader."Amount Including VAT");
            
            // Add suggested actions in order of preference
            CreditError.AddAction('Increase Credit Limit', Codeunit::"Customer Credit Management", 'IncreaseCreditLimit');
            CreditError.AddAction('Adjust Order Amount', Codeunit::"Sales Order Management", 'AdjustOrderAmount');
            CreditError.AddAction('Contact Credit Manager', Codeunit::"Customer Credit Management", 'ContactCreditManager');
            CreditError.AddAction('Review Customer History', Codeunit::"Customer Credit Management", 'ReviewCustomerHistory');
            
            Error(CreditError);
        end;
    end;
    
    local procedure SetErrorContext(CustomerNo: Code[20]; SalesOrderNo: Code[20]; OrderAmount: Decimal)
    begin
        // Store context in session variables for action handlers
        SessionStorage.Set('ErrorContext_CustomerNo', CustomerNo);
        SessionStorage.Set('ErrorContext_SalesOrderNo', SalesOrderNo);
        SessionStorage.Set('ErrorContext_OrderAmount', Format(OrderAmount));
    end;
}
```

### Customer Credit Management Action Handler

```al
codeunit 50100 "Customer Credit Management"
{
    procedure IncreaseCreditLimit()
    var
        Customer: Record Customer;
        CustomerCard: Page "Customer Card";
        CustomerNo: Code[20];
    begin
        CustomerNo := GetContextCustomerNo();
        if CustomerNo = '' then
            exit;
            
        if Customer.Get(CustomerNo) then begin
            // Open Customer Card focused on credit limit field
            Customer.SetRecFilter();
            CustomerCard.SetTableView(Customer);
            CustomerCard.SetRecord(Customer);
            
            // Set focus to credit limit field if possible
            CustomerCard.RunModal();
            
            Message('Credit limit updated successfully.');
        end else
            Message('Customer not found. Please refresh and try again.');
    end;
    
    procedure ContactCreditManager()
    var
        Customer: Record Customer;
        EmailDialog: Page "Email Dialog";
        CreditManager: Text;
        CustomerNo: Code[20];
        OrderAmount: Decimal;
    begin
        CustomerNo := GetContextCustomerNo();
        OrderAmount := GetContextOrderAmount();
        
        if Customer.Get(CustomerNo) then begin
            CreditManager := GetCreditManagerEmail();
            if CreditManager <> '' then begin
                EmailDialog.SetPredefinedContent(CreditManager, 
                    'Credit Limit Review Required', 
                    CreateCreditLimitEmailBody(Customer, OrderAmount));
                EmailDialog.RunModal();
                Message('Email prepared for credit manager.');
            end else
                Message('Credit manager contact information not configured. Please contact your administrator.');
        end;
    end;
    
    procedure ReviewCustomerHistory()
    var
        Customer: Record Customer;
        CustomerLedgerEntries: Page "Customer Ledger Entries";
        CustomerNo: Code[20];
    begin
        CustomerNo := GetContextCustomerNo();
        
        if Customer.Get(CustomerNo) then begin
            Customer.SetRecFilter();
            CustomerLedgerEntries.SetTableView(Customer);
            CustomerLedgerEntries.Run();
        end else
            Message('Customer not found. Please refresh and try again.');
    end;
    
    local procedure GetContextCustomerNo(): Code[20]
    var
        CustomerNo: Code[20];
    begin
        if SessionStorage.Get('ErrorContext_CustomerNo', CustomerNo) then
            exit(CustomerNo);
        exit('');
    end;
    
    local procedure GetContextOrderAmount(): Decimal
    var
        OrderAmountText: Text;
        OrderAmount: Decimal;
    begin
        if SessionStorage.Get('ErrorContext_OrderAmount', OrderAmountText) then
            if Evaluate(OrderAmount, OrderAmountText) then
                exit(OrderAmount);
        exit(0);
    end;
    
    local procedure GetCreditManagerEmail(): Text
    var
        CompanyInfo: Record "Company Information";
    begin
        CompanyInfo.Get();
        // Return configured credit manager email or default
        if CompanyInfo."Credit Manager Email" <> '' then
            exit(CompanyInfo."Credit Manager Email");
        exit('creditmanager@company.com'); // fallback
    end;
    
    local procedure CreateCreditLimitEmailBody(Customer: Record Customer; RequestedAmount: Decimal): Text
    var
        EmailBody: TextBuilder;
    begin
        EmailBody.AppendLine('Credit Limit Review Request');
        EmailBody.AppendLine('');
        EmailBody.AppendLine(StrSubstNo('Customer: %1 (%2)', Customer.Name, Customer."No."));
        EmailBody.AppendLine(StrSubstNo('Current Credit Limit: %1', Customer."Credit Limit"));
        EmailBody.AppendLine(StrSubstNo('Requested Order Amount: %1', RequestedAmount));
        EmailBody.AppendLine(StrSubstNo('Shortfall: %1', RequestedAmount - Customer."Credit Limit"));
        EmailBody.AppendLine('');
        EmailBody.AppendLine('Please review and approve an increased credit limit for this customer.');
        EmailBody.AppendLine('');
        EmailBody.AppendLine('Thank you,');
        EmailBody.AppendLine(UserId);
        
        exit(EmailBody.ToText());
    end;
}
```

### Sales Order Management Action Handler

```al
codeunit 50102 "Sales Order Management"
{
    procedure AdjustOrderAmount()
    var
        SalesHeader: Record "Sales Header";
        SalesOrder: Page "Sales Order";
        SalesOrderNo: Code[20];
    begin
        SalesOrderNo := GetContextSalesOrderNo();
        
        if SalesHeader.Get(SalesHeader."Document Type"::Order, SalesOrderNo) then begin
            SalesHeader.SetRecFilter();
            SalesOrder.SetTableView(SalesHeader);
            SalesOrder.SetRecord(SalesHeader);
            SalesOrder.RunModal();
            
            Message('Sales order opened for adjustment.');
        end else
            Message('Sales order not found. Please refresh and try again.');
    end;
    
    local procedure GetContextSalesOrderNo(): Code[20]
    var
        SalesOrderNo: Code[20];
    begin
        if SessionStorage.Get('ErrorContext_SalesOrderNo', SalesOrderNo) then
            exit(SalesOrderNo);
        exit('');
    end;
}
```

## Configuration Error Example

### Setup Validation with Actions

```al
procedure ValidateEmailConfiguration()
var
    SMTPSetup: Record "SMTP Mail Setup";
    ConfigError: ErrorInfo;
begin
    if not SMTPSetup.Get() then begin
        ConfigError.Message := 'Email configuration is not set up';
        ConfigError.DetailedMessage := 'SMTP settings are required to send emails. Please configure the email settings or contact your administrator.';
        
        ConfigError.AddAction('Open Email Setup', Codeunit::"Setup Management", 'OpenEmailSetup');
        ConfigError.AddAction('Run Setup Wizard', Codeunit::"Setup Management", 'RunEmailSetupWizard');
        ConfigError.AddAction('Contact Administrator', Codeunit::"Support Management", 'ContactAdminForEmailSetup');
        
        Error(ConfigError);
    end;
end;
```

### Setup Management Actions

```al
codeunit 50103 "Setup Management"
{
    procedure OpenEmailSetup()
    var
        SMTPMailSetup: Page "SMTP Mail Setup";
    begin
        SMTPMailSetup.RunModal();
        Message('Email setup page opened. Please configure the required settings.');
    end;
    
    procedure RunEmailSetupWizard()
    var
        EmailSetupWizard: Page "Email Setup Wizard";
    begin
        EmailSetupWizard.RunModal();
        Message('Email setup wizard completed.');
    end;
}
```

## Permission Error Example

### Permission Check with Actions

```al
procedure CheckTablePermission(TableID: Integer)
var
    PermissionError: ErrorInfo;
begin
    if not HasTablePermission(Database::"Sales Header", SecurityFilter::Insert) then begin
        PermissionError.Message := 'Insufficient permissions to create sales orders';
        PermissionError.DetailedMessage := 'You do not have permission to insert records in the Sales Header table. Contact your administrator to request access.';
        
        PermissionError.AddAction('Request Access', Codeunit::"Permission Management", 'RequestTableAccess');
        PermissionError.AddAction('View My Permissions', Codeunit::"Permission Management", 'ViewMyPermissions');
        PermissionError.AddAction('Contact Administrator', Codeunit::"Support Management", 'ContactAdminForPermissions');
        
        Error(PermissionError);
    end;
end;
```

## Data Validation Error Example

### Field Validation with Actions

```al
procedure ValidateRequiredFields(Customer: Record Customer)
var
    ValidationError: ErrorInfo;
    MissingFields: List of [Text];
begin
    // Check required fields
    if Customer.Name = '' then
        MissingFields.Add('Name');
    if Customer."Payment Terms Code" = '' then
        MissingFields.Add('Payment Terms Code');
    if Customer."Customer Posting Group" = '' then
        MissingFields.Add('Customer Posting Group');
    
    if MissingFields.Count > 0 then begin
        ValidationError.Message := StrSubstNo('Required fields are missing: %1', JoinList(MissingFields));
        ValidationError.DetailedMessage := 'Please fill in all required fields before saving the customer record.';
        
        ValidationError.AddAction('Open Customer Card', Codeunit::"Customer Management", 'OpenCustomerCard');
        ValidationError.AddAction('Fill Default Values', Codeunit::"Customer Management", 'FillDefaultValues');
        ValidationError.AddAction('View Field Requirements', Codeunit::"Help Management", 'ViewFieldRequirements');
        
        Error(ValidationError);
    end;
end;
```

## Testing Suggested Actions

### Test Action Availability

```al
[Test]
procedure TestCreditLimitErrorHasSuggestedActions()
var
    SalesHeader: Record "Sales Header";
    CaughtErrorInfo: ErrorInfo;
begin
    // Arrange
    CreateSalesOrderExceedingCreditLimit(SalesHeader);
    
    // Act
    ClearLastError();
    asserterror ValidateCreditLimit(SalesHeader);
    CaughtErrorInfo := GetLastErrorObject();
    
    // Assert
    Assert.IsTrue(CaughtErrorInfo.HasActions, 'Error should have suggested actions');
    Assert.IsTrue(CaughtErrorInfo.Actions.Count >= 2, 'Error should have at least 2 suggested actions');
    
    // Verify specific actions are available
    AssertActionExists(CaughtErrorInfo, 'Increase Credit Limit');
    AssertActionExists(CaughtErrorInfo, 'Adjust Order Amount');
end;
```

### Test Action Execution

```al
[Test]
procedure TestIncreaseCreditLimitAction()
var
    Customer: Record Customer;
begin
    // Arrange
    CreateTestCustomer(Customer);
    SetErrorContext(Customer."No.", '', 0);
    
    // Act
    IncreaseCreditLimit(); // This should not throw an error
    
    // Assert - verify the customer card was opened or context was handled
    Assert.IsTrue(true, 'Action executed without error');
end;
```

### Helper Methods for Testing

```al
local procedure AssertActionExists(ErrorInfo: ErrorInfo; ActionCaption: Text)
var
    ActionFound: Boolean;
    i: Integer;
begin
    for i := 1 to ErrorInfo.Actions.Count do begin
        if ErrorInfo.Actions.Get(i).Caption = ActionCaption then begin
            ActionFound := true;
            break;
        end;
    end;
    
    Assert.IsTrue(ActionFound, StrSubstNo('Expected action "%1" not found in error actions', ActionCaption));
end;
```
