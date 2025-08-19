# Object Patterns - AI-Enhanced Development Guide

<!-- AI_INSTRUCTION: This guide teaches GitHub Copilot to proactively suggest AL object patterns, improve developer prompts, and integrate Azure DevOps workflows naturally into development guidance -->

**Purpose**: Transform AL object development through intelligent guidance that educates developers, improves prompts, and ensures quality standards.

## How to Use This Guide with Copilot

**See**: [`../shared-templates.md`](../shared-templates.md) Template A for complete AI instruction patterns.

**Context**: Object development patterns (CONTEXT="object development", BASIC_REQUEST="Create a table", ENHANCED_REQUEST="Create comprehensive AL objects following established patterns with validation and testing")

---

## Progressive Learning Path

### 🟢 Beginner Object Patterns
**For developers new to AL or Business Central**

#### Basic Table Creation with Guided Learning

<!-- AI_TRIGGER: When beginner creates table -> Suggest field validation and explain why data integrity matters -->

**Learning Objective**: Create well-structured tables with proper validation

```al
// Following naming conventions from SharedGuidelines/Standards/naming-conventions.md
// Implementing validation patterns from SharedGuidelines/Standards/error-handling.md
table 50100 "BRC Customer Rating"
{
    Caption = 'Customer Rating';
    DataClassification = CustomerContent;
    LookupPageId = "BRC Customer Rating List";
    DrillDownPageId = "BRC Customer Rating List";

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            ToolTip = 'Specifies the number of the customer for this rating.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
            NotBlank = true;
            
            // Educational note: Table relations ensure data integrity
            trigger OnValidate()
            begin
                ValidateCustomerExists(); // Proper validation pattern
            end;
        }
        
        field(2; "Rating Score"; Integer)
        {
            Caption = 'Rating Score';
            ToolTip = 'Specifies the rating score from 1 to 5.';
            DataClassification = CustomerContent;
            MinValue = 1;
            MaxValue = 5;
            
            // Educational note: MinValue/MaxValue provide automatic validation
        }
    }
    
    // Educational note: Always implement validation procedures
    local procedure ValidateCustomerExists()
    var
        Customer: Record Customer;
    begin
        if "Customer No." = '' then
            exit;
            
        if not Customer.Get("Customer No.") then
            Error('Customer %1 does not exist.', "Customer No.");
    end;
}
```

<!-- PROACTIVE_SUGGEST: After table creation -> "Consider creating a corresponding test codeunit using TestingValidation/test-data-patterns.md to validate your table logic" -->

#### Prompt Enhancement for Beginners

<!-- PROMPT_EDUCATION: 
WEAK: "Make a page"
BETTER: "Create a Business Central card page for customer ratings following UI patterns from CoreDevelopment/object-patterns.md, with proper field grouping, actions for navigation, and error handling"
EDUCATIONAL_NOTE: "Page prompts should specify page type (card/list), business context (customer ratings), and include UI patterns and error handling. This ensures consistent, user-friendly interfaces."
-->

### 🟡 Intermediate Object Patterns
**For developers comfortable with basic AL concepts**

#### Advanced Validation with Business Logic

<!-- AI_TRIGGER: When intermediate developer implements business logic -> Suggest error handling patterns and testing considerations -->

**Learning Objective**: Implement complex business rules with proper error handling

```al
// Complex business validation following established patterns
table 50101 "BRC Customer Loyalty Points"
{
    Caption = 'Customer Loyalty Points';
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            ToolTip = 'Specifies the customer number.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
            NotBlank = true;
            
            trigger OnValidate()
            begin
                ValidateCustomerEligibility();
            end;
        }
        
        field(10; "Current Points"; Integer)
        {
            Caption = 'Current Points';
            ToolTip = 'Specifies the current loyalty points balance.';
            DataClassification = CustomerContent;
            MinValue = 0;
            
            trigger OnValidate()
            begin
                ValidatePointsAdjustment();
            end;
        }
    }
    
    // Complex business logic with proper error handling
    local procedure ValidateCustomerEligibility()
    var
        Customer: Record Customer;
        CustomerRating: Record "BRC Customer Rating";
    begin
        if not Customer.Get("Customer No.") then
            Error('Customer %1 does not exist.', "Customer No.");
            
        if Customer.Blocked <> Customer.Blocked::" " then
            Error('Cannot assign loyalty points to blocked customer %1.', "Customer No.");
            
        // Business rule: Customer must have minimum rating
        CustomerRating.SetRange("Customer No.", "Customer No.");
        CustomerRating.CalcFields("Average Rating");
        if CustomerRating."Average Rating" < 3.0 then
            Error('Customer %1 does not meet minimum rating requirement for loyalty program.', "Customer No.");
    end;
    
    local procedure ValidatePointsAdjustment()
    begin
        if ("Current Points" - xRec."Current Points") > 1000 then
            if not Confirm('Points increase of %1 is unusually large. Continue?', false, "Current Points" - xRec."Current Points") then
                Error('');
    end;
}
```

