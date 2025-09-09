# Long-Running Operation Tracking - AL Implementation Samples

This file contains working AL code examples for implementing Business Central long-running operation tracking patterns using job queue entries, session events, and BC's monitoring capabilities.

## Job Queue Entry Implementation Samples

### Operation Status Table

```al
table 50410 "Long Running Operation"
{
    DataClassification = SystemMetadata;
    Caption = 'Long Running Operation';
    
    fields
    {
        field(1; "Operation ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Operation ID';
        }
        field(2; "Operation Name"; Text[100])
        {
            DataClassification = SystemMetadata;
            Caption = 'Operation Name';
        }
        field(3; "Operation Type"; Text[50])
        {
            DataClassification = SystemMetadata;
            Caption = 'Operation Type';
        }
        field(4; "Job Queue Entry ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Job Queue Entry ID';
        }
        field(5; "Started At"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'Started At';
        }
        field(6; "Started By"; Code[50])
        {
            DataClassification = SystemMetadata;
            Caption = 'Started By';
            TableRelation = User."User Name";
        }
        field(7; Status; Enum "Long Running Operation Status")
        {
            DataClassification = SystemMetadata;
            Caption = 'Status';
        }
        field(8; "Progress Percentage"; Decimal)
        {
            DataClassification = SystemMetadata;
            Caption = 'Progress Percentage';
            MinValue = 0;
            MaxValue = 100;
            DecimalPlaces = 1 : 1;
        }
        field(9; "Current Step"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Current Step';
        }
        field(10; "Total Steps"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Total Steps';
        }
        field(11; "Records Processed"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Records Processed';
        }
        field(12; "Total Records"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Total Records';
        }
        field(13; "Estimated Completion"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'Estimated Completion';
        }
        field(14; "Completed At"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'Completed At';
        }
        field(15; "Duration Minutes"; Decimal)
        {
            DataClassification = SystemMetadata;
            Caption = 'Duration (Minutes)';
            DecimalPlaces = 2 : 2;
        }
        field(16; "Last Updated"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'Last Updated';
        }
        field(17; "Current Activity"; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'Current Activity';
        }
        field(18; "Error Message"; Text[2048])
        {
            DataClassification = SystemMetadata;
            Caption = 'Error Message';
        }
        field(19; "Can Cancel"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Can Cancel';
        }
        field(20; "Company Name"; Text[30])
        {
            DataClassification = SystemMetadata;
            Caption = 'Company Name';
        }
    }

    keys
    {
        key(PK; "Operation ID") { Clustered = true; }
        key(Status; Status, "Started At") { }
        key(User; "Started By", "Started At") { }
        key(JobQueue; "Job Queue Entry ID") { }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Operation Name", Status, "Progress Percentage", "Started At") { }
    }

    trigger OnInsert()
    begin
        if IsNullGuid("Operation ID") then
            "Operation ID" := CreateGuid();
        
        if "Started At" = 0DT then
            "Started At" := CurrentDateTime;
        
        if "Started By" = '' then
            "Started By" := UserId;
        
        if "Company Name" = '' then
            "Company Name" := CompanyName;
        
        "Last Updated" := CurrentDateTime;
    end;

    trigger OnModify()
    begin
        "Last Updated" := CurrentDateTime;
        
        if ("Completed At" <> 0DT) and ("Duration Minutes" = 0) then
            "Duration Minutes" := ("Completed At" - "Started At") / 60000;
    end;

    procedure UpdateProgress(NewProgressPercentage: Decimal; CurrentActivity: Text[250])
    begin
        Validate("Progress Percentage", NewProgressPercentage);
        Validate("Current Activity", CurrentActivity);
        
        if "Progress Percentage" >= 100 then begin
            Validate(Status, Status::Completed);
            Validate("Completed At", CurrentDateTime);
        end;
        
        Modify(true);
    end;

    procedure UpdateStepProgress(CurrentStep: Integer; TotalSteps: Integer)
    var
        StepProgress: Decimal;
    begin
        Validate("Current Step", CurrentStep);
        Validate("Total Steps", TotalSteps);
        
        if TotalSteps > 0 then begin
            StepProgress := (CurrentStep / TotalSteps) * 100;
            Validate("Progress Percentage", StepProgress);
        end;
        
        Modify(true);
    end;

    procedure UpdateRecordProgress(RecordsProcessed: Integer; TotalRecords: Integer)
    var
        RecordProgress: Decimal;
    begin
        Validate("Records Processed", RecordsProcessed);
        Validate("Total Records", TotalRecords);
        
        if TotalRecords > 0 then begin
            RecordProgress := (RecordsProcessed / TotalRecords) * 100;
            Validate("Progress Percentage", RecordProgress);
        end;
        
        Modify(true);
    end;

    procedure SetError(ErrorMessage: Text[2048])
    begin
        Validate(Status, Status::Failed);
        Validate("Error Message", ErrorMessage);
        Validate("Completed At", CurrentDateTime);
        Modify(true);
    end;

    procedure RequestCancellation()
    begin
        if "Can Cancel" and (Status = Status::Running) then begin
            Validate(Status, Status::"Cancellation Requested");
            Modify(true);
        end;
    end;
}
```

