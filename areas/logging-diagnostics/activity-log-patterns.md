---
title: "Activity Log Patterns"
description: "Comprehensive activity logging patterns for Business Central with intelligent user tracking and business process monitoring"
area: "logging-diagnostics"
difficulty: "intermediate"
object_types: ["Table", "Codeunit", "Enum", "Interface"]
variable_types: ["RecordRef", "JsonObject", "DateTime", "Boolean", "Guid"]
tags: ["activity-logging", "user-tracking", "business-process", "audit-trail", "compliance"]
---

# Activity Log Patterns

## Overview

Activity logging patterns in Business Central enable comprehensive tracking of user actions, business processes, and system events. This atomic covers intelligent logging frameworks with automated categorization, privacy-compliant tracking, and actionable analytics.

## Intelligent Activity Logging Framework

### Smart Activity Logger
```al
codeunit 50190 "Smart Activity Logger"
{
    procedure LogUserActivity(ActivityType: Enum "Activity Type"; ActivityData: JsonObject): Guid
    var
        ActivityLogEntry: Record "Activity Log Entry";
        ContextAnalyzer: Codeunit "Activity Context Analyzer";
        LogId: Guid;
    begin
        LogId := CreateGuid();
        
        // Create activity log entry with intelligent context
        CreateActivityLogEntry(ActivityLogEntry, ActivityType, ActivityData, LogId);
        
        // Analyze activity context for insights
        ContextAnalyzer.AnalyzeActivityContext(ActivityLogEntry);
        
        // Apply privacy compliance filtering
        ApplyPrivacyFiltering(ActivityLogEntry);
        
        // Enable intelligent categorization
        CategorizeActivity(ActivityLogEntry);
        
        exit(LogId);
    end;

    local procedure CreateActivityLogEntry(var ActivityLogEntry: Record "Activity Log Entry"; ActivityType: Enum "Activity Type"; ActivityData: JsonObject; LogId: Guid)
    var
        UserContext: JsonObject;
        SessionContext: JsonObject;
    begin
        ActivityLogEntry.Init();
        ActivityLogEntry."Log Entry ID" := LogId;
        ActivityLogEntry."Activity Type" := ActivityType;
        ActivityLogEntry."Date Time" := CurrentDateTime();
        ActivityLogEntry."User ID" := UserId();
        ActivityLogEntry."Company Name" := CompanyName();
        
        // Capture user context
        UserContext := BuildUserContext();
        ActivityLogEntry."User Context" := UserContext.AsText();
        
        // Capture session context
        SessionContext := BuildSessionContext();
        ActivityLogEntry."Session Context" := SessionContext.AsText();
        
        // Store activity data
        ActivityLogEntry."Activity Data" := ActivityData.AsText();
        
        // Set initial classification
        ActivityLogEntry."Privacy Level" := DeterminePrivacyLevel(ActivityType, ActivityData);
        ActivityLogEntry."Business Impact" := AssessBusinessImpact(ActivityType, ActivityData);
        
        ActivityLogEntry.Insert(true);
    end;
}
```

### Activity Log Entry Table
```al
table 50190 "Activity Log Entry"
{
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "Log Entry ID"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Log Entry ID';
        }
        field(2; "Activity Type"; Enum "Activity Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Activity Type';
        }
        field(3; "Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Date Time';
        }
        field(4; "User ID"; Code[50])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'User ID';
        }
        field(5; "Company Name"; Text[30])
        {
            DataClassification = OrganizationIdentifiableInformation;
            Caption = 'Company Name';
        }
        field(6; "Activity Data"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Activity Data';
        }
        field(7; "User Context"; Text[1024])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'User Context';
        }
        field(8; "Session Context"; Text[1024])
        {
            DataClassification = CustomerContent;
            Caption = 'Session Context';
        }
        field(9; "Privacy Level"; Enum "Privacy Level")
        {
            DataClassification = SystemMetadata;
            Caption = 'Privacy Level';
        }
        field(10; "Business Impact"; Enum "Business Impact Level")
        {
            DataClassification = CustomerContent;
            Caption = 'Business Impact';
        }
        field(11; "Activity Category"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Activity Category';
        }
        field(12; "Process Context"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Process Context';
        }
        field(13; "Risk Level"; Enum "Risk Level")
        {
            DataClassification = CustomerContent;
            Caption = 'Risk Level';
        }
    }
    
    keys
    {
        key(PK; "Log Entry ID") { Clustered = true; }
        key(User; "User ID", "Date Time") { }
        key(Activity; "Activity Type", "Date Time") { }
        key(Process; "Process Context", "Date Time") { }
    }
}
```

