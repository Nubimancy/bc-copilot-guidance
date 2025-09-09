---
title: "Progressive Error Disclosure - Code Samples"
description: "Complete code examples for implementing layered error messaging with user-friendly and technical details"
area: "error-handling"
difficulty: "intermediate"
object_types: ["Codeunit"]
variable_types: ["ErrorInfo"]
tags: ["error-handling", "user-experience", "samples", "verbosity", "role-based"]
---

# Progressive Error Disclosure - Code Samples

## Complete Implementation Examples

### Payment Processing with Progressive Disclosure

```al
codeunit 50200 "Payment Processor with Disclosure"
{
    procedure ProcessPaymentWithProgressiveError(PaymentData: Record "Payment Information"; UserContext: Record "User Setup")
    var
        PaymentError: ErrorInfo;
        ProcessingResult: Boolean;
    begin
        ClearLastError();
        ProcessingResult := TryProcessPayment(PaymentData);
        
        if not ProcessingResult then begin
            BuildProgressivePaymentError(PaymentError, PaymentData, UserContext, GetLastErrorText());
            Error(PaymentError);
        end;
    end;
    
    local procedure BuildProgressivePaymentError(var PaymentError: ErrorInfo; PaymentData: Record "Payment Information"; 
                                               UserContext: Record "User Setup"; TechnicalError: Text)
    begin
        // User-friendly primary message
        PaymentError.Message := 'Payment processing failed. Please try again or contact support.';
        
        // Build role-appropriate detailed message
        case UserContext."Role Center ID" of
            9022: // Business Manager
                PaymentError.DetailedMessage := BuildBusinessManagerPaymentContext(PaymentData, TechnicalError);
            9001: // Accountant  
                PaymentError.DetailedMessage := BuildAccountantPaymentContext(PaymentData, TechnicalError);
            9015: // IT Manager
                PaymentError.DetailedMessage := BuildTechnicalPaymentContext(PaymentData, TechnicalError);
            else
                PaymentError.DetailedMessage := BuildGeneralPaymentContext(PaymentData, TechnicalError);
        end;
        
        // Set verbosity based on role
        ConfigurePaymentErrorVerbosity(PaymentError, UserContext."Role Center ID");
        
        // Add role-specific actions
        AddPaymentRecoveryActions(PaymentError, UserContext."Role Center ID", PaymentData);
    end;
    
    local procedure BuildBusinessManagerPaymentContext(PaymentData: Record "Payment Information"; TechnicalError: Text): Text
    var
        ContextBuilder: TextBuilder;
    begin
        ContextBuilder.AppendLine('PAYMENT DETAILS:');
        ContextBuilder.AppendLine(StrSubstNo('• Amount: %1 %2', PaymentData.Amount, PaymentData."Currency Code"));
        ContextBuilder.AppendLine(StrSubstNo('• Customer: %1', PaymentData."Customer Name"));
        ContextBuilder.AppendLine(StrSubstNo('• Payment Method: %1', PaymentData."Payment Method"));
        ContextBuilder.AppendLine('');
        ContextBuilder.AppendLine('BUSINESS IMPACT:');
        ContextBuilder.AppendLine('• Customer payment is delayed');
        ContextBuilder.AppendLine('• Account reconciliation may be affected');
        ContextBuilder.AppendLine('• Consider alternative payment methods');
        ContextBuilder.AppendLine('');
        ContextBuilder.AppendLine('NEXT STEPS:');
        ContextBuilder.AppendLine('• Retry with different payment method');
        ContextBuilder.AppendLine('• Contact customer for alternative arrangement');
        ContextBuilder.AppendLine('• Escalate to IT if problem persists');
        
        exit(ContextBuilder.ToText());
    end;
    
    local procedure BuildAccountantPaymentContext(PaymentData: Record "Payment Information"; TechnicalError: Text): Text
    var
        ContextBuilder: TextBuilder;
    begin
        ContextBuilder.AppendLine('FINANCIAL DETAILS:');
        ContextBuilder.AppendLine(StrSubstNo('• Payment Amount: %1 %2', PaymentData.Amount, PaymentData."Currency Code"));
        ContextBuilder.AppendLine(StrSubstNo('• G/L Account: %1', PaymentData."G/L Account No."));
        ContextBuilder.AppendLine(StrSubstNo('• Dimension Set: %1', PaymentData."Dimension Set ID"));
        ContextBuilder.AppendLine(StrSubstNo('• Bank Account: %1', PaymentData."Bank Account No."));
        ContextBuilder.AppendLine('');
        ContextBuilder.AppendLine('ACCOUNTING IMPACT:');
        ContextBuilder.AppendLine('• Payment journal entry not created');
        ContextBuilder.AppendLine('• Bank reconciliation pending');
        ContextBuilder.AppendLine('• Customer ledger entry not updated');
        ContextBuilder.AppendLine('');
        ContextBuilder.AppendLine('GATEWAY RESPONSE:');
        if TechnicalError <> '' then
            ContextBuilder.AppendLine(StrSubstNo('• Error: %1', TechnicalError))
        else
            ContextBuilder.AppendLine('• No specific error returned from gateway');
        
        exit(ContextBuilder.ToText());
    end;
    
    local procedure BuildTechnicalPaymentContext(PaymentData: Record "Payment Information"; TechnicalError: Text): Text
    var
        ContextBuilder: TextBuilder;
    begin
        ContextBuilder.AppendLine('TECHNICAL DIAGNOSTICS:');
        ContextBuilder.AppendLine(StrSubstNo('• Timestamp: %1', CurrentDateTime));
        ContextBuilder.AppendLine(StrSubstNo('• User ID: %1', UserId));
        ContextBuilder.AppendLine(StrSubstNo('• Company: %1', CompanyName));
        ContextBuilder.AppendLine(StrSubstNo('• Session ID: %1', SessionId));
        ContextBuilder.AppendLine('');
        ContextBuilder.AppendLine('PAYMENT GATEWAY DATA:');
        ContextBuilder.AppendLine(StrSubstNo('• Gateway URL: %1', GetPaymentGatewayUrl()));
        ContextBuilder.AppendLine(StrSubstNo('• Transaction ID: %1', PaymentData."Transaction ID"));
        ContextBuilder.AppendLine(StrSubstNo('• Request Method: %1', PaymentData."HTTP Method"));
        ContextBuilder.AppendLine(StrSubstNo('• Timeout Setting: %1 seconds', GetGatewayTimeout()));
        ContextBuilder.AppendLine('');
        ContextBuilder.AppendLine('ERROR DETAILS:');
        ContextBuilder.AppendLine(StrSubstNo('• Raw Error: %1', TechnicalError));
        ContextBuilder.AppendLine(StrSubstNo('• Error Code: %1', ExtractErrorCode(TechnicalError)));
        ContextBuilder.AppendLine(StrSubstNo('• HTTP Status: %1', ExtractHttpStatus(TechnicalError)));
        ContextBuilder.AppendLine('');
        ContextBuilder.AppendLine('SYSTEM STATE:');
        ContextBuilder.AppendLine(StrSubstNo('• Available Memory: %1 MB', GetAvailableMemory()));
        ContextBuilder.AppendLine(StrSubstNo('• Network Status: %1', CheckNetworkConnectivity()));
        
        exit(ContextBuilder.ToText());
    end;
    
    local procedure ConfigurePaymentErrorVerbosity(var PaymentError: ErrorInfo; RoleCenterID: Integer)
    begin
        case RoleCenterID of
            9015: // IT Manager
                begin
                    PaymentError.Verbosity := Verbosity::Verbose;
                    PaymentError.DataClassification := DataClassification::SystemMetadata;
                end;
            9001: // Accountant
                begin
                    PaymentError.Verbosity := Verbosity::Normal;
                    PaymentError.DataClassification := DataClassification::CustomerContent;
                end;
            else begin
                PaymentError.Verbosity := Verbosity::Brief;
                PaymentError.DataClassification := DataClassification::CustomerContent;
            end;
        end;
    end;
    
    local procedure AddPaymentRecoveryActions(var PaymentError: ErrorInfo; RoleCenterID: Integer; PaymentData: Record "Payment Information")
    begin
        case RoleCenterID of
            9022: // Business Manager
                begin
                    PaymentError.AddAction('Retry with Different Method', Codeunit::"Payment Recovery", 'SelectAlternativeMethod');
                    PaymentError.AddAction('Contact Customer', Codeunit::"Customer Communication", 'NotifyPaymentIssue');
                    PaymentError.AddAction('View Payment History', Codeunit::"Payment History", 'ShowCustomerHistory');
                end;
            9001: // Accountant
                begin
                    PaymentError.AddAction('Create Manual Payment', Codeunit::"Manual Payment Processing", 'CreateManualEntry');
                    PaymentError.AddAction('Check Bank Account', Codeunit::"Bank Account Management", 'ValidateBankAccount');
                    PaymentError.AddAction('Review G/L Posting', Codeunit::"G/L Posting Review", 'ShowPostingPreview');
                    PaymentError.AddAction('Export for Investigation', Codeunit::"Payment Export", 'ExportPaymentData');
                end;
            9015: // IT Manager
                begin
                    PaymentError.AddAction('Test Gateway Connection', Codeunit::"Gateway Diagnostics", 'TestConnection');
                    PaymentError.AddAction('View System Logs', Codeunit::"System Diagnostics", 'ShowPaymentLogs');
                    PaymentError.AddAction('Reset Gateway Session', Codeunit::"Gateway Management", 'ResetSession');
                    PaymentError.AddAction('Generate Support Package', Codeunit::"Support Tools", 'GenerateSupportData');
                end;
            else begin
                PaymentError.AddAction('Contact Support', Codeunit::"Support Contact", 'OpenSupportRequest');
                PaymentError.AddAction('Try Again Later', Codeunit::"Payment Recovery", 'ScheduleRetry');
            end;
        end;
    end;
}
```

