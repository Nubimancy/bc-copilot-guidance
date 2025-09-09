---
title: "Progressive Error Disclosure"
description: "Implement layered error messaging that provides user-friendly messages with optional technical details"
area: "error-handling"
difficulty: "intermediate"
object_types: ["Codeunit"]
variable_types: ["ErrorInfo"]
tags: ["error-handling", "user-experience", "technical-details", "verbosity"]
---

# Progressive Error Disclosure

Progressive error disclosure provides users with appropriately detailed error information based on their role and needs, while keeping technical details available for troubleshooting.

## Core Principles

### User-Friendly Primary Messages
The main error message should be:
- Clear and non-technical
- Action-oriented
- Contextually appropriate for the business user
- Free of system jargon or technical codes

### Technical Details Available on Demand
Detailed technical information should be:
- Included in `DetailedMessage` property
- Accessible but not overwhelming
- Useful for IT administrators and developers
- Complete enough for troubleshooting

## Implementation Pattern

### Basic Progressive Disclosure Structure

```al
procedure ProcessPaymentWithGracefulHandling(PaymentData: Record "Payment Information")
var
    PaymentError: ErrorInfo;
begin
    if not TryProcessPayment(PaymentData) then begin
        // User-friendly message
        PaymentError.Message := 'Payment processing failed. Please try again or contact support.';
        
        // Technical details for troubleshooting
        PaymentError.DetailedMessage := StrSubstNo('Payment gateway returned error: %1. Transaction ID: %2. Timestamp: %3', 
                                                   GetLastErrorText(), PaymentData."Transaction ID", CurrentDateTime);
        
        // Context-aware actions
        PaymentError.AddAction('Retry Payment', Codeunit::"Payment Processor", 'RetryPayment');
        PaymentError.AddAction('Use Alternative Method', Codeunit::"Payment Processor", 'ShowAlternativeMethods');
        PaymentError.AddAction('Contact Support', Codeunit::"Payment Processor", 'ContactSupport');
        
        Error(PaymentError);
    end;
end;
```

### Contextual Error Verbosity

```al
procedure ValidateInventoryWithContext(Item: Record Item; RequiredQty: Decimal; UserRole: Enum "User Role Type")
var
    InventoryError: ErrorInfo;
    AvailableQty: Decimal;
begin
    AvailableQty := GetAvailableInventory(Item."No.");
    
    if AvailableQty < RequiredQty then begin
        // Primary message - always simple and business-focused
        InventoryError.Message := StrSubstNo('Insufficient inventory for item %1. Available: %2, Required: %3', 
                                            Item."No.", AvailableQty, RequiredQty);
        
        // Detailed message varies by user role
        case UserRole of
            UserRole::"Sales Person":
                InventoryError.DetailedMessage := BuildSalesPersonContext(Item, AvailableQty, RequiredQty);
            UserRole::"Inventory Manager":
                InventoryError.DetailedMessage := BuildInventoryManagerContext(Item, AvailableQty, RequiredQty);
            UserRole::"System Administrator":
                InventoryError.DetailedMessage := BuildTechnicalContext(Item, AvailableQty, RequiredQty);
            else
                InventoryError.DetailedMessage := BuildGenericContext(Item, AvailableQty, RequiredQty);
        end;
        
        // Add role-appropriate actions
        AddRoleBasedActions(InventoryError, UserRole, Item);
        
        Error(InventoryError);
    end;
end;
```

## Context-Specific Messaging

### Sales Person Context
Focus on business impact and customer management:

