---
title: "Intelligent Caching Strategies - Samples"
description: "Working AL code examples for implementing intelligent caching strategies in Business Central applications"
area: "performance-optimization"
difficulty: "advanced"
object_types: ["Codeunit", "Table", "Interface", "Enum"]
variable_types: ["RecordRef", "Record", "Boolean", "Integer", "DateTime"]
tags: ["intelligent-caching", "cache-optimization", "setloadfields", "performance-tuning", "record-loading"]
---

# Intelligent Caching Strategies - Samples

## SetLoadFields Optimization Examples

### Basic SetLoadFields Pattern

```al
procedure GetCustomerNameAndAddress(CustomerNo: Code[20]): Text
var
    Customer: Record Customer;
begin
    // Load only required fields for this operation
    Customer.SetLoadFields(Name, Address, "Address 2", City, "Post Code");
    if Customer.Get(CustomerNo) then
        exit(Customer.Name + ', ' + Customer.Address + ', ' + Customer.City);
    
    exit('');
end;
```

### Dynamic Field Loading Based on Context

```al
procedure LoadCustomerData(CustomerNo: Code[20]; IncludeFinancials: Boolean; IncludeContact: Boolean)
var
    Customer: Record Customer;
    FieldsToLoad: List of [Integer];
begin
    // Build dynamic field list based on requirements
    FieldsToLoad.Add(Customer.FieldNo("No."));
    FieldsToLoad.Add(Customer.FieldNo(Name));
    FieldsToLoad.Add(Customer.FieldNo(Address));
    
    if IncludeFinancials then begin
        FieldsToLoad.Add(Customer.FieldNo("Credit Limit (LCY)"));
        FieldsToLoad.Add(Customer.FieldNo("Payment Terms Code"));
    end;
    
    if IncludeContact then begin
        FieldsToLoad.Add(Customer.FieldNo("Phone No."));
        FieldsToLoad.Add(Customer.FieldNo("E-Mail"));
    end;
    
    Customer.SetLoadFields(FieldsToLoad);
    if Customer.Get(CustomerNo) then begin
        // Process customer data with only loaded fields
        ProcessCustomerData(Customer, IncludeFinancials, IncludeContact);
    end;
end;
```

### FlowField Strategic Loading

```al
procedure GetCustomerBalanceForCard(CustomerNo: Code[20]): Decimal
var
    Customer: Record Customer;
begin
    // Load FlowField only when specifically needed (Card page, not List)
    Customer.SetLoadFields("No.", Balance);
    if Customer.Get(CustomerNo) then begin
        Customer.CalcFields(Balance); // Calculate FlowField after loading
        exit(Customer.Balance);
    end;
    
    exit(0);
end;

procedure GetCustomersForList(): Query "Customer List"
var
    CustomerListQuery: Query "Customer List";
begin
    // Never include FlowFields in List queries for performance
    // Query definition includes only: No., Name, Address, City, Phone No.
    exit(CustomerListQuery);
end;
```

## Temporary Table Caching Patterns

### Complex Calculation Caching

```al
procedure CalculateCustomerStatistics(var TempCustomerStats: Record "Customer Statistics" temporary)
var
    Customer: Record Customer;
    SalesLine: Record "Sales Line";
    PurchaseLine: Record "Purchase Line";
begin
    TempCustomerStats.Reset();
    TempCustomerStats.DeleteAll(); // Clear previous calculations
    
    Customer.SetLoadFields("No.", Name, "Customer Posting Group");
    if Customer.FindSet() then
        repeat
            TempCustomerStats.Init();
            TempCustomerStats."Customer No." := Customer."No.";
            TempCustomerStats."Customer Name" := Customer.Name;
            
            // Cache calculated values to avoid repeated queries
            TempCustomerStats."Total Sales Amount" := CalculateCustomerSales(Customer."No.");
            TempCustomerStats."Total Purchase Amount" := CalculateCustomerPurchases(Customer."No.");
            TempCustomerStats."Last Transaction Date" := GetLastTransactionDate(Customer."No.");
            
            TempCustomerStats.Insert();
        until Customer.Next() = 0;
end;
```

### Cross-Table Join Caching

