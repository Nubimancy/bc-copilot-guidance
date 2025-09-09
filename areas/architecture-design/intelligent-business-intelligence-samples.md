---
title: "Intelligent Business Intelligence - Samples"  
description: "Working AL code examples for implementing business intelligence patterns in Business Central applications"
area: "architecture-design"
difficulty: "advanced"
object_types: ["Query", "Codeunit", "Page", "Report"]
variable_types: ["DataSet", "Decimal", "DateTime", "Boolean", "JsonObject"]
tags: ["business-intelligence", "query-objects", "power-bi", "reporting", "data-analysis"]
---

# Intelligent Business Intelligence - Samples

## Query Object Examples

### Optimized Sales Analytics Query

```al
query 50100 "Sales Analytics Query"
{
    QueryType = Normal;
    OrderBy = ascending(Customer_No);
    
    elements
    {
        dataitem(Customer; Customer)
        {
            column(Customer_No; "No.")
            {
                Caption = 'Customer No.';
            }
            column(Customer_Name; Name)
            {
                Caption = 'Customer Name';
            }
            column(Customer_Posting_Group; "Customer Posting Group")
            {
                Caption = 'Customer Posting Group';
            }
            
            dataitem(Sales_Header; "Sales Header")
            {
                DataItemLink = "Sell-to Customer No." = Customer."No.";
                SqlJoinType = InnerJoin;
                
                column(Document_Type; "Document Type")
                {
                    Caption = 'Document Type';
                }
                column(Order_Date; "Order Date")
                {
                    Caption = 'Order Date';
                }
                column(Posting_Date; "Posting Date")
                {
                    Caption = 'Posting Date';
                }
                
                dataitem(Sales_Line; "Sales Line")
                {
                    DataItemLink = "Document Type" = Sales_Header."Document Type",
                                   "Document No." = Sales_Header."No.";
                    SqlJoinType = InnerJoin;
                    
                    column(Item_No; "No.")
                    {
                        Caption = 'Item No.';
                    }
                    column(Quantity; Quantity)
                    {
                        Caption = 'Quantity';
                        Method = Sum;
                    }
                    column(Unit_Price; "Unit Price")
                    {
                        Caption = 'Unit Price';
                    }
                    column(Line_Amount; "Line Amount")
                    {
                        Caption = 'Line Amount';
                        Method = Sum;
                    }
                    column(Sales_Count; "Line No.")
                    {
                        Caption = 'Number of Sales';
                        Method = Count;
                    }
                }
            }
        }
    }
    
    trigger OnBeforeOpen()
    begin
        // Add dynamic filtering based on user permissions
        SetFilter(Customer_No, GetCustomerFilter());
    end;
}
```

### Power BI Optimized Query

```al
query 50101 "Power BI Customer Sales"
{
    QueryType = API;
    APIPublisher = 'MyCompany';
    APIGroup = 'analytics';
    APIVersion = 'v1.0';
    EntityName = 'customerSales';
    EntitySetName = 'customerSales';
    
    elements
    {
        dataitem(Customer; Customer)
        {
            column(customerId; SystemId)
            {
                Caption = 'Customer ID';
            }
            column(customerNumber; "No.")
            {
                Caption = 'Customer Number';
            }
            column(customerName; Name)
            {
                Caption = 'Customer Name';  
            }
            column(customerPostingGroup; "Customer Posting Group")
            {
                Caption = 'Customer Posting Group';
            }
            column(paymentTermsCode; "Payment Terms Code")
            {
                Caption = 'Payment Terms';
            }
            column(salesPersonCode; "Salesperson Code")  
            {
                Caption = 'Salesperson';
            }
            
            dataitem(CustLedgerEntry; "Cust. Ledger Entry")
            {
                DataItemLink = "Customer No." = Customer."No.";
                SqlJoinType = LeftOuterJoin;
                
                column(entryNo; "Entry No.")
                {
                    Caption = 'Entry No.';
                }
                column(postingDate; "Posting Date")
                {
                    Caption = 'Posting Date';
                }
                column(documentType; "Document Type")
                {
                    Caption = 'Document Type';
                }
                column(documentNo; "Document No.")
                {
                    Caption = 'Document No.';
                }
                column(salesAmount; "Sales (LCY)")
                {
                    Caption = 'Sales Amount';
                    Method = Sum;
                }
                column(remainingAmount; "Remaining Amount")
                {
                    Caption = 'Outstanding Amount';
                    Method = Sum;
                }
            }
        }
    }
}
```

## Report Dataset Examples

### Advanced Sales Report with Calculations

