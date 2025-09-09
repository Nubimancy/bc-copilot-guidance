```bash
# ✅ GitHub Integration Scripts

# Feature Branch Workflow with Issue Linking
create_feature_branch() {
    local issue_number=$1
    local feature_name=$2
    
    # Create and switch to feature branch
    git checkout -b "feature/${feature_name}"
    
    # Add branch description linking to issue
    git config branch."feature/${feature_name}".description "Feature implementation for issue #${issue_number}"
    
    echo "Created feature branch: feature/${feature_name}"
    echo "Linked to issue: #${issue_number}"
}

# Commit with automatic issue linking
commit_with_issue_link() {
    local issue_number=$1
    local commit_message=$2
    local implementation_detail=$3
    
    git commit -m "feat: ${commit_message}

Addresses #${issue_number}
- ${implementation_detail}
- Test coverage added
- Documentation updated

Co-authored-by: GitHub Copilot <copilot@github.com>"
}

# Create pull request with comprehensive context
create_contextual_pr() {
    local issue_number=$1
    local pr_title=$2
    local feature_description=$3
    
    # Create PR body with template
    cat > pr_body.md << EOF
## Feature Implementation

**Related Issue:** Closes #${issue_number}

**Description:**
${feature_description}

**Acceptance Criteria Checklist:**
- [ ] Feature meets all specified requirements
- [ ] Code follows AL development best practices  
- [ ] Unit tests added with >80% coverage
- [ ] Integration tests validate end-to-end functionality
- [ ] Documentation updated
- [ ] Performance impact assessed

**Testing Strategy:**
- [ ] Unit tests cover core business logic
- [ ] Integration tests validate system connections
- [ ] User acceptance testing completed
- [ ] Performance regression testing completed

**Review Checklist:**
- [ ] Code follows naming conventions
- [ ] Error handling implemented properly
- [ ] Security considerations addressed
- [ ] Business logic validated against requirements

**Deployment Notes:**
- [ ] Database changes documented
- [ ] Configuration updates identified
- [ ] Rollback procedures defined
EOF

    # Create pull request using GitHub CLI
    gh pr create --title "${pr_title}" --body-file pr_body.md --assignee @me
    
    # Clean up temporary file
    rm pr_body.md
}

# GitHub CLI Issue Management
manage_github_issues() {
    local action=$1
    local issue_number=$2
    
    case $action in
        "create")
            local title=$3
            local template=$4
            gh issue create --title "${title}" --body-file "${template}"
            ;;
        "assign")
            local assignee=$3
            gh issue edit "${issue_number}" --assignee "${assignee}"
            ;;
        "milestone")
            local milestone=$3
            gh issue edit "${issue_number}" --milestone "${milestone}"
            ;;
        "label")
            local label=$3
            gh issue edit "${issue_number}" --add-label "${label}"
            ;;
        "close")
            local close_comment=$3
            gh issue close "${issue_number}" --comment "${close_comment}"
            ;;
    esac
}

# Automated project board updates
update_project_board() {
    local issue_number=$1
    local status=$2
    local project_id=$3
    
    # Move issue to appropriate column based on status
    case $status in
        "in-progress")
            gh api graphql -f query='
                mutation {
                  updateProjectV2ItemFieldValue(input: {
                    projectId: "'${project_id}'"
                    itemId: "'${issue_number}'"
                    fieldId: "status"
                    value: {text: "In Progress"}
                  }) {
                    projectV2Item { id }
                  }
                }'
            ;;
        "review")
            # Move to review column and assign reviewers
            gh api graphql -f query='...' # Similar GraphQL mutation
            ;;
        "done")
            # Move to done column and update completion date
            gh api graphql -f query='...' # Similar GraphQL mutation
            ;;
    esac
}
```

