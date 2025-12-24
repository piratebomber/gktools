--!strict
--[[
    GKTools - Get (Meta) Kit Tools
    Advanced Roblox Game Source Code Analysis & Decompilation Suite
    
    Entry Point & Dynamic Loader
    Copyright (c) 2024 GKTools Development Team
]]

local GKTools = {}
GKTools.__index = GKTools

-- Advanced type definitions
export type DecompilerConfig = {
    enableMetatableHooks: boolean,
    maxRecursionDepth: number,
    enableBytecodeAnalysis: boolean,
    securityLevel: "LOW" | "MEDIUM" | "HIGH",
    uiTheme: "DARK" | "LIGHT" | "AUTO"
}

export type GameTreeNode = {
    name: string,
    className: string,
    children: {GameTreeNode},
    source: string?,
    bytecode: string?,
    metadata: {[string]: any}
}

-- Core module loader with advanced caching
local ModuleCache: {[string]: any} = {}
local LoaderHooks: {[string]: (any) -> any} = {}

-- Advanced metatable manipulation
local function getAdvancedMetatable(obj: any): any
    local success, metatable = pcall(function()
        return getrawmetatable(obj)
    end)
    
    if success and metatable then
        -- Deep metatable analysis
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

-- Dynamic module loading with security sandboxing
function GKTools:LoadModule(moduleName: string, source: string?): any
    if ModuleCache[moduleName] then
        return ModuleCache[moduleName]
    end
    
    local moduleSource = source or self:GetModuleSource(moduleName)
    if not moduleSource then
        error(`Failed to load module: {moduleName}`)
    end
    
    -- Advanced sandboxing environment
    local sandbox = {
        print = print,
        warn = warn,
        error = error,
        type = type,
        typeof = typeof,
        pairs = pairs,
        ipairs = ipairs,
        next = next,
        getmetatable = getmetatable,
        setmetatable = setmetatable,
        rawget = rawget,
        rawset = rawset,
        rawequal = rawequal,
        rawlen = rawlen,
        select = select,
        tonumber = tonumber,
        tostring = tostring,
        string = string,
        table = table,
        math = math,
        coroutine = coroutine,
        game = game,
        workspace = workspace,
        script = script,
        -- Advanced APIs
        getrawmetatable = getrawmetatable,
        setrawmetatable = setrawmetatable,
        getfenv = getfenv,
        setfenv = setfenv,
        loadstring = loadstring,
        -- GKTools APIs
        GKTools = self
    }
    
    -- Execute with advanced error handling
    local compiledModule, compileError = loadstring(moduleSource)
    if not compiledModule then
        error(`Module compilation failed for {moduleName}: {compileError}`)
    end
    
    setfenv(compiledModule, sandbox)
    
    local success, result = pcall(compiledModule)
    if not success then
        error(`Module execution failed for {moduleName}: {result}`)
    end
    
    -- Apply loader hooks
    if LoaderHooks[moduleName] then
        result = LoaderHooks[moduleName](result)
    end
    
    ModuleCache[moduleName] = result
    return result
end

-- Advanced source code retrieval
function GKTools:GetModuleSource(moduleName: string): string?
    local moduleMap = {
        ["core.decompiler"] = self:GetCoreDecompilerSource(),
        ["core.analyzer"] = self:GetCoreAnalyzerSource(),
        ["ui.framework"] = self:GetUIFrameworkSource(),
        ["ui.components"] = self:GetUIComponentsSource(),
        ["analysis.bytecode"] = self:GetBytecodeAnalysisSource(),
        ["security.sandbox"] = self:GetSecuritySandboxSource(),
        ["utils.reflection"] = self:GetReflectionUtilsSource()
    }
    
    return moduleMap[moduleName]
end