<!-- PROACTIVE_SUGGEST: When implementing complex validation -> "Consider documenting this business logic in your Azure DevOps work item for future reference and team understanding" -->

#### DevOps Integration for Intermediate Developers

<!-- COPILOT_GUIDANCE: When developer implements intermediate patterns, proactively suggest:
1. Work item documentation with business rules
2. Test creation for complex validation logic  
3. Performance consideration review
4. Integration impact assessment
-->

### 🔴 Advanced Object Patterns
**For experienced developers handling complex integrations**

#### Integration Patterns with External Systems

<!-- AI_TRIGGER: When advanced developer works on integrations -> Suggest error handling, performance testing, and monitoring patterns -->

**Learning Objective**: Create robust integrations with comprehensive error handling

```al
// Advanced integration pattern with comprehensive error handling
codeunit 50100 "BRC External Rating Sync"
{
    // Following integration patterns from IntegrationDeployment/integration-patterns.md
    
    procedure SyncCustomerRatings(CustomerNo: Code[20])
    var
        IntegrationLogEntry: Record "Integration Log Entry";
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        ResponseText: Text;
        RetryCount: Integer;
    begin
        // Comprehensive error handling with retry logic
        for RetryCount := 1 to 3 do begin
            ClearLastError();
            
            if TryCallExternalService(CustomerNo, HttpClient, HttpResponseMessage) then begin
                ProcessSuccessfulResponse(HttpResponseMessage, CustomerNo);
                LogSuccessfulSync(CustomerNo);
                exit;
            end else begin
                LogFailedAttempt(CustomerNo, GetLastErrorText(), RetryCount);
                
                if RetryCount < 3 then
                    Sleep(RetryCount * 1000) // Exponential backoff
                else
                    HandleFinalFailure(CustomerNo);
            end;
        end;
    end;
    
    [TryFunction]
    local procedure TryCallExternalService(CustomerNo: Code[20]; var HttpClient: HttpClient; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        RequestUri: Text;
        HttpContent: HttpContent;
    begin
        // Implementation with proper error boundaries
        RequestUri := StrSubstNo('https://api.rating-service.com/customers/%1/ratings', CustomerNo);
        
        SetupAuthentication(HttpClient);
        SetupHeaders(HttpContent);
        
        exit(HttpClient.Get(RequestUri, HttpResponseMessage));
    end;
    
    local procedure HandleFinalFailure(CustomerNo: Code[20])
    var
        NotificationMgt: Codeunit "Notification Management";
    begin
        // Graceful failure handling
        NotificationMgt.SendNotification(
            StrSubstNo('Failed to sync ratings for customer %1 after 3 attempts', CustomerNo),
            "Notification Entry Type"::Error);
            
        // Log for monitoring and alerting
        LogCriticalFailure(CustomerNo);
    end;
}
```

<!-- PROACTIVE_SUGGEST: When creating integration objects -> "Consider adding performance monitoring and alerting as outlined in PerformanceOptimization/optimization-guide.md" -->

### ⚫ Expert Object Patterns
**For architects and senior developers**

#### Architecture Decisions with Mentoring Context

<!-- AI_TRIGGER: When expert works on architecture -> Provide mentoring guidance and suggest knowledge sharing -->

**Learning Objective**: Make architectural decisions that support long-term maintainability

