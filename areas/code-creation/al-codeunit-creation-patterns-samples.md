# AL Codeunit Creation Patterns - Code Samples

## Basic Business Logic Codeunit Examples

### Simple Calculation and Validation Codeunit

```al
// Basic codeunit with calculation and validation logic
codeunit 50100 "Order Total Calculator"
{
    Access = Public;
    
    /// <summary>
    /// Calculates order total with discounts and taxes
    /// </summary>
    /// <param name="OrderNo">Sales order to calculate</param>
    /// <returns>Total order amount including tax</returns>
    procedure CalculateOrderTotal(OrderNo: Code[20]): Decimal
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SubTotal: Decimal;
        DiscountAmount: Decimal;
        TaxAmount: Decimal;
        TotalAmount: Decimal;
    begin
        // Input validation
        if OrderNo = '' then
            Error('Order number cannot be empty.');
            
        // Validate order exists
        if not SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo) then
            Error('Sales order %1 does not exist.', OrderNo);
            
        // Calculate subtotal
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", OrderNo);
        SalesLine.CalcSums(Amount);
        SubTotal := SalesLine.Amount;
        
        // Calculate discount
        DiscountAmount := CalculateOrderDiscount(SalesHeader, SubTotal);
        
        // Calculate tax on discounted amount
        TaxAmount := CalculateOrderTax(SalesHeader, SubTotal - DiscountAmount);
        
        // Calculate total
        TotalAmount := SubTotal - DiscountAmount + TaxAmount;
        
        // Log calculation for audit
        LogOrderCalculation(OrderNo, SubTotal, DiscountAmount, TaxAmount, TotalAmount);
        
        exit(TotalAmount);
    end;
    
    /// <summary>
    /// Validates order data for calculation
    /// </summary>
    /// <param name="OrderNo">Order to validate</param>
    procedure ValidateOrderForCalculation(OrderNo: Code[20]): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
    begin
        // Check order exists
        if not SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo) then
            exit(false);
            
        // Check customer exists and is not blocked
        if not Customer.Get(SalesHeader."Sell-to Customer No.") then
            exit(false);
            
        if Customer.Blocked <> Customer.Blocked::" " then
            exit(false);
            
        // Check order has lines
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", OrderNo);
        exit(not SalesLine.IsEmpty());
    end;
    
    /// <summary>
    /// Updates order totals after line changes
    /// </summary>
    /// <param name="OrderNo">Order to update</param>
    procedure UpdateOrderTotals(OrderNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
        NewTotal: Decimal;
    begin
        if not ValidateOrderForCalculation(OrderNo) then
            Error('Order %1 is not valid for total calculation.', OrderNo);
            
        // Calculate new total
        NewTotal := CalculateOrderTotal(OrderNo);
        
        // Update header with calculated total
        SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo);
        SalesHeader.Validate("Total Amount", NewTotal);
        SalesHeader.Modify(true);
        
        // Send notification if total changed significantly
        CheckForSignificantTotalChange(OrderNo, SalesHeader."Total Amount", NewTotal);
    end;
    
    /// <summary>
    /// Calculates discount amount for order
    /// </summary>
    local procedure CalculateOrderDiscount(SalesHeader: Record "Sales Header"; SubTotal: Decimal): Decimal
    var
        Customer: Record Customer;
        CustomerDiscountGroup: Record "Customer Discount Group";
        DiscountPct: Decimal;
    begin
        // Get customer discount percentage
        if Customer.Get(SalesHeader."Sell-to Customer No.") then begin
            if CustomerDiscountGroup.Get(Customer."Customer Disc. Group") then
                DiscountPct := CustomerDiscountGroup."Discount %";
        end;
        
        // Apply volume discount if applicable
        if SubTotal > 10000 then
            DiscountPct += 2; // Additional 2% for large orders
            
        exit(Round(SubTotal * DiscountPct / 100, 0.01));
    end;
    
    /// <summary>
    /// Calculates tax amount for order
    /// </summary>
    local procedure CalculateOrderTax(SalesHeader: Record "Sales Header"; TaxableAmount: Decimal): Decimal
    var
        TaxAreaCode: Code[20];
        TaxRate: Decimal;
    begin
        // Get tax area from customer or ship-to address
        TaxAreaCode := GetTaxAreaCode(SalesHeader);
        
        // Get tax rate for area
        TaxRate := GetTaxRate(TaxAreaCode);
        
        // Calculate tax
        exit(Round(TaxableAmount * TaxRate / 100, 0.01));
    end;
    
    /// <summary>
    /// Logs order calculation for audit trail
    /// </summary>
    local procedure LogOrderCalculation(OrderNo: Code[20]; SubTotal: Decimal; Discount: Decimal; Tax: Decimal; Total: Decimal)
    var
        ActivityLog: Record "Activity Log";
        LogMessage: Text;
    begin
        LogMessage := StrSubstNo('Order %1 calculated: Subtotal=%2, Discount=%3, Tax=%4, Total=%5',
            OrderNo, SubTotal, Discount, Tax, Total);
            
        ActivityLog.LogActivity(
            Database::"Sales Header",
            ActivityLog.Status::Success,
            'Order Calculation',
            'Totals Calculated',
            LogMessage);
    end;
}
```

