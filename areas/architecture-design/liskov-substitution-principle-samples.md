---
title: "Liskov Substitution Principle in AL - Code Samples"
description: "Complete code examples demonstrating Liskov Substitution Principle implementation in AL"
area: "architecture-design"
difficulty: "intermediate"
object_types: ["Codeunit", "Interface"]
variable_types: ["Record", ]
tags: ["solid-principles", "lsp", "liskov-substitution", "interfaces", "polymorphism", "samples"]
---

# Liskov Substitution Principle in AL - Code Samples

## Payment Processor Interface and Implementations

```al
interface "IPayment Processor"
{
    /// <summary>
    /// Payment processing contract that all implementations must honor
    /// All implementations must be substitutable for each other
    /// </summary>
    procedure ProcessPayment(Amount: Decimal; CustomerNo: Code[20]): Boolean;
    procedure ValidatePaymentData(Amount: Decimal; CustomerNo: Code[20]): Boolean;
    procedure GetLastTransactionId(): Text;
    procedure GetProcessingFee(Amount: Decimal): Decimal;
}

codeunit 50200 "Base Payment Processor" implements "IPayment Processor"
{
    /// <summary>
    /// Base implementation that defines the standard contract behavior
    /// </summary>
    
    var
        LastTransactionId: Text;
    
    procedure ProcessPayment(Amount: Decimal; CustomerNo: Code[20]): Boolean
    begin
        if not ValidatePaymentData(Amount, CustomerNo) then
            exit(false);
            
        LastTransactionId := CreateTransactionId();
        
        // Basic payment processing
        exit(ProcessBasicPayment(Amount, CustomerNo));
    end;
    
    procedure ValidatePaymentData(Amount: Decimal; CustomerNo: Code[20]): Boolean
    begin
        // Base validation: Amount must be positive and customer must exist
        if Amount <= 0 then
            exit(false);
            
        if CustomerNo = '' then
            exit(false);
            
        exit(CustomerExists(CustomerNo));
    end;
    
    procedure GetLastTransactionId(): Text
    begin
        exit(LastTransactionId);
    end;
    
    procedure GetProcessingFee(Amount: Decimal): Decimal
    begin
        // Base fee: 2% of amount
        exit(Amount * 0.02);
    end;
    
    local procedure ProcessBasicPayment(Amount: Decimal; CustomerNo: Code[20]): Boolean
    begin
        // Basic payment implementation
        exit(true);
    end;
    
    local procedure CustomerExists(CustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
    begin
        exit(Customer.Get(CustomerNo));
    end;
    
    local procedure CreateTransactionId(): Text
    begin
        exit(StrSubstNo('TXN-%1-%2', Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2><Hours24><Minutes,2><Seconds,2>'), Random(9999)));
    end;
}
```

## Proper LSP-Compliant Implementations

