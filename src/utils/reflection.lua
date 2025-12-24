--!strict
--[[
    GKTools Reflection Utilities
    Advanced Runtime Introspection & Manipulation
    
    Implements:
    - Deep object inspection
    - Metatable analysis
    - Function introspection
    - Memory layout analysis
    - Dynamic property access
]]

local ReflectionUtils = {}
ReflectionUtils.__index = ReflectionUtils

-- Advanced type definitions
export type ObjectInfo = {
    type: string,
    className: string?,
    properties: {[string]: PropertyInfo},
    methods: {[string]: MethodInfo},
    events: {[string]: EventInfo},
    metatable: MetatableInfo?,
    parent: ObjectInfo?,
    children: {ObjectInfo}
}

export type PropertyInfo = {
    name: string,
    type: string,
    value: any,
    readable: boolean,
    writable: boolean,
    inherited: boolean
}

export type MethodInfo = {
    name: string,
    parameters: {ParameterInfo},
    returnType: string?,
    source: string?,
    upvalues: {UpvalueInfo}
}

export type EventInfo = {
    name: string,
    connectionCount: number,
    canConnect: boolean
}

export type MetatableInfo = {
    metamethods: {[string]: any},
    index: any,
    newindex: any,
    readonly: boolean
}

export type ParameterInfo = {
    name: string,
    type: string,
    optional: boolean,
    default: any
}

export type UpvalueInfo = {
    name: string,
    value: any,
    level: number
}

-- Initialize reflection utilities
function ReflectionUtils:Initialize(config: any): ()
    self.config = config
    self.inspectionCache = {}
    self.metatableCache = {}
    
    print("Reflection Utils initialized with advanced introspection capabilities")
end

-- Deep object inspection
function ReflectionUtils:InspectObject(obj: any, maxDepth: number?): ObjectInfo
    local depth = maxDepth or 5
    local cacheKey = self:GenerateObjectKey(obj)
    
    if self.inspectionCache[cacheKey] then
        return self.inspectionCache[cacheKey]
    end
    
    local info: ObjectInfo = {
        type = typeof(obj),
        className = self:GetClassName(obj),
        properties = {},
        methods = {},
        events = {},
        metatable = self:InspectMetatable(obj),
        parent = nil,
        children = {}
    }
    
    -- Inspect properties
    info.properties = self:InspectProperties(obj)
    
    -- Inspect methods
    info.methods = self:InspectMethods(obj)
    
    -- Inspect events (for Instances)
    if typeof(obj) == "Instance" then
        info.events = self:InspectEvents(obj)
    end
    
    -- Inspect children (recursive, with depth limit)
    if depth > 0 and typeof(obj) == "Instance" then
        for _, child in ipairs((obj :: Instance):GetChildren()) do
            local childInfo = self:InspectObject(child, depth - 1)
            childInfo.parent = info
            table.insert(info.children, childInfo)
        end
    end
    
    -- Cache result
    self.inspectionCache[cacheKey] = info
    return info
end

-- Inspect object properties
function ReflectionUtils:InspectProperties(obj: any): {[string]: PropertyInfo}
    local properties = {}
    
    if typeof(obj) == "Instance" then
        -- Get Instance properties through reflection
        local instance = obj :: Instance
        
        -- Common properties to check
        local commonProperties = {
            "Name", "ClassName", "Parent", "Archivable"
        }
        
        -- Class-specific properties
        local classProperties = self:GetClassProperties(instance.ClassName)
        
        -- Combine all properties
        local allProperties = {}
        for _, prop in ipairs(commonProperties) do
            table.insert(allProperties, prop)
        end
        for _, prop in ipairs(classProperties) do
            table.insert(allProperties, prop)
        end
        
        -- Inspect each property
        for _, propName in ipairs(allProperties) do
            local propInfo = self:InspectProperty(instance, propName)
            if propInfo then
                properties[propName] = propInfo
            end
        end
    elseif type(obj) == "table" then
        -- Inspect table properties
        for key, value in pairs(obj) do
            properties[tostring(key)] = {
                name = tostring(key),
                type = typeof(value),
                value = value,
                readable = true,
                writable = true,
                inherited = false
            }
        end
    end
    
    return properties
