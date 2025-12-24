# GKTools API Documentation

## Overview
GKTools is an advanced Roblox game source code analysis and decompilation suite that provides unprecedented access to game internals through sophisticated Luau techniques and metaprogramming.

## Core Architecture

### Main Components

#### 1. Core Decompiler (`src/core/decompiler.lua`)
Advanced bytecode analysis and source reconstruction engine.

**Key Features:**
- Multiple source extraction methods
- Bytecode pattern analysis
- Advanced metatable manipulation
- Memory layout analysis

**API Methods:**
```lua
-- Initialize decompiler
decompiler:Initialize(config)

-- Extract source from instance
local source = decompiler:ExtractSource(instance)

-- Analyze complete game tree
local gameTree = decompiler:AnalyzeGameTree()

-- Decompile specific instance
local result = decompiler:DecompileInstance(instance)
```

#### 2. Core Analyzer (`src/core/analyzer.lua`)
Sophisticated code analysis and pattern recognition system.

**Key Features:**
- Security vulnerability detection
- Code complexity analysis
- Pattern matching
- Performance metrics

**API Methods:**
```lua
-- Analyze source code
local analysis = analyzer:AnalyzeSource(source, context)

-- Get complexity metrics
local complexity = analyzer:CalculateComplexity(source)

-- Detect security issues
local vulnerabilities = analyzer:DetectVulnerabilities(source)
```

#### 3. UI Framework (`src/ui/framework.lua`)
Modern interface system with advanced features.

**Key Features:**
- Dynamic component system
- Context menu support
- Theme management
- Responsive layouts

**API Methods:**
```lua
-- Initialize UI
ui:Initialize(config)

-- Create main interface
ui:CreateMainInterface()

-- Show context menu
ui:ShowContextMenu(position)
```

#### 4. UI Components (`src/ui/components.lua`)
Advanced interactive components for the interface.

**Key Features:**
- Tree view components
- Code editor with syntax highlighting
- Modal dialogs
- Progress indicators

**API Methods:**
```lua
-- Create tree view
local treeView = components:CreateTreeView(parent, config)

-- Create code editor
local editor = components:CreateCodeEditor(parent)

-- Create modal dialog
local modal = components:CreateModal(title, content, size)
```

#### 5. Bytecode Analysis (`src/analysis/bytecode.lua`)
Advanced Luau bytecode analysis and reconstruction.

**Key Features:**
- Instruction decoding
- Control flow analysis
- Data flow analysis
- Source reconstruction

**API Methods:**
```lua
-- Analyze bytecode
local instructions = bytecode:AnalyzeBytecode(source)

-- Build control flow graph
local cfg = bytecode:BuildControlFlowGraph(instructions)

-- Reconstruct source
local reconstructed = bytecode:ReconstructSource(instructions)
```

#### 6. Security Sandbox (`src/security/sandbox.lua`)
Advanced security and isolation system.

**Key Features:**
- Code execution sandboxing
- Permission management
- Resource monitoring
- Threat detection

**API Methods:**
```lua
-- Create sandbox
local sandbox = security:CreateSandbox(code, config)

-- Execute in sandbox
local result = security:ExecuteInSandbox(code, environment)

-- Get security report
local report = security:GetSecurityReport()
```

#### 7. Reflection Utils (`src/utils/reflection.lua`)
Advanced runtime introspection and manipulation.

**Key Features:**
- Deep object inspection
- Metatable analysis
- Function introspection
- Dynamic property access

**API Methods:**
```lua
-- Inspect object
local info = reflection:InspectObject(obj, maxDepth)

-- Get property
local value = reflection:GetProperty(obj, "path.to.property")

-- Set property
local success = reflection:SetProperty(obj, "path.to.property", value)
```

## Configuration

### Decompiler Config
```lua
local config = {
    enableMetatableHooks = true,
    maxRecursionDepth = 50,
    enableBytecodeAnalysis = true,
    securityLevel = "MEDIUM", -- "LOW" | "MEDIUM" | "HIGH"
    uiTheme = "AUTO" -- "DARK" | "LIGHT" | "AUTO"
}
```

### Security Levels

#### RESTRICTED
- Limited global access
- Blocked dangerous functions
- Strict resource limits
- Full monitoring enabled

#### NORMAL (Default)
- Standard global access
- Some functions blocked
- Moderate resource limits
- Monitoring enabled

#### ELEVATED
- Full global access
- No function restrictions
- High resource limits
- Monitoring optional

## Usage Examples

### Basic Usage
```lua
-- Load and initialize GKTools
local GKTools = loadstring(game:HttpGet("path/to/gktools"))()
local gktools = GKTools()

-- Initialize with default config
gktools:Initialize()

-- The UI will automatically appear
```

