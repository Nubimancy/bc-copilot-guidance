# Prefix Naming Guidelines - Code Samples

## AppSourceCop.json Configuration

```json
// Correct AppSourceCop.json configuration
{
  "mandatoryPrefix": "ABC",
  "supportedCountries": ["US", "CA", "GB"],
  "publisher": "ABC Solutions Inc.",
  "name": "ABC Customer Management"
}
```

## Table Prefix Examples

```al
// Correct prefix implementation
table 50000 "ABC Customer Rating"
{
    fields
    {
        field(1; "Customer No."; Code[20]) { }
        field(2; "Rating Value"; Integer) { }
    }
}

// Multiple tables with consistent prefix
table 50001 "ABC Sales Configuration"
{
    fields
    {
        field(1; "Configuration Code"; Code[20]) { }
        field(2; "Description"; Text[100]) { }
    }
}

table 50002 "ABC Product Category"
{
    fields
    {
        field(1; "Category Code"; Code[20]) { }
        field(2; "Category Name"; Text[50]) { }
    }
}
```

## Page Prefix Examples

```al
// List page with correct prefix
page 50000 "ABC Customer Ratings"
{
    PageType = List;
    SourceTable = "ABC Customer Rating";
    ApplicationArea = All;
    UsageCategory = Lists;
    
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Customer No."; Rec."Customer No.") { }
                field("Rating Value"; Rec."Rating Value") { }
            }
        }
    }
}

// Card page with correct prefix
page 50001 "ABC Customer Rating Card"
{
    PageType = Card;
    SourceTable = "ABC Customer Rating";
    
    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Customer No."; Rec."Customer No.") { }
                field("Rating Value"; Rec."Rating Value") { }
            }
        }
    }
}
```

## Codeunit Prefix Examples

```al
// Management codeunit with correct prefix
codeunit 50000 "ABC Customer Management"
{
    procedure ValidateCustomerRating(CustomerNo: Code[20]) Result: Boolean
    var
        CustomerRating: Record "ABC Customer Rating";
    begin
        CustomerRating.SetRange("Customer No.", CustomerNo);
        Result := CustomerRating.FindFirst();
    end;
    
    procedure CreateCustomerRating(CustomerNo: Code[20]; RatingValue: Integer)
    var
        CustomerRating: Record "ABC Customer Rating";
    begin
        CustomerRating."Customer No." := CustomerNo;
        CustomerRating."Rating Value" := RatingValue;
        CustomerRating.Insert(true);
    end;
}

// Event subscriber with correct prefix
codeunit 50001 "ABC Customer Event Subscribers"
{
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertCustomer(var Rec: Record Customer)
    var
        ABCCustomerMgt: Codeunit "ABC Customer Management";
    begin
        // Initialize default rating for new customers
        ABCCustomerMgt.CreateCustomerRating(Rec."No.", 0);
    end;
}
```

## Report Prefix Examples

```al
// Report with correct prefix
report 50000 "ABC Customer Rating Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ABCCustomerRating.rdlc';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    
    dataset
    {
        dataitem(Customer; Customer)
        {
            column(No_; "No.") { }
            column(Name; Name) { }
            
            dataitem("ABC Customer Rating"; "ABC Customer Rating")
            {
                DataItemLink = "Customer No." = field("No.");
                column(Rating_Value; "Rating Value") { }
            }
        }
    }
}
```

## Enum Prefix Examples

```al
// Enum with correct prefix
enum 50000 "ABC Rating Status"
{
    Extensible = true;
    
    value(0; " ") { Caption = ' '; }
    value(1; "Not Rated") { Caption = 'Not Rated'; }
    value(2; "Poor") { Caption = 'Poor'; }
    value(3; "Good") { Caption = 'Good'; }
    value(4; "Excellent") { Caption = 'Excellent'; }
}
```

## Interface Prefix Examples

```al
// Interface with correct prefix
interface "ABC Rating Calculator"
{
    procedure CalculateRating(CustomerNo: Code[20]) Rating: Integer;
    procedure GetRatingDescription(Rating: Integer) Description: Text[100];
}

// Implementation with correct prefix
codeunit 50010 "ABC Standard Rating Calculator" implements "ABC Rating Calculator"
{
    procedure CalculateRating(CustomerNo: Code[20]) Rating: Integer
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
    begin
        // Implementation logic
        Rating := 3; // Default good rating
    end;
    
    procedure GetRatingDescription(Rating: Integer) Description: Text[100]
    begin
        case Rating of
            1: Description := 'Poor Customer';
            2: Description := 'Average Customer';
            3: Description := 'Good Customer';
            4: Description := 'Excellent Customer';
        end;
    end;
}
```

## Complete Extension Example

```al
// app.json configuration
{
  "id": "12345678-1234-1234-1234-123456789abc",
  "name": "ABC Customer Management",
  "publisher": "ABC Solutions Inc.",
  "version": "1.0.0.0",
  "brief": "Customer rating and management system",
  "description": "Advanced customer rating system with analytics",
  "privacyStatement": "https://abc-solutions.com/privacy",
  "EULA": "https://abc-solutions.com/eula",
  "help": "https://abc-solutions.com/help",
  "url": "https://abc-solutions.com",
  "logo": "logo.png",
  "dependencies": [],
  "screenshots": [],
  "platform": "18.0.0.0",
  "application": "18.0.0.0",
  "idRanges": [
    {
      "from": 50000,
      "to": 50100
    }
  ]
}

// All objects consistently prefixed
table 50000 "ABC Customer Rating"          // ✓ Correct
page 50000 "ABC Customer Ratings"          // ✓ Correct  
codeunit 50000 "ABC Customer Management"   // ✓ Correct
report 50000 "ABC Customer Rating Report"  // ✓ Correct
```
