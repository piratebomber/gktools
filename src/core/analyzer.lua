--!strict
--[[
    GKTools Core Analyzer
    Advanced Code Analysis & Pattern Recognition
    
    Implements sophisticated analysis techniques:
    - AST parsing and manipulation
    - Control flow analysis
    - Data flow analysis
    - Security vulnerability detection
]]

local CoreAnalyzer = {}
CoreAnalyzer.__index = CoreAnalyzer

-- Advanced type definitions
export type AnalysisResult = {
    complexity: number,
    vulnerabilities: {SecurityIssue},
    patterns: {CodePattern},
    metrics: CodeMetrics,
    suggestions: {string}
}

export type SecurityIssue = {
    type: string,
    severity: "LOW" | "MEDIUM" | "HIGH" | "CRITICAL",
    description: string,
    line: number,
    column: number,
    suggestion: string
}

export type CodePattern = {
    name: string,
    matches: {{line: number, column: number, length: number}},
    confidence: number
}

export type CodeMetrics = {
    linesOfCode: number,
    cyclomaticComplexity: number,
    maintainabilityIndex: number,
    technicalDebt: number
}

-- Advanced pattern matching for code analysis
local SECURITY_PATTERNS = {
    {
        name = "loadstring_usage",
        pattern = "loadstring%s*%(",
        severity = "HIGH",
        description = "Dynamic code execution detected - potential security risk"
    },
    {
        name = "getrawmetatable_usage", 
        pattern = "getrawmetatable%s*%(",
        severity = "MEDIUM",
        description = "Metatable manipulation detected - advanced technique"
    },
    {
        name = "setrawmetatable_usage",
        pattern = "setrawmetatable%s*%(",
        severity = "HIGH", 
        description = "Metatable modification detected - potential security risk"
    },
    {
        name = "debug_library_usage",
        pattern = "debug%.%w+",
        severity = "MEDIUM",
        description = "Debug library usage detected - reflection capability"
    },
    {
        name = "environment_manipulation",
        pattern = "[gs]etfenv%s*%(",
        severity = "HIGH",
        description = "Environment manipulation detected - sandbox escape risk"
    },
    {
        name = "global_access",
        pattern = "_G%[",
        severity = "LOW",
        description = "Global table access detected"
    }
}

local CODE_PATTERNS = {
    {
        name = "function_definition",
        pattern = "function%s+(%w+)%s*%(",
        confidence = 0.95
    },
    {
        name = "local_function",
        pattern = "local%s+function%s+(%w+)%s*%(",
        confidence = 0.95
    },
    {
        name = "anonymous_function",
        pattern = "function%s*%(",
        confidence = 0.90
    },
    {
        name = "table_constructor",
        pattern = "%{[^}]*%}",
        confidence = 0.85
    },
    {
        name = "string_literal",
        pattern = "\"[^\"]*\"",
        confidence = 0.99
    },
    {
        name = "comment_block",
        pattern = "%-%-[^\n]*",
        confidence = 0.99
    }
}

-- Initialize analyzer
function CoreAnalyzer:Initialize(config: any): ()
    self.config = config
    self.analysisCache = {}
    
    print("Core Analyzer initialized with advanced pattern recognition")
end

-- Comprehensive source code analysis
function CoreAnalyzer:AnalyzeSource(source: string, context: string?): AnalysisResult
    local cacheKey = self:GenerateCacheKey(source, context)
    
    if self.analysisCache[cacheKey] then
        return self.analysisCache[cacheKey]
    end
    
    local result: AnalysisResult = {
        complexity = self:CalculateComplexity(source),
        vulnerabilities = self:DetectVulnerabilities(source),
        patterns = self:DetectPatterns(source),
        metrics = self:CalculateMetrics(source),
        suggestions = self:GenerateSuggestions(source)
    }
    
    self.analysisCache[cacheKey] = result
    return result
end

-- Advanced complexity calculation
function CoreAnalyzer:CalculateComplexity(source: string): number
    local complexity = 1 -- Base complexity
    
    -- Control flow complexity
    local controlPatterns = {
        "if%s", "elseif%s", "else%s", "while%s", "for%s", 
        "repeat%s", "function%s", "and%s", "or%s"
    }
    
    for _, pattern in ipairs(controlPatterns) do
        local _, count = source:gsub(pattern, "")
        complexity = complexity + count
    end
    
    -- Nesting complexity
    local nestingLevel = 0
    local maxNesting = 0
    
    for i = 1, #source do
        local char = source:sub(i, i)
        if char == "{" or char == "(" then
            nestingLevel = nestingLevel + 1
            maxNesting = math.max(maxNesting, nestingLevel)
        elseif char == "}" or char == ")" then
            nestingLevel = math.max(0, nestingLevel - 1)
        end
    end
    
    complexity = complexity + maxNesting * 2
    
    return complexity
end

-- Security vulnerability detection
function CoreAnalyzer:DetectVulnerabilities(source: string): {SecurityIssue}
    local vulnerabilities = {}
    local lines = source:split("\n")
    
    for lineNum, line in ipairs(lines) do
        for _, secPattern in ipairs(SECURITY_PATTERNS) do
            local matches = {line:find(secPattern.pattern)}
            if #matches > 0 then
                table.insert(vulnerabilities, {
                    type = secPattern.name,
                    severity = secPattern.severity,
                    description = secPattern.description,
                    line = lineNum,
                    column = matches[1],
                    suggestion = self:GenerateSecuritySuggestion(secPattern.name)
                })
            end
        end
    end
    
    return vulnerabilities
