---
title: "Performance Anti-Patterns - Code Samples"
description: "Complete code examples showing common performance mistakes and their optimized solutions in AL"
area: "architecture-design"
difficulty: "intermediate"
object_types: ["Codeunit", "Table", "Report"]
variable_types: ["Record", "RecordRef", "List", "Dictionary"]
tags: ["anti-patterns", "performance", "n-plus-one", "query-optimization", "samples"]
---

# Performance Anti-Patterns - Code Samples

## N+1 Query Problem

### ❌ Problem: Queries inside loops create massive database load

```al
// Don't do this - N+1 query problem destroys performance
codeunit 50500 "Customer Sales Bad Example"
{
    procedure UpdateCustomerTotalSales()
    var
        Customer: Record Customer;
        SalesLine: Record "Sales Line";
        CustomerSalesTotal: Decimal;
    begin
        // This is a performance disaster!
        // For 1000 customers, this makes 1001 database queries (1 + N)
        
        Customer.FindSet(); // 1 query to get all customers
        repeat
            // N queries - one for each customer!
            SalesLine.SetRange("Sell-to Customer No.", Customer."No.");
            SalesLine.CalcSums(Amount);
            CustomerSalesTotal := SalesLine.Amount;
            
            Customer."Total Sales" := CustomerSalesTotal; // Another query per customer!
            Customer.Modify();
            
        until Customer.Next() = 0;
        
        // Result: 1 + (N * 2) = 2001 queries for 1000 customers!
    end;
    
    procedure UpdateCustomerOrderCounts()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        OrderCount: Integer;
    begin
        // Another N+1 example - counting orders per customer
        Customer.FindSet(); // 1 query
        repeat
            // N more queries
            SalesHeader.SetRange("Sell-to Customer No.", Customer."No.");
            SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
            OrderCount := SalesHeader.Count();
            
            Customer."Order Count" := OrderCount;
            Customer.Modify(); // More queries
            
        until Customer.Next() = 0;
    end;
    
    procedure GetCustomerItemPurchases()
    var
        Customer: Record Customer;
        SalesLine: Record "Sales Line";
        Item: Record Item;
        PurchaseHistory: Text;
    begin
        // Triple nested N+1 - exponentially worse!
        Customer.FindSet(); // 1 query
        repeat
            SalesLine.SetRange("Sell-to Customer No.", Customer."No."); 
            SalesLine.FindSet(); // N queries (one per customer)
            repeat
                Item.Get(SalesLine."No."); // N*M queries (customers * lines)
                PurchaseHistory += Item.Description + '; ';
            until SalesLine.Next() = 0;
            
            Customer."Purchase History" := PurchaseHistory;
            Customer.Modify(); // N more queries
        until Customer.Next() = 0;
        
        // For 100 customers with 50 lines each: 1 + 100 + (100*50) + 100 = 5201 queries!
    end;
}
```

### ✅ Solution: Bulk operations with proper optimization

