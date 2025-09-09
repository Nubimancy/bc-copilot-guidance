---
title: "Test Data Prefixing Standards"
description: "Essential prefixing requirements and patterns for Business Central test data to prevent conflicts and ensure isolation"
area: "testing"
difficulty: "beginner"
object_types: ["Codeunit"]
variable_types: ["Record"]
tags: ["testing", "test-data", "prefixing", "data-isolation", "standards"]
---

# Test Data Prefixing Standards

## The X Prefix Requirement

When generating test data in Business Central AL test libraries and test codeunits, **always prefix Code and Text fields with 'X'** to ensure the data does not conflict with existing data in the database.

### Scope of Requirement

**This requirement applies to:**
- Test Library codeunits
- Test codeunits
- Any procedure that creates test data for testing purposes

**Fields that require X prefix:**
- Code fields (Customer No., Item No., etc.)
- Text fields (Name, Description, Address, etc.)
- Any string-based identifier or descriptive field

**Fields that do NOT require X prefix:**
- Numeric fields (amounts, quantities, dates)
- Boolean fields
- Enum/Option fields
- System-generated fields

## Basic Prefixing Patterns

### Master Data Prefixes

```al
// Customer data
Customer."No." := 'XCUST001';
Customer.Name := 'XTest Customer Name';
Customer.Address := 'XTest Street 123';

// Vendor data
Vendor."No." := 'XVEND001';
Vendor.Name := 'XTest Vendor Name';

// Item data
Item."No." := 'XITEM001';
Item.Description := 'XTest Item Description';
Item."Base Unit of Measure" := 'XPCS';

// G/L Account
GLAccount."No." := 'X1000';
GLAccount.Name := 'XTest GL Account';
```

### Document Data Prefixes

```al
// Sales documents
SalesHeader."No." := 'XSO001';
SalesHeader."External Document No." := 'XEXT001';

// Purchase documents
PurchaseHeader."No." := 'XPO001';
PurchaseHeader."Vendor Order No." := 'XVORDER001';

// Transfer documents
TransferHeader."No." := 'XTO001';
```

### Setup Data Prefixes

```al
// Location
Location.Code := 'XLOC01';
Location.Name := 'XTest Location';

// Dimensions
Dimension.Code := 'XDIM01';
Dimension.Name := 'XTest Dimension';

// Unit of Measure
UnitOfMeasure.Code := 'XUOM01';
UnitOfMeasure.Description := 'XTest Unit';
```

## Unique Test Data Generation

### Sequential Number Pattern

Generate unique identifiers using counters to avoid conflicts within test runs.

```al
var
    CustomerCounter: Integer;

procedure CreateUniqueCustomerNo(): Code[20]
begin
    CustomerCounter += 1;
    exit('XCUST' + Format(CustomerCounter).PadLeft(5, '0'));
    // Returns: XCUST00001, XCUST00002, etc.
end;

procedure CreateUniqueItemNo(): Code[20]
var
    ItemNo: Code[20];
begin
    ItemNo := 'XITEM' + Format(Random(99999)).PadLeft(5, '0');
    // Ensure uniqueness by checking existence
    while ItemExists(ItemNo) do
        ItemNo := 'XITEM' + Format(Random(99999)).PadLeft(5, '0');
    exit(ItemNo);
end;
```

### GUID-Based Pattern

For truly unique identifiers, use GUID fragments.

```al
procedure CreateUniqueDescription(): Text[100]
var
    GuidText: Text;
begin
    GuidText := DelChr(Format(CreateGuid()), '=', '{}');
    exit('XTest ' + CopyStr(GuidText, 1, 8));
    // Returns: XTest 12A4B6C8
end;

procedure CreateUniqueEmail(): Text[80]
var
    GuidText: Text;
begin
    GuidText := DelChr(Format(CreateGuid()), '=', '{}');
    exit('Xtest' + CopyStr(GuidText, 1, 8) + '@example.com');
    // Returns: Xtest12A4B6C8@example.com
end;
```

### Time-Based Pattern

Incorporate timestamps for uniqueness across test sessions.

```al
procedure CreateUniqueCustomerNo(): Code[20]
var
    TimeStamp: Text;
begin
    TimeStamp := Format(CurrentDateTime, 0, '<Day,2><Month,2><Hours24,2><Minutes,2>');
    exit('XC' + TimeStamp);
    // Returns: XC20081514 (20th day, 8th month, 15:14)
end;
```

