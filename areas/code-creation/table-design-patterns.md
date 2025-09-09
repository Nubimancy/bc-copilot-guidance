---
title: "Table Design Patterns"
description: "Architectural patterns and best practices for AL table design"
area: "code-creation"
difficulty: "intermediate"
object_types: ["Table", "TableExtension"]
variable_types: ["Record"]
tags: ["design", "architecture", "patterns"]
---

# Table Design Patterns

## Overview
Well-designed tables form the foundation of robust Business Central solutions. Proper design ensures maintainability, performance, and extensibility.

## Key Concepts

### Design Principles
- **Single Responsibility**: Each table has one clear purpose
- **Normalized Structure**: Minimize data redundancy
- **Extensibility**: Design for future enhancements
- **Performance**: Consider access patterns and indexing

### Table Structure Elements
- **Primary Key**: Unique identifier strategy
- **Field Organization**: Logical grouping and ordering
- **Indexes**: Performance optimization
- **Metadata**: Complete documentation and classification

## Best Practices

### 1. Consistent Naming Conventions
- Use descriptive table and field names
- Follow Business Central naming patterns
- Maintain consistency across related tables

### 2. Proper Data Classification
- Classify all fields according to privacy requirements
- Use appropriate DataClassification values
- Document sensitive data handling

### 3. Efficient Key Design
- Design primary keys for uniqueness and performance
- Consider clustered index implications
- Plan for common query patterns

### 4. Extensibility Considerations
- Reserve field numbers for extensions
- Design for modification without breaking changes
- Use proper access modifiers

## Common Pitfalls

### ❌ Avoid These Anti-Patterns:
- **God Tables**: Tables trying to do everything
- **Denormalized Chaos**: Excessive data duplication
- **Missing Metadata**: Incomplete documentation
- **Poor Key Design**: Inefficient primary keys
- **Validation in Wrong Places**: UI-only validation

### ✅ Use These Patterns Instead:
- **Focused Tables**: Single, clear responsibility
- **Proper Normalization**: Balanced structure
- **Complete Metadata**: Full documentation
- **Optimized Keys**: Performance-conscious design
- **Layered Validation**: Database, business, and UI layers

## Related Topics
- [Table Field Validation](table-field-validation.md)
- [Table Business Rules](table-business-rules.md)
- [Table Validation Samples](table-validation-samples.md)
