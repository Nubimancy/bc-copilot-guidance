# BC Test Automation Patterns - AL Implementation Samples

This file contains working AL code examples for implementing Business Central test automation patterns using test codeunits, test pages, and BC's built-in testing framework.

## Test Codeunit Implementation Samples

### Basic Test Codeunit Structure

```al
codeunit 50100 "Sales Document Test"
{
    Subtype = Test;

    [Test]
    procedure TestSalesOrderCreation()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
    begin
        // [SCENARIO] Creating a sales order updates document totals correctly
        
        // [GIVEN] A customer exists
        LibrarySales.CreateCustomer(Customer);
        
        // [WHEN] Creating a sales order with one line
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, LibraryInventory.CreateItemNo(), 10);
        SalesLine.Validate("Unit Price", 100);
        SalesLine.Modify(true);
        
        // [THEN] Document totals are calculated correctly
        SalesHeader.CalcFields(Amount);
        Assert.AreEqual(1000, SalesHeader.Amount, 'Sales order amount calculation failed');
    end;

    [Test]
    procedure TestSalesOrderPosting()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Posting a sales order creates shipment and invoice
        
        // [GIVEN] A complete sales order
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, CreateItemWithInventory(), 5);
        
        // [WHEN] Posting the sales order
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        
        // [THEN] Posted documents exist
        Assert.IsTrue(PostedDocumentNo <> '', 'Sales order posting failed');
        VerifyPostedSalesInvoice(PostedDocumentNo);
    end;

    local procedure CreateItemWithInventory(): Code[20]
    var
        Item: Record Item;
        ItemJournalLine: Record "Item Journal Line";
    begin
        LibraryInventory.CreateItem(Item);
        LibraryInventory.CreateItemJournalLineInItemTemplate(ItemJournalLine, Item."No.", '', '', 100);
        LibraryInventory.PostItemJournalLine(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");
        exit(Item."No.");
    end;

    local procedure VerifyPostedSalesInvoice(DocumentNo: Code[20])
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SalesInvoiceHeader.Get(DocumentNo);
        Assert.IsTrue(SalesInvoiceHeader."No." <> '', 'Posted sales invoice not found');
    end;
}
```

### Test Setup and Teardown Patterns

```al
codeunit 50101 "Purchase Process Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;

    [Test]
    procedure TestPurchaseOrderApproval()
    var
        PurchaseHeader: Record "Purchase Header";
        ApprovalEntry: Record "Approval Entry";
    begin
        // [SCENARIO] Purchase orders require approval when over limit
        Initialize();
        
        // [GIVEN] Purchase order over approval limit
        CreatePurchaseOrderOverLimit(PurchaseHeader);
        
        // [WHEN] Sending for approval
        LibraryWorkflow.SendPurchaseDocForApproval(PurchaseHeader);
        
        // [THEN] Approval entry is created
        FindApprovalEntry(ApprovalEntry, PurchaseHeader.RecordId);
        Assert.AreEqual(ApprovalEntry.Status::Open, ApprovalEntry.Status, 'Approval entry should be open');
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Purchase Process Test");
        
        if IsInitialized then
            exit;
            
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Purchase Process Test");
        
        // Setup approval workflow
        SetupApprovalWorkflow();
        
        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Purchase Process Test");
    end;

    local procedure SetupApprovalWorkflow()
    var
        WorkflowSetup: Codeunit "Workflow Setup";
    begin
        WorkflowSetup.InitWorkflow();
        LibraryWorkflow.CreateEnabledWorkflow(WorkflowSetup.PurchaseOrderApprovalWorkflowCode());
    end;
}
```

## Test Page Automation Samples

### Basic Test Page Usage

