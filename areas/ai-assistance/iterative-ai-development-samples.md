```al
// ✅ Progressive Enhancement Example - Customer Rewards System
// Phase 1: Basic Implementation
codeunit 50110 "Customer Rewards Phase1"
{
    // Start with core functionality only
    procedure CalculateBasicRewards(CustomerNo: Code[20]): Decimal
    var
        Customer: Record Customer;
        RewardAmount: Decimal;
    begin
        if Customer.Get(CustomerNo) then begin
            RewardAmount := Customer."Sales (LCY)" * 0.01; // 1% of sales
            exit(RewardAmount);
        end;
        exit(0);
    end;
}

// Phase 2: Add Error Handling and Validation
codeunit 50111 "Customer Rewards Phase2"
{
    procedure CalculateRewardsWithValidation(CustomerNo: Code[20]): Decimal
    var
        Customer: Record Customer;
        RewardAmount: Decimal;
    begin
        // Input validation
        if CustomerNo = '' then
            Error('Customer number cannot be empty');

        if not Customer.Get(CustomerNo) then
            Error('Customer %1 not found', CustomerNo);

        // Business rule validation
        if Customer.Blocked <> Customer.Blocked::" " then
            Error('Cannot calculate rewards for blocked customer %1', CustomerNo);

        // Core calculation with error handling
        if Customer."Sales (LCY)" < 0 then
            Error('Invalid sales amount for customer %1', CustomerNo);

        RewardAmount := Customer."Sales (LCY)" * 0.01;
        exit(RewardAmount);
    end;

    // Add logging for traceability
    local procedure LogRewardCalculation(CustomerNo: Code[20]; Amount: Decimal)
    var
        ActivityLog: Record "Activity Log";
    begin
        ActivityLog.LogActivity(
            Database::Customer,
            ActivityLog.Status::Success,
            'REWARD_CALC',
            StrSubstNo('Calculated rewards: %1 for customer %2', Amount, CustomerNo),
            '');
    end;
}

// Phase 3: Integration with Posting Routines
codeunit 50112 "Customer Rewards Phase3"
{
    procedure ProcessCustomerRewards(CustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
        RewardAmount: Decimal;
        GenJnlLine: Record "Gen. Journal Line";
    begin
        // Use validated calculation from Phase 2
        RewardAmount := CalculateRewardsWithValidation(CustomerNo);
        
        if RewardAmount = 0 then
            exit(true); // No rewards to process

        // Create journal entry for reward posting
        if not CreateRewardJournalEntry(CustomerNo, RewardAmount) then
            Error('Failed to create reward journal entry for customer %1', CustomerNo);

        // Post the reward
        if not PostRewardEntry(CustomerNo) then
            Error('Failed to post reward for customer %1', CustomerNo);

        exit(true);
    end;

    local procedure CreateRewardJournalEntry(CustomerNo: Code[20]; Amount: Decimal): Boolean
    var
        GenJnlLine: Record "Gen. Journal Line";
        NoSeries: Codeunit "No. Series";
    begin
        GenJnlLine.Init();
        GenJnlLine."Journal Template Name" := 'REWARDS';
        GenJnlLine."Journal Batch Name" := 'DEFAULT';
        GenJnlLine."Line No." := GetNextLineNo();
        GenJnlLine."Document No." := NoSeries.GetNextNo('REWARD', Today, true);
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
        GenJnlLine."Account No." := CustomerNo;
        GenJnlLine.Amount := Amount;
        GenJnlLine.Description := StrSubstNo('Reward payment for %1', CustomerNo);
        
        exit(GenJnlLine.Insert(true));
    end;

    local procedure PostRewardEntry(CustomerNo: Code[20]): Boolean
    var
        GenJnlPost: Codeunit "Gen. Jnl.-Post";
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine.SetRange("Account No.", CustomerNo);
        if GenJnlLine.FindSet() then
            GenJnlPost.Run(GenJnlLine);
        
        exit(true);
    end;
}

// Phase 4: Performance Optimization
codeunit 50113 "Customer Rewards Phase4"
{
    procedure BatchProcessRewards(var CustomerList: List of [Code[20]])
    var
        Customer: Record Customer;
        CustomerNo: Code[20];
        RewardCalculations: Dictionary of [Code[20], Decimal];
    begin
        // Bulk load customers for better performance
        Customer.SetFilter("No.", CreateFilterFromList(CustomerList));
        Customer.SetLoadFields("No.", "Sales (LCY)", "Blocked");
        
        if Customer.FindSet() then
            repeat
                // Calculate in memory first
                RewardCalculations.Add(Customer."No.", Customer."Sales (LCY)" * 0.01);
            until Customer.Next() = 0;

        // Batch process all calculations
        ProcessBatchRewards(RewardCalculations);
    end;

    local procedure CreateFilterFromList(CustomerList: List of [Code[20]]): Text
    var
        CustomerNo: Code[20];
        FilterText: Text;
    begin
        foreach CustomerNo in CustomerList do begin
            if FilterText <> '' then
                FilterText += '|';
            FilterText += CustomerNo;
        end;
        exit(FilterText);
    end;

    local procedure ProcessBatchRewards(RewardCalculations: Dictionary of [Code[20], Decimal])
    var
        GenJnlLine: Record "Gen. Journal Line";
        CustomerNo: Code[20];
        Amount: Decimal;
        LineNo: Integer;
    begin
        LineNo := 10000;
        
        foreach CustomerNo in RewardCalculations.Keys() do begin
            RewardCalculations.Get(CustomerNo, Amount);
            
            if Amount > 0 then begin
                CreateBatchJournalLine(CustomerNo, Amount, LineNo);
                LineNo += 10000;
            end;
        end;
        
        // Post entire batch
        PostBatchEntries();
    end;
}

// ✅ Context Management Implementation
codeunit 50114 "AI Context Manager"
{
    procedure UpdateImplementationContext(Phase: Integer; Status: Text; Notes: Text)
    var
        ImplementationLog: Record "Implementation Log";
    begin
        ImplementationLog.Init();
        ImplementationLog."Entry No." := GetNextEntryNo();
        ImplementationLog."Phase No." := Phase;
        ImplementationLog."Implementation Date" := Today;
        ImplementationLog."Implementation Time" := Time;
        ImplementationLog."Status" := Status;
        ImplementationLog."Notes" := Notes;
        ImplementationLog."User ID" := UserId;
        ImplementationLog.Insert(true);
    end;

    procedure GetPhaseContext(Phase: Integer): Text
    var
        ImplementationLog: Record "Implementation Log";
        Context: Text;
    begin
        ImplementationLog.SetRange("Phase No.", Phase);
        ImplementationLog.SetRange("Status", 'COMPLETED');
        if ImplementationLog.FindLast() then
            Context := ImplementationLog."Notes";
        
        exit(Context);
    end;

    local procedure GetNextEntryNo(): Integer
    var
        ImplementationLog: Record "Implementation Log";
    begin
        ImplementationLog.SetCurrentKey("Entry No.");
        if ImplementationLog.FindLast() then
            exit(ImplementationLog."Entry No." + 1)
        else
            exit(1);
    end;
}

// ✅ Validation Between Phases
codeunit 50115 "Phase Validation Controller"
{
    procedure ValidatePhaseCompletion(Phase: Integer): Boolean
    var
        ValidationResult: Boolean;
    begin
        case Phase of
            1:
                ValidationResult := ValidatePhase1();
            2:
                ValidationResult := ValidatePhase2();
            3:
                ValidationResult := ValidatePhase3();
            4:
                ValidationResult := ValidatePhase4();
        end;

        if ValidationResult then
            UpdatePhaseStatus(Phase, 'COMPLETED')
        else
            UpdatePhaseStatus(Phase, 'FAILED');

        exit(ValidationResult);
    end;

    local procedure ValidatePhase1(): Boolean
    var
        TestResult: Boolean;
    begin
        // Test basic functionality
        TestResult := TestBasicCalculation();
        exit(TestResult);
    end;

    local procedure ValidatePhase2(): Boolean
    var
        TestResult: Boolean;
    begin
        // Test error handling
        TestResult := TestErrorHandling();
        exit(TestResult);
    end;

    local procedure ValidatePhase3(): Boolean
    var
        TestResult: Boolean;
    begin
        // Test integration
        TestResult := TestIntegration();
        exit(TestResult);
    end;

    local procedure ValidatePhase4(): Boolean
    var
        TestResult: Boolean;
    begin
        // Test performance
        TestResult := TestPerformance();
        exit(TestResult);
    end;

    local procedure UpdatePhaseStatus(Phase: Integer; Status: Text)
    var
        ContextManager: Codeunit "AI Context Manager";
    begin
        ContextManager.UpdateImplementationContext(
            Phase, 
            Status, 
            StrSubstNo('Phase %1 validation %2', Phase, Status));
    end;
}
```
