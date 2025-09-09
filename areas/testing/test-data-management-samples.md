---
title: "Test Data Management - Code Samples"
description: "Complete code examples for creating, managing, and organizing test data in AL testing"
area: "testing"
difficulty: "intermediate"
object_types: ["Codeunit", "Table]
variable_types: []
tags: ["test-data", "data-management", "helper-methods", "samples"]
---

# Test Data Management - Code Samples

## Scenario-Specific Test Data Creation

```al
// Test data factory methods for different customer scenarios
local procedure CreateTierTwoCustomer(var Customer: Record Customer)
begin
    Customer.Init();
    Customer."No." := 'XTEST-TIER2-001';
    Customer.Name := 'XTest Tier 2 Customer';
    Customer."Customer Tier" := Customer."Customer Tier"::"Tier 2";
    Customer."Credit Limit (LCY)" := 5000;
    Customer.Insert(true);
end;

local procedure CreateStandardCustomer(var Customer: Record Customer)
begin
    Customer.Init();
    Customer."No." := 'XTEST-STD-001';
    Customer.Name := 'XTest Standard Customer';
    Customer."Customer Tier" := Customer."Customer Tier"::Standard;
    Customer."Credit Limit (LCY)" := 1000;
    Customer.Insert(true);
end;

local procedure CreateVIPCustomer(var Customer: Record Customer)
begin
    Customer.Init();
    Customer."No." := 'XTEST-VIP-001';
    Customer.Name := 'XTest VIP Customer';
    Customer."Customer Tier" := Customer."Customer Tier"::VIP;
    Customer."Credit Limit (LCY)" := 10000;
    Customer."Allow Line Disc." := true;
    Customer.Insert(true);
end;

local procedure CreateBlockedCustomer(var Customer: Record Customer)
begin
    Customer.Init();
    Customer."No." := 'XTEST-BLOCKED-001';
    Customer.Name := 'XTest Blocked Customer';
    Customer.Blocked := Customer.Blocked::All;
    Customer.Insert(true);
end;
```

## Complex Test Data Setup with Relationships

```al
local procedure CreateSalesOrderWithAmount(var SalesHeader: Record "Sales Header"; CustomerNo: Code[20]; Amount: Decimal)
var
    SalesLine: Record "Sales Line";
begin
    // Create sales header
    SalesHeader.Init();
    SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
    SalesHeader."No." := GetNextTestOrderNo();
    SalesHeader."Sell-to Customer No." := CustomerNo;
    SalesHeader."Order Date" := Today;
    SalesHeader.Insert(true);
    
    // Create sales line with specified amount
    SalesLine.Init();
    SalesLine."Document Type" := SalesHeader."Document Type";
    SalesLine."Document No." := SalesHeader."No.";
    SalesLine."Line No." := 10000;
    SalesLine.Type := SalesLine.Type::Item;
    SalesLine."No." := EnsureTestItemExists();
    SalesLine.Quantity := 1;
    SalesLine."Unit Price" := Amount;
    SalesLine.Insert(true);
end;

local procedure CreateSalesLineWithQuantity(var SalesLine: Record "Sales Line"; CustomerNo: Code[20]; Quantity: Decimal)
var
    SalesHeader: Record "Sales Header";
begin
    // Create parent order
    CreateBasicSalesOrder(SalesHeader, CustomerNo);
    
    // Create line with specific quantity
    SalesLine.Init();
    SalesLine."Document Type" := SalesHeader."Document Type";
    SalesLine."Document No." := SalesHeader."No.";
    SalesLine."Line No." := 10000;
    SalesLine.Type := SalesLine.Type::Item;
    SalesLine."No." := EnsureTestItemExists();
    SalesLine.Quantity := Quantity;
    SalesLine."Unit Price" := 100; // Standard test price
    SalesLine.Insert(true);
end;
```

## Test Helper and Utility Methods

```al
local procedure GetNextTestOrderNo(): Code[20]
var
    TestCounter: Integer;
begin
    TestCounter := GetTestCounterValue('SALES_ORDER');
    IncrementTestCounter('SALES_ORDER');
    exit(StrSubstNo('XTEST-SO-%1', Format(TestCounter, 0, '<Integer,3><Filler Character,0>')));
end;

local procedure EnsureTestItemExists(): Code[20]
var
    Item: Record Item;
    ItemNo: Code[20];
begin
    ItemNo := 'XTEST-ITEM-001';
    
    if not Item.Get(ItemNo) then begin
        Item.Init();
        Item."No." := ItemNo;
        Item.Description := 'XTest Standard Item';
        Item.Type := Item.Type::Inventory;
        Item."Base Unit of Measure" := 'PCS';
        Item."Unit Price" := 100;
        Item.Insert(true);
        
        // Ensure inventory exists
        CreateTestInventory(ItemNo, 1000);
    end;
    
    exit(ItemNo);
end;

local procedure CalculateExpectedPointsForTier(Amount: Decimal; CustomerTier: Enum "Customer Tier"): Integer
begin
    case CustomerTier of
        CustomerTier::"Tier 1":
            exit(Round(Amount * 0.02, 1)); // 2% for tier 1
        CustomerTier::"Tier 2":
            exit(Round(Amount * 0.05, 1)); // 5% for tier 2
        CustomerTier::"Tier 3":
            exit(Round(Amount * 0.10, 1)); // 10% for tier 3
    end;
end;

local procedure CustomerPointsUpdated(CustomerNo: Code[20]): Boolean
var
    Customer: Record Customer;
begin
    Customer.Get(CustomerNo);
    exit(Customer."Loyalty Points" > 0);
end;
```

## Test Data Builder Pattern

```al
codeunit 50401 "Test Customer Builder"
{
    var
        Customer: Record Customer;
        IsInitialized: Boolean;
    
    procedure Create(): Record Customer
    begin
        if not IsInitialized then
            InitializeDefaults();
            
        Customer.Insert(true);
        Clear(Customer);
        IsInitialized := false;
        exit(Customer);
    end;
    
    procedure WithNumber(CustomerNo: Code[20]): Codeunit "Test Customer Builder"
    begin
        EnsureInitialized();
        Customer."No." := CustomerNo;
        exit(this);
    end;
    
    procedure WithName(Name: Text[100]): Codeunit "Test Customer Builder"
    begin
        EnsureInitialized();
        Customer.Name := Name;
        exit(this);
    end;
    
    procedure WithTier(Tier: Enum "Customer Tier"): Codeunit "Test Customer Builder"
    begin
        EnsureInitialized();
        Customer."Customer Tier" := Tier;
        exit(this);
    end;
    
    procedure WithCreditLimit(CreditLimit: Decimal): Codeunit "Test Customer Builder"
    begin
        EnsureInitialized();
        Customer."Credit Limit (LCY)" := CreditLimit;
        exit(this);
    end;
    
    procedure Blocked(): Codeunit "Test Customer Builder"
    begin
        EnsureInitialized();
        Customer.Blocked := Customer.Blocked::All;
        exit(this);
    end;
    
    local procedure InitializeDefaults()
    begin
        Customer.Init();
        Customer."No." := GetNextTestCustomerNo();
        Customer.Name := 'Test Customer';
        Customer."Customer Tier" := Customer."Customer Tier"::Standard;
        Customer."Credit Limit (LCY)" := 1000;
        IsInitialized := true;
    end;
    
    local procedure EnsureInitialized()
    begin
        if not IsInitialized then
            InitializeDefaults();
    end;
    
    local procedure GetNextTestCustomerNo(): Code[20]
    var
        TestCounter: Integer;
    begin
        TestCounter := GetTestCounterValue('CUSTOMER');
        IncrementTestCounter('CUSTOMER');
        exit(StrSubstNo('XTEST-CUST-%1', Format(TestCounter, 0, '<Integer,3><Filler Character,0>')));
    end;
}

// Usage example:
local procedure CreateComplexTestScenario()
var
    Customer: Record Customer;
    CustomerBuilder: Codeunit "Test Customer Builder";
begin
    Customer := CustomerBuilder
        .WithName('High Value VIP Customer')
        .WithTier(Customer."Customer Tier"::VIP)
        .WithCreditLimit(50000)
        .Create();
end;
```

## Test Data Cleanup Patterns

```al
local procedure CleanupTestData()
var
    Customer: Record Customer;
    SalesHeader: Record "Sales Header";
    Item: Record Item;
begin
    // Clean up test customers
    Customer.SetFilter("No.", 'XTEST-*');
    Customer.DeleteAll(true);
    
    // Clean up test sales orders
    SalesHeader.SetFilter("No.", 'XTEST-*');
    SalesHeader.DeleteAll(true);
    
    // Clean up test items
    Item.SetFilter("No.", 'XTEST-*');
    Item.DeleteAll(true);
end;

[TearDown]
procedure TearDown()
begin
    CleanupTestData();
end;
```

## Related Topics
- [Test Data Management](test-data-management.md)
- [Business Logic Testing Patterns](business-logic-testing-patterns.md)
- [Boundary Condition Testing](boundary-condition-testing.md)