```al
// ✅ Optimized approach with bulk operations
codeunit 50500 "Customer Sales Good Example"
{
    procedure UpdateCustomerTotalSales()
    var
        Customer: Record Customer;
        SalesLine: Record "Sales Line";
        CustomerSalesMap: Dictionary of [Code[20], Decimal];
        CustomerNo: Code[20];
        SalesAmount: Decimal;
    begin
        // Step 1: Get all customer numbers in one query
        Customer.FindSet();
        repeat
            CustomerSalesMap.Add(Customer."No.", 0);
        until Customer.Next() = 0;
        
        // Step 2: Get ALL sales lines in one optimized query
        SalesLine.SetLoadFields("Sell-to Customer No.", Amount);
        if SalesLine.FindSet() then
            repeat
                if CustomerSalesMap.ContainsKey(SalesLine."Sell-to Customer No.") then begin
                    CustomerSalesMap.Get(SalesLine."Sell-to Customer No.", SalesAmount);
                    CustomerSalesMap.Set(SalesLine."Sell-to Customer No.", 
                                       SalesAmount + SalesLine.Amount);
                end;
            until SalesLine.Next() = 0;
        
        // Step 3: Bulk update all customers
        Customer.FindSet();
        repeat
            if CustomerSalesMap.Get(Customer."No.", SalesAmount) then begin
                Customer."Total Sales" := SalesAmount;
                Customer.Modify();
            end;
        until Customer.Next() = 0;
        
        // Result: Only 3 queries total regardless of customer count!
    end;
    
    procedure UpdateCustomerOrderCountsOptimized()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        CustomerOrderCounts: Dictionary of [Code[20], Integer];
        CustomerNo: Code[20];
        OrderCount: Integer;
    begin
        // Initialize customer counts
        Customer.FindSet();
        repeat
            CustomerOrderCounts.Add(Customer."No.", 0);
        until Customer.Next() = 0;
        
        // Single query to count all orders, grouped by customer
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetLoadFields("Sell-to Customer No.");
        
        if SalesHeader.FindSet() then
            repeat
                if CustomerOrderCounts.ContainsKey(SalesHeader."Sell-to Customer No.") then begin
                    CustomerOrderCounts.Get(SalesHeader."Sell-to Customer No.", OrderCount);
                    CustomerOrderCounts.Set(SalesHeader."Sell-to Customer No.", OrderCount + 1);
                end;
            until SalesHeader.Next() = 0;
        
        // Update all customers with counts
        Customer.FindSet();
        repeat
            if CustomerOrderCounts.Get(Customer."No.", OrderCount) then begin
                Customer."Order Count" := OrderCount;
                Customer.Modify();
            end;
        until Customer.Next() = 0;
    end;
    
    procedure GetCustomerItemPurchasesOptimized()
    var
        Customer: Record Customer;
        SalesLine: Record "Sales Line";
        Item: Record Item;
        CustomerPurchaseMap: Dictionary of [Code[20], Text];
        ItemDescriptionMap: Dictionary of [Code[20], Text];
        CustomerNo: Code[20];
        ItemNo: Code[20];
        PurchaseHistory: Text;
    begin
        // Step 1: Load all items into memory once
        Item.SetLoadFields("No.", Description);
        if Item.FindSet() then
            repeat
                ItemDescriptionMap.Add(Item."No.", Item.Description);
            until Item.Next() = 0;
        
        // Step 2: Initialize customer purchase histories
        Customer.FindSet();
        repeat
            CustomerPurchaseMap.Add(Customer."No.", '');
        until Customer.Next() = 0;
        
        // Step 3: Process all sales lines in one pass
        SalesLine.SetLoadFields("Sell-to Customer No.", "No.");
        if SalesLine.FindSet() then
            repeat
                CustomerNo := SalesLine."Sell-to Customer No.";
                ItemNo := SalesLine."No.";
                
                if CustomerPurchaseMap.ContainsKey(CustomerNo) and 
                   ItemDescriptionMap.ContainsKey(ItemNo) then begin
                    CustomerPurchaseMap.Get(CustomerNo, PurchaseHistory);
                    PurchaseHistory += ItemDescriptionMap.Get(ItemNo) + '; ';
                    CustomerPurchaseMap.Set(CustomerNo, PurchaseHistory);
                end;
            until SalesLine.Next() = 0;
        
        // Step 4: Update all customers with purchase histories
        Customer.FindSet();
        repeat
            if CustomerPurchaseMap.Get(Customer."No.", PurchaseHistory) then begin
                Customer."Purchase History" := PurchaseHistory;
                Customer.Modify();
            end;
        until Customer.Next() = 0;
        
        // Result: Only 4 queries total instead of thousands!
    end;
}
```

## Inefficient Record Loading

### ❌ Problem: Loading all fields when only some are needed

