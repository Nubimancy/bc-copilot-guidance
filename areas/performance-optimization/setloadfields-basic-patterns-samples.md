---
title: "SetLoadFields Basic Patterns - Code Samples"
description: "Complete code examples for essential SetLoadFields optimization patterns in AL"
area: "performance-optimization"
difficulty: "intermediate"
object_types: ["Codeunit", "Table", "Report"]
variable_types: ["Record", ]
tags: ["setloadfields", "performance", "optimization", "samples", "basic-patterns"]
---

# SetLoadFields Basic Patterns - Code Samples

## Essential Customer Processing

```al
codeunit 50600 "Customer Processing Optimized"
{
    procedure ProcessCustomersEfficiently()
    var
        Customer: Record Customer;
        ProcessedCount: Integer;
    begin
        // Load only the fields needed for processing
        Customer.SetLoadFields("No.", "Name", "Credit Limit (LCY)", "Balance (LCY)");
        Customer.SetRange(Blocked, Customer.Blocked::" ");
        
        if Customer.FindSet() then
            repeat
                // Process only loaded fields for optimal performance
                if Customer."Balance (LCY)" > Customer."Credit Limit (LCY)" then
                    ProcessOverLimitCustomer(Customer."No.", Customer.Name);
                ProcessedCount += 1;
            until Customer.Next() = 0;
        
        Message('Processed %1 customers efficiently', ProcessedCount);
    end;
    
    local procedure ProcessOverLimitCustomer(CustomerNo: Code[20]; CustomerName: Text[100])
    begin
        // Process customer who is over credit limit
        Message('Customer %1 (%2) is over credit limit', CustomerNo, CustomerName);
    end;
}
```

## Basic Report Data Collection

```al
codeunit 50601 "Sales Report Data Collection"
{
    procedure CollectSalesLineData()
    var
        SalesLine: Record "Sales Line";
        ReportData: Record "Sales Report Data" temporary;
        TotalAmount: Decimal;
    begin
        // Only load fields needed for the report
        SalesLine.SetLoadFields("Document No.", "Line No.", "No.", Description, Quantity, "Unit Price", "Line Amount");
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        
        if SalesLine.FindSet() then
            repeat
                ReportData.Init();
                ReportData."Document No." := SalesLine."Document No.";
                ReportData."Line No." := SalesLine."Line No.";
                ReportData."Item No." := SalesLine."No.";
                ReportData."Description" := SalesLine.Description;
                ReportData."Quantity" := SalesLine.Quantity;
                ReportData."Unit Price" := SalesLine."Unit Price";
                ReportData."Line Amount" := SalesLine."Line Amount";
                ReportData.Insert();
                
                TotalAmount += SalesLine."Line Amount";
            until SalesLine.Next() = 0;
            
        Message('Collected %1 sales lines with total amount %2', SalesLine.Count, TotalAmount);
    end;
}
```

## Item Inventory Processing

```al
codeunit 50602 "Item Processing Optimized"
{
    procedure ProcessLowStockItems()
    var
        Item: Record Item;
        ProcessedItems: Integer;
        LowStockThreshold: Decimal;
    begin
        LowStockThreshold := 10; // Business rule: reorder when stock below 10
        
        // Load only essential item fields for stock processing
        Item.SetLoadFields("No.", Description, Inventory, "Reorder Point", "Vendor No.");
        Item.SetRange(Type, Item.Type::Inventory);
        Item.SetFilter(Inventory, '<%1', LowStockThreshold);
        
        if Item.FindSet() then
            repeat
                ProcessLowStockItem(Item);
                ProcessedItems += 1;
            until Item.Next() = 0;
            
        Message('Processed %1 low stock items', ProcessedItems);
    end;
    
    local procedure ProcessLowStockItem(Item: Record Item)
    var
        PurchaseOrderMgmt: Codeunit "Purchase Order Management";
    begin
        if Item.Inventory < Item."Reorder Point" then begin
            // Create purchase order or notification
            if Item."Vendor No." <> '' then
                PurchaseOrderMgmt.CreateReorderSuggestion(Item."No.", Item."Vendor No.")
            else
                LogReorderAlert(Item."No.", Item.Description);
        end;
    end;
    
    local procedure LogReorderAlert(ItemNo: Code[20]; ItemDescription: Text[100])
    begin
        // Log alert for items without vendor
        Message('Alert: Item %1 (%2) needs reordering but has no vendor assigned', ItemNo, ItemDescription);
    end;
}
```

## Customer Validation Processing