### Operation Status Enum

```al
enum 50410 "Long Running Operation Status"
{
    Extensible = true;
    Caption = 'Long Running Operation Status';
    
    value(0; Pending)
    {
        Caption = 'Pending';
    }
    value(1; Running)
    {
        Caption = 'Running';
    }
    value(2; Completed)
    {
        Caption = 'Completed';
    }
    value(3; Failed)
    {
        Caption = 'Failed';
    }
    value(4; "Cancellation Requested")
    {
        Caption = 'Cancellation Requested';
    }
    value(5; Cancelled)
    {
        Caption = 'Cancelled';
    }
}
```

## Job Queue Operation Management

### Long-Running Operation Manager

```al
codeunit 50410 "Long Running Operation Mgmt"
{
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        OperationTelemetryTok: Label 'Long Running Operations', Locked = true;

    procedure StartOperation(OperationName: Text[100]; OperationType: Text[50]; CodeunitID: Integer): Guid
    var
        LongRunningOperation: Record "Long Running Operation";
        JobQueueEntry: Record "Job Queue Entry";
        OperationID: Guid;
    begin
        OperationID := CreateGuid();
        
        // Create operation record
        LongRunningOperation.Init();
        LongRunningOperation."Operation ID" := OperationID;
        LongRunningOperation."Operation Name" := OperationName;
        LongRunningOperation."Operation Type" := OperationType;
        LongRunningOperation.Status := LongRunningOperation.Status::Pending;
        LongRunningOperation."Can Cancel" := true;
        LongRunningOperation.Insert(true);
        
        // Create job queue entry
        CreateJobQueueEntry(JobQueueEntry, OperationID, CodeunitID);
        LongRunningOperation."Job Queue Entry ID" := JobQueueEntry.ID;
        LongRunningOperation.Modify(true);
        
        // Start the job
        Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry);
        
        // Log telemetry
        FeatureTelemetry.LogUptake('0000ABC', OperationTelemetryTok, Enum::"Feature Uptake Status"::Used);
        FeatureTelemetry.LogUsage('0000DEF', OperationTelemetryTok, 'Operation Started');
        
        exit(OperationID);
    end;

    local procedure CreateJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry"; OperationID: Guid; CodeunitID: Integer)
    begin
        JobQueueEntry.Init();
        JobQueueEntry.ID := CreateGuid();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := CodeunitID;
        JobQueueEntry.Description := 'Long Running Operation';
        JobQueueEntry."Parameter String" := OperationID;
        JobQueueEntry."Job Queue Category Code" := 'LONGRUN';
        JobQueueEntry."Maximum No. of Attempts to Run" := 1;
        JobQueueEntry."Rerun Delay (sec.)" := 0;
        JobQueueEntry."Earliest Start Date/Time" := CurrentDateTime;
        JobQueueEntry.Status := JobQueueEntry.Status::Ready;
        JobQueueEntry.Insert(true);
    end;

    procedure UpdateOperationProgress(OperationID: Guid; ProgressPercentage: Decimal; CurrentActivity: Text[250])
    var
        LongRunningOperation: Record "Long Running Operation";
    begin
        if LongRunningOperation.Get(OperationID) then begin
            LongRunningOperation.UpdateProgress(ProgressPercentage, CurrentActivity);
            
            // Send telemetry
            FeatureTelemetry.LogUsage('0000GHI', OperationTelemetryTok, 
                StrSubstNo('Progress Update: %1%%', ProgressPercentage));
        end;
    end;

    procedure CompleteOperation(OperationID: Guid; ResultMessage: Text[250])
    var
        LongRunningOperation: Record "Long Running Operation";
    begin
        if LongRunningOperation.Get(OperationID) then begin
            LongRunningOperation.UpdateProgress(100, ResultMessage);
            
            // Send completion telemetry
            FeatureTelemetry.LogUsage('0000JKL', OperationTelemetryTok, 
                StrSubstNo('Operation Completed: %1 minutes', LongRunningOperation."Duration Minutes"));
            
            // Send notification
            SendCompletionNotification(LongRunningOperation);
        end;
    end;

    procedure FailOperation(OperationID: Guid; ErrorMessage: Text[2048])
    var
        LongRunningOperation: Record "Long Running Operation";
    begin
        if LongRunningOperation.Get(OperationID) then begin
            LongRunningOperation.SetError(ErrorMessage);
            
            // Send error telemetry
            FeatureTelemetry.LogError('0000MNO', OperationTelemetryTok, 'Operation Failed', ErrorMessage);
            
            // Send notification
            SendErrorNotification(LongRunningOperation);
        end;
    end;

    local procedure SendCompletionNotification(LongRunningOperation: Record "Long Running Operation")
    var
        NotificationMgt: Codeunit "Notification Management";
        Notification: Notification;
    begin
        Notification.Id := CreateGuid();
        Notification.Message := StrSubstNo('Operation "%1" completed successfully', LongRunningOperation."Operation Name");
        Notification.Scope := NotificationScope::LocalScope;
        Notification.Send();
    end;

    local procedure SendErrorNotification(LongRunningOperation: Record "Long Running Operation")
    var
        NotificationMgt: Codeunit "Notification Management";
        Notification: Notification;
    begin
        Notification.Id := CreateGuid();
        Notification.Message := StrSubstNo('Operation "%1" failed: %2', 
            LongRunningOperation."Operation Name", LongRunningOperation."Error Message");
        Notification.Scope := NotificationScope::LocalScope;
        Notification.Send();
    end;

    procedure CancelOperation(OperationID: Guid)
    var
        LongRunningOperation: Record "Long Running Operation";
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if LongRunningOperation.Get(OperationID) then begin
            LongRunningOperation.RequestCancellation();
            
            // Cancel job queue entry if still running
            if JobQueueEntry.Get(LongRunningOperation."Job Queue Entry ID") then
                if JobQueueEntry.Status = JobQueueEntry.Status::"In Process" then begin
                    JobQueueEntry.Cancel();
                    LongRunningOperation.Status := LongRunningOperation.Status::Cancelled;
                    LongRunningOperation."Completed At" := CurrentDateTime;
                    LongRunningOperation.Modify(true);
                end;
            
            // Send telemetry
            FeatureTelemetry.LogUsage('0000PQR', OperationTelemetryTok, 'Operation Cancelled');
        end;
    end;
}
```