```al
// Don't do this - loading unnecessary data
codeunit 50501 "Report Generation Bad"
{
    procedure GenerateCustomerReport()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        ReportData: Text;
    begin
        // Loading ALL fields for ALL customers - very inefficient
        Customer.FindSet();
        repeat
            // Only using No. and Name, but loading entire record
            ReportData += Customer."No." + ' - ' + Customer.Name + '\n';
            
            // Loading ALL sales header fields when we only need a few
            SalesHeader.SetRange("Sell-to Customer No.", Customer."No.");
            SalesHeader.FindSet();
            repeat
                // Only using Document No. and Amount, but loaded everything
                ReportData += '  Order: ' + SalesHeader."No." + 
                             ' Amount: ' + Format(SalesHeader."Amount Including VAT") + '\n';
            until SalesHeader.Next() = 0;
            
        until Customer.Next() = 0;
    end;
    
    procedure ProcessLargeDataSet()
    var
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
        Item: Record Item;
    begin
        // Processing thousands of records without optimization
        SalesLine.FindSet(); // Loads ALL fields for ALL records
        repeat
            // Multiple related record lookups in loop - very slow
            Customer.Get(SalesLine."Sell-to Customer No."); // Full customer record
            Item.Get(SalesLine."No."); // Full item record
            
            // Only using a few fields from each record
            ProcessLineData(SalesLine."Document No.", Customer.Name, Item.Description);
            
        until SalesLine.Next() = 0;
    end;
}
```

### ✅ Solution: Optimized field loading and caching

```al
// ✅ Use SetLoadFields and caching for optimal performance
codeunit 50501 "Report Generation Good"
{
    procedure GenerateCustomerReport()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        ReportData: Text;
    begin
        // Only load the fields we actually need
        Customer.SetLoadFields("No.", Name);
        Customer.FindSet();
        repeat
            ReportData += Customer."No." + ' - ' + Customer.Name + '\n';
            
            // Only load required sales header fields
            SalesHeader.SetRange("Sell-to Customer No.", Customer."No.");
            SalesHeader.SetLoadFields("No.", "Amount Including VAT");
            if SalesHeader.FindSet() then
                repeat
                    ReportData += '  Order: ' + SalesHeader."No." + 
                                 ' Amount: ' + Format(SalesHeader."Amount Including VAT") + '\n';
                until SalesHeader.Next() = 0;
                
        until Customer.Next() = 0;
    end;
    
    procedure ProcessLargeDataSetOptimized()
    var
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
        Item: Record Item;
        CustomerCache: Dictionary of [Code[20], Text];
        ItemCache: Dictionary of [Code[20], Text];
    begin
        // Pre-load customer names into cache
        Customer.SetLoadFields("No.", Name);
        if Customer.FindSet() then
            repeat
                CustomerCache.Add(Customer."No.", Customer.Name);
            until Customer.Next() = 0;
        
        // Pre-load item descriptions into cache
        Item.SetLoadFields("No.", Description);
        if Item.FindSet() then
            repeat
                ItemCache.Add(Item."No.", Item.Description);
            until Item.Next() = 0;
        
        // Process sales lines with optimized field loading
        SalesLine.SetLoadFields("Document No.", "Sell-to Customer No.", "No.");
        SalesLine.FindSet();
        repeat
            // Use cached data instead of repeated database lookups
            ProcessLineDataOptimized(
                SalesLine."Document No.", 
                CustomerCache.Get(SalesLine."Sell-to Customer No."),
                ItemCache.Get(SalesLine."No.")
            );
        until SalesLine.Next() = 0;
    end;
    
    local procedure ProcessLineDataOptimized(DocumentNo: Code[20]; CustomerName: Text; ItemDescription: Text)
    begin
        // Process with cached data - no database calls needed
    end;
}
```

## Blocking Operations in Loops

### ❌ Problem: Long-running operations in loops

```al
// Don't do this - blocking operations in loops
codeunit 50502 "Batch Processing Bad"
{
    procedure ProcessCustomerNotifications()
    var
        Customer: Record Customer;
        EmailService: Codeunit "Email Service";
    begin
        // Sending emails synchronously in a loop - blocks UI
        Customer.FindSet();
        repeat
            // Each email send takes 2-3 seconds - UI frozen for minutes!
            EmailService.SendMarketingEmail(Customer."E-Mail", Customer.Name);
            
            // Database update after each email - inefficient
            Customer."Last Marketing Email Date" := Today;
            Customer.Modify();
            
        until Customer.Next() = 0;
        
        Message('Processed %1 customers', Customer.Count); // User waits forever for this
    end;
    
    procedure RecalculateAllPrices()
    var
        Item: Record Item;
        PricingEngine: Codeunit "Pricing Engine";
    begin
        // Complex pricing calculations in loop without progress indication
        Item.FindSet();
        repeat
            // Each calculation takes 5-10 seconds for complex items
            PricingEngine.RecalculateItemPricing(Item); // Blocking operation
            
            Item."Last Price Update" := CurrentDateTime;
            Item.Modify();
            
        until Item.Next() = 0;
        
        // User has no idea how long this will take or if it's working
    end;
}
```

