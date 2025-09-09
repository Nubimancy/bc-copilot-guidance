---
title: "Error Telemetry Best Practices"
description: "Advanced error tracking and telemetry patterns for Business Central applications with intelligent error classification and automated remediation guidance"
area: "telemetry"
difficulty: "intermediate"
object_types: ["Codeunit", "Table", "Enum"]
variable_types: ["ErrorInfo", "JsonObject", "JsonArray", "Dictionary"]
tags: ["error-telemetry", "error-tracking", "error-classification", "automated-remediation", "diagnostics"]
---

# Error Telemetry Best Practices

## Overview

Error telemetry in Business Central applications enables comprehensive error tracking, classification, and automated remediation through the platform's built-in telemetry capabilities. These patterns leverage BC's Telemetry codeunit, ErrorInfo objects, and custom dimensions to create intelligent error monitoring systems that integrate with Azure Application Insights and other monitoring tools.

## BC Error Telemetry Architecture

### ErrorInfo Integration Patterns

**Structured Error Capture in Business Central**

Leverage BC's ErrorInfo object for comprehensive error tracking:

- **ErrorInfo Construction**: Proper use of ErrorInfo.Create() with meaningful messages, detailed descriptions, and contextual information
- **Custom Dimensions**: Attach BC-specific context (Company, User, Object Type/ID, AL Stack Trace) to telemetry events
- **Verbosity Levels**: Strategic use of Normal, Warning, Error verbosity for proper Application Insights categorization
- **DataClassification**: Appropriate classification (SystemMetadata, CustomerContent) for GDPR compliance
- **TelemetryScope**: Publisher vs ExtensionPublisher scope selection based on error context

### BC Platform Integration

**Native Telemetry Codeunit Patterns**

Integrate with Business Central's telemetry infrastructure:

- **Telemetry Codeunit**: Proper use of the built-in Telemetry codeunit for consistent error logging
- **Event ID Management**: Systematic event ID assignment following BC conventions (0000XXX format)
- **Correlation Tracking**: Use Session.GetCurrentModuleExecutionContext() for operation correlation
- **Company Context**: Include Company.Name and Company.SystemId in custom dimensions
- **User Context**: Capture UserSecurityId(), UserId, and user role information safely

### Business Central Error Categories

**BC-Specific Error Classification**

Classify errors according to Business Central operational patterns:

- **AL Runtime Errors**: CodeCoverage issues, missing permissions, record locking conflicts
- **Database Errors**: SQL timeouts, deadlocks, constraint violations in BC database layer
- **Integration Errors**: Web service failures, API timeouts, external system connectivity issues
- **Business Logic Errors**: Validation failures, posting errors, workflow violations
- **Platform Errors**: License issues, feature limitations, environment-specific problems
- **Extension Conflicts**: Object name collisions, dependency issues, version compatibility problems

### Performance Impact Monitoring

**BC Resource Utilization Tracking**

Monitor BC-specific performance implications of error handling:

- **Database Query Impact**: Track query execution time increase during error scenarios
- **Session Resource Usage**: Monitor memory and CPU impact of error handling routines
- **User Experience Metrics**: Measure error recovery time and user workflow disruption
- **System Load Correlation**: Connect error patterns to BC system resource utilization
- **Tenant Performance**: Multi-tenant error impact analysis and isolation

## Implementation Checklist

### BC Telemetry Foundation
- [ ] **ErrorInfo Standardization**: Implement consistent ErrorInfo object construction patterns
- [ ] **Custom Dimensions Schema**: Define BC-specific dimension schema for error context
- [ ] **Event ID Management**: Create systematic event ID allocation for error categories
- [ ] **Correlation Framework**: Implement session and operation correlation tracking

### Error Classification System
- [ ] **BC Error Taxonomy**: Define Business Central specific error categories and severity levels
- [ ] **Context Capture**: Build comprehensive BC context collection (company, user, object, session)
- [ ] **Pattern Recognition**: Implement BC-specific error pattern identification
- [ ] **Impact Assessment**: Create BC business impact scoring for different error types

### Integration and Monitoring
- [ ] **Application Insights**: Configure proper BC telemetry forwarding to Azure Application Insights
- [ ] **Dashboard Creation**: Build BC-specific error monitoring dashboards and alerts
- [ ] **Automated Response**: Implement BC-aware error escalation and notification systems
- [ ] **Compliance Tracking**: Ensure GDPR and data classification compliance in error telemetry

## Best Practices

### BC Telemetry Excellence
- **Structured Logging**: Use ErrorInfo objects consistently rather than plain text messages
- **Context Richness**: Include BC-specific context (Company, User, Object, Session) in all error events
- **Performance Awareness**: Minimize telemetry overhead on BC system performance
- **Privacy Compliance**: Respect BC data classification rules in error message content
- **Event ID Consistency**: Follow BC event ID conventions for sustainable error tracking

### Error Handling Integration
- **Native Pattern Usage**: Leverage BC's built-in error handling patterns rather than custom solutions
- **User Experience**: Design error telemetry that supports BC user experience best practices
- **Extension Compatibility**: Ensure error telemetry works across BC extension boundaries
- **Version Compatibility**: Design telemetry that works across BC platform versions
- **Multi-Tenant Awareness**: Consider tenant isolation in error tracking and analysis

### Monitoring Strategy
- **Business Impact Focus**: Prioritize errors based on BC business process impact
- **Operational Integration**: Connect error telemetry to BC operational monitoring
- **Trend Analysis**: Track error patterns across BC upgrade cycles and releases
- **Proactive Detection**: Use BC-specific metrics for predictive error identification
- **Resolution Tracking**: Measure error resolution effectiveness in BC context

## Anti-Patterns

### BC Implementation Failures
- **Generic Error Messages**: Using plain text instead of structured ErrorInfo objects
- **Context Loss**: Missing BC-specific context (company, user, object) in error telemetry
- **Performance Impact**: Heavy telemetry that degrades BC system performance
- **Privacy Violations**: Logging sensitive data without proper BC data classification
- **Event ID Chaos**: Inconsistent or conflicting event ID usage across BC extensions

### Integration Problems
- **Platform Bypassing**: Custom telemetry systems that bypass BC's built-in capabilities
- **Scope Confusion**: Inappropriate use of Publisher vs ExtensionPublisher telemetry scope
- **Correlation Gaps**: Missing session and operation correlation in error tracking
- **Multi-Tenant Issues**: Error telemetry that doesn't respect BC tenant boundaries
- **Version Incompatibility**: Telemetry patterns that break across BC platform updates

### Operational Issues
- **Monitoring Blindness**: Error telemetry without proper BC operational dashboard integration
- **Response Delays**: Slow error detection and escalation in BC production environments  
- **Resolution Tracking Gaps**: No measurement of error fix effectiveness in BC context
- **Business Impact Ignorance**: Technical error focus without BC business process consideration
- **Compliance Neglect**: Error telemetry that violates GDPR or BC data governance requirements