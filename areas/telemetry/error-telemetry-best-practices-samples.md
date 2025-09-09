---
title: "Error Telemetry Best Practices - Samples"
description: "Working AL code examples for implementing error telemetry patterns in Business Central applications"
area: "telemetry"
difficulty: "intermediate"
object_types: ["Codeunit", "Table", "Enum"]
variable_types: ["ErrorInfo", "JsonObject", "JsonArray", "Dictionary"]
tags: ["error-telemetry", "error-tracking", "error-classification", "automated-remediation", "diagnostics"]
---

# Error Telemetry Best Practices - Samples

## ErrorInfo Construction Patterns

### Basic ErrorInfo with BC Context

```al
procedure CreateStructuredError(ErrorMessage: Text; DetailedDescription: Text)
var
    ErrorInfo: ErrorInfo;
    CustomDimensions: Dictionary of [Text, Text];
    TelemetryCD: Codeunit Telemetry;
begin
    // Build BC-specific context
    CustomDimensions.Add('CompanyName', CompanyName);
    CustomDimensions.Add('CompanySystemId', Format(Company.SystemId));
    CustomDimensions.Add('UserId', UserId);
    CustomDimensions.Add('UserSecurityId', Format(UserSecurityId()));
    CustomDimensions.Add('SessionId', Format(SessionId()));
    
    // Create structured ErrorInfo
    ErrorInfo.Create(ErrorMessage, true, DataClassification::SystemMetadata);
    ErrorInfo.DetailedMessage := DetailedDescription;
    ErrorInfo.AddNavigationAction('View Error Log');
    ErrorInfo.CustomDimensions := CustomDimensions;
    
    // Log to telemetry before throwing
    TelemetryCD.LogMessage('0000ERR', ErrorMessage, Verbosity::Error, 
        DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
    
    Error(ErrorInfo);
end;
```

### Enhanced ErrorInfo with AL Stack Trace

```al
procedure CreateEnhancedError(ErrorMessage: Text; ErrorCategory: Enum "Error Category")
var
    ErrorInfo: ErrorInfo;
    CustomDimensions: Dictionary of [Text, Text];
    TelemetryCD: Codeunit Telemetry;
    CallStack: Text;
begin
    // Capture AL execution context
    CallStack := GetLastErrorCallStack();
    
    // Build comprehensive BC context
    AddBCContextToDimensions(CustomDimensions);
    CustomDimensions.Add('ErrorCategory', Format(ErrorCategory));
    CustomDimensions.Add('CallStack', CallStack);
    CustomDimensions.Add('ObjectType', Format(Session.GetCurrentModuleExecutionContext().ObjectType));
    CustomDimensions.Add('ObjectId', Format(Session.GetCurrentModuleExecutionContext().ObjectId));
    
    ErrorInfo.Create(ErrorMessage, true, DataClassification::SystemMetadata);
    ErrorInfo.ErrorType := ErrorType::Client;
    ErrorInfo.Verbosity := Verbosity::Error;
    ErrorInfo.CustomDimensions := CustomDimensions;
    
    // Log with specific error category event ID
    LogCategorizedError(ErrorCategory, ErrorMessage, CustomDimensions);
    
    Error(ErrorInfo);
end;
```

## BC Platform Integration Examples

### Telemetry Codeunit Usage Patterns

