# Shared Templates for BC Copilot Community

## IMPORTANT: Exclusions from Template Consolidation

### BC Specialists Folder - DO NOT CONSOLIDATE
The `bc-specialists/` folder contains intentionally duplicated structure:
- **Purpose**: Consistent AI character context setting
- **Pattern**: "Your Role in BC Development", "Quest Focus Areas", "Return Scenarios" 
- **Why Duplicate**: Each specialist needs identical structure for proper AI behavior
- **Action**: EXCLUDE from deduplication - this is functional architecture, not bloat

### Files to EXCLUDE from Template Consolidation
- `bc-specialists/*.instructions.md` - Character definition files (functional duplication)
- `override-plan.md` - Implementation planning document
- `duplication-analysis.md` - Analysis report
- `shared-templates.md` - This template file
- `tools/*.ps1` - Utility scripts

## Standard Copilot Guidance Template

**Target Files for Consolidation**: Core development guidance with repeated AI instruction patterns

### Template A: Development Context Guidance
```markdown
## How to Use This Guide with Copilot

<!-- AI_INSTRUCTION: When developers work on [CONTEXT], proactively suggest:
1. [CONTEXT_SPECIFIC_GUIDANCE] with clear examples and validation
2. Quality assurance patterns and automated checking
3. DevOps integration for [CONTEXT] monitoring and workflow automation
4. Testing strategies for [CONTEXT] scenarios and comprehensive validation
-->

### Prompt Enhancement for [CONTEXT]

<!-- PROMPT_EDUCATION: 
WEAK: "[BASIC_REQUEST]"
BETTER: "[ENHANCED_REQUEST] with [CONTEXT] best practices, automated quality validation, DevOps workflow integration, and comprehensive documentation for maintainable [CONTEXT] implementation"
EDUCATIONAL_NOTE: "Enhanced prompts specify comprehensive approach, include quality standards ([CONTEXT] best practices), add automation (validation, DevOps), consider documentation, and focus on maintainable outcomes. This ensures thorough [CONTEXT] implementation."
-->
```

### Template B: Standards and Quality Context
```markdown
## How to Use This Guide with Copilot

<!-- AI_INSTRUCTION: When developers work on [STANDARDS_CONTEXT], proactively suggest:
1. Consistent application of [STANDARDS_CONTEXT] patterns across the codebase
2. Validation and compliance checking for [STANDARDS_CONTEXT] requirements
3. Integration with code review and quality assurance processes
4. Documentation and team communication of [STANDARDS_CONTEXT] decisions
-->

### Prompt Enhancement for [STANDARDS_CONTEXT]

<!-- PROMPT_EDUCATION: 
WEAK: "[BASIC_STANDARDS_REQUEST]"
BETTER: "[ENHANCED_STANDARDS_REQUEST] following established [STANDARDS_CONTEXT] guidelines, with consistency validation, team alignment, and comprehensive documentation for long-term maintainability"
EDUCATIONAL_NOTE: "Enhanced prompts specify adherence to established guidelines, include consistency validation, consider team collaboration, add documentation requirements, and focus on maintainability. This ensures consistent [STANDARDS_CONTEXT] implementation."
-->
```

### Context Variable Definitions
- **Error Handling**: CONTEXT="error handling", BASIC_REQUEST="Add error handling", ENHANCED_REQUEST="Implement comprehensive ErrorInfo-based error handling"
- **Naming Conventions**: CONTEXT="naming", BASIC_REQUEST="Fix naming", ENHANCED_REQUEST="Apply consistent naming conventions"
- **Code Style**: STANDARDS_CONTEXT="code style", BASIC_STANDARDS_REQUEST="Fix code style", ENHANCED_STANDARDS_REQUEST="Apply code style standards"
- **Testing**: CONTEXT="testing", BASIC_REQUEST="Add tests", ENHANCED_REQUEST="Implement comprehensive testing strategy"
- **Performance**: CONTEXT="performance optimization", BASIC_REQUEST="Make it faster", ENHANCED_REQUEST="Optimize performance with measurement and validation"

```markdown
## How to Use This Guide with Copilot

<!-- AI_INSTRUCTION: When developers work on [CONTEXT_AREA], proactively suggest:
1. [CONTEXT_SPECIFIC_ACTION_1]
2. [CONTEXT_SPECIFIC_ACTION_2] 
3. DevOps integration for [CONTEXT_AREA] monitoring and automation
4. Testing strategies for [CONTEXT_AREA] scenarios and validation
-->

### Prompt Enhancement for [CONTEXT_AREA]

<!-- PROMPT_EDUCATION: 
WEAK: "[WEAK_EXAMPLE]"
BETTER: "[BETTER_EXAMPLE] with [CONTEXT_AREA] validation, automated quality checks, and documentation integration for comprehensive [CONTEXT_AREA] improvement"
EDUCATIONAL_NOTE: "Enhanced prompts specify comprehensive approach, include validation ([CONTEXT_AREA] standards), add automation (quality checks), consider documentation, and focus on outcomes. This ensures thorough [CONTEXT_AREA] guidance."
-->
```

## Standard TOC Template

```markdown
## Table of Contents

### Quick Navigation
- [Core Guidelines](#core-guidelines) - Essential [CONTEXT] patterns
- [Implementation Examples](#implementation-examples) - Practical code samples
- [Best Practices](#best-practices) - Production-ready approaches
- [Cross-References](#cross-references) - Related guidelines and workflows

### Detailed Content
- **[PRIMARY_CONTEXT]**: Core implementation guidance
- **[SECONDARY_CONTEXT]**: Advanced patterns and optimization
- **[TERTIARY_CONTEXT]**: Integration and quality considerations
```

## Standard Cross-References Template

```markdown
## Cross-References

### Related Guidelines
- **[RELATED_AREA_1]**: `path/to/related-file.md` - [Brief description]
- **[RELATED_AREA_2]**: `path/to/related-file.md` - [Brief description]
- **[RELATED_AREA_3]**: `path/to/related-file.md` - [Brief description]

### Workflow Applications
- **[WORKFLOW_1]**: [Context-specific application]
- **[WORKFLOW_2]**: [Context-specific application] 
- **[WORKFLOW_3]**: [Context-specific application]
```

## Usage Instructions

### Template Replacement Process
1. Identify duplicated sections in target file
2. Replace with appropriate template
3. Customize [CONTEXT_VARIABLES] for specific content
4. Remove original duplicated content
5. Verify links and references still work

### Context Variables by File Type
- **Error Handling**: CONTEXT_AREA="error handling", WEAK_EXAMPLE="Add error handling"
- **Naming**: CONTEXT_AREA="naming", WEAK_EXAMPLE="Fix naming"  
- **Testing**: CONTEXT_AREA="testing", WEAK_EXAMPLE="Add tests"
- **Performance**: CONTEXT_AREA="performance", WEAK_EXAMPLE="Make it faster"

### Standardization Benefits
- **Content Reduction**: 13 files × ~150 lines each = ~2,000 lines → ~50 lines shared template = 97% reduction
- **Maintenance**: Single source of truth for common patterns
- **Consistency**: Identical experience across all guidance files
- **Override Compatible**: Templates work with planned override system