### Activity Classification Enums
```al
enum 50190 "Activity Type"
{
    Extensible = true;
    
    value(0; "User Login") { Caption = 'User Login'; }
    value(1; "Document Creation") { Caption = 'Document Creation'; }
    value(2; "Document Modification") { Caption = 'Document Modification'; }
    value(3; "Document Deletion") { Caption = 'Document Deletion'; }
    value(4; "Report Generation") { Caption = 'Report Generation'; }
    value(5; "Data Export") { Caption = 'Data Export'; }
    value(6; "Configuration Change") { Caption = 'Configuration Change'; }
    value(7; "Permission Change") { Caption = 'Permission Change'; }
    value(8; "Integration Activity") { Caption = 'Integration Activity'; }
    value(9; "System Administration") { Caption = 'System Administration'; }
}

enum 50191 "Privacy Level"
{
    Extensible = true;
    
    value(0; Public) { Caption = 'Public'; }
    value(1; Internal) { Caption = 'Internal'; }
    value(2; Confidential) { Caption = 'Confidential'; }
    value(3; Restricted) { Caption = 'Restricted'; }
}

enum 50192 "Business Impact Level"
{
    Extensible = true;
    
    value(0; Low) { Caption = 'Low'; }
    value(1; Medium) { Caption = 'Medium'; }
    value(2; High) { Caption = 'High'; }
    value(3; Critical) { Caption = 'Critical'; }
}

enum 50193 "Risk Level"
{
    Extensible = true;
    
    value(0; Minimal) { Caption = 'Minimal'; }
    value(1; Low) { Caption = 'Low'; }
    value(2; Medium) { Caption = 'Medium'; }
    value(3; High) { Caption = 'High'; }
    value(4; Critical) { Caption = 'Critical'; }
}
```

## Business Process Activity Tracking

### Process-Aware Activity Logger
```al
codeunit 50191 "Process Activity Logger"
{
    procedure LogBusinessProcessActivity(ProcessType: Text; ProcessStage: Text; ActivityData: JsonObject): Guid
    var
        ProcessLogger: Codeunit "Smart Activity Logger";
        ProcessActivityData: JsonObject;
        LogId: Guid;
    begin
        // Enhance activity data with process context
        ProcessActivityData := EnhanceWithProcessContext(ProcessType, ProcessStage, ActivityData);
        
        // Log with business process classification
        LogId := ProcessLogger.LogUserActivity("Activity Type"::"Document Modification", ProcessActivityData);
        
        // Update process tracking
        UpdateProcessTracking(LogId, ProcessType, ProcessStage);
        
        exit(LogId);
    end;

    local procedure EnhanceWithProcessContext(ProcessType: Text; ProcessStage: Text; ActivityData: JsonObject): JsonObject
    var
        EnhancedData: JsonObject;
        ProcessContext: JsonObject;
    begin
        // Copy original activity data
        EnhancedData := ActivityData;
        
        // Add process context information
        ProcessContext.Add('processType', ProcessType);
        ProcessContext.Add('processStage', ProcessStage);
        ProcessContext.Add('processTimestamp', CurrentDateTime());
        ProcessContext.Add('processUser', UserId());
        
        EnhancedData.Add('processContext', ProcessContext);
        
        exit(EnhancedData);
    end;

    procedure TrackSalesOrderProcess(SalesHeader: Record "Sales Header"; ProcessStage: Text)
    var
        SalesActivityData: JsonObject;
    begin
        // Build sales-specific activity data
        SalesActivityData.Add('documentType', Format(SalesHeader."Document Type"));
        SalesActivityData.Add('documentNo', SalesHeader."No.");
        SalesActivityData.Add('customerNo', SalesHeader."Sell-to Customer No.");
        SalesActivityData.Add('amount', SalesHeader."Amount Including VAT");
        SalesActivityData.Add('processStage', ProcessStage);
        
        // Log sales process activity
        LogBusinessProcessActivity('Sales Order Processing', ProcessStage, SalesActivityData);
    end;
}
```

