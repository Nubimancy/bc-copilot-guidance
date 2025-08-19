# AL Code Style Guidelines - AI-Enhanced Style Coaching

<!-- AI_TRIGGER: When developer writes AL code, proactively suggest style improvements and consistency validation -->
<!-- COPILOT_GUIDANCE: This guide teaches intelligent code style enforcement with proactive suggestions and DevOps integration -->

This document outlines the coding standards and best practices for AL code in this project. Following these guidelines ensures consistent, maintainable, and high-quality code, enhanced with AI training patterns for proactive style guidance.

## How to Use This Guide with Copilot

**See**: [`shared-templates.md`](../shared-templates.md) Template B for complete AI instruction patterns.

**Context**: Code style standards (STANDARDS_CONTEXT="code style", BASIC_STANDARDS_REQUEST="Fix code style", ENHANCED_STANDARDS_REQUEST="Apply code style standards following established guidelines")

## Table of Contents

### Quick Navigation
- [Quick Reference](#quick-reference) - Key style rules and patterns
- [Common Patterns](#common-patterns) - Frequently used code structures
- [Troubleshooting](#troubleshooting) - Style issue resolution

### Detailed Content
1. [Variable Naming Conventions](#variable-naming-conventions)
2. [Code Formatting Standards](#code-formatting-standards)
3. [Object Property Qualification](#object-property-qualification)
4. [String Formatting](#string-formatting)
5. [ToolTips](#tooltips)
6. [Text Constants and Localization](#text-constants-and-localization)
7. [Performance Considerations](#performance-considerations)
8. [Search Keywords](#search-keywords)
9. [Cross-References](#cross-references)

## Variable Naming Conventions

<!-- AI_TRIGGER: When developer declares variables, suggest naming convention compliance and style validation -->
<!-- PROACTIVE_SUGGEST: During variable declaration -> Suggest style consistency and DevOps quality gates -->

1. **PascalCase for Object Names**: Use PascalCase for all object names (tables, pages, codeunits, etc.)
   ```al
   codeunit 50100 "Sales Order Processor"
   
   <!-- COPILOT_GUIDANCE: When showing naming examples, remind developers to:
   1. Add naming convention validation to CI/CD pipeline
   2. Update work items with object naming decisions
   3. Consider code review checklist for naming compliance
   4. Document naming rationale for complex objects
   -->
   ```

2. **PascalCase for Variable Names**: Use PascalCase for all variable names
   ```al
   var
       Customer: Record Customer;
       SalesHeader: Record "Sales Header";
       TotalAmount: Decimal;
       
   <!-- AI_TRIGGER: When developer declares variables, suggest consistent naming patterns -->
   ```

3. **Prefix Temporary Variables**: Use prefix 'Temp' for temporary records
   ```al
   var
       TempSalesLine: Record "Sales Line" temporary;
   ```

4. **Variable Declaration Order**: Variables should be ordered by type in the following sequence:
   - Record
   - Report
   - Codeunit
   - XmlPort
   - Page
   - Query
   - Notification
   - BigText
   - DateFormula
   - RecordId
   - RecordRef
   - FieldRef
   - FilterPageBuilder
   - Other types (Text, Integer, Decimal, etc.)

## Data Types

1. **Use Enums Instead of Options**: Always use enums instead of the deprecated option data type
   ```al
   // Preferred: Use enum
   enum 50100 "Document Status"
   {
       Extensible = true;

       value(0; Open) { Caption = 'Open'; }
       value(1; "Pending Approval") { Caption = 'Pending Approval'; }
       value(2; Approved) { Caption = 'Approved'; }
       value(3; Rejected) { Caption = 'Rejected'; }
   }

   // In your table or variable declaration
   var
       DocumentStatus: Enum "Document Status";
   ```2. **Option Type Exceptions**: The only acceptable uses of option data type are:

   **Exception 1**: When calling existing procedures that use option parameters
   ```al
   // Acceptable when calling standard BC procedures
   var
       Direction: Option Forward,Backward;
   begin
       // Calling a standard procedure that expects option parameter
       Customer.Next(Direction::Forward);
   end;
   ```

   **Exception 2**: When subscribing to events that use option parameters
   ```al
   // Acceptable in event subscribers
   [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
   local procedure OnBeforePostSalesDoc(var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; var HideProgressWindow: Boolean; var IsHandled: Boolean; var DefaultOption: Option " ",Ship,Invoice,"Ship and Invoice")
   begin
       // Event handler code here
   end;
   ```

3. **Enum Best Practices**: When creating enums, follow these guidelines:
   ```al
   enum 50101 "Payment Method"
   {
       Extensible = true;  // Always make extensible unless there's a specific reason not to

       value(0; " ") { Caption = ' '; }  // Include blank value when appropriate
       value(1; Cash) { Caption = 'Cash'; }
       value(2; "Credit Card") { Caption = 'Credit Card'; }
       value(3; "Bank Transfer") { Caption = 'Bank Transfer'; }
       value(4; Check) { Caption = 'Check'; }
   }
   ```

4. **Converting Options to Enums**: When refactoring existing option fields, create corresponding enums
   ```al
   // Old option field (deprecated)
   // Status: Option " ",Open,"Pending Approval",Approved,Rejected;

   // New enum approach
   Status: Enum "Document Status";

   // Conversion procedure for data migration
   procedure ConvertOptionToEnum(OptionValue: Integer): Enum "Document Status"
   begin
       case OptionValue of
           0: exit("Document Status"::" ");
           1: exit("Document Status"::Open);
           2: exit("Document Status"::"Pending Approval");
           3: exit("Document Status"::Approved);
           4: exit("Document Status"::Rejected);
       end;
   end;
   ```## Code Formatting and Indentation

1. **Indentation**: Use 4 spaces for indentation (not tabs)

2. **Line Length**: Keep lines under 120 characters when possible

3. **Braces**: Place opening braces on the same line as the statement
   ```al
   if Customer.Find() then begin
       // Code here
   end;
   ```

4. **BEGIN..END Usage**: Only use BEGIN..END to enclose compound statements (multiple lines)
   ```al
   // Correct
   if Customer.Find() then
       Customer.Delete();

   // Also correct (for multiple statements)
   if Customer.Find() then begin
       Customer.CalcFields("Balance (LCY)");
       Customer.Delete();
   end;
   ```

5. **IF-ELSE Structure**: Each 'if' keyword should start a new line
   ```al
   if Condition1 then
       Statement1
   else if Condition2 then
       Statement2
   else
       Statement3;
   ```

6. **CASE Statement**: Use CASE instead of nested IF-THEN-ELSE when comparing the same variable against multiple values
   ```al
   // Instead of this:
   if Type = Type::Item then
       ProcessItem()
   else if Type = Type::Resource then
       ProcessResource()
   else
       ProcessOther();

   // Use this:
   case Type of
       Type::Item:
           ProcessItem();
       Type::Resource:
           ProcessResource();
       else
           ProcessOther();
   end;
   ```## Object Property Qualification

1. **Use "this" Qualification**: Always use "this" to qualify object properties when accessing them from within the same object
   ```al
   // In a table or page method
   procedure SetStatus(NewStatus: Enum "Status")
   begin
       this.Status := NewStatus;
       this.Modify();
   end;
   ```

2. **Explicit Record References**: Always use explicit record references when accessing fields
   ```al
   // Correct
   Customer.Name := 'CRONUS';

   // Incorrect
   Name := 'CRONUS';
   ```

## String Formatting

1. **Text Constants for String Formatting**: Use text constants for string formatting instead of hardcoded strings
   ```al
   // Define at the top of the object
   var
       CustomerCreatedMsg: Label 'Customer %1 has been created.';

   // Use in code
   Message(CustomerCreatedMsg, Customer."No.");
   ```

2. **String Concatenation**: Use string formatting instead of concatenation
   ```al
   // Instead of this:
   Message('Customer ' + Customer."No." + ' has been created.');

   // Use this:
   Message(CustomerCreatedMsg, Customer."No.");
   ```

3. **Placeholders**: Use numbered placeholders (%1, %2, etc.) in labels
   ```al
   ErrorMsg: Label 'Cannot delete %1 %2 because it has %3 entries.';
   ```## Error Handling

1. **Descriptive Error Messages**: Provide clear, actionable error messages
   ```al
   if not Customer.Find() then
       Error(CustomerNotFoundErr, CustomerNo);
   ```

2. **Error Constants**: Define error messages as constants
   ```al
   CustomerNotFoundErr: Label 'Customer %1 does not exist.';
   ```

## Comments

1. **Procedure Comments**: Document the purpose of procedures, parameters, and return values
   ```al
   /// <summary>
   /// Calculates the total amount for a sales document.
   /// </summary>
   /// <param name="DocumentType">The type of the sales document.</param>
   /// <param name="DocumentNo">The number of the sales document.</param>
   /// <returns>The total amount of the sales document.</returns>
   procedure CalculateTotalAmount(DocumentType: Enum "Sales Document Type"; DocumentNo: Code[20]): Decimal
   ```

2. **Code Comments**: Add comments to explain complex logic or business rules

## Removing Unused Variables

1. **Remove Unused Variables**: Delete variables that are declared but not used in the code
   ```al
   // If TempRecord is never used, remove it
   var
       Customer: Record Customer;
       // TempRecord: Record "Temp Record";  // Unused - should be removed
   ```

## Performance Considerations

1. **Use FindSet() with Repeat-Until**: For looping through records
   ```al
   if SalesLine.FindSet() then
       repeat
           // Process each record
       until SalesLine.Next() = 0;
   ```

2. **Use SetRange/SetFilter Before Find**: Limit record sets before processing
   ```al
   Customer.SetRange("Country/Region Code", 'US');
   if Customer.FindSet() then
   ```

## ToolTips

- All fields should have tooltips to provide context and guidance to users
- Use the `ToolTip` property in AL to define tooltips for fields, actions, and controls
- Ensure tooltips are concise and informative, helping users understand the purpose and usage of each field or action
- Avoid overly technical jargon in tooltips; aim for clarity and simplicity
- Use consistent terminology and phrasing across tooltips to maintain a cohesive user experience
- Review and update tooltips regularly to ensure they reflect any changes in functionality or user interface
- ToolTips on fields must start with 'Specifies' to maintain consistency and clarity

## Text Constants and Localization

- Use text constants or labels for all user-facing strings to support localization
- Define text constants at the beginning of the codeunit or page where they are used
- Use descriptive names for text constants that indicate their purpose
- When using StrSubstNo, always use a text constant or label for the format string
- Format text constant names as: ErrorMsg, ConfirmQst, InfoMsg, etc.
- Example:
  ```al
  var
      TypeMismatchErr: Label 'Field type mismatch: %1 field cannot be mapped to %2 field.';
  begin
      ErrorMessage := StrSubstNo(TypeMismatchErr, Format(CustomFieldType), Format(TargetFieldType));
  end;
  ```

By following these guidelines, you'll create more maintainable, readable, and efficient AL code.

## Quick Reference

## DevOps Integration for Code Style

<!-- AI_TRIGGER: When developer works on code style, suggest DevOps automation and quality gate integration -->
<!-- PROACTIVE_SUGGEST: During style improvements -> Suggest automated validation and team standards -->

### Automated Style Validation

**CI/CD Pipeline Integration:**
- Automated linting and style checking in build pipeline
- Style compliance validation before merge approval
- Code quality metrics tracking and reporting
- Style regression prevention in deployment pipeline

<!-- COPILOT_GUIDANCE: When discussing style automation, remind developers to:
1. Configure AL linting rules in development environment
2. Set up automated style checking in pull request validation
3. Track style compliance metrics in work item reporting
4. Document style decisions and exceptions in work items
-->

**Quality Gates for Code Style:**
- Style compliance validation before code review
- Naming convention verification in automated testing
- Code formatting validation in deployment pipeline
- Style consistency monitoring in production code

### Team Style Standards

**Code Review Integration:**
- Style checklist validation in peer reviews
- Consistent style feedback and improvement suggestions
- Style mentoring for new team members
- Documentation of style decisions and rationale

**Development Workflow:**
- Style guide integration in development environment
- Automated style formatting tools and configuration
- Style training and knowledge sharing sessions
- Continuous improvement of style standards

## Code Style Best Practices Summary

<!-- EDUCATIONAL_ESCALATION:
LEVEL_1: Suggest specific style improvement for developer's code
LEVEL_2: Provide detailed style guidance with examples and rationale
LEVEL_3: Explain style impact on maintainability and DevOps integration
LEVEL_4: Discuss enterprise-level style governance and automation strategies
-->

### Quick Code Style Checklist

<!-- AI_TRIGGER: When developer completes AL code, suggest this style validation checklist -->
<!-- PROACTIVE_SUGGEST: Before code review -> Suggest comprehensive style validation -->

- [ ] **Variable Naming**: All variables and objects use PascalCase
- [ ] **Variable Ordering**: Variables declared in proper type order
- [ ] **String Formatting**: StrSubstNo used with text constants for dynamic strings
- [ ] **ToolTips**: Field tooltips start with 'Specifies' and provide clear guidance
- [ ] **Code Formatting**: Consistent indentation and line breaks
- [ ] **Object Qualification**: Proper object property qualification
- [ ] **Performance Considerations**: Style choices support performance optimization
- [ ] **Localization**: Text constants and labels properly implemented
- [ ] **DevOps Integration**: Style validation integrated in CI/CD pipeline
- [ ] **Documentation**: Style decisions documented in work items

### AI-Enhanced Code Style Development

<!-- CONTEXT_RECOGNITION_PATTERNS:
IF developer_writing_al_code AND style_inconsistencies_detected:
  SUGGEST: "Review code style consistency for better maintainability"
  EDUCATE: "Consistent code style improves readability and team collaboration"

IF developer_declaring_variables AND naming_inconsistency_detected:
  SUGGEST: "Consider using consistent PascalCase naming for variables"
  EDUCATE: "Consistent variable naming helps with code readability and maintenance"

IF developer_working_on_code AND no_style_validation_mentioned:
  SUGGEST: "Add style validation to your development workflow"
  EDUCATE: "Automated style validation prevents style debt and improves code quality"
-->

### Key Style Rules
- **Variable Naming**: PascalCase for all variables and objects
- **Variable Ordering**: Record, Report, Codeunit, XMLPort, Page, Query, then others
- **String Formatting**: Use StrSubstNo with text constants for all dynamic strings
- **ToolTips**: Start field tooltips with 'Specifies', use clear and concise language
- **Performance**: Use SetLoadFields, avoid nested loops, implement proper filtering

This guide enables Copilot to provide intelligent, context-aware guidance for AL code style, ensuring consistency, maintainability, and proper DevOps integration throughout the development lifecycle.

### Common Patterns
```al
// Standard variable declaration order
var
    SalesHeader: Record "Sales Header";
    Customer: Record Customer;
    TempSalesLine: Record "Sales Line" temporary;
    ProcessingMsg: Label 'Processing %1...';
    TotalAmount: Decimal;
```

## Search Keywords

### AL Language Keywords
**Code Structure**: Variable naming, PascalCase, object qualification, procedure structure, AL syntax
**Formatting Standards**: Code formatting, indentation, line breaks, string formatting, text constants
**Performance Patterns**: SetLoadFields, bulk operations, filtering, record processing, optimization

### Business Central Concepts
**Object Development**: Page design, field tooltips, user experience, accessibility
**Extension Standards**: AL best practices, code quality, maintainability, AppSource compliance
**Localization**: Text constants, labels, multilingual support, internationalization

### Development Patterns
**Code Quality**: Consistent formatting, readable code, maintainable structure, error prevention
**Style Guidelines**: Naming conventions, code organization, documentation, best practices
**Team Standards**: Consistent development, code review patterns, quality assurance

## Cross-References

### Related SharedGuidelines
- **Naming Conventions**: `SharedGuidelines/Standards/naming-conventions.md` - Variable and object naming rules
- **Error Handling**: `SharedGuidelines/Standards/error-handling.md` - Error message formatting and text constants
- **Core Principles**: `SharedGuidelines/Configuration/core-principles.md` - Development foundation

### Workflow Applications
- **CoreDevelopment**: Implementation of style guidelines in object creation
- **TestingValidation**: Style standards for test code and validation procedures
- **PerformanceOptimization**: Performance-focused coding patterns and optimizations
- **AppSourcePublishing**: Code style compliance for marketplace requirements