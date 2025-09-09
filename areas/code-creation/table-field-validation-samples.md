---
title: "Table Field Validation - Code Samples"
description: "Complete code examples for implementing field-level validation in AL tables"
area: "code-creation"
difficulty: "intermediate"
object_types: ["Table"]
variable_types: ["Record", "Date"]
tags: ["table-validation", "samples", "field-validation", "data-validation"]
---

# Table Field Validation - Code Samples

## Customer Rating Table

Complete table implementation with field-level validation:

```al
table 50100 "BRC Customer Rating"
{
    Caption = 'Customer Rating';
    DataClassification = CustomerContent;
    LookupPageId = "BRC Customer Rating List";
    DrillDownPageId = "BRC Customer Rating List";

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
            end;
        }
        
        field(2; "Rating Score"; Integer)
        {
            Caption = 'Rating Score';
            ToolTip = 'Specifies the rating score from 1 to 5.';
            DataClassification = CustomerContent;
            MinValue = 1;
            MaxValue = 5;
        }
        
        field(3; "Rating Date"; Date)
        {
            Caption = 'Rating Date';
            ToolTip = 'Specifies when the rating was given.';
            DataClassification = CustomerContent;
            NotBlank = true;
            
            trigger OnValidate()
            begin
                ValidateRatingDate();
            end;
        }
        
        field(4; "Comments"; Text[250])
        {
            Caption = 'Comments';
            ToolTip = 'Specifies additional comments for the rating.';
            DataClassification = CustomerContent;
        }
    }
    
    keys
    {
        key(PK; "Customer No.", "Rating Date")
        {
            Clustered = true;
        }
        
        key(Rating; "Rating Score")
        {
            // For reporting and filtering by rating
        }
    }
    
    // Validation procedures
    local procedure ValidateCustomerExists()
    var
        Customer: Record Customer;
    begin
        if "Customer No." = '' then
            exit;
            
        if not Customer.Get("Customer No.") then
            Error('Customer %1 does not exist.', "Customer No.");
    end;
    
    local procedure ValidateRatingDate()
    begin
        if "Rating Date" > Today then
            Error('Rating date cannot be in the future.');
            
        if "Rating Date" < CalcDate('<-2Y>', Today) then
            Error('Rating date cannot be more than 2 years old.');
    end;
}
```

## Basic Field Validation Patterns

```al
table 50101 "Product Specification"
{
    fields
    {
        field(1; "Product Code"; Code[20])
        {
            Caption = 'Product Code';
            NotBlank = true;
            
            trigger OnValidate()
            begin
                ValidateProductCodeFormat();
            end;
        }
        
        field(2; "Weight (KG)"; Decimal)
        {
            Caption = 'Weight (KG)';
            MinValue = 0.01;
            MaxValue = 1000;
            DecimalPlaces = 2 : 2;
        }
        
        field(3; "Dimensions"; Text[50])
        {
            Caption = 'Dimensions';
            
            trigger OnValidate()
            begin
                ValidateDimensionsFormat();
            end;
        }
    }
    
    local procedure ValidateProductCodeFormat()
    begin
        if StrLen("Product Code") < 3 then
            Error('Product code must be at least 3 characters long.');
            
        if not (UpperCase(CopyStr("Product Code", 1, 1)) in ['A'..'Z']) then
            Error('Product code must start with a letter.');
    end;
    
    local procedure ValidateDimensionsFormat()
    var
        DimensionParts: List of [Text];
    begin
        if "Dimensions" = '' then
            exit;
            
        DimensionParts := "Dimensions".Split('x');
        if DimensionParts.Count <> 3 then
            Error('Dimensions must be in format: Length x Width x Height');
    end;
}
```

## Related Topics
- [Table Field Validation](table-field-validation.md)
- [Table Business Rules](table-business-rules.md)
- [Table Design Patterns](table-design-patterns.md)