### User Behavior Analytics
```al
codeunit 50192 "User Activity Analyzer"
{
    procedure AnalyzeUserActivity(UserId: Code[50]; AnalysisPeriod: DateFormula): JsonObject
    var
        ActivityLogEntry: Record "Activity Log Entry";
        UserAnalysis: JsonObject;
        ActivityPatterns: JsonArray;
    begin
        // Filter activity log for specific user and period
        ActivityLogEntry.SetRange("User ID", UserId);
        ActivityLogEntry.SetFilter("Date Time", '>=%1', CalcDate(AnalysisPeriod, Today));
        
        // Analyze activity patterns
        ActivityPatterns := AnalyzeActivityPatterns(ActivityLogEntry);
        UserAnalysis.Add('activityPatterns', ActivityPatterns);
        
        // Calculate productivity metrics
        UserAnalysis.Add('productivityMetrics', CalculateProductivityMetrics(ActivityLogEntry));
        
        // Identify potential security concerns
        UserAnalysis.Add('securityInsights', IdentifySecurityConcerns(ActivityLogEntry));
        
        // Generate behavior insights
        UserAnalysis.Add('behaviorInsights', GenerateBehaviorInsights(ActivityLogEntry));
        
        exit(UserAnalysis);
    end;

    local procedure AnalyzeActivityPatterns(var ActivityLogEntry: Record "Activity Log Entry"): JsonArray
    var
        Patterns: JsonArray;
        HourlyActivity: JsonObject;
        DailyActivity: JsonObject;
        TypeDistribution: JsonObject;
    begin
        // Analyze hourly activity patterns
        HourlyActivity := AnalyzeHourlyPatterns(ActivityLogEntry);
        Patterns.Add(HourlyActivity);
        
        // Analyze daily activity patterns
        DailyActivity := AnalyzeDailyPatterns(ActivityLogEntry);
        Patterns.Add(DailyActivity);
        
        // Analyze activity type distribution
        TypeDistribution := AnalyzeActivityTypeDistribution(ActivityLogEntry);
        Patterns.Add(TypeDistribution);
        
        exit(Patterns);
    end;
}
```

## Privacy-Compliant Activity Logging

### GDPR-Compliant Activity Logger
```al
codeunit 50193 "GDPR Activity Logger"
{
    procedure LogActivityWithPrivacyCompliance(ActivityType: Enum "Activity Type"; ActivityData: JsonObject): Guid
    var
        PrivacyFilter: Codeunit "Privacy Data Filter";
        ComplianceValidator: Codeunit "GDPR Compliance Validator";
        FilteredData: JsonObject;
        LogId: Guid;
    begin
        // Apply privacy filtering to activity data
        FilteredData := PrivacyFilter.FilterPersonalData(ActivityData);
        
        // Validate GDPR compliance
        if not ComplianceValidator.ValidateActivityLogging(FilteredData) then
            Error('Activity logging violates GDPR compliance requirements');
        
        // Log with privacy-compliant data
        LogId := LogPrivacyCompliantActivity(ActivityType, FilteredData);
        
        exit(LogId);
    end;

    local procedure LogPrivacyCompliantActivity(ActivityType: Enum "Activity Type"; FilteredData: JsonObject): Guid
    var
        ActivityLogger: Codeunit "Smart Activity Logger";
        AnonymizedData: JsonObject;
    begin
        // Apply additional anonymization if needed
        AnonymizedData := ApplyDataAnonymization(FilteredData);
        
        // Set appropriate data retention period
        SetDataRetentionPolicy(AnonymizedData);
        
        // Log activity with compliance markers
        exit(ActivityLogger.LogUserActivity(ActivityType, AnonymizedData));
    end;

    procedure PurgeExpiredActivityLogs()
    var
        ActivityLogEntry: Record "Activity Log Entry";
        RetentionManager: Codeunit "Data Retention Manager";
    begin
        // Identify expired activity logs based on retention policies
        ActivityLogEntry.SetFilter("Date Time", '<=%1', RetentionManager.GetRetentionCutoffDate());
        
        // Purge expired logs with audit trail
        if ActivityLogEntry.FindSet() then begin
            repeat
                LogDataPurgeActivity(ActivityLogEntry);
                ActivityLogEntry.Delete(true);
            until ActivityLogEntry.Next() = 0;
        end;
    end;
}
```

