---
title: "AppSource Foundation Setup"
description: "Essential metadata, app.json configuration, and basic requirements for AppSource publishing compliance"
area: "appsource-compliance"
difficulty: "beginner"
object_types: ["Table", "Page", "Codeunit"]
variable_types: ["Record"]
tags: ["appsource", "metadata", "app.json", "compliance", "publishing"]
---

# AppSource Foundation Setup

## Essential App Metadata Configuration

### App.json AppSource Compliance
Your `app.json` must include all required metadata for AppSource marketplace submission:

```json
{
    "id": "12345678-1234-1234-1234-123456789012",
    "name": "Customer Loyalty Manager",
    "publisher": "BRC Solutions",
    "version": "1.0.0.0",
    "brief": "Manage customer loyalty points and rewards efficiently",
    "description": "Comprehensive customer loyalty management solution that helps businesses track points, manage rewards, and analyze customer engagement patterns.",
    "privacyStatement": "https://brcsolutions.com/privacy",
    "EULA": "https://brcsolutions.com/eula",
    "help": "https://brcsolutions.com/help/loyalty-manager",
    "url": "https://brcsolutions.com",
    "logo": "loyalty-logo.png",
    "dependencies": [
        {
            "id": "63ca2fa4-4f03-4f2b-a480-172fef340d3f",
            "publisher": "Microsoft", 
            "name": "System Application",
            "version": "26.0.0.0"
        }
    ],
    "application": "26.0.0.0",
    "platform": "26.0.0.0"
}
```

### Required Metadata Elements

#### Publisher Information
- **Publisher Name**: Must match your Partner Center publisher name exactly
- **Publisher Website**: Active, professional website with support information
- **Contact Information**: Valid support email and contact details

#### App Identity
- **Unique GUID**: Generate using New-Guid PowerShell cmdlet, never reuse
- **Semantic Versioning**: Follow x.y.z.w format strictly
- **Clear App Name**: Descriptive, searchable name without trademark conflicts

#### Legal Requirements
- **Privacy Statement**: Publicly accessible URL explaining data handling
- **EULA**: End User License Agreement with clear terms
- **Help Documentation**: Comprehensive user guide and support resources

#### Technical Specifications
- **Dependencies**: List all required system applications and extensions
- **Platform Compatibility**: Specify minimum Business Central version
- **Logo Requirements**: 250x250 PNG image, professional quality

### Compliance Validation Checklist

#### Pre-Submission Requirements
1. **All URLs Active**: Verify privacy, EULA, and help links work correctly
2. **Logo Quality**: Professional 250x250 PNG with transparent background
3. **Version Consistency**: Match version across app.json and AL files
4. **Dependencies Verified**: Test with specified minimum versions

#### Metadata Quality Standards
1. **Description Clarity**: Clear business value proposition under 4000 characters
2. **Brief Summary**: Compelling summary under 100 characters
3. **Publisher Branding**: Consistent branding across all materials
4. **Language Standards**: Professional English with proper grammar

### Common Foundation Issues

#### Metadata Validation Failures
- Mismatched publisher names between Partner Center and app.json
- Invalid or inaccessible URLs for privacy, EULA, or help documentation
- Logo format or size violations
- Version numbering inconsistencies

#### Technical Configuration Errors  
- Incorrect or missing dependencies
- Platform version incompatibilities
- GUID conflicts with existing marketplace apps
- Missing required permissions or entitlements

### AI-Enhanced Foundation Setup
When setting up AppSource foundation requirements, AI assistance should:

- Validate all required metadata fields are complete and properly formatted
- Check that URLs are accessible and contain appropriate content
- Verify logo meets size and format requirements
- Confirm version numbering follows semantic versioning standards
- Suggest improvements for app description and brief summary clarity
