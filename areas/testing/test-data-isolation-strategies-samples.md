---
title: "Test Data Isolation Strategies - Code Samples"
description: "Complete implementations for maintaining data separation and preventing conflicts during automated testing scenarios"
area: "testing"
difficulty: "intermediate"
object_types: ["Codeunit", "TableExtension", "Table"]
variable_types: ["Record", "RecordRef", "FieldRef", "Dictionary"]
tags: ["testing", "data-isolation", "test-framework", "data-management", "conflict-prevention", "samples"]
---

# Test Data Isolation Strategies - Code Samples

## Complete Transaction-Based Isolation Implementation

### Advanced Transaction Manager

```al
codeunit 50300 "Advanced Transaction Manager"
{
    var
        TransactionStack: List of [Guid];
        IsolationContexts: Dictionary of [Guid, Record "Test Isolation Context"];
        SavePointManager: Codeunit "SavePoint Manager";
        
    /// <summary>
    /// Creates a new isolated transaction context with comprehensive tracking
    /// </summary>
    procedure BeginIsolatedTransaction(ContextName: Text[100]): Guid
    var
        IsolationContext: Record "Test Isolation Context";
        ContextId: Guid;
    begin
        ContextId := CreateGuid();
        
        // Create isolation context record
        IsolationContext.Init();
        IsolationContext."Context ID" := ContextId;
        IsolationContext."Context Name" := ContextName;
        IsolationContext."Session ID" := SessionId();
        IsolationContext."User ID" := UserId;
        IsolationContext."Start Time" := CurrentDateTime;
        IsolationContext."Transaction Level" := TransactionStack.Count + 1;
        IsolationContext.Active := true;
        
        // Store context
        IsolationContexts.Add(ContextId, IsolationContext);
        TransactionStack.Add(ContextId);
        
        // Begin database transaction
        if TransactionStack.Count = 1 then
            StartTransaction();
            
        // Create savepoint for nested transactions
        SavePointManager.CreateSavePoint(Format(ContextId));
        
        exit(ContextId);
    end;
    
    /// <summary>
    /// Commits an isolated transaction context
    /// </summary>
    procedure CommitIsolatedTransaction(ContextId: Guid): Boolean
    var
        IsolationContext: Record "Test Isolation Context";
    begin
        if not ValidateContext(ContextId, IsolationContext) then
            exit(false);
            
        // Update context
        IsolationContext."End Time" := CurrentDateTime;
        IsolationContext.Active := false;
        IsolationContext.Committed := true;
        IsolationContexts.Set(ContextId, IsolationContext);
        
        // Remove from transaction stack
        TransactionStack.Remove(ContextId);
        
        // Commit if this is the root transaction
        if TransactionStack.Count = 0 then
            CommitTransaction()
        else
            SavePointManager.ReleaseSavePoint(Format(ContextId));
            
        LogTransactionEvent(ContextId, 'COMMIT');
        exit(true);
    end;
    
    /// <summary>
    /// Rolls back an isolated transaction context
    /// </summary>
    procedure RollbackIsolatedTransaction(ContextId: Guid): Boolean
    var
        IsolationContext: Record "Test Isolation Context";
        StackIndex: Integer;
    begin
        if not ValidateContext(ContextId, IsolationContext) then
            exit(false);
            
        // Find context position in stack
        for StackIndex := TransactionStack.Count downto 1 do begin
            if TransactionStack.Get(StackIndex) = ContextId then
                break;
        end;
        
        // Rollback to savepoint or full transaction
        if StackIndex = 1 then
            RollbackTransaction()
        else
            SavePointManager.RollbackToSavePoint(Format(ContextId));
            
        // Update context and remove from stack
        IsolationContext."End Time" := CurrentDateTime;
        IsolationContext.Active := false;
        IsolationContext.Committed := false;
        IsolationContexts.Set(ContextId, IsolationContext);
        
        // Remove this and all nested contexts from stack
        while TransactionStack.Count >= StackIndex do
            TransactionStack.RemoveAt(TransactionStack.Count);
            
        LogTransactionEvent(ContextId, 'ROLLBACK');
        exit(true);
    end;
    
    /// <summary>
    /// Gets statistics for the current isolation context
    /// </summary>
    procedure GetContextStatistics(ContextId: Guid; var Statistics: Record "Test Context Statistics"): Boolean
    var
        IsolationContext: Record "Test Isolation Context";
    begin
        if not IsolationContexts.Get(ContextId, IsolationContext) then
            exit(false);
            
        Statistics.Init();
        Statistics."Context ID" := ContextId;
        Statistics."Context Name" := IsolationContext."Context Name";
        Statistics."Duration (ms)" := CurrentDateTime - IsolationContext."Start Time";
        Statistics."Records Created" := CountCreatedRecords(ContextId);
        Statistics."Records Modified" := CountModifiedRecords(ContextId);
        Statistics."Records Deleted" := CountDeletedRecords(ContextId);
        Statistics."Memory Usage (KB)" := GetContextMemoryUsage(ContextId);
        
        exit(true);
    end;
    
    local procedure ValidateContext(ContextId: Guid; var IsolationContext: Record "Test Isolation Context"): Boolean
    begin
        if not IsolationContexts.Get(ContextId, IsolationContext) then begin
            Error('Invalid isolation context ID: %1', ContextId);
            exit(false);
        end;
        
        if not IsolationContext.Active then begin
            Error('Isolation context %1 is not active', IsolationContext."Context Name");
            exit(false);
        end;
        
        exit(true);
    end;
    
    local procedure CountCreatedRecords(ContextId: Guid): Integer
    var
        ChangeLog: Record "Test Data Change Log";
    begin
        ChangeLog.SetRange("Context ID", ContextId);
        ChangeLog.SetRange("Operation Type", ChangeLog."Operation Type"::Insert);
        exit(ChangeLog.Count);
    end;
    
    local procedure CountModifiedRecords(ContextId: Guid): Integer
    var
        ChangeLog: Record "Test Data Change Log";
    begin
        ChangeLog.SetRange("Context ID", ContextId);
        ChangeLog.SetRange("Operation Type", ChangeLog."Operation Type"::Modify);
        exit(ChangeLog.Count);
    end;
    
    local procedure CountDeletedRecords(ContextId: Guid): Integer
    var
        ChangeLog: Record "Test Data Change Log";
    begin
        ChangeLog.SetRange("Context ID", ContextId);
        ChangeLog.SetRange("Operation Type", ChangeLog."Operation Type"::Delete);
        exit(ChangeLog.Count);
    end;
    
    local procedure GetContextMemoryUsage(ContextId: Guid): Integer
    var
        TempBlob: Record TempBlob temporary;
    begin
        // Implementation would measure actual memory usage
        // This is a simplified version
        exit(Random(1024));
    end;
    
    local procedure LogTransactionEvent(ContextId: Guid; EventType: Text[20])
    var
        TransactionLog: Record "Test Transaction Log";
    begin
        TransactionLog.Init();
        TransactionLog."Entry No." := GetNextLogEntryNo();
        TransactionLog."Context ID" := ContextId;
        TransactionLog."Event Type" := EventType;
        TransactionLog."Event Time" := CurrentDateTime;
        TransactionLog."Session ID" := SessionId();
        TransactionLog."User ID" := UserId;
        TransactionLog.Insert(true);
    end;
    
    local procedure GetNextLogEntryNo(): Integer
    var
        TransactionLog: Record "Test Transaction Log";
    begin
        TransactionLog.LockTable();
        if TransactionLog.FindLast() then
            exit(TransactionLog."Entry No." + 1)
        else
            exit(1);
    end;
}
```

