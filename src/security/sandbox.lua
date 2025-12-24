--!strict
--[[
    GKTools Security Sandbox
    Advanced Security & Isolation System
    
    Implements:
    - Code execution sandboxing
    - Permission management
    - Resource monitoring
    - Threat detection
    - Safe environment creation
]]

local SecuritySandbox = {}
SecuritySandbox.__index = SecuritySandbox

-- Advanced type definitions
export type SandboxConfig = {
    allowedGlobals: {string},
    blockedFunctions: {string},
    resourceLimits: ResourceLimits,
    permissionLevel: "RESTRICTED" | "NORMAL" | "ELEVATED",
    monitoringEnabled: boolean
}

export type ResourceLimits = {
    maxMemoryMB: number,
    maxExecutionTimeMS: number,
    maxCallDepth: number,
    maxIterations: number
}

export type SecurityThreat = {
    type: string,
    severity: "LOW" | "MEDIUM" | "HIGH" | "CRITICAL",
    description: string,
    source: string,
    timestamp: number,
    blocked: boolean
}

export type SandboxEnvironment = {
    globals: {[string]: any},
    functions: {[string]: any},
    monitoring: {[string]: any},
    restrictions: {[string]: any}
}

-- Default security configurations
local SECURITY_CONFIGS = {
    RESTRICTED = {
        allowedGlobals = {
            "print", "warn", "type", "typeof", "pairs", "ipairs", "next",
            "tonumber", "tostring", "string", "table", "math", "coroutine"
        },
        blockedFunctions = {
            "loadstring", "getrawmetatable", "setrawmetatable", "getfenv", "setfenv",
            "debug", "io", "os", "require", "dofile", "loadfile"
        },
        resourceLimits = {
            maxMemoryMB = 10,
            maxExecutionTimeMS = 1000,
            maxCallDepth = 50,
            maxIterations = 10000
        },
        permissionLevel = "RESTRICTED",
        monitoringEnabled = true
    },
    NORMAL = {
        allowedGlobals = {
            "print", "warn", "error", "type", "typeof", "pairs", "ipairs", "next",
            "getmetatable", "setmetatable", "rawget", "rawset", "rawequal", "rawlen",
            "tonumber", "tostring", "string", "table", "math", "coroutine",
            "game", "workspace", "script"
        },
        blockedFunctions = {
            "loadstring", "getrawmetatable", "setrawmetatable", "debug"
        },
        resourceLimits = {
            maxMemoryMB = 50,
            maxExecutionTimeMS = 5000,
            maxCallDepth = 100,
            maxIterations = 100000
        },
        permissionLevel = "NORMAL",
        monitoringEnabled = true
    },
    ELEVATED = {
        allowedGlobals = {}, -- All globals allowed
        blockedFunctions = {}, -- No functions blocked
        resourceLimits = {
            maxMemoryMB = 200,
            maxExecutionTimeMS = 30000,
            maxCallDepth = 500,
            maxIterations = 1000000
        },
        permissionLevel = "ELEVATED",
        monitoringEnabled = false
    }
}

-- Initialize security sandbox
function SecuritySandbox:Initialize(config: any): ()
    self.config = config
    self.sandboxConfig = SECURITY_CONFIGS[config.securityLevel] or SECURITY_CONFIGS.NORMAL
    self.threats = {}
    self.activeEnvironments = {}
    self.resourceMonitor = {}
    
    print(`Security Sandbox initialized with {config.securityLevel} security level`)
end

-- Create secure sandbox environment
function SecuritySandbox:CreateSandbox(code: string, customConfig: SandboxConfig?): SandboxEnvironment
    local sandboxConfig = customConfig or self.sandboxConfig
    
    -- Create isolated environment
    local environment = self:CreateIsolatedEnvironment(sandboxConfig)
    
    -- Setup monitoring if enabled
    if sandboxConfig.monitoringEnabled then
        self:SetupMonitoring(environment, sandboxConfig)
    end
    
    -- Apply security restrictions
    self:ApplySecurityRestrictions(environment, sandboxConfig)
    
    -- Store environment reference
    local envId = self:GenerateEnvironmentId()
    self.activeEnvironments[envId] = {
        environment = environment,
        config = sandboxConfig,
        createdAt = tick(),
        resourceUsage = {
            memory = 0,
            executionTime = 0,
            callDepth = 0,
            iterations = 0
        }
    }
    
    environment._sandboxId = envId
    return environment