```al
procedure CacheCustomerItemPurchases(var TempCustItemPurchase: Record "Temp Customer Item Purchase" temporary)
var
    Customer: Record Customer;
    Item: Record Item;
    PurchInvLine: Record "Purch. Inv. Line";
begin
    TempCustItemPurchase.DeleteAll();
    
    // Cache complex join results to temporary table
    Customer.SetLoadFields("No.", Name);
    if Customer.FindSet() then
        repeat
            PurchInvLine.SetRange("Buy-from Vendor No.", Customer."No.");
            PurchInvLine.SetLoadFields("No.", Quantity, "Direct Unit Cost", "Line Amount");
            
            if PurchInvLine.FindSet() then
                repeat
                    if Item.Get(PurchInvLine."No.") then begin
                        TempCustItemPurchase.Init();
                        TempCustItemPurchase."Customer No." := Customer."No.";
                        TempCustItemPurchase."Customer Name" := Customer.Name;
                        TempCustItemPurchase."Item No." := Item."No.";
                        TempCustItemPurchase."Item Description" := Item.Description;
                        TempCustItemPurchase.Quantity := PurchInvLine.Quantity;
                        TempCustItemPurchase."Unit Cost" := PurchInvLine."Direct Unit Cost";
                        TempCustItemPurchase."Line Amount" := PurchInvLine."Line Amount";
                        
                        if not TempCustItemPurchase.Insert() then
                            TempCustItemPurchase.Modify(); // Aggregate if already exists
                    end;
                until PurchInvLine.Next() = 0;
        until Customer.Next() = 0;
end;
```

## Batch Operations for Performance

### Efficient Record Processing

```al
procedure ProcessCustomerBatch(CustomerNos: List of [Code[20]])
var
    Customer: Record Customer;
    TempProcessingResults: Record "Processing Results" temporary;
    CustomerNo: Code[20];
    ProcessingBatch: List of [Record Customer];
begin
    // Load all customers in batch
    Customer.SetLoadFields("No.", Name, "Customer Posting Group", "Payment Terms Code");
    foreach CustomerNo in CustomerNos do begin
        if Customer.Get(CustomerNo) then
            ProcessingBatch.Add(Customer);
    end;
    
    // Process entire batch in memory
    foreach Customer in ProcessingBatch do begin
        ProcessSingleCustomer(Customer, TempProcessingResults);
    end;
    
    // Commit results in batch
    CommitProcessingResults(TempProcessingResults);
end;
```

### Smart Record Caching with Cleanup

```al
codeunit 50200 "Smart Record Cache"
{
    var
        CustomerCache: Dictionary of [Code[20], Record Customer];
        ItemCache: Dictionary of [Code[20], Record Item];
        CacheExpiry: DateTime;
        CacheValidityMinutes: Integer;

    trigger OnRun()
    begin
        CacheValidityMinutes := 15; // Cache valid for 15 minutes
    end;

    procedure GetCustomerFromCache(CustomerNo: Code[20]; var Customer: Record Customer): Boolean
    begin
        // Check cache validity
        if CurrentDateTime > CacheExpiry then
            ClearCache();
            
        if CustomerCache.Get(CustomerNo, Customer) then
            exit(true);
            
        // Load from database and cache
        Customer.SetLoadFields("No.", Name, Address, City, "Phone No.");
        if Customer.Get(CustomerNo) then begin
            CustomerCache.Set(CustomerNo, Customer);
            exit(true);
        end;
        
        exit(false);
    end;

    procedure ClearCache()
    begin
        Clear(CustomerCache);
        Clear(ItemCache);
        CacheExpiry := CurrentDateTime + (CacheValidityMinutes * 60 * 1000); // Add minutes in milliseconds
    end;
    
    // Automatic cleanup on codeunit destruction
    trigger OnDestroy()
    begin
        ClearCache();
    end;
}
```

## Performance-Aware Database Access

### Optimized Find vs Get Operations

