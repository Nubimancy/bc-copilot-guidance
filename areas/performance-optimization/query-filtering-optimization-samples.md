---
title: "Query Filtering Optimization - Code Samples"
description: "Complete code examples for optimizing database queries through efficient filtering strategies"
area: "performance-optimization"
difficulty: "intermediate"
object_types: ["Table]
variable_types: ["Date"]
tags: ["query-filtering", "samples", "indexing", "setrange"]
---

# Query Filtering Optimization - Code Samples

## Index-Aware Filtering

```al
procedure FindCustomersWithOptimalFiltering()
var
    Customer: Record Customer;
begin
    // ✅ GOOD: Filter on indexed fields first
    Customer.SetRange("Customer Posting Group", 'DOMESTIC');  // Indexed field
    Customer.SetRange("Gen. Bus. Posting Group", 'RETAIL');   // Indexed field
    Customer.SetFilter("Credit Limit (LCY)", '>%1', 10000);   // Secondary filter
    Customer.SetLoadFields("No.", "Name", "Credit Limit (LCY)"); // Only needed fields
    
    if Customer.FindSet() then
        repeat
            // Process customer...
        until Customer.Next() = 0;
end;

procedure FindCustomersWithBadFiltering()
var
    Customer: Record Customer;
begin
    // ❌ BAD: Non-indexed fields first, loading all data
    Customer.SetFilter(Comment, '*VIP*');              // Non-indexed, string search
    Customer.SetRange("Customer Posting Group", 'DOMESTIC'); // Should be first
    // Missing SetLoadFields - loads ALL fields
    
    if Customer.FindSet() then
        repeat
            // Process customer...
        until Customer.Next() = 0;
end;
```

## Efficient Date Range Filtering

```al
procedure ProcessRecentSalesOptimally(DaysBack: Integer)
var
    SalesHeader: Record "Sales Header";
    FromDate: Date;
begin
    FromDate := CalcDate(StrSubstNo('<-%1D>', DaysBack), Today);
    
    // ✅ EFFICIENT: Use indexed date field with range
    SalesHeader.SetRange("Order Date", FromDate, Today);
    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
    SalesHeader.SetLoadFields("No.", "Order Date", "Amount Including VAT");
    
    if SalesHeader.FindSet() then
        repeat
            ProcessSalesOrder(SalesHeader);
        until SalesHeader.Next() = 0;
end;

procedure ProcessRecentSalesInefficiently(DaysBack: Integer)
var
    SalesHeader: Record "Sales Header";
    FromDate: Date;
begin
    FromDate := CalcDate(StrSubstNo('<-%1D>', DaysBack), Today);
    
    // ❌ INEFFICIENT: Filtering after loading all data
    if SalesHeader.FindSet() then
        repeat
            if (SalesHeader."Order Date" >= FromDate) and 
               (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) then
                ProcessSalesOrder(SalesHeader);
        until SalesHeader.Next() = 0;
end;
```

## Complex Filter Optimization

```al
procedure FindItemsWithComplexFilters()
var
    Item: Record Item;
    ItemLedgerEntry: Record "Item Ledger Entry";
begin
    // ✅ OPTIMAL: Start with most selective filters
    Item.SetRange(Blocked, false);                    // Highly selective
    Item.SetRange("Item Category Code", 'ELECTRONICS'); // Indexed, selective
    Item.SetRange("Base Unit of Measure", 'PCS');     // Common, indexed
    Item.SetFilter("Unit Cost", '>%1', 100);          // Numeric filter last
    Item.SetLoadFields("No.", "Description", "Unit Cost", "Inventory");
    
    if Item.FindSet() then
        repeat
            // Check inventory level without additional query
            if Item.Inventory > 0 then
                ProcessItem(Item);
        until Item.Next() = 0;
end;

procedure FindItemsWithSuboptimalFilters()
var
    Item: Record Item;
    ItemLedgerEntry: Record "Item Ledger Entry";
begin
    // ❌ SUBOPTIMAL: Expensive operations first
    if Item.FindSet() then // No filters = full table scan
        repeat
            // Expensive per-record database queries
            ItemLedgerEntry.SetRange("Item No.", Item."No.");
            ItemLedgerEntry.CalcSums(Quantity);
            
            if (not Item.Blocked) and 
               (Item."Item Category Code" = 'ELECTRONICS') and 
               (ItemLedgerEntry.Quantity > 0) then
                ProcessItem(Item);
        until Item.Next() = 0;
end;
```

## Multi-Table Join Optimization

```al
procedure GetCustomerOrderSummary()
var
    Customer: Record Customer;
    SalesHeader: Record "Sales Header";
    SalesLine: Record "Sales Line";
    TempSummary: Record "Customer Summary" temporary;
begin
    // ✅ EFFICIENT: Pre-filter all tables, then join
    
    // Step 1: Get active customers only
    Customer.SetRange(Blocked, Customer.Blocked::" ");
    Customer.SetLoadFields("No.", "Name");
    
    // Step 2: Get recent orders only
    SalesHeader.SetRange("Order Date", CalcDate('<-3M>', Today), Today);
    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
    SalesHeader.SetLoadFields("No.", "Sell-to Customer No.", "Order Date");
    
    // Step 3: Get order lines with amounts
    SalesLine.SetLoadFields("Document No.", "Line Amount");
    
    // Step 4: Build summary in memory
    if SalesHeader.FindSet() then
        repeat
            if Customer.Get(SalesHeader."Sell-to Customer No.") then begin
                TempSummary."Customer No." := Customer."No.";
                TempSummary."Customer Name" := Customer.Name;
                
                // Calculate line totals for this order
                SalesLine.SetRange("Document No.", SalesHeader."No.");
                SalesLine.CalcSums("Line Amount");
                TempSummary."Order Total" := SalesLine."Line Amount";
                
                TempSummary.Insert();
            end;
        until SalesHeader.Next() = 0;
end;
```

## Related Topics
- [Query Filtering Optimization](query-filtering-optimization.md)
- [Database Performance Measurement](database-performance-measurement.md)
- [N+1 Query Problem](n-plus-one-query-problem.md)
