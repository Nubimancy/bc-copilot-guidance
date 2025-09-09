# Validation Checklist for BC Copilot Community

**PURPOSE**: Ensure all atomic topics and samples follow CONTRIBUTING.md guidelines consistently across all agent contexts.

## 📋 Pre-Creation Validation

### Topic Planning
- [ ] **Single Focus**: Topic addresses ONE specific concept clearly
- [ ] **Appropriate Area**: Fits into valid functional area (see CONTRIBUTING.md) and is in the folder for that area
- [ ] **Difficulty Assessment**: Beginner/Intermediate/Advanced appropriately assigned
- [ ] **Samples Need Assessment**: Determine if samples file is needed based on:
  - Topic involves specific AL object usage patterns (Codeunit procedures, Table fields, Page controls, etc.)
  - Implementation requires BC platform API calls (Telemetry, Session, Database, etc.)
  - Pattern includes BC-specific syntax or conventions (Event IDs, Custom Dimensions, DataClassification, etc.)
  - Developers would benefit from seeing working AL code examples alongside conceptual guidance
  - **Rule**: If main topic mentions specific AL objects, procedures, or BC APIs, samples file is typically needed
- [ ] 🚨**Critical BC Relevance**: Must be Business Central relevant, either in the Product coding/design/usage, or to business processes around Business Central practices

### Content Type Decision
- [ ] **Main Topic**: Conceptual guidance, principles, methodologies (NO AL code)
- [ ] **Samples File**: Working AL implementations (WITH AL code blocks)
- [ ] **Both Needed**: Complex topics requiring both strategic guidance and implementation examples

## 🎯 Main Topic File Validation

### Frontmatter Requirements
```yaml
title: "Descriptive Topic Title"
description: "Clear description of concept coverage"
area: "valid-functional-area"
difficulty: "beginner|intermediate|advanced"
object_types: ["Table", "Page"] # AL objects this concept applies to (pull from -samples)
variable_types: ["Record", "JsonObject"] # Complex AL types involved  (pull from -samples)
tags: ["relevant", "searchable", "keywords"]
```

### Content Requirements
- [ ] **NO AL Code Blocks**: Zero `````al` blocks in main topic files
- [ ] **Conceptual Focus**: Strategic thinking, principles, patterns, methodologies
- [ ] **Implementation Guidance**: WHAT to build and WHY, not HOW to code it
- [ ] **Architecture Focus**: Design decisions, trade-offs, best practices
- [ ] **AI Agent Friendly**: Helps agents understand concepts to generate better code

### Structure Requirements
- [ ] **Overview Section**: Clear concept introduction (~100-200 words)
- [ ] **Strategic Framework**: 2-4 main conceptual sections with detailed guidance
- [ ] **Implementation Checklist**: High-level implementation steps (bulleted list)
- [ ] **Best Practices**: 5-8 specific dos and recommended approaches
- [ ] **Anti-Patterns**: 5-8 specific don'ts and approaches to avoid

### Length and Depth Guidelines
- [ ] **Atomic Focus**: Target 50-100 lines per topic (like table-design-patterns.md at 71 lines)
- [ ] **Single Concept Rule**: Each topic covers exactly ONE focused concept that cannot be subdivided
- [ ] **Agent-Optimized**: Concise, scannable, essential information only
- [ ] **Quality over Quantity**: Better to have 3 focused 75-line topics than 1 sprawling 225-line topic
- [ ] **Break Down Large Topics**: If a topic exceeds ~150 lines, consider splitting into multiple atomic topics
- [ ] **Essential Only**: No fluff, redundancy, or tangential information

## 💻 Samples File Validation

### Naming Convention
- [ ] **Naming Pattern**: `{main-topic-name}-samples.md`
- [ ] **Frontmatter Match**: Same object_types/variable_types as main topic

### Content Requirements
- [ ] **Complete AL Code**: Working, compilable AL examples
- [ ] **Multiple Patterns**: Show different implementation approaches (2-4 examples minimum)
- [ ] **Real-World Examples**: Practical, business-relevant scenarios
- [ ] **Comments**: Explain complex logic and business rules
- [ ] **Best Practices**: Code demonstrates recommended patterns

