--!strict
--[[
    GKTools Loader Script
    Single-file loader for easy deployment and execution
    
    Usage:
    loadstring(game:HttpGet("path/to/loader.lua"))()
]]

-- Embedded GKTools source code
local GKTOOLS_SOURCE = [=[
--!strict
local GKTools = {}
GKTools.__index = GKTools

-- Configuration types
export type DecompilerConfig = {
    enableMetatableHooks: boolean,
    maxRecursionDepth: number,
    enableBytecodeAnalysis: boolean,
    securityLevel: "LOW" | "MEDIUM" | "HIGH",
    uiTheme: "DARK" | "LIGHT" | "AUTO"
}

-- Module cache
local ModuleCache = {}

-- Advanced metatable manipulation
local function getAdvancedMetatable(obj)
    local success, metatable = pcall(function()
        return getrawmetatable(obj)
    end)
    
    if success and metatable then
        local hooks = {}
        for key, value in pairs(metatable) do
            if type(value) == "function" then
                hooks[key] = value
            end
        end
        return metatable, hooks
    end
    
    return nil, {}
end

-- Dynamic module loading
function GKTools:LoadModule(moduleName)
    if ModuleCache[moduleName] then
        return ModuleCache[moduleName]
    end
    
    local moduleSource = self:GetModuleSource(moduleName)
    if not moduleSource then
        error("Failed to load module: " .. moduleName)
    end
    
    local sandbox = {
        print = print, warn = warn, error = error, type = type, typeof = typeof,
        pairs = pairs, ipairs = ipairs, next = next, getmetatable = getmetatable,
        setmetatable = setmetatable, rawget = rawget, rawset = rawset,
        tonumber = tonumber, tostring = tostring, string = string, table = table,
        math = math, coroutine = coroutine, game = game, workspace = workspace,
        script = script, getrawmetatable = getrawmetatable, setrawmetatable = setrawmetatable,
        getfenv = getfenv, setfenv = setfenv, loadstring = loadstring, GKTools = self
    }
    
    local compiledModule, compileError = loadstring(moduleSource)
    if not compiledModule then
        error("Module compilation failed for " .. moduleName .. ": " .. compileError)
    end
    
    setfenv(compiledModule, sandbox)
    
    local success, result = pcall(compiledModule)
    if not success then
        error("Module execution failed for " .. moduleName .. ": " .. result)
    end
    
    ModuleCache[moduleName] = result
    return result
end

-- Module source definitions
function GKTools:GetModuleSource(moduleName)
    local modules = {
        ["core.decompiler"] = [[
local CoreDecompiler = {}
CoreDecompiler.__index = CoreDecompiler

function CoreDecompiler:Initialize(config)
    self.config = config
    self.cache = {}
end

function CoreDecompiler:ExtractSource(instance)
    local methods = {
        function() return rawget(instance, "Source") end,
        function() return instance.Source end,
        function() 
            local mt = getrawmetatable(instance)
            return mt and mt.__index and mt.__index(instance, "Source")
        end
    }
    
    for _, method in ipairs(methods) do
        local success, result = pcall(method)
        if success and type(result) == "string" and #result > 0 then
            return result
        end
    end
    
    return nil
end

function CoreDecompiler:DecompileInstance(instance)
    return {
        source = self:ExtractSource(instance),
        metadata = {
            className = instance.ClassName,
            name = instance.Name,
            parent = instance.Parent and instance.Parent.Name or "nil"
        }
    }
end

function CoreDecompiler:AnalyzeGameTree()
    local gameTree = {}
    local services = {
        "ServerScriptService", "ServerStorage", "StarterGui", 
        "StarterPlayer", "Players", "Workspace", "ReplicatedStorage"
    }
    
    for _, serviceName in ipairs(services) do
        local success, service = pcall(function()
            return game:GetService(serviceName)
        end)
        
        if success and service then
            gameTree[serviceName] = self:AnalyzeServiceTree(service)
        end
    end
    
    return gameTree
end

function CoreDecompiler:AnalyzeServiceTree(service)
    local instances = {}
    
    local function analyzeRecursive(parent, depth)
        if depth > 10 then return end
        
        table.insert(instances, parent)
        
        for _, child in ipairs(parent:GetChildren()) do
            analyzeRecursive(child, depth + 1)
        end
    end
    
    analyzeRecursive(service, 0)
    return instances
end

return setmetatable({}, CoreDecompiler)
]],
        ["core.analyzer"] = [[
local CoreAnalyzer = {}
CoreAnalyzer.__index = CoreAnalyzer

function CoreAnalyzer:Initialize(config)
    self.config = config
end

function CoreAnalyzer:AnalyzeSource(source)
    local vulnerabilities = {}
    local patterns = {
        {pattern = "loadstring", severity = "HIGH", description = "Dynamic code execution"},
        {pattern = "getrawmetatable", severity = "MEDIUM", description = "Metatable access"},
        {pattern = "setrawmetatable", severity = "HIGH", description = "Metatable modification"}
    }
    
    for _, patternInfo in ipairs(patterns) do
        if source:find(patternInfo.pattern) then
            table.insert(vulnerabilities, {
                type = patternInfo.pattern,
                severity = patternInfo.severity,
                description = patternInfo.description
            })
        end
    end
    
    return {
        complexity = math.max(1, #source:split("\n")),
        vulnerabilities = vulnerabilities,
        patterns = {},
        metrics = {linesOfCode = #source:split("\n")},
        suggestions = {}
    }
end

return setmetatable({}, CoreAnalyzer)
]],
        ["ui.framework"] = [[
local UIFramework = {}
UIFramework.__index = UIFramework

local THEMES = {
    DARK = {
        colors = {
            background = Color3.fromRGB(30, 30, 30),
            surface = Color3.fromRGB(45, 45, 45),
            primary = Color3.fromRGB(100, 150, 255),
            text = Color3.fromRGB(255, 255, 255),
            textSecondary = Color3.fromRGB(200, 200, 200),
            border = Color3.fromRGB(70, 70, 70),
            error = Color3.fromRGB(255, 100, 100)
        },
        fonts = {primary = Enum.Font.Gotham, secondary = Enum.Font.GothamMedium, monospace = Enum.Font.RobotoMono},
        sizes = {titleBar = 30, toolbar = 40, sidebar = 250}
    }
}

function UIFramework:Initialize(config)
    self.config = config
    self.theme = THEMES.DARK
    self:CreateMainInterface()
end

function UIFramework:CreateMainInterface()
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "GKToolsUI"
    self.screenGui.ResetOnSpawn = false
    
    local success = pcall(function()
        self.screenGui.Parent = game:GetService("CoreGui")
    end)
    
    if not success then
        self.screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    
    self.mainWindow = Instance.new("Frame")
    self.mainWindow.Name = "MainWindow"
    self.mainWindow.Size = UDim2.new(0, 1200, 0, 800)
    self.mainWindow.Position = UDim2.new(0.5, -600, 0.5, -400)
    self.mainWindow.BackgroundColor3 = self.theme.colors.surface
    self.mainWindow.BorderSizePixel = 0
    self.mainWindow.Parent = self.screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = self.mainWindow
    
    self:CreateTitleBar()
    self:CreateSidebar()
    self:CreateMainContent()
    self:CreateStatusBar()
end

function UIFramework:CreateTitleBar()
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = self.theme.colors.primary
    titleBar.BorderSizePixel = 0
    titleBar.Parent = self.mainWindow
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -100, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "GKTools - Advanced Decompiler"
    titleText.TextColor3 = self.theme.colors.text
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Font = self.theme.fonts.secondary
    titleText.TextSize = 14
    titleText.Parent = titleBar
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 25, 0, 25)
    closeButton.Position = UDim2.new(1, -30, 0, 2.5)
    closeButton.BackgroundColor3 = self.theme.colors.error
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextColor3 = self.theme.colors.text
    closeButton.Font = self.theme.fonts.primary
    closeButton.TextSize = 16
    closeButton.Parent = titleBar
    
    closeButton.MouseButton1Click:Connect(function()
        self.screenGui:Destroy()
    end)
    
    self:MakeDraggable(titleBar, self.mainWindow)
end

function UIFramework:CreateSidebar()
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 250, 1, -55)
    sidebar.Position = UDim2.new(0, 0, 0, 30)
    sidebar.BackgroundColor3 = self.theme.colors.surface
    sidebar.BorderSizePixel = 0
    sidebar.Parent = self.mainWindow
    
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = self.theme.colors.background
    header.BorderSizePixel = 0
    header.Text = "Game Tree"
    header.TextColor3 = self.theme.colors.text
    header.Font = self.theme.fonts.secondary
    header.TextSize = 14
    header.Parent = sidebar
    
    self.treeView = Instance.new("ScrollingFrame")
    self.treeView.Name = "TreeView"
    self.treeView.Size = UDim2.new(1, 0, 1, -30)
    self.treeView.Position = UDim2.new(0, 0, 0, 30)
    self.treeView.BackgroundTransparency = 1
    self.treeView.BorderSizePixel = 0
    self.treeView.ScrollBarThickness = 8
    self.treeView.Parent = sidebar
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 2)
    layout.Parent = self.treeView
    
    self:RefreshGameTree()
end

function UIFramework:CreateMainContent()
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -250, 1, -55)
    content.Position = UDim2.new(0, 250, 0, 30)
    content.BackgroundColor3 = self.theme.colors.background
    content.BorderSizePixel = 0
    content.Parent = self.mainWindow
    
    local editor = Instance.new("ScrollingFrame")
    editor.Name = "CodeEditor"
    editor.Size = UDim2.new(1, 0, 1, 0)
    editor.BackgroundColor3 = self.theme.colors.background
    editor.BorderSizePixel = 0
    editor.ScrollBarThickness = 12
    editor.Parent = content
    
    local lineNumbers = Instance.new("TextLabel")
    lineNumbers.Name = "LineNumbers"
    lineNumbers.Size = UDim2.new(0, 50, 1, 0)
    lineNumbers.BackgroundColor3 = self.theme.colors.surface
    lineNumbers.BorderSizePixel = 0
    lineNumbers.Text = "1\n2\n3\n4\n5"
    lineNumbers.TextColor3 = self.theme.colors.textSecondary
    lineNumbers.TextXAlignment = Enum.TextXAlignment.Right
    lineNumbers.TextYAlignment = Enum.TextYAlignment.Top
    lineNumbers.Font = self.theme.fonts.monospace
    lineNumbers.TextSize = 12
    lineNumbers.Parent = editor
    
    self.codeArea = Instance.new("TextBox")
    self.codeArea.Name = "CodeArea"
    self.codeArea.Size = UDim2.new(1, -55, 1, 0)
    self.codeArea.Position = UDim2.new(0, 55, 0, 0)
    self.codeArea.BackgroundTransparency = 1
    self.codeArea.BorderSizePixel = 0
    self.codeArea.Text = "-- Select a script from the game tree to view its source code"
    self.codeArea.TextColor3 = self.theme.colors.text
    self.codeArea.TextXAlignment = Enum.TextXAlignment.Left
    self.codeArea.TextYAlignment = Enum.TextYAlignment.Top
    self.codeArea.Font = self.theme.fonts.monospace
    self.codeArea.TextSize = 12
    self.codeArea.MultiLine = true
    self.codeArea.ClearTextOnFocus = false
    self.codeArea.Parent = editor
    
    self.lineNumbers = lineNumbers
end

function UIFramework:CreateStatusBar()
    local statusBar = Instance.new("Frame")
    statusBar.Name = "StatusBar"
    statusBar.Size = UDim2.new(1, 0, 0, 25)
    statusBar.Position = UDim2.new(0, 0, 1, -25)
    statusBar.BackgroundColor3 = self.theme.colors.surface
    statusBar.BorderSizePixel = 0
    statusBar.Parent = self.mainWindow
    
    self.statusText = Instance.new("TextLabel")
    self.statusText.Size = UDim2.new(1, -10, 1, 0)
    self.statusText.Position = UDim2.new(0, 5, 0, 0)
    self.statusText.BackgroundTransparency = 1
    self.statusText.Text = "Ready - GKTools Advanced Decompiler"
    self.statusText.TextColor3 = self.theme.colors.textSecondary
    self.statusText.TextXAlignment = Enum.TextXAlignment.Left
    self.statusText.Font = self.theme.fonts.primary
    self.statusText.TextSize = 11
    self.statusText.Parent = statusBar
end

function UIFramework:RefreshGameTree()
    for _, child in ipairs(self.treeView:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    local services = {
        {name = "ServerScriptService", icon = "📜"},
        {name = "ServerStorage", icon = "📦"},
        {name = "StarterGui", icon = "🖥️"},
        {name = "StarterPlayer", icon = "👤"},
        {name = "Players", icon = "👥"},
        {name = "Workspace", icon = "🌍"}
    }
    
    for i, serviceInfo in ipairs(services) do
        local success, service = pcall(function()
            return game:GetService(serviceInfo.name)
        end)
        
        if success and service then
            self:CreateServiceNode(service, serviceInfo.icon, i)
        end
    end
end

function UIFramework:CreateServiceNode(service, icon, order)
    local serviceFrame = Instance.new("Frame")
    serviceFrame.Name = service.Name
    serviceFrame.Size = UDim2.new(1, 0, 0, 25)
    serviceFrame.BackgroundTransparency = 1
    serviceFrame.LayoutOrder = order
    serviceFrame.Parent = self.treeView
    
    local expandButton = Instance.new("TextButton")
    expandButton.Size = UDim2.new(0, 15, 0, 15)
    expandButton.Position = UDim2.new(0, 5, 0.5, -7.5)
    expandButton.BackgroundColor3 = self.theme.colors.primary
    expandButton.BorderSizePixel = 0
    expandButton.Text = "+"
    expandButton.TextColor3 = self.theme.colors.text
    expandButton.Font = self.theme.fonts.primary
    expandButton.TextSize = 10
    expandButton.Parent = serviceFrame
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 20, 0, 20)
    iconLabel.Position = UDim2.new(0, 25, 0.5, -10)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextColor3 = self.theme.colors.primary
    iconLabel.Font = self.theme.fonts.primary
    iconLabel.TextSize = 14
    iconLabel.Parent = serviceFrame
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -50, 1, 0)
    nameLabel.Position = UDim2.new(0, 50, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = service.Name
    nameLabel.TextColor3 = self.theme.colors.text
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Font = self.theme.fonts.primary
    nameLabel.TextSize = 12
    nameLabel.Parent = serviceFrame
    
    local expanded = false
    expandButton.MouseButton1Click:Connect(function()
        expanded = not expanded
        expandButton.Text = expanded and "-" or "+"
        
        if expanded then
            self:ExpandServiceNode(service, serviceFrame)
        else
            self:CollapseServiceNode(serviceFrame)
        end
    end)
end

function UIFramework:ExpandServiceNode(service, parentFrame)
    local children = service:GetChildren()
    
    for i, child in ipairs(children) do
        self:CreateChildNode(child, parentFrame, 1, i)
    end
end

function UIFramework:CreateChildNode(instance, parentFrame, depth, order)
    local childFrame = Instance.new("Frame")
    childFrame.Name = instance.Name .. "_Child"
    childFrame.Size = UDim2.new(1, 0, 0, 20)
    childFrame.BackgroundTransparency = 1
    childFrame.LayoutOrder = parentFrame.LayoutOrder + order * 0.01
    childFrame.Parent = self.treeView
    
    local indent = depth * 20
    local icon = self:GetClassIcon(instance.ClassName)
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 15, 0, 15)
    iconLabel.Position = UDim2.new(0, 25 + indent, 0.5, -7.5)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextColor3 = self.theme.colors.text
    iconLabel.Font = self.theme.fonts.primary
    iconLabel.TextSize = 10
    iconLabel.Parent = childFrame
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -(45 + indent), 1, 0)
    nameLabel.Position = UDim2.new(0, 45 + indent, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = instance.Name
    nameLabel.TextColor3 = self.theme.colors.text
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Font = self.theme.fonts.primary
    nameLabel.TextSize = 10
    nameLabel.Parent = childFrame
    
    nameLabel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:SelectNode(instance)
        end
    end)
end

function UIFramework:CollapseServiceNode(parentFrame)
    local parentOrder = parentFrame.LayoutOrder
    
    for _, child in ipairs(self.treeView:GetChildren()) do
        if child:IsA("Frame") and child.LayoutOrder > parentOrder and child.LayoutOrder < parentOrder + 1 then
            child:Destroy()
        end
    end
end

function UIFramework:SelectNode(instance)
    self.statusText.Text = "Selected: " .. instance.Name .. " (" .. instance.ClassName .. ")"
    
    if instance:IsA("Script") or instance:IsA("LocalScript") or instance:IsA("ModuleScript") then
        self:DecompileScript(instance)
    else
        self:DisplayInstanceInfo(instance)
    end
end

function UIFramework:DecompileScript(script)
    self.statusText.Text = "Decompiling " .. script.Name .. "..."
    
    if self.gktools and self.gktools.Decompiler then
        local result = self.gktools.Decompiler:DecompileInstance(script)
        
        if result.source then
            self:DisplaySource(result.source)
            self.statusText.Text = "Decompiled " .. script.Name .. " successfully"
        else
            self:DisplaySource("-- Could not decompile " .. script.Name .. "\n-- Reason: No source available")
            self.statusText.Text = "Failed to decompile " .. script.Name
        end
    else
        self:DisplaySource("-- Decompiler not available")
    end
end

function UIFramework:DisplaySource(source)
    self.codeArea.Text = source
    
    local lines = source:split("\n")
    local lineNumbers = {}
    for i = 1, #lines do
        table.insert(lineNumbers, tostring(i))
    end
    self.lineNumbers.Text = table.concat(lineNumbers, "\n")
end

function UIFramework:DisplayInstanceInfo(instance)
    local info = {
        "-- Instance Information",
        "-- Name: " .. instance.Name,
        "-- ClassName: " .. instance.ClassName,
        "-- Parent: " .. (instance.Parent and instance.Parent.Name or "nil"),
        "-- Children: " .. #instance:GetChildren()
    }
    
    self:DisplaySource(table.concat(info, "\n"))
end

function UIFramework:GetClassIcon(className)
    local icons = {
        Script = "📜", LocalScript = "📄", ModuleScript = "📋",
        Part = "🧱", Frame = "🖼️", TextLabel = "📝",
        TextButton = "🔘", Folder = "📁", Model = "🏗️"
    }
    return icons[className] or "📄"
end

function UIFramework:MakeDraggable(handle, target)
    local dragging = false
    local dragStart = Vector2.new()
    local startPos = UDim2.new()
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

return setmetatable({}, UIFramework)
]],
        ["analysis.bytecode"] = [[
local BytecodeAnalysis = {}
BytecodeAnalysis.__index = BytecodeAnalysis

function BytecodeAnalysis:Initialize(config)
    self.config = config
end

function BytecodeAnalysis:AnalyzeBytecode(source)
    return {}
end

return setmetatable({}, BytecodeAnalysis)
]],
        ["security.sandbox"] = [[
local SecuritySandbox = {}
SecuritySandbox.__index = SecuritySandbox

function SecuritySandbox:Initialize(config)
    self.config = config
end

function SecuritySandbox:CreateSandbox(code, config)
    return {globals = {print = print}}
end

function SecuritySandbox:ExecuteInSandbox(code, environment)
    return pcall(loadstring(code))
end

return setmetatable({}, SecuritySandbox)
]],
        ["utils.reflection"] = [[
local ReflectionUtils = {}
ReflectionUtils.__index = ReflectionUtils

function ReflectionUtils:Initialize(config)
    self.config = config
end

function ReflectionUtils:InspectObject(obj, maxDepth)
    return {
        type = typeof(obj),
        properties = {},
        methods = {},
        children = {}
    }
end

function ReflectionUtils:GetProperty(obj, path)
    local parts = path:split(".")
    local current = obj
    
    for _, part in ipairs(parts) do
        if current == nil then return nil end
        local success, value = pcall(function()
            return current[part]
        end)
        if not success then return nil end
        current = value
    end
    
    return current
end

return setmetatable({}, ReflectionUtils)
]]
    }
    
    return modules[moduleName]
