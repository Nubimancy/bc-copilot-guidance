# AI Agent Instructions for BC Copilot Guidance Repository 🤖

## Repository Context
**Purpose:** Community-driven Business Central development guidance with AI-enhancement focus  
**Goal:** Help developers build better BC solutions faster using AI assistance  
**Audience:** BC developers worldwide (beginner to advanced)

## Core Guidelines

### Code Standards (Critical)
- Follow Microsoft AL style guidelines strictly
- Include error handling in all examples
- Use meaningful variable/object names
- Test all code snippets before inclusion
- Add business logic comments

### Content Tone
- Professional but approachable
- Clear, actionable guidance
- Community-focused (no internal jargon)
- Include working code examples
- Reference official Microsoft docs

### Section-Specific Focus

**core-development/:** AL patterns, clean code, performance  
**testing-debugging/:** Testing strategies, debugging techniques  
**appsource-publishing/:** AppSource compliance, certification  
**integration-deployment/:** API patterns, security, automation  
**project-management/:** Generic workflows, GitHub-based

### Proactive Suggestions
Always suggest: related sections, next steps, testing strategies, performance tips

### Markdown Standards
```markdown
# Main heading (H1) - Section title
## Sub-section (H2) - Major topics
### Implementation (H3) - Specific guidance

**Bold** for key terms
`Code snippets` for AL/technical terms
```

### AL Code Template
```al
// Always include context comments
// Use realistic business scenarios
table 50100 "Sample Table"
{
    Caption = 'Sample Table';
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
        }
    }
}
```

### Quality Gates
1. ✅ Technical accuracy
2. ✅ Style consistency  
3. ✅ Community value
4. ✅ AI-enhancement focus
5. ✅ Maintainability

### Repository Structure
- Each section has README.md for navigation
- Code examples in `/examples/` subdirectories  
- Cross-references use relative links
- Assets in `/assets/` folders

### AI Enhancement Context
This repository teaches: GitHub Copilot for BC development, better AI prompts, AI workflow integration, quality with AI assistance, accelerated development.

### Community Focus
- Global BC developer audience
- Vendor-neutral (except Microsoft BC)
- Multiple skill levels
- Encourage contributions
- Avoid proprietary tools

**Key:** Every piece of content should help developers leverage AI tools more effectively while maintaining professional development standards.

---

*For human-readable information, see [README.md](README.md)*
