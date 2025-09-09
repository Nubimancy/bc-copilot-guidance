---
title: "Test Data Prefixing Standards - Code Samples"
description: "Complete implementations demonstrating Business Central test data prefixing patterns and unique generation strategies"
area: "testing"
difficulty: "beginner"
object_types: ["Codeunit"]
variable_types: ["Record"]
tags: ["testing", "test-data", "prefixing", "data-isolation", "standards", "samples"]
---

# Test Data Prefixing Standards - Code Samples

## Complete Test Data Generation Library

### Master Data Creation with Prefixing

```al
codeunit 50500 "Test Data Generation Library"
{
    var
        CustomerCounter: Integer;
        VendorCounter: Integer;
        ItemCounter: Integer;
        DocumentCounter: Integer;
        RandomSeed: Integer;
        
    trigger OnRun()
    begin
        Initialize();
    end;
    
    local procedure Initialize()
    begin
        if RandomSeed = 0 then begin
            Randomize();
            RandomSeed := Random(1000);
        end;
    end;
    
    /// <summary>
    /// Creates a test customer with proper X prefixing and incremental numbering
    /// </summary>
    /// <param name="Customer">Customer record to create</param>
    /// <returns>The generated customer number</returns>
    procedure CreateTestCustomer(var Customer: Record Customer): Code[20]
    var
        CustomerNo: Code[20];
        ContactNo: Code[20];
    begin
        CustomerNo := GenerateUniqueCustomerNo();
        
        Customer.Init();
        Customer."No." := CustomerNo;
        Customer.Name := 'XTest Customer ' + CopyStr(CustomerNo, 2); // Remove X for display
        Customer."Name 2" := 'XAdditional Name Info';
        Customer.Address := 'XTest Street ' + Format(Random(999));
        Customer."Address 2" := 'XSuite ' + Format(Random(100));
        Customer.City := 'XTest City';
        Customer.County := 'XTest County';
        Customer."Post Code" := 'X' + Format(Random(99999)).PadLeft(5, '0');
        Customer."Country/Region Code" := GetTestCountryCode();
        Customer."Phone No." := '+1-555-X' + Format(Random(999)).PadLeft(3, '0') + '-' + Format(Random(9999)).PadLeft(4, '0');
        Customer."Mobile Phone No." := '+1-555-X' + Format(Random(999)).PadLeft(3, '0') + '-' + Format(Random(9999)).PadLeft(4, '0');
        Customer."E-Mail" := 'Xtest' + CopyStr(DelChr(Format(CreateGuid()), '=', '{}'), 1, 8) + '@example.com';
        Customer."Home Page" := 'https://Xtest-customer-' + Format(Random(999)) + '.example.com';
        Customer."Language Code" := GetTestLanguageCode();
        Customer."Salesperson Code" := GetTestSalespersonCode();
        Customer."Payment Terms Code" := GetTestPaymentTermsCode();
        Customer."Payment Method Code" := GetTestPaymentMethodCode();
        Customer."Shipment Method Code" := GetTestShipmentMethodCode();
        Customer."Customer Posting Group" := GetTestCustomerPostingGroup();
        Customer."Gen. Bus. Posting Group" := GetTestGenBusPostingGroup();
        Customer."VAT Bus. Posting Group" := GetTestVATBusPostingGroup();
        Customer.Insert(true);
        
        // Create contact for customer
        CreateTestCustomerContact(Customer, ContactNo);
        
        exit(CustomerNo);
    end;
    
    /// <summary>
    /// Creates a test vendor with comprehensive X prefixing
    /// </summary>
    procedure CreateTestVendor(var Vendor: Record Vendor): Code[20]
    var
        VendorNo: Code[20];
    begin
        VendorNo := GenerateUniqueVendorNo();
        
        Vendor.Init();
        Vendor."No." := VendorNo;
        Vendor.Name := 'XTest Vendor ' + CopyStr(VendorNo, 2);
        Vendor."Name 2" := 'XVendor Additional Name';
        Vendor.Address := 'XVendor Street ' + Format(Random(999));
        Vendor."Address 2" := 'XVendor Suite ' + Format(Random(100));
        Vendor.City := 'XVendor City';
        Vendor.County := 'XVendor County';
        Vendor."Post Code" := 'XV' + Format(Random(9999)).PadLeft(4, '0');
        Vendor."Country/Region Code" := GetTestCountryCode();
        Vendor."Phone No." := '+1-555-XV' + Format(Random(99)).PadLeft(2, '0') + '-' + Format(Random(9999)).PadLeft(4, '0');
        Vendor."E-Mail" := 'Xvendor' + CopyStr(DelChr(Format(CreateGuid()), '=', '{}'), 1, 6) + '@vendor.example';
        Vendor."Home Page" := 'https://Xvendor-' + Format(Random(999)) + '.example.com';
        Vendor."Purchaser Code" := GetTestPurchaserCode();
        Vendor."Payment Terms Code" := GetTestPaymentTermsCode();
        Vendor."Payment Method Code" := GetTestPaymentMethodCode();
        Vendor."Shipment Method Code" := GetTestShipmentMethodCode();
        Vendor."Vendor Posting Group" := GetTestVendorPostingGroup();
        Vendor."Gen. Bus. Posting Group" := GetTestGenBusPostingGroup();
        Vendor."VAT Bus. Posting Group" := GetTestVATBusPostingGroup();
        Vendor.Insert(true);
        
        exit(VendorNo);
    end;
    
    /// <summary>
    /// Creates a test item with full specifications and X prefixing
    /// </summary>
    procedure CreateTestItem(var Item: Record Item): Code[20]
    var
        ItemNo: Code[20];
        UnitOfMeasure: Record "Unit of Measure";
    begin
        ItemNo := GenerateUniqueItemNo();
        
        // Ensure we have a test unit of measure
        CreateTestUnitOfMeasure(UnitOfMeasure, 'XPCS', 'XTest Pieces');
        
        Item.Init();
        Item."No." := ItemNo;
        Item.Description := 'XTest Item ' + CopyStr(ItemNo, 2);
        Item."Description 2" := 'XAdditional Item Description';
        Item."Base Unit of Measure" := UnitOfMeasure.Code;
        Item.Type := Item.Type::Inventory;
        Item."Inventory Posting Group" := GetTestInventoryPostingGroup();
        Item."Gen. Prod. Posting Group" := GetTestGenProdPostingGroup();
        Item."VAT Prod. Posting Group" := GetTestVATProdPostingGroup();
        Item."Item Category Code" := GetTestItemCategoryCode();
        Item."Unit Price" := Random(1000) + 10; // Random price between 10-1010
        Item."Unit Cost" := Item."Unit Price" * 0.7; // 70% cost ratio
        Item."Costing Method" := Item."Costing Method"::FIFO;
        Item."Replenishment System" := Item."Replenishment System"::Purchase;
        Item."Vendor No." := GetTestVendorNo();
        Item."Vendor Item No." := 'XV-' + CopyStr(ItemNo, 2);
        Item."Lead Time Calculation" := '<5D>'; // 5 days lead time
        Item."Safety Stock Quantity" := Random(50);
        Item."Reorder Point" := Random(100) + 50;
        Item."Reorder Quantity" := Random(500) + 100;
        Item."Alternative Item No." := GenerateAlternativeItemNo(ItemNo);
        Item.Insert(true);
        
        // Create additional item specifications
        CreateTestItemUnitsOfMeasure(Item);
        CreateTestItemVariants(Item);
        
        exit(ItemNo);
    end;
    
    /// <summary>
    /// Creates test sales document with proper prefixing
    /// </summary>
    procedure CreateTestSalesOrder(var SalesHeader: Record "Sales Header"): Code[20]
    var
        Customer: Record Customer;
        SalesLine: Record "Sales Line";
        Item: Record Item;
        DocumentNo: Code[20];
        LineNo: Integer;
    begin
        DocumentNo := GenerateUniqueSalesOrderNo();
        
        // Create test customer if needed
        CreateTestCustomer(Customer);
        
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := DocumentNo;
        SalesHeader."Sell-to Customer No." := Customer."No.";
        SalesHeader."Bill-to Customer No." := Customer."No.";
        SalesHeader."Ship-to Code" := ''; // Use customer default
        SalesHeader."Order Date" := Today;
        SalesHeader."Posting Date" := Today;
        SalesHeader."Document Date" := Today;
        SalesHeader."Requested Delivery Date" := CalcDate('<+7D>', Today);
        SalesHeader."Promised Delivery Date" := CalcDate('<+10D>', Today);
        SalesHeader."External Document No." := 'XEXT' + Format(Random(99999)).PadLeft(5, '0');
        SalesHeader."Your Reference" := 'XREF' + Format(Random(999));
        SalesHeader."Salesperson Code" := GetTestSalespersonCode();
        SalesHeader."Payment Terms Code" := GetTestPaymentTermsCode();
        SalesHeader."Payment Method Code" := GetTestPaymentMethodCode();
        SalesHeader."Shipment Method Code" := GetTestShipmentMethodCode();
        SalesHeader."Location Code" := GetTestLocationCode();
        SalesHeader.Insert(true);
        
        // Add test sales lines
        LineNo := 10000;
        CreateTestItem(Item);
        CreateTestSalesLine(SalesHeader, SalesLine, LineNo, Item."No.", Random(10) + 1, Item."Unit Price");
        
        LineNo += 10000;
        CreateTestItem(Item);
        CreateTestSalesLine(SalesHeader, SalesLine, LineNo, Item."No.", Random(5) + 1, Item."Unit Price");
        
        exit(DocumentNo);
    end;
    
    /// <summary>
    /// Creates test purchase document with comprehensive prefixing
    /// </summary>
    procedure CreateTestPurchaseOrder(var PurchaseHeader: Record "Purchase Header"): Code[20]
    var
        Vendor: Record Vendor;
        PurchaseLine: Record "Purchase Line";
        Item: Record Item;
        DocumentNo: Code[20];
        LineNo: Integer;
    begin
        DocumentNo := GenerateUniquePurchaseOrderNo();
        
        // Create test vendor if needed
        CreateTestVendor(Vendor);
        
        PurchaseHeader.Init();
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Order;
        PurchaseHeader."No." := DocumentNo;
        PurchaseHeader."Buy-from Vendor No." := Vendor."No.";
        PurchaseHeader."Pay-to Vendor No." := Vendor."No.";
        PurchaseHeader."Order Date" := Today;
        PurchaseHeader."Posting Date" := Today;
        PurchaseHeader."Document Date" := Today;
        PurchaseHeader."Expected Receipt Date" := CalcDate('<+14D>', Today);
        PurchaseHeader."Vendor Order No." := 'XVORDER' + Format(Random(99999)).PadLeft(5, '0');
        PurchaseHeader."Vendor Shipment No." := 'XVSHIP' + Format(Random(99999)).PadLeft(5, '0');
        PurchaseHeader."Purchaser Code" := GetTestPurchaserCode();
        PurchaseHeader."Payment Terms Code" := GetTestPaymentTermsCode();
        PurchaseHeader."Payment Method Code" := GetTestPaymentMethodCode();
        PurchaseHeader."Shipment Method Code" := GetTestShipmentMethodCode();
        PurchaseHeader."Location Code" := GetTestLocationCode();
        PurchaseHeader.Insert(true);
        
        // Add test purchase lines
        LineNo := 10000;
        CreateTestItem(Item);
        CreateTestPurchaseLine(PurchaseHeader, PurchaseLine, LineNo, Item."No.", Random(20) + 5, Item."Unit Cost");
        
        exit(DocumentNo);
    end;
    
    // Unique number generation methods
    local procedure GenerateUniqueCustomerNo(): Code[20]
    var
        Customer: Record Customer;
        CustomerNo: Code[20];
        MaxAttempts: Integer;
    begin
        MaxAttempts := 100;
        repeat
            CustomerCounter += 1;
            CustomerNo := 'XCUST' + Format(CustomerCounter + RandomSeed).PadLeft(6, '0');
            MaxAttempts -= 1;
        until (not Customer.Get(CustomerNo)) or (MaxAttempts = 0);
        
        if MaxAttempts = 0 then
            Error('Unable to generate unique customer number after 100 attempts');
            
        exit(CustomerNo);
    end;
    
    local procedure GenerateUniqueVendorNo(): Code[20]
    var
        Vendor: Record Vendor;
        VendorNo: Code[20];
        MaxAttempts: Integer;
    begin
        MaxAttempts := 100;
        repeat
            VendorCounter += 1;
            VendorNo := 'XVEND' + Format(VendorCounter + RandomSeed).PadLeft(6, '0');
            MaxAttempts -= 1;
        until (not Vendor.Get(VendorNo)) or (MaxAttempts = 0);
        
        if MaxAttempts = 0 then
            Error('Unable to generate unique vendor number after 100 attempts');
            
        exit(VendorNo);
    end;
    
    local procedure GenerateUniqueItemNo(): Code[20]
    var
        Item: Record Item;
        ItemNo: Code[20];
        MaxAttempts: Integer;
    begin
        MaxAttempts := 100;
        repeat
            ItemCounter += 1;
            ItemNo := 'XITEM' + Format(ItemCounter + RandomSeed).PadLeft(5, '0');
            MaxAttempts -= 1;
        until (not Item.Get(ItemNo)) or (MaxAttempts = 0);
        
        if MaxAttempts = 0 then
            Error('Unable to generate unique item number after 100 attempts');
            
        exit(ItemNo);
    end;
    
    local procedure GenerateUniqueSalesOrderNo(): Code[20]
    var
        SalesHeader: Record "Sales Header";
        DocumentNo: Code[20];
        MaxAttempts: Integer;
    begin
        MaxAttempts := 100;
        repeat
            DocumentCounter += 1;
            DocumentNo := 'XSO' + Format(DocumentCounter + RandomSeed).PadLeft(7, '0');
            MaxAttempts -= 1;
            SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
            SalesHeader.SetRange("No.", DocumentNo);
        until SalesHeader.IsEmpty() or (MaxAttempts = 0);
        
        if MaxAttempts = 0 then
            Error('Unable to generate unique sales order number after 100 attempts');
            
        exit(DocumentNo);
    end;
    
    local procedure GenerateUniquePurchaseOrderNo(): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        DocumentNo: Code[20];
        MaxAttempts: Integer;
    begin
        MaxAttempts := 100;
        repeat
            DocumentCounter += 1;
            DocumentNo := 'XPO' + Format(DocumentCounter + RandomSeed).PadLeft(7, '0');
            MaxAttempts -= 1;
            PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
            PurchaseHeader.SetRange("No.", DocumentNo);
        until PurchaseHeader.IsEmpty() or (MaxAttempts = 0);
        
        if MaxAttempts = 0 then
            Error('Unable to generate unique purchase order number after 100 attempts');
            
        exit(DocumentNo);
    end;
    
    // Helper methods for creating supporting test data
    local procedure CreateTestUnitOfMeasure(var UnitOfMeasure: Record "Unit of Measure"; UOMCode: Code[10]; Description: Text[50])
    begin
        if not UnitOfMeasure.Get(UOMCode) then begin
            UnitOfMeasure.Init();
            UnitOfMeasure.Code := UOMCode;
            UnitOfMeasure.Description := Description;
            UnitOfMeasure.Insert(true);
        end;
    end;
    
    local procedure CreateTestSalesLine(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; LineNo: Integer; ItemNo: Code[20]; Quantity: Decimal; UnitPrice: Decimal)
    begin
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Type := SalesLine.Type::Item;
        SalesLine."No." := ItemNo;
        SalesLine.Quantity := Quantity;
        SalesLine."Unit Price" := UnitPrice;
        SalesLine."Location Code" := SalesHeader."Location Code";
        SalesLine.Insert(true);
    end;
    
    local procedure CreateTestPurchaseLine(PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; LineNo: Integer; ItemNo: Code[20]; Quantity: Decimal; DirectUnitCost: Decimal)
    begin
        PurchaseLine.Init();
        PurchaseLine."Document Type" := PurchaseHeader."Document Type";
        PurchaseLine."Document No." := PurchaseHeader."No.";
        PurchaseLine."Line No." := LineNo;
        PurchaseLine.Type := PurchaseLine.Type::Item;
        PurchaseLine."No." := ItemNo;
        PurchaseLine.Quantity := Quantity;
        PurchaseLine."Direct Unit Cost" := DirectUnitCost;
        PurchaseLine."Location Code" := PurchaseHeader."Location Code";
        PurchaseLine.Insert(true);
    end;
    
    local procedure CreateTestCustomerContact(Customer: Record Customer; var ContactNo: Code[20])
    var
        Contact: Record Contact;
    begin
        ContactNo := 'XCONT' + Format(Random(999999)).PadLeft(6, '0');
        
        Contact.Init();
        Contact."No." := ContactNo;
        Contact.Type := Contact.Type::Person;
        Contact.Name := 'XTest Contact ' + Customer.Name;
        Contact."Company No." := Customer."No.";
        Contact.Address := Customer.Address;
        Contact.City := Customer.City;
        Contact."Post Code" := Customer."Post Code";
        Contact."Country/Region Code" := Customer."Country/Region Code";
        Contact."Phone No." := Customer."Phone No.";
        Contact."Mobile Phone No." := Customer."Mobile Phone No.";
        Contact."E-Mail" := Customer."E-Mail";
        Contact.Insert(true);
    end;
    
    local procedure CreateTestItemUnitsOfMeasure(Item: Record Item)
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        // Create box unit
        if not ItemUnitOfMeasure.Get(Item."No.", 'XBOX') then begin
            CreateTestUnitOfMeasure("Unit of Measure", 'XBOX', 'XTest Box');
            ItemUnitOfMeasure.Init();
            ItemUnitOfMeasure."Item No." := Item."No.";
            ItemUnitOfMeasure.Code := 'XBOX';
            ItemUnitOfMeasure."Qty. per Unit of Measure" := 10;
            ItemUnitOfMeasure.Insert(true);
        end;
    end;
    
    local procedure CreateTestItemVariants(Item: Record Item)
    var
        ItemVariant: Record "Item Variant";
    begin
        ItemVariant.Init();
        ItemVariant."Item No." := Item."No.";
        ItemVariant.Code := 'XVAR01';
        ItemVariant.Description := 'XTest Variant 1';
        if ItemVariant.Insert(true) then;
    end;
    
    local procedure GenerateAlternativeItemNo(BaseItemNo: Code[20]): Code[20]
    begin
        exit('XALT' + CopyStr(BaseItemNo, 6)); // Take last part of base item number
    end;
    
    // Configuration helper methods (would be implemented based on test environment setup)
    local procedure GetTestCountryCode(): Code[10]
    begin
        exit('XUS'); // Test country code
    end;
    
    local procedure GetTestLanguageCode(): Code[10]
    begin
        exit('ENU');
    end;
    
    local procedure GetTestSalespersonCode(): Code[20]
    begin
        exit('XSALES01');
    end;
    
    local procedure GetTestPurchaserCode(): Code[20]
    begin
        exit('XPURCH01');
    end;
    
    local procedure GetTestPaymentTermsCode(): Code[10]
    begin
        exit('X30DAYS');
    end;
    
    local procedure GetTestPaymentMethodCode(): Code[10]
    begin
        exit('XCHECK');
    end;
    
    local procedure GetTestShipmentMethodCode(): Code[10]
    begin
        exit('XGROUND');
    end;
    
    local procedure GetTestLocationCode(): Code[10]
    begin
        exit('XMAIN');
    end;
    
    local procedure GetTestCustomerPostingGroup(): Code[20]
    begin
        exit('XCUSTOMER');
    end;
    
    local procedure GetTestVendorPostingGroup(): Code[20]
    begin
        exit('XVENDOR');
    end;
    
    local procedure GetTestInventoryPostingGroup(): Code[20]
    begin
        exit('XINVENTORY');
    end;
    
    local procedure GetTestGenBusPostingGroup(): Code[20]
    begin
        exit('XDOMESTIC');
    end;
    
    local procedure GetTestGenProdPostingGroup(): Code[20]
    begin
        exit('XRETAIL');
    end;
    
    local procedure GetTestVATBusPostingGroup(): Code[20]
    begin
        exit('XDOMESTIC');
    end;
    
    local procedure GetTestVATProdPostingGroup(): Code[20]
    begin
        exit('XSTANDARD');
    end;
    
    local procedure GetTestItemCategoryCode(): Code[20]
    begin
        exit('XGENERAL');
    end;
    
    local procedure GetTestVendorNo(): Code[20]
    var
        Vendor: Record Vendor;
    begin
        Vendor.SetFilter("No.", 'XVEND*');
        if Vendor.FindFirst() then
            exit(Vendor."No.")
        else begin
            CreateTestVendor(Vendor);
            exit(Vendor."No.");
        end;
    end;
}
```

