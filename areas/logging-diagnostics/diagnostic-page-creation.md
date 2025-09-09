---
title: "Diagnostic Page Creation"
description: "Advanced diagnostic page patterns for Business Central with real-time monitoring and intelligent troubleshooting capabilities"
area: "logging-diagnostics"
difficulty: "advanced"
object_types: ["Page", "Codeunit", "Table", "Query"]
variable_types: ["JsonObject", "Dictionary", "DateTime", "Boolean", "RecordRef"]
tags: ["diagnostic-pages", "system-monitoring", "troubleshooting", "health-dashboard", "real-time"]
---

# Diagnostic Page Creation

## Overview

Diagnostic page creation in Business Central enables real-time system monitoring, performance analysis, and intelligent troubleshooting. This atomic covers advanced diagnostic page patterns with live data visualization, automated health checks, and comprehensive system insights.

## Intelligent Diagnostic Framework

### System Health Dashboard
```al
page 50190 "System Health Dashboard"
{
    PageType = RoleCenter;
    SourceTable = "System Diagnostic Data";
    SourceTableTemporary = true;
    RefreshOnActivate = true;

    layout
    {
        area(RoleCenter)
        {
            part("Performance Metrics"; "Performance Metrics Part")
            {
                ApplicationArea = All;
            }
            part("System Status"; "System Status Part")
            {
                ApplicationArea = All;
            }
            part("Active Processes"; "Active Processes Part")
            {
                ApplicationArea = All;
            }
            part("Error Analysis"; "Error Analysis Part")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Refresh Diagnostics")
            {
                ApplicationArea = All;
                Caption = 'Refresh Diagnostics';
                Image = Refresh;
                
                trigger OnAction()
                begin
                    RefreshDiagnosticData();
                end;
            }
            action("Run Health Check")
            {
                ApplicationArea = All;
                Caption = 'Run Health Check';
                Image = TestFile;
                
                trigger OnAction()
                begin
                    RunComprehensiveHealthCheck();
                end;
            }
            action("Generate Report")
            {
                ApplicationArea = All;
                Caption = 'Generate Report';
                Image = Report;
                
                trigger OnAction()
                begin
                    GenerateDiagnosticReport();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        InitializeDashboard();
    end;

    local procedure InitializeDashboard()
    var
        DiagnosticEngine: Codeunit "System Diagnostic Engine";
    begin
        DiagnosticEngine.InitializeRealTimeMonitoring();
        RefreshDiagnosticData();
    end;

    local procedure RefreshDiagnosticData()
    var
        DiagnosticCollector: Codeunit "Diagnostic Data Collector";
    begin
        DiagnosticCollector.CollectSystemMetrics(Rec);
        CurrPage.Update(false);
    end;
}
```

### System Diagnostic Data Table
```al
table 50190 "System Diagnostic Data"
{
    TableType = Temporary;
    DataClassification = SystemMetadata;
    
    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(2; "Metric Type"; Enum "Diagnostic Metric Type")
        {
            DataClassification = SystemMetadata;
            Caption = 'Metric Type';
        }
        field(3; "Metric Name"; Text[100])
        {
            DataClassification = SystemMetadata;
            Caption = 'Metric Name';
        }
        field(4; "Current Value"; Decimal)
        {
            DataClassification = SystemMetadata;
            Caption = 'Current Value';
        }
        field(5; "Threshold Value"; Decimal)
        {
            DataClassification = SystemMetadata;
            Caption = 'Threshold Value';
        }
        field(6; "Status"; Enum "Health Status")
        {
            DataClassification = SystemMetadata;
            Caption = 'Status';
        }
        field(7; "Last Updated"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'Last Updated';
        }
        field(8; "Trend Indicator"; Enum "Trend Direction")
        {
            DataClassification = SystemMetadata;
            Caption = 'Trend Indicator';
        }
        field(9; "Description"; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'Description';
        }
        field(10; "Action Required"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Action Required';
        }
    }
    
    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Metric; "Metric Type", "Metric Name") { }
        key(Status; Status, "Action Required") { }
    }
}
```