```al
local procedure BuildSalesPersonContext(Item: Record Item; Available: Decimal; Required: Decimal): Text
var
    ContextMessage: TextBuilder;
begin
    ContextMessage.AppendLine('INVENTORY STATUS:');
    ContextMessage.AppendLine(StrSubstNo('• Item: %1 - %2', Item."No.", Item.Description));
    ContextMessage.AppendLine(StrSubstNo('• Available: %1 %2', Available, Item."Base Unit of Measure"));
    ContextMessage.AppendLine(StrSubstNo('• Required: %1 %2', Required, Item."Base Unit of Measure"));
    ContextMessage.AppendLine('');
    ContextMessage.AppendLine('CUSTOMER IMPACT:');
    ContextMessage.AppendLine('• Order cannot be fulfilled as requested');
    ContextMessage.AppendLine('• Consider partial delivery or alternative items');
    ContextMessage.AppendLine('• Check expected receipt dates for restock');
    
    exit(ContextMessage.ToText());
end;
```

### Inventory Manager Context
Focus on supply chain and replenishment:

```al
local procedure BuildInventoryManagerContext(Item: Record Item; Available: Decimal; Required: Decimal): Text
var
    ContextMessage: TextBuilder;
    PurchaseOrder: Record "Purchase Header";
    RequisitionLine: Record "Requisition Line";
begin
    ContextMessage.AppendLine('INVENTORY ANALYSIS:');
    ContextMessage.AppendLine(StrSubstNo('• Current Stock: %1', Available));
    ContextMessage.AppendLine(StrSubstNo('• Shortage: %1', Required - Available));
    ContextMessage.AppendLine(StrSubstNo('• Safety Stock Level: %1', Item."Safety Stock Quantity"));
    ContextMessage.AppendLine(StrSubstNo('• Reorder Point: %1', Item."Reorder Point"));
    ContextMessage.AppendLine('');
    
    // Add supply information if available
    if HasPendingPurchaseOrders(Item."No.", PurchaseOrder) then begin
        ContextMessage.AppendLine('PENDING SUPPLIES:');
        ContextMessage.AppendLine(StrSubstNo('• Purchase Order: %1 (Qty: %2, Due: %3)', 
                                            PurchaseOrder."No.", GetPOQuantity(PurchaseOrder, Item."No."), PurchaseOrder."Expected Receipt Date"));
    end;
    
    if HasRequisitionSuggestions(Item."No.", RequisitionLine) then begin
        ContextMessage.AppendLine('PLANNING SUGGESTIONS:');
        ContextMessage.AppendLine(StrSubstNo('• Suggested Qty: %1', RequisitionLine.Quantity));
        ContextMessage.AppendLine(StrSubstNo('• Due Date: %1', RequisitionLine."Due Date"));
    end;
    
    exit(ContextMessage.ToText());
end;
```

### Technical Administrator Context
Focus on system details and troubleshooting:

```al
local procedure BuildTechnicalContext(Item: Record Item; Available: Decimal; Required: Decimal): Text
var
    ContextMessage: TextBuilder;
begin
    ContextMessage.AppendLine('TECHNICAL DETAILS:');
    ContextMessage.AppendLine(StrSubstNo('• Timestamp: %1', CurrentDateTime));
    ContextMessage.AppendLine(StrSubstNo('• User: %1', UserId));
    ContextMessage.AppendLine(StrSubstNo('• Session: %1', SessionId));
    ContextMessage.AppendLine(StrSubstNo('• Item Ledger Entries: %1', CountItemLedgerEntries(Item."No.")));
    ContextMessage.AppendLine('');
    ContextMessage.AppendLine('CALCULATION TRACE:');
    ContextMessage.AppendLine(StrSubstNo('• Inventory Calculation Method: %1', Item."Costing Method"));
    ContextMessage.AppendLine(StrSubstNo('• Location Filter: %1', GetCurrentLocationFilter()));
    ContextMessage.AppendLine(StrSubstNo('• Variant Filter: %1', GetCurrentVariantFilter()));
    ContextMessage.AppendLine(StrSubstNo('• Date Filter: %1', GetCurrentDateFilter()));
    
    exit(ContextMessage.ToText());
end;
```

## Layered Action Suggestions

### Role-Based Action Filtering