end

-- Create isolated environment
function SecuritySandbox:CreateIsolatedEnvironment(config: SandboxConfig): SandboxEnvironment
    local environment: SandboxEnvironment = {
        globals = {},
        functions = {},
        monitoring = {},
        restrictions = {}
    }
    
    -- Add allowed globals
    if #config.allowedGlobals > 0 then
        for _, globalName in ipairs(config.allowedGlobals) do
            local globalValue = _G[globalName]
            if globalValue ~= nil then
                environment.globals[globalName] = self:WrapGlobal(globalValue, globalName, config)
            end
        end
    else
        -- Copy all globals if none specified (ELEVATED mode)
        for key, value in pairs(_G) do
            if not self:IsBlocked(key, config.blockedFunctions) then
                environment.globals[key] = self:WrapGlobal(value, key, config)
            end
        end
    end
    
    -- Add safe versions of critical functions
    environment.globals.loadstring = function(source: string, chunkname: string?)
        return self:SafeLoadstring(source, chunkname, config)
    end
    
    environment.globals.getrawmetatable = function(obj: any)
        return self:SafeGetrawmetatable(obj, config)
    end
    
    environment.globals.setrawmetatable = function(obj: any, metatable: any)
        return self:SafeSetrawmetatable(obj, metatable, config)
    end
    
    return environment
end

-- Wrap global functions with security monitoring
function SecuritySandbox:WrapGlobal(globalValue: any, globalName: string, config: SandboxConfig): any
    if type(globalValue) ~= "function" then
        return globalValue
    end
    
    return function(...: any): any
        -- Check if function is blocked
        if self:IsBlocked(globalName, config.blockedFunctions) then
            self:RecordThreat({
                type = "BLOCKED_FUNCTION_ACCESS",
                severity = "HIGH",
                description = `Attempt to access blocked function: {globalName}`,
                source = debug.traceback(),
                timestamp = tick(),
                blocked = true
            })
            error(`Access to function '{globalName}' is blocked by security policy`)
        end
        
        -- Monitor resource usage
        local startTime = tick()
        local result = {pcall(globalValue, ...)}
        local endTime = tick()
        
        -- Update resource monitoring
        if config.monitoringEnabled then
            self:UpdateResourceUsage(globalName, endTime - startTime)
        end
        
        if result[1] then
            return unpack(result, 2)
        else
            error(result[2])
        end
    end
end

-- Safe loadstring implementation
function SecuritySandbox:SafeLoadstring(source: string, chunkname: string?, config: SandboxConfig): any
    -- Analyze source for threats
    local threats = self:AnalyzeSourceThreats(source)
    
    for _, threat in ipairs(threats) do
        self:RecordThreat(threat)
        
        if threat.severity == "CRITICAL" or threat.severity == "HIGH" then
            error(`Security threat detected in code: {threat.description}`)
        end
    end
    
    -- Compile with restricted environment
    local func, err = loadstring(source, chunkname)
    if not func then
        return nil, err
    end
    
    -- Set restricted environment
    local restrictedEnv = self:CreateRestrictedEnvironment(config)
    setfenv(func, restrictedEnv)
    
    return func
end

-- Safe getrawmetatable implementation
function SecuritySandbox:SafeGetrawmetatable(obj: any, config: SandboxConfig): any
    if config.permissionLevel == "RESTRICTED" then
        self:RecordThreat({
            type = "METATABLE_ACCESS",
            severity = "MEDIUM",
            description = "Attempt to access raw metatable in restricted mode",
            source = debug.traceback(),
            timestamp = tick(),
            blocked = true
        })
        return nil
    end
    
    return getrawmetatable(obj)
end

