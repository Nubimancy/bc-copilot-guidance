---
applyTo: '**/*.al'
---

# Copilot Limitations and Best Practices - AI Self-Awareness Framework

<!-- AI_TRIGGER: When Copilot suggests AL code, proactively warn about common limitations and suggest validation -->
<!-- COPILOT_GUIDANCE: This guide teaches Copilot self-awareness about limitations and proactive validation strategies -->

## How to Use This Guide with Copilot

<!-- AI_INSTRUCTION: When providing AL development assistance, proactively:
1. Acknowledge potential limitations in suggestions
2. Recommend validation steps for generated code
3. Suggest DevOps integration for code verification
4. Provide alternative approaches when uncertain
-->

### Self-Awareness Prompting for Copilot

<!-- PROMPT_EDUCATION: 
WEAK: "Generate AL code"
BETTER: "Generate AL code with validation steps, acknowledging any limitations, and suggest verification against Business Central documentation and DevOps quality gates"
EDUCATIONAL_NOTE: "Enhanced prompts request validation steps (verification), include self-awareness (limitations), reference standards (BC documentation), and consider workflow integration (DevOps quality gates). This yields more reliable and verifiable results."
-->

## Common Pitfalls to Avoid

<!-- AI_TRIGGER: When suggesting AL code, proactively warn about these common pitfalls and suggest validation -->
<!-- PROACTIVE_SUGGEST: During code generation -> Suggest validation steps and documentation verification -->

### ❌ Hallucinated APIs and Syntax

**Problem:** Copilot may suggest non-existent AL procedures or outdated syntax
- Suggests fictional Business Central APIs that don't exist
- Recommends deprecated procedures or obsolete patterns
- Creates plausible-looking but incorrect method signatures

<!-- COPILOT_GUIDANCE: When discussing API validation, remind developers to:
1. Add API validation to DevOps testing pipeline
2. Update work items with API verification status
3. Document API validation in code review checklists
4. Consider automated API validation tools
-->

**Solution:**
- Always verify against official Business Central documentation
- Cross-reference with established patterns in CoreDevelopment/
- Test generated code in actual Business Central environment
- Use IntelliSense to validate suggested procedures

**Example Validation:**
```al
// ❌ Copilot might suggest (fictional):
Customer.CalculateRewardPoints(Amount, TierLevel);

// ✅ Verify actual API exists:
if Customer.FindFirst() then
    // Check if CalculateRewardPoints actually exists
```

### ❌ Inconsistent Naming

**Problem:** May not follow your specific naming conventions
- Uses generic naming patterns instead of organization standards
- Doesn't consider prefix requirements or object numbering
- Mixes different naming styles within the same codebase

**Solution:**
- Always reference SharedGuidelines/Standards/naming-conventions.md in prompts
- Include specific prefix requirements in context
- Provide examples of correct naming in your prompts

**Prompt Enhancement:**
```
❌ Generic: "Create a customer table"
✅ Specific: "Create a customer rewards table following our naming conventions in SharedGuidelines/Standards/naming-conventions.md, using prefix 'BRC' and object number range 50100-50199"
```

### ❌ Missing Error Handling

**Problem:** Generated code often lacks proper error handling
- Happy path implementations without exception handling
- Missing user-friendly error messages
- No validation of input parameters

**Solution:**
- Explicitly request error handling patterns from SharedGuidelines/Standards/error-handling.md
- Include error scenarios in your requirements
- Ask for validation logic to be included

**Enhanced Prompt:**
```
"Create a posting routine that includes proper error handling per SharedGuidelines/Standards/error-handling.md, with user-friendly messages for common failure scenarios"
```

### ❌ Outdated Patterns

**Problem:** May suggest deprecated AL patterns or procedures
- Uses obsolete object types or properties
- Suggests patterns that don't work in current BC versions
- Recommends discontinued development approaches

**Solution:**
- Cross-reference with current Business Central version documentation
- Specify target BC version in prompts
- Validate against Microsoft's latest development guidelines

**Version-Specific Prompting:**
```
"Create a Business Central extension for version 23.0 using current AL patterns, avoiding any deprecated approaches"
```

## Trust vs. Verify Guidelines

### ✅ Generally Trust

**Basic AL Syntax and Structure:**
- Standard AL language constructs (if/then, case statements, loops)
- Common variable declarations and data types
- Basic object property syntax

**Common Business Central Object Patterns:**
- Table and field structure basics
- Page layout fundamentals
- Standard event patterns