```al
report 50100 "Advanced Sales Analytics"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Reports/AdvancedSalesAnalytics.rdl';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    
    dataset
    {
        dataitem(Customer; Customer)
        {
            RequestFilterFields = "No.", "Customer Posting Group", "Salesperson Code";
            
            column(Customer_No; "No.")
            {
                IncludeCaption = true;
            }
            column(Customer_Name; Name)
            {
                IncludeCaption = true;
            }
            column(Customer_PostingGroup; "Customer Posting Group")
            {
                IncludeCaption = true;
            }
            
            // Calculated fields for better performance
            column(TotalSales; TotalSalesAmount)
            {
                AutoCalcField = false; // Calculate in AL code
            }
            column(AvgOrderValue; AvgOrderValue)
            {
                AutoCalcField = false;
            }
            column(OrderCount; OrderCount)
            {
                AutoCalcField = false;
            }
            column(LastOrderDate; LastOrderDate)
            {
                AutoCalcField = false;
            }
            
            trigger OnAfterGetRecord()
            begin
                // Calculate analytics in AL for better performance
                CalculateCustomerAnalytics(Customer."No.");
            end;
        }
        
        dataitem(SalesAnalytics; "Integer")
        {
            DataItemTableView = sorting(Number) where(Number = filter(1..12)); // 12 months
            
            column(MonthNumber; Number)
            {
            }
            column(MonthName; MonthNames[Number])
            {
            }
            column(MonthlySales; MonthlySalesArray[Number])
            {
            }
            column(MonthlyOrderCount; MonthlyOrderArray[Number])
            {
            }
            
            trigger OnAfterGetRecord()
            begin
                // Calculate monthly metrics
                CalculateMonthlyMetrics(Customer."No.", Number);
            end;
        }
    }
    
    var
        TotalSalesAmount: Decimal;
        AvgOrderValue: Decimal;
        OrderCount: Integer;
        LastOrderDate: Date;
        MonthNames: array[12] of Text[20];
        MonthlySalesArray: array[12] of Decimal;
        MonthlyOrderArray: array[12] of Integer;
    
    trigger OnPreReport()
    begin
        InitializeMonthNames();
    end;
    
    local procedure CalculateCustomerAnalytics(CustomerNo: Code[20])
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        // Reset calculations
        TotalSalesAmount := 0;
        OrderCount := 0;
        LastOrderDate := 0D;
        
        // Efficient calculation using filtered record set
        CustLedgerEntry.SetRange("Customer No.", CustomerNo);
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetLoadFields("Sales (LCY)", "Posting Date");
        
        if CustLedgerEntry.FindSet() then
            repeat
                TotalSalesAmount += CustLedgerEntry."Sales (LCY)";
                OrderCount += 1;
                if CustLedgerEntry."Posting Date" > LastOrderDate then
                    LastOrderDate := CustLedgerEntry."Posting Date";
            until CustLedgerEntry.Next() = 0;
            
        // Calculate average
        if OrderCount > 0 then
            AvgOrderValue := TotalSalesAmount / OrderCount
        else
            AvgOrderValue := 0;
    end;
    
    local procedure CalculateMonthlyMetrics(CustomerNo: Code[20]; MonthNo: Integer)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        StartDate, EndDate: Date;
    begin
        // Calculate date range for month
        StartDate := DMY2Date(1, MonthNo, Date2DMY(WorkDate(), 3));
        EndDate := CalcDate('<+1M-1D>', StartDate);
        
        // Reset monthly values
        MonthlySalesArray[MonthNo] := 0;
        MonthlyOrderArray[MonthNo] := 0;
        
        CustLedgerEntry.SetRange("Customer No.", CustomerNo);
        CustLedgerEntry.SetRange("Posting Date", StartDate, EndDate);
        CustLedgerEntry.SetLoadFields("Sales (LCY)");
        
        if CustLedgerEntry.FindSet() then
            repeat
                MonthlySalesArray[MonthNo] += CustLedgerEntry."Sales (LCY)";
                MonthlyOrderArray[MonthNo] += 1;
            until CustLedgerEntry.Next() = 0;
    end;
    
    local procedure InitializeMonthNames()
    begin
        MonthNames[1] := 'January';
        MonthNames[2] := 'February';
        MonthNames[3] := 'March';
        MonthNames[4] := 'April';
        MonthNames[5] := 'May';
        MonthNames[6] := 'June';
        MonthNames[7] := 'July';
        MonthNames[8] := 'August';
        MonthNames[9] := 'September';
        MonthNames[10] := 'October';
        MonthNames[11] := 'November';
        MonthNames[12] := 'December';
    end;
}
```

## Role Center Analytics Integration

### KPI Dashboard Part

