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

## 🚀 Quick Start

**Common Scenarios**:
- **New to BC Development** → [Getting Started Guide](getting-started/) → [Core Development](core-development/)
- **First AI-Enhanced Project** → [Copilot Techniques](copilot-techniques/) → [Core Principles](getting-started/core-principles.md)
- **Writing Better Code** → [Coding Standards](core-development/coding-standards.md) → [Modern AL Patterns](modern-al-patterns/)
- **Better Error Handling** → [Modern Error Handling](core-development/modern-error-handling.md)
- **Testing Strategy** → [Testing Guide](testing-validation/testing-strategy.md)
- **Performance Issues** → [Optimization Guide](performance-optimization/optimization-guide.md)
- **AppSource Publishing** → [AppSource Requirements](appsource-publishing/appsource-requirements.md)
- **AI Prompting Help** → [Prompting Strategies](copilot-techniques/prompting-strategies.md)
- **Project Planning** → [Development Lifecycle](project-management/feature-development-lifecycle.md)

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

### **Core Development Workflows**
- **[core-development/](core-development/)** - AL objects, business logic, and fundamental patterns
- **[modern-al-patterns/](modern-al-patterns/)** - SOLID principles, clean architecture, and extensibility patterns
- **[testing-validation/](testing-validation/)** - Testing strategies and quality assurance
- **[performance-optimization/](performance-optimization/)** - Performance tuning and optimization
- **[appsource-publishing/](appsource-publishing/)** - Marketplace compliance and publishing

### **AI-Enhanced Development**
- **[ai-assistance/](ai-assistance/)** - Experience-based AI guidance, prompt libraries, and adaptive development workflows
- **[copilot-techniques/](copilot-techniques/)** - GitHub Copilot strategies, prompting, and AI-assisted development
- **[getting-started/](getting-started/)** - Onboarding guides for AI-enhanced BC development

### **Project Management & Standards**
- **[project-management/](project-management/)** - Development lifecycle and workflow patterns
- **[examples/](examples/)** - Sample projects and real-world scenarios

## 🌟 Key Features

### **AI-Enhanced Development**
- **Comprehensive prompting strategies** for GitHub Copilot
- **Context-aware development patterns** that work with AI assistance
- **Best practices** for AI-human collaboration in AL development

### **Complete Development Lifecycle**
- **Standards-based approach** from planning to deployment
- **Quality gates** and validation strategies
- **Performance optimization** techniques
- **AppSource compliance** guidelines

### **Community-Driven**
- **Open source** and freely available
- **Contribution-friendly** with clear guidelines
- **Real-world examples** from community experiences
- **Regularly updated** based on community feedback

## 🛠️ Common Development Tasks

**Quick Reference Links**:
- **Naming Conventions** → [naming-conventions](core-development/naming-conventions.md)
- **Code Style** → [coding-standards](core-development/coding-standards.md)
- **Error Handling** → [error-handling](core-development/error-handling.md)
- **Object Patterns** → [object-patterns](core-development/object-patterns.md)
- **Testing Strategy** → [testing-strategy](testing-validation/testing-strategy.md)
- **Performance Tuning** → [optimization-guide](performance-optimization/optimization-guide.md)
- **API Integration** → [integration-patterns](integration-deployment/integration-patterns.md)
- **AppSource Preparation** → [appsource-requirements](appsource-publishing/appsource-requirements.md)
- **AI Prompting** → [prompting-strategies](copilot-techniques/prompting-strategies.md)

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
- [AI-Assisted Development Best Practices](copilot-techniques/)

## 🎖️ Recognition

This repository builds upon the excellent foundation created by **Flemming Bakkensen** and incorporates community best practices from Business Central developers worldwide.

## 📜 License

This project is open source and available under the [MIT License](LICENSE).

## 🤖 For AI Agents

If you're an AI assistant working in this repository, please refer to [.copilot-instructions.md](.copilot-instructions.md) for specialized guidance on content standards, code patterns, and repository-specific context.

---

**Happy coding with AI assistance!** 🧙‍♂️⚡

*Transform your Business Central development with the power of artificial intelligence and community wisdom.*
