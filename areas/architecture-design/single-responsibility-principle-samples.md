---
title: "Single Responsibility Principle in AL - Code Samples"
description: "Complete code examples demonstrating Single Responsibility Principle implementation in AL"
area: "architecture-design"
difficulty: "intermediate"
object_types: ["Codeunit", "Table", "Page"]
variable_types: ["Record"]
tags: ["solid-principles", "srp", "single-responsibility", "samples", "best-practices"]
---

# Single Responsibility Principle in AL - Code Samples

## Customer Validation Codeunit

```al
codeunit 50100 "Customer Validation"
{
    /// <summary>
    /// Validates all customer data according to business rules
    /// Single responsibility: Customer data validation only
    /// </summary>
    
    procedure ValidateCustomerData(var Customer: Record Customer): Boolean
    var
        ValidationResult: Boolean;
    begin
        ValidationResult := true;
        
        if not ValidatePostingGroup(Customer."Customer Posting Group") then
            ValidationResult := false;
            
        if not ValidateVATRegistration(Customer."VAT Registration No.") then
            ValidationResult := false;
            
        if not ValidateCreditLimit(Customer."Credit Limit (LCY)") then
            ValidationResult := false;
            
        exit(ValidationResult);
    end;
    
    procedure ValidatePostingGroup(PostingGroupCode: Code[20]): Boolean
    var
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        if PostingGroupCode = '' then begin
            Error('Customer Posting Group cannot be empty');
            exit(false);
        end;
        
        if not CustomerPostingGroup.Get(PostingGroupCode) then begin
            Error('Customer Posting Group %1 does not exist', PostingGroupCode);
            exit(false);
        end;
        
        exit(true);
    end;
    
    procedure ValidateVATRegistration(VATRegNo: Text[20]): Boolean
    var
        VATRegNoSrvConfig: Record "VAT Reg. No. Srv Config";
    begin
        if VATRegNo = '' then
            exit(true); // VAT registration is optional
            
        // Basic format validation
        if StrLen(VATRegNo) < 8 then begin
            Error('VAT Registration No. must be at least 8 characters');
            exit(false);
        end;
        
        // Additional validation logic here
        exit(true);
    end;
    
    procedure ValidateCreditLimit(CreditLimit: Decimal): Boolean
    begin
        if CreditLimit < 0 then begin
            Error('Credit Limit cannot be negative');
            exit(false);
        end;
        
        // Additional business rule validations
        if CreditLimit > 1000000 then begin
            Error('Credit Limit exceeds maximum allowed amount');
            exit(false);
        end;
        
        exit(true);
    end;
}
```

## Customer Notification Codeunit

```al
codeunit 50101 "Customer Notification"
{
    /// <summary>
    /// Handles all customer notification scenarios
    /// Single responsibility: Customer notifications only
    /// </summary>
    
    procedure SendWelcomeEmail(CustomerNo: Code[20])
    var
        Customer: Record Customer;
        EmailSubject: Text;
        EmailBody: Text;
    begin
        if not Customer.Get(CustomerNo) then
            exit;
            
        EmailSubject := 'Welcome to Our Company!';
        EmailBody := BuildWelcomeEmailBody(Customer);
        
        SendEmail(Customer."E-Mail", EmailSubject, EmailBody);
    end;
    
    procedure SendPaymentReminder(CustomerNo: Code[20]; Amount: Decimal)
    var
        Customer: Record Customer;
        EmailSubject: Text;
        EmailBody: Text;
    begin
        if not Customer.Get(CustomerNo) then
            exit;
            
        EmailSubject := 'Payment Reminder';
        EmailBody := BuildPaymentReminderBody(Customer, Amount);
        
        SendEmail(Customer."E-Mail", EmailSubject, EmailBody);
    end;
    
    procedure SendCreditLimitWarning(CustomerNo: Code[20])
    var
        Customer: Record Customer;
        EmailSubject: Text;
        EmailBody: Text;
    begin
        if not Customer.Get(CustomerNo) then
            exit;
            
        EmailSubject := 'Credit Limit Warning';
        EmailBody := BuildCreditLimitWarningBody(Customer);
        
        SendEmail(Customer."E-Mail", EmailSubject, EmailBody);
    end;
    
    local procedure BuildWelcomeEmailBody(Customer: Record Customer): Text
    var
        EmailBody: TextBuilder;
    begin
        EmailBody.AppendLine(StrSubstNo('Dear %1,', Customer.Name));
        EmailBody.AppendLine('');
        EmailBody.AppendLine('Welcome to our company! We are excited to have you as our customer.');
        EmailBody.AppendLine('');
        EmailBody.AppendLine('Your customer number is: ' + Customer."No.");
        EmailBody.AppendLine('');
        EmailBody.AppendLine('Best regards,');
        EmailBody.AppendLine('The Team');
        
        exit(EmailBody.ToText());
    end;
    
    local procedure BuildPaymentReminderBody(Customer: Record Customer; Amount: Decimal): Text
    var
        EmailBody: TextBuilder;
    begin
        EmailBody.AppendLine(StrSubstNo('Dear %1,', Customer.Name));
        EmailBody.AppendLine('');
        EmailBody.AppendLine(StrSubstNo('This is a reminder that you have an outstanding balance of %1.', Amount));
        EmailBody.AppendLine('');
        EmailBody.AppendLine('Please arrange payment at your earliest convenience.');
        EmailBody.AppendLine('');
        EmailBody.AppendLine('Best regards,');
        EmailBody.AppendLine('Accounts Receivable Team');
        
        exit(EmailBody.ToText());
    end;
    
    local procedure BuildCreditLimitWarningBody(Customer: Record Customer): Text
    var
        EmailBody: TextBuilder;
    begin
        EmailBody.AppendLine(StrSubstNo('Dear %1,', Customer.Name));
        EmailBody.AppendLine('');
        EmailBody.AppendLine('Your account is approaching the credit limit.');
        EmailBody.AppendLine('Please contact us to discuss payment arrangements or credit limit increase.');
        EmailBody.AppendLine('');
        EmailBody.AppendLine('Best regards,');
        EmailBody.AppendLine('Credit Management Team');
        
        exit(EmailBody.ToText());
    end;
    
    local procedure SendEmail(ToEmail: Text; Subject: Text; Body: Text)
    begin
        // Implementation would use email sending functionality
        // This is a placeholder for the actual email sending logic
        Message('Email sent to %1\Subject: %2', ToEmail, Subject);
    end;
}
```

