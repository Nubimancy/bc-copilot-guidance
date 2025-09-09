---
title: "Performance Anti-Patterns"
description: "Common performance mistakes and inefficient patterns to avoid in AL"
area: "architecture-design"
difficulty: "intermediate"
object_types: ["Codeunit", "Table", "Report"]
variable_types: ["Record", "RecordRef", ]
tags: ["anti-patterns", "performance", "n-plus-one", "query-optimization", "setloadfields"]
---

# Performance Anti-Patterns

## Overview
Performance anti-patterns are coding practices that create unnecessary load on the database or application server, leading to poor user experience and scalability issues. These patterns often result from not understanding how AL interacts with the underlying SQL Server database.

## Key Concepts

### N+1 Query Problem
**Problem:** Executing one query to get a list, then one additional query for each item in the list

The N+1 pattern occurs when code retrieves a set of records and then makes individual database calls for each record:
- **Database Overload** - Generates excessive database round trips
- **Poor Scalability** - Performance degrades linearly with record count
- **Network Latency** - Each query suffers from network round-trip overhead
- **Resource Waste** - Inefficient use of database connection pool

### Inefficient Record Iteration
**Problem:** Loading unnecessary data or making redundant database calls during record processing

Common inefficient patterns include:
- **Loading All Fields** - When only specific fields are needed
- **Repeated Queries** - Making the same query multiple times
- **Inefficient Filtering** - Using AL code instead of database filtering
- **Missing SetLoadFields** - Not optimizing field loading for modern BC

### Blocking Operations in Loops
**Problem:** Performing expensive operations inside iteration loops

This creates multiplicative performance impact:
- **UI Blocking** - Long-running loops freeze the user interface
- **Transaction Locks** - Extended database transaction holding locks
- **Memory Consumption** - Accumulating objects without proper disposal
- **Timeout Risks** - Operations exceeding configured timeout limits

## Best Practices

### Use Efficient Query Patterns
- **Batch Operations** - Process multiple records in single database calls
- **Proper Filtering** - Apply filters at database level, not in AL code
- **SetLoadFields** - Only load the fields you actually need
- **Joins and Relations** - Use table relations efficiently

### Optimize Record Processing
- **Process in Batches** - Break large operations into manageable chunks
- **Use Temporary Records** - For complex processing scenarios
- **Minimize Database Calls** - Consolidate operations where possible
- **Proper Indexing** - Ensure database queries can use appropriate indexes

### Handle Large Data Sets Appropriately
- **Implement Pagination** - For user interfaces displaying many records
- **Background Processing** - For operations that don't need immediate results
- **Progress Indicators** - Keep users informed during longer operations
- **Timeout Handling** - Gracefully handle operation timeouts

## Common Pitfalls

### "It Works Fine in Development"
Small development datasets don't reveal performance issues that appear with production data volumes.

### "We Can Optimize Later"
Performance problems are much harder and more expensive to fix after system architecture is established.

### "Users Can Wait a Few Seconds"
Poor performance compounds - a few seconds per operation becomes hours for batch processes.

### "The Database Will Handle It"
While SQL Server is powerful, inefficient query patterns can overwhelm any database system.

## Related Topics
- [Object Design Anti-Patterns](object-design-anti-patterns.md)
- [Code Structure Anti-Patterns](code-structure-anti-patterns.md)
- [SetLoadFields Patterns](setloadfields-patterns.md)
- [Query Filtering Optimization](query-filtering-optimization.md)
