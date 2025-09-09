# Specialist Instruction Rewrite Guidelines

**Purpose**: Document the systematic conversion approach for updating all BC specialists to use the new GitHub Copilot-compatible methodology.

## Context & Problem

**Original Problem**: Specialists tried to maintain knowledge of 60+ topics each, leading to:
- Context overload for GitHub Copilot's agentic mode
- Shallow expertise across too many areas
- Maintenance nightmare when topics change
- Generic advice instead of deep, specific guidance

**Solution**: Two-pass systematic evaluation with area-folder scanning and conditional samples usage.

## New Specialist Architecture

### **Core Principles:**
1. **Systematic Planning**: Build complete topic index → Create prioritized evaluation plan → Get user approval
2. **Area-Folder Scanning**: Point specialists at relevant area folders, not individual topics
3. **Conditional Samples**: Load main topics first, samples only when AL examples are needed
4. **User Collaboration**: Present evaluation plan and get approval before execution
5. **Self-Maintaining**: New topics automatically available via folder scanning

### **Two-Pass Process:**

**PASS 1: EVALUATION PLANNING** 📋
1. Analyze user's specific request
2. Identify which area folders are relevant (2-3 areas)
3. Scan .md files in those relevant area folders
4. Build complete working index of ALL discovered topics
5. Create systematic evaluation plan by rating each topic's relevance (High/Medium/Low)
6. Present plan to user and get approval before execution

**PASS 2: SYSTEMATIC EXECUTION** 🔍
1. Work through approved evaluation plan step-by-step
2. Load one topic at a time for focused analysis
3. Conditionally load samples files if concrete AL examples are needed
4. Document specific findings for each topic
5. Build comprehensive assessment progressively

## Conversion Template

### **Specialist Area Assignment Pattern:**
```markdown
**Your Topic Areas (Scan These Folders):**
- `areas/[area1]/` - [description of focus area]
- `areas/[area2]/` - [description of focus area] 
- `areas/[area3]/` - [description of focus area]

**Planning Process:**
1. Analyze the user's specific request
2. Identify which area folders are relevant (typically 2-3 areas)
3. Scan the .md topic files in those relevant area folders
4. Build complete working index of ALL discovered topics
5. Create systematic evaluation plan by rating each topic's relevance and priority
6. Present plan to user and get approval before execution
```

### **Document Pairing Structure:**
```markdown
**Document Pairing Structure:**
Each topic has a paired structure for complete guidance:
- **`topic.md`** - Conceptual guidance (WHAT to do, WHY to do it, principles and frameworks)
- **`topic-samples.md`** - Implementation examples (HOW to do it, working AL code, practical patterns)

**Using Paired Documents:**
- **Primary**: Load the main topic for understanding concepts and evaluation criteria
- **Conditional**: Load the samples file IF you need concrete AL examples or patterns to compare against user code
- **Smart Selection**: Only use samples when they add value to your specific evaluation
```

### **Planning Response Pattern:**
```markdown
"[Specialist Identity] here! I'll conduct a systematic [evaluation type].

**📋 Building My Evaluation Plan:**

*Step 1: Scanning relevant areas for your request...*
*Scanning areas/[area1]/, areas/[area2]/, areas/[area3]/*

*Step 2: Complete Topic Index:*
**areas/[area1]/:**
- [topic1].md
- [topic2].md  
- [list all discovered topics...]

**areas/[area2]/:**  
- [topicA].md
- [topicB].md
- [list all discovered topics...]

*Step 3: Systematic Evaluation Plan:*
Based on your request, here's my prioritized evaluation plan:

**High Priority (Will Evaluate):**
1. `[topic].md` - [specific evaluation purpose]
2. `[topic].md` - [specific evaluation purpose]

**Medium Priority (Will Evaluate if Relevant):**
3. `[topic].md` - [specific evaluation purpose]

**Lower Priority (Available if Needed):**  
4. `[topic].md`
5. [other discovered topics...]

**❓ Does this evaluation plan look good to you?** 
- Want me to add focus on any specific areas?  
- Should I skip anything to keep this focused?
- Ready for me to start the systematic evaluation?

[Wait for user approval before proceeding to execution]"
```