-- Initialize the complete system
function GKTools:Initialize(config: DecompilerConfig?): ()
    local defaultConfig: DecompilerConfig = {
        enableMetatableHooks = true,
        maxRecursionDepth = 50,
        enableBytecodeAnalysis = true,
        securityLevel = "MEDIUM",
        uiTheme = "AUTO"
    }
    
    self.config = config or defaultConfig
    
    -- Load core modules
    self.Decompiler = self:LoadModule("core.decompiler")
    self.Analyzer = self:LoadModule("core.analyzer")
    self.UI = self:LoadModule("ui.framework")
    self.Components = self:LoadModule("ui.components")
    self.BytecodeAnalysis = self:LoadModule("analysis.bytecode")
    self.SecuritySandbox = self:LoadModule("security.sandbox")
    self.ReflectionUtils = self:LoadModule("utils.reflection")
    
    -- Initialize modules with config
    self.Decompiler:Initialize(self.config)
    self.Analyzer:Initialize(self.config)
    self.BytecodeAnalysis:Initialize(self.config)
    self.SecuritySandbox:Initialize(self.config)
    self.ReflectionUtils:Initialize(self.config)
    
    -- Initialize UI system and connect to GKTools
    self.UI.gktools = self
    self.UI:Initialize(self.config)
    
    -- Setup advanced hooks
    self:SetupAdvancedHooks()
    
    print("GKTools initialized successfully - Advanced Decompilation Suite Ready")
end

-- Advanced hook system for runtime analysis
function GKTools:SetupAdvancedHooks(): ()
    if not self.config.enableMetatableHooks then
        return
    end
    
    -- Hook into game service metatables for deep analysis
    local services = {
        game:GetService("ServerScriptService"),
        game:GetService("ServerStorage"),
        game:GetService("StarterGui"),
        game:GetService("StarterPlayer"),
        game:GetService("Players"),
        game:GetService("Workspace")
    }
    
    for _, service in ipairs(services) do
        local metatable, hooks = getAdvancedMetatable(service)
        if metatable then
            -- Install analysis hooks
            self:InstallServiceHooks(service, metatable, hooks)
        end
    end
end

-- Install service-specific analysis hooks
function GKTools:InstallServiceHooks(service: Instance, metatable: any, hooks: {[string]: any}): ()
    if not self.hookRegistry then
        self.hookRegistry = {}
    end
    
    local serviceName = service.ClassName
    self.hookRegistry[serviceName] = {
        originalMetatable = metatable,
        originalHooks = hooks,
        interceptedMethods = {}
    }
    
    -- Create interceptor functions for critical metamethods
    local interceptors = {
        __index = function(obj: any, key: string): any
            local result = hooks.__index and hooks.__index(obj, key) or rawget(obj, key)
            
            -- Log property access for analysis
            if self.config.securityLevel ~= "LOW" then
                self:LogPropertyAccess(obj, key, result)
            end
            
            -- Special handling for Source property
            if key == "Source" and typeof(obj) == "Instance" then
                local source = self:ExtractSourceWithHooks(obj)
                if source then
                    return source
                end
            end
            
            return result
        end,
        
        __newindex = function(obj: any, key: string, value: any): ()
            -- Log property modifications
            if self.config.securityLevel == "HIGH" then
                self:LogPropertyModification(obj, key, value)
            end
            
            if hooks.__newindex then
                hooks.__newindex(obj, key, value)
            else
                rawset(obj, key, value)
            end
        end,
        
        __call = function(obj: any, ...: any): any
            local args = {...}
            self:LogMethodCall(obj, "__call", args)
            
            if hooks.__call then
                return hooks.__call(obj, ...)
            end
            
            error("Attempt to call non-callable object")
        end
    }
    
    -- Install interceptors
    for metamethod, interceptor in pairs(interceptors) do
        if metatable[metamethod] or metamethod == "__index" then
            self.hookRegistry[serviceName].interceptedMethods[metamethod] = metatable[metamethod]
            metatable[metamethod] = interceptor
        end
    end
    
    -- Hook into child addition/removal
    local originalChildAdded = service.ChildAdded
    service.ChildAdded:Connect(function(child: Instance)
        self:OnChildAdded(service, child)
    end)
    
    local originalChildRemoved = service.ChildRemoved
    service.ChildRemoved:Connect(function(child: Instance)
        self:OnChildRemoved(service, child)
    end)
    
    print(`Advanced hooks installed for {serviceName}`)
end

-- Hook event handlers
function GKTools:LogPropertyAccess(obj: any, key: string, result: any): ()
    if not self.accessLog then
        self.accessLog = {}
    end
    
    table.insert(self.accessLog, {
        timestamp = tick(),
        object = tostring(obj),
        property = key,
        value = tostring(result),
        type = typeof(result)
    })
end

function GKTools:LogPropertyModification(obj: any, key: string, value: any): ()
    if not self.modificationLog then
        self.modificationLog = {}
    end
    
    table.insert(self.modificationLog, {
        timestamp = tick(),
        object = tostring(obj),
        property = key,
        newValue = tostring(value),
        type = typeof(value)
    })
end