```al
codeunit 50201 "Credit Card Processor" implements "IPayment Processor"
{
    /// <summary>
    /// Credit card implementation that maintains interface contract
    /// Can be substituted for base implementation without issues
    /// </summary>
    
    var
        LastTransactionId: Text;
    
    procedure ProcessPayment(Amount: Decimal; CustomerNo: Code[20]): Boolean
    begin
        if not ValidatePaymentData(Amount, CustomerNo) then
            exit(false);
            
        if not ValidateCreditCard(CustomerNo) then
            exit(false);
            
        LastTransactionId := CreateCreditCardTransactionId();
        
        // Credit card specific processing
        exit(ProcessCreditCardPayment(Amount, CustomerNo));
    end;
    
    procedure ValidatePaymentData(Amount: Decimal; CustomerNo: Code[20]): Boolean
    begin
        // ✅ LSP Compliant: Same base validation, can add more but not restrict
        if Amount <= 0 then
            exit(false);
            
        if CustomerNo = '' then
            exit(false);
            
        if not CustomerExists(CustomerNo) then
            exit(false);
            
        // Additional validation for credit cards (more permissive, not restrictive)
        // Allow small amounts that base might reject for efficiency
        exit(true);
    end;
    
    procedure GetLastTransactionId(): Text
    begin
        exit(LastTransactionId);
    end;
    
    procedure GetProcessingFee(Amount: Decimal): Decimal
    begin
        // Different fee structure but same return type and meaning
        // Credit card: 3% for amounts under 1000, 2.5% for higher amounts
        if Amount < 1000 then
            exit(Amount * 0.03)
        else
            exit(Amount * 0.025);
    end;
    
    local procedure ValidateCreditCard(CustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
        CustomerBankAccount: Record "Customer Bank Account";
    begin
        if not Customer.Get(CustomerNo) then
            exit(false);
            
        // Check if customer has valid credit card on file
        CustomerBankAccount.SetRange("Customer No.", CustomerNo);
        CustomerBankAccount.SetRange("Use for Electronic Payments", true);
        exit(not CustomerBankAccount.IsEmpty);
    end;
    
    local procedure ProcessCreditCardPayment(Amount: Decimal; CustomerNo: Code[20]): Boolean
    begin
        // Credit card specific processing logic
        // This could involve external API calls, tokenization, etc.
        exit(true);
    end;
    
    local procedure CustomerExists(CustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
    begin
        exit(Customer.Get(CustomerNo));
    end;
    
    local procedure CreateCreditCardTransactionId(): Text
    begin
        exit(StrSubstNo('CC-%1-%2', Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2><Hours24><Minutes,2><Seconds,2>'), Random(9999)));
    end;
}

codeunit 50202 "Bank Transfer Processor" implements "IPayment Processor"
{
    /// <summary>
    /// Bank transfer implementation maintaining LSP compliance
    /// Different implementation but same behavioral guarantees
    /// </summary>
    
    var
        LastTransactionId: Text;
    
    procedure ProcessPayment(Amount: Decimal; CustomerNo: Code[20]): Boolean
    begin
        if not ValidatePaymentData(Amount, CustomerNo) then
            exit(false);
            
        if not ValidateBankDetails(CustomerNo) then
            exit(false);
            
        LastTransactionId := CreateBankTransferTransactionId();
        
        // Bank transfer specific processing
        exit(ProcessBankTransfer(Amount, CustomerNo));
    end;
    
    procedure ValidatePaymentData(Amount: Decimal; CustomerNo: Code[20]): Boolean
    begin
        // ✅ LSP Compliant: Maintains base contract, adds bank-specific validation
        if Amount <= 0 then
            exit(false);
            
        if CustomerNo = '' then
            exit(false);
            
        if not CustomerExists(CustomerNo) then
            exit(false);
            
        // Bank transfers might have minimum amounts but we don't restrict the interface
        // Instead, we provide better error messages but still honor the contract
        exit(true);
    end;
    
    procedure GetLastTransactionId(): Text
    begin
        exit(LastTransactionId);
    end;
    
    procedure GetProcessingFee(Amount: Decimal): Decimal
    begin
        // Bank transfer: Fixed fee of 5 for amounts under 1000, percentage for higher
        if Amount < 1000 then
            exit(5.0)
        else
            exit(Amount * 0.01);
    end;
    
    local procedure ValidateBankDetails(CustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
        CustomerBankAccount: Record "Customer Bank Account";
    begin
        if not Customer.Get(CustomerNo) then
            exit(false);
            
        // Check if customer has valid bank account details
        CustomerBankAccount.SetRange("Customer No.", CustomerNo);
        CustomerBankAccount.SetFilter("Bank Account No.", '<>%1', '');
        CustomerBankAccount.SetFilter("SWIFT Code", '<>%1', '');
        exit(not CustomerBankAccount.IsEmpty);
    end;
    
    local procedure ProcessBankTransfer(Amount: Decimal; CustomerNo: Code[20]): Boolean
    begin
        // Bank transfer specific processing
        // This would involve SWIFT messaging, settlement processing, etc.
        exit(true);
    end;
    
    local procedure CustomerExists(CustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
    begin
        exit(Customer.Get(CustomerNo));
    end;
    
    local procedure CreateBankTransferTransactionId(): Text
    begin
        exit(StrSubstNo('BT-%1-%2', Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2><Hours24><Minutes,2><Seconds,2>'), Random(9999)));
    end;
}
```

