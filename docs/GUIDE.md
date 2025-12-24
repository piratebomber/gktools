# GKTools Installation & Usage Guide

## Quick Start

### Method 1: Single-Line Loader (Recommended)
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/gktools/main/loader.lua"))()
```

### Method 2: Manual Installation
1. Download all files from the `src/` directory
2. Place them in your Roblox game's ServerScriptService
3. Execute the main script:
```lua
local GKTools = require(game.ServerScriptService.gktools.src.init)
local gktools = GKTools()
gktools:Initialize()
```

## Features Overview

### 🔍 Advanced Decompilation
- **Multi-method source extraction**: Uses property access, metatable manipulation, and bytecode analysis
- **Real-time analysis**: Instant decompilation as you browse the game tree
- **Fallback mechanisms**: Multiple extraction methods ensure maximum compatibility

### 🌳 Complete Game Tree Visualization
- **All services**: ServerScriptService, ServerStorage, StarterGui, Players, etc.
- **Hierarchical browsing**: Expandable tree structure with icons
- **Real-time updates**: Automatically detects new scripts and instances

### 🎨 Modern UI Framework
- **Dark/Light themes**: Auto-detection or manual selection
- **Syntax highlighting**: Lua keyword and string highlighting
- **Draggable interface**: Resizable and movable windows
- **Context menus**: Right-click functionality throughout

### 🔒 Advanced Security
- **Sandbox execution**: Safe code execution environment
- **Threat detection**: Identifies dangerous patterns and functions
- **Permission levels**: Configurable security restrictions
- **Resource monitoring**: Tracks memory and execution time

### 🧠 Intelligent Analysis
- **Complexity metrics**: Cyclomatic complexity calculation
- **Vulnerability scanning**: Detects security issues
- **Pattern recognition**: Identifies code patterns and structures
- **Performance analysis**: Code quality metrics

## Interface Guide

### Main Window Layout
```
┌─────────────────────────────────────────────────────────┐
│ GKTools - Advanced Decompiler                    [- □ ×] │
├─────────────────────────────────────────────────────────┤
│ [🔄 Refresh] [💾 Export] [⚙️ Settings] [ℹ️ About]      │
├──────────────┬──────────────────────────────────────────┤
│ Game Tree    │ Code Editor                              │
│              │                                          │
│ 📜 ServerSc… │ 1  -- Select a script from the game     │
│ 📦 ServerSt… │ 2  -- tree to view its source code      │
│ 🖥️ StarterG… │ 3                                       │
│ 👤 StarterP… │ 4                                       │
│ 👥 Players   │ 5                                       │
│ 🌍 Workspace │                                          │
│              │                                          │
├──────────────┴──────────────────────────────────────────┤
│ Ready - GKTools Advanced Decompiler                     │
└─────────────────────────────────────────────────────────┘
```

### Game Tree Navigation
- **Click** service names to expand/collapse
- **Click** script names to decompile and view source
- **Right-click** for context menu options:
  - Refresh Tree
  - Expand All
  - Collapse All
  - Export Selected

### Code Editor Features
- **Line numbers**: Automatic line numbering
- **Syntax highlighting**: Lua keywords, strings, and comments
- **Scrollable**: Handle large source files
- **Read-only**: View decompiled source safely

## Configuration Options

### Security Levels

#### RESTRICTED
```lua
{
    securityLevel = "RESTRICTED",
    -- Limited global access
    -- Blocked dangerous functions
    -- Strict resource limits
    -- Full monitoring enabled
}
```

#### MEDIUM (Default)
```lua
{
    securityLevel = "MEDIUM",
    -- Standard global access
    -- Some functions blocked
    -- Moderate resource limits
    -- Monitoring enabled
}
```

#### HIGH
```lua
{
    securityLevel = "HIGH",
    -- Full global access
    -- No function restrictions
    -- High resource limits
    -- Monitoring optional
}
```

### Theme Options
```lua
{
    uiTheme = "AUTO",    -- Auto-detect based on Studio theme
    uiTheme = "DARK",    -- Force dark theme
    uiTheme = "LIGHT"    -- Force light theme
}
```

### Advanced Configuration
```lua
local config = {
    enableMetatableHooks = true,     -- Enable advanced metatable manipulation
    maxRecursionDepth = 50,          -- Maximum tree traversal depth
    enableBytecodeAnalysis = true,   -- Enable bytecode analysis features
    securityLevel = "MEDIUM",        -- Security restriction level
    uiTheme = "AUTO"                 -- UI theme selection
}

gktools:Initialize(config)
```

## Advanced Usage

### Programmatic Access
```lua
-- Get decompiler instance
local decompiler = gktools.Decompiler

-- Decompile specific script
local script = game.ServerScriptService.MyScript
local result = decompiler:DecompileInstance(script)

