---
title: "Table Business Rules - Code Samples"
description: "Complete code examples for implementing complex business rules in AL tables"
area: "code-creation"
difficulty: "advanced"
object_types: ["Table"]
variable_types: ["Record", "Enum"]
tags: ["business-rules", "samples", "table-validation", "complex-validation"]
---

# Table Business Rules - Code Samples

## Loyalty Points Table with Complex Validation

```al
table 50101 "BRC Customer Loyalty Points"
{
    Caption = 'Customer Loyalty Points';
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            ToolTip = 'Specifies the customer number.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
            NotBlank = true;
            
            trigger OnValidate()
            begin
                ValidateCustomerEligibility();
            end;
        }
        
        field(10; "Current Points"; Integer)
        {
            Caption = 'Current Points';
            ToolTip = 'Specifies the current loyalty points balance.';
            DataClassification = CustomerContent;
            MinValue = 0;
            
            trigger OnValidate()
            begin
                ValidatePointsAdjustment();
            end;
        }
        
        field(11; "Points Tier"; Enum "Customer Loyalty Tier")
        {
            Caption = 'Points Tier';
            ToolTip = 'Specifies the customer loyalty tier based on points.';
            DataClassification = CustomerContent;
            Editable = false; // Calculated field
            
            trigger OnValidate()
            begin
                Error('Points tier is automatically calculated and cannot be modified directly.');
            end;
        }
        
        field(20; "Last Transaction Date"; Date)
        {
            Caption = 'Last Transaction Date';
            ToolTip = 'Specifies the date of the last points transaction.';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
    
    keys
    {
        key(PK; "Customer No.")
        {
            Clustered = true;
        }
        
        key(Points; "Current Points")
        {
            // For tier calculations and reporting
        }
    }
    
    // Complex business validation
    local procedure ValidateCustomerEligibility()
    var
        Customer: Record Customer;
        CustomerRating: Record "BRC Customer Rating";
    begin
        if not Customer.Get("Customer No.") then
            Error('Customer %1 does not exist.', "Customer No.");
            
        if Customer.Blocked <> Customer.Blocked::" " then
            Error('Cannot assign loyalty points to blocked customer %1.', "Customer No.");
            
        // Business rule: Customer must have minimum rating
        CustomerRating.SetRange("Customer No.", "Customer No.");
        CustomerRating.CalcFields("Average Rating");
        if CustomerRating."Average Rating" < 3.0 then
            Error('Customer %1 must have a minimum average rating of 3.0 to participate in loyalty program.', "Customer No.");
    end;
    
    local procedure ValidatePointsAdjustment()
    var
        OldPoints: Integer;
        MaxDailyAdjustment: Integer;
    begin
        MaxDailyAdjustment := 1000; // Business rule: max 1000 points per day
        
        OldPoints := xRec."Current Points";
        
        if Abs("Current Points" - OldPoints) > MaxDailyAdjustment then
            Error('Daily points adjustment cannot exceed %1 points.', MaxDailyAdjustment);
            
        // Automatically update tier when points change
        UpdateLoyaltyTier();
        "Last Transaction Date" := Today;
    end;
    
    local procedure UpdateLoyaltyTier()
    begin
        case "Current Points" of
            0..999:
                "Points Tier" := "Points Tier"::Bronze;
            1000..4999:
                "Points Tier" := "Points Tier"::Silver;
            5000..9999:
                "Points Tier" := "Points Tier"::Gold;
            else
                "Points Tier" := "Points Tier"::Platinum;
        end;
    end;
}
```

## Multi-Field Business Logic Validation