end

-- Inspect individual property
function ReflectionUtils:InspectProperty(instance: Instance, propName: string): PropertyInfo?
    local success, value = pcall(function()
        return (instance :: any)[propName]
    end)
    
    if not success then
        return nil
    end
    
    local readable = success
    local writable = false
    
    -- Test writability
    local originalValue = value
    local writeSuccess = pcall(function()
        (instance :: any)[propName] = originalValue
    end)
    writable = writeSuccess
    
    return {
        name = propName,
        type = typeof(value),
        value = value,
        readable = readable,
        writable = writable,
        inherited = self:IsInheritedProperty(instance.ClassName, propName)
    }
end

-- Inspect object methods
function ReflectionUtils:InspectMethods(obj: any): {[string]: MethodInfo}
    local methods = {}
    
    if typeof(obj) == "Instance" then
        local instance = obj :: Instance
        
        -- Common Instance methods
        local commonMethods = {
            "GetChildren", "FindFirstChild", "WaitForChild", "Clone", "Destroy"
        }
        
        -- Class-specific methods
        local classMethods = self:GetClassMethods(instance.ClassName)
        
        -- Combine all methods
        local allMethods = {}
        for _, method in ipairs(commonMethods) do
            table.insert(allMethods, method)
        end
        for _, method in ipairs(classMethods) do
            table.insert(allMethods, method)
        end
        
        -- Inspect each method
        for _, methodName in ipairs(allMethods) do
            local methodInfo = self:InspectMethod(instance, methodName)
            if methodInfo then
                methods[methodName] = methodInfo
            end
        end
    elseif type(obj) == "table" then
        -- Inspect table methods
        for key, value in pairs(obj) do
            if type(value) == "function" then
                methods[tostring(key)] = self:InspectFunction(value, tostring(key))
            end
        end
    end
    
    return methods
end

-- Inspect individual method
function ReflectionUtils:InspectMethod(instance: Instance, methodName: string): MethodInfo?
    local success, method = pcall(function()
        return (instance :: any)[methodName]
    end)
    
    if not success or type(method) ~= "function" then
        return nil
    end
    
    return self:InspectFunction(method, methodName)
end

-- Inspect function details
function ReflectionUtils:InspectFunction(func: any, name: string): MethodInfo
    local info: MethodInfo = {
        name = name,
        parameters = {},
        returnType = nil,
        source = nil,
        upvalues = {}
    }
    
    -- Get function info using debug library
    local debugInfo = debug.getinfo(func, "S")
    if debugInfo then
        info.source = debugInfo.source
        info.returnType = self:InferReturnType(func)
    end
    
    -- Get upvalues
    info.upvalues = self:GetUpvalues(func)
    
    -- Get parameters (simplified)
    info.parameters = self:GetParameters(func)
    
    return info
end

-- Inspect events (for Instances)
function ReflectionUtils:InspectEvents(instance: Instance): {[string]: EventInfo}
    local events = {}
    
    -- Common events to check
    local commonEvents = {
        "ChildAdded", "ChildRemoved", "AncestryChanged"
    }
    
    -- Class-specific events
    local classEvents = self:GetClassEvents(instance.ClassName)
    
    -- Combine all events
    local allEvents = {}
    for _, event in ipairs(commonEvents) do
        table.insert(allEvents, event)
    end
    for _, event in ipairs(classEvents) do
        table.insert(allEvents, event)
    end
    
    -- Inspect each event
    for _, eventName in ipairs(allEvents) do
        local eventInfo = self:InspectEvent(instance, eventName)
        if eventInfo then
            events[eventName] = eventInfo
        end
    end
    
    return events
end