if result.source then
    print("Source code:")
    print(result.source)
    
    -- Analyze the source
    local analysis = gktools.Analyzer:AnalyzeSource(result.source)
    print("Complexity:", analysis.complexity)
    print("Vulnerabilities:", #analysis.vulnerabilities)
end
```

### Batch Analysis
```lua
-- Analyze all scripts in a service
local function analyzeService(service)
    local results = {}
    
    for _, child in ipairs(service:GetChildren()) do
        if child:IsA("Script") or child:IsA("LocalScript") or child:IsA("ModuleScript") then
            local result = gktools.Decompiler:DecompileInstance(child)
            if result.source then
                local analysis = gktools.Analyzer:AnalyzeSource(result.source)
                results[child.Name] = {
                    source = result.source,
                    complexity = analysis.complexity,
                    vulnerabilities = analysis.vulnerabilities
                }
            end
        end
    end
    
    return results
end

-- Analyze ServerScriptService
local results = analyzeService(game.ServerScriptService)
for scriptName, data in pairs(results) do
    print(`{scriptName}: {data.complexity} complexity, {#data.vulnerabilities} issues`)
end
```

### Security Analysis
```lua
-- Scan for security vulnerabilities
local function scanForVulnerabilities()
    local vulnerabilities = {}
    
    local services = {game.ServerScriptService, game.StarterPlayer, game.StarterGui}
    
    for _, service in ipairs(services) do
        for _, child in ipairs(service:GetDescendants()) do
            if child:IsA("Script") or child:IsA("LocalScript") or child:IsA("ModuleScript") then
                local result = gktools.Decompiler:DecompileInstance(child)
                if result.source then
                    local analysis = gktools.Analyzer:AnalyzeSource(result.source)
                    if #analysis.vulnerabilities > 0 then
                        vulnerabilities[child:GetFullName()] = analysis.vulnerabilities
                    end
                end
            end
        end
    end
    
    return vulnerabilities
end

local vulns = scanForVulnerabilities()
for scriptPath, issues in pairs(vulns) do
    print(`Security issues in {scriptPath}:`)
    for _, issue in ipairs(issues) do
        print(`  - {issue.type}: {issue.description} (Severity: {issue.severity})`)
    end
end
```

## Troubleshooting

### Common Issues

#### "Access Denied" Errors
**Cause**: Insufficient permissions or security restrictions
**Solution**: 
- Lower security level in configuration
- Ensure script has appropriate permissions
- Check if running in correct context (server vs client)

#### UI Not Appearing
**Cause**: CoreGui access denied or PlayerGui issues
**Solution**:
- The loader automatically falls back to PlayerGui
- Ensure no other scripts are interfering
- Try restarting the script

#### Decompilation Failures
**Cause**: Script protection or access restrictions
**Solution**:
- Some scripts may be protected and cannot be decompiled
- Try different extraction methods
- Check script permissions and context

#### Performance Issues
**Cause**: Large game trees or complex analysis
**Solution**:
- Reduce `maxRecursionDepth` in configuration
- Use higher security levels for better performance
- Analyze smaller sections at a time

### Debug Mode
```lua
-- Enable detailed logging
gktools.config.debugMode = true

-- This will provide detailed information about:
-- - Module loading process
-- - Decompilation attempts
-- - Security checks
-- - UI events
```

## Security Considerations

### Safe Usage Guidelines
1. **Always use appropriate security levels** for your environment
2. **Monitor resource usage** during analysis
3. **Review threat reports** regularly
4. **Validate external inputs** before analysis
5. **Use sandboxed execution** for untrusted code

### Detected Threats
GKTools automatically detects and reports:
- Dynamic code execution (`loadstring`)
- Metatable manipulation (`getrawmetatable`, `setrawmetatable`)
- Environment manipulation (`getfenv`, `setfenv`)
- Debug library usage
- Infinite loops and high complexity code

### Best Practices
- Start with RESTRICTED security level
- Gradually increase permissions as needed
- Regularly review security reports
- Keep resource limits reasonable
- Monitor for suspicious patterns

## API Reference

### Core Classes
- `GKTools`: Main controller class
- `CoreDecompiler`: Source extraction and analysis
- `CoreAnalyzer`: Code quality and security analysis
- `UIFramework`: Modern interface system
- `SecuritySandbox`: Safe execution environment
- `ReflectionUtils`: Advanced introspection utilities

### Key Methods
```lua
-- Initialization
gktools:Initialize(config?)

-- Decompilation
gktools.Decompiler:DecompileInstance(instance)
gktools.Decompiler:AnalyzeGameTree()

-- Analysis
gktools.Analyzer:AnalyzeSource(source, context?)

-- Security
gktools.SecuritySandbox:CreateSandbox(code, config?)
gktools.SecuritySandbox:ExecuteInSandbox(code, environment)

-- Reflection
gktools.ReflectionUtils:InspectObject(obj, maxDepth?)
gktools.ReflectionUtils:GetProperty(obj, propertyPath)
```

## Contributing

### Development Setup
1. Clone the repository
2. Make changes to source files in `src/`
3. Test with the example scripts in `examples/`
4. Update documentation as needed

### Code Style
- Use `--!strict` mode for all files
- Follow Luau type annotations
- Maintain consistent indentation
- Add comprehensive comments for complex logic

## License

MIT License - Advanced Research & Educational Use

This project is intended for educational and research purposes. Use responsibly and in accordance with Roblox Terms of Service.

## Support

For issues, questions, or contributions:
1. Check the troubleshooting section
2. Review existing documentation
3. Create detailed issue reports
4. Provide reproduction steps

---

**GKTools** - Advancing the state of Roblox game analysis and decompilation through sophisticated Luau techniques and modern interface design.