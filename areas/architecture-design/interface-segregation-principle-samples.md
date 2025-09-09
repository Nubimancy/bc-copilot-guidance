---
title: "Interface Segregation Principle in AL - Code Samples"
description: "Complete code examples demonstrating Interface Segregation Principle implementation in AL"
area: "architecture-design"
difficulty: "intermediate"
object_types: ["Interface", "Codeunit"]
variable_types: ["Record", ]
tags: ["solid-principles", "isp", "interface-segregation", "interfaces", "focused-design", "samples"]
---

# Interface Segregation Principle in AL - Code Samples

## Focused Interface Design

```al
// ✅ Good: Small, focused interfaces
interface "ICustomer Validator"
{
    /// <summary>
    /// Focused interface for customer validation only
    /// Clients only depend on validation methods they need
    /// </summary>
    procedure ValidateCustomer(var Customer: Record Customer): Boolean;
    procedure GetValidationErrors(): List of [Text];
}

interface "IEmail Sender"  
{
    /// <summary>
    /// Focused interface for email functionality only
    /// Separate from validation concerns
    /// </summary>
    procedure SendEmail(ToEmail: Text; Subject: Text; Body: Text): Boolean;
    procedure ValidateEmailAddress(Email: Text): Boolean;
}

interface "IReport Generator"
{
    /// <summary>
    /// Focused interface for report generation only
    /// Independent of validation and communication
    /// </summary>
    procedure GenerateCustomerReport(CustomerNo: Code[20]): Boolean;
    procedure GenerateSalesReport(DateFrom: Date; DateTo: Date): Boolean;
    procedure ExportReportToPDF(ReportData: Text; FileName: Text): Boolean;
}

interface "IData Backup"
{
    /// <summary>
    /// Focused interface for backup operations only
    /// Separate from business logic
    /// </summary>
    procedure BackupCustomerData(CustomerNo: Code[20]): Boolean;
    procedure RestoreCustomerData(CustomerNo: Code[20]; BackupDate: DateTime): Boolean;
    procedure VerifyBackupIntegrity(): Boolean;
}
```

## Interface Implementation Examples

