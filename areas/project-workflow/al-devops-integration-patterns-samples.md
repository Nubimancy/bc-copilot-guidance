# AL DevOps Integration Patterns - Code Samples

## Basic Work Item Integration

### Work Item Reference in AL Comments

```al
// Work Item #12345: Implement customer validation enhancement
// Feature: Enhanced Customer Validation
codeunit 50100 "Customer Validation Enhanced"
{
    // Implementation tracks to DevOps work item for traceability
    procedure ValidateCustomer(Customer: Record Customer): Boolean
    {
        // Work item requirements implemented here
    }
}
```

### Branch Naming and AL Object Correlation

```powershell
# Create feature branch linked to work item
git checkout -b feature/wi-12345-customer-validation-enhancement

# AL object development in feature branch
# Objects: Codeunit 50100, PageExt 50101, TableExt 50102
```

## DevOps Pipeline Configuration

### AL Build Pipeline (azure-pipelines.yml)

```yaml
# AL-specific DevOps pipeline configuration
trigger:
  branches:
    include:
    - main
    - feature/*
  paths:
    include:
    - 'src/**'
    - '*.app'

variables:
  ALProjectPath: '$(System.DefaultWorkingDirectory)/src'
  
stages:
- stage: Build
  jobs:
  - job: CompileAL
    steps:
    - task: ALOpsDockerCreate@1
      inputs:
        artifacttype: 'OnPrem'
        
    - task: ALOpsDockerStart@1
      
    - task: ALOpsImportFob@1
      inputs:
        filePath: '$(ALProjectPath)/**/*.al'
        
    - task: ALOpsCompilerTask@1
      inputs:
        projectpath: '$(ALProjectPath)'
        outputpath: '$(Build.ArtifactStagingDirectory)'
```

### Work Item Update Automation

```powershell
# PowerShell script for DevOps work item updates
param(
    [string]$WorkItemId,
    [string]$ALObjectName,
    [string]$Status
)

# Update work item with AL development progress
$workItem = Get-WorkItem -Id $WorkItemId
$workItem.Fields["System.Description"] += "`nAL Object Completed: $ALObjectName"
$workItem.Fields["System.State"] = $Status
$workItem.Save()
```

## Pull Request Integration

### PR Template for AL Changes

```markdown
## AL Development Summary
**Work Item**: #{{work-item-id}}
**AL Objects Modified**:
- [ ] Table Extensions: {{table-extensions}}
- [ ] Page Extensions: {{page-extensions}} 
- [ ] Codeunits: {{codeunits}}
- [ ] Other: {{other-objects}}

## Testing Completed
- [ ] Unit tests passing
- [ ] Integration tests validated
- [ ] Business logic verified
- [ ] Performance impact assessed

## DevOps Integration
- [ ] Work item updated with implementation details
- [ ] Branch follows naming convention
- [ ] AL objects documented in work item
```

### Automated Work Item Linking

```json
{
  "pullRequestId": 123,
  "workItemRefs": [
    {
      "id": "12345",
      "url": "https://dev.azure.com/org/project/_workitems/edit/12345"
    }
  ],
  "alObjectsModified": [
    "Codeunit 50100 Customer Validation Enhanced",
    "PageExt 50101 Customer Card Extension"
  ]
}
```

## Quality Gate Configuration

### AL Code Quality Gates

```yaml
# Quality gate configuration for AL projects
- task: SonarCloudPrepare@1
  inputs:
    SonarCloud: 'SonarCloud'
    organization: 'your-org'
    scannerMode: 'MSBuild'
    projectKey: 'al-project-key'
    extraProperties: |
      sonar.al.file.suffixes=.al
      sonar.sources=src/
      sonar.exclusions=**/test/**
      
- task: ALOpsLicenseImport@1
  inputs:
    usedocker: true
    license_path: '$(license.secureFilePath)'
    
- task: SonarCloudAnalyze@1
- task: SonarCloudPublish@1
```

### Test Integration in DevOps

```al
// AL Test Codeunit integrated with DevOps reporting
codeunit 50199 "Customer Validation Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;
    
    [Test]
    procedure TestCustomerValidationSuccess()
    var
        Customer: Record Customer;
        ValidationCodeunit: Codeunit "Customer Validation Enhanced";
    begin
        // Test implementation that reports to DevOps pipeline
        // Work Item #12345 - Test case validation
        
        // Arrange
        CreateTestCustomer(Customer);
        
        // Act & Assert
        Assert.IsTrue(ValidationCodeunit.ValidateCustomer(Customer), 
            'Customer validation should succeed for valid data');
    end;
}
```

## Advanced DevOps Integration

### AL Object Deployment Tracking

```powershell
# Track AL object deployments in work items
$deployedObjects = @(
    "Codeunit 50100 Customer Validation Enhanced",
    "PageExt 50101 Customer Card Extension",
    "TableExt 50102 Customer Table Extension"
)

foreach ($alObject in $deployedObjects) {
    $workItemUpdate = @{
        "op" = "add"
        "path" = "/fields/Custom.ALObjectsDeployed"
        "value" = "$alObject deployed on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    }
    
    Update-WorkItem -WorkItemId $WorkItemId -Updates @($workItemUpdate)
}
```

### Performance Metrics Integration

```al
// AL performance monitoring integrated with DevOps metrics
codeunit 50200 "Performance Monitoring"
{
    procedure TrackALPerformance(ObjectName: Text; ExecutionTime: Duration)
    var
        TelemetryClient: Codeunit "Telemetry Client";
    begin
        // Send performance data to DevOps analytics
        TelemetryClient.LogMessage(
            'AL-Performance', 
            StrSubstNo('Object: %1, ExecutionTime: %2ms', ObjectName, ExecutionTime),
            Verbosity::Normal
        );
    end;
}
```
