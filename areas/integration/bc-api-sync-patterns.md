---
title: "BC API Synchronization Patterns"
description: "Business Central API synchronization patterns for external system integration using web services, OData APIs, and integration events"
area: "integration"
difficulty: "advanced"
object_types: ["Codeunit", "Table", "Page", "XMLport"]
variable_types: ["JsonObject", "HttpClient", "DateTime", "Boolean", "RecordRef"]
tags: ["bc-api", "web-services", "odata", "integration-events", "external-sync"]
---

# BC API Synchronization Patterns

## Overview

Business Central API synchronization patterns focus on integrating BC with external systems through OData APIs, SOAP web services, and custom API pages. These patterns leverage BC's built-in web service capabilities, integration events, and job queue for reliable data synchronization with external systems while maintaining BC data integrity and performance.

## BC Integration Architecture

### Web Service Integration Patterns

**BC API and Web Service Design**

Implement robust BC external system integration through:

- **OData API Integration**: Standard BC APIs for customers, items, sales documents with proper authentication
- **Custom API Pages**: Purpose-built API pages for specific business scenarios and data models
- **SOAP Web Services**: Legacy system integration using BC codeunits and pages exposed as web services
- **Integration Events**: Business event integration for real-time external system notification
- **Job Queue Synchronization**: Scheduled sync jobs for batch processing and reliable data transfer

### BC Data Integrity Management

**Business Central Specific Data Handling**

Ensure data consistency through BC platform features:

- **Modify/OnModify Triggers**: Use table triggers to detect changes and trigger external sync processes
- **Change Log Integration**: Leverage BC's change log functionality for audit trails and sync tracking
- **Field Validation**: Apply BC field validation rules before external system synchronization
- **Number Series Management**: Coordinate BC number series with external system identifiers
- **Multi-Company Considerations**: Handle synchronization across BC companies and external systems

### BC Performance and Reliability

**Platform-Optimized Integration Patterns**

Optimize BC integration performance and reliability:

- **SetLoadFields Usage**: Optimize API data retrieval by loading only required fields for external sync
- **Commit and Transaction Management**: Proper commit handling to ensure data consistency during sync operations
- **Job Queue Retry Logic**: Implement robust retry mechanisms using BC job queue error handling
- **Rate Limiting**: Respect external system API limits and implement appropriate throttling in BC
- **Session Management**: Handle BC session timeouts and authentication renewal for long-running sync processes

## Implementation Checklist

### BC Web Service Setup
- [ ] **API Page Creation**: Design and implement custom API pages for external system integration
- [ ] **OData Configuration**: Configure standard BC OData endpoints with proper filtering and permissions
- [ ] **Authentication Setup**: Implement OAuth 2.0 or basic authentication for secure API access
- [ ] **Web Service Publishing**: Publish codeunits and pages as SOAP web services for legacy integration

### Integration Event Implementation
- [ ] **Business Event Design**: Create business events for key BC transactions (posting, approval, etc.)
- [ ] **External System Notification**: Implement event subscribers for external system communication
- [ ] **Event Payload Design**: Design appropriate event data structures for external consumption
- [ ] **Error Handling**: Build robust error handling for failed external system notifications

### Job Queue Synchronization
- [ ] **Sync Job Creation**: Design job queue entries for scheduled data synchronization
- [ ] **Retry Logic**: Implement appropriate retry mechanisms for failed sync operations
- [ ] **Performance Monitoring**: Track job queue execution times and success rates
- [ ] **Multi-Company Handling**: Design sync jobs that work correctly across BC companies

## Best Practices

### BC Web Service Design
- **API Page Optimization**: Design API pages with minimal field sets and efficient queries using SetLoadFields
- **OData Filter Support**: Implement proper filtering capabilities to reduce data transfer volumes
- **Authentication Security**: Use service-to-service authentication with minimal permissions required
- **Version Management**: Design APIs with proper versioning to handle BC updates and external system changes
- **Rate Limiting Respect**: Implement appropriate delays and throttling to respect external system limits

### Integration Event Strategy
- **Event Timing**: Fire business events after successful BC transaction commits to ensure data consistency
- **Payload Efficiency**: Include only essential data in event payloads to minimize network overhead
- **Async Processing**: Design event handling to be asynchronous to avoid impacting BC transaction performance
- **Error Isolation**: Ensure external system failures don't prevent BC business processes from completing
- **Event Replay**: Design events to be idempotent to handle replay scenarios safely

### BC Performance Integration
- **SetLoadFields Usage**: Always use SetLoadFields in integration code to optimize database queries
- **Commit Strategy**: Use commits appropriately to release locks but maintain transaction integrity
- **Session Management**: Handle BC session limits and connection pooling efficiently
- **Multi-Tenant Awareness**: Design integration patterns that work correctly in BC multi-tenant environments
- **Company Context**: Ensure integration code respects BC company boundaries and user permissions

## Anti-Patterns

### BC Web Service Failures
- **Over-Broad API Pages**: Creating API pages that expose too many fields causing performance issues
- **Authentication Gaps**: Using overly permissive authentication or insecure credential handling
- **SetLoadFields Neglect**: Not using SetLoadFields in integration code causing unnecessary database load
- **Synchronous Event Processing**: Making external system calls synchronously during BC business events
- **Permission Overreach**: Granting excessive permissions to integration users and service accounts

### BC Integration Problems
- **Company Boundary Violations**: Integration code that doesn't respect BC multi-company architecture
- **Session Abuse**: Creating too many concurrent sessions or not managing session timeouts properly
- **Transaction Mismanagement**: Poor commit/rollback handling causing data inconsistency
- **Number Series Conflicts**: Not coordinating BC number series with external system identifier schemes
- **Change Log Ignorance**: Not leveraging BC's built-in change tracking capabilities for sync operations

### Job Queue and Performance Issues
- **Job Queue Overload**: Creating too many frequent job queue entries causing system performance issues
- **Retry Logic Gaps**: Inadequate retry mechanisms for failed API calls and external system timeouts
- **Rate Limiting Ignorance**: Not respecting external system API limits causing integration failures
- **Multi-Tenant Blindness**: Integration patterns that don't work correctly in BC SaaS multi-tenant environments
- **Error Handling Deficits**: Poor error handling that causes BC processes to fail when external systems are unavailable