## Sample Long-Running Operation Implementation

### Data Processing Operation

```al
codeunit 50411 "Data Processing Operation"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        OperationID: Guid;
    begin
        if not Evaluate(OperationID, Rec."Parameter String") then
            Error('Invalid Operation ID: %1', Rec."Parameter String");
        
        ProcessLargeDataset(OperationID);
    end;

    local procedure ProcessLargeDataset(OperationID: Guid)
    var
        Customer: Record Customer;
        LongRunningOperationMgt: Codeunit "Long Running Operation Mgmt";
        ProcessedCount: Integer;
        TotalCount: Integer;
        ProgressPercentage: Decimal;
        StartTime: DateTime;
    begin
        StartTime := CurrentDateTime;
        
        // Start operation
        LongRunningOperationMgt.UpdateOperationProgress(OperationID, 0, 'Initializing data processing...');
        
        // Count total records
        TotalCount := Customer.Count();
        LongRunningOperationMgt.UpdateOperationProgress(OperationID, 5, 
            StrSubstNo('Found %1 customers to process', TotalCount));
        
        // Process records in batches
        if Customer.FindSet() then
            repeat
                ProcessedCount += 1;
                
                // Simulate processing work
                ProcessCustomerRecord(Customer);
                
                // Update progress every 100 records
                if (ProcessedCount mod 100) = 0 then begin
                    ProgressPercentage := 5 + ((ProcessedCount / TotalCount) * 90); // 5% reserved for initialization, 5% for completion
                    LongRunningOperationMgt.UpdateOperationProgress(OperationID, ProgressPercentage,
                        StrSubstNo('Processed %1 of %2 customers', ProcessedCount, TotalCount));
                end;
                
                // Check for cancellation
                if CheckCancellationRequested(OperationID) then begin
                    LongRunningOperationMgt.UpdateOperationProgress(OperationID, ProgressPercentage, 'Cancellation requested, stopping...');
                    exit;
                end;
                
                // Commit periodically to avoid long transactions
                if (ProcessedCount mod 500) = 0 then
                    Commit();
                    
            until Customer.Next() = 0;
        
        // Complete operation
        LongRunningOperationMgt.CompleteOperation(OperationID, 
            StrSubstNo('Successfully processed %1 customers in %2 minutes', 
                ProcessedCount, (CurrentDateTime - StartTime) / 60000));
    end;

    local procedure ProcessCustomerRecord(var Customer: Record Customer)
    begin
        // Simulate processing time
        Sleep(10);
        
        // Example: Update credit rating or perform calculations
        if Customer."Credit Limit (LCY)" > 0 then begin
            Customer."Last Date Modified" := Today;
            Customer.Modify();
        end;
    end;

    local procedure CheckCancellationRequested(OperationID: Guid): Boolean
    var
        LongRunningOperation: Record "Long Running Operation";
    begin
        if LongRunningOperation.Get(OperationID) then
            exit(LongRunningOperation.Status = LongRunningOperation.Status::"Cancellation Requested");
        
        exit(false);
    end;
}
```

