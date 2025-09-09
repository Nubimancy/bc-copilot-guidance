# AL Table Creation Patterns - Code Samples

## Basic Table Creation with Validation

### Well-Structured Table with Proper Validation

```al
// Basic table following AL best practices
table 50100 "Customer Rating"
{
    Caption = 'Customer Rating';
    DataClassification = CustomerContent;
    LookupPageId = "Customer Rating List";
    DrillDownPageId = "Customer Rating List";

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            ToolTip = 'Specifies the number of the customer for this rating.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
            NotBlank = true;
            
            trigger OnValidate()
            begin
                ValidateCustomerExists();
                UpdateCustomerRelatedFields();
            end;
            
            trigger OnLookup()
            var
                Customer: Record Customer;
                CustomerList: Page "Customer List";
            begin
                CustomerList.SetTableView(Customer);
                CustomerList.LookupMode(true);
                if CustomerList.RunModal() = Action::LookupOK then begin
                    CustomerList.GetRecord(Customer);
                    "Customer No." := Customer."No.";
                    Validate("Customer No.");
                end;
            end;
        }
        
        field(2; "Rating Value"; Decimal)
        {
            Caption = 'Rating Value';
            ToolTip = 'Specifies the rating value from 1 to 5.';
            DataClassification = CustomerContent;
            DecimalPlaces = 1 : 1;
            MinValue = 1.0;
            MaxValue = 5.0;
            
            trigger OnValidate()
            begin
                ValidateRatingValue();
                UpdateAverageRating();
            end;
        }
        
        field(3; "Rating Date"; Date)
        {
            Caption = 'Rating Date';
            ToolTip = 'Specifies when this rating was given.';
            DataClassification = CustomerContent;
            NotBlank = true;
            
            trigger OnValidate()
            begin
                if "Rating Date" > Today() then
                    Error('Rating date cannot be in the future.');
                    
                if "Rating Date" < CalcDate('-1Y', Today()) then
                    if not Confirm('Rating date is more than a year old. Do you want to continue?') then
                        Error('');
            end;
        }
        
        field(4; "Reviewer Name"; Text[100])
        {
            Caption = 'Reviewer Name';
            ToolTip = 'Specifies the name of the person who gave this rating.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        
        field(5; Comments; Text[250])
        {
            Caption = 'Comments';
            ToolTip = 'Specifies additional comments about this rating.';
            DataClassification = CustomerContent;
        }
        
        field(10; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        
        // Calculated fields
        field(20; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Customer.Name where("No." = field("Customer No.")));
            Editable = false;
        }
        
        field(21; "Average Rating"; Decimal)
        {
            Caption = 'Average Rating';
            FieldClass = FlowField;
            CalcFormula = average("Customer Rating"."Rating Value" where("Customer No." = field("Customer No.")));
            DecimalPlaces = 2 : 2;
            Editable = false;
        }
    }
    
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        
        key(CustomerKey; "Customer No.", "Rating Date")
        {
        }
        
        key(RatingValueKey; "Rating Value", "Rating Date")
        {
        }
    }
    
    trigger OnInsert()
    begin
        ValidateInsertPermissions();
        SetDefaultValues();
        LogRatingCreation();
    end;
    
    trigger OnModify()
    begin
        ValidateModifyPermissions();
        LogRatingModification();
    end;
    
    trigger OnDelete()
    begin
        ValidateDeletePermissions();
        LogRatingDeletion();
    end;
    
    /// <summary>
    /// Validates that the customer exists and is not blocked
    /// </summary>
    local procedure ValidateCustomerExists()
    var
        Customer: Record Customer;
    begin
        if "Customer No." = '' then
            exit;
            
        if not Customer.Get("Customer No.") then
            Error('Customer %1 does not exist.', "Customer No.");
            
        if Customer.Blocked <> Customer.Blocked::" " then
            Error('Customer %1 is blocked and cannot receive ratings.', "Customer No.");
    end;
    
    /// <summary>
    /// Validates the rating value against business rules
    /// </summary>
    local procedure ValidateRatingValue()
    begin
        if "Rating Value" < 1.0 then
            Error('Rating value must be at least 1.0');
            
        if "Rating Value" > 5.0 then
            Error('Rating value cannot exceed 5.0');
    end;
    
    /// <summary>
    /// Updates customer-related fields when customer changes
    /// </summary>
    local procedure UpdateCustomerRelatedFields()
    begin
        CalcFields("Customer Name");
        if "Rating Date" = 0D then
            "Rating Date" := Today();
    end;
    
    /// <summary>
    /// Updates the average rating calculation
    /// </summary>
    local procedure UpdateAverageRating()
    var
        CustomerRating: Record "Customer Rating";
    begin
        CustomerRating.SetRange("Customer No.", "Customer No.");
        CustomerRating.CalcFields("Average Rating");
        // Average rating is automatically calculated by FlowField
    end;
    
    /// <summary>
    /// Sets default values for new records
    /// </summary>
    local procedure SetDefaultValues()
    begin
        if "Rating Date" = 0D then
            "Rating Date" := Today();
            
        if "Reviewer Name" = '' then
            "Reviewer Name" := UserId();
    end;
    
    /// <summary>
    /// Validates permissions for inserting new ratings
    /// </summary>
    local procedure ValidateInsertPermissions()
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.Get(UserId()) then
            if UserSetup."Allow Rating Creation" = false then
                Error('You do not have permission to create ratings.');
    end;
    
    /// <summary>
    /// Validates permissions for modifying ratings
    /// </summary>
    local procedure ValidateModifyPermissions()
    begin
        if (xRec."Reviewer Name" <> "Reviewer Name") and (xRec."Reviewer Name" <> UserId()) then
            Error('You can only modify ratings that you created.');
    end;
    
    /// <summary>
    /// Validates permissions for deleting ratings
    /// </summary>
    local procedure ValidateDeletePermissions()
    begin
        if "Reviewer Name" <> UserId() then
            Error('You can only delete ratings that you created.');
    end;
    
    /// <summary>
    /// Logs rating creation for audit purposes
    /// </summary>
    local procedure LogRatingCreation()
    var
        ActivityLog: Record "Activity Log";
    begin
        ActivityLog.LogActivity(
            Rec,
            ActivityLog.Status::Success,
            'Rating Management',
            'Rating Created',
            StrSubstNo('Rating %1 created for customer %2', "Rating Value", "Customer No."));
    end;
    
    /// <summary>
    /// Logs rating modification for audit purposes
    /// </summary>
    local procedure LogRatingModification()
    var
        ActivityLog: Record "Activity Log";
    begin
        ActivityLog.LogActivity(
            Rec,
            ActivityLog.Status::Success,
            'Rating Management',
            'Rating Modified',
            StrSubstNo('Rating for customer %1 modified from %2 to %3', "Customer No.", xRec."Rating Value", "Rating Value"));
    end;
    
    /// <summary>
    /// Logs rating deletion for audit purposes
    /// </summary>
    local procedure LogRatingDeletion()
    var
        ActivityLog: Record "Activity Log";
    begin
        ActivityLog.LogActivity(
            Rec,
            ActivityLog.Status::Success,
            'Rating Management',
            'Rating Deleted',
            StrSubstNo('Rating %1 deleted for customer %2', "Rating Value", "Customer No."));
    end;
}
```