## Customer Reporting Codeunit

```al
codeunit 50102 "Customer Reporting"
{
    /// <summary>
    /// Handles customer reporting and analytics
    /// Single responsibility: Customer reporting only
    /// </summary>
    
    procedure GenerateCustomerSummaryReport(CustomerNo: Code[20])
    var
        Customer: Record Customer;
        ReportData: Text;
    begin
        if not Customer.Get(CustomerNo) then
            exit;
            
        ReportData := BuildCustomerSummary(Customer);
        DisplayReport(ReportData);
    end;
    
    procedure GenerateCustomerListReport(var Customers: Record Customer)
    var
        ReportBuilder: TextBuilder;
        ReportData: Text;
    begin
        ReportBuilder.AppendLine('Customer List Report');
        ReportBuilder.AppendLine('===================');
        ReportBuilder.AppendLine('');
        
        if Customers.FindSet() then
            repeat
                ReportBuilder.AppendLine(FormatCustomerLine(Customers));
            until Customers.Next() = 0;
            
        ReportData := ReportBuilder.ToText();
        DisplayReport(ReportData);
    end;
    
    procedure CalculateCustomerMetrics(CustomerNo: Code[20]): Text
    var
        Customer: Record Customer;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        TotalSales: Decimal;
        OutstandingAmount: Decimal;
        MetricsBuilder: TextBuilder;
    begin
        if not Customer.Get(CustomerNo) then
            exit('');
            
        // Calculate total sales
        CustLedgerEntry.SetRange("Customer No.", CustomerNo);
        CustLedgerEntry.SetRange("Posting Date", CalcDate('<-1Y>', Today), Today);
        CustLedgerEntry.CalcSums("Sales (LCY)");
        TotalSales := CustLedgerEntry."Sales (LCY)";
        
        // Calculate outstanding amount
        CustLedgerEntry.SetRange("Posting Date");
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.CalcSums("Remaining Amt. (LCY)");
        OutstandingAmount := CustLedgerEntry."Remaining Amt. (LCY)";
        
        // Build metrics summary
        MetricsBuilder.AppendLine(StrSubstNo('Customer: %1 - %2', Customer."No.", Customer.Name));
        MetricsBuilder.AppendLine(StrSubstNo('Annual Sales: %1', TotalSales));
        MetricsBuilder.AppendLine(StrSubstNo('Outstanding: %1', OutstandingAmount));
        MetricsBuilder.AppendLine(StrSubstNo('Credit Limit: %1', Customer."Credit Limit (LCY)"));
        
        exit(MetricsBuilder.ToText());
    end;
    
    local procedure BuildCustomerSummary(Customer: Record Customer): Text
    var
        SummaryBuilder: TextBuilder;
    begin
        SummaryBuilder.AppendLine('Customer Summary Report');
        SummaryBuilder.AppendLine('=======================');
        SummaryBuilder.AppendLine('');
        SummaryBuilder.AppendLine(StrSubstNo('Customer No.: %1', Customer."No."));
        SummaryBuilder.AppendLine(StrSubstNo('Name: %1', Customer.Name));
        SummaryBuilder.AppendLine(StrSubstNo('Address: %1', Customer.Address));
        SummaryBuilder.AppendLine(StrSubstNo('City: %1', Customer.City));
        SummaryBuilder.AppendLine(StrSubstNo('Phone: %1', Customer."Phone No."));
        SummaryBuilder.AppendLine(StrSubstNo('Email: %1', Customer."E-Mail"));
        SummaryBuilder.AppendLine('');
        SummaryBuilder.AppendLine(CalculateCustomerMetrics(Customer."No."));
        
        exit(SummaryBuilder.ToText());
    end;
    
    local procedure FormatCustomerLine(Customer: Record Customer): Text
    begin
        exit(StrSubstNo('%1 - %2 (%3)', Customer."No.", Customer.Name, Customer.City));
    end;
    
    local procedure DisplayReport(ReportData: Text)
    begin
        // Implementation would display the report
        // This could be a page, export to file, or other display mechanism
        Message(ReportData);
    end;
}
```