```al
codeunit 50100 "Error Telemetry Manager"
{
    var
        TelemetryCD: Codeunit Telemetry;
        EventIdPrefix: Text[4];

    trigger OnRun()
    begin
        EventIdPrefix := '0000'; // Follow BC event ID conventions
    end;

    procedure LogBusinessLogicError(ErrorMessage: Text; ProcessContext: Record "Process Context")
    var
        CustomDimensions: Dictionary of [Text, Text];
        EventId: Text[7];
    begin
        EventId := EventIdPrefix + 'BLE'; // Business Logic Error
        
        // Add BC business context
        CustomDimensions.Add('ProcessType', ProcessContext."Process Type");
        CustomDimensions.Add('DocumentType', ProcessContext."Document Type");
        CustomDimensions.Add('DocumentNo', ProcessContext."Document No.");
        AddStandardBCContext(CustomDimensions);
        
        TelemetryCD.LogMessage(EventId, ErrorMessage, Verbosity::Error,
            DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
    end;

    procedure LogIntegrationError(ErrorMessage: Text; EndpointUrl: Text; HttpStatusCode: Integer)
    var
        CustomDimensions: Dictionary of [Text, Text];
        EventId: Text[7];
    begin
        EventId := EventIdPrefix + 'INT'; // Integration Error
        
        CustomDimensions.Add('EndpointUrl', EndpointUrl);
        CustomDimensions.Add('HttpStatusCode', Format(HttpStatusCode));
        CustomDimensions.Add('IntegrationType', 'WebService');
        AddStandardBCContext(CustomDimensions);
        
        TelemetryCD.LogMessage(EventId, ErrorMessage, Verbosity::Error,
            DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, CustomDimensions);
    end;

    local procedure AddStandardBCContext(var CustomDimensions: Dictionary of [Text, Text])
    begin
        CustomDimensions.Add('CompanyName', CompanyName);
        CustomDimensions.Add('UserId', UserId);
        CustomDimensions.Add('ALVersion', GetALVersion());
        CustomDimensions.Add('PlatformVersion', GetPlatformVersion());
        CustomDimensions.Add('EnvironmentType', Format(EnvironmentInfo.GetEnvironmentType()));
        CustomDimensions.Add('TenantId', GetTenantId());
    end;
}
```

## Error Classification Implementation

### BC-Specific Error Categories

```al
enum 50100 "Error Category"
{
    Extensible = true;
    
    value(0; ALRuntime) { Caption = 'AL Runtime Error'; }
    value(1; DatabaseError) { Caption = 'Database Error'; }
    value(2; IntegrationError) { Caption = 'Integration Error'; }
    value(3; BusinessLogicError) { Caption = 'Business Logic Error'; }
    value(4; PlatformError) { Caption = 'Platform Error'; }
    value(5; ExtensionConflict) { Caption = 'Extension Conflict'; }
    value(6; PermissionError) { Caption = 'Permission Error'; }
    value(7; ValidationError) { Caption = 'Validation Error'; }
    value(8; PostingError) { Caption = 'Posting Error'; }
    value(9; WorkflowError) { Caption = 'Workflow Error'; }
}

codeunit 50101 "Error Classification Engine"
{
    procedure ClassifyError(ErrorMessage: Text; ErrorContext: JsonObject): Enum "Error Category"
    var
        ErrorCategory: Enum "Error Category";
    begin
        // Pattern matching for BC-specific error types
        if ContainsPattern(ErrorMessage, 'permission', 'access denied', 'not allowed') then
            exit(ErrorCategory::PermissionError);
            
        if ContainsPattern(ErrorMessage, 'database', 'sql', 'timeout', 'deadlock') then
            exit(ErrorCategory::DatabaseError);
            
        if ContainsPattern(ErrorMessage, 'web service', 'http', 'connection', 'endpoint') then
            exit(ErrorCategory::IntegrationError);
            
        if ContainsPattern(ErrorMessage, 'posting', 'document', 'dimension', 'balance') then
            exit(ErrorCategory::PostingError);
            
        // Default to AL Runtime for unclassified errors
        exit(ErrorCategory::ALRuntime);
    end;

    local procedure ContainsPattern(ErrorText: Text; Pattern1: Text; Pattern2: Text; Pattern3: Text): Boolean
    begin
        ErrorText := LowerCase(ErrorText);
        exit(StrPos(ErrorText, Pattern1) > 0) or (StrPos(ErrorText, Pattern2) > 0) or (StrPos(ErrorText, Pattern3) > 0);
    end;
}
```

## Performance Monitoring Integration

### BC Resource Tracking with Errors

```al
codeunit 50102 "Error Performance Tracker"
{
    procedure TrackErrorWithPerformanceImpact(ErrorInfo: ErrorInfo; StartTime: DateTime)
    var
        CustomDimensions: Dictionary of [Text, Text];
        TelemetryCD: Codeunit Telemetry;
        ExecutionTime: Duration;
        MemoryUsage: BigInteger;
    begin
        ExecutionTime := CurrentDateTime - StartTime;
        MemoryUsage := GetMemoryUsage(); // Custom procedure
        
        // Add performance metrics to error context
        CustomDimensions.Add('ExecutionTimeMs', Format(ExecutionTime));
        CustomDimensions.Add('MemoryUsageMB', Format(MemoryUsage));
        CustomDimensions.Add('DatabaseCalls', Format(GetDatabaseCallCount()));
        CustomDimensions.Add('ActiveSessions', Format(GetActiveSessionCount()));
        
        // Include standard BC context
        AddBCPerformanceContext(CustomDimensions);
        
        TelemetryCD.LogMessage('0000PER', 'Error with Performance Impact', 
            Verbosity::Warning, DataClassification::SystemMetadata, 
            TelemetryScope::ExtensionPublisher, CustomDimensions);
    end;

    local procedure AddBCPerformanceContext(var CustomDimensions: Dictionary of [Text, Text])
    var
        CompanyInfo: Record "Company Information";
        UserSetup: Record "User Setup";
    begin
        CustomDimensions.Add('CompanySize', GetCompanyDataSize());
        CustomDimensions.Add('UserRole', GetUserRole());
        CustomDimensions.Add('SessionType', Format(Session.DefaultClientType()));
        CustomDimensions.Add('IsBackgroundSession', Format(Session.IsSessionActive()));
    end;
}
```

