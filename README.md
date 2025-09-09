# Business Central Copilot Guidance 🧙‍♂️⚡

**A comprehensive, community-driven guide for AI-enhanced Business Central development**

## Overview

Open-source, workflow-based AL development guidelines for Microsoft Dynamics 365 Business Central. Organized by development lifecycle phases to maximize productivity with GitHub Copilot and AI assistance.

Whether you're a solo developer, part of a team, or contributing to the community, these guidelines will help you build better BC solutions faster.

## 🎯 Who This Is For

- **AL Developers** looking to enhance productivity with AI assistance
- **BC Partners** wanting standardized development practices
- **Community Contributors** sharing knowledge and best practices
- **Teams** adopting AI-enhanced development workflows

## 👥 BC Development Specialists

**Meet your AI-powered BC development team!** Each specialist brings deep expertise in their domain with distinct personalities tailored to help you excel in different aspects of BC development.

**Quick Specialist Reference:**
- **🏗️ [Alex Architect](bc-specialists/alex-architect.instructions.md)** - Solution planning, requirements analysis, unclear specifications  
- **🏺 [Logan Legacy](bc-specialists/logan-legacy.instructions.md)** - Understanding inherited code, system archaeology, code evolution
- **📚 [Maya Mentor](bc-specialists/maya-mentor.instructions.md)** - Learning-focused guidance, teaching concepts, skill building
- **⚡ [Sam Coder](bc-specialists/sam-coder.instructions.md)** - Fast expert development, efficient implementation, advanced patterns
- **🔍 [Dean Debug](bc-specialists/dean-debug.instructions.md)** - Performance issues, troubleshooting, system optimization
- **👨‍⚖️ [Roger Reviewer](bc-specialists/roger-reviewer.instructions.md)** - Code review, quality improvement, standards compliance
- **🧪 [Quinn Tester](bc-specialists/quinn-tester.instructions.md)** - Testing strategy, quality validation, "what could go wrong?"
- **🌐 [Jordan Bridge](bc-specialists/jordan-bridge.instructions.md)** - Integrations, extensibility, event-driven architecture  
- **🏪 [Morgan Market](bc-specialists/morgan-market.instructions.md)** - AppSource publishing, ISV business strategy
- **🤖 [Casey Copilot](bc-specialists/casey-copilot.instructions.md)** - AI workflow optimization, better prompting techniques
- **📚 [Taylor Docs](bc-specialists/taylor-docs.instructions.md)** - Documentation, knowledge management, technical writing

**[📋 Complete Specialist Guide](bc-specialists/README.md)** - Detailed specialist personalities, collaboration patterns, and usage guidance

*Choose your specialist based on your current development challenge and activate their specialized expertise for your AI-assisted development sessions!*

## 🚀 Quick Start

**Find Atomic Topics by Area**:
- **AI Assistance** → [/areas/ai-assistance/](areas/ai-assistance/) - AI-enhanced development workflows  
- **Architecture & Design** → [/areas/architecture-design/](areas/architecture-design/) - SOLID principles, patterns, anti-patterns
- **Code Creation** → [/areas/code-creation/](areas/code-creation/) - AL object creation and business logic
- **Code Formatting** → [/areas/code-formatting/](areas/code-formatting/) - Style standards and documentation
- **Error Handling** → [/areas/error-handling/](areas/error-handling/) - ErrorInfo patterns and best practices
- **Integration** → [/areas/integration/](areas/integration/) - APIs, events, and external systems
- **Naming Conventions** → [/areas/naming-conventions/](areas/naming-conventions/) - Object and variable naming
- **Performance** → [/areas/performance-optimization/](areas/performance-optimization/) - SetLoadFields, queries, optimization
- **Project Workflow** → [/areas/project-workflow/](areas/project-workflow/) - DevOps, CI/CD, automation
- **Testing** → [/areas/testing/](areas/testing/) - Test strategies, data patterns, validation
- **AppSource Compliance** → [/areas/appsource-compliance/](areas/appsource-compliance/) - Marketplace requirements

### 🔌 Plug-and-Play Setup (PowerShell)

Add this guidance as a git submodule and run the installer to auto-configure lightweight compliance hooks (non-invasive by default).

1) Add the submodule (HTTPS)

```powershell
git submodule add https://github.com/Nubimancy/bc-copilot-guidance copilot-guidance
git submodule update --init --recursive
```

2) Run the installer

- From the project root:

```powershell
pwsh -File ./copilot-guidance/scripts/install-bc-copilot-guidance.ps1
```

- Or from inside the submodule (auto-detects project root):

```powershell
cd ./copilot-guidance
pwsh -File ./scripts/install-bc-copilot-guidance.ps1
```

Optional flags
- Preview only:

```powershell
pwsh -File ./copilot-guidance/scripts/install-bc-copilot-guidance.ps1 -DryRun
```

- Enable PR gate and annotate AL files:

