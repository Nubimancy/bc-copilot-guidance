---
applyTo: '**/*.al'
---

# DevOps Integration with Copilot

**📋 PURPOSE**: Copilot prompting strategies for DevOps workflows, enhanced AI-assisted development patterns
**🎯 FOR**: Learning effective Copilot prompts, AI-enhanced development techniques, prompt education
**⚙️ OPERATIONAL WORKFLOWS**: See [DevOpsWorkflow/](../DevOpsWorkflow/) for operational DevOps processes, MCP commands, and workflow implementation

**Note**: When posting to ADO via MCP, in comments or any other field that has a format parameter, do not forget to specify the format as `markdown` to ensure proper rendering of the content.

## Azure DevOps Workflow Enhancement

### 4-Step Enhanced Development Workflow

#### Step 1: Work Item Assignment
**Traditional Approach:** Developer reads work item and starts coding
**Enhanced with Copilot:** Developer uses Copilot to interpret and analyze requirements

**Effective Prompts:**
```
"Help me understand the scope of ADO work item #123 and identify what questions I should ask stakeholders"

"Analyze this work item description and break down the technical requirements into development tasks"

"What information might be missing from this work item for complete implementation?"
```

#### Step 2: Context Gathering via MCP
**Traditional Approach:** Manual research through ADO interface
**Enhanced with Copilot:** Systematic information gathering using MCP queries

**Project Detection Workflow:**
```
"First determine the correct Azure DevOps project: if this workspace name starts with 'BRC_', use 'Apps' project, otherwise use 'Customers'. If the work item isn't found in the expected project, check the other project as a fallback."

"Query the ADO MCP to get comprehensive details for work item #123, including parent/child relationships and full hierarchy context. Use the detected project and gather all related work items for complete context."

"Get the parent work item context if this is a child item, and gather all sibling work items to understand the complete feature scope."
```

**📖 Note**: For specific MCP commands and operational workflows, see [DevOpsWorkflow/workflow-integration.md](../DevOpsWorkflow/workflow-integration.md)

**Workflow Integration:**
```
"Use MCP to gather complete work item context including parent/child hierarchy, then help me analyze the requirements and identify any missing information using the Information Gathering Strategy from .copilot/templates/instructions/copilot-instructions.md"

"Use MCP to find related work items and parent/child relationships to help me understand the broader context of this feature request and how it fits within the epic"

"Help me build a complete picture of this bug by querying the work item hierarchy, related work items, and comments via MCP to understand root cause and impact scope"
```

#### Step 3: Implementation Planning
**Traditional Approach:** Mental planning or informal notes
**Enhanced with Copilot:** Structured planning using .aidocs templates

**📖 Note**: For detailed implementation planning workflows, see [DevOpsWorkflow/workflow-integration.md](../DevOpsWorkflow/workflow-integration.md)

**Template Selection:**
```
"Based on this work item, should I use the feature or bugfix implementation template?"

"Help me determine which .aidocs template is most appropriate for this type of work"
```

**Plan Creation:**
```
"Help me fill out the implementation plan template using the ADO work item details and MCP queries"

"Create a comprehensive implementation plan by combining the work item requirements with our established patterns"
```

**Gap Analysis:**
```
"Review this partial implementation plan and suggest what information is missing"

"Identify areas where we need more stakeholder input before proceeding with development"
```

#### Step 4: Development with Context
**Traditional Approach:** Code from memory or search for examples
**Enhanced with Copilot:** Context-aware development using implementation plans

**Context-Rich Development:**
```
"Using the implementation plan in .aidocs/implementation-plans/feature-xyz.md as context, help me implement the Customer table with the fields and relationships specified in the Technical Analysis section"

"Based on the bug fix plan, generate the corrected posting routine that addresses the root cause identified"
```

## Copilot-Assisted DevOps Tasks

### Release Notes Generation

**Basic Release Notes:**
```
"Based on the completed implementation plans in .aidocs/implementation-plans/, generate release notes for version 1.2.0 highlighting the customer-facing improvements"
```

**Detailed Release Notes with Context:**
```
"Create comprehensive release notes that include:
- Customer-facing feature improvements from completed implementation plans
- Bug fixes with impact descriptions
- Technical changes that affect integrations
- Upgrade considerations for existing installations"
```

### Commit Message Creation

**Standard Commit Messages:**
```
"Generate a commit message for this feature implementation following our git conventions, referencing ADO work item #123 and the implementation plan"
```

**Conventional Commits with Context:**
```
"Create a conventional commit message that:
- References the specific ADO work item
- Summarizes the implementation approach
- Mentions any breaking changes
- Includes co-author information if pair programming"
```

### Pipeline YAML Assistance

**Basic Pipeline Creation:**
```
"Help me create an Azure DevOps pipeline YAML for building this Business Central extension, following our standard build patterns and including code analysis steps"
```