### Multi-Step Operation Implementation

```al
codeunit 50412 "Multi Step Operation"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        OperationID: Guid;
    begin
        if not Evaluate(OperationID, Rec."Parameter String") then
            Error('Invalid Operation ID: %1', Rec."Parameter String");
        
        ExecuteMultiStepProcess(OperationID);
    end;

    local procedure ExecuteMultiStepProcess(OperationID: Guid)
    var
        LongRunningOperationMgt: Codeunit "Long Running Operation Mgmt";
        LongRunningOperation: Record "Long Running Operation";
        CurrentStep: Integer;
        TotalSteps: Integer;
    begin
        TotalSteps := 5;
        
        // Initialize
        LongRunningOperation.Get(OperationID);
        LongRunningOperation."Total Steps" := TotalSteps;
        LongRunningOperation.Modify();
        
        // Step 1: Data Validation
        CurrentStep := 1;
        UpdateStepProgress(OperationID, CurrentStep, TotalSteps, 'Validating data integrity...');
        if not ExecuteDataValidation(OperationID) then exit;
        
        // Step 2: Data Backup
        CurrentStep := 2;
        UpdateStepProgress(OperationID, CurrentStep, TotalSteps, 'Creating data backup...');
        if not ExecuteDataBackup(OperationID) then exit;
        
        // Step 3: Data Processing
        CurrentStep := 3;
        UpdateStepProgress(OperationID, CurrentStep, TotalSteps, 'Processing data records...');
        if not ExecuteDataProcessing(OperationID) then exit;
        
        // Step 4: Data Verification
        CurrentStep := 4;
        UpdateStepProgress(OperationID, CurrentStep, TotalSteps, 'Verifying processed data...');
        if not ExecuteDataVerification(OperationID) then exit;
        
        // Step 5: Cleanup
        CurrentStep := 5;
        UpdateStepProgress(OperationID, CurrentStep, TotalSteps, 'Performing cleanup...');
        ExecuteCleanup(OperationID);
        
        // Complete
        LongRunningOperationMgt.CompleteOperation(OperationID, 'Multi-step process completed successfully');
    end;

    local procedure UpdateStepProgress(OperationID: Guid; CurrentStep: Integer; TotalSteps: Integer; Activity: Text[250])
    var
        LongRunningOperation: Record "Long Running Operation";
        ProgressPercentage: Decimal;
    begin
        ProgressPercentage := (CurrentStep / TotalSteps) * 100;
        
        if LongRunningOperation.Get(OperationID) then begin
            LongRunningOperation."Current Step" := CurrentStep;
            LongRunningOperation."Progress Percentage" := ProgressPercentage;
            LongRunningOperation."Current Activity" := Activity;
            LongRunningOperation.Modify();
        end;
    end;

    local procedure ExecuteDataValidation(OperationID: Guid): Boolean
    begin
        // Simulate validation work
        Sleep(2000);
        
        if CheckCancellation(OperationID) then
            exit(false);
        
        exit(true);
    end;

    local procedure ExecuteDataBackup(OperationID: Guid): Boolean
    begin
        // Simulate backup work
        Sleep(5000);
        
        if CheckCancellation(OperationID) then
            exit(false);
        
        exit(true);
    end;

    local procedure ExecuteDataProcessing(OperationID: Guid): Boolean
    begin
        // Simulate processing work
        Sleep(10000);
        
        if CheckCancellation(OperationID) then
            exit(false);
        
        exit(true);
    end;

    local procedure ExecuteDataVerification(OperationID: Guid): Boolean
    begin
        // Simulate verification work
        Sleep(3000);
        
        if CheckCancellation(OperationID) then
            exit(false);
        
        exit(true);
    end;

    local procedure ExecuteCleanup(OperationID: Guid)
    begin
        // Simulate cleanup work
        Sleep(1000);
    end;

    local procedure CheckCancellation(OperationID: Guid): Boolean
    var
        LongRunningOperation: Record "Long Running Operation";
        LongRunningOperationMgt: Codeunit "Long Running Operation Mgmt";
    begin
        if LongRunningOperation.Get(OperationID) then
            if LongRunningOperation.Status = LongRunningOperation.Status::"Cancellation Requested" then begin
                LongRunningOperation.Status := LongRunningOperation.Status::Cancelled;
                LongRunningOperation."Completed At" := CurrentDateTime;
                LongRunningOperation.Modify();
                exit(true);
            end;
        
        exit(false);
    end;
}
```

