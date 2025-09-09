---
title: "Variable Naming Patterns"
description: "AL variable and parameter naming conventions for consistent code style"
area: "naming-conventions"
difficulty: "beginner"
object_types: ["Table", "Page", "Codeunit"]
variable_types: ["Record", "RecordRef"]
tags: ["naming", "variables", "parameters", "conventions"]
---

# Variable Naming Patterns

## Overview

Consistent variable naming patterns are essential for readable, maintainable AL code. This guide provides standardized approaches for naming variables and parameters across different AL object types and scenarios.

## Key Concepts

### Basic Naming Rules
- Use PascalCase for all identifiers (objects, variables, parameters, methods)
- Create descriptive names that clearly indicate the purpose
- Avoid abbreviations unless they are widely understood
- Be consistent with naming patterns throughout the codebase
- Follow Microsoft's official AL naming guidelines

### Record Variable Conventions
Names of variables and parameters of type `Record` should be suffixed with the table name without whitespaces. For multiple variables of the same record type, use meaningful suffixes.

### Page Variable Conventions
Names of variables and parameters of type `Page` should be suffixed with the page name without whitespaces.

### Parameter Declaration Standards
A parameter must only be declared as `var` if necessary (when the parameter needs to be modified).

## Best Practices

### Multiple Variables of Same Type
If there is a need for multiple variables or parameters of the same type, the name must be suffixed with a meaningful name:
- `CustomerNew: Record Customer;`
- `CustomerOld: Record Customer;`

### Variable Ordering Standards
- Object and complex variable types must be listed first, then simple variables
- Standard order: Record, Report, Codeunit, XmlPort, Page, Query, Notification, BigText, DateFormula, RecordId, RecordRef, FieldRef, FilterPageBuilder
- Other variables are not sorted

### Temporary Variable Naming
Use the `Temp` prefix for temporary variables:
- `TempCustomer: Record Customer temporary;`
- `TempSalesAnalysis: Record "Sales Analysis" temporary;`

## Common Pitfalls

### Avoid Ambiguous Names
- **Wrong:** `Rec: Record Customer;`
- **Right:** `Customer: Record Customer;`

### Avoid Generic Suffixes
- **Wrong:** `CustomerVar: Record Customer;`
- **Right:** `Customer: Record Customer;`

### Multiple Record Variables Need Context
- **Wrong:** `Customer1: Record Customer;`, `Customer2: Record Customer;`
- **Right:** `SourceCustomer: Record Customer;`, `TargetCustomer: Record Customer;`

## Related Topics

- Object Naming Conventions
- Data Type Conventions  
- Code Documentation Standards
- AL Development Environment Setup