```al
local procedure AddRoleBasedActions(var ErrorInfo: ErrorInfo; UserRole: Enum "User Role Type"; Item: Record Item)
begin
    case UserRole of
        UserRole::"Sales Person":
            begin
                ErrorInfo.AddAction('Check Alternatives', Codeunit::"Item Alternatives", 'ShowAlternatives');
                ErrorInfo.AddAction('Partial Delivery', Codeunit::"Sales Order Management", 'SetupPartialDelivery');
                ErrorInfo.AddAction('Customer Notification', Codeunit::"Customer Communication", 'NotifyDelay');
            end;
            
        UserRole::"Inventory Manager":
            begin
                ErrorInfo.AddAction('Create Purchase Order', Codeunit::"Purchase Management", 'CreateEmergencyPO');
                ErrorInfo.AddAction('Run Planning Worksheet', Codeunit::"Planning Management", 'RunRequisitionPlan');
                ErrorInfo.AddAction('Transfer from Location', Codeunit::"Transfer Management", 'ShowTransferOptions');
                ErrorInfo.AddAction('Adjust Safety Stock', Codeunit::"Item Management", 'AdjustSafetyStock');
            end;
            
        UserRole::"System Administrator":
            begin
                ErrorInfo.AddAction('View Item Ledger', Codeunit::"Item Ledger Analysis", 'OpenLedgerEntries');
                ErrorInfo.AddAction('Recalculate Inventory', Codeunit::"Inventory Management", 'RecalculateInventory');
                ErrorInfo.AddAction('Check Data Integrity', Codeunit::"Data Validation", 'ValidateItemData');
                ErrorInfo.AddAction('Export Error Log', Codeunit::"Error Management", 'ExportErrorDetails');
            end;
            
        else begin
            // Default actions for general users
            ErrorInfo.AddAction('Contact Inventory Team', Codeunit::"Contact Management", 'ContactInventoryTeam');
            ErrorInfo.AddAction('View Item Card', Codeunit::"Item Management", 'ShowItemCard');
        end;
    end;
end;
```

## Verbosity Level Management

### Dynamic Verbosity Control

```al
procedure ConfigureErrorVerbosity(var ErrorInfo: ErrorInfo; UserRole: Enum "User Role Type"; 
                                 ErrorSeverity: Enum "Error Severity")
begin
    // Set appropriate verbosity based on role and severity
    case UserRole of
        UserRole::"System Administrator":
            ErrorInfo.Verbosity := Verbosity::Verbose; // Always show full details
            
        UserRole::"Inventory Manager", UserRole::"Purchase Manager":
            if ErrorSeverity = ErrorSeverity::Critical then
                ErrorInfo.Verbosity := Verbosity::Verbose
            else
                ErrorInfo.Verbosity := Verbosity::Normal;
                
        UserRole::"Sales Person", UserRole::"End User":
            if ErrorSeverity = ErrorSeverity::Critical then
                ErrorInfo.Verbosity := Verbosity::Normal
            else
                ErrorInfo.Verbosity := Verbosity::Brief; // Minimal technical details
                
        else
            ErrorInfo.Verbosity := Verbosity::Brief; // Default to minimal
    end;
    
    // Adjust data classification based on verbosity
    if ErrorInfo.Verbosity = Verbosity::Verbose then
        ErrorInfo.DataClassification := DataClassification::SystemMetadata
    else
        ErrorInfo.DataClassification := DataClassification::CustomerContent;
end;
```

## Best Practices

### Message Hierarchy
1. **Primary Message**: Always business-focused and actionable
2. **Detailed Message**: Technical context appropriate to user role
3. **Suggested Actions**: Prioritized by likelihood to resolve the issue

### Context Preservation
- Include relevant business context (customer, order, item)
- Preserve technical tracking information (timestamps, session IDs)
- Maintain audit trail for compliance and troubleshooting

### User Experience Optimization
- Keep primary messages concise and clear
- Make technical details opt-in rather than overwhelming
- Provide graduated response options from simple to complex

Progressive error disclosure ensures that every user gets the right amount of information to effectively handle errors while maintaining system usability and providing complete troubleshooting capabilities when needed.