## Intermediate Business Logic with Complex Validation

### Inventory Management Codeunit

```al
// Intermediate codeunit with complex business rules and validation
codeunit 50101 "Inventory Reservation Manager"
{
    Access = Public;
    
    /// <summary>
    /// Reserves inventory for sales order with comprehensive validation
    /// </summary>
    /// <param name="OrderNo">Sales order number</param>
    /// <param name="ForceReservation">Whether to force reservation even if low stock</param>
    procedure ReserveInventoryForOrder(OrderNo: Code[20]; ForceReservation: Boolean): Boolean
    var
        SalesLine: Record "Sales Line";
        Item: Record Item;
        ReservationEntry: Record "Reservation Entry";
        InventoryLevel: Decimal;
        ReservedQuantity: Decimal;
        AvailableQuantity: Decimal;
        TotalReserved: Integer;
        TotalLines: Integer;
    begin
        // Comprehensive input validation
        ValidateReservationParameters(OrderNo, ForceReservation);
        
        // Process each line in the order
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", OrderNo);
        SalesLine.SetFilter(Type, '%1', SalesLine.Type::Item);
        
        if SalesLine.FindSet() then begin
            repeat
                TotalLines += 1;
                
                // Validate item can be reserved
                if ValidateItemReservation(SalesLine."No.", SalesLine.Quantity) then begin
                    // Check inventory availability
                    InventoryLevel := GetAvailableInventory(SalesLine."No.", SalesLine."Location Code");
                    ReservedQuantity := GetReservedQuantity(SalesLine."No.", SalesLine."Location Code");
                    AvailableQuantity := InventoryLevel - ReservedQuantity;
                    
                    // Apply business rules for reservation
                    if CanReserveQuantity(SalesLine."No.", SalesLine.Quantity, AvailableQuantity, ForceReservation) then begin
                        // Create reservation entry
                        if CreateReservationEntry(SalesLine) then
                            TotalReserved += 1
                        else
                            LogReservationFailure(OrderNo, SalesLine."No.", 'Failed to create reservation entry');
                    end else
                        LogReservationFailure(OrderNo, SalesLine."No.", 
                            StrSubstNo('Insufficient inventory: Available=%1, Required=%2', AvailableQuantity, SalesLine.Quantity));
                end else
                    LogReservationFailure(OrderNo, SalesLine."No.", 'Item not eligible for reservation');
                    
            until SalesLine.Next() = 0;
        end;
        
        // Evaluate reservation success
        LogReservationSummary(OrderNo, TotalLines, TotalReserved);
        
        // Return success if all or most lines were reserved
        exit(TotalReserved >= Round(TotalLines * 0.8, 1)); // 80% success threshold
    end;
    
    /// <summary>
    /// Validates reservation parameters and business rules
    /// </summary>
    local procedure ValidateReservationParameters(OrderNo: Code[20]; ForceReservation: Boolean)
    var
        SalesHeader: Record "Sales Header";
        Customer: Record Customer;
        InventorySetup: Record "Inventory Setup";
    begin
        // Basic parameter validation
        if OrderNo = '' then
            Error('Order number cannot be empty.');
            
        // Validate order exists and is appropriate status
        if not SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo) then
            Error('Sales order %1 does not exist.', OrderNo);
            
        if SalesHeader.Status = SalesHeader.Status::Released then
            Error('Cannot modify reservations for released order %1.', OrderNo);
            
        // Validate customer eligibility
        if not Customer.Get(SalesHeader."Sell-to Customer No.") then
            Error('Customer %1 does not exist.', SalesHeader."Sell-to Customer No.");
            
        if Customer.Blocked <> Customer.Blocked::" " then
            Error('Cannot reserve inventory for blocked customer %1.', Customer."No.");
            
        // Check inventory setup allows reservations
        InventorySetup.Get();
        if not InventorySetup."Allow Reservations" then
            Error('Inventory reservations are not enabled in system setup.');
    end;
    
    /// <summary>
    /// Validates whether an item can be reserved
    /// </summary>
    local procedure ValidateItemReservation(ItemNo: Code[20]; Quantity: Decimal): Boolean
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
    begin
        // Check item exists
        if not Item.Get(ItemNo) then
            exit(false);
            
        // Check item allows reservations
        if not Item.Reserve then
            exit(false);
            
        // Check item is not blocked
        if Item.Blocked then
            exit(false);
            
        // Check quantity is positive
        if Quantity <= 0 then
            exit(false);
            
        // Additional business rule validations
        if Item.Type <> Item.Type::Inventory then
            exit(false);
            
        exit(true);
    end;
    
    /// <summary>
    /// Checks if quantity can be reserved based on business rules
    /// </summary>
    local procedure CanReserveQuantity(ItemNo: Code[20]; RequiredQty: Decimal; AvailableQty: Decimal; ForceReservation: Boolean): Boolean
    var
        Item: Record Item;
        MinimumStockLevel: Decimal;
        SafetyStockLevel: Decimal;
        ReservableQuantity: Decimal;
    begin
        Item.Get(ItemNo);
        
        // Get stock level requirements
        MinimumStockLevel := Item."Minimum Inventory";
        SafetyStockLevel := Item."Safety Stock Quantity";
        
        // Calculate quantity available for reservation (considering safety stock)
        ReservableQuantity := AvailableQty - MaxValue(MinimumStockLevel, SafetyStockLevel);
        
        // Check if sufficient quantity available
        if RequiredQty <= ReservableQuantity then
            exit(true);
            
        // If forced reservation allowed, check against total available
        if ForceReservation and (RequiredQty <= AvailableQty) then begin
            // Log warning about low stock reservation
            LogLowStockReservation(ItemNo, RequiredQty, AvailableQty, ReservableQuantity);
            exit(true);
        end;
        
        exit(false);
    end;
    
    /// <summary>
    /// Creates reservation entry for sales line
    /// </summary>
    local procedure CreateReservationEntry(SalesLine: Record "Sales Line"): Boolean
    var
        ReservEntry: Record "Reservation Entry";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        ItemLedgEntry: Record "Item Ledger Entry";
        ReservationMgt: Codeunit "Reservation Management";
        QtyToReserve: Decimal;
        EntryNo: Integer;
    begin
        // Find available item ledger entries
        ItemLedgEntry.SetCurrentKey("Item No.", "Variant Code", "Location Code", "Posting Date");
        ItemLedgEntry.SetRange("Item No.", SalesLine."No.");
        ItemLedgEntry.SetRange("Location Code", SalesLine."Location Code");
        ItemLedgEntry.SetRange(Open, true);
        ItemLedgEntry.SetFilter("Remaining Quantity", '>0');
        
        if ItemLedgEntry.FindSet() then begin
            QtyToReserve := SalesLine.Quantity;
            
            repeat
                if QtyToReserve > 0 then begin
                    // Reserve from this ledger entry
                    EntryNo := CreateReservationFromLedgerEntry(SalesLine, ItemLedgEntry, QtyToReserve);
                    if EntryNo <> 0 then
                        QtyToReserve -= MinValue(QtyToReserve, ItemLedgEntry."Remaining Quantity");
                end;
            until (ItemLedgEntry.Next() = 0) or (QtyToReserve <= 0);
            
            // Log reservation success
            LogSuccessfulReservation(SalesLine."Document No.", SalesLine."No.", SalesLine.Quantity - QtyToReserve);
            
            exit(QtyToReserve = 0); // True if fully reserved
        end;
        
        exit(false);
    end;
    
    /// <summary>
    /// Gets available inventory for item and location
    /// </summary>
    local procedure GetAvailableInventory(ItemNo: Code[20]; LocationCode: Code[10]): Decimal
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        ItemLedgEntry.SetCurrentKey("Item No.", "Variant Code", "Location Code");
        ItemLedgEntry.SetRange("Item No.", ItemNo);
        ItemLedgEntry.SetRange("Location Code", LocationCode);
        ItemLedgEntry.CalcSums("Remaining Quantity");
        exit(ItemLedgEntry."Remaining Quantity");
    end;
    
    /// <summary>
    /// Cancels all reservations for an order
    /// </summary>
    procedure CancelOrderReservations(OrderNo: Code[20])
    var
        ReservEntry: Record "Reservation Entry";
        ReservMgt: Codeunit "Reservation Management";
        CancelledCount: Integer;
    begin
        // Find all reservations for this order
        ReservEntry.SetRange("Source Type", Database::"Sales Line");
        ReservEntry.SetRange("Source Subtype", 1); // Sales Order
        ReservEntry.SetRange("Source ID", OrderNo);
        
        if ReservEntry.FindSet() then begin
            repeat
                ReservEntry.Delete(true);
                CancelledCount += 1;
            until ReservEntry.Next() = 0;
        end;
        
        // Log cancellation
        LogReservationCancellation(OrderNo, CancelledCount);
    end;
    
    /// <summary>
    /// Logs reservation failure for tracking
    /// </summary>
    local procedure LogReservationFailure(OrderNo: Code[20]; ItemNo: Code[20]; Reason: Text)
    var
        ActivityLog: Record "Activity Log";
    begin
        ActivityLog.LogActivity(
            Database::"Sales Line",
            ActivityLog.Status::Failed,
            'Inventory Reservation',
            'Reservation Failed',
            StrSubstNo('Order %1, Item %2: %3', OrderNo, ItemNo, Reason));
    end;
    
    /// <summary>
    /// Logs successful reservation
    /// </summary>
    local procedure LogSuccessfulReservation(OrderNo: Code[20]; ItemNo: Code[20]; ReservedQty: Decimal)
    var
        ActivityLog: Record "Activity Log";
    begin
        ActivityLog.LogActivity(
            Database::"Sales Line",
            ActivityLog.Status::Success,
            'Inventory Reservation',
            'Reservation Created',
            StrSubstNo('Order %1, Item %2: Reserved %3 units', OrderNo, ItemNo, ReservedQty));
    end;
}
```

