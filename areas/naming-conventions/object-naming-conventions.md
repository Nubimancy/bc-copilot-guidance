---
title: "Object Naming Conventions"
description: "AL object naming standards for tables, pages, codeunits, and reports"
area: "naming-conventions"
difficulty: "beginner"  
object_types: ["Table", "Page", "Codeunit", "Report"]
variable_types: ["Record", "RecordRef"]
tags: ["naming", "objects", "conventions", "standards"]
---

# Object Naming Conventions

## Overview

Consistent object naming conventions ensure AL code is maintainable, discoverable, and compliant with Business Central standards. This guide establishes naming patterns for all AL object types.

## Key Concepts

### Universal Naming Rules
- Use PascalCase for all object identifiers
- Create descriptive names that clearly indicate purpose and functionality
- Avoid abbreviations unless they are widely understood
- Maintain consistency with naming patterns throughout the codebase
- Follow Microsoft's official AL naming guidelines

### Object-Specific Patterns
Each AL object type has specific naming conventions that reflect its role and usage patterns within the application architecture.

## Best Practices

### Table Naming Standards
- **Table names should be singular nouns** representing a single entity
- Use descriptive names that clearly indicate the data stored
- Example: `Customer`, `Sales Header`, `Item Ledger Entry`

### Field Naming Standards  
- **Field names should clearly describe the data they contain**
- Use complete words rather than abbreviations when possible
- **Boolean fields should be named with positive assertions**
  - **Right:** "Is Complete", "Is Active", "Allow Posting"
  - **Wrong:** "Not Complete", "Inactive", "Disable Posting"

### Page Naming Standards
- **List pages:** Use plural form of the entity (`Customers`, `Sales Orders`)
- **Card pages:** Use "Card" suffix (`Customer Card`, `Sales Order`)  
- **Document pages:** Named with document type (`Sales Invoice`, `Purchase Order`)
- **Worksheet pages:** Use "Worksheet" suffix (`Item Journal`)

### Codeunit Naming Standards
- **Business logic codeunits:** Named after functionality provided (`Customer Management`, `Sales Posting`)
- **Utility codeunits:** Include suffix indicating purpose (`Data Migration Mgt`, `Format Document`)
- **Event subscriber codeunits:** Include "Event Subscribers" (`Sales Event Subscribers`)

### Report Naming Standards
- **Report names should clearly indicate purpose and output**
- **Processing reports:** Include "Processing" (`Customer Processing`, `Inventory Processing`)
- **Document reports:** Named after document type (`Sales Invoice`, `Purchase Receipt`)

## Common Pitfalls

### Avoid Vague Names
- **Wrong:** `Data`, `Info`, `Management`
- **Right:** `Customer Data`, `Sales Info`, `Inventory Management`

### Avoid Inconsistent Pluralization
- **Wrong:** `Customer` page showing multiple customers
- **Right:** `Customers` page showing multiple customers

### Avoid Negative Boolean Fields
- **Wrong:** `Not Shipped`, `Disable Processing`
- **Right:** `Shipped` (false = not shipped), `Enable Processing`

## Related Topics

- Variable Naming Patterns
- Prefix Naming Guidelines
- Data Type Conventions
- AppSource Compliance Standards
