# Code Optimization Patterns - Code Samples

## Efficient Record Processing

```al
// Optimal record iteration pattern
procedure ProcessCustomerBatch(var Customer: Record Customer)
var
    ProcessedCount: Integer;
begin
    // Pre-filter records for efficiency
    Customer.SetRange("Customer Posting Group", 'RETAIL');
    Customer.SetRange("Country/Region Code", 'US');
    Customer.SetFilter("Credit Limit (LCY)", '>0');
    
    // Use FindSet() for multiple record processing
    if Customer.FindSet() then
        repeat
            ProcessSingleCustomer(Customer);
            ProcessedCount += 1;
        until Customer.Next() = 0;
    
    Message('Processed %1 customers', ProcessedCount);
end;

// Wrong approach - inefficient iteration
procedure ProcessCustomerBatchWrong(var Customer: Record Customer)
begin
    // DON'T do this - Find('-') is deprecated and less efficient
    if Customer.Find('-') then
        repeat
            ProcessSingleCustomer(Customer);
        until Customer.Next() = 0;
end;
```

## Variable Cleanup Examples

```al
// Clean variable declaration - only necessary variables
procedure CalculateCustomerDiscount(var Customer: Record Customer): Decimal
var
    SalesHeader: Record "Sales Header";
    TotalSalesAmount: Decimal;
    DiscountPercentage: Decimal;
begin
    // Calculate total sales for discount determination
    SalesHeader.SetRange("Sell-to Customer No.", Customer."No.");
    SalesHeader.SetFilter("Document Date", '>=%1', CalcDate('<-1Y>', Today()));
    SalesHeader.CalcSums("Amount Including VAT");
    
    TotalSalesAmount := SalesHeader."Amount Including VAT";
    
    // Apply tiered discount structure
    case TotalSalesAmount of
        0..10000:
            DiscountPercentage := 0;
        10001..50000:
            DiscountPercentage := 5;
        50001..100000:
            DiscountPercentage := 10;
        else
            DiscountPercentage := 15;
    end;
    
    exit(DiscountPercentage);
end;

// Wrong approach - unused variables
procedure CalculateCustomerDiscountWrong(var Customer: Record Customer): Decimal
var
    SalesHeader: Record "Sales Header";
    SalesLine: Record "Sales Line";  // UNUSED - should be removed
    Item: Record Item;               // UNUSED - should be removed
    TempRecord: Record "Temp Record"; // UNUSED - should be removed
    TotalSalesAmount: Decimal;
    DiscountPercentage: Decimal;
    TempAmount: Decimal;             // UNUSED - should be removed
begin
    // Same logic but with unnecessary variable declarations
    exit(DiscountPercentage);
end;
```

## Pre-filtering Optimization

```al
// Efficient filtering before processing
procedure UpdateCustomerPrices(CountryCode: Code[10]; PostingGroup: Code[20])
var
    Customer: Record Customer;
    UpdateCount: Integer;
begin
    // Apply filters before database access
    Customer.SetRange("Country/Region Code", CountryCode);
    Customer.SetRange("Customer Posting Group", PostingGroup);
    Customer.SetRange(Blocked, Customer.Blocked::" "); // Only active customers
    
    if Customer.FindSet(true) then  // true parameter allows modifications
        repeat
            // Update pricing for filtered customers only
            UpdateCustomerPricing(Customer);
            UpdateCount += 1;
        until Customer.Next() = 0;
    
    Message('Updated pricing for %1 customers', UpdateCount);
end;

// Wrong approach - filtering after retrieval
procedure UpdateCustomerPricesWrong(CountryCode: Code[10]; PostingGroup: Code[20])
var
    Customer: Record Customer;
    UpdateCount: Integer;
begin
    // DON'T do this - retrieves all customers then filters
    if Customer.FindSet(true) then
        repeat
            // Filtering in AL code instead of database - inefficient!
            if (Customer."Country/Region Code" = CountryCode) and 
               (Customer."Customer Posting Group" = PostingGroup) and
               (Customer.Blocked = Customer.Blocked::" ") then begin
                UpdateCustomerPricing(Customer);
                UpdateCount += 1;
            end;
        until Customer.Next() = 0;
end;
```

## Batch Processing Optimization

```al
// Efficient batch processing with temporary tables
procedure ProcessLargeDataSet(var Customer: Record Customer)
var
    TempProcessingResults: Record "Processing Results" temporary;
    ProcessingBatchSize: Integer;
    CurrentBatchCount: Integer;
begin
    ProcessingBatchSize := 100; // Process in batches of 100
    
    Customer.SetCurrentKey("No.");
    if Customer.FindSet() then
        repeat
            // Add to temporary table for batch processing
            TempProcessingResults.TransferFields(Customer);
            TempProcessingResults.Insert();
            CurrentBatchCount += 1;
            
            // Process batch when it reaches the batch size
            if CurrentBatchCount >= ProcessingBatchSize then begin
                ProcessBatch(TempProcessingResults);
                TempProcessingResults.DeleteAll();
                CurrentBatchCount := 0;
                Commit(); // Commit after each batch
            end;
        until Customer.Next() = 0;
    
    // Process remaining records
    if CurrentBatchCount > 0 then
        ProcessBatch(TempProcessingResults);
end;

// Batch processing helper
local procedure ProcessBatch(var TempProcessingResults: Record "Processing Results" temporary)
begin
    if TempProcessingResults.FindSet() then
        repeat
            // Process each record in the batch
            ProcessSingleRecord(TempProcessingResults);
        until TempProcessingResults.Next() = 0;
end;
```