```al
procedure OptimizedCustomerLookup(SearchTerm: Text): List of [Code[20]]
var
    Customer: Record Customer;
    CustomerNos: List of [Code[20]];
begin
    Customer.SetLoadFields("No.", Name); // Only load fields needed for search
    
    // Use appropriate method based on search pattern
    if StrLen(SearchTerm) = MaxStrLen(Customer."No.") then begin
        // Exact match - use Get for primary key lookup
        if Customer.Get(SearchTerm) then
            CustomerNos.Add(Customer."No.");
    end else begin
        // Partial match - use filtered FindSet
        Customer.SetFilter(Name, '@*' + SearchTerm + '*');
        Customer.SetCurrentKey(Name); // Use appropriate index
        
        if Customer.FindSet() then
            repeat
                CustomerNos.Add(Customer."No.");
            until (Customer.Next() = 0) or (CustomerNos.Count() >= 50); // Limit results
    end;
    
    exit(CustomerNos);
end;
```

### Index-Aware Caching

```al
procedure CacheCustomersByPostingGroup(PostingGroup: Code[20]; var TempCustomer: Record Customer temporary)
var
    Customer: Record Customer;
begin
    TempCustomer.DeleteAll();
    
    // Use index-optimized filtering
    Customer.SetCurrentKey("Customer Posting Group", "No."); // Use appropriate index
    Customer.SetRange("Customer Posting Group", PostingGroup);
    Customer.SetLoadFields("No.", Name, Address, "Phone No.", "Customer Posting Group");
    
    if Customer.FindSet() then
        repeat
            TempCustomer.TransferFields(Customer);
            TempCustomer.Insert();
        until Customer.Next() = 0;
end;
```

## Session-Scoped Caching

### Page Data Caching

```al
page 50100 "Customer Analytics"
{
    PageType = Card;
    SourceTable = Customer;
    
    var
        TempAnalyticsData: Record "Analytics Data" temporary;
        DataCached: Boolean;
    
    trigger OnAfterGetRecord()
    begin
        if not DataCached then begin
            CacheAnalyticsData();
            DataCached := true;
        end;
    end;
    
    trigger OnAfterGetCurrRecord()
    begin
        // Refresh cache when customer changes
        if Rec."No." <> xRec."No." then begin
            DataCached := false;
            TempAnalyticsData.DeleteAll();
        end;
    end;
    
    local procedure CacheAnalyticsData()
    var
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
    begin
        Customer.SetLoadFields("No.", Name);
        if Customer.Get(Rec."No.") then begin
            // Cache expensive calculations
            TempAnalyticsData.Init();
            TempAnalyticsData."Customer No." := Customer."No.";
            TempAnalyticsData."Total Sales" := CalculateTotalSales(Customer."No.");
            TempAnalyticsData."Avg Order Value" := CalculateAvgOrderValue(Customer."No.");
            TempAnalyticsData."Last Order Date" := GetLastOrderDate(Customer."No.");
            TempAnalyticsData.Insert();
        end;
    end;
}
```

## Multi-Company Caching Patterns

### Company-Aware Cache Management

```al
codeunit 50201 "Multi-Company Cache Manager"
{
    var
        CompanyCustomerCache: Dictionary of [Text, Dictionary of [Code[20], Record Customer]];
        
    procedure GetCustomerFromCompanyCache(CompanyName: Text; CustomerNo: Code[20]; var Customer: Record Customer): Boolean
    var
        CompanyCache: Dictionary of [Code[20], Record Customer];
    begin
        // Get company-specific cache
        if not CompanyCustomerCache.Get(CompanyName, CompanyCache) then begin
            Clear(CompanyCache);
            CompanyCustomerCache.Set(CompanyName, CompanyCache);
        end;
        
        if CompanyCache.Get(CustomerNo, Customer) then
            exit(true);
            
        // Load from specific company database
        Customer.ChangeCompany(CompanyName);
        Customer.SetLoadFields("No.", Name, Address);
        if Customer.Get(CustomerNo) then begin
            CompanyCache.Set(CustomerNo, Customer);
            CompanyCustomerCache.Set(CompanyName, CompanyCache);
            exit(true);
        end;
        
        exit(false);
    end;
    
    procedure ClearCompanyCache(CompanyName: Text)
    var
        EmptyCache: Dictionary of [Code[20], Record Customer];
    begin
        CompanyCustomerCache.Set(CompanyName, EmptyCache);
    end;
}
```