---
title: "Exception State Handling for Business Central Features"
description: "Management patterns for handling exception states in Business Central feature development workflows"
area: "project-workflow"  
difficulty: "intermediate"
object_types: ["Enum", "Codeunit"]
variable_types: ["DateTime"]
tags: ["exception-handling", "workflow", "state-management", "blockers", "escalation"]
---

# Exception State Handling for Business Central Features

## Overview

Exception state handling provides structured approaches for managing features that encounter blockers, require temporary suspension, or need cancellation during development. This pattern ensures proper handling of non-standard workflow situations while maintaining visibility and accountability.

## Key Concepts

### Exception State Types
- **On Hold**: Temporary suspension due to blockers or dependencies
- **Cancelled**: Permanent termination of feature development
- **Blocked**: Waiting for external dependencies or decisions
- **Escalated**: Requiring management intervention or priority reassignment

### Recovery Patterns
Exception states include defined recovery paths to return features to normal development workflow when conditions are resolved.

## Best Practices

### On Hold State Management

**Clear Blocker Documentation**
- Document specific reasons for placing feature on hold
- Identify required actions and responsible parties for resolution
- Set expected resolution timeframes and review schedules
- Maintain regular status reviews and escalation triggers

**Stakeholder Communication**
- Notify all affected stakeholders immediately when feature is placed on hold
- Provide regular updates on resolution progress
- Communicate impact on related features and project timelines
- Establish clear criteria for resuming development

### Cancelled State Procedures

**Proper Cancellation Process**
- Document business justification for feature cancellation
- Assess impact on related features and project scope
- Handle resource reallocation and timeline adjustments
- Archive feature documentation and  changes appropriately

**Knowledge Retention**
- Capture lessons learned from cancelled features
- Document technical insights and design decisions for future reference
- Maintain searchable archive for similar future requirements
- Share knowledge with development team to prevent repeated efforts

## Related Topics

- Feature Development State Management
- Project Management Tool Integration
- Escalation and Communication Patterns