### Diagnostic Classification Enums
```al
enum 50190 "Diagnostic Metric Type"
{
    Extensible = true;
    
    value(0; Performance) { Caption = 'Performance'; }
    value(1; Memory) { Caption = 'Memory'; }
    value(2; Database) { Caption = 'Database'; }
    value(3; Network) { Caption = 'Network'; }
    value(4; Security) { Caption = 'Security'; }
    value(5; Integration) { Caption = 'Integration'; }
    value(6; UserActivity) { Caption = 'User Activity'; }
}

enum 50191 "Health Status"
{
    Extensible = true;
    
    value(0; Healthy) { Caption = 'Healthy'; }
    value(1; Warning) { Caption = 'Warning'; }
    value(2; Critical) { Caption = 'Critical'; }
    value(3; Error) { Caption = 'Error'; }
    value(4; Unknown) { Caption = 'Unknown'; }
}

enum 50192 "Trend Direction"
{
    Extensible = true;
    
    value(0; Stable) { Caption = 'Stable'; }
    value(1; Improving) { Caption = 'Improving'; }
    value(2; Declining) { Caption = 'Declining'; }
    value(3; Volatile) { Caption = 'Volatile'; }
}
```

## Real-Time Performance Monitoring

### Performance Metrics Part
```al
page 50191 "Performance Metrics Part"
{
    PageType = CardPart;
    SourceTable = "System Diagnostic Data";
    SourceTableTemporary = true;
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            cuegroup("CPU Performance")
            {
                field("CPU Usage"; GetCPUUsage())
                {
                    ApplicationArea = All;
                    Caption = 'CPU Usage %';
                    StyleExpr = GetCPUUsageStyle();
                    
                    trigger OnDrillDown()
                    begin
                        ShowCPUDetails();
                    end;
                }
                field("CPU Trend"; GetCPUTrend())
                {
                    ApplicationArea = All;
                    Caption = 'CPU Trend';
                    StyleExpr = GetTrendStyle(GetCPUTrend());
                }
            }
            cuegroup("Memory Performance")
            {
                field("Memory Usage"; GetMemoryUsage())
                {
                    ApplicationArea = All;
                    Caption = 'Memory Usage %';
                    StyleExpr = GetMemoryUsageStyle();
                    
                    trigger OnDrillDown()
                    begin
                        ShowMemoryDetails();
                    end;
                }
                field("Available Memory"; GetAvailableMemory())
                {
                    ApplicationArea = All;
                    Caption = 'Available Memory GB';
                }
            }
            cuegroup("Database Performance")
            {
                field("DB Response Time"; GetDBResponseTime())
                {
                    ApplicationArea = All;
                    Caption = 'DB Response Time ms';
                    StyleExpr = GetDBResponseStyle();
                }
                field("Active Connections"; GetActiveConnections())
                {
                    ApplicationArea = All;
                    Caption = 'Active Connections';
                }
            }
        }
    }

    local procedure GetCPUUsage(): Decimal
    var
        PerformanceMonitor: Codeunit "Performance Monitor";
    begin
        exit(PerformanceMonitor.GetCurrentCPUUsage());
    end;

    local procedure GetCPUUsageStyle(): Text
    var
        CPUUsage: Decimal;
    begin
        CPUUsage := GetCPUUsage();
        
        case true of
            CPUUsage > 90: exit('Unfavorable');
            CPUUsage > 75: exit('Ambiguous');
            else exit('Favorable');
        end;
    end;
}
```

### System Diagnostic Engine
```al
codeunit 50195 "System Diagnostic Engine"
{
    procedure InitializeRealTimeMonitoring()
    var
        MonitoringScheduler: Codeunit "Monitoring Scheduler";
        HealthChecker: Codeunit "System Health Checker";
    begin
        // Start real-time data collection
        MonitoringScheduler.StartRealTimeCollection();
        
        // Initialize health checking
        HealthChecker.InitializeHealthMonitoring();
        
        // Configure alert thresholds
        ConfigureAlertThresholds();
    end;

    procedure CollectComprehensiveMetrics(): JsonObject
    var
        Metrics: JsonObject;
        PerformanceCollector: Codeunit "Performance Metrics Collector";
        SystemCollector: Codeunit "System Status Collector";
        SecurityCollector: Codeunit "Security Metrics Collector";
    begin
        // Collect performance metrics
        Metrics.Add('performance', PerformanceCollector.CollectPerformanceData());
        
        // Collect system status
        Metrics.Add('systemStatus', SystemCollector.CollectSystemStatus());
        
        // Collect security metrics
        Metrics.Add('security', SecurityCollector.CollectSecurityMetrics());
        
        // Collect integration health
        Metrics.Add('integrations', CollectIntegrationHealth());
        
        exit(Metrics);
    end;

    local procedure CollectIntegrationHealth(): JsonObject
    var
        IntegrationHealth: JsonObject;
        APIMonitor: Codeunit "API Health Monitor";
        WebServiceMonitor: Codeunit "Web Service Monitor";
    begin
        // Monitor API endpoints
        IntegrationHealth.Add('apiHealth', APIMonitor.GetAPIHealthStatus());
        
        // Monitor web services
        IntegrationHealth.Add('webServices', WebServiceMonitor.GetWebServiceStatus());
        
        // Monitor external connections
        IntegrationHealth.Add('externalConnections', MonitorExternalConnections());
        
        exit(IntegrationHealth);
    end;
}
```

