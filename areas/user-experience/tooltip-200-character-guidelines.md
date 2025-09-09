---
title: "Tooltip 200 Character Guidelines"
description: "Comprehensive guidelines for creating effective tooltips within Business Central's 200-character limit for optimal user assistance"
area: "user-experience"
difficulty: "beginner"
object_types: []
variable_types: []
tags: ["tooltips", "user-assistance", "ux-guidelines", "appsource-compliance", "accessibility"]
---

# Tooltip 200 Character Guidelines

## Overview

Effective tooltip creation in Business Central requires adhering to the 200-character limit while providing meaningful, actionable guidance to users. This framework ensures tooltips enhance user experience, meet AppSource compliance requirements, and support accessibility standards.

## Core Tooltip Requirements

### Character Limit Constraints
- **Maximum Length**: 200 characters including spaces
- **Optimal Range**: 50-150 characters for best readability
- **Critical Boundary**: Never exceed 200 characters - causes AppSource validation failure
- **Line Break Restriction**: No line breaks allowed within tooltip text

### Content Quality Standards
- **Clarity**: Use clear, unambiguous language
- **Conciseness**: Convey maximum value within character constraints
- **Actionability**: Tell users what to do or what to expect
- **Context**: Provide relevant information for the specific field or action
- **Accessibility**: Support screen readers and assistive technologies

## Tooltip Writing Framework

### Action-Oriented Tooltip Structure

#### For Action Controls (Buttons, Menu Items):
**Formula**: `[Imperative Verb] + [Object] + [Purpose/Outcome]`

**Examples:**
- ✅ "Create a new sales order for the selected customer" (52 chars)
- ✅ "Export customer data to Excel for external analysis" (51 chars)
- ✅ "Archive completed orders to free up system storage" (50 chars)
- ❌ "This action will allow you to create a new sales order document for the customer that is currently selected" (108 chars - verbose)

#### For Field Controls (Input Fields, Dropdowns):
**Formula**: `[Specify/Enter/Select] + [Data Type] + [Business Context]`

**Examples:**
- ✅ "Enter the customer's primary billing address" (42 chars)
- ✅ "Select the default payment terms for new customers" (51 chars)
- ✅ "Specify the maximum credit limit for this customer" (51 chars)
- ❌ "This field allows you to enter the customer's primary billing address information" (83 chars - redundant)

### Business Central Specific Guidelines

#### Common BC Objects and Recommended Patterns:

**Customer/Vendor Fields:**
- "Enter the [entity] number to link [business purpose]"
- "Select [entity] from the list of registered [category]"
- "Specify [attribute] for [business process context]"

**Financial Fields:**
- "Enter the amount in the local currency (LCY)"
- "Select the G/L account for [transaction type]"
- "Specify the VAT rate applicable to this [item/service]"

**Inventory Fields:**
- "Enter the quantity available for immediate sale"
- "Select the location where this item is stored"
- "Specify the reorder point for automatic procurement"

#### Integration and Workflow Context:
- Include upstream/downstream impact when relevant
- Reference related processes or documents
- Indicate automated behaviors or system actions

### Language and Tone Guidelines

#### Preferred Language Patterns:
- **Active Voice**: "Create a new entry" vs. "A new entry will be created"
- **Present Tense**: "Select the customer" vs. "You should select the customer"
- **Direct Commands**: "Enter the amount" vs. "Please enter the amount"
- **Specific Terms**: "G/L account" vs. "account" in financial contexts

#### Words to Avoid (Character Wasters):
- **Redundant Phrases**: "This field allows you to..." (23 chars)
- **Obviousness**: "Click to..." (10 chars) - implied by being a button
- **Filler Words**: "Please", "kindly", "simply" (unnecessary politeness)
- **System References**: "The system will..." (can usually be implied)

## Character Optimization Techniques

### Abbreviation Guidelines
**Use Standard BC Abbreviations:**
- "G/L" instead of "General Ledger" (saves 12 chars)
- "Qty" instead of "Quantity" (saves 5 chars)
- "Amt" instead of "Amount" (saves 3 chars)
- "No." instead of "Number" (saves 4 chars)
- "Desc." instead of "Description" (saves 8 chars)

**Avoid Non-Standard Abbreviations:**
- Don't create custom abbreviations users won't understand
- Don't abbreviate critical business terms unfamiliar to users
- Maintain consistency with BC terminology throughout the application