```al
codeunit 50102 "Customer Card Test"
{
    Subtype = Test;

    [Test]
    procedure TestCustomerCardFieldValidation()
    var
        Customer: Record Customer;
        CustomerCard: TestPage "Customer Card";
    begin
        // [SCENARIO] Customer card validates required fields
        
        // [GIVEN] New customer record
        Customer.Init();
        Customer.Insert(true);
        
        // [WHEN] Opening customer card and entering invalid data
        CustomerCard.OpenEdit();
        CustomerCard.GoToRecord(Customer);
        
        // [THEN] Field validation works correctly
        asserterror CustomerCard."Credit Limit (LCY)".SetValue(-1000);
        Assert.ExpectedError('Credit limit cannot be negative');
        
        // [WHEN] Entering valid data
        CustomerCard."Credit Limit (LCY)".SetValue(5000);
        CustomerCard.Close();
        
        // [THEN] Value is saved correctly
        Customer.Get(Customer."No.");
        Assert.AreEqual(5000, Customer."Credit Limit (LCY)", 'Credit limit not saved correctly');
    end;

    [Test]
    procedure TestCustomerCardActions()
    var
        Customer: Record Customer;
        CustomerCard: TestPage "Customer Card";
        CustomerLedgerEntries: TestPage "Customer Ledger Entries";
    begin
        // [SCENARIO] Customer card actions navigate correctly
        
        // [GIVEN] Customer with ledger entries
        CreateCustomerWithLedgerEntries(Customer);
        
        // [WHEN] Opening customer card and clicking ledger entries action
        CustomerCard.OpenView();
        CustomerCard.GoToRecord(Customer);
        CustomerLedgerEntries.Trap();
        CustomerCard."Ledger E&ntries".Invoke();
        
        // [THEN] Customer ledger entries page opens with correct filter
        Assert.AreEqual(Customer."No.", CustomerLedgerEntries.Filter.GetFilter("Customer No."), 
            'Customer ledger entries not filtered correctly');
        CustomerLedgerEntries.Close();
        CustomerCard.Close();
    end;
}
```

### Advanced Test Page Patterns

```al
codeunit 50103 "Sales Order Test Page"
{
    Subtype = Test;

    [Test]
    procedure TestSalesOrderLineEntry()
    var
        SalesHeader: Record "Sales Header";
        Item: Record Item;
        Customer: Record Customer;
        SalesOrder: TestPage "Sales Order";
    begin
        // [SCENARIO] Sales order line entry calculates totals automatically
        
        // [GIVEN] Sales order and item
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        LibraryInventory.CreateItem(Item);
        
        // [WHEN] Opening sales order and adding line
        SalesOrder.OpenEdit();
        SalesOrder.GoToRecord(SalesHeader);
        SalesOrder.SalesLines.New();
        SalesOrder.SalesLines.Type.SetValue(SalesOrder.SalesLines.Type::Item);
        SalesOrder.SalesLines."No.".SetValue(Item."No.");
        SalesOrder.SalesLines.Quantity.SetValue(10);
        SalesOrder.SalesLines."Unit Price".SetValue(50);
        
        // [THEN] Line amount is calculated automatically
        Assert.AreEqual(500, SalesOrder.SalesLines."Line Amount".AsDecimal(), 
            'Line amount calculation failed');
        
        // [WHEN] Adding second line
        SalesOrder.SalesLines.Next();
        SalesOrder.SalesLines.New();
        SalesOrder.SalesLines.Type.SetValue(SalesOrder.SalesLines.Type::Item);
        SalesOrder.SalesLines."No.".SetValue(Item."No.");
        SalesOrder.SalesLines.Quantity.SetValue(5);
        SalesOrder.SalesLines."Unit Price".SetValue(100);
        
        // [THEN] Document totals update correctly
        Assert.AreEqual(1000, SalesOrder."Total Amount Incl. VAT".AsDecimal(), 
            'Document total calculation failed');
        
        SalesOrder.Close();
    end;
}
```

## Business Process Testing Samples

### Document Posting Workflow Test

