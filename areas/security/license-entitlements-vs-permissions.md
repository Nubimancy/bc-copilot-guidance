---
title: "License Entitlements vs Permissions"
description: "Understanding the distinction between Business Central license entitlements and permission sets for proper access control design"
area: "security"
difficulty: "beginner"
object_types: ["PermissionSet", "Codeunit", "PageExtension"]
variable_types: []
tags: ["security", "licensing", "entitlements", "permissions", "access-control"]
---

# License Entitlements vs Permissions

## Overview

Business Central uses a two-layer access control system: license entitlements provide broad access categories based on user license type, while permission sets provide fine-grained control over specific objects and operations. Understanding this distinction is crucial for designing effective security models.

## Core Concepts

### License Entitlements
License entitlements are broad access rights included with specific Business Central license types:
- **Essential License**: Core business processes (sales, purchasing, inventory, finance)
- **Premium License**: All Essential features plus advanced functionality (manufacturing, service management, warehouse management)
- **Team Member License**: Limited read access and basic data entry for specific scenarios
- **Device License**: Access for shared devices in specific scenarios

### Permission Sets
Permission sets provide granular control within the boundaries set by license entitlements:
- **Object-level permissions**: Access to specific tables, pages, reports, codeunits
- **Operation permissions**: Read, Insert, Modify, Delete, Execute rights
- **Data-level restrictions**: Combined with security filters for record-level access

### The Relationship
License entitlements act as a filter **before** permission sets are evaluated:
1. License entitlement determines broad access categories
2. Permission sets refine access within those categories
3. Security filters further restrict data access

## Implementation Patterns

### 1. License-Aware Permission Design

Design permission sets that respect license boundaries rather than fighting them. Essential license users shouldn't receive permissions for Premium-only features.

### 2. Layered Permission Architecture

Build permission sets in layers that align with license types:
- **Base permissions**: Available to all license types
- **Essential extensions**: Additional permissions for Essential+ licenses  
- **Premium extensions**: Advanced permissions requiring Premium licenses

### 3. License Validation in Custom Code

When building custom functionality, validate both license entitlements and specific permissions to provide clear error messages to users.

## Best Practices

### Permission Set Naming
Use naming conventions that indicate license requirements:
- `SALES BASE` - Works with all licenses
- `SALES ESSENTIAL` - Requires Essential license or higher
- `MANUFACTURING PREMIUM` - Requires Premium license

### Testing Across License Types
Test permission sets with different license types to ensure:
- Functionality works as expected for intended license levels
- Clear error messages for insufficient license entitlements
- No confusing permission errors when license is the real issue

### Documentation and Communication
Clearly document license requirements for:
- Custom permission sets
- Business processes
- User role definitions

## Common Patterns

### Essential License Permission Sets
Focus on core business processes available to Essential license users. Avoid including advanced features that require Premium licenses.

### Premium License Enhancements
Create additive permission sets that extend Essential functionality with Premium-only features. Use included permission sets to build on existing Essential permissions.

### Team Member Scenarios
Design specific permission sets for Team Member license holders that provide targeted access for specific business scenarios without exceeding license limitations.

## Validation and Testing

### License Compatibility Testing
- Test permission sets with each intended license type
- Verify error messages are user-friendly
- Confirm license boundaries are respected

### Permission vs. Entitlement Conflicts
When users report access issues:
1. First check if they have appropriate license entitlements
2. Then verify permission set assignments
3. Finally check security filters and other restrictions

### Audit License Usage
Regularly review:
- User license assignments vs. actual usage
- Permission sets assigned to users with different license types
- Custom functionality that may require specific license levels

## Business Considerations

### Cost Optimization
- Assign minimum required license type for each user's actual needs
- Use Team Member licenses where appropriate
- Consider shared device scenarios for Device licenses

### Compliance and Governance
- Maintain documentation of license requirements for business processes
- Regular audits of license vs. permission alignment
- Clear escalation path for license-related access issues

### Change Management
When implementing new functionality:
1. Determine license requirements early
2. Communicate license impact to stakeholders
3. Plan permission sets that align with license boundaries

## Related Topics

- Permission Sets Creation and Management
- Security Filters and Record-Level Access
- Effective Permissions Auditing
- User Management and Role Assignment