## Application Insights Integration

### Custom Dimensions for BC Context

```al
codeunit 50103 "BC Telemetry Dimensions"
{
    procedure CreateBCSpecificDimensions(): Dictionary of [Text, Text]
    var
        Dimensions: Dictionary of [Text, Text];
        Company: Record Company;
        User: Record User;
    begin
        // Core BC identifiers
        if Company.Get(CompanyName) then begin
            Dimensions.Add('bc_company_name', Company.Name);
            Dimensions.Add('bc_company_id', Format(Company.SystemId));
        end;
        
        if User.Get(UserSecurityId()) then begin
            Dimensions.Add('bc_user_name', User."User Name");
            Dimensions.Add('bc_user_id', Format(User."User Security ID"));
        end;
        
        // BC platform context
        Dimensions.Add('bc_al_version', GetALVersion());
        Dimensions.Add('bc_platform_version', GetPlatformVersion());
        Dimensions.Add('bc_environment_type', Format(EnvironmentInfo.GetEnvironmentType()));
        Dimensions.Add('bc_tenant_id', GetTenantId());
        
        // BC session context
        Dimensions.Add('bc_session_id', Format(SessionId()));
        Dimensions.Add('bc_client_type', Format(Session.DefaultClientType()));
        Dimensions.Add('bc_language_id', Format(GlobalLanguage()));
        
        exit(Dimensions);
    end;

    procedure AddErrorSpecificDimensions(var Dimensions: Dictionary of [Text, Text]; ErrorCategory: Enum "Error Category")
    begin
        Dimensions.Add('bc_error_category', Format(ErrorCategory));
        Dimensions.Add('bc_error_timestamp', Format(CurrentDateTime, 0, 9));
        Dimensions.Add('bc_call_stack', GetLastErrorCallStack());
        
        // Add current object context
        Dimensions.Add('bc_object_type', Format(Session.GetCurrentModuleExecutionContext().ObjectType));
        Dimensions.Add('bc_object_id', Format(Session.GetCurrentModuleExecutionContext().ObjectId));
    end;
}
```

## Multi-Tenant Error Handling

### Tenant-Aware Error Telemetry

```al
codeunit 50104 "Multi-Tenant Error Handler"
{
    procedure LogTenantSpecificError(ErrorMessage: Text; TenantContext: JsonObject)
    var
        CustomDimensions: Dictionary of [Text, Text];
        TelemetryCD: Codeunit Telemetry;
        TenantId: Text;
    begin
        TenantId := GetTenantId();
        
        // Tenant isolation in error tracking
        CustomDimensions.Add('tenant_id', TenantId);
        CustomDimensions.Add('tenant_environment', GetTenantEnvironmentType());
        CustomDimensions.Add('tenant_region', GetTenantRegion());
        
        // Extract tenant-specific context from JsonObject
        if TenantContext.Contains('custom_tenant_data') then
            CustomDimensions.Add('tenant_custom_data', GetJsonValue(TenantContext, 'custom_tenant_data'));
            
        // Standard BC context
        AddStandardBCContext(CustomDimensions);
        
        // Use tenant-scoped telemetry
        TelemetryCD.LogMessage('0000TNT', ErrorMessage, Verbosity::Error,
            DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
    end;

    local procedure GetTenantEnvironmentType(): Text
    var
        EnvironmentInfo: Codeunit "Environment Information";
    begin
        case EnvironmentInfo.GetEnvironmentType() of
            EnvironmentType::Production:
                exit('Production');
            EnvironmentType::Sandbox:
                exit('Sandbox');
            else
                exit('Unknown');
        end;
    end;
}
```