```al
codeunit 50603 "Customer Validation Optimized"
{
    procedure ValidateCustomerSetup()
    var
        Customer: Record Customer;
        ValidationErrors: Integer;
    begin
        // Load only fields needed for validation
        Customer.SetLoadFields("No.", "Name", "Customer Posting Group", "Payment Terms Code", "Payment Method Code");
        
        if Customer.FindSet() then
            repeat
                if not ValidateCustomerConfiguration(Customer) then
                    ValidationErrors += 1;
            until Customer.Next() = 0;
            
        if ValidationErrors > 0 then
            Message('Found %1 customers with configuration errors', ValidationErrors)
        else
            Message('All customers passed validation');
    end;
    
    local procedure ValidateCustomerConfiguration(Customer: Record Customer): Boolean
    var
        ValidationPassed: Boolean;
    begin
        ValidationPassed := true;
        
        // Check required posting group
        if Customer."Customer Posting Group" = '' then begin
            LogValidationError(Customer."No.", 'Missing Customer Posting Group');
            ValidationPassed := false;
        end;
        
        // Check payment terms
        if Customer."Payment Terms Code" = '' then begin
            LogValidationError(Customer."No.", 'Missing Payment Terms Code');
            ValidationPassed := false;
        end;
        
        // Check payment method for certain customer categories
        if Customer."Payment Method Code" = '' then begin
            LogValidationError(Customer."No.", 'Missing Payment Method Code');
            ValidationPassed := false;
        end;
        
        exit(ValidationPassed);
    end;
    
    local procedure LogValidationError(CustomerNo: Code[20]; ErrorMessage: Text)
    begin
        Message('Customer %1: %2', CustomerNo, ErrorMessage);
    end;
}
```

## Order Processing with SetLoadFields

```al
codeunit 50604 "Order Processing Performance"
{
    procedure ProcessPendingOrders()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ProcessedOrders: Integer;
    begin
        // Load only essential sales header fields
        SalesHeader.SetLoadFields("Document Type", "No.", "Sell-to Customer No.", "Order Date", Status);
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange(Status, SalesHeader.Status::Open);
        SalesHeader.SetFilter("Order Date", '>=%1', CalcDate('<-30D>', Today)); // Last 30 days
        
        if SalesHeader.FindSet() then
            repeat
                if ProcessOrderLines(SalesHeader."No.") then
                    ProcessedOrders += 1;
            until SalesHeader.Next() = 0;
            
        Message('Successfully processed %1 pending orders', ProcessedOrders);
    end;
    
    local procedure ProcessOrderLines(DocumentNo: Code[20]): Boolean
    var
        SalesLine: Record "Sales Line";
        AllLinesProcessed: Boolean;
    begin
        AllLinesProcessed := true;
        
        // Load only fields needed for line processing
        SalesLine.SetLoadFields("Document No.", "Line No.", Type, "No.", Quantity, "Qty. to Ship");
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", DocumentNo);
        SalesLine.SetFilter("Qty. to Ship", '>0');
        
        if SalesLine.FindSet() then
            repeat
                if not ProcessSalesLine(SalesLine) then
                    AllLinesProcessed := false;
            until SalesLine.Next() = 0;
            
        exit(AllLinesProcessed);
    end;
    
    local procedure ProcessSalesLine(SalesLine: Record "Sales Line"): Boolean
    begin
        // Process individual sales line
        if SalesLine.Type = SalesLine.Type::Item then begin
            // Check inventory and process shipping
            exit(CheckInventoryAndShip(SalesLine."No.", SalesLine.Quantity));
        end;
        
        exit(true); // Non-item lines don't need inventory check
    end;
    
    local procedure CheckInventoryAndShip(ItemNo: Code[20]; RequiredQty: Decimal): Boolean
    var
        Item: Record Item;
    begin
        // Load only inventory field for stock check
        Item.SetLoadFields(Inventory);
        if Item.Get(ItemNo) then
            exit(Item.Inventory >= RequiredQty);
            
        exit(false);
    end;
}
```

## Performance Comparison Example

```al
codeunit 50605 "Performance Comparison Demo"
{
    procedure DemonstratePerformanceDifference()
    begin
        Message('Processing without SetLoadFields...');
        ProcessCustomersWithoutOptimization();
        
        Message('Processing with SetLoadFields...');
        ProcessCustomersWithOptimization();
        
        Message('Performance demonstration complete. Check the difference!');
    end;
    
    local procedure ProcessCustomersWithoutOptimization()
    var
        Customer: Record Customer;
        StartTime: DateTime;
        EndTime: DateTime;
        ProcessedCount: Integer;
    begin
        StartTime := CurrentDateTime;
        
        // NO SetLoadFields - loads ALL 200+ fields
        if Customer.FindSet() then
            repeat
                // Only using 2 fields, but loaded everything
                if Customer."No." <> '' then
                    ProcessedCount += 1;
            until Customer.Next() = 0;
            
        EndTime := CurrentDateTime;
        Message('Processed %1 customers in %2ms (WITHOUT SetLoadFields)', 
            ProcessedCount, EndTime - StartTime);
    end;
    
    local procedure ProcessCustomersWithOptimization()
    var
        Customer: Record Customer;
        StartTime: DateTime;
        EndTime: DateTime;
        ProcessedCount: Integer;
    begin
        StartTime := CurrentDateTime;
        
        // WITH SetLoadFields - loads only needed fields
        Customer.SetLoadFields("No.");
        if Customer.FindSet() then
            repeat
                // Only using 1 field, only loaded 1 field
                if Customer."No." <> '' then
                    ProcessedCount += 1;
            until Customer.Next() = 0;
            
        EndTime := CurrentDateTime;
        Message('Processed %1 customers in %2ms (WITH SetLoadFields)', 
            ProcessedCount, EndTime - StartTime);
    end;
}
```

## Related Topics
- [SetLoadFields Basic Patterns](setloadfields-basic-patterns.md)
- [SetLoadFields Advanced Scenarios](setloadfields-advanced-scenarios.md)
- [SetLoadFields Performance Measurement](setloadfields-performance-measurement.md)
