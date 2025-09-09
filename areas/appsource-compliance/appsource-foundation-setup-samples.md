# AppSource Foundation Setup - Code Samples

## Complete App.json Example

```json
{
    "id": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
    "name": "Advanced Customer Insights",
    "publisher": "Contoso Business Solutions",
    "version": "2.1.3.0",
    "brief": "AI-powered customer analytics and behavior insights for Business Central",
    "description": "Transform your customer data into actionable insights with Advanced Customer Insights. Features include predictive analytics, customer segmentation, behavior tracking, loyalty program management, and comprehensive reporting dashboards. Integrate seamlessly with existing Business Central workflows while maintaining data privacy and security compliance.",
    "privacyStatement": "https://contoso.com/privacy-policy",
    "EULA": "https://contoso.com/end-user-license-agreement",
    "help": "https://docs.contoso.com/customer-insights",
    "url": "https://contoso.com",
    "logo": "contoso-customer-insights-logo.png",
    "screenshots": [
        "screenshot1.png",
        "screenshot2.png",
        "screenshot3.png"
    ],
    "dependencies": [
        {
            "id": "63ca2fa4-4f03-4f2b-a480-172fef340d3f",
            "publisher": "Microsoft",
            "name": "System Application",
            "version": "26.0.0.0"
        },
        {
            "id": "437dbf0e-84ff-417a-965d-ed2bb9650972",
            "publisher": "Microsoft",
            "name": "Base Application",
            "version": "26.0.0.0"
        }
    ],
    "application": "26.0.0.0",
    "platform": "26.0.0.0",
    "idRanges": [
        {
            "from": 50100,
            "to": 50199
        }
    ],
    "contextSensitiveHelpUrl": "https://docs.contoso.com/customer-insights/{0}",
    "showMyCode": false,
    "runtime": "11.0",
    "target": "Cloud"
}
```

## Logo Requirements Validation Script

```powershell
# AppSource Logo Validation Script
param(
    [Parameter(Mandatory=$true)]
    [string]$LogoPath
)

function Test-AppSourceLogo {
    param([string]$Path)
    
    $results = @{
        IsValid = $true
        Issues = @()
        Recommendations = @()
    }
    
    if (-not (Test-Path $Path)) {
        $results.IsValid = $false
        $results.Issues += "Logo file not found at specified path"
        return $results
    }
    
    # Check file format
    $extension = [System.IO.Path]::GetExtension($Path).ToLower()
    if ($extension -ne '.png') {
        $results.IsValid = $false
        $results.Issues += "Logo must be PNG format, found: $extension"
    }
    
    # Check dimensions using .NET
    Add-Type -AssemblyName System.Drawing
    $img = [System.Drawing.Image]::FromFile($Path)
    
    if ($img.Width -ne 250 -or $img.Height -ne 250) {
        $results.IsValid = $false
        $results.Issues += "Logo must be exactly 250x250 pixels, found: $($img.Width)x$($img.Height)"
    }
    
    # Check file size (should be reasonable for web)
    $fileSize = (Get-Item $Path).Length
    if ($fileSize -gt 500KB) {
        $results.Recommendations += "Logo file size is $([math]::Round($fileSize/1KB))KB. Consider optimizing for faster loading."
    }
    
    $img.Dispose()
    return $results
}

$validation = Test-AppSourceLogo -Path $LogoPath
if ($validation.IsValid) {
    Write-Host "✅ Logo meets AppSource requirements" -ForegroundColor Green
} else {
    Write-Host "❌ Logo validation failed:" -ForegroundColor Red
    $validation.Issues | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
}

if ($validation.Recommendations.Count -gt 0) {
    Write-Host "💡 Recommendations:" -ForegroundColor Yellow
    $validation.Recommendations | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
}
```

## URL Validation Examples

```powershell
# AppSource URL Validation Script
$appJson = Get-Content "app.json" | ConvertFrom-Json

$requiredUrls = @{
    "Privacy Statement" = $appJson.privacyStatement
    "EULA" = $appJson.EULA
    "Help Documentation" = $appJson.help
    "Publisher Website" = $appJson.url
}

foreach ($urlType in $requiredUrls.Keys) {
    $url = $requiredUrls[$urlType]
    
    try {
        $response = Invoke-WebRequest -Uri $url -Method Head -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ $urlType is accessible" -ForegroundColor Green
        } else {
            Write-Host "⚠️  $urlType returned status code: $($response.StatusCode)" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "❌ $urlType is not accessible: $url" -ForegroundColor Red
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}
```

## Version Management Examples

```json
// Version progression examples for AppSource
{
    "initial_release": "1.0.0.0",
    "bug_fix": "1.0.1.0",
    "minor_feature": "1.1.0.0",
    "major_update": "2.0.0.0",
    "hotfix": "2.0.0.1"
}
```

## Dependency Management

```al
// Example of proper dependency handling in AL code
codeunit 50100 "Dependency Validator"
{
    procedure ValidateSystemDependencies()
    var
        ModuleInfo: ModuleInfo;
        SystemAppId: Guid;
    begin
        // Validate System Application dependency
        SystemAppId := '63ca2fa4-4f03-4f2b-a480-172fef340d3f';
        
        if not NavApp.GetModuleInfo(SystemAppId, ModuleInfo) then
            Error('Required System Application dependency not found. Please install System Application.');
            
        // Validate minimum version requirement
        if ModuleInfo.AppVersion < Version.Create(26, 0, 0, 0) then
            Error('System Application version %1 is too old. Minimum required version is 26.0.0.0', ModuleInfo.AppVersion);
    end;
}
```

## Pre-Submission Validation Checklist

```yaml
# AppSource Foundation Validation Checklist
foundation_validation:
  metadata:
    - app_json_valid: true
    - guid_unique: true
    - publisher_name_matches: true
    - version_semantic: true
    
  urls:
    - privacy_statement_accessible: true
    - eula_accessible: true
    - help_documentation_accessible: true
    - publisher_website_accessible: true
    
  assets:
    - logo_format_png: true
    - logo_size_250x250: true
    - screenshots_provided: true
    - screenshots_high_quality: true
    
  dependencies:
    - system_application_specified: true
    - base_application_specified: true
    - versions_compatible: true
    - id_ranges_defined: true
    
  technical:
    - context_sensitive_help: true
    - runtime_specified: true
    - target_platform_cloud: true
    - show_my_code_false: true
```
