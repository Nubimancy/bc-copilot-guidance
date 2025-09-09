---
title: "Object Design Anti-Patterns - Code Samples"
description: "Complete code examples showing common object design mistakes and their solutions in AL"
area: "architecture-design"
difficulty: "intermediate"
object_types: ["Codeunit", "Table", "Page"]
variable_types: ["Record", ]
tags: ["anti-patterns", "object-design", "god-objects", "magic-numbers", "samples"]
---

# Object Design Anti-Patterns - Code Samples

## God Objects (Everything in One Place)

### ❌ Problem: Violates Single Responsibility Principle

```al
// Don't do this - violates Single Responsibility Principle
codeunit 50100 "Customer Everything Manager"
{
    // This object tries to do everything related to customers
    // Result: 1000+ line codeunit that's impossible to maintain
    
    procedure ValidateCustomer() // 200+ lines
    var
        Customer: Record Customer;
    begin
        // Complex validation logic
        // Credit checking
        // Address validation
        // Tax validation
        // Business rules validation
        // Integration validation
        // [200 lines of mixed concerns]
    end;
    
    procedure ProcessCustomerOrders() // 300+ lines
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // Order creation
        // Inventory checking
        // Pricing calculations
        // Discount applications
        // Tax calculations
        // Shipping calculations
        // Integration with external systems
        // Email notifications
        // [300 lines of mixed responsibilities]
    end;
    
    procedure SendNotifications() // 150+ lines
    begin
        // Email notifications
        // SMS notifications
        // Push notifications
        // Integration notifications
        // Audit notifications
        // [150 lines of notification logic]
    end;
    
    procedure GenerateReports() // 250+ lines
    begin
        // Customer statements
        // Order history reports
        // Credit reports
        // Analytics reports
        // Export functions
        // [250 lines of reporting logic]
    end;
    
    procedure IntegrateWithExternalSystems() // 400+ lines
    begin
        // CRM integration
        // Accounting system sync
        // Shipping integration
        // Payment processing
        // Tax service integration
        // [400 lines of integration logic]
    end;
}
```

### ✅ Solution: Single Responsibility Objects

```al
// ✅ Single responsibility - focused, testable, maintainable
codeunit 50100 "Customer Validator"
{
    procedure ValidateCustomer(var Customer: Record Customer): Boolean
    var
        ValidationResult: Boolean;
    begin
        ValidationResult := true;
        
        if not ValidateBasicInfo(Customer) then
            ValidationResult := false;
            
        if not ValidateCreditRules(Customer) then
            ValidationResult := false;
            
        if not ValidateBusinessRules(Customer) then
            ValidationResult := false;
            
        exit(ValidationResult);
    end;
    
    local procedure ValidateBasicInfo(Customer: Record Customer): Boolean
    begin
        if Customer.Name = '' then
            Error('Customer name is required');
            
        if Customer."No." = '' then
            Error('Customer number is required');
            
        exit(true);
    end;
    
    local procedure ValidateCreditRules(Customer: Record Customer): Boolean
    var
        CustomerCreditMgt: Codeunit "Customer Credit Management";
    begin
        exit(CustomerCreditMgt.ValidateCreditLimit(Customer));
    end;
}

codeunit 50101 "Customer Order Processor"
{
    procedure ProcessCustomerOrders(CustomerNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
        OrderValidator: Codeunit "Sales Order Validator";
        PricingEngine: Codeunit "Pricing Calculation Engine";
    begin
        SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
        SalesHeader.SetRange(Status, SalesHeader.Status::Open);
        
        if SalesHeader.FindSet() then
            repeat
                if OrderValidator.ValidateOrder(SalesHeader) then
                    PricingEngine.CalculatePricing(SalesHeader);
            until SalesHeader.Next() = 0;
    end;
}

codeunit 50102 "Customer Notification Manager"
{
    procedure SendWelcomeNotification(CustomerNo: Code[20])
    var
        Customer: Record Customer;
        EmailService: Codeunit "Email Service";
    begin
        if Customer.Get(CustomerNo) then
            EmailService.SendWelcomeEmail(Customer."E-Mail", Customer.Name);
    end;
    
    procedure SendOrderConfirmation(SalesOrderNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
        EmailService: Codeunit "Email Service";
    begin
        if SalesHeader.Get(SalesHeader."Document Type"::Order, SalesOrderNo) then
            EmailService.SendOrderConfirmation(SalesHeader);
    end;
}

codeunit 50103 "Customer Report Generator"
{
    procedure GenerateCustomerStatement(CustomerNo: Code[20])
    var
        Customer: Record Customer;
        ReportGenerator: Codeunit "Report Generation Helper";
    begin
        if Customer.Get(CustomerNo) then
            ReportGenerator.CreateCustomerStatement(Customer);
    end;
}

codeunit 50104 "Customer Integration Manager"
{
    procedure SyncToExternalCRM(CustomerNo: Code[20])
    var
        Customer: Record Customer;
        CRMIntegration: Codeunit "CRM Integration Service";
    begin
        if Customer.Get(CustomerNo) then
            CRMIntegration.SyncCustomer(Customer);
    end;
}
```

## Magic Numbers and Hardcoded Values

### ❌ Problem: Business rules buried in code

