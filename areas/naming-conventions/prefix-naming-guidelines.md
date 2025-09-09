---
title: "Prefix Naming Guidelines"  
description: "AppSource prefix requirements and implementation standards"
area: "naming-conventions"
difficulty: "intermediate"
object_types: ["Table", "Page", "Codeunit", "Report"] 
variable_types: ["Record"]
tags: ["prefix", "appsource", "compliance", "naming"]
---

# Prefix Naming Guidelines

## Overview

Prefix naming is mandatory for AppSource compliance and ensures object uniqueness across Business Central extensions. This guide establishes standardized prefix implementation patterns.

## Key Concepts

### Prefix Requirements
All objects must have a prefix to prevent naming conflicts and ensure AppSource compliance. The prefix system provides namespace isolation for custom objects.

### Prefix Configuration
The prefix is defined in the AppSourceCop.json file and must be consistently applied across all custom objects in the extension.

### Format Standards  
Prefixes follow a strict format specification to maintain consistency and readability across all Business Central extensions.

## Best Practices

### Mandatory Prefix Rules
1. **All objects must have a prefix** - No exceptions for custom objects
2. **Prefix defined in AppSourceCop.json** - Centralized configuration
3. **Standard format:** `<Prefix> ` (prefix + space)
4. **Always uppercase** - Consistent capitalization
5. **Always followed by space** - Clear visual separation  
6. **Used once per object name** - No duplicate prefixes
7. **Always at beginning** - Consistent positioning

### Prefix Selection Guidelines
- Choose meaningful prefixes that represent your organization or solution
- Keep prefixes short (2-4 characters) for readability
- Use letter combinations that are unlikely to conflict with other vendors
- Avoid generic prefixes like "NEW", "CUST", "EXT"

### AppSourceCop.json Configuration
```json
{
  "mandatoryPrefix": "ABC",
  "supportedCountries": ["US", "CA", "GB"]
}
```

## Common Pitfalls

### Missing Prefix
- **Wrong:** `Customer Rating` (no prefix)
- **Right:** `ABC Customer Rating`

### Incorrect Format  
- **Wrong:** `ABCCustomer Rating` (no space)
- **Right:** `ABC Customer Rating`

### Inconsistent Casing
- **Wrong:** `abc Customer Rating` (lowercase prefix)
- **Right:** `ABC Customer Rating`

### Multiple Prefixes
- **Wrong:** `ABC XYZ Customer Rating` (multiple prefixes)
- **Right:** `ABC Customer Rating`

### Wrong Position
- **Wrong:** `Customer ABC Rating` (prefix not at beginning)
- **Right:** `ABC Customer Rating`

## Related Topics

- Object Naming Conventions
- AppSource Compliance Standards
- Extension Development Patterns
- Business Central Object Architecture