## LSP-Compliant Usage Example

```al
codeunit 50203 "Payment Manager"
{
    /// <summary>
    /// Demonstrates LSP - all payment processors can be used interchangeably
    /// The client code doesn't need to know which implementation is being used
    /// </summary>
    
    procedure ProcessCustomerPayment(CustomerNo: Code[20]; Amount: Decimal; ProcessorType: Enum "Payment Processor Type"): Boolean
    var
        PaymentProcessor: Interface "IPayment Processor";
    begin
        // Get appropriate processor - all are substitutable
        PaymentProcessor := GetPaymentProcessor(ProcessorType);
        
        // Use processor without knowing the specific implementation
        // This works because of LSP compliance
        if not PaymentProcessor.ValidatePaymentData(Amount, CustomerNo) then begin
            Error('Payment validation failed');
            exit(false);
        end;
        
        if not PaymentProcessor.ProcessPayment(Amount, CustomerNo) then begin
            Error('Payment processing failed');
            exit(false);
        end;
        
        // Log successful transaction
        LogPaymentTransaction(PaymentProcessor.GetLastTransactionId(), Amount, 
                            PaymentProcessor.GetProcessingFee(Amount));
        
        exit(true);
    end;
    
    procedure TestAllProcessors()
    var
        ProcessorTypes: List of [Enum "Payment Processor Type"];
        ProcessorType: Enum "Payment Processor Type";
        PaymentProcessor: Interface "IPayment Processor";
        TestAmount: Decimal;
        TestCustomer: Code[20];
    begin
        // ✅ LSP Test: All implementations should behave consistently
        ProcessorTypes.Add(ProcessorType::Base);
        ProcessorTypes.Add(ProcessorType::"Credit Card");
        ProcessorTypes.Add(ProcessorType::"Bank Transfer");
        
        TestAmount := 100.00;
        TestCustomer := '10000';
        
        // Test each processor with same parameters
        foreach ProcessorType in ProcessorTypes do begin
            PaymentProcessor := GetPaymentProcessor(ProcessorType);
            
            // All processors should handle these basic scenarios consistently
            Assert.IsTrue(PaymentProcessor.ValidatePaymentData(TestAmount, TestCustomer), 
                        StrSubstNo('Processor %1 should validate positive amount and valid customer', ProcessorType));
            
            Assert.IsFalse(PaymentProcessor.ValidatePaymentData(-10, TestCustomer), 
                         StrSubstNo('Processor %1 should reject negative amounts', ProcessorType));
            
            Assert.IsFalse(PaymentProcessor.ValidatePaymentData(TestAmount, ''), 
                         StrSubstNo('Processor %1 should reject empty customer', ProcessorType));
            
            // All should return some fee (could be different amounts but same type)
            Assert.IsTrue(PaymentProcessor.GetProcessingFee(TestAmount) >= 0, 
                        StrSubstNo('Processor %1 should return non-negative fee', ProcessorType));
        end;
        
        Message('All processors passed LSP compliance tests');
    end;
    
    local procedure GetPaymentProcessor(ProcessorType: Enum "Payment Processor Type"): Interface "IPayment Processor"
    var
        BaseProcessor: Codeunit "Base Payment Processor";
        CreditCardProcessor: Codeunit "Credit Card Processor";
        BankTransferProcessor: Codeunit "Bank Transfer Processor";
    begin
        case ProcessorType of
            ProcessorType::Base:
                exit(BaseProcessor);
            ProcessorType::"Credit Card":
                exit(CreditCardProcessor);
            ProcessorType::"Bank Transfer":
                exit(BankTransferProcessor);
            else
                exit(BaseProcessor);
        end;
    end;
    
    local procedure LogPaymentTransaction(TransactionId: Text; Amount: Decimal; Fee: Decimal)
    begin
        // Log payment transaction details
        Message('Transaction %1: Amount %2, Fee %3', TransactionId, Amount, Fee);
    end;
}
```