### Inventory Management with Context-Sensitive Errors

```al
codeunit 50201 "Inventory Error Handler"
{
    procedure ValidateInventoryWithDisclosure(Item: Record Item; RequiredQty: Decimal; 
                                            Location: Record Location; UserRole: Text[50])
    var
        InventoryError: ErrorInfo;
        AvailableQty: Decimal;
        UserRoleEnum: Enum "User Role Type";
    begin
        AvailableQty := CalculateAvailableInventory(Item."No.", Location.Code);
        
        if AvailableQty < RequiredQty then begin
            // Convert text role to enum
            UserRoleEnum := ConvertToUserRoleEnum(UserRole);
            
            BuildInventoryShortageError(InventoryError, Item, RequiredQty, AvailableQty, Location, UserRoleEnum);
            Error(InventoryError);
        end;
    end;
    
    local procedure BuildInventoryShortageError(var InventoryError: ErrorInfo; Item: Record Item; 
                                              RequiredQty: Decimal; AvailableQty: Decimal; 
                                              Location: Record Location; UserRole: Enum "User Role Type")
    var
        Shortage: Decimal;
    begin
        Shortage := RequiredQty - AvailableQty;
        
        // Universal business-friendly message
        InventoryError.Message := StrSubstNo('Insufficient inventory for %1. Short by %2 %3', 
                                           Item.Description, Shortage, Item."Base Unit of Measure");
        
        // Role-specific detailed context
        case UserRole of
            UserRole::"Sales Person":
                InventoryError.DetailedMessage := BuildSalesPersonInventoryContext(Item, RequiredQty, AvailableQty, Location);
            UserRole::"Inventory Manager":
                InventoryError.DetailedMessage := BuildInventoryManagerContext(Item, RequiredQty, AvailableQty, Location);
            UserRole::"Purchase Agent":
                InventoryError.DetailedMessage := BuildPurchaseAgentContext(Item, RequiredQty, AvailableQty, Location);
            UserRole::"Warehouse Worker":
                InventoryError.DetailedMessage := BuildWarehouseWorkerContext(Item, RequiredQty, AvailableQty, Location);
            UserRole::"Production Planner":
                InventoryError.DetailedMessage := BuildProductionPlannerContext(Item, RequiredQty, AvailableQty, Location);
            else
                InventoryError.DetailedMessage := BuildGenericInventoryContext(Item, RequiredQty, AvailableQty, Location);
        end;
        
        // Configure verbosity and classification
        SetInventoryErrorVerbosity(InventoryError, UserRole);
        
        // Add role-appropriate actions
        AddInventoryRecoveryActions(InventoryError, UserRole, Item, Shortage);
    end;
    
    local procedure BuildSalesPersonInventoryContext(Item: Record Item; Required: Decimal; 
                                                   Available: Decimal; Location: Record Location): Text
    var
        ContextBuilder: TextBuilder;
        ExpectedDate: Date;
    begin
        ContextBuilder.AppendLine('CUSTOMER IMPACT ANALYSIS:');
        ContextBuilder.AppendLine(StrSubstNo('• Item: %1 - %2', Item."No.", Item.Description));
        ContextBuilder.AppendLine(StrSubstNo('• Location: %1', Location.Name));
        ContextBuilder.AppendLine(StrSubstNo('• Available Now: %1 %2', Available, Item."Base Unit of Measure"));
        ContextBuilder.AppendLine(StrSubstNo('• Customer Needs: %1 %2', Required, Item."Base Unit of Measure"));
        ContextBuilder.AppendLine(StrSubstNo('• Shortage: %1 %2', Required - Available, Item."Base Unit of Measure"));
        ContextBuilder.AppendLine('');
        
        // Check alternative locations
        if HasInventoryInOtherLocations(Item."No.", Required - Available) then begin
            ContextBuilder.AppendLine('ALTERNATIVE LOCATIONS:');
            AddAlternativeLocationInfo(ContextBuilder, Item."No.", Required - Available);
            ContextBuilder.AppendLine('');
        end;
        
        // Expected restock information
        ExpectedDate := GetNextExpectedReceipt(Item."No.");
        if ExpectedDate <> 0D then begin
            ContextBuilder.AppendLine('RESTOCK INFORMATION:');
            ContextBuilder.AppendLine(StrSubstNo('• Expected Receipt: %1', ExpectedDate));
            ContextBuilder.AppendLine(StrSubstNo('• Expected Quantity: %1', GetExpectedReceiptQuantity(Item."No.", ExpectedDate)));
            ContextBuilder.AppendLine('');
        end;
        
        ContextBuilder.AppendLine('SALES OPTIONS:');
        ContextBuilder.AppendLine('• Offer partial delivery of available stock');
        ContextBuilder.AppendLine('• Suggest alternative items if available');
        ContextBuilder.AppendLine('• Schedule future delivery when restocked');
        ContextBuilder.AppendLine('• Contact customer about timeline expectations');
        
        exit(ContextBuilder.ToText());
    end;
    
    local procedure BuildInventoryManagerContext(Item: Record Item; Required: Decimal; 
                                               Available: Decimal; Location: Record Location): Text
    var
        ContextBuilder: TextBuilder;
        SafetyStock: Decimal;
        ReorderPoint: Decimal;
    begin
        SafetyStock := Item."Safety Stock Quantity";
        ReorderPoint := Item."Reorder Point";
        
        ContextBuilder.AppendLine('INVENTORY MANAGEMENT ANALYSIS:');
        ContextBuilder.AppendLine(StrSubstNo('• Current Stock: %1 %2', Available, Item."Base Unit of Measure"));
        ContextBuilder.AppendLine(StrSubstNo('• Safety Stock: %1 %2', SafetyStock, Item."Base Unit of Measure"));
        ContextBuilder.AppendLine(StrSubstNo('• Reorder Point: %1 %2', ReorderPoint, Item."Base Unit of Measure"));
        ContextBuilder.AppendLine(StrSubstNo('• Shortage: %1 %2', Required - Available, Item."Base Unit of Measure"));
        
        if Available < SafetyStock then
            ContextBuilder.AppendLine('• ⚠️  BELOW SAFETY STOCK LEVEL');
        if Available < ReorderPoint then
            ContextBuilder.AppendLine('• 🔔 REORDER POINT TRIGGERED');
            
        ContextBuilder.AppendLine('');
        
        // Supply analysis
        ContextBuilder.AppendLine('SUPPLY CHAIN STATUS:');
        AddSupplyChainAnalysis(ContextBuilder, Item."No.");
        ContextBuilder.AppendLine('');
        
        // Demand analysis
        ContextBuilder.AppendLine('DEMAND ANALYSIS:');
        AddDemandAnalysis(ContextBuilder, Item."No.", Location.Code);
        ContextBuilder.AppendLine('');
        
        // Planning suggestions
        ContextBuilder.AppendLine('PLANNING RECOMMENDATIONS:');
        AddPlanningRecommendations(ContextBuilder, Item."No.", Required - Available);
        
        exit(ContextBuilder.ToText());
    end;
    
    local procedure BuildPurchaseAgentContext(Item: Record Item; Required: Decimal; 
                                            Available: Decimal; Location: Record Location): Text
    var
        ContextBuilder: TextBuilder;
    begin
        ContextBuilder.AppendLine('PROCUREMENT ANALYSIS:');
        ContextBuilder.AppendLine(StrSubstNo('• Shortage Quantity: %1 %2', Required - Available, Item."Base Unit of Measure"));
        ContextBuilder.AppendLine(StrSubstNo('• Lead Time: %1', Item."Lead Time Calculation"));
        ContextBuilder.AppendLine(StrSubstNo('• Minimum Order Qty: %1', Item."Minimum Order Quantity"));
        ContextBuilder.AppendLine(StrSubstNo('• Order Multiple: %1', Item."Order Multiple"));
        ContextBuilder.AppendLine('');
        
        // Vendor information
        ContextBuilder.AppendLine('VENDOR INFORMATION:');
        AddVendorAnalysis(ContextBuilder, Item."No.");
        ContextBuilder.AppendLine('');
        
        // Cost analysis
        ContextBuilder.AppendLine('COST ANALYSIS:');
        AddCostAnalysis(ContextBuilder, Item."No.", Required - Available);
        ContextBuilder.AppendLine('');
        
        // Procurement options
        ContextBuilder.AppendLine('PROCUREMENT OPTIONS:');
        ContextBuilder.AppendLine('• Create emergency purchase order');
        ContextBuilder.AppendLine('• Check vendor stock availability');
        ContextBuilder.AppendLine('• Consider expedited delivery options');
        ContextBuilder.AppendLine('• Explore alternative suppliers');
        
        exit(ContextBuilder.ToText());
    end;
    
    local procedure SetInventoryErrorVerbosity(var InventoryError: ErrorInfo; UserRole: Enum "User Role Type")
    begin
        case UserRole of
            UserRole::"System Administrator", UserRole::"IT Manager":
                begin
                    InventoryError.Verbosity := Verbosity::Verbose;
                    InventoryError.DataClassification := DataClassification::SystemMetadata;
                end;
            UserRole::"Inventory Manager", UserRole::"Purchase Agent", UserRole::"Production Planner":
                begin
                    InventoryError.Verbosity := Verbosity::Normal;
                    InventoryError.DataClassification := DataClassification::CustomerContent;
                end;
            else begin
                InventoryError.Verbosity := Verbosity::Brief;
                InventoryError.DataClassification := DataClassification::CustomerContent;
            end;
        end;
    end;
    
    local procedure AddInventoryRecoveryActions(var InventoryError: ErrorInfo; UserRole: Enum "User Role Type"; 
                                              Item: Record Item; ShortageQty: Decimal)
    begin
        case UserRole of
            UserRole::"Sales Person":
                begin
                    InventoryError.AddAction('Check Other Locations', Codeunit::"Location Management", 'ShowAvailableLocations');
                    InventoryError.AddAction('Suggest Alternatives', Codeunit::"Item Alternatives", 'FindAlternatives');
                    InventoryError.AddAction('Partial Delivery Setup', Codeunit::"Delivery Management", 'SetupPartialDelivery');
                    InventoryError.AddAction('Customer Notification', Codeunit::"Customer Communication", 'NotifyStockShortage');
                end;
                
            UserRole::"Inventory Manager":
                begin
                    InventoryError.AddAction('Transfer from Location', Codeunit::"Transfer Management", 'CreateTransferOrder');
                    InventoryError.AddAction('Run Planning Worksheet', Codeunit::"Planning Worksheet", 'CalculateRegenPlan');
                    InventoryError.AddAction('Adjust Safety Stock', Codeunit::"Safety Stock Management", 'AdjustSafetyStock');
                    InventoryError.AddAction('Emergency Recount', Codeunit::"Physical Inventory", 'EmergencyRecount');
                end;
                
            UserRole::"Purchase Agent":
                begin
                    InventoryError.AddAction('Create Emergency PO', Codeunit::"Emergency Purchasing", 'CreateEmergencyOrder');
                    InventoryError.AddAction('Contact Vendor', Codeunit::"Vendor Communication", 'ContactForEmergencyDelivery');
                    InventoryError.AddAction('Check Vendor Stock', Codeunit::"Vendor Integration", 'CheckVendorAvailability');
                    InventoryError.AddAction('Expedited Delivery', Codeunit::"Delivery Options", 'SetupExpeditedDelivery');
                end;
                
            UserRole::"Warehouse Worker":
                begin
                    InventoryError.AddAction('Verify Physical Count', Codeunit::"Physical Inventory", 'QuickRecount');
                    InventoryError.AddAction('Check Reserved Stock', Codeunit::"Reservation Management", 'ShowReservations');
                    InventoryError.AddAction('Location Transfer', Codeunit::"Internal Movement", 'CreateInternalMovement');
                end;
                
            else begin
                InventoryError.AddAction('Contact Inventory Team', Codeunit::"Contact Management", 'ContactInventoryTeam');
                InventoryError.AddAction('View Item Details', Codeunit::"Item Information", 'ShowItemCard');
            end;
        end;
    end;
}
```