## User Interface Pages

### Long-Running Operations List Page

```al
page 50410 "Long Running Operations"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Long Running Operation";
    Caption = 'Long Running Operations';
    Editable = false;
    CardPageId = "Long Running Operation Card";
    
    layout
    {
        area(Content)
        {
            repeater(Operations)
            {
                field("Operation Name"; Rec."Operation Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the operation.';
                }
                field("Operation Type"; Rec."Operation Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of operation.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the current status of the operation.';
                }
                field("Progress Percentage"; Rec."Progress Percentage")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the completion percentage of the operation.';
                    
                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Long Running Operation Card", Rec);
                    end;
                }
                field("Started At"; Rec."Started At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the operation was started.';
                }
                field("Started By"; Rec."Started By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who started the operation.';
                }
                field("Current Activity"; Rec."Current Activity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the current activity of the operation.';
                }
            }
        }
    }
    
    actions
    {
        area(Processing)
        {
            action(Refresh)
            {
                ApplicationArea = All;
                Caption = 'Refresh';
                ToolTip = 'Refresh the operation status.';
                Image = Refresh;
                
                trigger OnAction()
                begin
                    CurrPage.Update();
                end;
            }
            action(Cancel)
            {
                ApplicationArea = All;
                Caption = 'Cancel Operation';
                ToolTip = 'Cancel the selected operation.';
                Image = Cancel;
                Enabled = Rec."Can Cancel" and (Rec.Status = Rec.Status::Running);
                
                trigger OnAction()
                var
                    LongRunningOperationMgt: Codeunit "Long Running Operation Mgmt";
                begin
                    if Confirm('Are you sure you want to cancel this operation?') then begin
                        LongRunningOperationMgt.CancelOperation(Rec."Operation ID");
                        CurrPage.Update();
                    end;
                end;
            }
        }
    }
}
```