-- Safe setrawmetatable implementation
function SecuritySandbox:SafeSetrawmetatable(obj: any, metatable: any, config: SandboxConfig): any
    if config.permissionLevel == "RESTRICTED" then
        self:RecordThreat({
            type = "METATABLE_MODIFICATION",
            severity = "HIGH",
            description = "Attempt to modify raw metatable in restricted mode",
            source = debug.traceback(),
            timestamp = tick(),
            blocked = true
        })
        error("Metatable modification is not allowed in restricted mode")
    end
    
    -- Log metatable modifications
    self:RecordThreat({
        type = "METATABLE_MODIFICATION",
        severity = "LOW",
        description = "Metatable modification detected",
        source = debug.traceback(),
        timestamp = tick(),
        blocked = false
    })
    
    return setrawmetatable(obj, metatable)
end

-- Analyze source code for security threats
function SecuritySandbox:AnalyzeSourceThreats(source: string): {SecurityThreat}
    local threats = {}
    
    -- Dangerous patterns
    local dangerousPatterns = {
        {
            pattern = "getrawmetatable%s*%(",
            type = "METATABLE_ACCESS",
            severity = "MEDIUM",
            description = "Raw metatable access detected"
        },
        {
            pattern = "setrawmetatable%s*%(",
            type = "METATABLE_MODIFICATION", 
            severity = "HIGH",
            description = "Raw metatable modification detected"
        },
        {
            pattern = "loadstring%s*%(",
            type = "DYNAMIC_CODE_EXECUTION",
            severity = "HIGH",
            description = "Dynamic code execution detected"
        },
        {
            pattern = "debug%.",
            type = "DEBUG_LIBRARY_USAGE",
            severity = "MEDIUM",
            description = "Debug library usage detected"
        },
        {
            pattern = "_G%[",
            type = "GLOBAL_TABLE_ACCESS",
            severity = "LOW",
            description = "Global table access detected"
        },
        {
            pattern = "while%s+true%s+do",
            type = "INFINITE_LOOP",
            severity = "MEDIUM",
            description = "Potential infinite loop detected"
        },
        {
            pattern = "repeat.*until%s+false",
            type = "INFINITE_LOOP",
            severity = "MEDIUM", 
            description = "Potential infinite loop detected"
        }
    }
    
    -- Scan for patterns
    for _, patternInfo in ipairs(dangerousPatterns) do
        local matches = {source:find(patternInfo.pattern)}
        if #matches > 0 then
            table.insert(threats, {
                type = patternInfo.type,
                severity = patternInfo.severity,
                description = patternInfo.description,
                source = source:sub(matches[1], matches[2]),
                timestamp = tick(),
                blocked = false
            })
        end
    end
    
    -- Check for excessive complexity
    local complexity = self:CalculateComplexity(source)
    if complexity > 100 then
        table.insert(threats, {
            type = "HIGH_COMPLEXITY",
            severity = "MEDIUM",
            description = `Code complexity ({complexity}) exceeds recommended threshold`,
            source = "complexity_analysis",
            timestamp = tick(),
            blocked = false
        })
    end
    
    return threats
end

-- Calculate code complexity
function SecuritySandbox:CalculateComplexity(source: string): number
    local complexity = 1
    
    local complexityPatterns = {
        "if%s", "elseif%s", "else%s", "while%s", "for%s",
        "repeat%s", "function%s", "and%s", "or%s"
    }
    
    for _, pattern in ipairs(complexityPatterns) do
        local _, count = source:gsub(pattern, "")
        complexity = complexity + count
    end
    
    return complexity
end

-- Setup resource monitoring
function SecuritySandbox:SetupMonitoring(environment: SandboxEnvironment, config: SandboxConfig): ()
    local monitoring = {
        startTime = tick(),
        callCount = 0,
        memoryUsage = 0,
        iterationCount = 0
    }
    
    -- Wrap functions to monitor calls
    for name, func in pairs(environment.globals) do
        if type(func) == "function" then
            environment.globals[name] = function(...: any): any
                monitoring.callCount = monitoring.callCount + 1
                
                -- Check call depth limit
                if monitoring.callCount > config.resourceLimits.maxCallDepth then
                    error("Maximum call depth exceeded")
                end
                
                local result = {pcall(func, ...)}
                monitoring.callCount = monitoring.callCount - 1
                
                if result[1] then
                    return unpack(result, 2)
                else
                    error(result[2])
                end
            end
        end
    end
    
    environment.monitoring = monitoring
end