```powershell
pwsh -File ./copilot-guidance/scripts/install-bc-copilot-guidance.ps1 -EnableCI -AnnotateAL
```

To update later

```powershell
git submodule update --remote --merge copilot-guidance
```

## 📁 Repository Structure

### **🔬 Atomic Topic Architecture**

This repository uses an **atomic topic structure** where each concept is broken down into focused, self-contained topics with practical examples:

- **[/areas/](areas/)** - All development topics organized by functional area (134 atomic topics)
  - Each topic has clear YAML frontmatter for discoverability
  - Every topic includes a companion `-samples.md` file with practical examples
  - Topics are discovered via JSON indexes, not hierarchical navigation

### **🤖 Agent Discovery System**
- **[object-types-index.json](areas/object-types-index.json)** - Maps AL object types to relevant topics
- **[variable-types-index.json](areas/variable-types-index.json)** - Maps variable types to applicable guidance

### **🧙‍♂️ Specialist Instruction Files**
- **[bc-specialists/](bc-specialists/)** - AI specialist personas for domain-specific guidance

### **🛠️ Development Tools**
- **[tools/](tools/)** - PowerShell validation scripts for maintaining quality and consistency

## 🌟 Key Features

### **🔬 Atomic Topic Structure**
- **134 focused topics** covering every aspect of BC development
- **Companion sample files** with practical, copy-paste examples
- **JSON-based discovery** for agents and developers
- **Consistent YAML frontmatter** for easy categorization and search

### **🤖 AI-Enhanced Development**
- **Comprehensive prompting strategies** for GitHub Copilot
- **Context-aware development patterns** that work with AI assistance
- **Best practices** for AI-human collaboration in AL development
- **Specialist personas** for domain-specific AI guidance

### **🏗️ Complete Development Lifecycle**
- **Standards-based approach** from planning to deployment
- **Quality gates** and validation strategies
- **Performance optimization** techniques
- **AppSource compliance** guidelines

### **👥 Community-Driven**
- **Open source** and freely available
- **Contribution-friendly** with clear atomic topic guidelines
- **Real-world examples** from community experiences
- **Validation tools** to maintain quality and consistency

## 🛠️ Common Development Tasks

**Quick Reference - Find Topics by Need**:
- **👥 BC Specialists** → [Specialist Team](bc-specialists/README.md) → Choose expert help for your specific challenge
- **Naming Patterns** → [/areas/naming-conventions/](areas/naming-conventions/) → Variable, object, prefix naming
- **Code Quality** → [/areas/code-formatting/](areas/code-formatting/) → Style standards, documentation
- **Error Handling** → [/areas/error-handling/](areas/error-handling/) → ErrorInfo patterns, progressive disclosure
- **Object Creation** → [/areas/code-creation/](areas/code-creation/) → Tables, codeunits, business logic
- **Testing Strategy** → [/areas/testing/](areas/testing/) → Test patterns, data management
- **Performance Tuning** → [/areas/performance-optimization/](areas/performance-optimization/) → SetLoadFields, query optimization
- **API Integration** → [/areas/integration/](areas/integration/) → Events, external systems
- **AppSource Preparation** → [/areas/appsource-compliance/](areas/appsource-compliance/) → Marketplace requirements
- **AI Assistance** → [/areas/ai-assistance/](areas/ai-assistance/) → Prompting, workflows, collaboration

## 🤝 Contributing

We welcome contributions from the Business Central community! Whether you're:
- **Sharing best practices** from your development experience
- **Adding new patterns** or techniques you've discovered
- **Improving documentation** and examples
- **Reporting issues** or suggesting improvements

See our **[Contributing Guidelines](CONTRIBUTING.md)** for how to get involved.

## 📚 Additional Resources

### **Official Microsoft Resources**
- [Business Central Developer Documentation](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/)
- [AL Language Reference](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-programming-in-al)
- [AppSource Publishing Guidelines](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/readiness/readiness-checklist-submit-app)

### **Community Resources**
- [Business Central Community Forums](https://community.dynamics.com/365/b)
- [AL Language GitHub Repository](https://github.com/microsoft/al)
- [Business Central Samples](https://github.com/microsoft/BCApps)

### **AI Development**
- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [AI-Assisted Development Topics](/areas/ai-assistance/) - Atomic guidance for AI-enhanced BC development

## 🎖️ Recognition

This repository builds upon the excellent foundation created by **Flemming Bakkensen** and incorporates community best practices from Business Central developers worldwide.

## 📜 License

This project is open source and available under the [MIT License](LICENSE).

## 🤖 For AI Agents

If you're an AI assistant working in this repository, please refer to [copilot-instructions.md](copilot-instructions.md) for specialized guidance on the atomic topic structure, content standards, and repository-specific context.

---

**Happy coding with AI assistance!** 🧙‍♂️⚡

*Transform your Business Central development with the power of artificial intelligence and community wisdom.*