```al
codeunit 50300 "Customer Data Validator" implements "ICustomer Validator"
{
    /// <summary>
    /// Implements only validation interface - focused responsibility
    /// No need to implement unrelated email, reporting, or backup methods
    /// </summary>
    
    var
        ValidationErrors: List of [Text];
    
    procedure ValidateCustomer(var Customer: Record Customer): Boolean
    var
        IsValid: Boolean;
    begin
        Clear(ValidationErrors);
        IsValid := true;
        
        // Customer number validation
        if Customer."No." = '' then begin
            ValidationErrors.Add('Customer number is required');
            IsValid := false;
        end;
        
        // Name validation
        if Customer.Name = '' then begin
            ValidationErrors.Add('Customer name is required');
            IsValid := false;
        end;
        
        // Contact validation
        if (Customer."Phone No." = '') and (Customer."E-Mail" = '') then begin
            ValidationErrors.Add('Either phone number or email is required');
            IsValid := false;
        end;
        
        // Posting group validation
        if Customer."Customer Posting Group" = '' then begin
            ValidationErrors.Add('Customer posting group is required');
            IsValid := false;
        end else
            if not ValidatePostingGroup(Customer."Customer Posting Group") then begin
                ValidationErrors.Add(StrSubstNo('Customer posting group %1 does not exist', Customer."Customer Posting Group"));
                IsValid := false;
            end;
        
        // Payment terms validation
        if Customer."Payment Terms Code" <> '' then
            if not ValidatePaymentTerms(Customer."Payment Terms Code") then begin
                ValidationErrors.Add(StrSubstNo('Payment terms %1 does not exist', Customer."Payment Terms Code"));
                IsValid := false;
            end;
        
        exit(IsValid);
    end;
    
    procedure GetValidationErrors(): List of [Text]
    begin
        exit(ValidationErrors);
    end;
    
    local procedure ValidatePostingGroup(PostingGroupCode: Code[20]): Boolean
    var
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        exit(CustomerPostingGroup.Get(PostingGroupCode));
    end;
    
    local procedure ValidatePaymentTerms(PaymentTermsCode: Code[10]): Boolean
    var
        PaymentTerms: Record "Payment Terms";
    begin
        exit(PaymentTerms.Get(PaymentTermsCode));
    end;
}

codeunit 50301 "SMTP Email Sender" implements "IEmail Sender"
{
    /// <summary>
    /// Implements only email interface - no validation, reporting, or backup concerns
    /// Focused on email functionality only
    /// </summary>
    
    procedure SendEmail(ToEmail: Text; Subject: Text; Body: Text): Boolean
    var
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
    begin
        if not ValidateEmailAddress(ToEmail) then
            exit(false);
            
        EmailMessage.Create(ToEmail, Subject, Body);
        exit(Email.Send(EmailMessage));
    end;
    
    procedure ValidateEmailAddress(Email: Text): Boolean
    begin
        // Basic email validation
        if Email = '' then
            exit(false);
            
        if StrPos(Email, '@') = 0 then
            exit(false);
            
        if StrPos(Email, '.') = 0 then
            exit(false);
            
        // More sophisticated email validation could be added here
        exit(true);
    end;
}

codeunit 50302 "Customer Report Generator" implements "IReport Generator"
{
    /// <summary>
    /// Implements only reporting interface - no validation, email, or backup concerns
    /// Focused on report generation only
    /// </summary>
    
    procedure GenerateCustomerReport(CustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
        ReportBuilder: TextBuilder;
        ReportContent: Text;
    begin
        if not Customer.Get(CustomerNo) then
            exit(false);
            
        ReportContent := BuildCustomerReportContent(Customer);
        
        // Generate and display report
        Message('Customer Report:\%1', ReportContent);
        exit(true);
    end;
    
    procedure GenerateSalesReport(DateFrom: Date; DateTo: Date): Boolean
    var
        SalesHeader: Record "Sales Header";
        ReportBuilder: TextBuilder;
        TotalAmount: Decimal;
        OrderCount: Integer;
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("Order Date", DateFrom, DateTo);
        
        ReportBuilder.AppendLine('Sales Report');
        ReportBuilder.AppendLine('============');
        ReportBuilder.AppendLine(StrSubstNo('Period: %1 to %2', DateFrom, DateTo));
        ReportBuilder.AppendLine('');
        
        if SalesHeader.FindSet() then
            repeat
                SalesHeader.CalcFields("Amount Including VAT");
                TotalAmount += SalesHeader."Amount Including VAT";
                OrderCount += 1;
                ReportBuilder.AppendLine(StrSubstNo('Order %1: %2 - Amount: %3', 
                    SalesHeader."No.", SalesHeader."Sell-to Customer Name", SalesHeader."Amount Including VAT"));
            until SalesHeader.Next() = 0;
        
        ReportBuilder.AppendLine('');
        ReportBuilder.AppendLine(StrSubstNo('Total Orders: %1', OrderCount));
        ReportBuilder.AppendLine(StrSubstNo('Total Amount: %1', TotalAmount));
        
        Message(ReportBuilder.ToText());
        exit(true);
    end;
    
    procedure ExportReportToPDF(ReportData: Text; FileName: Text): Boolean
    begin
        // Implementation would export to PDF
        // This is a placeholder for actual PDF export functionality
        Message('Report exported to PDF: %1', FileName);
        exit(true);
    end;
    
    local procedure BuildCustomerReportContent(Customer: Record Customer): Text
    var
        ReportBuilder: TextBuilder;
    begin
        ReportBuilder.AppendLine(StrSubstNo('Customer No.: %1', Customer."No."));
        ReportBuilder.AppendLine(StrSubstNo('Name: %1', Customer.Name));
        ReportBuilder.AppendLine(StrSubstNo('Address: %1', Customer.Address));
        ReportBuilder.AppendLine(StrSubstNo('City: %1, %2', Customer.City, Customer."Post Code"));
        ReportBuilder.AppendLine(StrSubstNo('Phone: %1', Customer."Phone No."));
        ReportBuilder.AppendLine(StrSubstNo('Email: %1', Customer."E-Mail"));
        
        // Add financial information
        Customer.CalcFields("Balance (LCY)", "Sales (LCY)");
        ReportBuilder.AppendLine(StrSubstNo('Current Balance: %1', Customer."Balance (LCY)"));
        ReportBuilder.AppendLine(StrSubstNo('Total Sales: %1', Customer."Sales (LCY)"));
        
        exit(ReportBuilder.ToText());
    end;
}
```

## Composite Implementation Using Multiple Interfaces