-- Inspect individual event
function ReflectionUtils:InspectEvent(instance: Instance, eventName: string): EventInfo?
    local success, event = pcall(function()
        return (instance :: any)[eventName]
    end)
    
    if not success or typeof(event) ~= "RBXScriptSignal" then
        return nil
    end
    
    return {
        name = eventName,
        connectionCount = 0, -- Cannot determine connection count
        canConnect = true
    }
end

-- Inspect metatable
function ReflectionUtils:InspectMetatable(obj: any): MetatableInfo?
    local cacheKey = self:GenerateObjectKey(obj) .. "_metatable"
    
    if self.metatableCache[cacheKey] then
        return self.metatableCache[cacheKey]
    end
    
    local success, metatable = pcall(function()
        return getrawmetatable(obj)
    end)
    
    if not success or not metatable then
        return nil
    end
    
    local info: MetatableInfo = {
        metamethods = {},
        index = nil,
        newindex = nil,
        readonly = false
    }
    
    -- Inspect metamethods
    local metamethods = {
        "__index", "__newindex", "__call", "__tostring", "__len",
        "__add", "__sub", "__mul", "__div", "__mod", "__pow",
        "__unm", "__eq", "__lt", "__le", "__concat", "__gc"
    }
    
    for _, metamethod in ipairs(metamethods) do
        local value = metatable[metamethod]
        if value ~= nil then
            info.metamethods[metamethod] = {
                type = type(value),
                value = value
            }
        end
    end
    
    -- Special handling for __index and __newindex
    info.index = metatable.__index
    info.newindex = metatable.__newindex
    
    -- Test if metatable is readonly
    local originalValue = metatable.__test
    local writeSuccess = pcall(function()
        metatable.__test = "test"
        metatable.__test = originalValue
    end)
    info.readonly = not writeSuccess
    
    -- Cache result
    self.metatableCache[cacheKey] = info
    return info
end

-- Get function upvalues
function ReflectionUtils:GetUpvalues(func: any): {UpvalueInfo}
    local upvalues = {}
    local level = 1
    
    while true do
        local name, value = debug.getupvalue(func, level)
        if not name then
            break
        end
        
        table.insert(upvalues, {
            name = name,
            value = value,
            level = level
        })
        
        level = level + 1
        
        -- Prevent infinite loops
        if level > 100 then
            break
        end
    end
    
    return upvalues
end

-- Get function parameters (simplified)
function ReflectionUtils:GetParameters(func: any): {ParameterInfo}
    local parameters = {}
    
    -- This is a simplified implementation
    -- In a real system, this would parse function signatures
    local info = debug.getinfo(func, "u")
    if info then
        for i = 1, info.nparams do
            table.insert(parameters, {
                name = `param{i}`,
                type = "any",
                optional = false,
                default = nil
            })
        end
        
        -- Handle varargs
        if info.isvararg then
            table.insert(parameters, {
                name = "...",
                type = "any",
                optional = true,
                default = nil
            })
        end
    end
    
    return parameters
end

-- Advanced property access
function ReflectionUtils:GetProperty(obj: any, propertyPath: string): any
    local parts = propertyPath:split(".")
    local current = obj
    
    for _, part in ipairs(parts) do
        if current == nil then
            return nil
        end
        
        local success, value = pcall(function()
            if typeof(current) == "Instance" then
                return (current :: any)[part]
            elseif type(current) == "table" then
                return current[part]
            else
                return nil
            end
        end)
        
        if not success then
            return nil
        end
        
        current = value
    end
    
    return current
end