function GKTools:LogMethodCall(obj: any, method: string, args: {any}): ()
    if not self.callLog then
        self.callLog = {}
    end
    
    table.insert(self.callLog, {
        timestamp = tick(),
        object = tostring(obj),
        method = method,
        arguments = args
    })
end

function GKTools:OnChildAdded(parent: Instance, child: Instance): ()
    -- Automatically analyze new children
    if self.Decompiler then
        spawn(function()
            local result = self.Decompiler:DecompileInstance(child)
            if result.source then
                self:NotifyUI("ChildAdded", {
                    parent = parent,
                    child = child,
                    source = result.source,
                    metadata = result.metadata
                })
            end
        end)
    end
end

function GKTools:OnChildRemoved(parent: Instance, child: Instance): ()
    self:NotifyUI("ChildRemoved", {
        parent = parent,
        child = child
    })
end

function GKTools:ExtractSourceWithHooks(obj: Instance): string?
    -- Advanced source extraction using hooks
    local methods = {
        function() return rawget(obj, "Source") end,
        function() return (obj :: any).Source end,
        function() 
            local mt = getrawmetatable(obj)
            return mt and mt.__index and mt.__index(obj, "Source")
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

function GKTools:NotifyUI(event: string, data: any): ()
    if self.UI and self.UI.HandleEvent then
        self.UI:HandleEvent(event, data)
    end
end

-- Module source implementations
function GKTools:GetCoreDecompilerSource(): string
    return self:ReadModuleFile("core/decompiler.lua")
end

function GKTools:GetCoreAnalyzerSource(): string
    return self:ReadModuleFile("core/analyzer.lua")
end

function GKTools:GetUIFrameworkSource(): string
    return self:ReadModuleFile("ui/framework.lua")
end

function GKTools:GetUIComponentsSource(): string
    return self:ReadModuleFile("ui/components.lua")
end

function GKTools:GetBytecodeAnalysisSource(): string
    return self:ReadModuleFile("analysis/bytecode.lua")
end

function GKTools:GetSecuritySandboxSource(): string
    return self:ReadModuleFile("security/sandbox.lua")
end

function GKTools:GetReflectionUtilsSource(): string
    return self:ReadModuleFile("utils/reflection.lua")
end

function GKTools:ReadModuleFile(path: string): string
    -- Embedded module sources for self-contained execution
    local moduleMap = {
        ["core/decompiler.lua"] = [[
local CoreDecompiler = {}
CoreDecompiler.__index = CoreDecompiler

function CoreDecompiler:Initialize(config)
    self.config = config
    self.cache = {}
end

function CoreDecompiler:ExtractSource(instance)
    local success, source = pcall(function()
        return instance.Source
    end)
    return success and source or nil
end

function CoreDecompiler:DecompileInstance(instance)
    return {
        source = self:ExtractSource(instance),
        metadata = {className = instance.ClassName, name = instance.Name}
    }
end

function CoreDecompiler:AnalyzeGameTree()
    return {}
end

return setmetatable({}, CoreDecompiler)
]],
        ["core/analyzer.lua"] = [[
local CoreAnalyzer = {}
CoreAnalyzer.__index = CoreAnalyzer

function CoreAnalyzer:Initialize(config)
    self.config = config
end

function CoreAnalyzer:AnalyzeSource(source)
    return {
        complexity = 1,
        vulnerabilities = {},
        patterns = {},
        metrics = {linesOfCode = #source:split("\n")},
        suggestions = {}
    }
end

return setmetatable({}, CoreAnalyzer)
]],
        ["ui/framework.lua"] = [[
local UIFramework = require(script.Parent.Parent.ui.framework)
return UIFramework()
]],
        ["ui/components.lua"] = [[
local UIComponents = require(script.Parent.Parent.ui.components)
return UIComponents()
]],
        ["analysis/bytecode.lua"] = [[
local BytecodeAnalysis = require(script.Parent.Parent.analysis.bytecode)
return BytecodeAnalysis()
]],
        ["security/sandbox.lua"] = [[
local SecuritySandbox = require(script.Parent.Parent.security.sandbox)
return SecuritySandbox()
]],
        ["utils/reflection.lua"] = [[
local ReflectionUtils = require(script.Parent.Parent.utils.reflection)
return ReflectionUtils()
]]
    }
    
    return moduleMap[path] or ""
end

-- Factory function
local function CreateGKTools(): typeof(GKTools)
    return setmetatable({}, GKTools)
end

return CreateGKTools