```al
codeunit 50303 "Customer Service Manager" implements "ICustomer Validator", "IEmail Sender"
{
    /// <summary>
    /// Demonstrates proper interface composition
    /// Implements multiple focused interfaces as needed
    /// Does not implement unneeded interfaces (IReport Generator, IData Backup)
    /// </summary>
    
    var
        ValidationErrors: List of [Text];
    
    // ICustomer Validator implementation
    procedure ValidateCustomer(var Customer: Record Customer): Boolean
    var
        BasicValidator: Codeunit "Customer Data Validator";
    begin
        // Delegate to specialized validator or implement custom logic
        exit(BasicValidator.ValidateCustomer(Customer));
    end;
    
    procedure GetValidationErrors(): List of [Text]
    begin
        exit(ValidationErrors);
    end;
    
    // IEmail Sender implementation  
    procedure SendEmail(ToEmail: Text; Subject: Text; Body: Text): Boolean
    var
        EmailSender: Codeunit "SMTP Email Sender";
    begin
        // Delegate to specialized email sender
        exit(EmailSender.SendEmail(ToEmail, Subject, Body));
    end;
    
    procedure ValidateEmailAddress(Email: Text): Boolean
    var
        EmailSender: Codeunit "SMTP Email Sender";
    begin
        exit(EmailSender.ValidateEmailAddress(Email));
    end;
    
    // Customer service specific methods (not part of interfaces)
    procedure ProcessCustomerComplaint(CustomerNo: Code[20]; ComplaintText: Text): Boolean
    var
        Customer: Record Customer;
        ComplaintEmail: Text;
    begin
        if not Customer.Get(CustomerNo) then
            exit(false);
            
        // Validate customer data
        if not ValidateCustomer(Customer) then
            exit(false);
            
        // Send acknowledgment email
        ComplaintEmail := BuildComplaintAcknowledgmentEmail(Customer, ComplaintText);
        exit(SendEmail(Customer."E-Mail", 'Complaint Acknowledgment', ComplaintEmail));
    end;
    
    local procedure BuildComplaintAcknowledgmentEmail(Customer: Record Customer; ComplaintText: Text): Text
    var
        EmailBuilder: TextBuilder;
    begin
        EmailBuilder.AppendLine(StrSubstNo('Dear %1,', Customer.Name));
        EmailBuilder.AppendLine('');
        EmailBuilder.AppendLine('Thank you for bringing your concern to our attention.');
        EmailBuilder.AppendLine('');
        EmailBuilder.AppendLine('Your complaint:');
        EmailBuilder.AppendLine(ComplaintText);
        EmailBuilder.AppendLine('');
        EmailBuilder.AppendLine('We will investigate and respond within 2 business days.');
        EmailBuilder.AppendLine('');
        EmailBuilder.AppendLine('Best regards,');
        EmailBuilder.AppendLine('Customer Service Team');
        
        exit(EmailBuilder.ToText());
    end;
}
```

## Interface Segregation vs. Fat Interface Comparison

