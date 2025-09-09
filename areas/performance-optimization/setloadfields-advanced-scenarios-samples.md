---
title: "SetLoadFields Advanced Scenarios - Code Samples"
description: "Complete code examples for complex SetLoadFields optimization scenarios in AL"
area: "performance-optimization"
difficulty: "advanced"
object_types: ["Codeunit", "Table", "Report"]
variable_types: ["Record", "DateTime"]
tags: ["setloadfields", "advanced-patterns", "complex-scenarios", "samples", "multi-table"]
---

# SetLoadFields Advanced Scenarios - Code Samples

## Calculated Fields with Related Tables

```al
codeunit 50700 "Customer Statistics Advanced"
{
    procedure GetCustomerStatistics(var TempCustomerStats: Record "Customer Statistics" temporary)
    var
        Customer: Record Customer;
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
    begin
        // Efficient customer data loading
        Customer.SetLoadFields("No.", "Name", "Customer Posting Group");
        if Customer.FindSet() then
            repeat
                TempCustomerStats.Init();
                TempCustomerStats."Customer No." := Customer."No.";
                TempCustomerStats."Customer Name" := Customer.Name;
                
                // Efficient ledger entry processing with SetLoadFields
                CustomerLedgerEntry.SetLoadFields("Remaining Amount", "Amount");
                CustomerLedgerEntry.SetRange("Customer No.", Customer."No.");
                CustomerLedgerEntry.SetRange(Open, true);
                CustomerLedgerEntry.CalcSums("Remaining Amount");
                TempCustomerStats."Outstanding Amount" := CustomerLedgerEntry."Remaining Amount";
                
                TempCustomerStats.Insert();
            until Customer.Next() = 0;
    end;
}
```

## Complex Multi-Table Analysis

```al
codeunit 50701 "Customer Purchase Analysis"
{
    procedure AnalyzeCustomerPurchasePatterns()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CustomerAnalysis: Record "Customer Analysis" temporary;
        TotalAmount: Decimal;
    begin
        // Load only essential customer fields
        Customer.SetLoadFields("No.", "Name", "ABC Customer Category");
        Customer.SetRange("ABC Customer Category", Customer."ABC Customer Category"::Premium);
        
        if Customer.FindSet() then
            repeat
                Clear(CustomerAnalysis);
                CustomerAnalysis."Customer No." := Customer."No.";
                CustomerAnalysis."Customer Name" := Customer.Name;
                
                // Efficient sales analysis with minimal field loading
                SalesHeader.SetLoadFields("No.", "Sell-to Customer No.", "Document Date");
                SalesHeader.SetRange("Sell-to Customer No.", Customer."No.");
                SalesHeader.SetRange("Document Date", CalcDate('<-1Y>', Today), Today);
                
                if SalesHeader.FindSet() then
                    repeat
                        SalesLine.SetLoadFields("Document No.", "Line Amount");
                        SalesLine.SetRange("Document No.", SalesHeader."No.");
                        SalesLine.CalcSums("Line Amount");
                        TotalAmount += SalesLine."Line Amount";
                    until SalesHeader.Next() = 0;
                
                CustomerAnalysis."Total Purchase Amount" := TotalAmount;
                CustomerAnalysis.Insert();
                TotalAmount := 0;
            until Customer.Next() = 0;
    end;
    
    procedure AnalyzeItemSalesPerformance()
    var
        Item: Record Item;
        SalesLine: Record "Sales Line";
        ItemAnalysis: Record "Item Analysis" temporary;
        TotalQuantitySold: Decimal;
        TotalRevenue: Decimal;
        LastSaleDate: Date;
    begin
        // Load only essential item fields for analysis
        Item.SetLoadFields("No.", Description, "Item Category Code", "Product Group Code");
        Item.SetRange(Type, Item.Type::Inventory);
        
        if Item.FindSet() then
            repeat
                Clear(ItemAnalysis);
                ItemAnalysis."Item No." := Item."No.";
                ItemAnalysis.Description := Item.Description;
                ItemAnalysis."Item Category Code" := Item."Item Category Code";
                
                // Analyze sales performance with optimized field loading
                SalesLine.SetLoadFields("No.", Quantity, "Line Amount", "Shipment Date");
                SalesLine.SetRange("No.", Item."No.");
                SalesLine.SetRange(Type, SalesLine.Type::Item);
                SalesLine.SetFilter("Shipment Date", '>=%1', CalcDate('<-1Y>', Today));
                
                TotalQuantitySold := 0;
                TotalRevenue := 0;
                LastSaleDate := 0D;
                
                if SalesLine.FindSet() then
                    repeat
                        TotalQuantitySold += SalesLine.Quantity;
                        TotalRevenue += SalesLine."Line Amount";
                        if SalesLine."Shipment Date" > LastSaleDate then
                            LastSaleDate := SalesLine."Shipment Date";
                    until SalesLine.Next() = 0;
                
                ItemAnalysis."Total Quantity Sold" := TotalQuantitySold;
                ItemAnalysis."Total Revenue" := TotalRevenue;
                ItemAnalysis."Last Sale Date" := LastSaleDate;
                ItemAnalysis."Average Unit Price" := CalculateAverageUnitPrice(TotalRevenue, TotalQuantitySold);
                ItemAnalysis.Insert();
            until Item.Next() = 0;
    end;
    
    local procedure CalculateAverageUnitPrice(TotalRevenue: Decimal; TotalQuantity: Decimal): Decimal
    begin
        if TotalQuantity <> 0 then
            exit(TotalRevenue / TotalQuantity);
        exit(0);
    end;
}
```