```al
page 50100 "Sales KPI Dashboard"
{
    PageType = CardPart;
    SourceTable = "Cue Setup";
    RefreshOnActivate = true;
    
    layout
    {
        area(content)
        {
            cuegroup("Sales Performance")
            {
                field("Today Sales"; TodaySales)
                {
                    ApplicationArea = All;
                    Caption = 'Today''s Sales';
                    StyleExpr = TodaySalesStyle;
                    
                    trigger OnDrillDown()
                    begin
                        DrillDownTodaySales();
                    end;
                }
                
                field("Month Sales"; MonthSales)
                {
                    ApplicationArea = All;
                    Caption = 'This Month Sales';
                    StyleExpr = MonthSalesStyle;
                }
                
                field("Open Orders"; OpenOrders)
                {
                    ApplicationArea = All;
                    Caption = 'Open Sales Orders';
                    StyleExpr = OpenOrdersStyle;
                }
                
                field("Overdue Orders"; OverdueOrders)
                {
                    ApplicationArea = All;
                    Caption = 'Overdue Orders';
                    StyleExpr = OverdueOrdersStyle;
                }
            }
        }
    }
    
    var
        TodaySales: Decimal;
        MonthSales: Decimal;
        OpenOrders: Integer;
        OverdueOrders: Integer;
        TodaySalesStyle: Text;
        MonthSalesStyle: Text;
        OpenOrdersStyle: Text;
        OverdueOrdersStyle: Text;
    
    trigger OnOpenPage()
    begin
        RefreshKPIData();
    end;
    
    trigger OnAfterGetCurrRecord()
    begin
        RefreshKPIData();
    end;
    
    local procedure RefreshKPIData()
    begin
        CalculateTodaySales();
        CalculateMonthSales();
        CalculateOpenOrders();
        CalculateOverdueOrders();
        SetStyles();
    end;
    
    local procedure CalculateTodaySales()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Posting Date", WorkDate());
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetLoadFields("Sales (LCY)");
        
        TodaySales := 0;
        if CustLedgerEntry.FindSet() then
            repeat
                TodaySales += CustLedgerEntry."Sales (LCY)";
            until CustLedgerEntry.Next() = 0;
    end;
    
    local procedure CalculateMonthSales()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        StartOfMonth: Date;
    begin
        StartOfMonth := CalcDate('<-CM>', WorkDate());
        
        CustLedgerEntry.SetRange("Posting Date", StartOfMonth, WorkDate());
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetLoadFields("Sales (LCY)");
        
        MonthSales := 0;
        if CustLedgerEntry.FindSet() then
            repeat
                MonthSales += CustLedgerEntry."Sales (LCY)";
            until CustLedgerEntry.Next() = 0;
    end;
    
    local procedure CalculateOpenOrders()
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange(Status, SalesHeader.Status::Released);
        OpenOrders := SalesHeader.Count();
    end;
    
    local procedure CalculateOverdueOrders()
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetFilter("Shipment Date", '<%1', WorkDate());
        SalesHeader.SetRange(Status, SalesHeader.Status::Released);
        OverdueOrders := SalesHeader.Count();
    end;
    
    local procedure SetStyles()
    begin
        // Style based on performance thresholds
        if TodaySales > 10000 then
            TodaySalesStyle := 'Favorable'
        else if TodaySales > 5000 then
            TodaySalesStyle := 'Ambiguous'
        else
            TodaySalesStyle := 'Unfavorable';
            
        if OverdueOrders = 0 then
            OverdueOrdersStyle := 'Favorable'
        else if OverdueOrders <= 5 then
            OverdueOrdersStyle := 'Ambiguous'
        else
            OverdueOrdersStyle := 'Unfavorable';
    end;
    
    local procedure DrillDownTodaySales()
    var
        CustLedgerEntries: Page "Customer Ledger Entries";
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Posting Date", WorkDate());
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntries.SetTableView(CustLedgerEntry);
        CustLedgerEntries.Run();
    end;
}
```

## Power BI Integration Examples

### OData Page for Power BI

