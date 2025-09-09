---
title: "N+1 Query Problem - Code Samples"
description: "Complete code examples demonstrating how to identify and solve N+1 query performance issues"
area: "performance-optimization"
difficulty: "intermediate"
object_types: ["Table]
variable_types: []
tags: ["n-plus-one", "samples", "performance", "database-optimization"]
---

# N+1 Query Problem - Code Samples

## ❌ BEFORE: Inefficient Nested Queries

```al
// DON'T DO THIS - Database calls inside loops
procedure CalculateCustomerTotalsInefficient()
var
    Customer: Record Customer;
    SalesHeader: Record "Sales Header";
    SalesLine: Record "Sales Line";
    TotalAmount: Decimal;
begin
    if Customer.FindSet() then // Query #1
        repeat
            // Query #2, #3, #4... - One per customer!
            SalesHeader.SetRange("Sell-to Customer No.", Customer."No.");
            if SalesHeader.FindSet() then
                repeat
                    // Query #2a, #2b, #2c... - One per sales header!
                    SalesLine.SetRange("Document No.", SalesHeader."No.");
                    SalesLine.CalcSums("Line Amount");
                    TotalAmount += SalesLine."Line Amount";
                until SalesHeader.Next() = 0;
            // Process customer with total...
        until Customer.Next() = 0;
end;

// RESULT: 100 customers = 100+ database queries = SLOW!
```

## ✅ AFTER: Optimized Bulk Operations

```al
// DO THIS - Bulk operations with minimal database calls
procedure CalculateCustomerTotalsOptimized()
var
    Customer: Record Customer;
    SalesLine: Record "Sales Line";
    TempCustomerTotals: Record "Customer Totals" temporary;
begin
    // Step 1: Load only required customer fields (Query #1)
    Customer.SetLoadFields("No.", "Name");
    Customer.SetRange(Blocked, Customer.Blocked::" ");
    
    // Step 2: Bulk load ALL sales data in one query (Query #2)
    SalesLine.SetLoadFields("Sell-to Customer No.", "Line Amount");
    SalesLine.SetRange("Document Date", CalcDate('<-1Y>', Today), Today);
    
    // Step 3: Process in memory using temporary tables (No database calls)
    if SalesLine.FindSet() then
        repeat
            TempCustomerTotals.Reset();
            TempCustomerTotals.SetRange("Customer No.", SalesLine."Sell-to Customer No.");
            if TempCustomerTotals.FindFirst() then begin
                TempCustomerTotals."Total Amount" += SalesLine."Line Amount";
                TempCustomerTotals.Modify();
            end else begin
                TempCustomerTotals.Init();
                TempCustomerTotals."Customer No." := SalesLine."Sell-to Customer No.";
                TempCustomerTotals."Total Amount" := SalesLine."Line Amount";
                TempCustomerTotals.Insert();
            end;
        until SalesLine.Next() = 0;
    
    // Step 4: Final processing with minimal database operations (Query #3)
    if Customer.FindSet() then
        repeat
            TempCustomerTotals.SetRange("Customer No.", Customer."No.");
            if TempCustomerTotals.FindFirst() then
                ProcessCustomerTotal(Customer."No.", Customer.Name, TempCustomerTotals."Total Amount");
        until Customer.Next() = 0;
end;

// RESULT: 100 customers = 3 database queries = FAST!
```

## Common N+1 Anti-Patterns

```al
// ❌ Anti-pattern: Loading related data in loops
procedure BadInventoryReport()
var
    Item: Record Item;
    ItemLedgerEntry: Record "Item Ledger Entry";
    StockLevel: Decimal;
begin
    if Item.FindSet() then
        repeat
            // BAD: One query per item
            ItemLedgerEntry.SetRange("Item No.", Item."No.");
            ItemLedgerEntry.CalcSums(Quantity);
            StockLevel := ItemLedgerEntry.Quantity;
            
            // Process each item...
        until Item.Next() = 0;
end;

// ✅ Better: Pre-load all data
procedure GoodInventoryReport()
var
    Item: Record Item;
    ItemLedgerEntry: Record "Item Ledger Entry";
    TempItemStock: Record "Item Stock Buffer" temporary;
begin
    // Load all stock data at once
    if ItemLedgerEntry.FindSet() then
        repeat
            TempItemStock."Item No." := ItemLedgerEntry."Item No.";
            if TempItemStock.Find() then begin
                TempItemStock.Quantity += ItemLedgerEntry.Quantity;
                TempItemStock.Modify();
            end else begin
                TempItemStock.Quantity := ItemLedgerEntry.Quantity;
                TempItemStock.Insert();
            end;
        until ItemLedgerEntry.Next() = 0;
    
    // Process items with pre-loaded data
    if Item.FindSet() then
        repeat
            if TempItemStock.Get(Item."No.") then
                ProcessItem(Item, TempItemStock.Quantity);
        until Item.Next() = 0;
end;
```

## Related Topics
- [N+1 Query Problem](n-plus-one-query-problem.md)
- [Bulk Processing Patterns](bulk-processing-patterns.md)
- [Database Performance Measurement](database-performance-measurement.md)