## Advanced Filtering with Dynamic SetLoadFields

```al
codeunit 50702 "Dynamic Report Generation"
{
    procedure GenerateCustomerReport(ShowFinancials: Boolean; ShowSalesData: Boolean; ShowContactInfo: Boolean)
    var
        Customer: Record Customer;
        FieldList: List of [Text];
        FieldName: Text;
    begin
        // Build dynamic field list based on report requirements
        BuildFieldList(FieldList, ShowFinancials, ShowSalesData, ShowContactInfo);
        
        // Apply dynamic SetLoadFields
        Customer.SetLoadFields(FieldList);
        
        if Customer.FindSet() then
            repeat
                ProcessCustomerForReport(Customer, ShowFinancials, ShowSalesData, ShowContactInfo);
            until Customer.Next() = 0;
    end;
    
    local procedure BuildFieldList(var FieldList: List of [Text]; ShowFinancials: Boolean; ShowSalesData: Boolean; ShowContactInfo: Boolean)
    begin
        // Always include basic identification fields
        FieldList.Add('No.');
        FieldList.Add('Name');
        
        // Conditionally add fields based on report parameters
        if ShowFinancials then begin
            FieldList.Add('Credit Limit (LCY)');
            FieldList.Add('Balance (LCY)');
            FieldList.Add('Payment Terms Code');
            FieldList.Add('Payment Method Code');
        end;
        
        if ShowSalesData then begin
            FieldList.Add('Sales (LCY)');
            FieldList.Add('Last Date Modified');
            FieldList.Add('ABC Customer Category');
        end;
        
        if ShowContactInfo then begin
            FieldList.Add('Address');
            FieldList.Add('City');
            FieldList.Add('Post Code');
            FieldList.Add('Phone No.');
            FieldList.Add('E-Mail');
            FieldList.Add('Contact');
        end;
    end;
    
    local procedure ProcessCustomerForReport(Customer: Record Customer; ShowFinancials: Boolean; ShowSalesData: Boolean; ShowContactInfo: Boolean)
    begin
        // Process customer data based on what fields were loaded
        ProcessBasicCustomerInfo(Customer);
        
        if ShowFinancials then
            ProcessFinancialData(Customer);
            
        if ShowSalesData then
            ProcessSalesData(Customer);
            
        if ShowContactInfo then
            ProcessContactInfo(Customer);
    end;
}
```

## Complex Calculated Fields and FlowFields