### **Execution Response Pattern:**
```markdown
**🔍 [Topic Area] Analysis:**
Loading: `areas/[area]/[specific-topic].md`

**Findings:**
- [Specific observations based on topic principles]
- [If concrete examples would help]: Loading `[topic]-samples.md` for comparison patterns
- [Strengths identified]
- [Issues found with specific guidance]
```

## Reference Implementation

**See**: `roger-reviewer-new.instructions.md` for complete working example

**Roger's Areas:**
- `areas/code-review/` - Code review methodologies, quality checklists
- `areas/code-formatting/` - Formatting standards, documentation patterns
- `areas/naming-conventions/` - Object naming, variable naming consistency
- `areas/architecture-design/` - SOLID principles, anti-patterns, design quality
- `areas/performance-optimization/` - Performance anti-patterns, optimization awareness
- `areas/testing/` - Test quality assessment, coverage analysis

**Compare**: `roger-reviewer.instructions.md` (original) vs `roger-reviewer-new.instructions.md` (systematic approach)

## Benefits for GitHub Copilot

**Concrete Operations**: 
- "Build complete topic index" vs "select relevant topics"
- "Rate each topic High/Medium/Low" vs subjective selection
- "Scan area folders" vs trying to remember topic lists

**Context Management**:
- Load one topic at a time instead of trying to know everything
- Conditional samples usage saves context space
- User approval creates natural break points

**Collaborative Control**:
- User sees exactly what will be evaluated
- Can adjust scope before expensive execution starts
- Controls complexity and time investment

## Conversion Checklist

For each specialist to convert:

### **Planning Section Updates:**
- [ ] Replace topic lists with area folder references
- [ ] Add 6-step systematic planning process
- [ ] Include complete topic index building
- [ ] Add user approval step before execution
- [ ] Remove vague "select relevant topics" language

### **Document Structure Updates:**
- [ ] Explain topic.md vs topic-samples.md pairing
- [ ] Emphasize conditional samples usage
- [ ] Add "Smart Selection" guidance
- [ ] Remove assumptions about loading both files

### **Response Pattern Updates:**
- [ ] Replace generic evaluation with systematic planning template
- [ ] Add step-by-step topic index building
- [ ] Include priority rating (High/Medium/Low)
- [ ] Add user approval request
- [ ] Show progressive execution with one topic at a time

### **Consistency Checks:**
- [ ] Ensure all examples match the 6-step process
- [ ] Remove contradictory guidance about document usage
- [ ] Verify area folder assignments are correct
- [ ] Test that specialist doesn't try to maintain too many areas

## Specialist Area Assignments

Based on `specialist-area-coverage-matrix.md`, each specialist should focus on 3-6 related areas maximum:

**Example Assignments** (from Roger):
- Code Review (primary expertise)
- Code Formatting (standards)
- Naming Conventions (consistency)
- Architecture Design (quality principles)
- Performance Optimization (quality awareness)
- Testing (quality validation)

**Key**: Specialists should have logical, coherent area groupings that support their core expertise rather than scattered, unrelated topics.

## Testing & Validation

**After Conversion:**
1. Test systematic planning with mock scenarios
2. Verify area folder scanning works correctly
3. Ensure conditional samples loading functions properly
4. Validate user approval flow is clear
5. Check that execution follows approved plan
6. Confirm specialist doesn't get overwhelmed by topic volume

**Success Criteria:**
- Specialist can build comprehensive topic index from folders
- User understands and can modify evaluation plan
- Execution focuses deeply on selected topics
- Samples are used strategically, not automatically
- Overall process feels systematic and manageable

---

**Next Steps**: Use this template to systematically convert all specialists from the old "know everything" approach to the new "systematic evaluation" methodology.