## Advanced Troubleshooting Pages

### Error Analysis Dashboard
```al
page 50192 "Error Analysis Dashboard"
{
    PageType = List;
    SourceTable = "Error Analysis Entry";
    SourceTableTemporary = true;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Error Code"; Rec."Error Code")
                {
                    ApplicationArea = All;
                    StyleExpr = GetErrorSeverityStyle();
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                }
                field("Frequency"; Rec.Frequency)
                {
                    ApplicationArea = All;
                    StyleExpr = GetFrequencyStyle();
                }
                field("Last Occurrence"; Rec."Last Occurrence")
                {
                    ApplicationArea = All;
                }
                field("Resolution Status"; Rec."Resolution Status")
                {
                    ApplicationArea = All;
                }
                field("AI Suggestion"; Rec."AI Suggestion")
                {
                    ApplicationArea = All;
                    MultiLine = true;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Analyze Error")
            {
                ApplicationArea = All;
                Caption = 'Analyze Error';
                Image = Analyze;
                
                trigger OnAction()
                begin
                    AnalyzeSelectedError();
                end;
            }
            action("Generate Fix")
            {
                ApplicationArea = All;
                Caption = 'Generate Fix';
                Image = Suggest;
                
                trigger OnAction()
                begin
                    GenerateAIFixSuggestion();
                end;
            }
        }
    }

    local procedure AnalyzeSelectedError()
    var
        ErrorAnalyzer: Codeunit "AI Error Analyzer";
        AnalysisResult: JsonObject;
    begin
        AnalysisResult := ErrorAnalyzer.AnalyzeError(Rec."Error Code", Rec."Error Message");
        UpdateErrorAnalysis(AnalysisResult);
    end;
}
```

### Error Analysis Entry Table
```al
table 50191 "Error Analysis Entry"
{
    TableType = Temporary;
    DataClassification = SystemMetadata;
    
    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(2; "Error Code"; Code[50])
        {
            DataClassification = SystemMetadata;
            Caption = 'Error Code';
        }
        field(3; "Error Message"; Text[500])
        {
            DataClassification = SystemMetadata;
            Caption = 'Error Message';
        }
        field(4; Frequency; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Frequency';
        }
        field(5; "Last Occurrence"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'Last Occurrence';
        }
        field(6; "First Occurrence"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'First Occurrence';
        }
        field(7; "Affected Users"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Affected Users';
        }
        field(8; "Resolution Status"; Enum "Resolution Status")
        {
            DataClassification = SystemMetadata;
            Caption = 'Resolution Status';
        }
        field(9; "AI Suggestion"; Text[1024])
        {
            DataClassification = SystemMetadata;
            Caption = 'AI Suggestion';
        }
        field(10; "Severity Level"; Enum "Error Severity")
        {
            DataClassification = SystemMetadata;
            Caption = 'Severity Level';
        }
    }
}
```

## Intelligent Health Monitoring

