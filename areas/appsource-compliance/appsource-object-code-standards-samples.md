# AppSource Object and Code Standards - Code Samples

## Complete Table Example with AppSource Compliance

```al
table 50100 "BRC Customer Loyalty Card"
{
    Caption = 'Customer Loyalty Card';
    DataClassification = CustomerContent;
    LookupPageId = "BRC Customer Loyalty List";
    DrillDownPageId = "BRC Customer Loyalty List";
    
    fields
    {
        field(1; "Card No."; Code[20])
        {
            Caption = 'Card No.';
            ToolTip = 'Specifies the unique identifier for the loyalty card. Each card must have a unique number.';
            DataClassification = CustomerContent;
            NotBlank = true;
            
            trigger OnValidate()
            begin
                ValidateCardNumber();
            end;
        }
        
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            ToolTip = 'Specifies the customer who owns this loyalty card. The customer must exist in the system.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
            NotBlank = true;
            
            trigger OnValidate()
            begin
                ValidateCustomerExists();
                UpdateCustomerName();
            end;
        }
        
        field(3; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            ToolTip = 'Shows the name of the customer who owns this loyalty card. This field is automatically updated.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        
        field(10; "Points Balance"; Integer)
        {
            Caption = 'Points Balance';
            ToolTip = 'Shows the current points balance on the loyalty card. Points cannot be negative.';
            DataClassification = CustomerContent;
            MinValue = 0;
            
            trigger OnValidate()
            begin
                if "Points Balance" < 0 then
                    Error('Points balance cannot be negative. Current attempt to set: %1', "Points Balance");
            end;
        }
        
        field(11; "Card Status"; Enum "BRC Card Status")
        {
            Caption = 'Card Status';
            ToolTip = 'Specifies whether the loyalty card is active, suspended, or expired.';
            DataClassification = CustomerContent;
            InitValue = Active;
        }
        
        field(20; "Issue Date"; Date)
        {
            Caption = 'Issue Date';
            ToolTip = 'Specifies the date when the loyalty card was issued to the customer.';
            DataClassification = CustomerContent;
            
            trigger OnValidate()
            begin
                if "Issue Date" > Today then
                    Error('Issue date cannot be in the future. Please enter a valid date.');
            end;
        }
        
        field(21; "Expiry Date"; Date)
        {
            Caption = 'Expiry Date';
            ToolTip = 'Specifies when the loyalty card expires. Leave blank for cards that do not expire.';
            DataClassification = CustomerContent;
            
            trigger OnValidate()
            begin
                if ("Expiry Date" <> 0D) and ("Expiry Date" <= "Issue Date") then
                    Error('Expiry date must be after the issue date.');
            end;
        }
    }
    
    keys
    {
        key(PK; "Card No.") { Clustered = true; }
        key(CustomerKey; "Customer No.") { }
        key(StatusKey; "Card Status", "Expiry Date") { }
    }
    
    trigger OnInsert()
    begin
        if "Issue Date" = 0D then
            "Issue Date" := Today;
            
        UpdateCustomerName();
    end;
    
    trigger OnDelete()
    begin
        CheckCardCanBeDeleted();
    end;
    
    /// <summary>
    /// Validates that the card number is unique across all loyalty cards
    /// </summary>
    local procedure ValidateCardNumber()
    var
        ExistingCard: Record "BRC Customer Loyalty Card";
        ErrorInfo: ErrorInfo;
    begin
        if "Card No." = '' then
            exit;
            
        ExistingCard.SetRange("Card No.", "Card No.");
        ExistingCard.SetFilter("Customer No.", '<>%1', "Customer No.");
        
        if not ExistingCard.IsEmpty then begin
            ErrorInfo.Title := 'Duplicate Card Number';
            ErrorInfo.Message := StrSubstNo('Card number %1 is already assigned to another customer.', "Card No.");
            ErrorInfo.DetailedMessage := 'Each loyalty card must have a unique card number. Please choose a different number or check if this card already exists.';
            ErrorInfo.AddAction('View Existing Card', Codeunit::"BRC Loyalty Management", 'ShowCardDetails');
            Error(ErrorInfo);
        end;
    end;
    
    /// <summary>
    /// Validates that the customer exists in the system
    /// </summary>
    local procedure ValidateCustomerExists()
    var
        Customer: Record Customer;
    begin
        if "Customer No." = '' then
            exit;
            
        if not Customer.Get("Customer No.") then
            Error('Customer %1 does not exist. Please verify the customer number and try again.', "Customer No.");
            
        if Customer.Blocked <> Customer.Blocked::" " then
            Error('Customer %1 is blocked and cannot have loyalty cards assigned.', "Customer No.");
    end;
    
    /// <summary>
    /// Updates the customer name field from the customer record
    /// </summary>
    local procedure UpdateCustomerName()
    var
        Customer: Record Customer;
    begin
        if Customer.Get("Customer No.") then
            "Customer Name" := Customer.Name
        else
            "Customer Name" := '';
    end;
    
    /// <summary>
    /// Checks if the loyalty card can be safely deleted
    /// </summary>
    local procedure CheckCardCanBeDeleted()
    var
        LoyaltyTransaction: Record "BRC Loyalty Transaction";
    begin
        LoyaltyTransaction.SetRange("Card No.", "Card No.");
        if not LoyaltyTransaction.IsEmpty then
            Error('Cannot delete loyalty card %1 because it has transaction history.', "Card No.");
    end;
}
```