## Document Validator LSP Example

```al
interface "IDocument Validator"
{
    procedure ValidateDocument(DocumentNo: Code[20]): Boolean;
    procedure GetValidationMessage(): Text;
    procedure CanValidateDocumentType(DocumentType: Text): Boolean;
}

codeunit 50204 "Basic Document Validator" implements "IDocument Validator"
{
    /// <summary>
    /// Base document validator with minimal requirements
    /// </summary>
    
    var
        LastValidationMessage: Text;
    
    procedure ValidateDocument(DocumentNo: Code[20]): Boolean
    begin
        Clear(LastValidationMessage);
        
        // Basic validation: Document number must not be empty
        if DocumentNo = '' then begin
            LastValidationMessage := 'Document number cannot be empty';
            exit(false);
        end;
        
        // Basic format check
        if StrLen(DocumentNo) < 3 then begin
            LastValidationMessage := 'Document number must be at least 3 characters';
            exit(false);
        end;
        
        LastValidationMessage := 'Document validation passed';
        exit(true);
    end;
    
    procedure GetValidationMessage(): Text
    begin
        exit(LastValidationMessage);
    end;
    
    procedure CanValidateDocumentType(DocumentType: Text): Boolean
    begin
        // Base validator can handle all document types
        exit(true);
    end;
}

codeunit 50205 "Sales Document Validator" implements "IDocument Validator"
{
    /// <summary>
    /// ✅ LSP Compliant: More specific validator that maintains base contract
    /// Can be substituted for base validator without breaking code
    /// </summary>
    
    var
        LastValidationMessage: Text;
    
    procedure ValidateDocument(DocumentNo: Code[20]): Boolean
    var
        SalesHeader: Record "Sales Header";
    begin
        Clear(LastValidationMessage);
        
        // Include base validation (not more restrictive)
        if DocumentNo = '' then begin
            LastValidationMessage := 'Document number cannot be empty';
            exit(false);
        end;
        
        if StrLen(DocumentNo) < 3 then begin
            LastValidationMessage := 'Document number must be at least 3 characters';
            exit(false);
        end;
        
        // Additional sales-specific validation (enhances but doesn't restrict)
        SalesHeader.SetRange("No.", DocumentNo);
        if SalesHeader.IsEmpty then begin
            LastValidationMessage := 'Sales document not found';
            exit(false);
        end;
        
        // Enhanced validation for sales documents
        if SalesHeader.FindFirst() then begin
            if SalesHeader."Sell-to Customer No." = '' then begin
                LastValidationMessage := 'Sales document missing customer number';
                exit(false);
            end;
        end;
        
        LastValidationMessage := 'Sales document validation passed with enhanced checks';
        exit(true);
    end;
    
    procedure GetValidationMessage(): Text
    begin
        exit(LastValidationMessage);
    end;
    
    procedure CanValidateDocumentType(DocumentType: Text): Boolean
    begin
        // More specific about what it can validate, but doesn't break substitutability
        exit(DocumentType in ['SALES ORDER', 'SALES INVOICE', 'SALES QUOTE']);
    end;
}
```

## LSP Violation Examples (What NOT to do)