**Standard Development Practices:**
- Code organization and structure
- Comment patterns and documentation
- Basic procedure organization

### ⚠️ Always Verify

**API Calls and Procedure Signatures:**
- Method names and parameter lists
- Return types and expected values
- Object method availability

**Business Central Version-Specific Features:**
- New AL language features
- Platform-specific implementations
- Version compatibility requirements

**Custom Extension Integration Patterns:**
- Integration with existing customizations
- Extension dependency requirements
- Upgrade compatibility considerations

**Performance Implications:**
- Database query efficiency
- Memory usage patterns
- Processing optimization suggestions

### 🔍 Always Validate

**Object Naming Against Your Conventions:**
- Prefix usage and consistency
- Object numbering compliance
- Naming pattern adherence

**Error Handling Implementation:**
- Comprehensive exception coverage
- User-friendly error messages
- Proper error propagation

**Test Coverage Completeness:**
- All code paths tested
- Edge cases covered
- Integration scenarios validated

**Integration with Existing Codebase:**
- Compatibility with current implementations
- No breaking changes introduced
- Proper dependency management

## Validation Steps

### Code Review Checklist

**1. Standards Compliance:**
```
□ Object naming follows SharedGuidelines/Standards/naming-conventions.md
□ Code style matches SharedGuidelines/Standards/code-style.md
□ Proper indentation and formatting applied
□ Comment standards followed consistently
```

**2. Pattern Consistency:**
```
□ Object patterns match CoreDevelopment/object-patterns.md
□ Business logic follows established approaches
□ Integration patterns are consistent
□ Database design follows normalization principles
```

**3. Error Handling:**
```
□ All potential error conditions identified
□ User-friendly error messages implemented
□ Proper exception propagation in place
□ Error logging appropriately configured
```

**4. Test Coverage:**
```
□ Unit tests for all business logic
□ Integration tests for external dependencies
□ Edge cases and boundary conditions tested
□ Performance tests for critical operations
```

**5. Performance:**
```
□ Database queries optimized
□ Memory usage considerations addressed
□ Processing efficiency evaluated
□ Scaling implications considered
```

### Testing Validation

**Automated Validation Prompt:**
```
"Review this Copilot-generated code against our quality standards:
1. Check naming conventions against SharedGuidelines/Standards/naming-conventions.md
2. Verify error handling patterns per SharedGuidelines/Standards/error-handling.md
3. Ensure proper test coverage following TestingValidation/testing-strategy.md
4. Validate performance considerations per PerformanceOptimization/optimization-guide.md"
```

**Manual Testing Requirements:**
- Test in actual Business Central environment
- Verify with multiple data scenarios
- Validate error conditions trigger correctly
- Confirm performance meets expectations

### Integration Testing

**Business Central Environment:**
- Deploy to development environment
- Test with realistic data volumes
- Verify integration with existing functionality
- Validate user experience flows

**Extension Validation Tools:**
- Run AL Language extension validation
- Execute Business Central compiler checks
- Perform static code analysis
- Validate against AppSource requirements (if applicable)

**Performance Testing:**
- Measure execution times under load
- Monitor memory usage patterns
- Test with large datasets
- Validate concurrent user scenarios

## Best Practices for Effective Collaboration

### Iterative Refinement

**Start with Basic Implementation:**
1. Request core functionality first
2. Add complexity incrementally
3. Validate each iteration before proceeding
4. Build on verified foundations

**Progressive Enhancement:**
```
Phase 1: "Create basic customer rewards table structure"
Phase 2: "Add validation logic following our error handling patterns"
Phase 3: "Include integration with posting routines"
Phase 4: "Add performance optimizations for large datasets"
```

### Context Management

**Keep Implementation Plans Updated:**
- Update .aidocs plans as implementation evolves
- Document decisions and rationale
- Maintain links between work items and implementation
- Share context across development sessions

**Reference Specific Documents:**
- Always include relevant guideline file references
- Provide business context from work items
- Link to related implementation plans
- Include stakeholder feedback and decisions

**Maintain Clear Project Context:**
- Specify Business Central version and environment
- Include customer or project-specific requirements
- Reference existing customizations and dependencies
- Provide performance and scalability requirements

### Quality Gates

**Manual Review of All Generated Code:**
- Never commit generated code without review
- Validate against multiple quality criteria
- Test in development environment first
- Peer review for complex implementations

**Validation Against Established Patterns:**
- Compare with existing similar implementations
- Ensure consistency with architectural decisions
- Validate integration patterns and approaches
- Confirm alignment with business requirements