## Advanced Table with Complex Business Logic

### Customer Loyalty Points Table

```al
// Advanced table with complex validation and business logic
table 50101 "Customer Loyalty Points"
{
    Caption = 'Customer Loyalty Points';
    DataClassification = CustomerContent;
    LookupPageId = "Customer Loyalty Points List";
    
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
                CalculatePointsExpiration();
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
                UpdatePointsHistory();
            end;
        }
        
        field(11; "Lifetime Points"; Integer)
        {
            Caption = 'Lifetime Points Earned';
            ToolTip = 'Specifies the total points earned by this customer.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        
        field(12; "Points Redeemed"; Integer)
        {
            Caption = 'Points Redeemed';
            ToolTip = 'Specifies the total points redeemed by this customer.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        
        field(20; "Tier Level"; Enum "Customer Loyalty Tier")
        {
            Caption = 'Tier Level';
            ToolTip = 'Specifies the customer loyalty tier level.';
            DataClassification = CustomerContent;
            
            trigger OnValidate()
            begin
                ValidateTierLevel();
                ApplyTierBenefits();
            end;
        }
        
        field(21; "Points Expiration Date"; Date)
        {
            Caption = 'Points Expiration Date';
            ToolTip = 'Specifies when the current points will expire.';
            DataClassification = CustomerContent;
        }
        
        field(30; "Last Activity Date"; Date)
        {
            Caption = 'Last Activity Date';
            ToolTip = 'Specifies the date of the last points activity.';
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
        
        key(TierKey; "Tier Level", "Current Points")
        {
        }
        
        key(ExpirationKey; "Points Expiration Date")
        {
        }
    }
    
    trigger OnInsert()
    begin
        SetDefaultValues();
        CalculateInitialTier();
        LogLoyaltyAccountCreation();
    end;
    
    /// <summary>
    /// Validates customer eligibility for loyalty program
    /// </summary>
    local procedure ValidateCustomerEligibility()
    var
        Customer: Record Customer;
        CustomerRating: Record "Customer Rating";
        MinimumRating: Decimal;
    begin
        if not Customer.Get("Customer No.") then
            Error('Customer %1 does not exist.', "Customer No.");
            
        if Customer.Blocked <> Customer.Blocked::" " then
            Error('Cannot assign loyalty points to blocked customer %1.', "Customer No.");
            
        // Business rule: Customer must have minimum average rating
        CustomerRating.SetRange("Customer No.", "Customer No.");
        CustomerRating.CalcFields("Average Rating");
        MinimumRating := 3.0;
        
        if CustomerRating."Average Rating" < MinimumRating then
            Error('Customer %1 must have an average rating of at least %2 to participate in the loyalty program.', 
                "Customer No.", MinimumRating);
    end;
    
    /// <summary>
    /// Validates points adjustment based on business rules
    /// </summary>
    local procedure ValidatePointsAdjustment()
    var
        MaxDailyPoints: Integer;
        PointsToday: Integer;
    begin
        MaxDailyPoints := 1000; // Maximum points that can be adjusted per day
        
        // Check daily points limit
        PointsToday := GetDailyPointsAdjustment();
        if (PointsToday + ("Current Points" - xRec."Current Points")) > MaxDailyPoints then
            Error('Daily points adjustment limit of %1 would be exceeded.', MaxDailyPoints);
    end;
    
    /// <summary>
    /// Calculates when points will expire
    /// </summary>
    local procedure CalculatePointsExpiration()
    var
        LoyaltySetup: Record "Loyalty Program Setup";
    begin
        LoyaltySetup.Get();
        "Points Expiration Date" := CalcDate(LoyaltySetup."Points Expiration Period", Today());
    end;
    
    /// <summary>
    /// Validates and applies tier level changes
    /// </summary>
    local procedure ValidateTierLevel()
    var
        RequiredPoints: Integer;
    begin
        RequiredPoints := GetRequiredPointsForTier("Tier Level");
        
        if "Current Points" < RequiredPoints then
            Error('Customer needs at least %1 points for %2 tier level.', RequiredPoints, "Tier Level");
    end;
    
    /// <summary>
    /// Applies benefits based on tier level
    /// </summary>
    local procedure ApplyTierBenefits()
    var
        Customer: Record Customer;
    begin
        if Customer.Get("Customer No.") then begin
            case "Tier Level" of
                "Tier Level"::Bronze:
                    Customer."Payment Discount %" := 2;
                "Tier Level"::Silver:
                    Customer."Payment Discount %" := 5;
                "Tier Level"::Gold:
                    Customer."Payment Discount %" := 8;
                "Tier Level"::Platinum:
                    Customer."Payment Discount %" := 12;
            end;
            Customer.Modify();
        end;
    end;
    
    /// <summary>
    /// Gets the required points for a specific tier level
    /// </summary>
    local procedure GetRequiredPointsForTier(TierLevel: Enum "Customer Loyalty Tier"): Integer
    begin
        case TierLevel of
            TierLevel::Bronze:
                exit(100);
            TierLevel::Silver:
                exit(500);
            TierLevel::Gold:
                exit(1500);
            TierLevel::Platinum:
                exit(5000);
            else
                exit(0);
        end;
    end;
    
    /// <summary>
    /// Gets total points adjusted today for this customer
    /// </summary>
    local procedure GetDailyPointsAdjustment(): Integer
    var
        LoyaltyPointsHistory: Record "Loyalty Points History";
    begin
        LoyaltyPointsHistory.SetRange("Customer No.", "Customer No.");
        LoyaltyPointsHistory.SetRange("Transaction Date", Today());
        LoyaltyPointsHistory.CalcSums("Points Adjustment");
        exit(LoyaltyPointsHistory."Points Adjustment");
    end;
    
    /// <summary>
    /// Updates points history when points are modified
    /// </summary>
    local procedure UpdatePointsHistory()
    var
        LoyaltyPointsHistory: Record "Loyalty Points History";
        PointsChange: Integer;
    begin
        PointsChange := "Current Points" - xRec."Current Points";
        if PointsChange <> 0 then begin
            LoyaltyPointsHistory.Init();
            LoyaltyPointsHistory."Entry No." := GetNextEntryNo();
            LoyaltyPointsHistory."Customer No." := "Customer No.";
            LoyaltyPointsHistory."Transaction Date" := Today();
            LoyaltyPointsHistory."Points Adjustment" := PointsChange;
            LoyaltyPointsHistory."Reason Code" := DetermineReasonCode(PointsChange);
            LoyaltyPointsHistory."User ID" := UserId();
            LoyaltyPointsHistory.Insert();
            
            "Last Activity Date" := Today();
        end;
    end;
    
    local procedure GetNextEntryNo(): Integer
    var
        LoyaltyPointsHistory: Record "Loyalty Points History";
    begin
        LoyaltyPointsHistory.LockTable();
        if LoyaltyPointsHistory.FindLast() then
            exit(LoyaltyPointsHistory."Entry No." + 1)
        else
            exit(1);
    end;
    
    local procedure DetermineReasonCode(PointsChange: Integer): Code[10]
    begin
        if PointsChange > 0 then
            exit('EARNED')
        else
            exit('REDEEMED');
    end;
}
```