```al
// ❌ Bad: Fat interface violates ISP
interface "ICustomer Everything"
{
    // Validation methods
    procedure ValidateCustomer(var Customer: Record Customer): Boolean;
    procedure GetValidationErrors(): List of [Text];
    
    // Email methods
    procedure SendEmail(ToEmail: Text; Subject: Text; Body: Text): Boolean;
    procedure ValidateEmailAddress(Email: Text): Boolean;
    procedure SendNewsletterToAllCustomers(): Boolean;
    
    // Reporting methods
    procedure GenerateCustomerReport(CustomerNo: Code[20]): Boolean;
    procedure GenerateSalesReport(DateFrom: Date; DateTo: Date): Boolean;
    procedure ExportReportToPDF(ReportData: Text; FileName: Text): Boolean;
    procedure ScheduleReportGeneration(ReportType: Text; Schedule: Text): Boolean;
    
    // Backup methods
    procedure BackupCustomerData(CustomerNo: Code[20]): Boolean;
    procedure RestoreCustomerData(CustomerNo: Code[20]; BackupDate: DateTime): Boolean;
    procedure VerifyBackupIntegrity(): Boolean;
    
    // Payment methods
    procedure ProcessPayment(Amount: Decimal; PaymentMethod: Text): Boolean;
    procedure ValidatePaymentData(PaymentData: Text): Boolean;
    procedure RefundPayment(TransactionId: Text): Boolean;
    
    // Data import/export methods
    procedure ImportCustomerData(FilePath: Text): Boolean;
    procedure ExportCustomerData(CustomerFilter: Text; FilePath: Text): Boolean;
    procedure ValidateImportFile(FilePath: Text): Boolean;
}

// ❌ Problems with fat interface implementation
codeunit 50304 "Simple Customer Validator" implements "ICustomer Everything"
{
    /// <summary>
    /// This implementation only needs validation but is forced to implement everything
    /// Violates ISP - client depends on methods it doesn't use
    /// </summary>
    
    var
        ValidationErrors: List of [Text];
    
    // Actually needed methods
    procedure ValidateCustomer(var Customer: Record Customer): Boolean
    begin
        // Real implementation
        exit(Customer."No." <> '');
    end;
    
    procedure GetValidationErrors(): List of [Text]
    begin
        exit(ValidationErrors);
    end;
    
    // ❌ Forced to implement methods we don't need or want
    procedure SendEmail(ToEmail: Text; Subject: Text; Body: Text): Boolean
    begin
        Error('Email functionality not supported by this validator');
    end;
    
    procedure ValidateEmailAddress(Email: Text): Boolean
    begin
        Error('Email functionality not supported by this validator');
    end;
    
    procedure SendNewsletterToAllCustomers(): Boolean
    begin
        Error('Email functionality not supported by this validator');
    end;
    
    procedure GenerateCustomerReport(CustomerNo: Code[20]): Boolean
    begin
        Error('Reporting functionality not supported by this validator');
    end;
    
    procedure GenerateSalesReport(DateFrom: Date; DateTo: Date): Boolean
    begin
        Error('Reporting functionality not supported by this validator');
    end;
    
    procedure ExportReportToPDF(ReportData: Text; FileName: Text): Boolean
    begin
        Error('PDF export not supported by this validator');
    end;
    
    procedure ScheduleReportGeneration(ReportType: Text; Schedule: Text): Boolean
    begin
        Error('Report scheduling not supported by this validator');
    end;
    
    procedure BackupCustomerData(CustomerNo: Code[20]): Boolean
    begin
        Error('Backup functionality not supported by this validator');
    end;
    
    procedure RestoreCustomerData(CustomerNo: Code[20]; BackupDate: DateTime): Boolean
    begin
        Error('Restore functionality not supported by this validator');
    end;
    
    procedure VerifyBackupIntegrity(): Boolean
    begin
        Error('Backup verification not supported by this validator');
    end;
    
    procedure ProcessPayment(Amount: Decimal; PaymentMethod: Text): Boolean
    begin
        Error('Payment processing not supported by this validator');
    end;
    
    procedure ValidatePaymentData(PaymentData: Text): Boolean
    begin
        Error('Payment validation not supported by this validator');
    end;
    
    procedure RefundPayment(TransactionId: Text): Boolean
    begin
        Error('Payment refunds not supported by this validator');
    end;
    
    procedure ImportCustomerData(FilePath: Text): Boolean
    begin
        Error('Data import not supported by this validator');
    end;
    
    procedure ExportCustomerData(CustomerFilter: Text; FilePath: Text): Boolean
    begin
        Error('Data export not supported by this validator');
    end;
    
    procedure ValidateImportFile(FilePath: Text): Boolean
    begin
        Error('File validation not supported by this validator');
    end;
}
```

## Proper Interface Usage in Client Code

```al
codeunit 50305 "Customer Management System"
{
    /// <summary>
    /// Demonstrates proper use of segregated interfaces
    /// Each component only depends on interfaces it actually needs
    /// </summary>
    
    var
        CustomerValidator: Interface "ICustomer Validator";
        EmailSender: Interface "IEmail Sender";
        ReportGenerator: Interface "IReport Generator";
    
    procedure SetCustomerValidator(NewValidator: Interface "ICustomer Validator")
    begin
        CustomerValidator := NewValidator;
    end;
    
    procedure SetEmailSender(NewSender: Interface "IEmail Sender")
    begin
        EmailSender := NewSender;
    end;
    
    procedure SetReportGenerator(NewGenerator: Interface "IReport Generator")
    begin
        ReportGenerator := NewGenerator;
    end;
    
    procedure ProcessNewCustomer(var Customer: Record Customer): Boolean
    begin
        // Only use validation interface - no dependency on email, reporting, etc.
        if not CustomerValidator.ValidateCustomer(Customer) then begin
            ShowValidationErrors(CustomerValidator.GetValidationErrors());
            exit(false);
        end;
        
        // Save customer
        Customer.Insert(true);
        
        // Send welcome email - only depends on email interface
        if Customer."E-Mail" <> '' then
            EmailSender.SendEmail(Customer."E-Mail", 'Welcome!', 'Welcome to our company!');
        
        exit(true);
    end;
    
    procedure GenerateCustomerAnalysis(CustomerNo: Code[20])
    begin
        // Only use reporting interface - no dependency on validation, email, etc.
        ReportGenerator.GenerateCustomerReport(CustomerNo);
    end;
    
    procedure ValidateCustomerList(var Customer: Record Customer)
    var
        ErrorMessages: List of [Text];
        ErrorMessage: Text;
    begin
        // Only use validation interface
        if Customer.FindSet() then
            repeat
                if not CustomerValidator.ValidateCustomer(Customer) then begin
                    ErrorMessages := CustomerValidator.GetValidationErrors();
                    foreach ErrorMessage in ErrorMessages do
                        Message('Customer %1: %2', Customer."No.", ErrorMessage);
                end;
            until Customer.Next() = 0;
    end;
    
    local procedure ShowValidationErrors(ValidationErrors: List of [Text])
    var
        ErrorText: Text;
    begin
        foreach ErrorText in ValidationErrors do
            Message('Validation Error: %1', ErrorText);
    end;
}
```