```al
codeunit 50703 "Advanced FlowField Processing"
{
    procedure CalculateCustomerMetrics()
    var
        Customer: Record Customer;
        CustomerMetrics: Record "Customer Metrics" temporary;
    begin
        // Load fields needed for FlowField calculations
        Customer.SetLoadFields("No.", "Name", "Sales (LCY)", "Balance (LCY)", "Balance Due (LCY)");
        
        if Customer.FindSet() then
            repeat
                // Calculate FlowFields efficiently
                Customer.CalcFields("Sales (LCY)", "Balance (LCY)", "Balance Due (LCY)");
                
                CustomerMetrics.Init();
                CustomerMetrics."Customer No." := Customer."No.";
                CustomerMetrics."Customer Name" := Customer.Name;
                CustomerMetrics."Total Sales" := Customer."Sales (LCY)";
                CustomerMetrics."Current Balance" := Customer."Balance (LCY)";
                CustomerMetrics."Overdue Balance" := Customer."Balance Due (LCY)";
                
                // Calculate derived metrics
                CustomerMetrics."Credit Utilization %" := CalculateCreditUtilization(Customer);
                CustomerMetrics."Payment Performance Score" := CalculatePaymentScore(Customer);
                
                CustomerMetrics.Insert();
            until Customer.Next() = 0;
    end;
    
    procedure GenerateVendorAnalysis()
    var
        Vendor: Record Vendor;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PurchaseLine: Record "Purchase Line";
        VendorAnalysis: Record "Vendor Analysis" temporary;
        PurchaseAmount: Decimal;
        PaymentTermsScore: Decimal;
    begin
        // Multi-table analysis with optimized field loading
        Vendor.SetLoadFields("No.", "Name", "Payment Terms Code", "Currency Code");
        
        if Vendor.FindSet() then
            repeat
                Clear(VendorAnalysis);
                VendorAnalysis."Vendor No." := Vendor."No.";
                VendorAnalysis."Vendor Name" := Vendor.Name;
                
                // Calculate purchase volume with SetLoadFields
                PurchaseLine.SetLoadFields("Buy-from Vendor No.", "Line Amount");
                PurchaseLine.SetRange("Buy-from Vendor No.", Vendor."No.");
                PurchaseLine.SetFilter("Expected Receipt Date", '>=%1', CalcDate('<-1Y>', Today));
                PurchaseLine.CalcSums("Line Amount");
                PurchaseAmount := PurchaseLine."Line Amount";
                VendorAnalysis."Annual Purchase Volume" := PurchaseAmount;
                
                // Calculate payment performance
                VendorLedgerEntry.SetLoadFields("Vendor No.", "Remaining Amount", "Due Date", "Pmt. Discount Date");
                VendorLedgerEntry.SetRange("Vendor No.", Vendor."No.");
                VendorLedgerEntry.SetRange(Open, true);
                
                PaymentTermsScore := CalculateVendorPaymentScore(VendorLedgerEntry);
                VendorAnalysis."Payment Performance Score" := PaymentTermsScore;
                
                VendorAnalysis.Insert();
            until Vendor.Next() = 0;
    end;
    
    local procedure CalculateCreditUtilization(Customer: Record Customer): Decimal
    var
        CreditLimit: Decimal;
    begin
        // Load credit limit separately if needed
        if Customer."Credit Limit (LCY)" = 0 then
            exit(0);
            
        exit((Customer."Balance (LCY)" / Customer."Credit Limit (LCY)") * 100);
    end;
    
    local procedure CalculatePaymentScore(Customer: Record Customer): Decimal
    begin
        // Simplified payment score calculation
        if Customer."Balance Due (LCY)" = 0 then
            exit(100); // Perfect score
            
        if Customer."Balance Due (LCY)" > (Customer."Balance (LCY)" * 0.5) then
            exit(25); // Poor score
            
        exit(75); // Good score
    end;
    
    local procedure CalculateVendorPaymentScore(var VendorLedgerEntry: Record "Vendor Ledger Entry"): Decimal
    var
        OnTimePayments: Integer;
        TotalPayments: Integer;
    begin
        if VendorLedgerEntry.FindSet() then
            repeat
                TotalPayments += 1;
                if VendorLedgerEntry."Due Date" >= Today then
                    OnTimePayments += 1;
            until VendorLedgerEntry.Next() = 0;
            
        if TotalPayments = 0 then
            exit(100);
            
        exit((OnTimePayments / TotalPayments) * 100);
    end;
}
```

## Background Processing with Optimized Field Loading

```al
codeunit 50704 "Background Processing Optimized"
{
    procedure ProcessLargeDatasetInBackground()
    var
        SalesLine: Record "Sales Line";
        ProcessingBatch: Record "Processing Batch" temporary;
        BatchSize: Integer;
        ProcessedRecords: Integer;
    begin
        BatchSize := 1000; // Process in batches of 1000 records
        
        // Load only essential fields for background processing
        SalesLine.SetLoadFields("Document No.", "Line No.", "No.", Quantity, "Line Amount", "Outstanding Quantity");
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetFilter("Outstanding Quantity", '>0');
        
        if SalesLine.FindSet() then
            repeat
                // Add to processing batch
                AddToProcessingBatch(ProcessingBatch, SalesLine);
                ProcessedRecords += 1;
                
                // Process batch when full
                if ProcessedRecords mod BatchSize = 0 then begin
                    ProcessBatch(ProcessingBatch);
                    ProcessingBatch.DeleteAll();
                end;
                
            until SalesLine.Next() = 0;
        
        // Process remaining records
        if ProcessingBatch.FindFirst() then begin
            ProcessBatch(ProcessingBatch);
            ProcessingBatch.DeleteAll();
        end;
    end;
    
    local procedure AddToProcessingBatch(var ProcessingBatch: Record "Processing Batch" temporary; SalesLine: Record "Sales Line")
    begin
        ProcessingBatch.Init();
        ProcessingBatch."Entry No." := ProcessingBatch.Count + 1;
        ProcessingBatch."Document No." := SalesLine."Document No.";
        ProcessingBatch."Line No." := SalesLine."Line No.";
        ProcessingBatch."Item No." := SalesLine."No.";
        ProcessingBatch."Outstanding Quantity" := SalesLine."Outstanding Quantity";
        ProcessingBatch.Insert();
    end;
    
    local procedure ProcessBatch(var ProcessingBatch: Record "Processing Batch" temporary)
    begin
        if ProcessingBatch.FindSet() then
            repeat
                ProcessSalesLineRecord(ProcessingBatch);
            until ProcessingBatch.Next() = 0;
    end;
    
    local procedure ProcessSalesLineRecord(ProcessingBatch: Record "Processing Batch" temporary)
    begin
        // Process individual sales line record from batch
        // Implementation specific to business requirements
    end;
}
```

## Related Topics
- [SetLoadFields Advanced Scenarios](setloadfields-advanced-scenarios.md)
- [SetLoadFields Basic Patterns](setloadfields-basic-patterns.md)
- [SetLoadFields Performance Measurement](setloadfields-performance-measurement.md)