### System Health Checker
```al
codeunit 50196 "System Health Checker"
{
    procedure RunComprehensiveHealthCheck(): JsonObject
    var
        HealthReport: JsonObject;
        ComponentHealth: JsonArray;
    begin
        // Check core system components
        ComponentHealth.Add(CheckDatabaseHealth());
        ComponentHealth.Add(CheckApplicationHealth());
        ComponentHealth.Add(CheckIntegrationHealth());
        ComponentHealth.Add(CheckSecurityHealth());
        ComponentHealth.Add(CheckPerformanceHealth());
        
        HealthReport.Add('componentHealth', ComponentHealth);
        HealthReport.Add('overallStatus', DetermineOverallHealth(ComponentHealth));
        HealthReport.Add('recommendations', GenerateHealthRecommendations(ComponentHealth));
        
        exit(HealthReport);
    end;

    local procedure CheckDatabaseHealth(): JsonObject
    var
        DatabaseHealth: JsonObject;
        DatabaseMonitor: Codeunit "Database Health Monitor";
    begin
        DatabaseHealth.Add('component', 'Database');
        DatabaseHealth.Add('status', DatabaseMonitor.GetDatabaseStatus());
        DatabaseHealth.Add('responseTime', DatabaseMonitor.GetAverageResponseTime());
        DatabaseHealth.Add('connections', DatabaseMonitor.GetActiveConnections());
        DatabaseHealth.Add('lockingIssues', DatabaseMonitor.CheckLockingIssues());
        DatabaseHealth.Add('recommendations', DatabaseMonitor.GetRecommendations());
        
        exit(DatabaseHealth);
    end;

    local procedure CheckApplicationHealth(): JsonObject
    var
        ApplicationHealth: JsonObject;
        AppMonitor: Codeunit "Application Health Monitor";
    begin
        ApplicationHealth.Add('component', 'Application');
        ApplicationHealth.Add('status', AppMonitor.GetApplicationStatus());
        ApplicationHealth.Add('memoryUsage', AppMonitor.GetMemoryUsage());
        ApplicationHealth.Add('errorRate', AppMonitor.GetErrorRate());
        ApplicationHealth.Add('userSessions', AppMonitor.GetActiveUserSessions());
        ApplicationHealth.Add('recommendations', AppMonitor.GetRecommendations());
        
        exit(ApplicationHealth);
    end;
}
```

## Implementation Checklist

### Diagnostic Infrastructure Setup
- [ ] Deploy diagnostic page framework and supporting codeunits
- [ ] Configure system diagnostic data tables and structures
- [ ] Set up real-time data collection mechanisms
- [ ] Initialize health monitoring and alert systems
- [ ] Configure diagnostic metric classifications

### Dashboard Configuration
- [ ] Implement system health dashboard with live metrics
- [ ] Configure performance monitoring pages
- [ ] Set up error analysis and troubleshooting dashboards
- [ ] Enable trend analysis and historical data tracking
- [ ] Configure user-friendly metric visualization

### Monitoring and Alerting
- [ ] Set up real-time performance monitoring
- [ ] Configure health check automation and scheduling
- [ ] Enable intelligent alert systems with thresholds
- [ ] Implement automated diagnostic report generation
- [ ] Configure escalation procedures for critical issues

### Analytics and Intelligence
- [ ] Enable AI-powered error analysis and suggestions
- [ ] Configure predictive health monitoring
- [ ] Set up pattern recognition for proactive issue detection
- [ ] Implement intelligent troubleshooting recommendations
- [ ] Enable automated resolution suggestions

## Best Practices

### Diagnostic Page Design
- Design pages for real-time monitoring with automatic refresh
- Use visual indicators (colors, icons) for quick status assessment
- Provide drill-down capabilities for detailed analysis
- Enable exportable diagnostic reports for external analysis
- Implement role-based access to sensitive diagnostic information

### Performance Optimization
- Use temporary tables for diagnostic data to avoid database impact
- Implement efficient data collection with minimal system overhead
- Cache frequently accessed diagnostic information
- Use background processing for intensive diagnostic operations
- Enable configurable monitoring intervals based on system load

## Anti-Patterns to Avoid

- Creating diagnostic pages that impact system performance
- Implementing monitoring without proper alerting mechanisms
- Designing diagnostic interfaces that are too complex for quick analysis
- Collecting excessive diagnostic data without clear analysis purposes
- Failing to provide actionable insights and recommendations

## Related Topics
- [Activity Log Patterns](activity-log-patterns.md)
- [System Performance Monitoring](../performance-optimization/system-performance-monitoring.md)
- [Background Process Monitoring](background-process-monitoring.md)