## Helper Functions for Context Building

### Supply Chain Analysis Helpers

```al
codeunit 50202 "Context Building Helpers"
{
    procedure AddSupplyChainAnalysis(var ContextBuilder: TextBuilder; ItemNo: Code[20])
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ProductionOrder: Record "Production Order";
        TransferHeader: Record "Transfer Header";
    begin
        // Pending purchase orders
        PurchaseLine.SetRange("No.", ItemNo);
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
        if PurchaseLine.FindSet() then begin
            ContextBuilder.AppendLine('PENDING PURCHASE ORDERS:');
            repeat
                if PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.") then
                    ContextBuilder.AppendLine(StrSubstNo('• PO %1: %2 %3 (Due: %4)', 
                                                        PurchaseHeader."No.", 
                                                        PurchaseLine."Outstanding Quantity",
                                                        PurchaseLine."Unit of Measure Code",
                                                        PurchaseLine."Expected Receipt Date"));
            until PurchaseLine.Next() = 0;
        end else
            ContextBuilder.AppendLine('• No pending purchase orders');
            
        // Production orders
        ProductionOrder.SetRange(Status, ProductionOrder.Status::Released);
        ProductionOrder.SetCurrentKey("Source No.");
        ProductionOrder.SetRange("Source No.", ItemNo);
        if ProductionOrder.FindSet() then begin
            ContextBuilder.AppendLine('PRODUCTION ORDERS:');
            repeat
                ContextBuilder.AppendLine(StrSubstNo('• Prod Order %1: %2 %3 (Due: %4)', 
                                                    ProductionOrder."No.", 
                                                    ProductionOrder.Quantity - ProductionOrder."Finished Quantity",
                                                    ProductionOrder."Unit of Measure Code",
                                                    ProductionOrder."Due Date"));
            until ProductionOrder.Next() = 0;
        end;
        
        // Incoming transfers
        if HasIncomingTransfers(ItemNo) then begin
            ContextBuilder.AppendLine('INCOMING TRANSFERS:');
            AddIncomingTransferInfo(ContextBuilder, ItemNo);
        end;
    end;
    
    procedure AddDemandAnalysis(var ContextBuilder: TextBuilder; ItemNo: Code[20]; LocationCode: Code[10])
    var
        SalesLine: Record "Sales Line";
        ServiceLine: Record "Service Line";
        ProdOrderComponent: Record "Prod. Order Component";
        TotalDemand: Decimal;
    begin
        // Sales orders demand
        SalesLine.SetRange("No.", ItemNo);
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Location Code", LocationCode);
        SalesLine.CalcSums("Outstanding Quantity");
        TotalDemand += SalesLine."Outstanding Quantity";
        
        if SalesLine."Outstanding Quantity" > 0 then
            ContextBuilder.AppendLine(StrSubstNo('• Sales Orders: %1 units', SalesLine."Outstanding Quantity"));
            
        // Service orders demand
        ServiceLine.SetRange("No.", ItemNo);
        ServiceLine.SetRange("Document Type", ServiceLine."Document Type"::Order);
        ServiceLine.SetRange("Location Code", LocationCode);
        ServiceLine.CalcSums("Outstanding Quantity");
        TotalDemand += ServiceLine."Outstanding Quantity";
        
        if ServiceLine."Outstanding Quantity" > 0 then
            ContextBuilder.AppendLine(StrSubstNo('• Service Orders: %1 units', ServiceLine."Outstanding Quantity"));
            
        // Production demand
        ProdOrderComponent.SetRange("Item No.", ItemNo);
        ProdOrderComponent.SetRange("Location Code", LocationCode);
        ProdOrderComponent.SetRange(Status, ProdOrderComponent.Status::Released);
        ProdOrderComponent.CalcSums("Remaining Quantity");
        TotalDemand += ProdOrderComponent."Remaining Quantity";
        
        if ProdOrderComponent."Remaining Quantity" > 0 then
            ContextBuilder.AppendLine(StrSubstNo('• Production: %1 units', ProdOrderComponent."Remaining Quantity"));
            
        ContextBuilder.AppendLine(StrSubstNo('• TOTAL DEMAND: %1 units', TotalDemand));
    end;
    
    procedure AddPlanningRecommendations(var ContextBuilder: TextBuilder; ItemNo: Code[20]; ShortageQty: Decimal)
    var
        Item: Record Item;
        RecommendedQty: Decimal;
        SuggestedAction: Text;
    begin
        if Item.Get(ItemNo) then begin
            RecommendedQty := CalculateOptimalOrderQuantity(Item, ShortageQty);
            SuggestedAction := GetOptimalSupplyAction(Item, ShortageQty);
            
            ContextBuilder.AppendLine(StrSubstNo('• Recommended Action: %1', SuggestedAction));
            ContextBuilder.AppendLine(StrSubstNo('• Suggested Quantity: %1 %2', RecommendedQty, Item."Base Unit of Measure"));
            
            case Item."Replenishment System" of
                Item."Replenishment System"::Purchase:
                    ContextBuilder.AppendLine('• Create purchase requisition');
                Item."Replenishment System"::"Prod. Order":
                    ContextBuilder.AppendLine('• Schedule production order');
                Item."Replenishment System"::Transfer:
                    ContextBuilder.AppendLine('• Arrange transfer from main location');
            end;
            
            if Item."Safety Stock Quantity" < ShortageQty then
                ContextBuilder.AppendLine('• Consider increasing safety stock level');
        end;
    end;
    
    local procedure CalculateOptimalOrderQuantity(Item: Record Item; ShortageQty: Decimal): Decimal
    var
        OptimalQty: Decimal;
    begin
        OptimalQty := ShortageQty;
        
        // Apply minimum order quantity
        if OptimalQty < Item."Minimum Order Quantity" then
            OptimalQty := Item."Minimum Order Quantity";
            
        // Apply order multiple
        if Item."Order Multiple" > 0 then
            OptimalQty := Round(OptimalQty / Item."Order Multiple", 1, '>') * Item."Order Multiple";
            
        // Add safety buffer
        OptimalQty += Item."Safety Stock Quantity";
        
        exit(OptimalQty);
    end;
    
    local procedure GetOptimalSupplyAction(Item: Record Item; ShortageQty: Decimal): Text
    begin
        case Item."Replenishment System" of
            Item."Replenishment System"::Purchase:
                if ShortageQty > Item."Maximum Order Quantity" then
                    exit('Multiple purchase orders required')
                else if GetVendorLeadTime(Item."Vendor No.") <= 7 then
                    exit('Emergency purchase order')
                else
                    exit('Standard purchase order');
                    
            Item."Replenishment System"::"Prod. Order":
                if CanScheduleProduction(Item."No.", ShortageQty) then
                    exit('Schedule production')
                else
                    exit('Purchase raw materials first');
                    
            Item."Replenishment System"::Transfer:
                if HasSufficientStockAtSource(Item."No.", ShortageQty) then
                    exit('Transfer from main location')
                else
                    exit('Source location also short - purchase required');
        end;
        
        exit('Review replenishment method');
    end;
}
```

These comprehensive examples demonstrate how to implement progressive error disclosure that adapts to user roles while maintaining clear, actionable error messages for all users.
