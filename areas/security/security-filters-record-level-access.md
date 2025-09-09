---
title: "Security Filters and Record-Level Access"
description: "Implementation patterns for record-level security using security filters and data access restrictions"
area: "security"
difficulty: "advanced"
object_types: ["Table", "Codeunit"]
variable_types: ["Record"]
tags: ["security", "data-access", "record-level", "filters"]
---

# Security Filters and Record-Level Access

## Overview

Security filters provide record-level access control in Business Central, complementing permission sets by restricting which specific records a user can access within permitted tables. This pattern ensures data isolation and supports multi-tenant, multi-company, and role-based data segmentation.

## Core Concepts

### Security Filter Architecture
Security filters operate as invisible WHERE clauses applied to all database operations:
- **Applied transparently**: Users don't see filter restrictions in UI
- **Enforced at database level**: Cannot be bypassed by code or UI manipulation  
- **Stackable**: Multiple filters can apply to same table for different users
- **Inherited**: Security filters apply to related tables through relationships

### Filter Types
| Filter Type | Use Case | Example |
|-------------|----------|---------|
| **Field-based** | Restrict by field values | `Salesperson Code = USER` |
| **Dimensional** | Multi-dimensional restrictions | `Department + Location` |
| **Relational** | Cascade through table relationships | Customer → Sales Documents |
| **Company-based** | Multi-company data isolation | `Company = CRONUS` |

## Implementation Patterns

### 1. Territory-Based Sales Access

Implement geographical sales territory restrictions by applying security filters to customer-related tables. This ensures sales representatives can only access customers and sales documents within their assigned territories.

### 2. Department-Based Document Access

Implement department-based access to financial documents using dimension-based security filters. This restricts users to only view and modify documents related to their department or cost center.

### 3. Hierarchical Access Control

Implement manager-subordinate data access patterns where managers can see their own data plus data from their direct reports. This creates a natural hierarchy of data visibility that matches organizational structure.

## Best Practices

### Security Filter Design Principles

1. **Principle of Least Privilege**
   - Grant access to minimum necessary data
   - Layer filters for defense in depth
   - Regular audit and review filters

2. **Performance Optimization**
   Use indexed fields for filters to ensure optimal database performance. Avoid complex expressions that cannot utilize database indexes effectively.

3. **Maintainable Filter Logic**
   Centralize security filter management in dedicated codeunits. This ensures consistent application of filters and makes it easier to audit and maintain access controls.

### Multi-Company Considerations

Handle multi-company scenarios by applying company-specific security filters when users have access to multiple companies. This ensures data isolation between companies while allowing authorized cross-company access.

## Testing and Validation

### Security Filter Testing Checklist
- [ ] Test filter effectiveness with minimum required data access
- [ ] Verify filters don't break legitimate business processes
- [ ] Confirm cascading filters work through related tables  
- [ ] Test performance impact of complex filters
- [ ] Validate filter expressions parse correctly
- [ ] Test edge cases (empty results, null values)

### Monitoring and Auditing

Implement logging mechanisms to track security filter applications for audit trail purposes. This helps with compliance requirements and troubleshooting access issues.

## Integration Patterns

### With Permission Sets
Security filters complement permission sets by providing two layers of access control:
- **Permission sets** control WHAT objects a user can access
- **Security filters** control WHICH records within those objects are accessible

### With Workflows
Integrate security filters with approval workflows to ensure users can only approve documents they are authorized to access. Security filters automatically apply during workflow processing to maintain data access controls.

## Common Patterns

### Date-Based Access
Restrict access to records based on date ranges, such as allowing users to only access documents from the current period or within a specific timeframe.

### Status-Based Filters
Apply filters based on document or record status, such as limiting access to only open documents or active records.

### Multi-Dimensional Filters
Combine multiple dimensions (department, project, location) to create complex access control scenarios that match your organization's structure.

## Security Considerations

- **Filter Bypass Prevention**: Security filters cannot be disabled by users or code
- **Performance Impact**: Complex filters may impact query performance
- **Inheritance**: Understand how filters cascade through related tables
- **Testing**: Always test in development environment before production
- **Documentation**: Maintain clear documentation of all applied filters

## Related Topics

- Permission Sets Creation and Management
- License Entitlements vs Permissions  
- Effective Permissions Auditing
- Multi-Company Security Architecture