```al
// Don't do this - unclear business meaning
codeunit 50200 "Order Processing Bad Example"
{
    procedure CalculateDiscount(var SalesLine: Record "Sales Line")
    begin
        if SalesLine.Quantity > 100 then  // What's special about 100?
            SalesLine."Line Discount %" := 5;  // Why 5%?
            
        if SalesLine."Unit Price" > 50000 then  // High-value threshold?
            SalesLine."Line Discount %" := 10;  // Why 10%?
            
        if SalesLine.Type = 2 then  // What is type 2?
            SalesLine."Line Discount %" := 15;  // Service discount?
            
        // Customer status check
        if GetCustomerStatus(SalesLine."Sell-to Customer No.") = 'VIP' then
            SalesLine."Line Discount %" := 20;  // VIP discount
    end;
    
    procedure ValidateOrderValue(SalesHeader: Record "Sales Header")
    begin
        SalesHeader.CalcFields("Amount Including VAT");
        
        if SalesHeader."Amount Including VAT" > 500000 then  // Why 500,000?
            Error('Order requires approval');
            
        if SalesHeader."Amount Including VAT" < 10 then  // Minimum order?
            Error('Order too small');
    end;
}
```

### ✅ Solution: Named Constants and Enums

```al
// ✅ Named constants with business meaning
codeunit 50200 "Business Rules Constants"
{
    // Discount thresholds
    procedure GetBulkOrderQuantityThreshold(): Decimal
    begin
        exit(100); // Orders above this quantity get bulk discount
    end;
    
    procedure GetBulkOrderDiscountPercent(): Decimal
    begin
        exit(5); // 5% discount for bulk orders
    end;
    
    procedure GetHighValueOrderThreshold(): Decimal
    begin
        exit(50000); // High-value order threshold for special pricing
    end;
    
    procedure GetHighValueDiscountPercent(): Decimal
    begin
        exit(10); // 10% discount for high-value orders
    end;
    
    procedure GetServiceItemDiscountPercent(): Decimal
    begin
        exit(15); // 15% standard discount for service items
    end;
    
    procedure GetVIPCustomerDiscountPercent(): Decimal
    begin
        exit(20); // 20% VIP customer discount
    end;
    
    // Order validation thresholds
    procedure GetApprovalRequiredAmount(): Decimal
    begin
        exit(500000); // Orders above this amount require approval
    end;
    
    procedure GetMinimumOrderAmount(): Decimal
    begin
        exit(10); // Minimum viable order amount
    end;
}

// Use setup table for configurable business rules
table 50200 "Sales Setup Extension"
{
    fields
    {
        field(50000; "Bulk Order Quantity Threshold"; Decimal)
        {
            Caption = 'Bulk Order Quantity Threshold';
            InitValue = 100;
        }
        
        field(50001; "Bulk Order Discount %"; Decimal)
        {
            Caption = 'Bulk Order Discount %';
            InitValue = 5;
            DecimalPlaces = 2 : 2;
        }
        
        field(50002; "High Value Order Threshold"; Decimal)
        {
            Caption = 'High Value Order Threshold';
            InitValue = 50000;
        }
    }
}

codeunit 50201 "Order Processing Good Example"
{
    procedure CalculateDiscount(var SalesLine: Record "Sales Line")
    var
        SalesSetupExt: Record "Sales Setup Extension";
        BusinessRules: Codeunit "Business Rules Constants";
        Customer: Record Customer;
    begin
        SalesSetupExt.Get();
        
        // Bulk quantity discount - configurable business rule
        if SalesLine.Quantity > SalesSetupExt."Bulk Order Quantity Threshold" then
            SalesLine."Line Discount %" := SalesSetupExt."Bulk Order Discount %";
            
        // High-value order discount - configurable threshold
        if SalesLine."Unit Price" > SalesSetupExt."High Value Order Threshold" then
            SalesLine."Line Discount %" := BusinessRules.GetHighValueDiscountPercent();
            
        // Service item discount - enum instead of magic number
        if SalesLine.Type = SalesLine.Type::Resource then
            SalesLine."Line Discount %" := BusinessRules.GetServiceItemDiscountPercent();
            
        // VIP customer discount - clear business rule
        if GetCustomerTier(SalesLine."Sell-to Customer No.") = Customer."Customer Tier"::VIP then
            SalesLine."Line Discount %" := BusinessRules.GetVIPCustomerDiscountPercent();
    end;
    
    procedure ValidateOrderValue(SalesHeader: Record "Sales Header")
    var
        BusinessRules: Codeunit "Business Rules Constants";
    begin
        SalesHeader.CalcFields("Amount Including VAT");
        
        if SalesHeader."Amount Including VAT" > BusinessRules.GetApprovalRequiredAmount() then
            Error('Order value of %1 exceeds approval threshold of %2', 
                SalesHeader."Amount Including VAT", 
                BusinessRules.GetApprovalRequiredAmount());
                
        if SalesHeader."Amount Including VAT" < BusinessRules.GetMinimumOrderAmount() then
            Error('Order value of %1 is below minimum order amount of %2', 
                SalesHeader."Amount Including VAT", 
                BusinessRules.GetMinimumOrderAmount());
    end;
}
```

## Related Topics
- [Object Design Anti-Patterns](object-design-anti-patterns.md)
- [Code Structure Anti-Patterns](code-structure-anti-patterns.md)
- [Performance Anti-Patterns](performance-anti-patterns.md)
