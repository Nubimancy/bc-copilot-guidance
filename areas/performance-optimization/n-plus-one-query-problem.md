---
title: "N+1 Query Problem Solutions"
description: "Identifying and resolving N+1 query anti-patterns in AL code"
area: "performance-optimization"
difficulty: "intermediate"
object_types: ["Table", "Report", "Page"]
variable_types: ["Record", "RecordRef"]
tags: ["performance", "n+1", "queries", "optimization"]
---

# N+1 Query Problem Solutions

## Overview
The N+1 query problem occurs when code executes one query to retrieve N records, then executes N additional queries to fetch related data for each record. This creates massive performance bottlenecks.

## Key Concepts

### What is N+1 Problem?
- **Initial Query**: Fetch N parent records
- **Subsequent Queries**: N additional queries for each parent's related data
- **Total Queries**: 1 + N (hence "N+1")
- **Performance Impact**: Linear degradation with data growth

### Common Triggers
- Nested loops with database operations
- Accessing related table data inside record loops
- Inefficient use of table relations
- Missing bulk processing patterns

## Best Practices

### 1. Identify N+1 Patterns
Look for these code structures:
- Record loops with Get() calls inside
- Nested record operations
- Related table lookups in processing loops
- Multiple individual record operations

### 2. Use Bulk Processing Instead
- Process related records in batches
- Use temporary tables for intermediate results
- Minimize database round trips
- Leverage set-based operations

### 3. Optimize Data Access
- Use SetLoadFields for selective loading
- Pre-fetch related data where possible
- Consider query objects for complex aggregations
- Implement efficient filtering strategies

## Common Pitfalls

### ❌ Avoid These Anti-Patterns:
- Individual record Get() calls in loops
- Accessing related tables inside record loops
- Processing records one by one
- Ignoring database operation counts

### ✅ Use These Patterns Instead:
- Bulk operations and temporary tables
- Pre-loaded related data
- Set-based processing approaches
- Efficient loop structures with minimal DB calls

## Related Topics
- [Bulk Processing Patterns](bulk-processing-patterns.md)
- [Query Filtering Optimization](query-filtering-optimization.md)
- [Database Query Samples](database-query-samples.md)