end

-- Initialize system
function GKTools:Initialize(config)
    self.config = config or {
        enableMetatableHooks = true,
        maxRecursionDepth = 50,
        enableBytecodeAnalysis = true,
        securityLevel = "MEDIUM",
        uiTheme = "DARK"
    }
    
    -- Load modules
    self.Decompiler = self:LoadModule("core.decompiler")
    self.Analyzer = self:LoadModule("core.analyzer")
    self.UI = self:LoadModule("ui.framework")
    self.BytecodeAnalysis = self:LoadModule("analysis.bytecode")
    self.SecuritySandbox = self:LoadModule("security.sandbox")
    self.ReflectionUtils = self:LoadModule("utils.reflection")
    
    -- Initialize modules
    self.Decompiler:Initialize(self.config)
    self.Analyzer:Initialize(self.config)
    self.BytecodeAnalysis:Initialize(self.config)
    self.SecuritySandbox:Initialize(self.config)
    self.ReflectionUtils:Initialize(self.config)
    
    -- Connect UI to GKTools
    self.UI.gktools = self
    self.UI:Initialize(self.config)
    
    print("GKTools initialized successfully - Advanced Decompilation Suite Ready")
end

-- Factory function
local function CreateGKTools()
    return setmetatable({}, GKTools)
end

return CreateGKTools
]=]

-- Execute the embedded GKTools
local GKTools = loadstring(GKTOOLS_SOURCE)()

-- Auto-initialize with default config
local gktools = GKTools()
gktools:Initialize()

print("GKTools loaded and initialized!")
print("The advanced decompiler interface should now be visible.")
print("Use the game tree on the left to explore and decompile scripts.")

return gktools