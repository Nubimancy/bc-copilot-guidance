# Code Documentation Standards - Code Samples

## XML Procedure Documentation Examples

```al
/// <summary>
/// Calculates the total amount for a sales document including tax and discounts.
/// </summary>
/// <param name="DocumentType">The type of the sales document (Quote, Order, Invoice).</param>
/// <param name="DocumentNo">The unique number of the sales document.</param>
/// <returns>The total amount of the sales document in local currency.</returns>
procedure CalculateTotalAmount(DocumentType: Enum "Sales Document Type"; DocumentNo: Code[20]): Decimal
var
    SalesHeader: Record "Sales Header";
    SalesLine: Record "Sales Line";
    TotalAmount: Decimal;
begin
    if not SalesHeader.Get(DocumentType, DocumentNo) then
        exit(0);
    
    SalesLine.SetRange("Document Type", DocumentType);
    SalesLine.SetRange("Document No.", DocumentNo);
    SalesLine.CalcSums("Amount Including VAT");
    
    exit(SalesLine."Amount Including VAT");
end;

/// <summary>
/// Validates customer credit limit before processing a sales order.
/// Checks both the credit limit and current outstanding balance.
/// </summary>
/// <param name="Customer">The customer record to validate.</param>
/// <param name="OrderAmount">The amount of the new sales order.</param>
/// <returns>True if the customer is within credit limit, false otherwise.</returns>
procedure ValidateCreditLimit(var Customer: Record Customer; OrderAmount: Decimal): Boolean
var
    OutstandingAmount: Decimal;
begin
    if Customer."Credit Limit (LCY)" = 0 then
        exit(true); // No credit limit set
    
    Customer.CalcFields("Balance (LCY)");
    OutstandingAmount := Customer."Balance (LCY)" + OrderAmount;
    
    exit(OutstandingAmount <= Customer."Credit Limit (LCY)");
end;
```

## Tooltip Examples for Fields

```al
// Table field tooltips
table 50100 "ABC Customer Rating"
{
    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            ToolTip = 'Specifies the customer number that this rating applies to.';
        }
        
        field(2; "Rating Value"; Integer)
        {
            Caption = 'Rating Value';
            ToolTip = 'Specifies the rating value from 1 (poor) to 5 (excellent).';
            MinValue = 1;
            MaxValue = 5;
        }
        
        field(3; "Rating Date"; Date)
        {
            Caption = 'Rating Date';
            ToolTip = 'Specifies the date when this rating was assigned.';
        }
        
        field(4; "Is Active"; Boolean)
        {
            Caption = 'Is Active';
            ToolTip = 'Specifies whether this rating is currently active and should be used in calculations.';
        }
    }
}
```

## Page Control Tooltips

```al
// Page with proper tooltips for controls
page 50100 "ABC Customer Rating Card"
{
    PageType = Card;
    SourceTable = "ABC Customer Rating";
    
    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the customer that this rating record applies to.';
                }
                
                field("Rating Value"; Rec."Rating Value")
                {
                    ToolTip = 'Specifies the rating score from 1 (needs improvement) to 5 (outstanding performance).';
                }
                
                field("Rating Date"; Rec."Rating Date")
                {
                    ToolTip = 'Specifies when this customer rating was recorded or last updated.';
                }
            }
        }
    }
    
    actions
    {
        area(Processing)
        {
            action(RecalculateRating)
            {
                Caption = 'Recalculate Rating';
                ToolTip = 'Recalculates the customer rating based on recent transaction history and payment behavior.';
                
                trigger OnAction()
                begin
                    RecalculateCustomerRating();
                end;
            }
        }
    }
}
```

## Business Logic Comments