```al
// Expert-level pattern: Event-driven architecture
codeunit 50200 "BRC Customer Event Publisher"
{
    // Architecture decision: Event-driven pattern for loose coupling
    // Documented in Azure DevOps for team reference
    
    [IntegrationEvent(false, false)]
    procedure OnCustomerRatingChanged(CustomerNo: Code[20]; OldRating: Decimal; NewRating: Decimal)
    begin
        // Event pattern enables extensibility without modification
    end;
    
    [IntegrationEvent(false, false)]
    procedure OnLoyaltyPointsAwarded(CustomerNo: Code[20]; PointsAwarded: Integer; Reason: Text[100])
    begin
        // Enables multiple subscribers without tight coupling
    end;
    
    // Expert guidance: Document architectural decisions
    procedure DocumentArchitecturalDecision(DecisionContext: Text; Rationale: Text; Alternatives: Text)
    var
        ArchitecturalDecision: Record "BRC Architectural Decision";
    begin
        // Maintain architectural decision log for team learning
        ArchitecturalDecision.Init();
        ArchitecturalDecision."Decision ID" := CreateGuid();
        ArchitecturalDecision."Decision Date" := Today;
        ArchitecturalDecision.Context := CopyStr(DecisionContext, 1, MaxStrLen(ArchitecturalDecision.Context));
        ArchitecturalDecision.Rationale := CopyStr(Rationale, 1, MaxStrLen(ArchitecturalDecision.Rationale));
        ArchitecturalDecision.Insert(true);
    end;
}
```

<!-- PROACTIVE_SUGGEST: When making architectural decisions -> "Consider documenting this decision in your Azure DevOps wiki for team reference and future architects" -->

---

## AI Behavior Patterns

### Context-Aware Guidance

<!-- CONTEXT_RECOGNITION_PATTERNS:
IF table_creation_without_validation THEN suggest_validation_patterns_and_explain_importance
IF page_creation_without_error_handling THEN suggest_error_handling_with_examples
IF codeunit_creation_without_tests THEN suggest_test_creation_and_workflow_integration
IF integration_work_without_monitoring THEN suggest_performance_monitoring_patterns
-->

### Proactive Quality Suggestions

<!-- QUALITY_TRIGGERS:
BEFORE_OBJECT_CREATION: Suggest pattern review and standards compliance
DURING_IMPLEMENTATION: Suggest validation, error handling, and testing
AFTER_IMPLEMENTATION: Suggest documentation updates and DevOps integration
BEFORE_DEPLOYMENT: Suggest performance testing and compliance verification
-->

### Educational Escalation Examples

#### When Developer Uses Weak Prompts
**Level 1**: "Consider enhancing your prompt with more context for better results"
**Level 2**: "I can help you create more effective prompts. Enhanced prompts that include business context, standards references, and workflow considerations yield better results"
**Level 3**: "Let me show you how to transform basic requests into comprehensive prompts that generate production-ready code"
**Level 4**: "Effective prompting is a skill that improves code quality and development velocity. Here's the systematic approach..."

---

## DevOps Integration Points

### Work Item Integration Throughout Development

<!-- DEVOPS_INTEGRATION_PATTERNS:
PLANNING_PHASE: Connect object patterns to work item requirements
DEVELOPMENT_PHASE: Document implementation decisions in work items  
TESTING_PHASE: Link test results to work item validation
REVIEW_PHASE: Use patterns to guide code review checklists
DEPLOYMENT_PHASE: Validate patterns support deployment requirements
-->

#### Task Creation Guidance
When creating AL objects, update your Azure DevOps work item with:
- **Object Purpose**: Business requirement this object fulfills
- **Pattern Applied**: Which pattern from this guide was used
- **Integration Points**: How this object connects to existing system
- **Testing Plan**: Test scenarios and validation approach

#### Progress Tracking Integration  
Document in work items:
- **Implementation Decisions**: Why specific patterns were chosen
- **Quality Checkpoints**: Validation and testing completion
- **Performance Considerations**: Any optimization decisions
- **Deployment Requirements**: Prerequisites and validation needs

### Quality Gates Integration

<!-- QUALITY_GATE_PATTERNS:
DESIGN_GATE: Pattern compliance and architecture review
IMPLEMENTATION_GATE: Standards compliance and error handling validation
TESTING_GATE: Test coverage and validation completeness
DEPLOYMENT_GATE: Performance validation and compliance verification
-->

---