## Activity Log Reporting and Analytics

### Activity Analytics Dashboard
```al
codeunit 50194 "Activity Analytics Engine"
{
    procedure GenerateActivityReport(ReportType: Enum "Activity Report Type"; Parameters: JsonObject): JsonObject
    var
        ActivityReport: JsonObject;
    begin
        case ReportType of
            ReportType::"User Activity Summary":
                ActivityReport := GenerateUserActivitySummary(Parameters);
            ReportType::"Process Performance":
                ActivityReport := GenerateProcessPerformanceReport(Parameters);
            ReportType::"Security Audit":
                ActivityReport := GenerateSecurityAuditReport(Parameters);
            ReportType::"Compliance Report":
                ActivityReport := GenerateComplianceReport(Parameters);
        end;
        
        exit(ActivityReport);
    end;

    local procedure GenerateUserActivitySummary(Parameters: JsonObject): JsonObject
    var
        ActivityLogEntry: Record "Activity Log Entry";
        Summary: JsonObject;
        UserMetrics: JsonArray;
        DateRange: JsonObject;
    begin
        Parameters.Get('dateRange', DateRange);
        
        // Apply date filters
        ApplyDateFilters(ActivityLogEntry, DateRange);
        
        // Generate user-level metrics
        UserMetrics := GenerateUserMetrics(ActivityLogEntry);
        Summary.Add('userMetrics', UserMetrics);
        
        // Generate system-level metrics
        Summary.Add('systemMetrics', GenerateSystemMetrics(ActivityLogEntry));
        
        // Generate trend analysis
        Summary.Add('trendAnalysis', GenerateTrendAnalysis(ActivityLogEntry));
        
        exit(Summary);
    end;
}
```

## Implementation Checklist

### Activity Logging Infrastructure
- [ ] Deploy Smart Activity Logger and supporting codeunits
- [ ] Configure activity types and classification enums
- [ ] Set up activity log entry table with proper indexing
- [ ] Initialize privacy compliance filtering
- [ ] Configure business process activity tracking

### User Activity Monitoring
- [ ] Implement user behavior analytics
- [ ] Configure activity pattern analysis
- [ ] Set up productivity metrics calculation
- [ ] Enable security concern identification
- [ ] Configure user activity reporting

### Privacy and Compliance
- [ ] Implement GDPR-compliant activity logging
- [ ] Configure data retention policies
- [ ] Set up automated data purging
- [ ] Enable privacy filtering and anonymization
- [ ] Configure compliance validation and reporting

### Analytics and Reporting
- [ ] Set up activity analytics dashboard
- [ ] Configure activity report generation
- [ ] Enable trend analysis and insights
- [ ] Set up automated report distribution
- [ ] Configure alerting for unusual activity patterns

## Best Practices

### Activity Logging Strategy
- Log meaningful business activities that provide value for analysis
- Apply appropriate privacy levels and data classification
- Use intelligent categorization for efficient analysis
- Implement comprehensive process context tracking
- Enable configurable logging levels based on business needs

### Privacy and Compliance
- Always apply privacy filtering before logging personal data
- Implement appropriate data retention and purging policies
- Use anonymization techniques where full data isn't required
- Provide clear audit trails for compliance reporting
- Enable user consent management for activity tracking

## Anti-Patterns to Avoid

- Logging excessive detail that creates privacy concerns
- Storing activity logs without proper data classification
- Implementing activity logging without privacy compliance
- Creating logs that are too verbose and impact performance
- Failing to provide meaningful analytics and insights from logged data

## Related Topics
- [Diagnostic Page Creation](diagnostic-page-creation.md)
- [GDPR Privacy Compliance Implementation](../security/gdpr-privacy-compliance-implementation.md)
- [User Activity Audit Trails](user-activity-audit-trails.md)