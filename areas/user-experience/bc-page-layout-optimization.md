---
title: "Progressive Form Disclosure"
description: "Business Central page design patterns for progressive field disclosure with FastTab optimization, Promoted actions, and performance-aware field management"
area: "user-experience"
difficulty: "intermediate"
object_types: ["Page", "PageExtension", "Codeunit", "Table"]
variable_types: ["Record", "Boolean", "Action", "PagePart"]
tags: ["progressive-disclosure", "page-design", "fasttabs", "promoted-actions", "bc-performance"]
---

# Progressive Form Disclosure

## Overview

Progressive form disclosure in Business Central focuses on optimizing page layouts through strategic FastTab organization, Promoted action placement, and performance-aware field management. These patterns reduce cognitive load and improve system performance by intelligently organizing information based on user workflows and Business Central platform capabilities.

## BC Page Design Architecture

### FastTab Organization Patterns

**Strategic Information Architecture**

Organize page information through Business Central FastTab optimization:

- **Primary Information FastTabs**: Essential business data in General and Details tabs with logical field grouping
- **Secondary Information Grouping**: Supplementary data in dedicated FastTabs (Invoicing, Shipping, Foreign Trade)
- **Performance-Aware Field Selection**: Avoid FlowFields in List pages unless business-critical, prioritize base table fields
- **Logical Tab Progression**: Design FastTab sequence to match typical user workflow and data entry patterns
- **Responsive FastTab Design**: Optimize FastTab layouts for different screen sizes and Business Central clients

### Promoted Action Strategy

**Action Accessibility Optimization**

Implement strategic action promotion for enhanced usability:

- **Primary Action Promotion**: Essential business functions (Post, Release, Print) prominently displayed in action bar
- **Contextual Action Groups**: Related actions grouped logically (Process, Request Approval, Navigate)
- **Role-Based Action Visibility**: Show promoted actions relevant to user's business role and permissions
- **Performance-Conscious Actions**: Promote actions that users access frequently to reduce ribbon navigation
- **Mobile-Optimized Promotion**: Consider touch interface needs when selecting promoted actions

### Performance-Aware Field Management

**BC Platform Optimization**

Optimize page performance through intelligent field management:

- **SetLoadFields Implementation**: Use SetLoadFields for large tables to optimize data loading and page rendering
- **Temporary Table Usage**: Leverage temporary tables for complex calculations and data manipulation scenarios
- **FlowField Strategy**: Minimize FlowField usage in List pages, reserve for Card pages where calculation impact is manageable
- **Page Part Optimization**: Use Page Parts efficiently for related information without overwhelming main page performance
- **Conditional Field Display**: Implement field visibility based on record state and user context to reduce visual complexity

## Implementation Checklist

### Page Design Foundation
- [ ] **FastTab Structure**: Design logical FastTab organization following BC user workflow patterns
- [ ] **Field Prioritization**: Identify essential fields for primary FastTabs, secondary fields for supplementary tabs
- [ ] **Performance Analysis**: Evaluate FlowField usage impact and optimize for List page performance
- [ ] **Action Strategy**: Define primary actions for promotion based on user role and business process frequency

### BC Platform Integration
- [ ] **SetLoadFields Implementation**: Apply SetLoadFields patterns for large table optimization
- [ ] **Temporary Table Strategy**: Identify scenarios requiring temporary tables for complex data operations
- [ ] **Page Part Integration**: Design efficient Page Part usage for related information display
- [ ] **Conditional Visibility**: Implement field and action visibility based on record state and user context

### User Experience Optimization
- [ ] **Mobile Consideration**: Ensure promoted actions and FastTab design work effectively on mobile devices
- [ ] **Role-Based Design**: Adapt page layouts for different user roles (order processors, managers, etc.)
- [ ] **Workflow Integration**: Align page design with standard BC business processes and approval workflows
- [ ] **Performance Validation**: Test page performance with realistic data volumes and user scenarios

## Best Practices

### BC Page Design Excellence
- **FastTab Logic**: Organize fields into FastTabs that reflect natural business process workflows
- **Performance First**: Avoid FlowFields in List pages unless absolutely necessary for business operations
- **Promoted Action Discipline**: Promote only the most frequently used actions to prevent ribbon clutter
- **Field Grouping**: Group related fields logically within FastTabs (General, Communication, Invoicing)
- **Consistent Patterns**: Follow standard BC page design patterns across similar business entities

### Platform Optimization
- **SetLoadFields Usage**: Implement SetLoadFields for tables with many fields to improve load performance
- **Temporary Table Strategy**: Use temporary tables for complex calculations that don't require database persistence
- **Page Part Efficiency**: Design Page Parts to show relevant information without performance degradation
- **Conditional Display**: Show fields based on record state (e.g., shipping fields only for sales orders)
- **Mobile Awareness**: Design promoted actions and FastTab layouts that work well on Business Central mobile app

### Business Process Integration
- **Workflow Alignment**: Design page layouts to support standard BC approval and posting workflows
- **Role-Based Optimization**: Adapt field prominence and action promotion for different user roles
- **Process Sequence**: Arrange FastTabs in the order users typically complete business processes
- **Validation Integration**: Use field validation and page triggers to support progressive data entry
- **Performance Testing**: Validate page performance with realistic data volumes and concurrent user loads

## Anti-Patterns

### BC Page Design Failures
- **FlowField Abuse**: Using FlowFields extensively in List pages causing performance degradation
- **FastTab Chaos**: Creating too many FastTabs or organizing fields illogically across tabs
- **Action Promotion Overload**: Promoting too many actions making the ribbon cluttered and confusing
- **Inconsistent Page Patterns**: Using different organizational approaches across similar business entity pages
- **Role Blindness**: Not considering different user roles when designing field prominence and action visibility

### Platform Performance Issues
- **SetLoadFields Neglect**: Not using SetLoadFields for large tables causing unnecessary data loading
- **Temporary Table Misuse**: Using permanent tables for calculations that should use temporary tables
- **Page Part Overload**: Adding too many Page Parts causing page rendering performance issues
- **FlowField in Lists**: Including expensive FlowField calculations in List pages without business justification
- **Conditional Logic Gaps**: Not implementing field visibility logic based on record state and business rules

### Business Process Disconnection
- **Workflow Misalignment**: Designing page layouts that don't support standard BC business processes
- **Process Sequence Confusion**: Organizing FastTabs in an order that doesn't match natural workflow progression
- **Validation Gaps**: Missing field validation that supports progressive data entry and business rule enforcement
- **Mobile Incompatibility**: Creating promoted action layouts that don't work effectively on Business Central mobile
- **Performance Testing Neglect**: Not validating page performance with realistic data volumes and user concurrency