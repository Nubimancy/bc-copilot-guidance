---
title: "Error Handling Principles"
description: "Core principles for effective error handling in AL development"
area: "error-handling"
difficulty: "beginner"
object_types: ["Codeunit", "Table", "Page"]
variable_types: ["ErrorInfo"]
tags: ["error-handling", "principles", "user-experience", "best-practices"]
---

# Error Handling Principles

## Overview

Effective error handling in Business Central AL development follows core principles that prioritize user experience, actionable feedback, and appropriate technical mechanisms.

## Core Principles

### 1. Always Provide Actionable Information

Error messages should:
- **Clearly explain what went wrong** - Avoid technical jargon and cryptic messages
- **Provide context about why it happened** - Help users understand the business logic
- **Offer guidance on how to fix the problem** - Include specific steps or suggestions
- **When possible, include actions the user can take directly from the error** - Use suggested actions

**Example Context:**
```
❌ Bad: "Credit limit exceeded"
✅ Good: "Credit limit of $10,000 exceeded. Requested amount: $15,000. Consider increasing the credit limit or reducing the order amount."
```

### 2. Use Appropriate AL Mechanisms

Choose the right AL method based on the situation:

- **Use `Error`** for critical errors that should stop processing
  - Data validation failures
  - Business rule violations
  - System failures that prevent continuation

- **Use `Message`** for informational messages that don't stop processing
  - Status updates
  - Warnings that don't block operations
  - Confirmation of completed actions

- **Use `Confirm`** when user confirmation is required before proceeding
  - Destructive operations
  - Important business decisions
  - Continuing with warnings

- **Use `StrMenu`** when the user needs to make a choice
  - Multiple valid options
  - Alternative processing paths
  - User preferences

### 3. Layer Error Information

Structure errors with multiple levels of detail:
- **Primary message** - Brief, user-friendly explanation
- **Detailed message** - Technical context and resolution steps  
- **Suggested actions** - Direct user actions to resolve the issue

### 4. Consider the User Context

Tailor error messages to the user's role and technical expertise:
- **End users** - Focus on business impact and resolution steps
- **Administrators** - Include system context and configuration guidance
- **Developers** - Provide technical details and debugging information

## Business Benefits

Following these principles delivers:
- **Improved user experience** - Users understand and can resolve issues
- **Reduced support burden** - Clear messages reduce help desk calls
- **Faster problem resolution** - Actionable guidance speeds fixes
- **Better system adoption** - Users trust systems that communicate clearly

## Implementation Guidelines

1. **Start with the user** - Write errors from the user's perspective
2. **Test error scenarios** - Ensure messages make sense in context
3. **Use consistent language** - Maintain terminology across the application
4. **Review regularly** - Update messages based on user feedback

These principles form the foundation for all error handling patterns and should guide every error message you create.