-- Apply security restrictions
function SecuritySandbox:ApplySecurityRestrictions(environment: SandboxEnvironment, config: SandboxConfig): ()
    local restrictions = {
        maxExecutionTime = config.resourceLimits.maxExecutionTimeMS,
        maxMemory = config.resourceLimits.maxMemoryMB * 1024 * 1024,
        maxIterations = config.resourceLimits.maxIterations
    }
    
    environment.restrictions = restrictions
end

-- Execute code in sandbox
function SecuritySandbox:ExecuteInSandbox(code: string, environment: SandboxEnvironment): any
    local sandboxId = environment._sandboxId
    local sandboxData = self.activeEnvironments[sandboxId]
    
    if not sandboxData then
        error("Invalid sandbox environment")
    end
    
    -- Compile code
    local func, err = loadstring(code)
    if not func then
        return nil, err
    end
    
    -- Set sandbox environment
    setfenv(func, environment.globals)
    
    -- Execute with monitoring
    local startTime = tick()
    local success, result = pcall(func)
    local endTime = tick()
    
    -- Update resource usage
    sandboxData.resourceUsage.executionTime = sandboxData.resourceUsage.executionTime + (endTime - startTime) * 1000
    
    -- Check resource limits
    if sandboxData.resourceUsage.executionTime > sandboxData.config.resourceLimits.maxExecutionTimeMS then
        self:RecordThreat({
            type = "EXECUTION_TIME_EXCEEDED",
            severity = "HIGH",
            description = "Maximum execution time exceeded",
            source = code,
            timestamp = tick(),
            blocked = true
        })
        error("Maximum execution time exceeded")
    end
    
    if success then
        return result
    else
        return nil, result
    end
end

-- Create restricted environment for loadstring
function SecuritySandbox:CreateRestrictedEnvironment(config: SandboxConfig): {[string]: any}
    local env = {}
    
    -- Add only safe globals
    local safeGlobals = {
        "print", "warn", "type", "typeof", "pairs", "ipairs", "next",
        "tonumber", "tostring", "string", "table", "math"
    }
    
    for _, globalName in ipairs(safeGlobals) do
        env[globalName] = _G[globalName]
    end
    
    return env
end

-- Utility functions
function SecuritySandbox:IsBlocked(functionName: string, blockedList: {string}): boolean
    for _, blocked in ipairs(blockedList) do
        if functionName == blocked then
            return true
        end
    end
    return false
end

function SecuritySandbox:RecordThreat(threat: SecurityThreat): ()
    table.insert(self.threats, threat)
    
    -- Log threat based on severity
    if threat.severity == "CRITICAL" or threat.severity == "HIGH" then
        warn(`[SECURITY] {threat.severity}: {threat.description}`)
    end
    
    -- Limit threat log size
    if #self.threats > 1000 then
        table.remove(self.threats, 1)
    end
end

function SecuritySandbox:UpdateResourceUsage(functionName: string, executionTime: number): ()
    if not self.resourceMonitor[functionName] then
        self.resourceMonitor[functionName] = {
            callCount = 0,
            totalTime = 0,
            averageTime = 0
        }
    end
    
    local monitor = self.resourceMonitor[functionName]
    monitor.callCount = monitor.callCount + 1
    monitor.totalTime = monitor.totalTime + executionTime
    monitor.averageTime = monitor.totalTime / monitor.callCount
end

function SecuritySandbox:GenerateEnvironmentId(): string
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local id = ""
    
    for i = 1, 16 do
        local randomIndex = math.random(1, #chars)
        id = id .. chars:sub(randomIndex, randomIndex)
    end
    
    return id
end

-- Get security report
function SecuritySandbox:GetSecurityReport(): {[string]: any}
    return {
        threats = self.threats,
        activeEnvironments = #self.activeEnvironments,
        resourceMonitor = self.resourceMonitor,
        config = self.sandboxConfig
    }
end

-- Cleanup sandbox environment
function SecuritySandbox:CleanupSandbox(sandboxId: string): ()
    if self.activeEnvironments[sandboxId] then
        self.activeEnvironments[sandboxId] = nil
    end
end

-- Factory function
local function CreateSecuritySandbox(): typeof(SecuritySandbox)
    return setmetatable({}, SecuritySandbox)
end

return CreateSecuritySandbox