```al
table 50102 "Sales Order Line Extension"
{
    fields
    {
        field(50000; "Discount %"; Decimal)
        {
            Caption = 'Discount %';
            DecimalPlaces = 2 : 2;
            MinValue = 0;
            MaxValue = 100;
            
            trigger OnValidate()
            begin
                ValidateDiscountRules();
            end;
        }
        
        field(50001; "Special Price"; Boolean)
        {
            Caption = 'Special Price';
            
            trigger OnValidate()
            begin
                if "Special Price" then
                    ValidateSpecialPriceAuthorization();
            end;
        }
        
        field(50002; "Authorized By"; Code[50])
        {
            Caption = 'Authorized By';
            TableRelation = User."User Name";
        }
    }
    
    local procedure ValidateDiscountRules()
    var
        Customer: Record Customer;
        UserSetup: Record "User Setup";
        MaxDiscount: Decimal;
    begin
        if "Discount %" = 0 then
            exit;
            
        // Get customer discount limit
        if Customer.Get("Sell-to Customer No.") then
            MaxDiscount := Customer."Max Discount %"
        else
            MaxDiscount := 10; // Default limit
            
        // Check user authorization for higher discounts
        if "Discount %" > MaxDiscount then begin
            UserSetup.Get(UserId);
            if not UserSetup."Allow Discount Override" then
                Error('You are not authorized to give discount higher than %1%%.', MaxDiscount);
                
            if "Discount %" > UserSetup."Max Discount %" then
                Error('Maximum discount you can authorize is %1%%.', UserSetup."Max Discount %");
                
            "Special Price" := true;
            "Authorized By" := UserId;
        end;
    end;
    
    local procedure ValidateSpecialPriceAuthorization()
    var
        UserSetup: Record "User Setup";
    begin
        if not UserSetup.Get(UserId) then
            Error('User setup not found for current user.');
            
        if not UserSetup."Allow Special Pricing" then
            Error('You are not authorized to set special prices.');
            
        if "Authorized By" = '' then
            "Authorized By" := UserId;
    end;
}
```

## Cross-Table Business Rule Validation

```al
table 50103 "Project Resource Allocation"
{
    fields
    {
        field(1; "Project No."; Code[20])
        {
            TableRelation = Job."No.";
            
            trigger OnValidate()
            begin
                ValidateProjectStatus();
            end;
        }
        
        field(2; "Resource No."; Code[20])
        {
            TableRelation = Resource."No.";
            
            trigger OnValidate()
            begin
                ValidateResourceAvailability();
            end;
        }
        
        field(3; "Allocation %"; Decimal)
        {
            DecimalPlaces = 2 : 2;
            MinValue = 1;
            MaxValue = 100;
            
            trigger OnValidate()
            begin
                ValidateAllocationLimits();
            end;
        }
    }
    
    local procedure ValidateProjectStatus()
    var
        Job: Record Job;
    begin
        if Job.Get("Project No.") then begin
            if Job.Status = Job.Status::Completed then
                Error('Cannot allocate resources to completed project %1.', "Project No.");
                
            if Job.Status = Job.Status::Planning then
                if not Confirm('Project %1 is still in planning phase. Continue?', false, "Project No.") then
                    Error('');
        end;
    end;
    
    local procedure ValidateResourceAvailability()
    var
        Resource: Record Resource;
        ExistingAllocation: Record "Project Resource Allocation";
        TotalAllocation: Decimal;
    begin
        if not Resource.Get("Resource No.") then
            exit;
            
        if Resource.Blocked then
            Error('Resource %1 is blocked and cannot be allocated.', "Resource No.");
            
        // Check total allocation doesn't exceed 100%
        ExistingAllocation.SetRange("Resource No.", "Resource No.");
        ExistingAllocation.SetFilter("Project No.", '<>%1', "Project No.");
        ExistingAllocation.CalcSums("Allocation %");
        TotalAllocation := ExistingAllocation."Allocation %" + "Allocation %";
        
        if TotalAllocation > 100 then
            Error('Total allocation for resource %1 would exceed 100%% (Current: %2%%).', 
                "Resource No.", ExistingAllocation."Allocation %");
    end;
}
```

## Related Topics
- [Table Business Rules](table-business-rules.md)
- [Table Field Validation](table-field-validation.md)
- [Table Design Patterns](table-design-patterns.md)