```al
codeunit 50104 "Sales Posting Workflow Test"
{
    Subtype = Test;

    [Test]
    procedure TestCompleteSalesProcess()
    var
        Customer: Record Customer;
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PostedShipmentNo: Code[20];
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO] Complete sales process from order to posting
        Initialize();
        
        // [GIVEN] Customer and item with inventory
        LibrarySales.CreateCustomer(Customer);
        CreateItemWithInventory(Item, 100);
        
        // [WHEN] Creating and posting sales order
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 10);
        SalesLine.Validate("Unit Price", 50);
        SalesLine.Modify(true);
        
        PostedShipmentNo := LibrarySales.PostSalesDocument(SalesHeader, true, false);
        PostedInvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, false, true);
        
        // [THEN] Posted documents are created correctly
        SalesShipmentHeader.Get(PostedShipmentNo);
        Assert.AreEqual(Customer."No.", SalesShipmentHeader."Sell-to Customer No.", 
            'Shipment customer mismatch');
        
        SalesInvoiceHeader.Get(PostedInvoiceNo);
        Assert.AreEqual(500, SalesInvoiceHeader.Amount, 'Invoice amount incorrect');
        
        // [THEN] Item inventory is reduced
        Item.Get(Item."No.");
        Item.CalcFields(Inventory);
        Assert.AreEqual(90, Item.Inventory, 'Item inventory not reduced correctly');
    end;

    local procedure CreateItemWithInventory(var Item: Record Item; Quantity: Decimal)
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        LibraryInventory.CreateItem(Item);
        LibraryInventory.CreateItemJournalLineInItemTemplate(
            ItemJournalLine, Item."No.", '', '', Quantity);
        LibraryInventory.PostItemJournalLine(
            ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");
    end;
}
```

### Multi-Document Validation Test

```al
codeunit 50105 "Purchase Return Test"
{
    Subtype = Test;

    [Test]
    procedure TestPurchaseReturnProcess()
    var
        Vendor: Record Vendor;
        Item: Record Item;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ReturnShipmentHeader: Record "Return Shipment Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        OriginalReceiptNo: Code[20];
        ReturnShipmentNo: Code[20];
        CreditMemoNo: Code[20];
    begin
        // [SCENARIO] Purchase return process creates correct documents
        
        // [GIVEN] Posted purchase receipt
        LibraryPurchase.CreateVendor(Vendor);
        LibraryInventory.CreateItem(Item);
        OriginalReceiptNo := CreateAndPostPurchaseReceipt(Vendor."No.", Item."No.", 20);
        
        // [WHEN] Creating and posting purchase return order
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::"Return Order", Vendor."No.");
        LibraryPurchase.CreatePurchLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, Item."No.", 5);
        PurchaseLine.Validate("Receipt No.", OriginalReceiptNo);
        PurchaseLine.Modify(true);
        
        ReturnShipmentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);
        CreditMemoNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);
        
        // [THEN] Return documents are created with correct references
        ReturnShipmentHeader.Get(ReturnShipmentNo);
        Assert.AreEqual(Vendor."No.", ReturnShipmentHeader."Buy-from Vendor No.", 
            'Return shipment vendor mismatch');
        
        PurchCrMemoHdr.Get(CreditMemoNo);
        Assert.AreEqual(ReturnShipmentNo, PurchCrMemoHdr."Return Shipment No.", 
            'Credit memo return shipment reference missing');
        
        // [THEN] Item inventory is adjusted correctly
        VerifyItemLedgerEntries(Item."No.", -5);
    end;

    local procedure CreateAndPostPurchaseReceipt(VendorNo: Code[20]; ItemNo: Code[20]; Quantity: Decimal): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, VendorNo);
        LibraryPurchase.CreatePurchLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, ItemNo, Quantity);
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false));
    end;

    local procedure VerifyItemLedgerEntries(ItemNo: Code[20]; ExpectedQuantity: Decimal)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        TotalQuantity: Decimal;
    begin
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.FindSet();
        repeat
            TotalQuantity += ItemLedgerEntry.Quantity;
        until ItemLedgerEntry.Next() = 0;
        
        Assert.AreEqual(ExpectedQuantity, TotalQuantity, 
            StrSubstNo('Item ledger entries total quantity should be %1', ExpectedQuantity));
    end;
}
```

## Test Data Management Samples

### Temporary Table Testing Pattern