```al
// Complex business logic with explanatory comments
procedure ProcessCustomerUpgrade(var Customer: Record Customer; NewTier: Enum "Customer Tier")
var
    SalesHistory: Record "Sales Header";
    RequiredSalesAmount: Decimal;
begin
    // Validate upgrade eligibility based on sales history
    // Customer must have minimum sales volume in last 12 months
    SalesHistory.SetRange("Sell-to Customer No.", Customer."No.");
    SalesHistory.SetFilter("Document Date", '>=%1', CalcDate('<-1Y>', Today()));
    SalesHistory.CalcSums("Amount Including VAT");
    
    case NewTier of
        "Customer Tier"::Silver:
            RequiredSalesAmount := 50000; // $50K minimum for Silver
        "Customer Tier"::Gold:
            RequiredSalesAmount := 150000; // $150K minimum for Gold
        "Customer Tier"::Platinum:
            RequiredSalesAmount := 500000; // $500K minimum for Platinum
    end;
    
    if SalesHistory."Amount Including VAT" < RequiredSalesAmount then
        Error(InsufficientSalesErr, Customer."No.", NewTier, RequiredSalesAmount);
    
    // Apply tier-specific benefits
    // Silver: 5% discount, Gold: 10% discount, Platinum: 15% discount + free shipping
    UpdateCustomerDiscountPercentage(Customer, NewTier);
    
    if NewTier = "Customer Tier"::Platinum then
        Customer."Free Shipping" := true; // Platinum customers get free shipping
    
    Customer."Customer Tier" := NewTier;
    Customer."Tier Effective Date" := Today();
    Customer.Modify(true);
end;
```

## Error Documentation Patterns

```al
/// <summary>
/// Validates that a customer can be deleted safely.
/// Checks for dependent records that would prevent deletion.
/// </summary>
/// <param name="CustomerNo">The customer number to validate for deletion.</param>
/// <exception cref="Error">Thrown when customer has active transactions or outstanding balance.</exception>
procedure ValidateCustomerDeletion(CustomerNo: Code[20])
var
    Customer: Record Customer;
    SalesHeader: Record "Sales Header";
    CustLedgerEntry: Record "Cust. Ledger Entry";
    OutstandingAmount: Decimal;
begin
    if not Customer.Get(CustomerNo) then
        Error(CustomerNotFoundErr, CustomerNo);
    
    // Check for open sales documents
    SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
    SalesHeader.SetFilter("Document Type", '%1|%2', SalesHeader."Document Type"::Quote, SalesHeader."Document Type"::Order);
    if not SalesHeader.IsEmpty() then
        Error(CannotDeleteCustomerWithOpenOrdersErr, CustomerNo);
    
    // Check for outstanding balance
    Customer.CalcFields("Balance (LCY)");
    if Customer."Balance (LCY)" <> 0 then
        Error(CannotDeleteCustomerWithBalanceErr, CustomerNo, Customer."Balance (LCY)");
end;
```

## Configuration and Setup Comments

```al
/// <summary>
/// Initializes default settings for the ABC Customer Management module.
/// This procedure should be called once during setup to configure default values.
/// </summary>
procedure InitializeModuleDefaults()
var
    ABCSetup: Record "ABC Setup";
begin
    // Create setup record if it doesn't exist
    if not ABCSetup.Get() then begin
        ABCSetup.Init();
        ABCSetup."Default Rating Period" := 30; // Default to 30-day rating periods
        ABCSetup."Auto-Calculate Ratings" := true; // Enable automatic rating calculation
        ABCSetup."Minimum Order Amount" := 100; // $100 minimum for rating calculation
        ABCSetup."Rating Calculation Method" := ABCSetup."Rating Calculation Method"::"Sales Volume";
        ABCSetup.Insert(true);
    end;
    
    // Configure number series for customer ratings
    // This ensures proper sequential numbering for rating records
    InitializeRatingNumberSeries();
end;
```

## API and Integration Documentation

```al
/// <summary>
/// Web service endpoint for retrieving customer rating information.
/// Used by external systems to access current customer ratings.
/// </summary>
/// <param name="CustomerNo">The customer number to retrieve rating for.</param>
/// <returns>JSON structure containing rating details and metadata.</returns>
[ServiceEnabled]
procedure GetCustomerRating(CustomerNo: Code[20]): Text
var
    CustomerRating: Record "ABC Customer Rating";
    RatingJson: JsonObject;
begin
    if not CustomerRating.Get(CustomerNo) then
        Error(CustomerRatingNotFoundErr, CustomerNo);
    
    // Build JSON response with rating information
    RatingJson.Add('customerNo', CustomerNo);
    RatingJson.Add('ratingValue', CustomerRating."Rating Value");
    RatingJson.Add('ratingDate', CustomerRating."Rating Date");
    RatingJson.Add('isActive', CustomerRating."Is Active");
    RatingJson.Add('lastUpdated', CurrentDateTime());
    
    exit(Format(RatingJson));
end;
```
