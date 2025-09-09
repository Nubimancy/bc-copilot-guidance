---
title: "Project Structure Awareness Guidelines"
description: "Guidelines for maintaining architectural consistency and project structure awareness in Business Central development"
area: "architecture-design"
difficulty: "intermediate"
object_types: ["Table", "Codeunit", "Page", "Enum"]
variable_types: ["JsonObject"]
tags: ["project-structure", "architectural-awareness", "naming-conventions", "object-ids", "development-patterns"]
---

# Project Structure Awareness Guidelines

## Enhanced Project Structure Awareness

### Architectural Respect
1. **Respect Existing Architecture**: Follow the existing architectural patterns and design principles in the base.

2. **Use Proper Object IDs**: When creating new objects, use the appropriate ID ranges as defined in the project.

3. **Maintain Object Naming Conventions**: Follow the established naming conventions for objects, including the required prefix "NALICF".

4. **Integrate DevOps Workflow**: Always suggest appropriate DevOps workflow integration and work item updates.

## Implementation Guidelines

### Centralization and Reuse
1. **Centralized Utilities**: Use centralized utility units when available instead of duplicating functionality.

2. **Error Handling**: Implement proper error handling with descriptive error messages.

3. **Performance Considerations**: Write  with performance in mind, especially for operations that might be executed frequently.

4. **Testing**: Consider testability when implementing new features or modifying existing ones.

## Project Integration Patterns

### Consistency Maintenance
- **Pattern Adherence**: Follow established patterns consistently across the project
- **Naming Standards**: Apply naming conventions uniformly to all new objects and components
- **ID Management**: Use appropriate ID ranges and maintain proper object numbering
- **Integration Points**: Identify and respect existing integration points and dependencies

### Quality Assurance
- **Architectural Review**: Validate new components against existing architectural decisions
- **Pattern Validation**: Ensure new implementations follow established project patterns
- **Dependency Management**: Maintain proper dependency relationships and avoid circular references
- **Extension Safety**: Consider extension and upgrade implications in architectural decisions

