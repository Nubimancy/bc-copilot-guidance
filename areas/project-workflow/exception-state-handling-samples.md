````markdown
# Exception State Handling Examples

## On Hold State Management Example

### GitHub Issue Template for On Hold State
```markdown
## 🚧 Feature On Hold: [Feature Name]

**Blocker Type**: [Technical/Business/Resource/External]
**Blocker Description**: 
Brief description of what is blocking progress

**Impact Assessment**:
- Timeline Impact: +[X] days/weeks
- Resource Impact: [Description]
- Dependent Features: [List affected features]

**Resolution Requirements**:
- [ ] Action Item 1 - Assigned to: [@username]
- [ ] Action Item 2 - Assigned to: [@username]
- [ ] External dependency resolution - ETA: [Date]

**Next Review Date**: [Date]
**Escalation Trigger**: [Conditions that require escalation]

**Stakeholders Notified**:
- [ ] Product Owner
- [ ] Development Team
- [ ] Business Stakeholders
- [ ] Project Manager
```

### PowerShell Script for On Hold Processing
```powershell
param(
    [string]$FeatureID,
    [string]$BlockerReason,
    [string]$ExpectedResolutionDate,
    [string[]]$ResponsibleParties
)

# Update feature state to On Hold
$onHoldData = @{
    State = "OnHold"
    BlockerReason = $BlockerReason
    ExpectedResolution = $ExpectedResolutionDate
    ResponsibleParties = $ResponsibleParties -join ","
    OnHoldDate = (Get-Date).ToString("yyyy-MM-dd")
}

# Log on hold event
Write-EventLog -LogName "FeatureManagement" -Source "StateManager" -EntryType Information -EventId 1001 -Message "Feature $FeatureID placed on hold: $BlockerReason"

# Send notifications
Send-OnHoldNotifications -FeatureID $FeatureID -Data $onHoldData
```
````

````al
// Exception State Handler for Business Central
codeunit 50220 "Exception State Handler"
{
    procedure PlaceFeatureOnHold(FeatureID: Code[20]; BlockerReason: Text; ExpectedResolution: Date): Boolean
    var
        FeatureRecord: Record "Feature Development";
        OnHoldRecord: Record "Feature On Hold";
        NotificationManager: Codeunit "Notification Manager";
    begin
        // Update main feature record
        FeatureRecord.Get(FeatureID);
        FeatureRecord."Previous State" := FeatureRecord."Current State";
        FeatureRecord."Current State" := FeatureRecord."Current State"::"On Hold";
        FeatureRecord."State Change Date" := CurrentDateTime();
        FeatureRecord.Modify(true);
        
        // Create on hold record
        OnHoldRecord.Init();
        OnHoldRecord."Feature ID" := FeatureID;
        OnHoldRecord."Blocker Reason" := BlockerReason;
        OnHoldRecord."On Hold Date" := CurrentDateTime();
        OnHoldRecord."Expected Resolution" := ExpectedResolution;
        OnHoldRecord."Created By" := UserId();
        OnHoldRecord.Insert(true);
        
        // Send notifications
        NotificationManager.NotifyFeatureOnHold(FeatureID, BlockerReason);
        
        exit(true);
    end;

    procedure CancelFeature(FeatureID: Code[20]; CancellationReason: Text): Boolean
    var
        FeatureRecord: Record "Feature Development";
        CancellationRecord: Record "Feature Cancellation";
        ArchiveManager: Codeunit "Feature Archive Manager";
        NotificationManager: Codeunit "Notification Manager";
    begin
        // Update main feature record
        FeatureRecord.Get(FeatureID);
        FeatureRecord."Previous State" := FeatureRecord."Current State";
        FeatureRecord."Current State" := FeatureRecord."Current State"::Cancelled;
        FeatureRecord."State Change Date" := CurrentDateTime();
        FeatureRecord.Modify(true);
        
        // Create cancellation record
        CancellationRecord.Init();
        CancellationRecord."Feature ID" := FeatureID;
        CancellationRecord."Cancellation Reason" := CancellationReason;
        CancellationRecord."Cancelled Date" := CurrentDateTime();
        CancellationRecord."Cancelled By" := UserId();
        CancellationRecord.Insert(true);
        
        // Archive feature data
        ArchiveManager.ArchiveFeature(FeatureID);
        
        // Send notifications
        NotificationManager.NotifyFeatureCancelled(FeatureID, CancellationReason);
        
        exit(true);
    end;

    procedure ResumeFromOnHold(FeatureID: Code[20]; ResolutionNotes: Text): Boolean
    var
        FeatureRecord: Record "Feature Development";
        OnHoldRecord: Record "Feature On Hold";
        PreviousState: Enum "Feature State";
    begin
        // Get previous state before on hold
        FeatureRecord.Get(FeatureID);
        PreviousState := FeatureRecord."Previous State";
        
        // Update feature state
        FeatureRecord."Current State" := PreviousState;
        FeatureRecord."State Change Date" := CurrentDateTime();
        FeatureRecord.Modify(true);
        
        // Update on hold record
        OnHoldRecord.SetRange("Feature ID", FeatureID);
        OnHoldRecord.SetRange("Resolution Date", 0DT);
        if OnHoldRecord.FindLast() then begin
            OnHoldRecord."Resolution Date" := CurrentDateTime();
            OnHoldRecord."Resolution Notes" := ResolutionNotes;
            OnHoldRecord."Resolved By" := UserId();
            OnHoldRecord.Modify(true);
        end;
        
        exit(true);
    end;
}
````

````json
{
  "exceptionStateConfiguration": {
    "onHoldStates": {
      "maxDurationDays": 30,
      "reviewFrequencyDays": 7,
      "autoEscalationDays": 14,
      "blockerTypes": [
        {
          "type": "Technical",
          "description": "Technical blockers requiring engineering resolution",
          "escalationPath": ["TechLead", "Engineering Manager", "CTO"]
        },
        {
          "type": "Business",
          "description": "Business decision or priority blockers",
          "escalationPath": ["Product Owner", "Product Manager", "VP Product"]
        },
        {
          "type": "Resource",
          "description": "Resource availability or allocation blockers",
          "escalationPath": ["Project Manager", "Resource Manager", "Director"]
        },
        {
          "type": "External",
          "description": "Third-party or vendor dependency blockers",
          "escalationPath": ["Integration Lead", "Vendor Manager", "Executive Sponsor"]
        }
      ]
    },
    "cancellationProcedures": {
      "approvalRequired": true,
      "approverRoles": ["Product Owner", "Project Manager"],
      "impactAssessmentRequired": true,
      "knowledgeRetentionRequired": true,
      "archivalPolicy": {
        "retentionPeriodYears": 3,
        "documentationRequired": ["Requirements", "Technical Design", "Code Changes"],
        "accessLevel": "Team Lead and Above"
      }
    },
    "notificationRules": {
      "onHoldNotifications": {
        "immediate": ["Feature Owner", "Product Owner", "Project Manager"],
        "daily": ["Development Team"],
        "weekly": ["Stakeholders"]
      },
      "cancellationNotifications": {
        "immediate": ["All Stakeholders", "Development Team", "Management"],
        "postCancellation": ["Resource Planning", "Project Planning"]
      }
    }
  }
}
````