## Test Data Cleanup Framework

### Comprehensive Cleanup Procedures

```al
codeunit 50501 "Test Data Cleanup Manager"
{
    /// <summary>
    /// Cleans up all test data based on X prefix pattern
    /// </summary>
    procedure CleanupAllTestData()
    begin
        CleanupTestDocuments();
        CleanupTestMasterData();
        CleanupTestSetupData();
        CleanupTestJournalData();
        CleanupTestLedgerEntries();
    end;
    
    /// <summary>
    /// Cleans up test master data records
    /// </summary>
    procedure CleanupTestMasterData()
    begin
        CleanupTestCustomers();
        CleanupTestVendors();
        CleanupTestItems();
        CleanupTestContacts();
        CleanupTestGLAccounts();
    end;
    
    /// <summary>
    /// Cleans up test document records
    /// </summary>
    procedure CleanupTestDocuments()
    begin
        CleanupTestSalesDocuments();
        CleanupTestPurchaseDocuments();
        CleanupTestTransferOrders();
        CleanupTestServiceDocuments();
    end;
    
    local procedure CleanupTestCustomers()
    var
        Customer: Record Customer;
        DeletedCount: Integer;
    begin
        Customer.SetFilter("No.", 'X*');
        DeletedCount := Customer.Count();
        
        if Customer.FindSet() then
            Customer.DeleteAll(true);
            
        LogCleanupResult('Customer', DeletedCount);
    end;
    
    local procedure CleanupTestVendors()
    var
        Vendor: Record Vendor;
        DeletedCount: Integer;
    begin
        Vendor.SetFilter("No.", 'X*');
        DeletedCount := Vendor.Count();
        
        if Vendor.FindSet() then
            Vendor.DeleteAll(true);
            
        LogCleanupResult('Vendor', DeletedCount);
    end;
    
    local procedure CleanupTestItems()
    var
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        DeletedCount: Integer;
    begin
        // First check for item ledger entries
        ItemLedgerEntry.SetFilter("Item No.", 'X*');
        if not ItemLedgerEntry.IsEmpty() then
            Error('Cannot delete test items with ledger entries. Clean up transactions first.');
            
        Item.SetFilter("No.", 'X*');
        DeletedCount := Item.Count();
        
        if Item.FindSet() then
            Item.DeleteAll(true);
            
        LogCleanupResult('Item', DeletedCount);
    end;
    
    local procedure CleanupTestSalesDocuments()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DeletedCount: Integer;
    begin
        SalesHeader.SetFilter("No.", 'XSO*|XSI*|XSC*|XSR*'); // Orders, Invoices, Credit Memos, Returns
        DeletedCount := SalesHeader.Count();
        
        if SalesHeader.FindSet() then begin
            repeat
                SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                SalesLine.SetRange("Document No.", SalesHeader."No.");
                SalesLine.DeleteAll(true);
            until SalesHeader.Next() = 0;
            
            SalesHeader.DeleteAll(true);
        end;
        
        LogCleanupResult('Sales Document', DeletedCount);
    end;
    
    local procedure CleanupTestPurchaseDocuments()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DeletedCount: Integer;
    begin
        PurchaseHeader.SetFilter("No.", 'XPO*|XPI*|XPC*|XPR*'); // Orders, Invoices, Credit Memos, Returns
        DeletedCount := PurchaseHeader.Count();
        
        if PurchaseHeader.FindSet() then begin
            repeat
                PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
                PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
                PurchaseLine.DeleteAll(true);
            until PurchaseHeader.Next() = 0;
            
            PurchaseHeader.DeleteAll(true);
        end;
        
        LogCleanupResult('Purchase Document', DeletedCount);
    end;
    
    local procedure LogCleanupResult(RecordType: Text; DeletedCount: Integer)
    begin
        if DeletedCount > 0 then
            Message('Cleaned up %1 test %2 records', DeletedCount, RecordType)
        else
            Message('No test %1 records found for cleanup', RecordType);
    end;
    
    /// <summary>
    /// Validates that no test data remains after cleanup
    /// </summary>
    procedure ValidateCleanupComplete(): Boolean
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        ValidationErrors: List of [Text];
    begin
        // Check for remaining test data
        Customer.SetFilter("No.", 'X*');
        if not Customer.IsEmpty() then
            ValidationErrors.Add(StrSubstNo('%1 test customers remain', Customer.Count()));
            
        Vendor.SetFilter("No.", 'X*');
        if not Vendor.IsEmpty() then
            ValidationErrors.Add(StrSubstNo('%1 test vendors remain', Vendor.Count()));
            
        Item.SetFilter("No.", 'X*');
        if not Item.IsEmpty() then
            ValidationErrors.Add(StrSubstNo('%1 test items remain', Item.Count()));
            
        SalesHeader.SetFilter("No.", 'X*');
        if not SalesHeader.IsEmpty() then
            ValidationErrors.Add(StrSubstNo('%1 test sales documents remain', SalesHeader.Count()));
            
        PurchaseHeader.SetFilter("No.", 'X*');
        if not PurchaseHeader.IsEmpty() then
            ValidationErrors.Add(StrSubstNo('%1 test purchase documents remain', PurchaseHeader.Count()));
        
        if ValidationErrors.Count > 0 then begin
            ReportValidationErrors(ValidationErrors);
            exit(false);
        end;
        
        Message('Test data cleanup validation successful - no test data remains');
        exit(true);
    end;
    
    local procedure ReportValidationErrors(ValidationErrors: List of [Text])
    var
        ErrorMessage: Text;
        AllErrors: Text;
    begin
        foreach ErrorMessage in ValidationErrors do begin
            if AllErrors <> '' then
                AllErrors += '\';
            AllErrors += ErrorMessage;
        end;
        
        Error('Test data cleanup incomplete:\%1', AllErrors);
    end;
}
```

These comprehensive samples demonstrate production-ready test data prefixing with proper uniqueness generation, conflict prevention, and complete cleanup frameworks.