## Advanced Integration Codeunit Examples

### External API Integration with Retry Logic

```al
// Advanced integration codeunit with comprehensive error handling
codeunit 50200 "Product Catalog API Manager"
{
    Access = Public;
    
    var
        APIBaseUrl: Label 'https://api.productcatalog.com/v1/';
        MaxRetryAttempts: Integer;
        RetryDelayMs: Integer;
        
    trigger OnRun()
    begin
        MaxRetryAttempts := 3;
        RetryDelayMs := 2000;
    end;
    
    /// <summary>
    /// Synchronizes product catalog from external API with retry and error handling
    /// </summary>
    /// <param name="CategoryCode">Product category to sync</param>
    /// <returns>Number of products synchronized</returns>
    procedure SyncProductCatalog(CategoryCode: Code[20]): Integer
    var
        IntegrationLogEntry: Record "Integration Log Entry";
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        JsonResponse: JsonObject;
        ProductsArray: JsonArray;
        RetryCount: Integer;
        ProductsSynced: Integer;
        ErrorMessage: Text;
    begin
        // Initialize integration logging
        CreateIntegrationLog(IntegrationLogEntry, 'PRODUCT_SYNC', CategoryCode);
        
        // Validate input parameters
        if CategoryCode = '' then begin
            UpdateIntegrationLog(IntegrationLogEntry, 'Failed', 'Category code cannot be empty');
            Error('Category code cannot be empty.');
        end;
        
        // Retry logic with exponential backoff
        for RetryCount := 1 to MaxRetryAttempts do begin
            ClearLastError();
            
            if AttemptProductSync(CategoryCode, HttpClient, HttpResponseMessage, JsonResponse) then begin
                // Process successful response
                if ExtractProductsArray(JsonResponse, ProductsArray) then begin
                    ProductsSynced := ProcessProductsFromAPI(ProductsArray, CategoryCode);
                    
                    UpdateIntegrationLog(IntegrationLogEntry, 'Completed', 
                        StrSubstNo('%1 products synchronized', ProductsSynced));
                    LogSyncSuccess(CategoryCode, ProductsSynced, RetryCount);
                    
                    exit(ProductsSynced);
                end else begin
                    ErrorMessage := 'Failed to extract products from API response';
                    LogSyncAttempt(CategoryCode, RetryCount, false, ErrorMessage);
                end;
            end else begin
                ErrorMessage := GetLastErrorText();
                if ErrorMessage = '' then
                    ErrorMessage := StrSubstNo('HTTP request failed with status: %1', HttpResponseMessage.HttpStatusCode());
                LogSyncAttempt(CategoryCode, RetryCount, false, ErrorMessage);
            end;
            
            // Exponential backoff before retry
            if RetryCount < MaxRetryAttempts then
                Sleep(RetryDelayMs * RetryCount);
        end;
        
        // All retries failed
        UpdateIntegrationLog(IntegrationLogEntry, 'Failed', ErrorMessage);
        HandleSyncFailure(CategoryCode, ErrorMessage);
        
        exit(0);
    end;
    
    /// <summary>
    /// Attempts to sync products from external API
    /// </summary>
    [TryFunction]
    local procedure AttemptProductSync(CategoryCode: Code[20]; var HttpClient: HttpClient; var HttpResponseMessage: HttpResponseMessage; var JsonResponse: JsonObject): Boolean
    var
        RequestUri: Text;
        ResponseContent: Text;
        AuthToken: Text;
    begin
        // Configure HTTP client
        SetupHttpClient(HttpClient);
        
        // Get authentication token
        AuthToken := GetAuthenticationToken();
        if AuthToken = '' then
            Error('Failed to obtain authentication token');
            
        // Build request URI with category filter
        RequestUri := StrSubstNo('products?category=%1&limit=1000', CategoryCode);
        
        // Add authentication header
        HttpClient.DefaultRequestHeaders().Add('Authorization', StrSubstNo('Bearer %1', AuthToken));
        HttpClient.DefaultRequestHeaders().Add('Accept', 'application/json');
        HttpClient.DefaultRequestHeaders().Add('User-Agent', 'BusinessCentral-ProductSync/2.0');
        
        // Make API request with timeout
        HttpClient.Timeout(60000); // 60 second timeout
        if not HttpClient.Get(APIBaseUrl + RequestUri, HttpResponseMessage) then
            exit(false);
            
        // Check response status
        if not HttpResponseMessage.IsSuccessStatusCode() then begin
            HttpResponseMessage.Content().ReadAs(ResponseContent);
            Error('API request failed with status %1: %2', HttpResponseMessage.HttpStatusCode(), ResponseContent);
        end;
        
        // Parse JSON response
        HttpResponseMessage.Content().ReadAs(ResponseContent);
        if not JsonResponse.ReadFrom(ResponseContent) then
            Error('Invalid JSON response format');
            
        exit(true);
    end;
    
    /// <summary>
    /// Processes products from API response with validation
    /// </summary>
    local procedure ProcessProductsFromAPI(ProductsArray: JsonArray; CategoryCode: Code[20]): Integer
    var
        JsonToken: JsonToken;
        ProductObject: JsonObject;
        Item: Record Item;
        ProcessedCount: Integer;
        ErrorCount: Integer;
        ProductData: Record "Temp Product Import Data" temporary;
    begin
        // Process each product in the response
        foreach JsonToken in ProductsArray do begin
            ProductObject := JsonToken.AsObject();
            
            // Extract and validate product data
            if ExtractProductData(ProductObject, ProductData) then begin
                // Validate business rules
                if ValidateProductForImport(ProductData, CategoryCode) then begin
                    // Create or update item record
                    if CreateOrUpdateItem(ProductData) then
                        ProcessedCount += 1
                    else begin
                        ErrorCount += 1;
                        LogProductProcessingError(ProductData."External ID", 'Failed to create/update item');
                    end;
                end else begin
                    ErrorCount += 1;
                    LogProductProcessingError(ProductData."External ID", 'Product validation failed');
                end;
            end else begin
                ErrorCount += 1;
                LogProductProcessingError('Unknown', 'Failed to extract product data');
            end;
        end;
        
        // Log processing summary
        LogProductProcessingSummary(CategoryCode, ProductsArray.Count(), ProcessedCount, ErrorCount);
        
        exit(ProcessedCount);
    end;
    
    /// <summary>
    /// Validates product data against business rules
    /// </summary>
    local procedure ValidateProductForImport(var ProductData: Record "Temp Product Import Data" temporary; CategoryCode: Code[20]): Boolean
    var
        Item: Record Item;
        InventorySetup: Record "Inventory Setup";
    begin
        // Basic data validation
        if ProductData."External ID" = '' then
            exit(false);
            
        if ProductData.Description = '' then
            exit(false);
            
        if ProductData."Unit Price" < 0 then
            exit(false);
            
        // Business rule validations
        InventorySetup.Get();
        
        // Check if item already exists with different category
        if Item.Get(ProductData."Item No.") then begin
            if Item."Item Category Code" <> CategoryCode then begin
                LogProductProcessingWarning(ProductData."External ID", 
                    StrSubstNo('Item exists with different category: %1 vs %2', Item."Item Category Code", CategoryCode));
                // Allow update but flag for review
            end;
        end;
        
        // Check price reasonableness
        if ProductData."Unit Price" > InventorySetup."Maximum Item Price" then begin
            LogProductProcessingWarning(ProductData."External ID", 
                StrSubstNo('Price %1 exceeds maximum allowed price %2', ProductData."Unit Price", InventorySetup."Maximum Item Price"));
            // Don't fail validation but log warning
        end;
        
        // Check for required fields based on category
        if RequiresBrandForCategory(CategoryCode) and (ProductData.Brand = '') then begin
            LogProductProcessingError(ProductData."External ID", 'Brand is required for this category');
            exit(false);
        end;
        
        exit(true);
    end;
    
    /// <summary>
    /// Creates or updates item record with product data
    /// </summary>
    local procedure CreateOrUpdateItem(var ProductData: Record "Temp Product Import Data" temporary): Boolean
    var
        Item: Record Item;
        ItemExists: Boolean;
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        ItemExists := Item.Get(ProductData."Item No.");
        
        if not ItemExists then begin
            Item.Init();
            if ProductData."Item No." = '' then
                Item."No." := NoSeriesMgt.GetNextNo(GetItemNoSeries(), Today(), true)
            else
                Item."No." := ProductData."Item No.";
        end;
        
        // Update item fields with API data
        Item.Description := ProductData.Description;
        Item."Description 2" := ProductData."Description 2";
        Item."Unit Price" := ProductData."Unit Price";
        Item."Item Category Code" := ProductData."Category Code";
        Item."External Item ID" := ProductData."External ID";
        Item."Last Date Modified" := Today();
        
        // Set default values for new items
        if not ItemExists then begin
            Item.Type := Item.Type::Inventory;
            Item."Base Unit of Measure" := GetDefaultUOM();
            Item."Costing Method" := Item."Costing Method"::FIFO;
            Item."Replenishment System" := Item."Replenishment System"::Purchase;
        end;
        
        // Save item record
        if ItemExists then
            Item.Modify(true)
        else
            Item.Insert(true);
            
        // Create item cross-reference for external ID
        CreateItemCrossReference(Item."No.", ProductData."External ID");
        
        exit(true);
    end;
    
    /// <summary>
    /// Handles sync failure with appropriate notifications and logging
    /// </summary>
    local procedure HandleSyncFailure(CategoryCode: Code[20]; ErrorMessage: Text)
    var
        NotificationMgt: Codeunit "Notification Management";
        ActivityLog: Record "Activity Log";
    begin
        // Send notification to system administrator
        NotificationMgt.SendNotification(
            StrSubstNo('Product catalog sync failed for category %1: %2', CategoryCode, ErrorMessage),
            "Notification Entry Type"::Error);
            
        // Create high-priority activity log entry
        ActivityLog.LogActivity(
            Database::Item,
            ActivityLog.Status::Failed,
            'Product Catalog Sync',
            'Sync Failure',
            StrSubstNo('Failed to sync products for category %1 after %2 attempts. Error: %3',
                CategoryCode, MaxRetryAttempts, ErrorMessage));
                
        // Create follow-up task in work management system
        CreateSyncFailureTask(CategoryCode, ErrorMessage);
        
        // Send alert to monitoring system if configured
        SendMonitoringAlert('PRODUCT_SYNC_FAILURE', 
            StrSubstNo('Category: %1, Error: %2', CategoryCode, ErrorMessage));
    end;
    
    /// <summary>
    /// Sets up HTTP client with standard configuration
    /// </summary>
    local procedure SetupHttpClient(var HttpClient: HttpClient)
    begin
        HttpClient.Clear();
        HttpClient.SetBaseAddress(APIBaseUrl);
        HttpClient.DefaultRequestHeaders().Add('Accept', 'application/json');
        HttpClient.DefaultRequestHeaders().Add('User-Agent', 'BusinessCentral-Integration/1.0');
        HttpClient.Timeout(30000); // 30 second timeout
    end;
    
    /// <summary>
    /// Gets authentication token for API access
    /// </summary>
    local procedure GetAuthenticationToken(): Text
    var
        OAuth2: Codeunit OAuth2;
        Token: Text;
        ClientId: Text;
        ClientSecret: Text;
        TokenEndpoint: Text;
    begin
        // Get OAuth configuration from setup
        GetOAuthConfiguration(ClientId, ClientSecret, TokenEndpoint);
        
        // Request access token
        if OAuth2.RequestClientCredentialsAdminConsent(ClientId, ClientSecret, TokenEndpoint, '', Token) then
            exit(Token)
        else
            exit('');
    end;
}
```