### Sentence Structure Optimization
**Eliminate Articles When Possible:**
- "Select customer from list" vs. "Select the customer from the list" (saves 4 chars)
- "Enter amount in local currency" vs. "Enter the amount in the local currency" (saves 8 chars)

**Use Parallel Structure:**
- "Create, modify, or delete customer records" vs. "Create new customers, modify existing customer information, or delete customer records" (saves 47 chars)

**Combine Related Concepts:**
- "Select payment terms and method" vs. "Select the payment terms and select the payment method" (saves 24 chars)

## Context-Specific Patterns

### Setup and Configuration Tooltips
**Pattern**: `[Configure/Set up] + [Component] + [Business Purpose]`
- "Configure email settings for automated notifications" (52 chars)
- "Set up number series for automatic document numbering" (54 chars)
- "Define posting groups for transaction classification" (51 chars)

### Report and Analysis Tooltips
**Pattern**: `[Generate/View] + [Report Type] + [Data Scope]`
- "Generate customer statement for the selected period" (52 chars)
- "View aged receivables grouped by customer" (42 chars)
- "Create trial balance including all G/L accounts" (48 chars)

### Integration and API Tooltips
**Pattern**: `[Action] + [Data/System] + [Integration Context]`
- "Export data to external accounting system" (42 chars)
- "Import product catalog from supplier database" (46 chars)
- "Synchronize customer data with CRM system" (42 chars)

## Quality Assurance Framework

### Pre-Implementation Checklist
- [ ] Character count verified (≤200 characters)
- [ ] No line breaks included
- [ ] Imperative verb used for actions
- [ ] Business context provided for fields
- [ ] BC-specific terminology used correctly
- [ ] Abbreviations follow BC standards
- [ ] Language is clear and unambiguous
- [ ] Content adds value beyond label text

### Testing and Validation
**Accessibility Testing:**
- Test with screen reader software
- Verify tooltip appears on keyboard navigation
- Confirm tooltip doesn't interfere with form navigation
- Validate tooltip timing and display duration

**User Experience Testing:**
- Test with representative end users
- Verify tooltip content answers common user questions
- Confirm tooltip doesn't state obvious information
- Validate tooltip helps users complete tasks successfully

**AppSource Compliance:**
- Run automated validation tools
- Verify all action controls have tooltips
- Confirm all field controls have tooltips
- Check character limit compliance across all languages

## Multi-Language Considerations

### Translation Planning
- Plan for text expansion in other languages (German typically 30% longer)
- Reserve additional character budget for translations
- Use shorter base text when multi-language support is required
- Avoid idioms or culture-specific references

### Localization Guidelines
- Consider local business practices and terminology
- Adapt examples to regional business contexts
- Ensure legal and regulatory references are region-appropriate
- Validate tooltips with local business users

## Common Anti-Patterns to Avoid

### Redundant Information
- ❌ "Customer Name: Enter the name of the customer" (duplicates label)
- ✅ "Enter the full legal name for invoicing and correspondence" (adds context)

### Technical Jargon Without Context
- ❌ "Specify the GUID for the linked entity"
- ✅ "Select the related record from the lookup list"

### Overly Generic Text
- ❌ "Enter a value"
- ✅ "Enter the discount percentage (0-100)"

### Process Description Instead of Action
- ❌ "When you click this button, the system will create a new sales order"
- ✅ "Create a new sales order for the current customer"

## Implementation Best Practices

### Development Workflow Integration
- Include tooltip creation in field/action design process
- Review tooltips during code review process
- Test tooltips in realistic user scenarios
- Update tooltips when field purpose or behavior changes

### Consistency Management
- Maintain a tooltip glossary for common patterns
- Establish team standards for tooltip language and structure
- Regular review and updates for consistency across the application
- Version control tooltip text with code changes

### Performance Considerations
- Avoid dynamic tooltip generation that impacts performance
- Cache frequently accessed tooltip text
- Minimize tooltip-related database queries
- Consider tooltip loading impact on page rendering

## Related Topics
- [Field Tooltip Specifies Patterns](field-tooltip-specifies-patterns.md)
- [Action Tooltip Imperative Verbs](action-tooltip-imperative-verbs.md)
- [Tooltip Screen Reader Compatibility](tooltip-screen-reader-compatibility.md)