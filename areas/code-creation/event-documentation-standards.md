---
title: "Event Documentation Standards"
description: "Comprehensive documentation patterns for AL integration and business events using XML comments and self-documenting code"
area: "code-creation"
difficulty: "intermediate"
object_types: ["Codeunit"]
variable_types: ["Record"]
tags: ["documentation", "events", "xml-comments", "self-documenting", "maintainability"]
---

# Event Documentation Standards

Proper documentation of AL events is critical for extensibility and maintainability. Well-documented events enable other developers to understand purpose, usage patterns, and parameter meanings without examining implementation details.

## XML Documentation Comments

### Integration Event Documentation Template

Use comprehensive XML documentation for all integration events:

```al
/// <summary>
/// Raised before customer credit limit validation begins.
/// Use to add custom validation rules or modify validation behavior.
/// </summary>
/// <param name="Customer">The customer record being validated</param>
/// <param name="RequestedLimit">The requested credit limit amount</param>  
/// <param name="IsHandled">Set to true to skip standard validation</param>
/// <param name="ValidationResult">Set validation result when IsHandled = true</param>
/// <param name="ValidationMessage">Custom message when validation fails</param>
/// <example>
/// Subscribe to add custom industry-specific credit validation:
/// <code>
/// [EventSubscriber(ObjectType::Codeunit, Codeunit::"Credit Validation", 'OnBeforeValidateCustomerCreditLimit', '', false, false)]
/// local procedure OnBeforeValidateCustomerCreditLimit(var Customer: Record Customer; RequestedLimit: Decimal; var IsHandled: Boolean; var ValidationResult: Boolean; var ValidationMessage: Text)
/// begin
///     if Customer."Industry Code" = 'HIGH-RISK' then begin
///         ValidationResult := RequestedLimit <= 1000;
///         ValidationMessage := 'High-risk customers limited to 1000 credit limit';
///         IsHandled := true;
///     end;
/// end;
/// </code>
/// </example>
/// <remarks>
/// Standard validation checks payment history, credit rating, and existing balances.
/// Extensions can completely replace validation by setting IsHandled = true.
/// When multiple subscribers set IsHandled, the last one wins.
/// </remarks>
[IntegrationEvent(false, false)]
local procedure OnBeforeValidateCustomerCreditLimit(var Customer: Record Customer; 
                                                   RequestedLimit: Decimal;
                                                   var IsHandled: Boolean;
                                                   var ValidationResult: Boolean;
                                                   var ValidationMessage: Text)
begin
end;
```

### Business Event Documentation Template

Business events require additional context about external system integration:

```al
/// <summary>
/// Published when customer loyalty status changes, providing data for external marketing systems.
/// Publishes structured JSON payload suitable for Power Automate and Logic Apps consumption.
/// </summary>
/// <param name="Customer">Customer record with updated loyalty status</param>
/// <param name="OldStatus">Previous loyalty status value</param>
/// <param name="NewStatus">New loyalty status value</param>
/// <param name="PointsBalance">Current loyalty points balance</param>
/// <param name="StatusEffectiveDate">Date when new status becomes effective</param>
/// <example>
/// JSON Payload Structure:
/// <code>
/// {
///   "eventType": "CustomerLoyaltyStatusChanged",
///   "timestamp": "2024-03-15T14:30:00Z",
///   "customer": {
///     "no": "CUST001",
///     "name": "Acme Corporation",
///     "email": "contact@acme.com"
///   },
///   "loyaltyChange": {
///     "oldStatus": "Silver",
///     "newStatus": "Gold", 
///     "pointsBalance": 15500,
///     "effectiveDate": "2024-03-15"
///   }
/// }
/// </code>
/// </example>
/// <remarks>
/// Integrating systems should:
/// - Handle duplicate events (idempotent processing)
/// - Validate customer exists in their system
/// - Update marketing segments and campaigns
/// - Trigger appropriate customer communications
/// 
/// Event is published synchronously - external failures will not rollback BC transaction.
/// Consider implementing retry logic in consuming systems.
/// </remarks>
procedure PublishCustomerLoyaltyStatusChanged(Customer: Record Customer; 
                                            OldStatus: Enum "Loyalty Status"; 
                                            NewStatus: Enum "Loyalty Status";
                                            PointsBalance: Integer;
                                            StatusEffectiveDate: Date)
```

## Self-Documenting Event Names

### Meaningful Event Naming Patterns