## Prompt Enhancement Framework

### Common Enhancement Patterns

#### Table Creation Prompts
```markdown
❌ WEAK: "Create a customer table"
✅ ENHANCED: "Create a Business Central customer extension table following naming conventions from SharedGuidelines/Standards/naming-conventions.md, with validation patterns from SharedGuidelines/Standards/error-handling.md, and corresponding test scenarios from TestingValidation/testing-strategy.md"

🎓 EDUCATION: Enhanced prompts specify object type (extension), reference standards (naming, validation), and include testing considerations. This approach ensures comprehensive, quality-assured development.
```

#### Page Development Prompts  
```markdown
❌ WEAK: "Make a page for this table"
✅ ENHANCED: "Create a Business Central card page for customer ratings with proper field grouping, navigation actions following UI patterns from CoreDevelopment/object-patterns.md, error handling from SharedGuidelines/Standards/error-handling.md, and accessibility compliance from IntegrationDeployment/accessibility-standards.md"

🎓 EDUCATION: Page prompts should specify page type, UI patterns, error handling, and accessibility. This ensures consistent, user-friendly interfaces that meet compliance requirements.
```

#### Integration Development Prompts
```markdown
❌ WEAK: "Connect to external API"  
✅ ENHANCED: "Create Business Central integration with external rating API following patterns from IntegrationDeployment/integration-patterns.md, implementing retry logic and error handling from SharedGuidelines/Standards/error-handling.md, with monitoring capabilities from PerformanceOptimization/optimization-guide.md, and comprehensive testing from TestingValidation/testing-strategy.md"

🎓 EDUCATION: Integration prompts require error handling, monitoring, and testing considerations. This approach creates robust, production-ready integrations.
```

---

## Validation and Testing Integration

### Proactive Testing Suggestions

<!-- PROACTIVE_SUGGEST: After object creation -> "Create corresponding test codeunit using TestingValidation/test-data-patterns.md for comprehensive validation" -->

#### Test Creation Guidance
For every object pattern, consider:
- **Unit Tests**: Validate business logic and validation rules
- **Integration Tests**: Verify interaction with related objects
- **Performance Tests**: Ensure optimization requirements are met
- **User Experience Tests**: Validate accessibility and usability

#### Test Data Patterns
Reference `TestingValidation/test-data-patterns.md` for:
- Consistent test data creation approaches
- Boundary condition testing scenarios  
- Error condition validation patterns
- Performance testing data volumes

---

## Performance Optimization Integration

### Proactive Performance Suggestions

<!-- PROACTIVE_SUGGEST: When creating data-intensive objects -> "Consider performance implications and review PerformanceOptimization/optimization-guide.md for relevant patterns" -->

#### Performance Patterns by Object Type
- **Tables**: Indexing strategies and FlowField optimization
- **Pages**: Lazy loading and data filtering patterns
- **Codeunits**: Efficient query patterns and caching strategies
- **Reports**: Data source optimization and rendering performance

---

## AppSource Compliance Integration

### Proactive Compliance Suggestions

<!-- PROACTIVE_SUGGEST: When working on AppSource extension -> "Review AppSourcePublishing/appsource-requirements.md for compliance requirements that apply to your object type" -->

#### Compliance Considerations by Pattern
- **Object Naming**: AppSource naming convention compliance
- **Data Classification**: Proper data classification for all fields
- **Error Handling**: User-friendly error messages and guidance
- **Accessibility**: UI compliance with accessibility standards

---

## Success Metrics and Continuous Improvement

### AI Guidance Effectiveness Indicators
- ✅ Copilot proactively suggests appropriate patterns during development
- ✅ Weak prompts are enhanced with educational context
- ✅ DevOps workflows are naturally integrated into guidance
- ✅ Developers demonstrate improved prompting skills over time
- ✅ Quality standards are encouraged without explicit requests

### Developer Learning Progression
- **Beginner → Intermediate**: Consistent use of validation patterns
- **Intermediate → Advanced**: Integration of business logic with error handling
- **Advanced → Expert**: Architectural decisions with team mentoring
- **Expert → Mentor**: Contributing to pattern evolution and team education

---

**This guide transforms object development from reactive coding into proactive, quality-focused development that builds expertise while maintaining standards and workflow integration.**