## Page Example with AppSource Compliance

```al
page 50100 "BRC Customer Loyalty Card"
{
    PageType = Card;
    SourceTable = "BRC Customer Loyalty Card";
    Caption = 'Customer Loyalty Card';
    ApplicationArea = All;
    UsageCategory = Documents;
    
    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                
                field("Card No."; Rec."Card No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier for the loyalty card.';
                    ShowMandatory = true;
                }
                
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer who owns this loyalty card.';
                    ShowMandatory = true;
                }
                
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the name of the customer who owns this loyalty card.';
                }
                
                field("Card Status"; Rec."Card Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the loyalty card is active, suspended, or expired.';
                }
            }
            
            group(PointsInformation)
            {
                Caption = 'Points Information';
                
                field("Points Balance"; Rec."Points Balance")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the current points balance on the loyalty card.';
                    Style = Strong;
                    StyleExpr = Rec."Points Balance" > 1000;
                }
                
                field("Issue Date"; Rec."Issue Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when the loyalty card was issued.';
                }
                
                field("Expiry Date"; Rec."Expiry Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the loyalty card expires.';
                }
            }
        }
    }
    
    actions
    {
        area(Processing)
        {
            action(AddPoints)
            {
                ApplicationArea = All;
                Caption = 'Add Points';
                ToolTip = 'Add loyalty points to this customer''s account.';
                Image = Add;
                
                trigger OnAction()
                var
                    LoyaltyMgmt: Codeunit "BRC Loyalty Management";
                begin
                    LoyaltyMgmt.AddPointsDialog(Rec);
                end;
            }
            
            action(ViewTransactions)
            {
                ApplicationArea = All;
                Caption = 'View Transactions';
                ToolTip = 'View the transaction history for this loyalty card.';
                Image = Entries;
                
                trigger OnAction()
                var
                    LoyaltyTransaction: Record "BRC Loyalty Transaction";
                begin
                    LoyaltyTransaction.SetRange("Card No.", Rec."Card No.");
                    Page.Run(Page::"BRC Loyalty Transactions", LoyaltyTransaction);
                end;
            }
        }
    }
}
```

## Permission Set Examples

```al
// Comprehensive permission set for loyalty management
permissionset 50100 "BRC LOYALTY FULL"
{
    Caption = 'Customer Loyalty - Full Access';
    Assignable = true;
    
    Permissions = 
        // Table Data Permissions
        tabledata "BRC Customer Loyalty Card" = RIMD,
        tabledata "BRC Loyalty Transaction" = RIMD,
        tabledata "BRC Loyalty Program" = RIMD,
        
        // Object Permissions
        table "BRC Customer Loyalty Card" = X,
        table "BRC Loyalty Transaction" = X,
        table "BRC Loyalty Program" = X,
        page "BRC Customer Loyalty Card" = X,
        page "BRC Customer Loyalty List" = X,
        page "BRC Loyalty Transactions" = X,
        page "BRC Loyalty Programs" = X,
        codeunit "BRC Loyalty Management" = X,
        codeunit "BRC Points Calculator" = X,
        report "BRC Loyalty Points Report" = X;
}

// Limited permission set for read-only access
permissionset 50101 "BRC LOYALTY VIEW"
{
    Caption = 'Customer Loyalty - View Only';
    Assignable = true;
    
    Permissions = 
        // Table Data Permissions (Read only)
        tabledata "BRC Customer Loyalty Card" = R,
        tabledata "BRC Loyalty Transaction" = R,
        tabledata "BRC Loyalty Program" = R,
        
        // Object Permissions
        table "BRC Customer Loyalty Card" = X,
        table "BRC Loyalty Transaction" = X,
        table "BRC Loyalty Program" = X,
        page "BRC Customer Loyalty List" = X,
        page "BRC Loyalty Transactions" = X,
        report "BRC Loyalty Points Report" = X;
}
```