## Performance-Optimized Table Design

### Indexed Table for High-Volume Operations

```al
// Performance-optimized table design
table 50102 "Customer Transaction Log"
{
    Caption = 'Customer Transaction Log';
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            ToolTip = 'Specifies the customer number.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        
        field(3; "Transaction Date"; DateTime)
        {
            Caption = 'Transaction Date';
            ToolTip = 'Specifies when the transaction occurred.';
            DataClassification = CustomerContent;
        }
        
        field(4; "Transaction Type"; Enum "Transaction Type")
        {
            Caption = 'Transaction Type';
            ToolTip = 'Specifies the type of transaction.';
            DataClassification = CustomerContent;
        }
        
        field(5; Amount; Decimal)
        {
            Caption = 'Amount';
            ToolTip = 'Specifies the transaction amount.';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
        }
    }
    
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        
        // Optimized for customer queries
        key(CustomerDateKey; "Customer No.", "Transaction Date")
        {
            SumIndexFields = Amount;
        }
        
        // Optimized for reporting
        key(DateTypeKey; "Transaction Date", "Transaction Type")
        {
            SumIndexFields = Amount;
        }
        
        // Optimized for recent transactions
        key(RecentTransactionsKey; "Transaction Date" desc)
        {
            SumIndexFields = Amount;
        }
    }
    
    // Minimal triggers for performance
    trigger OnInsert()
    begin
        if "Transaction Date" = 0DT then
            "Transaction Date" := CurrentDateTime();
    end;
}
```
