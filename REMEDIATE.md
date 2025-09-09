# BC Copilot Community Drift Remediation Task

## Objective
Fix drifted atomic topic files that contain AL code but should be conceptual guidance only, following VALIDATION-CHECKLIST.md standards.

## Step-by-Step Process

### Phase 1: Assessment and Planning **COMPLETED**
1. **Generate File List**: Create comprehensive list of all `/areas/**/*.md` files (excluding `*-samples.md`)
2. **Create REMEDIATION.md**: Generate checklist file with all non-sample topic files for progress tracking
3. **Identify Drifted Files**: Use `find-drifted-topics.ps1` to identify files needing conversion
4. **Prioritize by Recency**: Start with most recent files (today's date), then work backwards

### Phase 2: Systematic Remediation
For each file in REMEDIATION.md:
1. **Read Current File**: Analyze existing content and structure
2. **Apply VALIDATION-CHECKLIST**: Check against all validation criteria
3. **Convert AL Code to Concepts**: Replace AL implementations with strategic frameworks
4. **Fix Frontmatter**: Ensure proper object_types/variable_types based on concepts 
5. **Ensure Atomic Focus**: Target 50-100 lines, single indivisible concept
6. **Split if Oversized**: If >150 lines, consider splitting into multiple atomic topics
7. **Update Checklist**: Mark file as completed in REMEDIATION.md

### Phase 3: Quality Assurance
1. **Run Validation Scripts**: Execute all validation tools after every 10 files
2. **Reference Good Examples**: Use atomic examples as models
3. **Check Progress**: Update REMEDIATION.md progress counters regularly

## Key Reference Files
- **VALIDATION-CHECKLIST.md**: Complete quality standards and requirements
- **CONTRIBUTING.md**: Original atomic topic rules
- **find-drifted-topics.ps1**: Identifies files needing remediation

## Good Examples to Follow
- **`areas/code-creation/table-design-patterns.md`** (71 lines) - Perfect atomic concept with relevant AL types
- **`areas/requirements-gathering/business-rule-discovery-techniques.md`** - Note: This may be too long and need splitting

## Atomic Topic Conversion Rules

### ❌ Remove from Main Topics
- All `````al` code blocks
- Step-by-step implementation instructions
- Detailed code explanations
- Specific AL syntax examples

### ✅ Keep in Main Topics
- Strategic frameworks and methodologies
- Design principles and architectural guidance
- WHAT to build and WHY decisions matter
- Best practices and anti-patterns
- Implementation checklists (high-level steps only)

### ✅ Frontmatter Rules
- **object_types**: List AL objects the concepts apply to (NOT empty arrays unless purely conceptual)
- **variable_types**: List complex AL types involved in implementing the concepts
- **area**: Must match valid functional areas from VALIDATION-CHECKLIST
- **difficulty**: Appropriate level assessment

### ✅ Structure Requirements
- **50-100 lines target** (like the excellent 71-line table-design-patterns.md)
- **Single concept focus** that cannot be subdivided further
- **Agent-optimized**: Concise, scannable, essential information only
- **Required sections**: Overview, Strategic Framework, Implementation Checklist, Best Practices, Anti-Patterns

## REMEDIATION.md Progress Template

Create this file to track progress:

```markdown
# Remediation Progress Tracker

**Total Files**: [COUNT]
**Drifted Files**: [COUNT]
**Completed**: 0
**Remaining**: [COUNT]

## File Checklist

### Recently Created (Priority 1)
- [ ] areas/telemetry/error-telemetry-best-practices.md
- [ ] areas/background-tasks/long-running-operation-tracking.md
- [ ] areas/testing/automated-test-generation.md
- [ ] [... continue with all recent files]

### Historical Files (Priority 2)
- [ ] areas/ai-assistance/ai-guidance-enhancement-patterns.md
- [ ] areas/appsource-compliance/appsource-object-code-standards.md
- [ ] [... continue with all historical drifted files]

## Progress Summary
- **Latest Completed**: [file name]
- **Current Working**: [file name]
- **Validation Status**: [scripts run date/results]
```

## Validation Commands
Run these regularly during remediation:

```powershell
# Check for remaining drifted files
powershell -ExecutionPolicy Bypass -File "find-drifted-topics.ps1"

# Validate frontmatter (must be 100% success)
.\tools\Validate-FrontMatter.ps1

# Validate type indexes (must be 0 errors)
.\tools\Validate-TypeIndexes.ps1
```

## Success Criteria
- ✅ All drifted files converted to atomic conceptual guidance format
- ✅ Zero AL code blocks in main topic files
- ✅ All files 50-100 lines following atomic principles
- ✅ Proper frontmatter with appropriate object_types/variable_types
- ✅ All validation scripts show 0 errors
- ✅ REMEDIATION.md shows 100% completion

## Work Pattern
1. **Start with REMEDIATION.md creation**
2. **Work systematically through the list** (don't jump around)
3. **Update progress after each file**
4. **Run validation scripts every 10 files**
5. **Focus on atomic concepts** - eliminate bloat and complexity

## Remember
- **Atomic = indivisible single concept**
- **Conceptual guidance only** - no AL implementation code
- **AI agent optimized** - concise and scannable
- **Quality over quantity** - better to split large topics than keep them bloated

Start with creating REMEDIATION.md, then work systematically through each file!