### ✅ Solution: Background processing with progress tracking

```al
// ✅ Optimized with background processing and progress tracking
codeunit 50502 "Batch Processing Good"
{
    procedure ProcessCustomerNotificationsAsync()
    var
        Customer: Record Customer;
        NotificationQueue: Record "Notification Queue";
        CustomerCount: Integer;
        ProcessedCount: Integer;
    begin
        // Queue all notifications for background processing
        CustomerCount := Customer.Count();
        
        Customer.FindSet();
        repeat
            // Add to queue instead of processing immediately
            QueueMarketingEmail(Customer);
            ProcessedCount += 1;
            
            // Update progress periodically
            if ProcessedCount mod 100 = 0 then
                UpdateProgress(ProcessedCount, CustomerCount, 'Queuing notifications...');
                
        until Customer.Next() = 0;
        
        // Start background job to process queue
        StartEmailProcessingJob();
        
        Message('Queued %1 marketing emails for background processing', CustomerCount);
    end;
    
    procedure RecalculateAllPricesWithProgress()
    var
        Item: Record Item;
        PricingEngine: Codeunit "Pricing Engine";
        ProgressDialog: Dialog;
        TotalItems: Integer;
        ProcessedItems: Integer;
        StartTime: DateTime;
    begin
        TotalItems := Item.Count();
        StartTime := CurrentDateTime;
        
        ProgressDialog.Open(
            'Recalculating item prices...\' +
            'Progress: #1####### / #2#######\' +
            'Current Item: #3##########\' +
            'Estimated time remaining: #4#######'
        );
        
        Item.FindSet();
        repeat
            ProcessedItems += 1;
            
            // Update progress dialog
            ProgressDialog.Update(1, ProcessedItems);
            ProgressDialog.Update(2, TotalItems);
            ProgressDialog.Update(3, Item."No.");
            ProgressDialog.Update(4, CalculateTimeRemaining(StartTime, ProcessedItems, TotalItems));
            
            // Process in smaller batches to avoid UI blocking
            PricingEngine.RecalculateItemPricing(Item);
            Item."Last Price Update" := CurrentDateTime;
            Item.Modify();
            
            // Allow UI updates every 10 items
            if ProcessedItems mod 10 = 0 then
                Sleep(10); // Brief pause to allow UI updates
                
        until Item.Next() = 0;
        
        ProgressDialog.Close();
        Message('Successfully recalculated prices for %1 items', TotalItems);
    end;
    
    local procedure QueueMarketingEmail(Customer: Record Customer)
    var
        NotificationQueue: Record "Notification Queue";
    begin
        NotificationQueue.Init();
        NotificationQueue."Entry No." := GetNextEntryNo();
        NotificationQueue."Customer No." := Customer."No.";
        NotificationQueue."Email Address" := Customer."E-Mail";
        NotificationQueue."Customer Name" := Customer.Name;
        NotificationQueue.Status := NotificationQueue.Status::Pending;
        NotificationQueue.Insert();
    end;
    
    local procedure UpdateProgress(Current: Integer; Total: Integer; Operation: Text)
    var
        ProgressWindow: Dialog;
    begin
        // Show progress to user
    end;
    
    local procedure CalculateTimeRemaining(StartTime: DateTime; Processed: Integer; Total: Integer): Text
    var
        ElapsedTime: Duration;
        EstimatedTotal: Duration;
        Remaining: Duration;
    begin
        if Processed = 0 then
            exit('Calculating...');
            
        ElapsedTime := CurrentDateTime - StartTime;
        EstimatedTotal := ElapsedTime * Total / Processed;
        Remaining := EstimatedTotal - ElapsedTime;
        
        exit(Format(Remaining));
    end;
}
```

## Related Topics
- [Performance Anti-Patterns](performance-anti-patterns.md)
- [SetLoadFields Patterns](setloadfields-patterns.md)
- [Query Filtering Optimization](query-filtering-optimization.md)