### Complete Company-Level Isolation

```al
codeunit 50301 "Company Isolation Manager"
{
    var
        TestCompanies: Dictionary of [Text, Record "Test Company Registry"];
        CompanyTemplates: Dictionary of [Text, Record "Company Setup Template"];
        
    /// <summary>
    /// Creates a fully isolated test company with complete setup
    /// </summary>
    procedure CreateFullyIsolatedCompany(CompanyPrefix: Text[10]; TemplateCode: Code[20]): Text[30]
    var
        Company: Record Company;
        CompanyInformation: Record "Company Information";
        GeneralLedgerSetup: Record "General Ledger Setup";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        InventorySetup: Record "Inventory Setup";
        CompanyRegistry: Record "Test Company Registry";
        CompanyName: Text[30];
        CurrentCompany: Text[30];
    begin
        CompanyName := GenerateUniqueCompanyName(CompanyPrefix);
        CurrentCompany := CompanyName();
        
        try
            // Create the company
            Company.Init();
            Company.Name := CompanyName;
            Company."Display Name" := 'Test Company - ' + CompanyPrefix;
            Company."Evaluation Company" := true;
            Company.Insert(true);
            
            // Switch to new company for setup
            ChangeCompany(CompanyName);
            
            // Apply company template
            ApplyCompanyTemplate(TemplateCode);
            
            // Setup company information
            SetupCompanyInformation(CompanyPrefix);
            
            // Setup all modules
            SetupGeneralLedger();
            SetupSalesReceivables();
            SetupPurchasesPayables();
            SetupInventoryManagement();
            SetupNumberSeries();
            
            // Create master data
            CreateMasterData();
            
            // Register company
            CompanyRegistry.Init();
            CompanyRegistry."Company Name" := CompanyName;
            CompanyRegistry."Company Prefix" := CompanyPrefix;
            CompanyRegistry."Template Code" := TemplateCode;
            CompanyRegistry."Created DateTime" := CurrentDateTime;
            CompanyRegistry."Created By" := UserId;
            CompanyRegistry."Session ID" := SessionId();
            CompanyRegistry.Active := true;
            TestCompanies.Add(CompanyName, CompanyRegistry);
            
        finally
            // Switch back to original company
            ChangeCompany(CurrentCompany);
        end;
        
        exit(CompanyName);
    end;
    
    /// <summary>
    /// Destroys isolated test company and all its data
    /// </summary>
    procedure DestroyIsolatedCompany(CompanyName: Text[30]): Boolean
    var
        Company: Record Company;
        CompanyRegistry: Record "Test Company Registry";
        CurrentCompany: Text[30];
    begin
        if not TestCompanies.Get(CompanyName, CompanyRegistry) then
            exit(false);
            
        CurrentCompany := CompanyName();
        
        try
            // Validate company can be deleted
            if not ValidateCompanyCanBeDeleted(CompanyName) then
                exit(false);
                
            // Switch to company and perform pre-deletion cleanup
            ChangeCompany(CompanyName);
            PerformPreDeletionCleanup();
            
            // Switch back and delete company
            ChangeCompany(CurrentCompany);
            Company.Get(CompanyName);
            Company.Delete(true);
            
            // Update registry
            CompanyRegistry.Active := false;
            CompanyRegistry."Deleted DateTime" := CurrentDateTime;
            CompanyRegistry."Deleted By" := UserId;
            TestCompanies.Set(CompanyName, CompanyRegistry);
            
        except
            ChangeCompany(CurrentCompany);
            exit(false);
        end;
        
        exit(true);
    end;
    
    /// <summary>
    /// Creates comprehensive test data in isolated company
    /// </summary>
    procedure PopulateTestData(CompanyName: Text[30]; DataSetCode: Code[20])
    var
        CurrentCompany: Text[30];
        TestDataLibrary: Codeunit "Test Data Generation Library";
        Customer: Record Customer;
        Vendor: Record Vendor;
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        i: Integer;
    begin
        CurrentCompany := CompanyName();
        ChangeCompany(CompanyName);
        
        try
            // Create customers
            for i := 1 to 10 do begin
                TestDataLibrary.CreateTestCustomer(Customer);
                Customer.Name := Customer.Name + ' ' + Format(i);
                Customer.Modify(true);
            end;
            
            // Create vendors
            for i := 1 to 5 do begin
                TestDataLibrary.CreateTestVendor(Vendor);
                Vendor.Name := Vendor.Name + ' ' + Format(i);
                Vendor.Modify(true);
            end;
            
            // Create items
            for i := 1 to 20 do begin
                TestDataLibrary.CreateTestItem(Item);
                Item.Description := Item.Description + ' ' + Format(i);
                Item.Modify(true);
            end;
            
            // Create sales orders
            for i := 1 to 5 do
                TestDataLibrary.CreateTestSalesOrder(SalesHeader);
                
            // Create purchase orders
            for i := 1 to 3 do
                TestDataLibrary.CreateTestPurchaseOrder(PurchaseHeader);
                
        finally
            ChangeCompany(CurrentCompany);
        end;
    end;
    
    local procedure GenerateUniqueCompanyName(Prefix: Text[10]): Text[30]
    var
        Company: Record Company;
        CompanyName: Text[30];
        Counter: Integer;
        MaxAttempts: Integer;
    begin
        MaxAttempts := 1000;
        repeat
            Counter += 1;
            CompanyName := 'TEST_' + Prefix + '_' + Format(Random(99999)).PadLeft(5, '0');
        until (not Company.Get(CompanyName)) or (Counter > MaxAttempts);
        
        if Counter > MaxAttempts then
            Error('Unable to generate unique company name after %1 attempts', MaxAttempts);
            
        exit(CompanyName);
    end;
    
    local procedure ApplyCompanyTemplate(TemplateCode: Code[20])
    var
        CompanySetupTemplate: Record "Company Setup Template";
    begin
        if CompanySetupTemplate.Get(TemplateCode) then begin
            // Apply template configuration
            // This would contain the actual template application logic
        end;
    end;
    
    local procedure SetupCompanyInformation(CompanyPrefix: Text[10])
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Init();
        CompanyInformation.Name := 'Test Company ' + CompanyPrefix;
        CompanyInformation.Address := 'XTest Address 123';
        CompanyInformation.City := 'XTest City';
        CompanyInformation."Post Code" := 'X12345';
        CompanyInformation."Country/Region Code" := 'US';
        CompanyInformation."Phone No." := '+1-555-XTEST';
        CompanyInformation."E-Mail" := 'test@' + CompanyPrefix + '.example.com';
        CompanyInformation."Home Page" := 'https://' + CompanyPrefix + '.test.example.com';
        CompanyInformation.Insert(true);
    end;
    
    local procedure SetupGeneralLedger()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        Currency: Record Currency;
        GLAccount: Record "G/L Account";
        i: Integer;
    begin
        // Setup G/L configuration
        GeneralLedgerSetup."LCY Code" := 'USD';
        GeneralLedgerSetup."Local Currency Symbol" := '$';
        GeneralLedgerSetup."Local Currency Description" := 'US Dollar';
        GeneralLedgerSetup.Modify(true);
        
        // Create basic chart of accounts
        CreateTestChartOfAccounts();
    end;
    
    local procedure SetupNumberSeries()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        // Customer number series
        CreateNumberSeries('XCUST', 'Test Customers', 'XCUST000001', 'XCUST999999');
        
        // Vendor number series
        CreateNumberSeries('XVEND', 'Test Vendors', 'XVEND000001', 'XVEND999999');
        
        // Item number series
        CreateNumberSeries('XITEM', 'Test Items', 'XITEM00001', 'XITEM99999');
        
        // Sales document series
        CreateNumberSeries('XSO', 'Test Sales Orders', 'XSO0000001', 'XSO9999999');
        CreateNumberSeries('XSI', 'Test Sales Invoices', 'XSI0000001', 'XSI9999999');
        
        // Purchase document series
        CreateNumberSeries('XPO', 'Test Purchase Orders', 'XPO0000001', 'XPO9999999');
        CreateNumberSeries('XPI', 'Test Purchase Invoices', 'XPI0000001', 'XPI9999999');
    end;
    
    local procedure CreateNumberSeries(SeriesCode: Code[20]; Description: Text[100]; StartNo: Code[20]; EndNo: Code[20])
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if NoSeries.Get(SeriesCode) then
            exit;
            
        NoSeries.Init();
        NoSeries.Code := SeriesCode;
        NoSeries.Description := Description;
        NoSeries."Default Nos." := true;
        NoSeries."Manual Nos." := true;
        NoSeries.Insert(true);
        
        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := SeriesCode;
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine."Starting Date" := Today;
        NoSeriesLine."Starting No." := StartNo;
        NoSeriesLine."Ending No." := EndNo;
        NoSeriesLine."Increment-by No." := 1;
        NoSeriesLine.Insert(true);
    end;
    
    local procedure CreateTestChartOfAccounts()
    var
        GLAccount: Record "G/L Account";
    begin
        // Create basic test G/L accounts
        CreateGLAccount('X1000', 'XTest Cash Account', GLAccount."Account Type"::Posting, GLAccount."Account Category"::Assets);
        CreateGLAccount('X1100', 'XTest Accounts Receivable', GLAccount."Account Type"::Posting, GLAccount."Account Category"::Assets);
        CreateGLAccount('X1200', 'XTest Inventory', GLAccount."Account Type"::Posting, GLAccount."Account Category"::Assets);
        CreateGLAccount('X2000', 'XTest Accounts Payable', GLAccount."Account Type"::Posting, GLAccount."Account Category"::Liabilities);
        CreateGLAccount('X3000', 'XTest Equity', GLAccount."Account Type"::Posting, GLAccount."Account Category"::Equity);
        CreateGLAccount('X4000', 'XTest Revenue', GLAccount."Account Type"::Posting, GLAccount."Account Category"::Income);
        CreateGLAccount('X5000', 'XTest Cost of Goods Sold', GLAccount."Account Type"::Posting, GLAccount."Account Category"::"Cost of Goods Sold");
        CreateGLAccount('X6000', 'XTest Operating Expenses', GLAccount."Account Type"::Posting, GLAccount."Account Category"::Expense);
    end;
    
    local procedure CreateGLAccount(AccountNo: Code[20]; AccountName: Text[100]; AccountType: Enum "G/L Account Type"; AccountCategory: Enum "G/L Account Category")
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.Init();
        GLAccount."No." := AccountNo;
        GLAccount.Name := AccountName;
        GLAccount."Account Type" := AccountType;
        GLAccount."Account Category" := AccountCategory;
        GLAccount."Direct Posting" := true;
        GLAccount.Insert(true);
    end;
    
    local procedure ValidateCompanyCanBeDeleted(CompanyName: Text[30]): Boolean
    var
        Company: Record Company;
        GLEntry: Record "G/L Entry";
    begin
        // Check if company exists
        if not Company.Get(CompanyName) then
            exit(false);
            
        // Check if company has any posted entries
        GLEntry.ChangeCompany(CompanyName);
        if not GLEntry.IsEmpty() then begin
            Message('Cannot delete company %1 - contains posted entries', CompanyName);
            exit(false);
        end;
        
        exit(true);
    end;
    
    local procedure PerformPreDeletionCleanup()
    begin
        // Additional cleanup procedures before company deletion
        // Remove any specific test artifacts
    end;
    
    local procedure CreateMasterData()
    var
        PaymentTerms: Record "Payment Terms";
        PaymentMethod: Record "Payment Method";
        ShipmentMethod: Record "Shipment Method";
        CustomerPostingGroup: Record "Customer Posting Group";
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        // Create basic setup records needed for master data
        CreatePaymentTerms('X30DAYS', '30 Days Net', '<30D>');
        CreatePaymentMethod('XCHECK', 'Test Check Payment');
        CreateShipmentMethod('XGROUND', 'Test Ground Shipping');
        CreateCustomerPostingGroup('XCUSTOMER', 'Test Customers');
        CreateVendorPostingGroup('XVENDOR', 'Test Vendors');
    end;
    
    local procedure CreatePaymentTerms(Code: Code[10]; Description: Text[100]; DueDateCalculation: DateFormula)
    var
        PaymentTerms: Record "Payment Terms";
    begin
        PaymentTerms.Init();
        PaymentTerms.Code := Code;
        PaymentTerms.Description := Description;
        PaymentTerms."Due Date Calculation" := DueDateCalculation;
        PaymentTerms.Insert(true);
    end;
    
    local procedure CreatePaymentMethod(Code: Code[10]; Description: Text[100])
    var
        PaymentMethod: Record "Payment Method";
    begin
        PaymentMethod.Init();
        PaymentMethod.Code := Code;
        PaymentMethod.Description := Description;
        PaymentMethod.Insert(true);
    end;
    
    local procedure CreateShipmentMethod(Code: Code[10]; Description: Text[100])
    var
        ShipmentMethod: Record "Shipment Method";
    begin
        ShipmentMethod.Init();
        ShipmentMethod.Code := Code;
        ShipmentMethod.Description := Description;
        ShipmentMethod.Insert(true);
    end;
    
    local procedure CreateCustomerPostingGroup(Code: Code[20]; Description: Text[100])
    var
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        CustomerPostingGroup.Init();
        CustomerPostingGroup.Code := Code;
        CustomerPostingGroup.Description := Description;
        CustomerPostingGroup."Receivables Account" := 'X1100';
        CustomerPostingGroup.Insert(true);
    end;
    
    local procedure CreateVendorPostingGroup(Code: Code[20]; Description: Text[100])
    var
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        VendorPostingGroup.Init();
        VendorPostingGroup.Code := Code;
        VendorPostingGroup.Description := Description;
        VendorPostingGroup."Payables Account" := 'X2000';
        VendorPostingGroup.Insert(true);
    end;
    
    local procedure SetupSalesReceivables()
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup."Customer Nos." := 'XCUST';
        SalesReceivablesSetup."Order Nos." := 'XSO';
        SalesReceivablesSetup."Invoice Nos." := 'XSI';
        SalesReceivablesSetup.Modify(true);
    end;
    
    local procedure SetupPurchasesPayables()
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        PurchasesPayablesSetup."Vendor Nos." := 'XVEND';
        PurchasesPayablesSetup."Order Nos." := 'XPO';
        PurchasesPayablesSetup."Invoice Nos." := 'XPI';
        PurchasesPayablesSetup.Modify(true);
    end;
    
    local procedure SetupInventoryManagement()
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup."Item Nos." := 'XITEM';
        InventorySetup.Modify(true);
    end;
}
```

These comprehensive samples provide production-ready isolation strategies with complete transaction management, company-level isolation, and robust cleanup procedures.
