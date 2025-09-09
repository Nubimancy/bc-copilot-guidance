---
title: "SetLoadFields Basic Patterns"
description: "Essential patterns for using SetLoadFields to optimize AL performance"
area: "performance-optimization"
difficulty: "intermediate"
object_types: ["Codeunit", "Table", "Report"]
variable_types: ["Record"]
tags: ["setloadfields", "performance", "optimization", "basic-patterns", "field-loading"]
---

# SetLoadFields Basic Patterns

## Overview
SetLoadFields is a modern AL performance optimization that allows you to specify exactly which fields to load from the database. This dramatically reduces data transfer, memory usage, and processing time by avoiding unnecessary field loading.

## Key Concepts

### Why SetLoadFields Matters
In Business Central, every field loaded from the database creates overhead:
- **Database I/O** - Less data transferred from SQL Server
- **Network Traffic** - Smaller result sets over network connections
- **Memory Usage** - Fewer objects and data structures in memory
- **Processing Time** - Faster record iteration and operations

### Performance Impact
Without SetLoadFields, AL loads ALL fields from a table (often 50-200+ fields). With SetLoadFields, you load only what you need:
- **Customer Table**: 200+ fields → Load only 4 needed fields = **95% reduction**
- **Sales Line Table**: 100+ fields → Load only 6 needed fields = **94% reduction**
- **Item Table**: 150+ fields → Load only 3 needed fields = **98% reduction**

### Basic Usage Pattern
The standard pattern for SetLoadFields optimization:
1. **Identify Required Fields** - Determine exactly which fields your code uses
2. **Set Field Loading** - Call SetLoadFields with specific field names
3. **Apply Filters** - Set ranges and filters as normal
4. **Process Records** - Iterate with optimal performance

## Best Practices

### Field Selection Strategy
- **Only Load What You Use** - Don't load fields "just in case"
- **Include Key Fields** - Always include fields used in keys and filters
- **Consider Related Operations** - Include fields for CalcSums, CalcFields operations
- **Review Code Logic** - Ensure all referenced fields are included

### Timing of SetLoadFields Call
- **Before FindSet()** - SetLoadFields must be called before finding records
- **After Filters** - Set ranges and filters first, then optimize field loading
- **Consistent Usage** - Use SetLoadFields consistently across similar operations

### Common Field Categories to Include
- **Identification Fields** - Primary key fields ("No." fields)
- **Display Fields** - Fields shown to users (Name, Description)
- **Business Logic Fields** - Fields used in calculations or validation
- **Status Fields** - Fields that control processing flow (Blocked, Status)

## Common Pitfalls

### Loading Too Many Fields
Don't defeat the purpose by loading unnecessary fields "for safety."

### Missing Required Fields
Forgetting to include a field that's accessed later in code will cause runtime errors.

### Inconsistent Application
Using SetLoadFields in some places but not others creates inconsistent performance characteristics.

### Complex Field Dependencies
Be aware of fields that trigger calculations or lookups when accessed - these may need related fields loaded.

## Related Topics
- [SetLoadFields Advanced Scenarios](setloadfields-advanced-scenarios.md)
- [SetLoadFields Performance Measurement](setloadfields-performance-measurement.md)
- [Query Filtering Optimization](query-filtering-optimization.md)
