# AL Development Environment Setup Patterns - Code Samples

## Docker Container Configuration

### Business Central Container Setup

```powershell
# Create and start Business Central development container
$containerName = "bc-dev"
$imageName = "mcr.microsoft.com/businesscentral/onprem:latest"

# Container configuration with development optimizations
$containerParams = @{
    accept_eula = $true
    containerName = $containerName
    imageName = $imageName
    Credential = $credential
    auth = "NavUserPassword"
    includeTestToolkit = $true
    includeTestLibrariesOnly = $true
    doNotExportObjectsToText = $true
    shortcuts = "Desktop"
    useBestContainerOS = $true
}

New-BCContainer @containerParams
```

### Container Resource Optimization

```powershell
# Docker container with optimized resource allocation
docker run -d `
  --name bc-dev-optimized `
  --hostname bc-dev `
  -p 1433:1433 `
  -p 80:80 `
  -p 8080:8080 `
  -p 443:443 `
  -p 7049:7049 `
  -p 7048:7048 `
  --memory=8g `
  --cpus="4" `
  -e accept_eula=Y `
  -e usessl=N `
  -e auth=NavUserPassword `
  -e username=admin `
  -e password=P@ssw0rd123 `
  mcr.microsoft.com/businesscentral/onprem:latest
```

## VS Code Configuration

### Workspace Settings (settings.json)

```json
{
    "al.enableCodeAnalysis": true,
    "al.codeAnalyzers": [
        "${CodeCop}",
        "${PerTenantExtensionCop}",
        "${UICop}",
        "${AppSourceCop}"
    ],
    "al.enableCodeActions": true,
    "al.browser": "Edge",
    "al.compileOnSave": false,
    "al.incrementalBuild": true,
    "files.autoSave": "onWindowChange",
    "editor.minimap.enabled": false,
    "editor.wordWrap": "on",
    "al.assemblyProbingPaths": [
        "./.alpackages"
    ],
    "al.packageCachePath": "./.alpackages"
}
```

### Launch Configuration (launch.json)

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "type": "al",
            "request": "launch",
            "name": "Local Development Server",
            "server": "http://bc-dev",
            "serverInstance": "BC",
            "authentication": "UserPassword",
            "username": "admin",
            "password": "P@ssw0rd123",
            "startupObjectId": 22,
            "startupObjectType": "Page",
            "breakOnError": true,
            "launchBrowser": true,
            "enableLongRunningSqlStatements": true,
            "enableSqlInformationDebugger": true,
            "tenant": "default"
        },
        {
            "type": "al",
            "request": "launch",
            "name": "Cloud Sandbox",
            "environmentType": "Sandbox",
            "environmentName": "MySandbox",
            "startupObjectId": 22,
            "startupObjectType": "Page",
            "breakOnError": true,
            "launchBrowser": true
        }
    ]
}
```

## Project Configuration

### App Manifest (app.json)

```json
{
    "id": "12345678-1234-1234-1234-123456789012",
    "name": "My AL Extension",
    "publisher": "My Company",
    "version": "1.0.0.0",
    "brief": "Brief description of the extension",
    "description": "Detailed description of the extension functionality",
    "privacyStatement": "https://mycompany.com/privacy",
    "EULA": "https://mycompany.com/eula",
    "help": "https://mycompany.com/help",
    "url": "https://mycompany.com",
    "logo": "logo.png",
    "dependencies": [
        {
            "id": "63ca2fa4-4f03-4f2b-a480-172fef340d3f",
            "publisher": "Microsoft",
            "name": "System Application",
            "version": "19.0.0.0"
        },
        {
            "id": "437dbf0e-84ff-417a-965d-ed2bb9650972",
            "publisher": "Microsoft", 
            "name": "Base Application",
            "version": "19.0.0.0"
        }
    ],
    "screenshots": [],
    "platform": "19.0.0.0",
    "application": "19.0.0.0",
    "idRanges": [
        {
            "from": 50000,
            "to": 50099
        }
    ],
    "resourceExposurePolicy": {
        "allowDebugging": true,
        "allowDownloadingSource": false,
        "includeSourceInSymbolFile": false
    },
    "runtime": "9.0",
    "features": [
        "NoImplicitWith"
    ]
}
```

### Git Configuration (.gitignore)

```gitignore
# AL-specific ignores
.alpackages/
*.app
.vscode/rad.json

# Build artifacts
/Translations/
/.alcache/
/.alpublish/

# VS Code settings (keep workspace-specific)
.vscode/settings.json
!.vscode/launch.json
!.vscode/tasks.json

# Windows
Thumbs.db
Desktop.ini

# macOS
.DS_Store
.AppleDouble

# Environment files
.env
.env.local
```

## Team Environment Templates

### Shared Development Container Script

```powershell
# Team development container setup script
param(
    [string]$DeveloperName,
    [string]$ProjectName = "TeamALProject"
)

