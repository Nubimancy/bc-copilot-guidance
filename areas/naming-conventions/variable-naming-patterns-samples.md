# Variable Naming Patterns - Code Samples

## Basic Record Variable Naming

```al
// Basic record variable naming
procedure ProcessCustomer()
var
    Customer: Record Customer;
    SalesHeader: Record "Sales Header";
    SalesLine: Record "Sales Line";
begin
    // Implementation
end;
```

## Multiple Variables of Same Type

```al
// Multiple variables of the same type - use descriptive suffixes
procedure TransferBetweenCustomers()
var
    SourceCustomer: Record Customer;
    TargetCustomer: Record Customer;
    TempCustomer: Record Customer temporary;
begin
    // Transfer logic implementation
end;
```

## Complex Scenario with Related Records

```al
// Complex scenario with related records
procedure AnalyzeCustomerSales()
var
    Customer: Record Customer;
    SalesHeader: Record "Sales Header";
    SalesLine: Record "Sales Line";
    ItemLedgerEntry: Record "Item Ledger Entry";
    TempSalesAnalysis: Record "Sales Analysis" temporary;
    FilterCustomer: Record Customer;
begin
    // Analysis implementation
end;
```

## Extension and Base Table Variables

```al
// Working with extensions and base tables
procedure ProcessCustomerRatings()
var
    Customer: Record Customer;  // Base table
    CustomerRating: Record "ABC Customer Rating";  // Extension table
    TempCustomerSummary: Record "Customer Summary" temporary;
begin
    // Rating processing logic
end;
```

## Page Variable Examples

```al
// Page variable naming
procedure ShowCustomerCard()
var
    CustomerCard: Page "Customer Card";
    CustomerList: Page "Customer List";
begin
    CustomerCard.SetRecord(Customer);
    CustomerCard.Run();
end;
```

## Parameter Declaration Examples

```al
// Proper parameter declaration
procedure UpdateCustomerStatus(var Customer: Record Customer; NewStatus: Enum "Customer Status")
var
    // Customer passed by reference because it's modified
    // NewStatus passed by value because it's read-only
begin
    Customer.Status := NewStatus;
    Customer.Modify(true);
end;
```

## Variable Ordering Example

```al
// Correct variable ordering
procedure ComplexBusinessLogic()
var
    // Object types first
    Customer: Record Customer;
    SalesInvoice: Report "Standard Sales - Invoice";
    NotificationMgt: Codeunit "Notification Management";
    
    // Then simple types
    CustomerNo: Code[20];
    TotalAmount: Decimal;
    ProcessDate: Date;
    IsProcessed: Boolean;
begin
    // Implementation
end;
```
