````yaml
# GitHub Actions Workflow for Business Central
name: CI/CD Pipeline for Business Central Extension

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  AL_GO_VERSION: 'latest'
  ARTIFACT_URL: 'https://bcartifacts.azureedge.net/sandbox/latest'

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
      
    - name: Setup AL-Go
      uses: microsoft/AL-Go-Actions/Setup@main
      with:
        go-version: '${{ env.AL_GO_VERSION }}'
        
    - name: Build Extension
      uses: microsoft/AL-Go-Actions/BuildApp@main
      with:
        artifact: '${{ env.ARTIFACT_URL }}'
        
    - name: Run Unit Tests
      uses: microsoft/AL-Go-Actions/RunTests@main
      with:
        tests: 'unit'
        
    - name: Run Integration Tests  
      uses: microsoft/AL-Go-Actions/RunTests@main
      with:
        tests: 'integration'
        
    - name: Generate Test Reports
      uses: microsoft/AL-Go-Actions/PublishResults@main
      with:
        publish-junit: true
        
    - name: Quality Gate Check
      run: |
        echo "Checking quality gates..."
        # Add quality gate validation logic here
        
  deploy-dev:
    needs: build-and-test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    
    environment: development
    
    steps:
    - name: Deploy to Development
      uses: microsoft/AL-Go-Actions/Deploy@main
      with:
        environment: 'dev'
        
  deploy-prod:
    needs: build-and-test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    environment: production
    
    steps:
    - name: Deploy to Production
      uses: microsoft/AL-Go-Actions/Deploy@main
      with:
        environment: 'prod'
        approval-required: true
````

````powershell
# PowerShell script for Azure DevOps Pipeline
# azure-pipelines.yml equivalent functionality

param(
    [string]$Environment = "dev",
    [string]$ArtifactUrl = "https://bcartifacts.azureedge.net/sandbox/latest"
)

# Build stage implementation
function Invoke-BuildStage {
    Write-Host "Starting build stage..."
    
    # Setup Business Central environment
    $containerName = "bc-build-$((Get-Date).Ticks)"
    
    try {
        # Create BC container for build
        New-BCContainer -containerName $containerName -artifactUrl $ArtifactUrl
        
        # Compile extension
        Compile-AppInBCContainer -containerName $containerName -appProjectFolder "."
        
        # Export app file
        Get-AppFromBCContainer -containerName $containerName -appName "MyExtension" -appFile "MyExtension.app"
        
        Write-Host "Build completed successfully"
    }
    finally {
        # Cleanup
        Remove-BCContainer -containerName $containerName
    }
}

# Test stage implementation
function Invoke-TestStage {
    param([string]$AppFile)
    
    Write-Host "Starting test stage..."
    
    $containerName = "bc-test-$((Get-Date).Ticks)"
    
    try {
        # Create test container
        New-BCContainer -containerName $containerName -artifactUrl $ArtifactUrl
        
        # Install app
        Publish-BCContainerApp -containerName $containerName -appFile $AppFile -sync -install
        
        # Run tests
        Run-TestsInBCContainer -containerName $containerName -testSuite "MyExtensionTests" -JUnitResultsFile "test-results.xml"
        
        Write-Host "Tests completed successfully"
    }
    finally {
        Remove-BCContainer -containerName $containerName
    }
}

# Quality gate validation
function Test-QualityGates {
    param([string]$TestResultsFile)
    
    Write-Host "Validating quality gates..."
    
    # Parse test results
    [xml]$testResults = Get-Content $TestResultsFile
    $totalTests = $testResults.testsuite.tests
    $failures = $testResults.testsuite.failures
    
    # Calculate pass rate
    $passRate = (($totalTests - $failures) / $totalTests) * 100
    
    if ($passRate -lt 80) {
        throw "Test pass rate ($passRate%) below threshold (80%)"
    }
    
    Write-Host "Quality gates passed successfully"
}

# Execute pipeline stages
Invoke-BuildStage
Invoke-TestStage -AppFile "MyExtension.app"
Test-QualityGates -TestResultsFile "test-results.xml"
````

````al
// Business Central integration with CI/CD pipeline
codeunit 50180 "CICD Pipeline Integration"
{
    procedure TriggerBuildPipeline(ProjectID: Code[20]): Boolean
    var
        PipelineConnector: Codeunit "Pipeline API Connector";
        BuildRequest: JsonObject;
        BuildResult: JsonObject;
        BuildID: Text;
    begin
        // Prepare build request
        BuildRequest.Add('projectId', ProjectID);
        BuildRequest.Add('branch', GetCurrentBranch(ProjectID));
        BuildRequest.Add('triggerReason', 'Manual trigger from Business Central');
        
        // Trigger build
        BuildResult := PipelineConnector.TriggerBuild(BuildRequest);
        
        // Extract build ID
        if ExtractBuildID(BuildResult, BuildID) then begin
            // Store build information
            StoreBuildInformation(ProjectID, BuildID, BuildResult);
            exit(true);
        end;
        
        exit(false);
    end;

    procedure MonitorBuildStatus(ProjectID: Code[20]; BuildID: Text): Text
    var
        PipelineConnector: Codeunit "Pipeline API Connector";
        StatusResponse: JsonObject;
        BuildStatus: Text;
    begin
        // Get current build status
        StatusResponse := PipelineConnector.GetBuildStatus(BuildID);
        
        if ExtractBuildStatus(StatusResponse, BuildStatus) then begin
            // Update local status
            UpdateBuildStatus(ProjectID, BuildID, BuildStatus);
            
            // Handle status changes
            HandleStatusChange(ProjectID, BuildID, BuildStatus);
        end;
        
        exit(BuildStatus);
    end;

    procedure GetDeploymentStatus(ProjectID: Code[20]; Environment: Text): Record "Deployment Status"
    var
        DeploymentStatus: Record "Deployment Status";
        PipelineConnector: Codeunit "Pipeline API Connector";
        StatusData: JsonObject;
    begin
        StatusData := PipelineConnector.GetDeploymentStatus(ProjectID, Environment);
        
        DeploymentStatus := ParseDeploymentStatus(StatusData, ProjectID, Environment);
        
        exit(DeploymentStatus);
    end;

    local procedure StoreBuildInformation(ProjectID: Code[20]; BuildID: Text; BuildData: JsonObject)
    var
        BuildRecord: Record "Pipeline Build";
        StartTime: DateTime;
        CommitHash: Text;
    begin
        BuildRecord.Init();
        BuildRecord."Project ID" := ProjectID;
        BuildRecord."Build ID" := BuildID;
        BuildRecord."Build Status" := BuildRecord."Build Status"::Running;
        BuildRecord."Start Time" := CurrentDateTime();
        
        // Extract additional information
        ExtractBuildDetails(BuildData, StartTime, CommitHash);
        BuildRecord."Commit Hash" := CommitHash;
        
        BuildRecord.Insert(true);
    end;

    local procedure HandleStatusChange(ProjectID: Code[20]; BuildID: Text; NewStatus: Text)
    var
        NotificationManager: Codeunit "Build Notification Manager";
    begin
        case NewStatus of
            'COMPLETED':
                NotificationManager.NotifyBuildSuccess(ProjectID, BuildID);
            'FAILED':
                NotificationManager.NotifyBuildFailure(ProjectID, BuildID);
            'CANCELLED':
                NotificationManager.NotifyBuildCancelled(ProjectID, BuildID);
        end;
    end;
}
````