Events should be self-explanatory through descriptive names that indicate business context:

```al
// ✅ Good - Clear business meaning and context
OnBeforeCustomerCreditLimitValidation()
OnAfterSalesOrderConfirmation()
OnInventoryBelowReorderPoint()
OnCustomerPaymentOverdue()
OnItemDiscontinuationNotice()

// ✅ Good - State transition events with clear before/after
OnCustomerStatusChangedFromActiveToBlocked()
OnOrderStatusChangedFromPendingToConfirmed()
OnItemStatusChangedFromActiveToDiscontinued()

// ❌ Poor - Technical focus without business context
OnBeforeValidate()
OnAfterProcess()
OnDataChanged()
OnRecordModified()
```

### Parameter Naming Conventions

Use descriptive parameter names that indicate purpose and data type:

```al
// ✅ Good - Clear, descriptive parameter names
[IntegrationEvent(false, false)]
local procedure OnBeforeCalculateItemAvailability(var Item: Record Item; 
                                                 LocationFilter: Text;
                                                 DateFilter: Text;
                                                 var AvailableQuantity: Decimal;
                                                 var IsHandled: Boolean)

// ✅ Good - Record parameters for extensibility
[IntegrationEvent(false, false)]  
local procedure OnBeforeProcessSalesOrder(var SalesHeader: Record "Sales Header";
                                         var SalesLines: Record "Sales Line";
                                         ProcessingOptions: Record "Order Processing Setup")

// ❌ Poor - Generic, unclear parameter names
[IntegrationEvent(false, false)]
local procedure OnBeforeProcess(var Rec: Record "Sales Header"; 
                               var Lines: Record "Sales Line";
                               Options: Text)
```

## Usage Documentation Patterns

### Event Discovery Documentation

Help developers find and understand events through comprehensive usage documentation:

```al
/// <summary>
/// Sales Order Processing Events - Extension Guide
/// 
/// This codeunit provides integration events for customizing sales order processing workflow.
/// Events are designed to support common extension scenarios without code modification.
/// </summary>
/// <extensionScenarios>
/// Common extension scenarios supported:
/// 
/// 1. CUSTOM VALIDATION RULES
///    - Subscribe to OnValidateSalesOrder to add industry-specific validation
///    - Use ValidationErrors parameter to collect multiple validation issues
///    - Set IsHandled = true to replace standard validation entirely
/// 
/// 2. ORDER ENRICHMENT  
///    - Subscribe to OnAfterCreateSalesOrder to add custom fields or related data
///    - Modify SalesHeader and SalesLine records to add calculated values
///    - Create related records (custom tracking, external system references)
/// 
/// 3. EXTERNAL SYSTEM INTEGRATION
///    - Subscribe to OnAfterConfirmSalesOrder to notify external systems
///    - Use business event publishers for asynchronous external notifications
///    - Implement error handling for external system failures
/// 
/// 4. APPROVAL WORKFLOWS
///    - Subscribe to OnBeforeReleaseSalesOrder to check approval status
///    - Set IsHandled = true to prevent release pending approval
///    - Create approval entries and notification workflows
/// </extensionScenarios>
/// <performanceConsiderations>
/// Event Performance Guidelines:
/// - Keep event subscribers lightweight - avoid expensive operations
/// - Use TryFunction pattern for operations that might fail
/// - Batch external system calls where possible
/// - Cache frequently accessed data to avoid repeated database queries
/// - Consider async processing for non-critical operations
/// </performanceConsiderations>
codeunit 50200 "Sales Order Event Manager"
```

### Event Relationship Documentation

Document how events relate to each other and proper usage patterns:

```al
/// <summary>
/// Customer Registration Event Sequence
/// 
/// Events fire in this sequence during customer registration:
/// 1. OnBeforeValidateCustomerData - Validate and modify customer data
/// 2. OnBeforeInsertCustomer - Final chance to modify before insert
/// 3. OnAfterInsertCustomer - Customer record created, customize defaults
/// 4. OnAfterSetupCustomerDefaults - All defaults applied, add extensions
/// 5. OnAfterCustomerRegistrationComplete - Registration finished, external notifications
/// </summary>
/// <eventSequence>
/// Proper event usage patterns:
/// 
/// VALIDATION (Events 1-2):
/// - Add custom validation rules
/// - Modify customer data based on business rules  
/// - Prevent registration by raising errors
/// - Collect validation issues for user feedback
/// 
/// POST-CREATION (Events 3-4):
/// - Create related records (contacts, dimensions, custom tables)
/// - Apply extended configuration and setup
/// - Initialize feature-specific settings
/// 
/// COMPLETION (Event 5):
/// - Send external notifications
/// - Update integration systems
/// - Log audit trails
/// - Trigger follow-up workflows
/// </eventSequence>
/// <errorHandling>
/// Error Handling Guidelines:
/// - Events 1-2: Errors prevent customer creation (recommended)
/// - Events 3-4: Errors should be logged but not fail registration
/// - Event 5: Errors should be logged, retry mechanisms recommended
/// </errorHandling>
```

