# Getting Started with AI-Enhanced BC Development 🚀

**Quick setup guide for Business Central development with GitHub Copilot**

## Essential Setup (15 minutes)

### Required Tools
- **VS Code** + AL Language Extension  
- **GitHub Copilot Extension** (requires GitHub Pro/Enterprise)
- **Business Central Docker** or **Sandbox Environment**
- **Git** for version control

```bash
# Install core extensions
code --install-extension ms-dynamics-smb.al
code --install-extension GitHub.copilot
code --install-extension GitHub.copilot-chat
```

### GitHub Copilot Setup
1. Sign in to GitHub in VS Code
2. Authorize Copilot when prompted  
3. Test: `Ctrl+Shift+P` → "GitHub Copilot: Open Copilot Chat"

### BC Environment  
**Docker (Recommended):**
```powershell
docker pull mcr.microsoft.com/businesscentral/sandbox
New-BcContainer -accept_eula -containerName bcdev -imageName mcr.microsoft.com/businesscentral/sandbox
```

**Cloud Sandbox:** Use Microsoft 365 Developer tenant + BC Sandbox

## First AI Project (10 minutes)

```powershell
# Create and setup project
mkdir MyFirstBCApp && cd MyFirstBCApp
al:go  # AL: Go command in VS Code
git init && git add . && git commit -m "Initial AL project"
```

## AI Development Essentials

### Effective Copilot Prompts
```al
// ✅ Good: Specific, contextual
// Create a table for customer loyalty points with validation
table 50100 "Customer Loyalty Points"

// ❌ Avoid: Vague requests  
// make a table
```

### Core AL Patterns with AI
**Tables:** `// Create table for [business concept] with [specific fields]`
**Pages:** `// Create list page for [table name] with [specific features]`  
**Codeunits:** `// Create codeunit for [business process] with error handling`

### AI-Assisted Debugging
1. **Use Copilot Chat:** Select error → Ask "Explain this AL error"
2. **Context-aware fixes:** Include surrounding code in requests
3. **Pattern recognition:** Ask for similar working examples

## Next Steps

**Choose your path:**
- **Understanding Principles:** → [Core Principles](core-principles.md) - Foundation concepts
- **New to AL:** → [Core Development](../core-development/)
- **Experienced AL:** → [Copilot Techniques](../copilot-techniques/)  
- **Team Lead:** → [Project Management](../project-management/)

## Quick Reference

**Copilot Shortcuts:**
- `Ctrl+I` - Inline suggestions
- `Ctrl+Shift+P` → "Copilot Chat" - Open chat
- `Alt+\` - Accept suggestion
- `Alt+[` / `Alt+]` - Navigate suggestions

**AL Essentials:**
- `al:go` - New AL project
- `Ctrl+Shift+P` → "AL: Download symbols" - Get BC symbols
- `F5` - Publish to BC environment

**Common Issues:**
- **Copilot not working?** Check GitHub authentication  
- **AL symbols missing?** Download symbols first
- **Container issues?** Verify Docker Desktop is running

---

**Ready to build amazing BC solutions with AI assistance!** 🧙‍♂️⚡

*For detailed guides, see other sections in this repository.*