```al
codeunit 50206 "Broken Validator" implements "IDocument Validator"
{
    /// <summary>
    /// ❌ LSP VIOLATION EXAMPLE - DO NOT IMPLEMENT LIKE THIS
    /// This violates LSP by strengthening preconditions
    /// </summary>
    
    var
        LastValidationMessage: Text;
    
    procedure ValidateDocument(DocumentNo: Code[20]): Boolean
    begin
        // ❌ VIOLATION: Strengthening preconditions
        // Base contract allows any non-empty document number >= 3 chars
        // This implementation requires exactly 10 characters - breaks substitutability
        
        if StrLen(DocumentNo) <> 10 then begin
            Error('Document number must be exactly 10 characters'); // This breaks client code!
            exit(false);
        end;
        
        // ❌ VIOLATION: Different error handling behavior
        // Base implementation sets message and returns false
        // This implementation throws an error - breaks substitutability
        
        LastValidationMessage := 'Validation with strict requirements';
        exit(true);
    end;
    
    procedure GetValidationMessage(): Text
    begin
        exit(LastValidationMessage);
    end;
    
    procedure CanValidateDocumentType(DocumentType: Text): Boolean
    begin
        // ❌ VIOLATION: Weakening postconditions
        // Sometimes returns true when it should return false
        exit(Random(2) = 1); // Unreliable behavior breaks substitutability
    end;
}
```

## LSP Compliance Testing Framework

```al
codeunit 50207 "LSP Compliance Tester"
{
    /// <summary>
    /// Framework for testing LSP compliance across implementations
    /// </summary>
    
    procedure TestDocumentValidators()
    var
        Validators: List of [Interface "IDocument Validator"];
        Validator: Interface "IDocument Validator";
        TestCases: List of [Text];
        TestCase: Text;
        Results: List of [Boolean];
        ExpectedResults: List of [Boolean];
    begin
        // Setup test implementations
        AddValidatorImplementations(Validators);
        AddTestCases(TestCases, ExpectedResults);
        
        // Test each implementation with same test cases
        foreach Validator in Validators do begin
            Clear(Results);
            foreach TestCase in TestCases do begin
                Results.Add(Validator.ValidateDocument(TestCase));
            end;
            
            // All implementations should produce consistent results for same inputs
            ValidateConsistentBehavior(Results, ExpectedResults, GetValidatorName(Validator));
        end;
    end;
    
    local procedure AddValidatorImplementations(var Validators: List of [Interface "IDocument Validator"])
    var
        BasicValidator: Codeunit "Basic Document Validator";
        SalesValidator: Codeunit "Sales Document Validator";
    begin
        Validators.Add(BasicValidator);
        Validators.Add(SalesValidator);
    end;
    
    local procedure AddTestCases(var TestCases: List of [Text]; var ExpectedResults: List of [Boolean])
    begin
        // Test cases that all implementations should handle consistently
        TestCases.Add('DOC001'); ExpectedResults.Add(true);   // Valid document
        TestCases.Add('AB');     ExpectedResults.Add(false);  // Too short
        TestCases.Add('');       ExpectedResults.Add(false);  // Empty
        TestCases.Add('VALIDOC123'); ExpectedResults.Add(true); // Valid long document
    end;
    
    local procedure ValidateConsistentBehavior(Results: List of [Boolean]; ExpectedResults: List of [Boolean]; ValidatorName: Text)
    var
        i: Integer;
        Result: Boolean;
        Expected: Boolean;
    begin
        for i := 1 to Results.Count do begin
            Results.Get(i, Result);
            ExpectedResults.Get(i, Expected);
            
            if Result <> Expected then
                Error('LSP Violation: %1 produced unexpected result for test case %2. Expected: %3, Got: %4',
                      ValidatorName, i, Expected, Result);
        end;
        
        Message('LSP Compliance Test Passed for %1', ValidatorName);
    end;
    
    local procedure GetValidatorName(Validator: Interface "IDocument Validator"): Text
    begin
        // This would need to be implemented based on how to identify the validator
        exit('Unknown Validator');
    end;
}
```

## Related Topics
- [Liskov Substitution Principle](liskov-substitution-principle.md)
- [Single Responsibility Principle](single-responsibility-principle.md)
- [Interface Segregation Principle](interface-segregation-principle.md)