```al
codeunit 50106 "Data Processing Test"
{
    Subtype = Test;

    [Test]
    procedure TestDataProcessingWithTempTable()
    var
        TempCustomer: Record Customer temporary;
        Customer: Record Customer;
        ProcessingResult: Integer;
    begin
        // [SCENARIO] Data processing works correctly with temporary tables
        
        // [GIVEN] Temporary table with test data
        CreateTempCustomerData(TempCustomer);
        
        // [WHEN] Processing temporary data
        ProcessingResult := ProcessCustomerData(TempCustomer);
        
        // [THEN] Processing completes without affecting permanent data
        Assert.AreEqual(3, ProcessingResult, 'Processing result incorrect');
        
        // [THEN] No permanent records were created
        Customer.SetRange("No.", 'TEMP001', 'TEMP003');
        Assert.RecordIsEmpty(Customer);
    end;

    local procedure CreateTempCustomerData(var TempCustomer: Record Customer temporary)
    var
        i: Integer;
    begin
        for i := 1 to 3 do begin
            TempCustomer.Init();
            TempCustomer."No." := 'TEMP00' + Format(i);
            TempCustomer.Name := 'Test Customer ' + Format(i);
            TempCustomer."Credit Limit (LCY)" := i * 1000;
            TempCustomer.Insert();
        end;
    end;

    local procedure ProcessCustomerData(var TempCustomer: Record Customer temporary): Integer
    var
        ProcessedCount: Integer;
    begin
        if TempCustomer.FindSet() then
            repeat
                // Simulate data processing
                TempCustomer."Credit Limit (LCY)" := TempCustomer."Credit Limit (LCY)" * 1.1;
                TempCustomer.Modify();
                ProcessedCount += 1;
            until TempCustomer.Next() = 0;
        exit(ProcessedCount);
    end;
}
```

### Test Data Cleanup Pattern

```al
codeunit 50107 "Test Data Cleanup Example"
{
    Subtype = Test;

    var
        CreatedCustomerNos: List of [Code[20]];
        CreatedItemNos: List of [Code[20]];

    [Test]
    procedure TestWithAutomaticCleanup()
    var
        Customer: Record Customer;
        Item: Record Item;
        SalesHeader: Record "Sales Header";
    begin
        // [SCENARIO] Test with automatic cleanup of created records
        
        // [GIVEN] Test data that will be cleaned up
        CreateTestCustomer(Customer);
        CreateTestItem(Item);
        
        // [WHEN] Performing business operations
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        
        // [THEN] Operations complete successfully
        Assert.AreEqual(Customer."No.", SalesHeader."Sell-to Customer No.", 
            'Sales header customer assignment failed');
    end;

    [TearDown]
    procedure TearDown()
    begin
        CleanupTestData();
    end;

    local procedure CreateTestCustomer(var Customer: Record Customer)
    begin
        LibrarySales.CreateCustomer(Customer);
        CreatedCustomerNos.Add(Customer."No.");
    end;

    local procedure CreateTestItem(var Item: Record Item)
    begin
        LibraryInventory.CreateItem(Item);
        CreatedItemNos.Add(Item."No.");
    end;

    local procedure CleanupTestData()
    var
        Customer: Record Customer;
        Item: Record Item;
        CustomerNo: Code[20];
        ItemNo: Code[20];
    begin
        // Clean up customers
        foreach CustomerNo in CreatedCustomerNos do
            if Customer.Get(CustomerNo) then
                Customer.Delete(true);
        
        // Clean up items
        foreach ItemNo in CreatedItemNos do
            if Item.Get(ItemNo) then
                Item.Delete(true);
        
        Clear(CreatedCustomerNos);
        Clear(CreatedItemNos);
    end;
}
```

## Performance and Integration Testing

### Performance Test Pattern

```al
codeunit 50108 "Performance Test Example"
{
    Subtype = Test;

    [Test]
    procedure TestLargeDatasetPerformance()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        StartTime: DateTime;
        EndTime: DateTime;
        ElapsedTime: Duration;
        i: Integer;
    begin
        // [SCENARIO] System performs adequately with large datasets
        
        // [GIVEN] Large number of sales orders
        LibrarySales.CreateCustomer(Customer);
        StartTime := CurrentDateTime();
        
        for i := 1 to 100 do
            LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        
        EndTime := CurrentDateTime();
        ElapsedTime := EndTime - StartTime;
        
        // [THEN] Performance is within acceptable limits
        Assert.IsTrue(ElapsedTime < 30000, 'Performance test exceeded 30 second limit');
        
        // [THEN] All records were created
        SalesHeader.SetRange("Sell-to Customer No.", Customer."No.");
        Assert.AreEqual(100, SalesHeader.Count(), 'Not all sales orders were created');
    end;
}
```

These samples demonstrate comprehensive BC test automation patterns using the platform's built-in testing framework, test pages, and business validation capabilities.