### Advanced Configuration
```lua
local GKTools = loadstring(game:HttpGet("path/to/gktools"))()
local gktools = GKTools()

-- Custom configuration
local config = {
    enableMetatableHooks = true,
    maxRecursionDepth = 100,
    enableBytecodeAnalysis = true,
    securityLevel = "HIGH",
    uiTheme = "DARK"
}

gktools:Initialize(config)
```

### Programmatic Analysis
```lua
-- Get decompiler instance
local decompiler = gktools.Decompiler

-- Analyze specific script
local script = game.ServerScriptService.SomeScript
local result = decompiler:DecompileInstance(script)

if result.source then
    print("Decompiled source:")
    print(result.source)
else
    print("Could not decompile script")
end

-- Analyze entire game tree
local gameTree = decompiler:AnalyzeGameTree()
for serviceName, instances in pairs(gameTree) do
    print(`Found {#instances} instances in {serviceName}`)
end
```

### Security Analysis
```lua
-- Get analyzer instance
local analyzer = gktools.Analyzer

-- Analyze source code
local source = [[
    local function dangerousCode()
        loadstring("print('Hello')")()
        getrawmetatable(game).__index = function() end
    end
]]

local analysis = analyzer:AnalyzeSource(source)

print(`Complexity: {analysis.complexity}`)
print(`Vulnerabilities found: {#analysis.vulnerabilities}`)

for _, vulnerability in ipairs(analysis.vulnerabilities) do
    print(`- {vulnerability.type}: {vulnerability.description}`)
end
```

### Custom UI Integration
```lua
-- Access UI framework
local ui = gktools.UI

-- Create custom modal
local customContent = Instance.new("TextLabel")
customContent.Text = "Custom content here"
customContent.Size = UDim2.new(1, 0, 1, 0)

local modal = gktools.Components:CreateModal(
    "Custom Dialog",
    customContent,
    UDim2.new(0, 500, 0, 400)
)
```

## Event System

### UI Events
```lua
-- Listen for node selection
gktools.UI.OnNodeSelected = function(nodeData)
    print(`Selected: {nodeData.text}`)
    
    -- Load source in editor
    if nodeData.source then
        gktools.UI.codeArea.Text = nodeData.source
    end
end

-- Listen for analysis completion
gktools.Analyzer.OnAnalysisComplete = function(result)
    print("Analysis completed")
    -- Update UI with results
end
```

### Security Events
```lua
-- Listen for security threats
gktools.SecuritySandbox.OnThreatDetected = function(threat)
    warn(`Security threat: {threat.description}`)
end
```

## Advanced Features

### Custom Decompilation Methods
```lua
-- Add custom extraction method
gktools.Decompiler.ExtractViaCustomMethod = function(self, instance)
    -- Custom implementation
    return customSource
end

-- Register method
table.insert(gktools.Decompiler.extractionMethods, 
    gktools.Decompiler.ExtractViaCustomMethod)
```

### Plugin System
```lua
-- Create plugin
local MyPlugin = {}

function MyPlugin:Initialize(gktools)
    self.gktools = gktools
    
    -- Add custom functionality
    gktools.UI:AddToolbarButton({
        text = "My Plugin",
        icon = "🔧",
        action = function()
            self:DoSomething()
        end
    })
end

function MyPlugin:DoSomething()
    print("Plugin functionality")
end

-- Register plugin
gktools:RegisterPlugin(MyPlugin)
```

## Performance Considerations

### Caching
- All analysis results are cached automatically
- Cache keys are generated based on content hashes
- Cache size is limited to prevent memory issues

### Resource Limits
- Configurable execution time limits
- Memory usage monitoring
- Call depth protection
- Iteration count limits

### Optimization Tips
1. Use appropriate security levels
2. Limit recursion depth for large hierarchies
3. Enable caching for repeated operations
4. Monitor resource usage in production

## Troubleshooting

### Common Issues

#### "Module compilation failed"
- Check syntax in custom modules
- Verify all dependencies are available
- Review security sandbox restrictions

#### "Maximum execution time exceeded"
- Increase resource limits in config
- Optimize complex analysis operations
- Use lower security levels for performance

#### "Access denied" errors
- Check security level configuration
- Verify required permissions
- Review blocked function lists

### Debug Mode
```lua
-- Enable debug logging
gktools.config.debugMode = true

-- This will provide detailed logging of all operations
```

## Security Considerations

### Safe Usage
- Always use appropriate security levels
- Monitor resource usage
- Review threat reports regularly
- Validate all external inputs

### Threat Detection
- Automatic detection of dangerous patterns
- Real-time monitoring of code execution
- Comprehensive logging of security events
- Configurable response policies

## License
MIT License - Advanced Research & Educational Use

For more information and updates, visit the GKTools repository.