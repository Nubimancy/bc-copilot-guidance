# Contributing to BC Copilot Guidance 🤝

Thank you for your interest in contributing to this community-driven Business Central development guide! Your contributions help make AI-enhanced BC development accessible to developers worldwide.

## How to Contribute

We welcome all types of contributions:
- **Bug fixes** and corrections
- **New content** and guides  
- **Code examples** and samples
- **Improved explanations** and clarity
- **Community resources** and links
- **Translation** and localization

## Getting Started

### 1. Fork and Clone

```bash
# Fork the repository on GitHub, then clone your fork
git clone https://github.com/YOUR-USERNAME/bc-copilot-guidance.git
cd bc-copilot-guidance

# Add upstream remote
git remote add upstream https://github.com/Nubimancy/bc-copilot-guidance.git
```

### 2. Create a Feature Branch

```bash
# Create a branch for your contribution
git checkout -b feature/your-contribution-name

# Or for bug fixes
git checkout -b fix/description-of-fix
```

### 3. Make Your Changes

Follow our content standards (see below) when making changes.

### 4. Test Your Changes

- **Validate markdown formatting** using a markdown previewer
- **Test code examples** in a BC development environment  
- **Check links** to ensure they work correctly
- **Review spelling and grammar**

### 5. Submit a Pull Request

```bash
# Commit your changes
git add .
git commit -m "feat: add guide for XYZ feature"

# Push to your fork
git push origin feature/your-contribution-name

# Create pull request on GitHub
```

## Content Standards

### Writing Style

#### Tone and Voice
- **Professional but approachable** - Technical expertise with friendly guidance
- **Clear and concise** - Avoid unnecessary jargon or overly complex explanations
- **Action-oriented** - Focus on what developers can do and achieve
- **Community-minded** - Emphasize shared learning and collaboration

#### Structure
- **Use clear headings** with proper markdown hierarchy (H1 → H2 → H3)
- **Include practical examples** with working code samples
- **Add context** for why something matters, not just how to do it
- **Provide next steps** and related resources

### Code Standards

#### AL Code Examples
- **Follow Microsoft AL style guidelines**
- **Include proper comments** explaining business logic
- **Use meaningful object and variable names**
- **Include error handling** where appropriate
- **Test all code examples** before submitting

```al
// ✅ Good example
table 50100 "Customer Loyalty Points"
{
    DataClassification = CustomerContent;
    Caption = 'Customer Loyalty Points';
    
    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer."No.";
            NotBlank = true;
        }
        
        field(2; "Points Balance"; Decimal)
        {
            Caption = 'Points Balance';
            MinValue = 0;
            DecimalPlaces = 0 : 2;
        }
    }
    
    keys
    {
        key(PK; "Customer No.")
        {
            Clustered = true;
        }
    }
}
```

#### Markdown Formatting
- **Use code blocks** with language specification
- **Include file paths** in examples when relevant
- **Add line comments** to explain complex code sections
- **Use consistent indentation** (4 spaces for AL code)

### Documentation Standards

#### File Structure
```
section-name/
├── README.md          # Main guide for the section
├── specific-topic.md  # Detailed topic guides
├── examples/          # Code examples and samples
└── resources/         # Additional resources and links
```

#### Frontmatter (when applicable)
```yaml
---
title: "Guide Title"
description: "Brief description of the guide content"
category: "core-development" # or testing, optimization, etc.
difficulty: "beginner" # beginner, intermediate, advanced
last_updated: "2025-01-17"
---
```

#### Cross-References
- **Link to related sections** within the repository
- **Reference official Microsoft documentation** when appropriate
- **Include community resources** and external links
- **Maintain link accuracy** and update broken links

## Types of Contributions

### 🐛 Bug Reports and Fixes

**When reporting bugs:**
- Use the issue template provided
- Include specific examples of incorrect information
- Suggest corrections when possible
- Test your understanding against official documentation

**When fixing bugs:**
- Reference the issue number in your commit
- Include explanation of what was incorrect
- Verify fix against authoritative sources

### 📝 Content Improvements

**New Guides:**
- Choose topics not already covered
- Follow the established structure and style
- Include practical examples and real-world scenarios
- Test all code examples thoroughly