**Advanced Pipeline Configuration:**
```
"Generate a complete Azure DevOps pipeline that includes:
- Multi-stage build with Business Central compilation
- Automated testing with our test framework
- Code quality gates using our standards
- Deployment to multiple environments
- Integration with our existing variable groups"
```

### Pull Request Assistance

**PR Description Generation:**
```
"Generate a pull request description that includes:
- Summary of changes based on the implementation plan
- Testing instructions for reviewers
- Links to relevant work items and documentation
- Checklist for reviewers based on our quality standards"
```

**Review Request Templates:**
```
"Create a review request that highlights:
- Key areas requiring careful review
- Potential impact on existing functionality
- Specific validation steps needed
- Integration testing recommendations"
```

## Information Request Templates

### ADO Comment Generation

**Missing Requirements:**
```
"Generate an ADO comment requesting missing technical specifications for work item #123, using the template format from .copilot/templates/instructions/copilot-instructions.md".
```

**Example Generated Comment:**
```
@[Stakeholder] - Additional information needed for implementation planning:

**Business Requirements:**
- What should happen when a customer reaches the maximum reward points?
- How should expired points be handled in the calculation?

**Technical Specifications:**
- Should this integrate with existing customer posting routines?
- Are there performance requirements for large customer datasets?

**Acceptance Criteria:**
- What validation should occur during point redemption?
- How should errors be communicated to users?

Please provide these details so we can create a complete implementation plan.
```

### Email Template Creation

**Stakeholder Communication:**
```
"Create a professional email template to request additional business requirements for the customer rewards feature, including specific questions about point calculation rules"
```

**Example Generated Email:**
```
Subject: Implementation Planning - Additional Requirements for Customer Rewards Feature

Hi [Stakeholder],

I'm working on implementing the Customer Rewards feature (Work Item #123) and need some additional information to create a complete implementation plan.

The current requirements specify a basic point accumulation system, but I need clarification on several business rules to ensure we deliver exactly what's needed.

**Business Logic Questions:**
• How should points be calculated for different transaction types?
• What happens when customers return items that earned points?
• Should there be different point rates for different customer tiers?

**Integration Requirements:**
• How should this integrate with existing customer statements?
• Are there reporting requirements for reward point analytics?
• Should points affect credit limit calculations?

**User Experience:**
• How should customers view their point balance?
• What notifications should be sent when points are earned or expire?
• How should staff access customer reward information?

Having these details will help ensure we deliver a solution that meets all business needs. Please let me know if you'd like to discuss any of these points in detail.

Thanks,
[Developer Name]
```

## Automated Documentation

### Technical Documentation Generation

**API Documentation:**
```
"Generate technical documentation for the Customer Rewards API based on the implementation plan and actual code implementation"
```

**Integration Guides:**
```
"Create an integration guide for external systems that need to interact with our customer rewards functionality"
```

### User Documentation Assistance

**Feature Documentation:**
```
"Generate user documentation for the customer rewards feature that explains:
- How to access reward information
- Step-by-step process for redeeming points
- Common troubleshooting scenarios
- Administrator configuration options"
```

## DevOps Automation Scripts

### Build Script Enhancement

**Pipeline Optimization:**
```
"Help me optimize our build pipeline by:
- Identifying steps that can run in parallel
- Adding caching for frequently used dependencies
- Including automated security scanning
- Optimizing artifact publishing"
```

### Deployment Automation

**Environment-Specific Deployment:**
```
"Generate deployment scripts that handle:
- Environment-specific configuration
- Database migration coordination
- Extension upgrade procedures
- Rollback strategies for failed deployments"
```

## Quality Gate Integration

### Automated Code Review

**Pre-commit Validation:**
```
"Create a pre-commit hook script that validates:
- Code follows our naming conventions
- Error handling patterns are implemented
- Test coverage meets our standards
- Documentation is updated appropriately"
```

### Continuous Integration Enhancement

**Quality Metrics:**
```
"Help me set up quality gates that measure:
- Code coverage percentages
- Performance regression detection
- Security vulnerability scanning
- Compliance with AL best practices"
```

## Integration Best Practices

### Workflow Automation

1. **Use Copilot for routine DevOps tasks** to maintain consistency
2. **Generate templates and scripts** that can be reused across projects
3. **Automate documentation updates** to keep information current
4. **Create standardized processes** that team members can follow

### Context Management

1. **Maintain implementation plans** as single source of truth
2. **Reference work items consistently** in all generated content
3. **Update documentation** as implementations evolve
4. **Share effective prompts** across the development team

### Quality Assurance

1. **Review all generated content** before using in production
2. **Validate scripts and automation** in development environments
3. **Test documentation accuracy** with actual use cases
4. **Maintain version control** for all generated artifacts