## Error Handling Examples

```al
// Advanced error handling with ErrorInfo
codeunit 50100 "BRC Loyalty Management"
{
    /// <summary>
    /// Adds points to a customer's loyalty card with comprehensive validation
    /// </summary>
    /// <param name="CardNo">The loyalty card number</param>
    /// <param name="PointsToAdd">Number of points to add</param>
    /// <param name="TransactionType">Type of transaction for audit trail</param>
    procedure AddPoints(CardNo: Code[20]; PointsToAdd: Integer; TransactionType: Text[50])
    var
        LoyaltyCard: Record "BRC Customer Loyalty Card";
        ErrorInfo: ErrorInfo;
    begin
        // Validate parameters
        if CardNo = '' then begin
            ErrorInfo.Title := 'Missing Card Number';
            ErrorInfo.Message := 'A loyalty card number must be specified.';
            ErrorInfo.DetailedMessage := 'To add points, please specify which loyalty card should receive the points.';
            Error(ErrorInfo);
        end;
        
        if PointsToAdd <= 0 then begin
            ErrorInfo.Title := 'Invalid Points Amount';
            ErrorInfo.Message := StrSubstNo('Points to add must be greater than zero. You entered: %1', PointsToAdd);
            ErrorInfo.DetailedMessage := 'Points must be a positive number. To deduct points, use the DeductPoints procedure instead.';
            ErrorInfo.AddAction('Deduct Points', Codeunit::"BRC Loyalty Management", 'DeductPointsDialog');
            Error(ErrorInfo);
        end;
        
        // Get and validate loyalty card
        if not LoyaltyCard.Get(CardNo) then begin
            ErrorInfo.Title := 'Loyalty Card Not Found';
            ErrorInfo.Message := StrSubstNo('Loyalty card %1 does not exist.', CardNo);
            ErrorInfo.DetailedMessage := 'Please verify the card number and try again. You can search for existing cards using the loyalty card list.';
            ErrorInfo.AddAction('Open Card List', Page::"BRC Customer Loyalty List");
            Error(ErrorInfo);
        end;
        
        // Validate card status
        if LoyaltyCard."Card Status" <> LoyaltyCard."Card Status"::Active then begin
            ErrorInfo.Title := 'Card Not Active';
            ErrorInfo.Message := StrSubstNo('Loyalty card %1 is %2 and cannot receive points.', CardNo, LoyaltyCard."Card Status");
            ErrorInfo.DetailedMessage := 'Only active loyalty cards can receive points. Please activate the card first or contact customer service.';
            ErrorInfo.AddAction('View Card Details', Page::"BRC Customer Loyalty Card", LoyaltyCard.RecordId);
            Error(ErrorInfo);
        end;
        
        // Check expiry date
        if (LoyaltyCard."Expiry Date" <> 0D) and (LoyaltyCard."Expiry Date" < Today) then begin
            ErrorInfo.Title := 'Card Expired';
            ErrorInfo.Message := StrSubstNo('Loyalty card %1 expired on %2.', CardNo, LoyaltyCard."Expiry Date");
            ErrorInfo.DetailedMessage := 'Expired cards cannot receive points. Please renew the card or issue a new one.';
            Error(ErrorInfo);
        end;
        
        // Add points and create transaction record
        LoyaltyCard."Points Balance" += PointsToAdd;
        LoyaltyCard.Modify(true);
        
        CreateLoyaltyTransaction(CardNo, PointsToAdd, TransactionType);
        
        Message('Successfully added %1 points to card %2. New balance: %3 points.', 
                PointsToAdd, CardNo, LoyaltyCard."Points Balance");
    end;
}
```