**Testing Before Integration:**
- Unit test all generated business logic
- Integration test external dependencies
- Performance test critical operations
- User acceptance test for UI components

### Documentation Updates

**Update .aidocs with Lessons Learned:**
- Document what prompts work well
- Record common validation issues discovered
- Share effective quality validation approaches
- Update templates based on experience

**Share Effective Prompts with Team:**
- Maintain library of successful prompts
- Document context patterns that work well
- Share validation approaches that catch issues
- Collaborate on prompt improvement strategies

**Document Successful Integration Patterns:**
- Record effective workflow integrations
- Document DevOps automation successes
- Share quality gate implementations
- Maintain best practice documentation

## Team Training and Adoption

### Onboarding New Team Members

**Essential Training Topics:**
1. Understanding Copilot capabilities and limitations
2. Effective prompting strategies for AL development
3. Quality validation processes and tools
4. Integration with existing development workflows

**Hands-On Practice:**
1. Guided practice with simple AL objects
2. Progressive complexity with supervision
3. Code review exercises focusing on validation
4. Integration testing practice scenarios

### Continuous Improvement

**Regular Review Sessions:**
- Monthly review of Copilot effectiveness
- Discussion of new patterns and approaches
- Sharing of successful prompts and workflows
- Identification of common issues and solutions

**Process Refinement:**
- Update guidelines based on experience
- Enhance validation checklists with new learnings
- Improve integration workflows based on feedback
- Maintain currency with Copilot capability updates

## Common Failure Patterns and Solutions

### Pattern: Over-Reliance on Generated Code

**Symptoms:**
- Accepting suggestions without understanding
- Skipping validation and testing steps
- Not considering integration implications

**Solutions:**
- Mandatory code review processes
- Required testing before integration
- Understanding-based acceptance criteria

### Pattern: Inconsistent Quality Standards

**Symptoms:**
- Variable code quality across features
- Different naming conventions in use
- Inconsistent error handling approaches

**Solutions:**
- Standardized prompt templates
- Automated quality validation tools
- Consistent reference to guideline documents

### Pattern: Insufficient Context in Prompts

**Symptoms:**
- Generic code that doesn't fit requirements
- Missing business logic considerations
- Poor integration with existing systems

**Solutions:**
- Detailed prompt construction guidelines
- Required reference to implementation plans
- Business context inclusion requirements

## AI Self-Awareness Best Practices Summary

<!-- EDUCATIONAL_ESCALATION:
LEVEL_1: Acknowledge limitation and suggest simple validation
LEVEL_2: Provide detailed validation guidance with specific steps
LEVEL_3: Explain limitation context and comprehensive verification approach
LEVEL_4: Discuss enterprise-level validation strategies and automation
-->

### Copilot Self-Awareness Checklist

<!-- AI_TRIGGER: When providing AL assistance, use this self-awareness checklist -->
<!-- PROACTIVE_SUGGEST: During code generation -> Suggest validation and limitation awareness -->

- [ ] **API Verification**: Acknowledge when API existence should be verified
- [ ] **Documentation Reference**: Suggest checking official Business Central documentation
- [ ] **Pattern Validation**: Recommend validating against established patterns
- [ ] **Testing Requirements**: Suggest appropriate testing for generated code
- [ ] **DevOps Integration**: Recommend work item updates and pipeline validation
- [ ] **Quality Gates**: Suggest code review and quality validation steps
- [ ] **Context Limitations**: Acknowledge when more context might be needed
- [ ] **Alternative Approaches**: Provide multiple options when uncertainty exists

### Context-Aware Limitation Guidance

<!-- CONTEXT_RECOGNITION_PATTERNS:
IF generating_al_code AND uncertain_about_api:
  SUGGEST: "Please verify this API exists in Business Central documentation"
  EDUCATE: "AI-generated APIs should always be validated against official documentation"

IF providing_complex_solution AND missing_context:
  SUGGEST: "Consider providing more business context for better accuracy"
  EDUCATE: "Detailed context helps AI provide more accurate and relevant solutions"

IF suggesting_patterns AND uncertain_about_current_standards:
  SUGGEST: "Validate this pattern against your current coding standards"
  EDUCATE: "Standards evolve, so validation against current guidelines ensures consistency"
-->

This guide enables Copilot to maintain self-awareness about limitations while providing intelligent guidance for AL development, ensuring quality, accuracy, and proper validation throughout the development process.