## Performance-Optimized Calculations

```al
// Efficient calculation with minimal database hits
procedure CalculateCustomerStatistics(CustomerNo: Code[20]) CustomerStats: Record "Customer Statistics"
var
    Customer: Record Customer;
    SalesHeader: Record "Sales Header";
    CustLedgerEntry: Record "Cust. Ledger Entry";
begin
    // Get customer with required fields only
    Customer.Get(CustomerNo);
    Customer.SetLoadFields("No.", Name, "Customer Posting Group");
    
    CustomerStats."Customer No." := CustomerNo;
    CustomerStats."Customer Name" := Customer.Name;
    
    // Single calculation for sales totals
    SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
    SalesHeader.SetFilter("Document Date", '>=%1', CalcDate('<-1Y>', Today()));
    SalesHeader.CalcSums("Amount Including VAT");
    CustomerStats."Annual Sales Amount" := SalesHeader."Amount Including VAT";
    
    // Single calculation for balance
    Customer.CalcFields("Balance (LCY)");
    CustomerStats."Current Balance" := Customer."Balance (LCY)";
    
    // Calculate payment statistics in one operation
    CustLedgerEntry.SetRange("Customer No.", CustomerNo);
    CustLedgerEntry.SetFilter("Posting Date", '>=%1', CalcDate('<-1Y>', Today()));
    CustLedgerEntry.CalcSums("Sales (LCY)", "Payment (LCY)");
    
    CustomerStats."Payment Ratio" := 0;
    if CustLedgerEntry."Sales (LCY)" <> 0 then
        CustomerStats."Payment Ratio" := CustLedgerEntry."Payment (LCY)" / CustLedgerEntry."Sales (LCY)" * 100;
    
    exit(CustomerStats);
end;
```

## Memory-Efficient Variable Management

```al
// Properly organized variables by type and usage
procedure ComplexBusinessProcess()
var
    // Record variables first (most complex)
    Customer: Record Customer;
    SalesHeader: Record "Sales Header";
    SalesLine: Record "Sales Line";
    TempResults: Record "Processing Results" temporary;
    
    // Object variables
    ProcessingReport: Report "Customer Processing";
    
    // Simple variables last
    CustomerNo: Code[20];
    TotalAmount: Decimal;
    ProcessingDate: Date;
    IsCompleted: Boolean;
begin
    // Implementation with all variables being used
    Customer.SetRange("No.", CustomerNo);
    // ... rest of implementation
end;

// Resource cleanup pattern
procedure ProcessWithCleanup()
var
    TempCustomer: Record Customer temporary;
    ProcessingStream: InStream;
begin
    try
        // Processing logic
        PerformProcessing(TempCustomer, ProcessingStream);
    finally
        // Cleanup temporary data
        TempCustomer.DeleteAll();
        Clear(ProcessingStream);
    end;
end;
```

## Anti-Pattern Examples to Avoid

```al
// WRONG: N+1 Query Problem
procedure CalculateTotalsWrong()
var
    Customer: Record Customer;
    SalesHeader: Record "Sales Header";
    CustomerTotal: Decimal;
begin
    if Customer.FindSet() then
        repeat
            // This creates a separate query for each customer - very inefficient!
            SalesHeader.SetRange("Sell-to Customer No.", Customer."No.");
            SalesHeader.CalcSums("Amount Including VAT");
            CustomerTotal := SalesHeader."Amount Including VAT";
            // Process customer total
        until Customer.Next() = 0;
end;

// RIGHT: Batch Processing Approach
procedure CalculateTotalsRight()
var
    Customer: Record Customer;
    SalesHeader: Record "Sales Header";
    TempTotals: Record "Customer Totals" temporary;
begin
    // Pre-calculate all totals in single operations
    SalesHeader.SetCurrentKey("Sell-to Customer No.");
    if SalesHeader.FindSet() then
        repeat
            if not TempTotals.Get(SalesHeader."Sell-to Customer No.") then begin
                TempTotals."Customer No." := SalesHeader."Sell-to Customer No.";
                TempTotals."Total Amount" := 0;
                TempTotals.Insert();
            end;
            TempTotals."Total Amount" += SalesHeader."Amount Including VAT";
            TempTotals.Modify();
        until SalesHeader.Next() = 0;
    
    // Now process results efficiently
    if TempTotals.FindSet() then
        repeat
            ProcessCustomerTotal(TempTotals);
        until TempTotals.Next() = 0;
end;
```