### Operation Details Card Page

```al
page 50411 "Long Running Operation Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "Long Running Operation";
    Caption = 'Long Running Operation';
    Editable = false;
    
    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                
                field("Operation Name"; Rec."Operation Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the operation.';
                }
                field("Operation Type"; Rec."Operation Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of operation.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the current status of the operation.';
                }
                field("Started At"; Rec."Started At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the operation was started.';
                }
                field("Started By"; Rec."Started By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who started the operation.';
                }
            }
            
            group(Progress)
            {
                Caption = 'Progress';
                
                field("Progress Percentage"; Rec."Progress Percentage")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the completion percentage of the operation.';
                }
                field("Current Step"; Rec."Current Step")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the current step number.';
                }
                field("Total Steps"; Rec."Total Steps")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total number of steps.';
                }
                field("Records Processed"; Rec."Records Processed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of records processed.';
                }
                field("Total Records"; Rec."Total Records")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total number of records to process.';
                }
                field("Current Activity"; Rec."Current Activity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the current activity of the operation.';
                }
            }
            
            group(Timing)
            {
                Caption = 'Timing';
                
                field("Estimated Completion"; Rec."Estimated Completion")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the estimated completion time.';
                }
                field("Completed At"; Rec."Completed At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the operation was completed.';
                }
                field("Duration Minutes"; Rec."Duration Minutes")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the duration of the operation in minutes.';
                }
                field("Last Updated"; Rec."Last Updated")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the operation status was last updated.';
                }
            }
            
            group(ErrorInfo)
            {
                Caption = 'Error Information';
                Visible = Rec.Status = Rec.Status::Failed;
                
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the error message if the operation failed.';
                    MultiLine = true;
                }
            }
        }
    }
    
    actions
    {
        area(Processing)
        {
            action(Refresh)
            {
                ApplicationArea = All;
                Caption = 'Refresh';
                ToolTip = 'Refresh the operation status.';
                Image = Refresh;
                
                trigger OnAction()
                begin
                    CurrPage.Update();
                end;
            }
            action(Cancel)
            {
                ApplicationArea = All;
                Caption = 'Cancel Operation';
                ToolTip = 'Cancel this operation.';
                Image = Cancel;
                Enabled = Rec."Can Cancel" and (Rec.Status = Rec.Status::Running);
                
                trigger OnAction()
                var
                    LongRunningOperationMgt: Codeunit "Long Running Operation Mgmt";
                begin
                    if Confirm('Are you sure you want to cancel this operation?') then begin
                        LongRunningOperationMgt.CancelOperation(Rec."Operation ID");
                        CurrPage.Update();
                    end;
                end;
            }
        }
    }
}
```

These samples demonstrate comprehensive BC long-running operation tracking using the platform's job queue framework, proper status management, and user-friendly monitoring interfaces.