## Documentation Maintenance

### Version Documentation

Document event changes across versions for backward compatibility:

```al
/// <summary>
/// Customer Validation Event - Enhanced Parameters
/// </summary>
/// <versionHistory>
/// v1.0: OnValidateCustomer(Customer, IsValid, ErrorMessage)
/// v1.1: Added ValidationContext parameter for richer error reporting  
/// v1.2: Added ValidationErrors List parameter for multiple error collection
/// v2.0: BREAKING: Replaced single ErrorMessage with ValidationErrors List
/// </versionHistory>
/// <migrationGuidance>
/// Upgrading from v1.x to v2.0:
/// - Replace ErrorMessage parameter usage with ValidationErrors.Add(ErrorMessage)
/// - Update error handling to iterate ValidationErrors list
/// - Test all event subscribers with new parameter structure
/// 
/// Example migration:
/// OLD: if not IsValid then ErrorMessage := 'Validation failed';
/// NEW: if not IsValid then ValidationErrors.Add('Validation failed');
/// </migrationGuidance>
/// <backwardCompatibility>
/// v2.0 maintains compatibility by:
/// - Preserving IsValid parameter for simple validation scenarios
/// - ValidationErrors parameter is optional (can be ignored by simple subscribers)
/// - Event fires in same sequence and timing as previous versions
/// </backwardCompatibility>
[IntegrationEvent(false, false)]
local procedure OnValidateCustomerEnhanced(var Customer: Record Customer;
                                          var IsValid: Boolean;
                                          var ValidationErrors: List of [Text])
```

### Testing Documentation

Include testing guidance in event documentation:

```al
/// <summary>
/// Order Processing Event - Testing Guidelines
/// </summary>
/// <testingRecommendations>
/// Essential test scenarios for event subscribers:
/// 
/// 1. POSITIVE FLOW TESTING
///    - Verify event fires with expected parameters
///    - Confirm subscriber logic executes correctly
///    - Validate data modifications are applied
/// 
/// 2. ERROR CONDITION TESTING  
///    - Test subscriber error handling
///    - Verify graceful degradation when subscriber fails
///    - Confirm transaction rollback behavior
/// 
/// 3. PARAMETER VALIDATION TESTING
///    - Test with null/empty parameter values
///    - Verify parameter modification effects
///    - Test parameter combinations
/// 
/// 4. INTEGRATION TESTING
///    - Test with multiple subscribers
///    - Verify subscriber execution order
///    - Test subscriber interaction effects
/// </testingRecommendations>
/// <testCode>
/// Sample test structure:
/// <code>
/// [Test] 
/// procedure TestOrderProcessingEventFires()
/// var
///     SalesHeader: Record "Sales Header";
///     EventSubscriber: Codeunit "Test Event Subscriber";
/// begin
///     BindSubscription(EventSubscriber);
///     ProcessSalesOrder(SalesHeader);
///     Assert.IsTrue(EventSubscriber.WasEventFired(), 'Event should fire');
///     UnbindSubscription(EventSubscriber);
/// end;
/// </code>
/// </testCode>
```

## Documentation Best Practices

### Consistency Standards

- **Always document**: Every integration and business event
- **Use templates**: Consistent XML comment structure
- **Include examples**: Real-world usage scenarios in documentation
- **Version changes**: Document parameter and behavior changes
- **Performance notes**: Include performance considerations
- **Error scenarios**: Document error handling expectations

### Maintenance Guidelines

- **Review regularly**: Update documentation with functionality changes
- **Test examples**: Ensure documented examples compile and work
- **Validate links**: Keep cross-references accurate
- **User feedback**: Incorporate developer feedback into documentation

Well-documented events significantly reduce integration effort and improve code maintainability by providing clear, comprehensive guidance for extension developers.