-- Advanced property setting
function ReflectionUtils:SetProperty(obj: any, propertyPath: string, value: any): boolean
    local parts = propertyPath:split(".")
    local current = obj
    
    -- Navigate to parent of target property
    for i = 1, #parts - 1 do
        local part = parts[i]
        local success, nextValue = pcall(function()
            if typeof(current) == "Instance" then
                return (current :: any)[part]
            elseif type(current) == "table" then
                return current[part]
            else
                return nil
            end
        end)
        
        if not success or nextValue == nil then
            return false
        end
        
        current = nextValue
    end
    
    -- Set the target property
    local targetProperty = parts[#parts]
    local success = pcall(function()
        if typeof(current) == "Instance" then
            (current :: any)[targetProperty] = value
        elseif type(current) == "table" then
            current[targetProperty] = value
        end
    end)
    
    return success
end

-- Utility functions
function ReflectionUtils:GenerateObjectKey(obj: any): string
    if typeof(obj) == "Instance" then
        return `Instance_{(obj :: Instance).ClassName}_{tostring(obj)}`
    else
        return `{typeof(obj)}_{tostring(obj)}`
    end
end

function ReflectionUtils:GetClassName(obj: any): string?
    if typeof(obj) == "Instance" then
        return (obj :: Instance).ClassName
    end
    return nil
end

function ReflectionUtils:GetClassProperties(className: string): {string}
    -- This would contain comprehensive property lists for each class
    local classProperties = {
        Part = {"Size", "Position", "Rotation", "Material", "Color", "Transparency"},
        Script = {"Source", "Disabled", "RunContext"},
        LocalScript = {"Source", "Disabled", "RunContext"},
        ModuleScript = {"Source"},
        Frame = {"Size", "Position", "BackgroundColor3", "BackgroundTransparency"},
        TextLabel = {"Text", "TextColor3", "TextSize", "Font"},
        TextButton = {"Text", "TextColor3", "TextSize", "Font"},
        ImageLabel = {"Image", "ImageColor3", "ImageTransparency"},
        ScrollingFrame = {"CanvasSize", "ScrollBarThickness", "ScrollingDirection"}
    }
    
    return classProperties[className] or {}
end

function ReflectionUtils:GetClassMethods(className: string): {string}
    -- This would contain comprehensive method lists for each class
    local classMethods = {
        Part = {"SetNetworkOwner", "GetNetworkOwner", "CanSetNetworkOwnership"},
        Script = {},
        LocalScript = {},
        ModuleScript = {},
        Frame = {"TweenSize", "TweenPosition"},
        TextLabel = {},
        TextButton = {},
        ImageLabel = {},
        ScrollingFrame = {}
    }
    
    return classMethods[className] or {}
end

function ReflectionUtils:GetClassEvents(className: string): {string}
    -- This would contain comprehensive event lists for each class
    local classEvents = {
        Part = {"Touched", "TouchEnded"},
        Script = {},
        LocalScript = {},
        ModuleScript = {},
        Frame = {},
        TextLabel = {},
        TextButton = {"MouseButton1Click", "MouseButton2Click", "MouseEnter", "MouseLeave"},
        ImageLabel = {},
        ScrollingFrame = {}
    }
    
    return classEvents[className] or {}
end

function ReflectionUtils:IsInheritedProperty(className: string, propertyName: string): boolean
    -- This would check if a property is inherited from a base class
    local baseProperties = {"Name", "ClassName", "Parent", "Archivable"}
    
    for _, baseProp in ipairs(baseProperties) do
        if propertyName == baseProp then
            return true
        end
    end
    
    return false
end

function ReflectionUtils:InferReturnType(func: any): string?
    -- This would analyze function to infer return type
    -- Simplified implementation
    return "any"
end

-- Memory analysis
function ReflectionUtils:AnalyzeMemoryLayout(obj: any): {[string]: any}
    local layout = {
        size = 0,
        references = 0,
        type = typeof(obj),
        address = tostring(obj)
    }
    
    -- Estimate memory usage (simplified)
    if type(obj) == "string" then
        layout.size = #obj
    elseif type(obj) == "table" then
        local count = 0
        for _, _ in pairs(obj) do
            count = count + 1
        end
        layout.size = count * 8 -- Rough estimate
        layout.references = count
    elseif typeof(obj) == "Instance" then
        layout.size = 64 -- Base instance size estimate
        layout.references = #(obj :: Instance):GetChildren()
    end
    
    return layout
end

-- Factory function
local function CreateReflectionUtils(): typeof(ReflectionUtils)
    return setmetatable({}, ReflectionUtils)
end

return CreateReflectionUtils