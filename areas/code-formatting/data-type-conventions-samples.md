# Data Type Conventions - Code Samples

## Enum Creation Examples

```al
// Standard enum with extensibility
enum 50100 "Document Status"
{
    Extensible = true;

    value(0; Open) { Caption = 'Open'; }
    value(1; "Pending Approval") { Caption = 'Pending Approval'; }
    value(2; Approved) { Caption = 'Approved'; }
    value(3; Rejected) { Caption = 'Rejected'; }
}

// Enum with blank option for optional fields
enum 50101 "Payment Method"
{
    Extensible = true;

    value(0; " ") { Caption = ' '; }  // Blank value for optional usage
    value(1; Cash) { Caption = 'Cash'; }
    value(2; "Credit Card") { Caption = 'Credit Card'; }
    value(3; "Bank Transfer") { Caption = 'Bank Transfer'; }
    value(4; Check) { Caption = 'Check'; }
}

// Priority enum with logical ordering
enum 50102 "Task Priority"
{
    Extensible = true;
    
    value(0; " ") { Caption = ' '; }
    value(1; Low) { Caption = 'Low'; }
    value(2; Medium) { Caption = 'Medium'; }
    value(3; High) { Caption = 'High'; }
    value(4; Critical) { Caption = 'Critical'; }
}
```

## Enum Usage in Tables

```al
// Using enums in table definitions
table 50100 "ABC Document Header"
{
    fields
    {
        field(1; "Document No."; Code[20]) { }
        field(2; "Document Status"; Enum "Document Status") { }
        field(3; "Payment Method"; Enum "Payment Method") { }
        field(4; "Priority"; Enum "Task Priority") { }
    }
}
```

## Variable Declaration with Enums

```al
// Correct enum variable usage
procedure ProcessDocument()
var
    DocumentStatus: Enum "Document Status";
    PaymentMethod: Enum "Payment Method";
    TaskPriority: Enum "Task Priority";
    DocHeader: Record "ABC Document Header";
begin
    DocumentStatus := "Document Status"::Open;
    DocHeader."Document Status" := DocumentStatus;
    
    if DocHeader."Payment Method" = "Payment Method"::Cash then
        ProcessCashPayment();
end;
```

## Option Type - Acceptable Exception Cases

```al
// Exception 1: Calling existing procedures that use option parameters
procedure NavigateRecords()
var
    Customer: Record Customer;
    Direction: Option Forward,Backward;
begin
    // Acceptable when calling standard BC procedures
    Customer.Next(Direction::Forward);
end;

// Exception 2: Event subscribers with option parameters  
[EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
local procedure OnBeforePostSalesDoc(
    var SalesHeader: Record "Sales Header"; 
    CommitIsSuppressed: Boolean; 
    PreviewMode: Boolean; 
    var HideProgressWindow: Boolean; 
    var IsHandled: Boolean; 
    var DefaultOption: Option " ",Ship,Invoice,"Ship and Invoice")
begin
    // Event handler code - option parameter required by event signature
    if DefaultOption = DefaultOption::"Ship and Invoice" then
        // Handle combined shipping and invoicing
        exit;
end;
```

## Option to Enum Conversion Pattern

```al
// Migration utility for converting option data to enums
procedure ConvertOptionToEnum(OptionValue: Integer): Enum "Document Status"
begin
    case OptionValue of
        0: exit("Document Status"::" ");
        1: exit("Document Status"::Open);
        2: exit("Document Status"::"Pending Approval");
        3: exit("Document Status"::Approved);
        4: exit("Document Status"::Rejected);
    end;
end;

// Data migration procedure
procedure MigrateDocumentStatusData()
var
    DocHeader: Record "ABC Document Header";
    OldOptionValue: Integer;
begin
    if DocHeader.FindSet(true) then
        repeat
            // Assume OldOptionValue comes from legacy option field
            // OldOptionValue := DocHeader."Old Status Option";
            DocHeader."Document Status" := ConvertOptionToEnum(OldOptionValue);
            DocHeader.Modify();
        until DocHeader.Next() = 0;
end;
```

## Complex Enum Scenarios

```al
// Enum with business logic integration
enum 50103 "Approval Workflow Status"
{
    Extensible = true;
    
    value(0; " ") { Caption = ' '; }
    value(10; "Pending Approval") { Caption = 'Pending Approval'; }
    value(20; "In Review") { Caption = 'In Review'; }
    value(30; "Approved") { Caption = 'Approved'; }
    value(40; "Rejected") { Caption = 'Rejected'; }
    value(50; "On Hold") { Caption = 'On Hold'; }
}

// Using enum in business logic
procedure ValidateStatusTransition(FromStatus: Enum "Approval Workflow Status"; ToStatus: Enum "Approval Workflow Status"): Boolean
begin
    case FromStatus of
        "Approval Workflow Status"::"Pending Approval":
            exit(ToStatus in ["Approval Workflow Status"::"In Review", "Approval Workflow Status"::Rejected]);
        "Approval Workflow Status"::"In Review":
            exit(ToStatus in ["Approval Workflow Status"::Approved, "Approval Workflow Status"::Rejected, "Approval Workflow Status"::"On Hold"]);
        "Approval Workflow Status"::"On Hold":
            exit(ToStatus in ["Approval Workflow Status"::"In Review", "Approval Workflow Status"::Rejected]);
        else
            exit(false);
    end;
end;
```

## Enum Extension Pattern

```al
// Extending existing enum in another extension
enumextension 50100 "Extended Payment Method" extends "Payment Method"
{
    value(50; "Digital Wallet") { Caption = 'Digital Wallet'; }
    value(51; "Cryptocurrency") { Caption = 'Cryptocurrency'; }
    value(52; "Bank Draft") { Caption = 'Bank Draft'; }
}

// Using extended enum values
procedure ProcessExtendedPaymentMethod(PaymentMethod: Enum "Payment Method")
begin
    case PaymentMethod of
        "Payment Method"::"Digital Wallet":
            ProcessDigitalWalletPayment();
        "Payment Method"::Cryptocurrency:
            ProcessCryptocurrencyPayment();
        "Payment Method"::"Bank Draft":
            ProcessBankDraftPayment();
        else
            // Handle base enum values
            ProcessStandardPaymentMethod(PaymentMethod);
    end;
end;
```