## Expert-Level Event-Driven Codeunit

### Comprehensive Event Orchestration System

```al
// Expert-level event orchestration with monitoring and architectural documentation
codeunit 50300 "Business Process Orchestrator"
{
    Access = Public;
    
    var
        EventProcessingEnabled: Boolean;
        MaxEventProcessingTime: Integer;
        
    trigger OnRun()
    begin
        EventProcessingEnabled := true;
        MaxEventProcessingTime := 300000; // 5 minutes
    end;
    
    /// <summary>
    /// Orchestrates complex business process with event sequencing and monitoring
    /// Architecture: Event-driven pattern with saga pattern for long-running processes
    /// Documentation: Azure DevOps Wiki - Architecture/Event-Driven-Patterns.md
    /// </summary>
    /// <param name="ProcessId">Unique identifier for the business process</param>
    /// <param name="ProcessType">Type of business process to orchestrate</param>
    /// <param name="InitiatingEvent">Event that triggered this process</param>
    procedure OrchestratBusinessProcess(ProcessId: Guid; ProcessType: Enum "Business Process Type"; InitiatingEvent: Text[100])
    var
        ProcessContext: Record "Business Process Context";
        PerformanceMonitor: Codeunit "Performance Monitor";
        EventSequencer: Codeunit "Event Sequence Manager";
        MonitoringSession: Guid;
        ProcessingStartTime: DateTime;
    begin
        if not EventProcessingEnabled then
            exit;
            
        ProcessingStartTime := CurrentDateTime();
        MonitoringSession := PerformanceMonitor.StartSession(StrSubstNo('Business Process %1', ProcessType));
        
        try
            // Create process context for tracking and recovery
            CreateProcessContext(ProcessContext, ProcessId, ProcessType, InitiatingEvent);
            
            // Begin process orchestration with timeout protection
            case ProcessType of
                ProcessType::"Order Fulfillment":
                    OrchestrateOrderFulfillment(ProcessContext);
                ProcessType::"Customer Onboarding":
                    OrchestrateCustomerOnboarding(ProcessContext);
                ProcessType::"Inventory Replenishment":
                    OrchestrateInventoryReplenishment(ProcessContext);
                ProcessType::"Financial Period Close":
                    OrchestrateFinancialPeriodClose(ProcessContext);
                else
                    Error('Unsupported process type: %1', ProcessType);
            end;
            
            // Complete process tracking
            CompleteProcessExecution(ProcessContext, true, '');
            
            // Document successful process execution
            DocumentProcessExecution(ProcessId, ProcessType, CurrentDateTime() - ProcessingStartTime);
            
        except
            // Handle process failure with recovery options
            CompleteProcessExecution(ProcessContext, false, GetLastErrorText());
            
            // Initiate process recovery if applicable
            InitiateProcessRecovery(ProcessContext, GetLastErrorText());
            
            // Re-raise exception for caller handling
            Error(GetLastErrorText());
        end;
        
        PerformanceMonitor.EndSession(MonitoringSession);
    end;
    
    /// <summary>
    /// Orchestrates order fulfillment process with multiple stages and compensations
    /// </summary>
    local procedure OrchestrateOrderFulfillment(var ProcessContext: Record "Business Process Context")
    var
        OrderNo: Code[20];
        FulfillmentStage: Enum "Order Fulfillment Stage";
        CompensationActions: List of [Text];
    begin
        OrderNo := ProcessContext."Reference Document No.";
        
        // Stage 1: Validate Order
        FulfillmentStage := FulfillmentStage::"Order Validation";
        UpdateProcessStage(ProcessContext, Format(FulfillmentStage));
        
        if not ValidateOrderForFulfillment(OrderNo) then begin
            LogProcessStageFailure(ProcessContext, FulfillmentStage, 'Order validation failed');
            Error('Order %1 failed validation for fulfillment', OrderNo);
        end;
        
        PublishOrderValidatedEvent(OrderNo);
        CompensationActions.Add('CANCEL_VALIDATION');
        
        // Stage 2: Reserve Inventory
        FulfillmentStage := FulfillmentStage::"Inventory Reservation";
        UpdateProcessStage(ProcessContext, Format(FulfillmentStage));
        
        if not ReserveInventoryForOrder(OrderNo) then begin
            ExecuteCompensationActions(CompensationActions);
            LogProcessStageFailure(ProcessContext, FulfillmentStage, 'Inventory reservation failed');
            Error('Failed to reserve inventory for order %1', OrderNo);
        end;
        
        PublishInventoryReservedEvent(OrderNo);
        CompensationActions.Add('CANCEL_RESERVATION');
        
        // Stage 3: Process Payment
        FulfillmentStage := FulfillmentStage::"Payment Processing";
        UpdateProcessStage(ProcessContext, Format(FulfillmentStage));
        
        if not ProcessOrderPayment(OrderNo) then begin
            ExecuteCompensationActions(CompensationActions);
            LogProcessStageFailure(ProcessContext, FulfillmentStage, 'Payment processing failed');
            Error('Payment processing failed for order %1', OrderNo);
        end;
        
        PublishPaymentProcessedEvent(OrderNo);
        CompensationActions.Add('REFUND_PAYMENT');
        
        // Stage 4: Ship Order
        FulfillmentStage := FulfillmentStage::"Order Shipment";
        UpdateProcessStage(ProcessContext, Format(FulfillmentStage));
        
        if not ShipOrder(OrderNo) then begin
            ExecuteCompensationActions(CompensationActions);
            LogProcessStageFailure(ProcessContext, FulfillmentStage, 'Order shipment failed');
            Error('Order shipment failed for order %1', OrderNo);
        end;
        
        PublishOrderShippedEvent(OrderNo);
        
        // Final Stage: Complete Order
        FulfillmentStage := FulfillmentStage::"Order Completion";
        UpdateProcessStage(ProcessContext, Format(FulfillmentStage));
        
        CompleteOrderFulfillment(OrderNo);
        PublishOrderCompletedEvent(OrderNo);
        
        LogProcessStageSuccess(ProcessContext, FulfillmentStage, 'Order fulfillment completed successfully');
    end;
    
    /// <summary>
    /// Publishes integration events for process stages
    /// Architecture: Event-driven pattern enables loose coupling and extensibility
    /// </summary>
    /// <param name="OrderNo">Order number</param>
    [IntegrationEvent(false, false)]
    procedure OnOrderValidated(OrderNo: Code[20])
    begin
        // Published when order validation completes successfully
        // Subscribers can implement custom validation extensions
    end;
    
    /// <summary>
    /// Published when inventory reservation completes
    /// </summary>
    /// <param name="OrderNo">Order number</param>
    [IntegrationEvent(false, false)]
    procedure OnInventoryReserved(OrderNo: Code[20])
    begin
        // Enables inventory-related process extensions
    end;
    
    /// <summary>
    /// Published when payment processing completes
    /// </summary>
    /// <param name="OrderNo">Order number</param>
    [IntegrationEvent(false, false)]
    procedure OnPaymentProcessed(OrderNo: Code[20])
    begin
        // Enables payment-related process extensions and notifications
    end;
    
    /// <summary>
    /// Published when order shipment completes
    /// </summary>
    /// <param name="OrderNo">Order number</param>
    [IntegrationEvent(false, false)]
    procedure OnOrderShipped(OrderNo: Code[20])
    begin
        // Enables shipping-related notifications and tracking updates
    end;
    
    /// <summary>
    /// Published when entire order fulfillment process completes
    /// </summary>
    /// <param name="OrderNo">Order number</param>
    [IntegrationEvent(false, false)]
    procedure OnOrderFulfillmentCompleted(OrderNo: Code[20])
    begin
        // Enables completion-related processes like customer notifications,
        // loyalty point awards, and analytics updates
    end;
    
    /// <summary>
    /// Initiates process recovery for failed business processes
    /// Expert Pattern: Saga pattern with compensation for long-running processes
    /// </summary>
    /// <param name="ProcessContext">Failed process context</param>
    /// <param name="FailureReason">Reason for process failure</param>
    local procedure InitiateProcessRecovery(var ProcessContext: Record "Business Process Context"; FailureReason: Text)
    var
        ProcessRecovery: Record "Process Recovery";
        RecoveryStrategy: Enum "Process Recovery Strategy";
    begin
        // Determine recovery strategy based on failure type and process stage
        RecoveryStrategy := DetermineRecoveryStrategy(ProcessContext, FailureReason);
        
        // Create recovery record for tracking and manual intervention
        CreateProcessRecoveryRecord(ProcessRecovery, ProcessContext, RecoveryStrategy, FailureReason);
        
        case RecoveryStrategy of
            RecoveryStrategy::"Automatic Retry":
                ScheduleProcessRetry(ProcessContext);
            RecoveryStrategy::"Manual Intervention":
                NotifyProcessAdministrators(ProcessContext, FailureReason);
            RecoveryStrategy::"Compensate and Abort":
                ExecuteProcessCompensation(ProcessContext);
            RecoveryStrategy::"Escalate to Supervisor":
                EscalateProcessFailure(ProcessContext, FailureReason);
        end;
        
        // Log recovery initiation for audit trail
        LogProcessRecoveryInitiation(ProcessContext, RecoveryStrategy, FailureReason);
    end;
    
    /// <summary>
    /// Provides architectural guidance and mentoring for team development
    /// Expert Responsibility: Knowledge transfer and architectural decision documentation
    /// </summary>
    /// <param name="ArchitecturalTopic">Topic requiring guidance</param>
    /// <param name="TeamMemberUserId">Team member requesting guidance</param>
    /// <param name="ComplexityLevel">Complexity level of the guidance needed</param>
    procedure ProvideArchitecturalGuidance(ArchitecturalTopic: Text[100]; TeamMemberUserId: Code[50]; ComplexityLevel: Option Basic,Intermediate,Advanced,Expert)
    var
        GuidanceSession: Record "Architectural Guidance Session";
        MentoringPlan: Record "Team Mentoring Plan";
        GuidanceContent: Text;
        LearningResources: List of [Text];
    begin
        // Create guidance session record for tracking
        CreateGuidanceSession(GuidanceSession, ArchitecturalTopic, TeamMemberUserId, ComplexityLevel);
        
        // Generate appropriate guidance based on complexity level
        GuidanceContent := GenerateArchitecturalGuidance(ArchitecturalTopic, ComplexityLevel);
        
        // Provide learning resources based on topic and level
        PopulateLearningResources(LearningResources, ArchitecturalTopic, ComplexityLevel);
        
        // Document guidance for knowledge base
        DocumentArchitecturalGuidance(GuidanceSession, GuidanceContent, LearningResources);
        
        // Schedule follow-up mentoring session if needed
        if ComplexityLevel >= ComplexityLevel::Advanced then
            ScheduleFollowUpMentoring(TeamMemberUserId, ArchitecturalTopic);
            
        // Update team member's learning progress
        UpdateLearningProgress(TeamMemberUserId, ArchitecturalTopic, ComplexityLevel);
        
        // Send guidance notification with resources
        SendArchitecturalGuidanceNotification(TeamMemberUserId, GuidanceContent, LearningResources);
    end;
    
    /// <summary>
    /// Creates comprehensive process context for tracking and recovery
    /// </summary>
    local procedure CreateProcessContext(var ProcessContext: Record "Business Process Context"; ProcessId: Guid; ProcessType: Enum "Business Process Type"; InitiatingEvent: Text[100])
    begin
        ProcessContext.Init();
        ProcessContext."Process ID" := ProcessId;
        ProcessContext."Process Type" := ProcessType;
        ProcessContext."Initiating Event" := InitiatingEvent;
        ProcessContext."Start DateTime" := CurrentDateTime();
        ProcessContext.Status := ProcessContext.Status::Processing;
        ProcessContext."User ID" := UserId();
        ProcessContext."Session ID" := SessionId();
        ProcessContext."Company Name" := CompanyName();
        ProcessContext.Insert(true);
    end;
    
    /// <summary>
    /// Updates process execution stage for monitoring
    /// </summary>
    local procedure UpdateProcessStage(var ProcessContext: Record "Business Process Context"; StageName: Text[50])
    begin
        ProcessContext."Current Stage" := StageName;
        ProcessContext."Stage Start Time" := CurrentDateTime();
        ProcessContext.Modify(true);
    end;
    
    /// <summary>
    /// Completes process execution with success/failure status
    /// </summary>
    local procedure CompleteProcessExecution(var ProcessContext: Record "Business Process Context"; Success: Boolean; ErrorMessage: Text)
    begin
        ProcessContext."End DateTime" := CurrentDateTime();
        if Success then
            ProcessContext.Status := ProcessContext.Status::Completed
        else begin
            ProcessContext.Status := ProcessContext.Status::Failed;
            ProcessContext."Error Message" := CopyStr(ErrorMessage, 1, MaxStrLen(ProcessContext."Error Message"));
        end;
        ProcessContext.Modify(true);
    end;
}
```