# Standardized container configuration for team
$teamContainerConfig = @{
    containerName = "$ProjectName-$DeveloperName"
    imageName = "mcr.microsoft.com/businesscentral/onprem:19.5"
    accept_eula = $true
    auth = "NavUserPassword"
    Credential = (Get-Credential -Message "Enter container credentials")
    includeTestToolkit = $true
    memoryLimit = "8GB"
    shortcuts = "Desktop"
    useCleanDatabase = $true
    multitenant = $false
}

# Create standardized development environment
New-BCContainer @teamContainerConfig

# Configure container for team standards
$containerName = $teamContainerConfig.containerName
Import-TestToolkitToBCContainer -containerName $containerName
Setup-BCContainerTestUsers -containerName $containerName
```

### Environment Validation Script

```powershell
# Validate AL development environment setup
function Test-ALEnvironmentSetup {
    $results = @()
    
    # Check Docker Desktop
    try {
        $dockerVersion = docker --version
        $results += @{ Component = "Docker"; Status = "OK"; Version = $dockerVersion }
    } catch {
        $results += @{ Component = "Docker"; Status = "MISSING"; Version = "N/A" }
    }
    
    # Check VS Code
    try {
        $codeVersion = code --version
        $results += @{ Component = "VS Code"; Status = "OK"; Version = $codeVersion[0] }
    } catch {
        $results += @{ Component = "VS Code"; Status = "MISSING"; Version = "N/A" }
    }
    
    # Check AL Extension
    $alExtension = code --list-extensions | Where-Object { $_ -like "*ms-dynamics-smb.al*" }
    if ($alExtension) {
        $results += @{ Component = "AL Extension"; Status = "OK"; Version = $alExtension }
    } else {
        $results += @{ Component = "AL Extension"; Status = "MISSING"; Version = "N/A" }
    }
    
    # Check BC Container
    try {
        $containers = Get-BCContainers
        if ($containers.Count -gt 0) {
            $results += @{ Component = "BC Container"; Status = "OK"; Version = "$($containers.Count) containers" }
        } else {
            $results += @{ Component = "BC Container"; Status = "MISSING"; Version = "N/A" }
        }
    } catch {
        $results += @{ Component = "BC Container"; Status = "ERROR"; Version = "N/A" }
    }
    
    return $results
}

# Run environment validation
Test-ALEnvironmentSetup | Format-Table -AutoSize
```

## Advanced Configuration

### Multi-Environment Management

```powershell
# Script to manage multiple AL development environments
class ALEnvironmentManager {
    [hashtable]$environments = @{}
    
    [void] CreateEnvironment([string]$name, [string]$version, [int]$idRangeStart) {
        $config = @{
            containerName = "bc-$name"
            imageName = "mcr.microsoft.com/businesscentral/onprem:$version"
            idRangeStart = $idRangeStart
            idRangeEnd = $idRangeStart + 99
            created = Get-Date
        }
        
        $this.environments[$name] = $config
        $this.CreateContainer($config)
    }
    
    [void] CreateContainer([hashtable]$config) {
        New-BCContainer `
            -containerName $config.containerName `
            -imageName $config.imageName `
            -accept_eula `
            -auth "NavUserPassword" `
            -Credential (Get-Credential) `
            -includeTestToolkit
    }
    
    [void] SwitchEnvironment([string]$name) {
        if ($this.environments.ContainsKey($name)) {
            $config = $this.environments[$name]
            Write-Host "Switching to environment: $name"
            Write-Host "Container: $($config.containerName)"
            Write-Host "ID Range: $($config.idRangeStart)-$($config.idRangeEnd)"
        }
    }
}

# Usage example
$envManager = [ALEnvironmentManager]::new()
$envManager.CreateEnvironment("Development", "19.5", 50000)
$envManager.CreateEnvironment("Testing", "19.5", 51000)
$envManager.SwitchEnvironment("Development")
```

### Automated Project Initialization

```powershell
# Initialize new AL project with team standards
function Initialize-ALProject {
    param(
        [string]$ProjectName,
        [string]$Publisher,
        [int]$IdRangeStart = 50000
    )
    
    # Create project folder structure
    New-Item -Path $ProjectName -ItemType Directory -Force
    Set-Location $ProjectName
    
    # Initialize folders
    @("src", "test", "docs", ".vscode") | ForEach-Object {
        New-Item -Path $_ -ItemType Directory -Force
    }
    
    # Create app.json with team template
    $appJson = @{
        id = [System.Guid]::NewGuid().ToString()
        name = $ProjectName
        publisher = $Publisher
        version = "1.0.0.0"
        brief = "AL Extension for $ProjectName"
        description = "Business Central AL extension"
        platform = "19.0.0.0"
        application = "19.0.0.0"
        idRanges = @(
            @{
                from = $IdRangeStart
                to = $IdRangeStart + 99
            }
        )
        runtime = "9.0"
        features = @("NoImplicitWith")
    } | ConvertTo-Json -Depth 10
    
    $appJson | Out-File -Path "app.json" -Encoding UTF8
    
    Write-Host "AL project '$ProjectName' initialized successfully"
    Write-Host "ID Range: $IdRangeStart - $($IdRangeStart + 99)"
}

# Initialize new project
Initialize-ALProject -ProjectName "CustomerEnhancement" -Publisher "My Company" -IdRangeStart 50100
```