## Read-Only vs. Read-Write Interface Segregation

```al
// ✅ Good: Separate interfaces for different access patterns
interface "ICustomer Reader"
{
    /// <summary>
    /// Read-only interface for customer data access
    /// Used by components that only need to read customer information
    /// </summary>
    procedure GetCustomer(CustomerNo: Code[20]): Record Customer;
    procedure FindCustomersByCity(City: Text): List of [Record Customer];
    procedure CustomerExists(CustomerNo: Code[20]): Boolean;
}

interface "ICustomer Writer"
{
    /// <summary>
    /// Write interface for customer data modifications
    /// Used by components that need to modify customer data
    /// </summary>
    procedure CreateCustomer(var Customer: Record Customer): Boolean;
    procedure UpdateCustomer(var Customer: Record Customer): Boolean;
    procedure DeleteCustomer(CustomerNo: Code[20]): Boolean;
}

// Read-only implementations don't need to implement write methods
codeunit 50306 "Customer Report Reader" implements "ICustomer Reader"
{
    /// <summary>
    /// Read-only implementation - no forced write method implementation
    /// Perfect for reporting and analysis components
    /// </summary>
    
    procedure GetCustomer(CustomerNo: Code[20]): Record Customer
    var
        Customer: Record Customer;
    begin
        Customer.Get(CustomerNo);
        exit(Customer);
    end;
    
    procedure FindCustomersByCity(City: Text): List of [Record Customer]
    var
        Customer: Record Customer;
        CustomerList: List of [Record Customer];
    begin
        Customer.SetRange(City, City);
        if Customer.FindSet() then
            repeat
                CustomerList.Add(Customer);
            until Customer.Next() = 0;
        exit(CustomerList);
    end;
    
    procedure CustomerExists(CustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
    begin
        exit(Customer.Get(CustomerNo));
    end;
}

// Full CRUD implementation implements both interfaces
codeunit 50307 "Customer Data Manager" implements "ICustomer Reader", "ICustomer Writer"
{
    /// <summary>
    /// Full implementation for components that need both read and write access
    /// Implements both interfaces as needed
    /// </summary>
    
    // ICustomer Reader implementation
    procedure GetCustomer(CustomerNo: Code[20]): Record Customer
    var
        Customer: Record Customer;
    begin
        Customer.Get(CustomerNo);
        exit(Customer);
    end;
    
    procedure FindCustomersByCity(City: Text): List of [Record Customer]
    var
        Customer: Record Customer;
        CustomerList: List of [Record Customer];
    begin
        Customer.SetRange(City, City);
        if Customer.FindSet() then
            repeat
                CustomerList.Add(Customer);
            until Customer.Next() = 0;
        exit(CustomerList);
    end;
    
    procedure CustomerExists(CustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
    begin
        exit(Customer.Get(CustomerNo));
    end;
    
    // ICustomer Writer implementation
    procedure CreateCustomer(var Customer: Record Customer): Boolean
    begin
        Customer.Insert(true);
        exit(true);
    end;
    
    procedure UpdateCustomer(var Customer: Record Customer): Boolean
    begin
        Customer.Modify(true);
        exit(true);
    end;
    
    procedure DeleteCustomer(CustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
    begin
        if Customer.Get(CustomerNo) then begin
            Customer.Delete(true);
            exit(true);
        end;
        exit(false);
    end;
}
```

## Related Topics
- [Interface Segregation Principle](interface-segregation-principle.md)
- [Single Responsibility Principle](single-responsibility-principle.md)
- [Dependency Inversion Principle](dependency-inversion-principle.md)