## Specialized Table for Customer Categories

```al
table 50100 "Customer Category"
{
    /// <summary>
    /// Focused table for customer categorization
    /// Single responsibility: Customer category data only
    /// </summary>
    
    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        
        field(2; "Description"; Text[50])
        {
            Caption = 'Description';
        }
        
        field(3; "Discount %"; Decimal)
        {
            Caption = 'Discount %';
            DecimalPlaces = 2:2;
            MinValue = 0;
            MaxValue = 100;
        }
        
        field(4; "Credit Days"; Integer)
        {
            Caption = 'Credit Days';
            MinValue = 0;
        }
        
        field(5; "Priority Level"; Option)
        {
            Caption = 'Priority Level';
            OptionMembers = Low,Normal,High,VIP;
        }
    }
    
    keys
    {
        key(PK; "Code") { Clustered = true; }
        key(Description; Description) { }
    }
    
    trigger OnInsert()
    begin
        TestField(Code);
        TestField(Description);
        ValidateDiscountPercentage();
    end;
    
    trigger OnModify()
    begin
        ValidateDiscountPercentage();
    end;
    
    local procedure ValidateDiscountPercentage()
    begin
        if ("Discount %" < 0) or ("Discount %" > 100) then
            Error('Discount percentage must be between 0 and 100');
    end;
}
```

## Focused Page for Customer Categories

```al
page 50100 "Customer Category List"
{
    /// <summary>
    /// Simple list page focused only on customer category display
    /// Single responsibility: Display customer categories
    /// </summary>
    
    PageType = List;
    SourceTable = "Customer Category";
    ApplicationArea = All;
    UsageCategory = Lists;
    
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; "Code")
                {
                    ApplicationArea = All;
                }
                
                field("Description"; Description)
                {
                    ApplicationArea = All;
                }
                
                field("Discount %"; "Discount %")
                {
                    ApplicationArea = All;
                }
                
                field("Credit Days"; "Credit Days")
                {
                    ApplicationArea = All;
                }
                
                field("Priority Level"; "Priority Level")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    
    actions
    {
        area(Processing)
        {
            action(ShowCustomers)
            {
                ApplicationArea = All;
                Caption = 'Show Customers in Category';
                Image = Customer;
                
                trigger OnAction()
                begin
                    ShowCustomersInCategory();
                end;
            }
        }
    }
    
    local procedure ShowCustomersInCategory()
    var
        Customer: Record Customer;
        CustomerList: Page "Customer List";
    begin
        // This demonstrates proper separation - the page doesn't do complex processing
        // It delegates to appropriate objects or opens related pages
        Customer.SetRange("ABC Customer Category", "Code");
        CustomerList.SetTableView(Customer);
        CustomerList.Run();
    end;
}
```

## Integration Example: Using SRP Objects Together

```al
codeunit 50103 "Customer Management Coordinator"
{
    /// <summary>
    /// Coordinates between different customer-related objects
    /// Single responsibility: Orchestrate customer operations
    /// </summary>
    
    var
        CustomerValidation: Codeunit "Customer Validation";
        CustomerNotification: Codeunit "Customer Notification";
        CustomerReporting: Codeunit "Customer Reporting";
    
    procedure ProcessNewCustomer(var Customer: Record Customer)
    begin
        // Validate using specialized validation object
        if not CustomerValidation.ValidateCustomerData(Customer) then
            exit;
            
        // Save the customer
        Customer.Insert(true);
        
        // Send welcome notification using specialized notification object
        CustomerNotification.SendWelcomeEmail(Customer."No.");
        
        // Generate initial report using specialized reporting object
        CustomerReporting.GenerateCustomerSummaryReport(Customer."No.");
    end;
    
    procedure HandleCreditLimitExceeded(CustomerNo: Code[20])
    begin
        // Send notification using specialized notification object
        CustomerNotification.SendCreditLimitWarning(CustomerNo);
        
        // Generate credit report using specialized reporting object
        CustomerReporting.CalculateCustomerMetrics(CustomerNo);
    end;
}
```

## Related Topics
- [Single Responsibility Principle](single-responsibility-principle.md)
- [Open-Closed Principle](open-closed-principle.md)
- [Interface Segregation Principle](interface-segregation-principle.md)