```al
page 50101 "Power BI Sales Data"
{
    PageType = API;
    APIPublisher = 'MyCompany';
    APIGroup = 'analytics';
    APIVersion = 'v1.0';
    EntityName = 'salesData';
    EntitySetName = 'salesData';
    SourceTable = "Cust. Ledger Entry";
    DelayedInsert = true;
    ODataKeyFields = SystemId;
    
    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'ID';
                }
                field(customerNumber; Rec."Customer No.")
                {
                    Caption = 'Customer No.';
                }
                field(customerName; CustomerName)
                {
                    Caption = 'Customer Name';
                }
                field(documentType; Rec."Document Type")
                {
                    Caption = 'Document Type';
                }
                field(documentNumber; Rec."Document No.")
                {
                    Caption = 'Document No.';
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date';
                }
                field(salesAmount; Rec."Sales (LCY)")
                {
                    Caption = 'Sales Amount';
                }
                field(remainingAmount; Rec."Remaining Amount")
                {
                    Caption = 'Remaining Amount';
                }
                field(salespersonCode; SalespersonCode)
                {
                    Caption = 'Salesperson';
                }
                field(customerPostingGroup; CustomerPostingGroup)
                {
                    Caption = 'Customer Posting Group';
                }
                field(lastModified; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified';
                }
            }
        }
    }
    
    var
        CustomerName: Text[100];
        SalespersonCode: Code[20];
        CustomerPostingGroup: Code[20];
    
    trigger OnAfterGetRecord()
    var
        Customer: Record Customer;
    begin
        // Enrich data with related information
        if Customer.Get(Rec."Customer No.") then begin
            CustomerName := Customer.Name;
            SalespersonCode := Customer."Salesperson Code";
            CustomerPostingGroup := Customer."Customer Posting Group";
        end;
    end;
}
```

## Analytics Codeunit Helper

### Data Processing Utilities

```al
codeunit 50100 "Analytics Helper"
{
    procedure CalculateCustomerTrends(CustomerNo: Code[20]): JsonObject
    var
        TrendData: JsonObject;
        SalesData: JsonArray;
        MonthlyData: JsonObject;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        i: Integer;
    begin
        // Calculate 12-month sales trend
        for i := -11 to 0 do begin
            MonthlyData := CalculateMonthlyData(CustomerNo, i);
            SalesData.Add(MonthlyData);
        end;
        
        TrendData.Add('customerNo', CustomerNo);
        TrendData.Add('monthlySales', SalesData);
        TrendData.Add('calculatedAt', CurrentDateTime);
        
        exit(TrendData);
    end;
    
    local procedure CalculateMonthlyData(CustomerNo: Code[20]; MonthOffset: Integer): JsonObject
    var
        MonthData: JsonObject;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        StartDate, EndDate: Date;
        TotalSales: Decimal;
        OrderCount: Integer;
    begin
        // Calculate month boundaries
        StartDate := CalcDate('<' + Format(MonthOffset) + 'M+CM-CM>', WorkDate());
        EndDate := CalcDate('<' + Format(MonthOffset) + 'M+CM>', WorkDate());
        
        CustLedgerEntry.SetRange("Customer No.", CustomerNo);
        CustLedgerEntry.SetRange("Posting Date", StartDate, EndDate);
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetLoadFields("Sales (LCY)");
        
        if CustLedgerEntry.FindSet() then
            repeat
                TotalSales += CustLedgerEntry."Sales (LCY)";
                OrderCount += 1;
            until CustLedgerEntry.Next() = 0;
        
        MonthData.Add('month', Format(StartDate, 0, '<Year4>-<Month,2>'));
        MonthData.Add('sales', TotalSales);
        MonthData.Add('orderCount', OrderCount);
        
        exit(MonthData);
    end;
    
    procedure ExportAnalyticsToJSON(var TempBlob: Codeunit "Temp Blob"; CustomerFilter: Text)
    var
        Customer: Record Customer;
        JSONWriter: JsonObject;
        CustomersArray: JsonArray;
        CustomerData: JsonObject;
    begin
        Customer.SetFilter("No.", CustomerFilter);
        Customer.SetLoadFields("No.", Name, "Customer Posting Group");
        
        if Customer.FindSet() then
            repeat
                CustomerData := CreateCustomerAnalyticsJSON(Customer);
                CustomersArray.Add(CustomerData);
            until Customer.Next() = 0;
        
        JSONWriter.Add('customers', CustomersArray);
        JSONWriter.Add('generatedAt', CurrentDateTime);
        
        // Write to TempBlob for export
        WriteJSONToBlob(JSONWriter, TempBlob);
    end;
    
    local procedure CreateCustomerAnalyticsJSON(Customer: Record Customer): JsonObject
    var
        CustomerJSON: JsonObject;
        TrendData: JsonObject;
    begin
        CustomerJSON.Add('customerNo', Customer."No.");
        CustomerJSON.Add('name', Customer.Name);
        CustomerJSON.Add('postingGroup', Customer."Customer Posting Group");
        
        TrendData := CalculateCustomerTrends(Customer."No.");
        CustomerJSON.Add('trends', TrendData);
        
        exit(CustomerJSON);
    end;
}
```