```powershell
# ✅ Azure DevOps Integration PowerShell Scripts

# Azure DevOps Work Item Integration
function Connect-AzureDevOpsWorkItem {
    param(
        [string]$Organization,
        [string]$Project,
        [int]$WorkItemId,
        [string]$PersonalAccessToken
    )
    
    # Set up authentication
    $headers = @{
        'Authorization' = "Basic $([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$PersonalAccessToken")))"
        'Content-Type' = 'application/json'
    }
    
    # Get work item details
    $workItemUrl = "https://dev.azure.com/$Organization/$Project/_apis/wit/workitems/$WorkItemId"
    $response = Invoke-RestMethod -Uri $workItemUrl -Headers $headers -Method Get
    
    return $response
}

function Create-WorkItemLink {
    param(
        [string]$Organization,
        [string]$Project,
        [int]$WorkItemId,
        [string]$CommitId,
        [string]$Repository,
        [string]$PersonalAccessToken
    )
    
    $headers = @{
        'Authorization' = "Basic $([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$PersonalAccessToken")))"
        'Content-Type' = 'application/json-patch+json'
    }
    
    # Create link between work item and commit
    $linkData = @(
        @{
            'op' = 'add'
            'path' = '/relations/-'
            'value' = @{
                'rel' = 'ArtifactLink'
                'url' = "vstfs:///Git/Commit/$CommitId"
                'attributes' = @{
                    'comment' = 'Code changes for work item implementation'
                }
            }
        }
    )
    
    $workItemUrl = "https://dev.azure.com/$Organization/$Project/_apis/wit/workitems/$WorkItemId"
    Invoke-RestMethod -Uri $workItemUrl -Headers $headers -Method Patch -Body ($linkData | ConvertTo-Json -Depth 5)
}

function Update-WorkItemStatus {
    param(
        [string]$Organization,
        [string]$Project,
        [int]$WorkItemId,
        [string]$NewState,
        [string]$PersonalAccessToken
    )
    
    $headers = @{
        'Authorization' = "Basic $([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$PersonalAccessToken")))"
        'Content-Type' = 'application/json-patch+json'
    }
    
    $updateData = @(
        @{
            'op' = 'replace'
            'path' = '/fields/System.State'
            'value' = $NewState
        }
    )
    
    $workItemUrl = "https://dev.azure.com/$Organization/$Project/_apis/wit/workitems/$WorkItemId"
    Invoke-RestMethod -Uri $workItemUrl -Headers $headers -Method Patch -Body ($updateData | ConvertTo-Json -Depth 3)
}

# Batch work item operations
function Get-ProjectWorkItems {
    param(
        [string]$Organization,
        [string]$Project,
        [string]$Query,
        [string]$PersonalAccessToken
    )
    
    $headers = @{
        'Authorization' = "Basic $([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$PersonalAccessToken")))"
        'Content-Type' = 'application/json'
    }
    
    $queryData = @{
        'query' = $Query
    } | ConvertTo-Json
    
    $queryUrl = "https://dev.azure.com/$Organization/$Project/_apis/wit/wiql"
    $queryResult = Invoke-RestMethod -Uri $queryUrl -Headers $headers -Method Post -Body $queryData
    
    # Get detailed work item information
    $workItemIds = $queryResult.workItems | ForEach-Object { $_.id }
    $workItemsUrl = "https://dev.azure.com/$Organization/$Project/_apis/wit/workitems?ids=$($workItemIds -join ',')"
    $workItems = Invoke-RestMethod -Uri $workItemsUrl -Headers $headers -Method Get
    
    return $workItems.value
}

function Create-FeatureWorkItem {
    param(
        [string]$Organization,
        [string]$Project,
        [string]$Title,
        [string]$Description,
        [string]$AcceptanceCriteria,
        [string]$PersonalAccessToken
    )
    
    $headers = @{
        'Authorization' = "Basic $([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$PersonalAccessToken")))"
        'Content-Type' = 'application/json-patch+json'
    }
    
    $workItemData = @(
        @{
            'op' = 'add'
            'path' = '/fields/System.Title'
            'value' = $Title
        },
        @{
            'op' = 'add'
            'path' = '/fields/System.Description'
            'value' = $Description
        },
        @{
            'op' = 'add'
            'path' = '/fields/Microsoft.VSTS.Common.AcceptanceCriteria'
            'value' = $AcceptanceCriteria
        }
    )
    
    $createUrl = "https://dev.azure.com/$Organization/$Project/_apis/wit/workitems/`$Feature"
    $newWorkItem = Invoke-RestMethod -Uri $createUrl -Headers $headers -Method Post -Body ($workItemData | ConvertTo-Json -Depth 3)
    
    return $newWorkItem
}
```

```al
// ✅ Business Central Integration with Project Management Tools
codeunit 50160 "Project Tool Integration"
{
    procedure SyncWithGitHubIssue(IssueNumber: Integer; Repository: Text): Boolean
    var
        GitHubConnector: Codeunit "GitHub API Connector";
        IssueData: JsonObject;
        SyncResult: Boolean;
    begin
        // Get issue details from GitHub
        IssueData := GitHubConnector.GetIssueDetails(Repository, IssueNumber);
        
        // Create or update local project record
        SyncResult := CreateLocalProjectRecord(IssueData, Repository);
        
        // Update project status based on GitHub issue state
        if SyncResult then
            SyncResult := UpdateProjectStatus(IssueData);
            
        exit(SyncResult);
    end;

    procedure CreateGitHubIssue(ProjectID: Code[20]; Title: Text; Description: Text): Integer
    var
        GitHubConnector: Codeunit "GitHub API Connector";
        ProjectRecord: Record "Development Project";
        IssueData: JsonObject;
        IssueNumber: Integer;
    begin
        if not ProjectRecord.Get(ProjectID) then
            Error('Project %1 not found', ProjectID);

        // Prepare issue data
        IssueData.Add('title', Title);
        IssueData.Add('body', Description);
        IssueData.Add('assignees', CreateAssigneeArray(ProjectRecord."Assigned To"));
        IssueData.Add('labels', CreateLabelArray(ProjectRecord."Project Type", ProjectRecord.Priority));

        // Create issue in GitHub
        IssueNumber := GitHubConnector.CreateIssue(ProjectRecord.Repository, IssueData);
        
        // Update local record with GitHub issue number
        if IssueNumber > 0 then begin
            ProjectRecord."GitHub Issue No." := IssueNumber;
            ProjectRecord."Integration Status" := ProjectRecord."Integration Status"::Synced;
            ProjectRecord.Modify(true);
        end;

        exit(IssueNumber);
    end;

    procedure SyncWithAzureDevOpsWorkItem(WorkItemID: Integer; Project: Text): Boolean
    var
        ADOConnector: Codeunit "Azure DevOps Connector";
        WorkItemData: JsonObject;
        SyncResult: Boolean;
    begin
        // Get work item details
        WorkItemData := ADOConnector.GetWorkItemDetails(Project, WorkItemID);
        
        // Create or update local project record
        SyncResult := CreateLocalProjectRecord(WorkItemData, Project);
        
        // Sync related work items (parent/child relationships)
        if SyncResult then
            SyncResult := SyncRelatedWorkItems(WorkItemData, Project);
            
        exit(SyncResult);
    end;

    local procedure CreateLocalProjectRecord(ItemData: JsonObject; Source: Text): Boolean
    var
        ProjectRecord: Record "Development Project";
        ProjectID: Code[20];
        Title: Text;
        Description: Text;
        State: Text;
    begin
        // Extract data from JSON
        if not ExtractItemData(ItemData, ProjectID, Title, Description, State) then
            exit(false);

        // Create or update project record
        if not ProjectRecord.Get(ProjectID) then begin
            ProjectRecord.Init();
            ProjectRecord."Project ID" := ProjectID;
            ProjectRecord."Creation Date" := Today;
            ProjectRecord.Insert(true);
        end;

        // Update project fields
        ProjectRecord.Title := Title;
        ProjectRecord.Description := Description;
        ProjectRecord."Project Status" := ConvertStateToStatus(State);
        ProjectRecord."Integration Source" := Source;
        ProjectRecord."Last Sync Date" := Today;
        ProjectRecord."Last Sync Time" := Time;
        ProjectRecord.Modify(true);

        exit(true);
    end;

    local procedure ExtractItemData(ItemData: JsonObject; var ProjectID: Code[20]; var Title: Text; var Description: Text; var State: Text): Boolean
    var
        IDToken: JsonToken;
        TitleToken: JsonToken;
        DescToken: JsonToken;
        StateToken: JsonToken;
    begin
        // Extract required fields
        if not ItemData.Get('number', IDToken) then
            if not ItemData.Get('id', IDToken) then
                exit(false);

        if not ItemData.Get('title', TitleToken) then
            exit(false);

        ItemData.Get('body', DescToken);
        ItemData.Get('state', StateToken);

        // Convert to AL types
        ProjectID := Format(IDToken.AsValue().AsInteger());
        Title := TitleToken.AsValue().AsText();
        Description := DescToken.AsValue().AsText();
        State := StateToken.AsValue().AsText();

        exit(true);
    end;

    local procedure ConvertStateToStatus(State: Text): Enum "Project Status"
    begin
        case LowerCase(State) of
            'open', 'new', 'active':
                exit("Project Status"::Active);
            'in progress', 'doing', 'development':
                exit("Project Status"::"In Progress");
            'closed', 'done', 'completed':
                exit("Project Status"::Completed);
            else
                exit("Project Status"::Pending);
        end;
    end;

    local procedure CreateAssigneeArray(AssignedTo: Code[50]): JsonArray
    var
        AssigneeArray: JsonArray;
    begin
        if AssignedTo <> '' then
            AssigneeArray.Add(AssignedTo);
        
        exit(AssigneeArray);
    end;

    local procedure CreateLabelArray(ProjectType: Text; Priority: Option): JsonArray
    var
        LabelArray: JsonArray;
    begin
        // Add project type label
        if ProjectType <> '' then
            LabelArray.Add(LowerCase(ProjectType));
        
        // Add priority label
        case Priority of
            Priority::High:
                LabelArray.Add('high-priority');
            Priority::Medium:
                LabelArray.Add('medium-priority');
            Priority::Low:
                LabelArray.Add('low-priority');
        end;

        exit(LabelArray);
    end;
}
```