**Enhancing Existing Content:**
- Improve clarity and readability
- Add missing information or examples  
- Update outdated information
- Expand on topics that need more detail

### 💡 New Features

**New Sections:**
- Propose new major sections via GitHub Issues first
- Ensure they fit the overall repository structure
- Include comprehensive content plan
- Consider maintenance requirements

**Code Examples:**
- Add practical, real-world examples
- Include step-by-step implementation guides
- Provide context for when to use each approach
- Test examples in multiple BC versions when relevant

### 🌍 Translations

While the primary language is English, we welcome:
- **Localized examples** for specific regions/countries
- **Cultural context** for business scenarios
- **Region-specific resources** and community links

## Review Process

### Pull Request Review
1. **Automated checks** run on all PRs (markdown linting, link checking)
2. **Maintainer review** for content accuracy and style
3. **Community feedback** period for significant changes
4. **Final approval** and merge

### Review Criteria
- **Technical accuracy** - Information must be correct and current
- **Style consistency** - Follows established writing and formatting standards  
- **Value addition** - Contributes meaningfully to developer knowledge
- **Maintenance** - Can be reasonably maintained over time

## Community Guidelines

### Code of Conduct

We are committed to providing a welcoming and inclusive environment:

- **Be respectful** in all interactions
- **Assume positive intent** from other contributors
- **Focus on constructive feedback** rather than criticism
- **Welcome newcomers** and help them get started
- **Credit others** for their contributions and ideas

### Communication

**GitHub Issues:**
- Use for bug reports, feature requests, and planning discussions
- Search existing issues before creating new ones
- Use clear, descriptive titles
- Provide sufficient context and examples

**Pull Request Discussions:**
- Focus on the specific changes being proposed
- Provide actionable feedback
- Explain the reasoning behind suggestions
- Be open to alternative approaches

### Recognition

We recognize contributors through:
- **Contributors list** in the repository README
- **Acknowledgment** in release notes for significant contributions
- **Community highlights** in documentation updates

## Getting Help

### For New Contributors
- **Read existing content** to understand style and structure
- **Start small** with minor improvements or corrections
- **Ask questions** in GitHub Issues if you're unsure
- **Join community discussions** to understand needs and priorities

### For Technical Questions
- **Check official BC documentation** first
- **Search community forums** for similar questions
- **Test your understanding** in a development environment
- **Ask specific questions** with relevant context

### For Process Questions
- **Review this contributing guide** thoroughly
- **Look at previous pull requests** for examples
- **Ask maintainers** for clarification when needed

## Development Setup

### Local Development
```bash
# Install recommended tools for markdown editing
npm install -g markdownlint-cli
npm install -g markdown-link-check

# Validate markdown files
markdownlint **/*.md

# Check all links
markdown-link-check **/*.md
```

### Testing Code Examples
- Set up local BC development environment
- Test all AL code examples before submitting
- Verify examples work with current BC versions
- Include version compatibility notes when relevant

## Maintenance

### Keeping Content Current
- **Monitor BC releases** for changes affecting guidance
- **Update examples** to reflect current best practices  
- **Verify links** regularly and fix broken ones
- **Incorporate community feedback** and suggestions

### Long-term Vision
This repository aims to be:
- **The definitive guide** for AI-enhanced BC development
- **Community-maintained** and continuously improved
- **Beginner-friendly** while remaining comprehensive
- **Practically focused** on real-world development scenarios

---

**Thank you for contributing to the Business Central development community!** 🚀

*Your contributions help developers worldwide build better solutions faster with AI assistance. Every improvement, no matter how small, makes a difference.*

## Quick Reference

### Commit Message Format
```
type(scope): description

feat(core-dev): add AL object patterns guide
fix(examples): correct table relation syntax
docs(readme): update installation instructions
style(format): fix markdown formatting issues
```

### Branch Naming
```
feature/descriptive-name
fix/bug-description
docs/documentation-update
```

### Issue Labels
- `bug` - Something isn't working correctly
- `enhancement` - New feature or improvement
- `documentation` - Documentation improvements
- `good first issue` - Good for newcomers
- `help wanted` - Community input requested