### Structure and Length Guidelines
- [ ] **Pattern Organization**: Each implementation pattern in its own section
- [ ] **Code Completeness**: Full object definitions, not just snippets
- [ ] **Example Progression**: Start simple, build to complex scenarios
- [ ] **Total Length**: 200-600 lines depending on pattern complexity
- [ ] **Comment Density**: 20-30% comments explaining business logic and patterns

## 🔍 Quality Validation

### Reference Examples
**Good Main Topic**: `areas/code-creation/table-design-patterns.md`
- Conceptual guidance only
- No AL code blocks
- Proper frontmatter with relevant AL types
- Strategic thinking focus

**Good Samples**: `areas/code-creation/table-design-patterns-samples.md`
- Complete working AL code
- Multiple implementation examples
- Practical business scenarios

**Good Conceptual-Only**: `areas/requirements-gathering/business-rule-discovery-techniques.md`
- Pure methodology/framework
- Empty object_types/variable_types arrays (legitimately)
- No AL-specific content

### Frontmatter Validation Rules
- [ ] **object_types**: List AL objects the concepts apply to, or [] if purely conceptual
- [ ] **variable_types**: List complex AL types involved, or [] if none
- [ ] **Tags**: 3-5 relevant, searchable keywords
- [ ] **Area**: Must match valid functional area (see Valid Areas below)

### Valid Functional Areas
```
ai-assistance, analytics, appsource-compliance, architecture-design, background-tasks, 
code-creation, code-formatting, code-review, data-management, documentation, 
error-handling, installation-upgrade, integration, logging-diagnostics, namespaces, 
naming-conventions, performance-optimization, performance, project-workflow, 
requirements-gathering, security, telemetry, testing, ui-ux, user-experience, 
workflow, workflows
```

## 🚨 Common Drift Patterns to Avoid

### Main Topic Anti-Patterns
- ❌ **AL Code in Main Topics**: Any `````al` blocks in conceptual files
- ❌ **Implementation Details**: Step-by-step coding instructions
- ❌ **Empty Arrays Wrong**: Using [] when AL types ARE involved
- ❌ **Wrong Arrays**: Listing irrelevant AL types in frontmatter

### Samples Anti-Patterns  
- ❌ **Conceptual Content**: Strategic guidance in samples files
- ❌ **Incomplete Code**: Code snippets that won't compile
- ❌ **Single Example**: Only showing one implementation approach

## 🛠️ Validation Tools

### Automated Validation
**MANDATORY: All scripts must show 0 errors before any PR can be accepted**

```powershell
# Run frontmatter validation (must be 100% success)
.\tools\Validate-FrontMatter.ps1

# Run type index validation (must be 0 errors) 
.\tools\Validate-TypeIndexes.ps1

# Find drifted topics (AL code in main topics)
powershell -ExecutionPolicy Bypass -File "find-drifted-topics.ps1"
```

**Index Updates Required:**
- [ ] **JSON Indexes**: Type indexes automatically updated by validation scripts
- [ ] **Discovery System**: Object-types-index.json and variable-types-index.json must reflect changes

### Manual Validation Questions
1. **Can an AI agent understand the CONCEPT from the main topic?**
2. **Can a developer IMPLEMENT the concept from the samples?**
3. **Does the frontmatter accurately reflect AL involvement?**
4. **Would this help a developer be "phenomenally successful"?**

## 📝 Editor Context Instructions

When working on atomic topics:

### For Maven (Writing)
- Focus on **strategic thinking** and **conceptual frameworks**
- Avoid AL implementation details in main topics
- Create samples files for complex implementation patterns

### For Echo (Reviewing)
- Validate against this checklist before marking complete
- Check for AL code drift in main topics
- Ensure frontmatter accuracy

### For Any Agent
- **Always reference this checklist** before topic creation/editing
- **Use validation tools** to verify compliance
- **Check reference examples** when unsure about format

---

**Remember**: Main topics teach CONCEPTS, samples show IMPLEMENTATION. Keep them separate but coordinated!