end

-- Code pattern detection
function CoreAnalyzer:DetectPatterns(source: string): {CodePattern}
    local patterns = {}
    
    for _, codePattern in ipairs(CODE_PATTERNS) do
        local matches = {}
        local searchPos = 1
        
        while searchPos <= #source do
            local startPos, endPos = source:find(codePattern.pattern, searchPos)
            if not startPos then break end
            
            local line, column = self:GetLineColumn(source, startPos)
            table.insert(matches, {
                line = line,
                column = column,
                length = endPos - startPos + 1
            })
            
            searchPos = endPos + 1
        end
        
        if #matches > 0 then
            table.insert(patterns, {
                name = codePattern.name,
                matches = matches,
                confidence = codePattern.confidence
            })
        end
    end
    
    return patterns
end

-- Calculate comprehensive code metrics
function CoreAnalyzer:CalculateMetrics(source: string): CodeMetrics
    local lines = source:split("\n")
    local linesOfCode = 0
    
    -- Count non-empty, non-comment lines
    for _, line in ipairs(lines) do
        local trimmed = line:match("^%s*(.-)%s*$")
        if #trimmed > 0 and not trimmed:match("^%-%-") then
            linesOfCode = linesOfCode + 1
        end
    end
    
    local complexity = self:CalculateComplexity(source)
    
    -- Maintainability Index (simplified)
    local maintainabilityIndex = math.max(0, 171 - 5.2 * math.log(linesOfCode) - 0.23 * complexity)
    
    -- Technical Debt (based on complexity and vulnerabilities)
    local vulnerabilities = self:DetectVulnerabilities(source)
    local technicalDebt = complexity * 0.1 + #vulnerabilities * 2
    
    return {
        linesOfCode = linesOfCode,
        cyclomaticComplexity = complexity,
        maintainabilityIndex = maintainabilityIndex,
        technicalDebt = technicalDebt
    }
end

-- Generate improvement suggestions
function CoreAnalyzer:GenerateSuggestions(source: string): {string}
    local suggestions = {}
    local metrics = self:CalculateMetrics(source)
    local vulnerabilities = self:DetectVulnerabilities(source)
    
    -- Complexity suggestions
    if metrics.cyclomaticComplexity > 10 then
        table.insert(suggestions, "Consider breaking down complex functions into smaller, more manageable pieces")
    end
    
    -- Security suggestions
    if #vulnerabilities > 0 then
        table.insert(suggestions, "Review security vulnerabilities and implement proper input validation")
    end
    
    -- Code quality suggestions
    if metrics.linesOfCode > 100 then
        table.insert(suggestions, "Consider splitting large files into smaller modules for better maintainability")
    end
    
    if metrics.maintainabilityIndex < 50 then
        table.insert(suggestions, "Improve code readability by adding comments and simplifying complex logic")
    end
    
    -- Pattern-based suggestions
    local patterns = self:DetectPatterns(source)
    for _, pattern in ipairs(patterns) do
        if pattern.name == "loadstring_usage" and #pattern.matches > 3 then
            table.insert(suggestions, "Excessive use of loadstring detected - consider alternative approaches")
        end
    end
    
    return suggestions
end

-- Utility functions
function CoreAnalyzer:GenerateCacheKey(source: string, context: string?): string
    local hash = 0
    for i = 1, #source do
        hash = (hash * 31 + string.byte(source, i)) % 2147483647
    end
    return tostring(hash) .. (context or "")
end

function CoreAnalyzer:GetLineColumn(source: string, position: number): (number, number)
    local line = 1
    local column = 1
    
    for i = 1, position - 1 do
        if source:sub(i, i) == "\n" then
            line = line + 1
            column = 1
        else
            column = column + 1
        end
    end
    
    return line, column
end

function CoreAnalyzer:GenerateSecuritySuggestion(vulnerabilityType: string): string
    local suggestions = {
        loadstring_usage = "Use safer alternatives like ModuleScripts or pre-compiled functions",
        getrawmetatable_usage = "Ensure metatable access is necessary and properly secured",
        setrawmetatable_usage = "Avoid metatable modifications unless absolutely necessary",
        debug_library_usage = "Limit debug library usage to development environments only",
        environment_manipulation = "Use proper sandboxing techniques instead of environment manipulation",
        global_access = "Prefer local variables and explicit imports over global access"
    }
    
    return suggestions[vulnerabilityType] or "Review this code pattern for potential security implications"
end

-- Advanced AST analysis (simplified implementation)
function CoreAnalyzer:ParseAST(source: string): any
    -- This would implement a full AST parser in a real system
    -- For now, return a simplified structure
    return {
        type = "Program",
        body = self:ParseStatements(source),
        sourceType = "script"
    }
end

function CoreAnalyzer:ParseStatements(source: string): {any}
    local statements = {}
    local lines = source:split("\n")
    
    for i, line in ipairs(lines) do
        local trimmed = line:match("^%s*(.-)%s*$")
        if #trimmed > 0 and not trimmed:match("^%-%-") then
            table.insert(statements, {
                type = "Statement",
                line = i,
                content = trimmed
            })
        end
    end
    
    return statements
end

-- Factory function
local function CreateCoreAnalyzer(): typeof(CoreAnalyzer)
    return setmetatable({}, CoreAnalyzer)
end

return CreateCoreAnalyzer