## Consistent Prefixing Best Practices

### Good Prefixing Examples

```al
// Consistent and clear
Customer."No." := 'XCUST001';
Customer.Name := 'XTest Customer';
Customer.Address := 'XTest Address';
Customer.City := 'XTest City';
Customer."Post Code" := 'X12345';

Vendor."No." := 'XVEND001';
Vendor.Name := 'XTest Vendor';
Vendor.Address := 'XTest Vendor Address';

Item."No." := 'XITEM001';
Item.Description := 'XTest Item';
Item."Description 2" := 'XTest Item Line 2';
```

### Prefixing Anti-Patterns

```al
// Bad - Inconsistent prefixing
Customer."No." := 'TESTCUST001';  // Should be XCUST001
Vendor."No." := 'V001';           // Should be XVEND001
Item."No." := 'XITEM001';         // Good

// Bad - Mixed prefixing styles
Customer."No." := 'X-CUST-001';   // Avoid special characters
Customer.Name := 'Test Customer'; // Missing X prefix
Customer.Address := 'xtest addr'; // Inconsistent casing

// Bad - Overly complex prefixes
Customer."No." := 'XTESTCUSTOMERDATA001'; // Too verbose
Item."No." := 'XITEMFORTESTING001';       // Too descriptive
```

## Test Data Identification Benefits

### Database Recognition

The X prefix makes test data immediately identifiable in the database.

```al
// Easy to spot in database queries
SELECT * FROM Customer WHERE "No." LIKE 'X%'
SELECT * FROM Item WHERE "No." LIKE 'X%'

// Clear separation from production data
Production Customer: 'CUST001'
Test Customer: 'XCUST001'
```

### Simplified Filtering

Filter test data easily for cleanup or analysis.

```al
procedure CleanupAllTestCustomers()
var
    Customer: Record Customer;
begin
    Customer.SetFilter("No.", 'X*');
    if Customer.FindSet() then
        Customer.DeleteAll(true);
end;

procedure CountTestItems(): Integer
var
    Item: Record Item;
begin
    Item.SetFilter("No.", 'XITEM*');
    exit(Item.Count);
end;
```

### Test Environment Management

Maintain clean test environments by identifying test data.

```al
procedure ResetTestEnvironment()
begin
    CleanupTestCustomers();
    CleanupTestVendors();
    CleanupTestItems();
    CleanupTestDocuments();
end;

procedure CleanupTestDocuments()
var
    SalesHeader: Record "Sales Header";
    PurchaseHeader: Record "Purchase Header";
begin
    SalesHeader.SetFilter("No.", 'XSO*');
    SalesHeader.DeleteAll(true);
    
    PurchaseHeader.SetFilter("No.", 'XPO*');
    PurchaseHeader.DeleteAll(true);
end;
```

## Validation and Error Prevention

### Prefix Validation

Implement validation to ensure prefixing standards are followed.

```al
procedure ValidateTestDataPrefix(FieldValue: Text; FieldName: Text)
begin
    if not FieldValue.StartsWith('X') then
        Error('Test data field %1 must start with X prefix. Current value: %2', FieldName, FieldValue);
end;

procedure CreateTestCustomer(var Customer: Record Customer; CustomerNo: Code[20])
begin
    ValidateTestDataPrefix(CustomerNo, 'Customer No.');
    
    Customer.Init();
    Customer."No." := CustomerNo;
    Customer.Name := 'XTest Customer ' + CustomerNo;
    Customer.Insert(true);
end;
```

### Conflict Prevention

Check for existing data to prevent conflicts.

```al
procedure EnsureUniqueTestCustomer(var CustomerNo: Code[20])
var
    Customer: Record Customer;
    Counter: Integer;
    BaseNo: Code[20];
begin
    if not CustomerNo.StartsWith('X') then
        CustomerNo := 'X' + CustomerNo;
        
    BaseNo := CustomerNo;
    Counter := 1;
    
    while Customer.Get(CustomerNo) do begin
        Counter += 1;
        CustomerNo := BaseNo + Format(Counter);
    end;
end;
```

Following these prefixing standards ensures test data remains isolated, identifiable, and manageable throughout the testing lifecycle.
