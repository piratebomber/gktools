--!strict
--[[
    GKTools Usage Example
    Demonstrates advanced decompilation and analysis capabilities
]]

-- Load GKTools
local GKTools = loadstring(game:HttpGet("https://raw.githubusercontent.com/example/gktools/main/src/init.lua"))()

-- Create GKTools instance
local gktools = GKTools()

-- Advanced configuration
local config = {
    enableMetatableHooks = true,
    maxRecursionDepth = 100,
    enableBytecodeAnalysis = true,
    securityLevel = "MEDIUM", -- "LOW" | "MEDIUM" | "HIGH"
    uiTheme = "DARK" -- "DARK" | "LIGHT" | "AUTO"
}

-- Initialize with custom config
gktools:Initialize(config)

-- Example 1: Basic decompilation
print("=== Basic Decompilation Example ===")
local testScript = game.ServerScriptService:FindFirstChild("TestScript")
if testScript then
    local result = gktools.Decompiler:DecompileInstance(testScript)
    if result.source then
        print("Decompiled source:")
        print(result.source)
    else
        print("Could not decompile script")
    end
end

-- Example 2: Game tree analysis
print("\n=== Game Tree Analysis ===")
local gameTree = gktools.Decompiler:AnalyzeGameTree()
for serviceName, instances in pairs(gameTree) do
    print(`{serviceName}: {#instances} instances`)
end

-- Example 3: Security analysis
print("\n=== Security Analysis ===")
local dangerousCode = [[
    local function exploit()
        loadstring("print('Dangerous code')")()
        getrawmetatable(game).__index = function() return nil end
    end
    exploit()
]]

local analysis = gktools.Analyzer:AnalyzeSource(dangerousCode)
print(`Code complexity: {analysis.complexity}`)
print(`Vulnerabilities found: {#analysis.vulnerabilities}`)

for _, vulnerability in ipairs(analysis.vulnerabilities) do
    print(`- {vulnerability.type}: {vulnerability.description} (Severity: {vulnerability.severity})`)
end

-- Example 4: Bytecode analysis
print("\n=== Bytecode Analysis ===")
local simpleCode = [[
    local x = 5
    local y = 10
    return x + y
]]

local instructions = gktools.BytecodeAnalysis:AnalyzeBytecode(simpleCode)
if instructions then
    print(`Found {#instructions} bytecode instructions`)
    for i, instruction in ipairs(instructions) do
        print(`{i}: {instruction.opname} {table.concat(instruction.operands, ", ")}`)
    end
end

-- Example 5: Reflection utilities
print("\n=== Reflection Example ===")
local workspace = game.Workspace
local info = gktools.ReflectionUtils:InspectObject(workspace, 2)
print(`Workspace type: {info.type}`)
print(`Properties found: {#info.properties}`)
print(`Methods found: {#info.methods}`)
print(`Children found: {#info.children}`)

-- Example 6: Security sandbox
print("\n=== Security Sandbox Example ===")
local sandbox = gktools.SecuritySandbox:CreateSandbox("print('Hello from sandbox')")
local result = gktools.SecuritySandbox:ExecuteInSandbox("print('Safe execution')", sandbox)
print(`Sandbox execution result: {tostring(result)}`)

-- Example 7: Advanced property access
print("\n=== Advanced Property Access ===")
local playerName = gktools.ReflectionUtils:GetProperty(game, "Players.LocalPlayer.Name")
if playerName then
    print(`Local player name: {playerName}`)
end

-- Example 8: Custom analysis
print("\n=== Custom Analysis ===")
local function analyzeAllScripts()
    local scriptCount = 0
    local totalLines = 0
    
    local function analyzeContainer(container)
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("Script") or child:IsA("LocalScript") or child:IsA("ModuleScript") then
                scriptCount = scriptCount + 1
                
                local result = gktools.Decompiler:DecompileInstance(child)
                if result.source then
                    local lines = result.source:split("\n")
                    totalLines = totalLines + #lines
                    
                    local analysis = gktools.Analyzer:AnalyzeSource(result.source)
                    if #analysis.vulnerabilities > 0 then
                        print(`Security issues in {child.Name}: {#analysis.vulnerabilities}`)
                    end
                end
            end
            
            -- Recurse into children
            analyzeContainer(child)
        end
    end
    
    -- Analyze all services
    analyzeContainer(game.ServerScriptService)
    analyzeContainer(game.StarterPlayer)
    analyzeContainer(game.StarterGui)
    
    print(`Total scripts analyzed: {scriptCount}`)
    print(`Total lines of code: {totalLines}`)
end

analyzeAllScripts()

print("\n=== GKTools Example Complete ===")
print("The UI should now be visible with the game tree loaded.")
print("You can interact with the interface to explore and decompile scripts.")