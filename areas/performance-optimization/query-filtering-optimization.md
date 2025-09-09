---
title: "Query Filtering Optimization"
description: "Advanced filtering strategies for optimized database query performance"
area: "performance-optimization"
difficulty: "intermediate"
object_types: ["Table", "Query"]
variable_types: ["Record", "RecordRef"]
tags: ["filtering", "indexes", "setrange", "optimization"]
---

# Query Filtering Optimization

## Overview
Effective filtering strategies can dramatically improve query performance by leveraging database indexes, minimizing data retrieval, and using optimal filter sequences.

## Key Concepts

### Index-Aware Filtering
- **Clustered Index**: Primary key order affects performance
- **Secondary Indexes**: Additional optimized access paths
- **Filter Order**: Match index field order for best performance
- **Selective Filters**: Most restrictive filters first

### Filtering Techniques
- **SetRange**: Efficient range filtering
- **SetFilter**: Complex filter expressions  
- **Selective Loading**: Only necessary fields
- **Progressive Filtering**: Layer filters from broad to specific

## Best Practices

### 1. Use Index-Optimized Filtering
- Filter on indexed fields first
- Follow index field order in filter sequence
- Use SetRange for range queries when possible
- Avoid filtering on non-indexed fields in large tables

### 2. Implement Selective Loading
- Use SetLoadFields to limit data retrieval
- Load only fields needed for processing
- Consider network and memory implications
- Balance selectivity with complexity

### 3. Optimize Date Range Queries
- Use efficient date filtering patterns
- Consider date index strategies
- Handle date boundaries correctly
- Optimize for common date range scenarios

## Common Pitfalls

### ❌ Avoid These Anti-Patterns:
- Filtering on non-indexed fields as primary filter
- Loading all fields when only few are needed  
- Complex filter expressions without index support
- Ignoring filter order and index structure

### ✅ Use These Patterns Instead:
- Index-aware filter ordering
- Selective field loading with SetLoadFields
- Efficient range queries with SetRange
- Progressive filtering from broad to specific

## Related Topics
- [N+1 Query Problem Solutions](n-plus-one-query-problem.md)
- [Bulk Processing Patterns](bulk-processing-patterns.md)
- [Database Query Samples](database-query-samples.md)
