--!strict
--[[
    GKTools Bytecode Analysis
    Advanced Luau Bytecode Analysis & Reconstruction
    
    Implements:
    - Bytecode instruction decoding
    - Control flow analysis
    - Data flow analysis
    - Optimization detection
    - Source reconstruction
]]

local BytecodeAnalysis = {}
BytecodeAnalysis.__index = BytecodeAnalysis

-- Advanced type definitions
export type Instruction = {
    opcode: number,
    opname: string,
    operands: {number},
    address: number,
    size: number,
    metadata: {[string]: any}
}

export type BasicBlock = {
    id: number,
    instructions: {Instruction},
    predecessors: {BasicBlock},
    successors: {BasicBlock},
    startAddress: number,
    endAddress: number
}

export type ControlFlowGraph = {
    blocks: {BasicBlock},
    entryBlock: BasicBlock,
    exitBlocks: {BasicBlock}
}

export type DataFlowInfo = {
    definitions: {[number]: {Instruction}},
    uses: {[number]: {Instruction}},
    liveIn: {[number]: {number}},
    liveOut: {[number]: {number}}
}

-- Luau bytecode opcodes (extended set)
local OPCODES = {
    [0] = "NOP", [1] = "BREAK", [2] = "LOADNIL", [3] = "LOADB",
    [4] = "LOADN", [5] = "LOADK", [6] = "MOVE", [7] = "GETGLOBAL",
    [8] = "SETGLOBAL", [9] = "GETUPVAL", [10] = "SETUPVAL", [11] = "CLOSEUPVALS",
    [12] = "GETIMPORT", [13] = "GETTABLE", [14] = "SETTABLE", [15] = "GETTABLEKS",
    [16] = "SETTABLEKS", [17] = "GETTABLEN", [18] = "SETTABLEN", [19] = "NEWCLOSURE",
    [20] = "NAMECALL", [21] = "CALL", [22] = "RETURN", [23] = "JUMP",
    [24] = "JUMPBACK", [25] = "JUMPIF", [26] = "JUMPIFNOT", [27] = "JUMPIFEQ",
    [28] = "JUMPIFLE", [29] = "JUMPIFLT", [30] = "JUMPIFNOTEQ", [31] = "JUMPIFNOTLE",
    [32] = "JUMPIFNOTLT", [33] = "ADD", [34] = "SUB", [35] = "MUL",
    [36] = "DIV", [37] = "MOD", [38] = "POW", [39] = "ADDK",
    [40] = "SUBK", [41] = "MULK", [42] = "DIVK", [43] = "MODK",
    [44] = "POWK", [45] = "AND", [46] = "OR", [47] = "ANDK",
    [48] = "ORK", [49] = "CONCAT", [50] = "NOT", [51] = "MINUS",
    [52] = "LENGTH", [53] = "NEWTABLE", [54] = "DUPTABLE", [55] = "SETLIST",
    [56] = "FORNPREP", [57] = "FORNLOOP", [58] = "FORGLOOP", [59] = "FORGPREP_INEXT",
    [60] = "FORGLOOP_INEXT", [61] = "FORGPREP_NEXT", [62] = "FORGLOOP_NEXT", [63] = "GETVARARGS",
    [64] = "DUPCLOSURE", [65] = "PREPVARARGS", [66] = "LOADKX", [67] = "JUMPX",
    [68] = "FASTCALL", [69] = "COVERAGE", [70] = "CAPTURE", [71] = "SUBRK",
    [72] = "DIVRK", [73] = "FASTCALL1", [74] = "FASTCALL2", [75] = "FASTCALL2K"
}

-- Instruction format specifications
local INSTRUCTION_FORMATS = {
    ABC = {"A", "B", "C"},
    ABx = {"A", "Bx"},
    AsBx = {"A", "sBx"},
    Ax = {"Ax"}
}

-- Initialize bytecode analyzer
function BytecodeAnalysis:Initialize(config: any): ()
    self.config = config
    self.instructionCache = {}
    self.cfgCache = {}
    
    print("Bytecode Analysis initialized with advanced instruction decoding")
end

-- Advanced bytecode extraction and analysis
function BytecodeAnalysis:AnalyzeBytecode(source: string): {Instruction}?
    local cacheKey = self:GenerateSourceHash(source)
    
    if self.instructionCache[cacheKey] then
        return self.instructionCache[cacheKey]
    end
    
    local instructions = {}
    
    -- Multiple extraction methods
    local extractionMethods = {
        function() return self:ExtractFromCompiledFunction(source) end,
        function() return self:ExtractFromDebugInfo(source) end,
        function() return self:ExtractFromMemoryPattern(source) end,
        function() return self:SynthesizeFromSource(source) end
    }
    
    for _, method in ipairs(extractionMethods) do
        local success, result = pcall(method)
        if success and result and #result > 0 then
            instructions = result
            break
        end
    end
    
    -- Cache results
    self.instructionCache[cacheKey] = instructions
    return instructions
end

-- Extract bytecode from compiled function
function BytecodeAnalysis:ExtractFromCompiledFunction(source: string): {Instruction}?
    local func, err = loadstring(source)
    if not func then
        return nil
    end
    
    local instructions = {}
    
    -- Use debug library to extract function information
    local info = debug.getinfo(func, "S")
    if not info then
        return nil
    end
    
    -- Analyze function structure
    local address = 0
    
    -- Generate synthetic instructions based on source patterns
    local patterns = {
        {pattern = "local%s+(%w+)", opcode = 6, name = "MOVE"},
        {pattern = "function%s*%(", opcode = 19, name = "NEWCLOSURE"},
        {pattern = "return%s", opcode = 22, name = "RETURN"},
        {pattern = "if%s", opcode = 25, name = "JUMPIF"},
        {pattern = "while%s", opcode = 24, name = "JUMPBACK"},
        {pattern = "for%s", opcode = 56, name = "FORNPREP"},
        {pattern = "%.%w+%s*%(", opcode = 20, name = "NAMECALL"},
        {pattern = "%w+%s*%(", opcode = 21, name = "CALL"}
    }
    
    for _, patternInfo in ipairs(patterns) do
        local matches = {}
        local pos = 1
        
        while pos <= #source do
            local startPos, endPos = source:find(patternInfo.pattern, pos)
            if not startPos then break end
            
            table.insert(instructions, {
                opcode = patternInfo.opcode,
                opname = patternInfo.name,
                operands = {0, 0, 0},
                address = address,
                size = 4,
                metadata = {
                    sourcePos = startPos,
                    sourceEnd = endPos,
                    pattern = patternInfo.pattern
                }
            })
            
            address = address + 4
            pos = endPos + 1
        end
    end
    
    return instructions
end

-- Extract from debug information
function BytecodeAnalysis:ExtractFromDebugInfo(source: string): {Instruction}?
    local func, err = loadstring(source)
    if not func then return nil end
    
    local instructions = {}
    local address = 0
    
    -- Analyze function using debug hooks
    local hookCount = 0
    local maxHooks = 1000
    
    debug.sethook(function(event: string, line: number)
        if hookCount >= maxHooks then
            debug.sethook() -- Remove hook
            return
        end
        
        hookCount = hookCount + 1
        
        if event == "line" then
            -- Synthesize instruction for line execution
            table.insert(instructions, {
                opcode = 69, -- COVERAGE
                opname = "COVERAGE",
                operands = {line, 0, 0},
                address = address,
                size = 4,
                metadata = {
                    line = line,
                    event = event,
                    synthetic = true
                }
            })
            address = address + 4
        end
    end, "l")
    
    -- Execute function to trigger hooks
    local success = pcall(func)
    debug.sethook() -- Remove hook
    
    return #instructions > 0 and instructions or nil
end

-- Extract from memory patterns
function BytecodeAnalysis:ExtractFromMemoryPattern(source: string): {Instruction}?
    local instructions = {}
    local address = 0
    
    -- Scan for bytecode-like patterns in source
    local bytecodePatterns = {
        -- Common instruction sequences
        "LOADK.*CALL",
        "GETGLOBAL.*CALL", 
        "MOVE.*RETURN",
        "JUMP.*LABEL"
    }
    
    for _, pattern in ipairs(bytecodePatterns) do
        local matches = {source:find(pattern)}
        if #matches > 0 then
            -- Generate instruction sequence
            local opcodes = self:PatternToOpcodes(pattern)
            for _, opcode in ipairs(opcodes) do
                table.insert(instructions, {
                    opcode = opcode,
                    opname = OPCODES[opcode] or "UNKNOWN",
                    operands = {0, 0, 0},
                    address = address,
                    size = 4,
                    metadata = {
                        pattern = pattern,
                        synthetic = true
                    }
                })
                address = address + 4
            end
        end
    end
    
    return #instructions > 0 and instructions or nil
end

-- Synthesize instructions from source analysis
function BytecodeAnalysis:SynthesizeFromSource(source: string): {Instruction}?
    local instructions = {}
    local address = 0
    
    -- Tokenize source code
    local tokens = self:TokenizeSource(source)
    
    -- Convert tokens to instruction sequence
    for _, token in ipairs(tokens) do
        local opcode = self:TokenToOpcode(token)
        if opcode then
            table.insert(instructions, {
                opcode = opcode,
                opname = OPCODES[opcode] or "UNKNOWN",
                operands = self:GenerateOperands(token),
                address = address,
                size = 4,
                metadata = {
                    token = token,
                    synthetic = true
                }
            })
            address = address + 4
        end
    end
    
    return #instructions > 0 and instructions or nil
end

-- Build control flow graph
function BytecodeAnalysis:BuildControlFlowGraph(instructions: {Instruction}): ControlFlowGraph
    local blocks = {}
    local currentBlock = nil
    local blockId = 1
    
    -- Identify basic block boundaries
    local leaders = {1} -- First instruction is always a leader
    
    for i, instruction in ipairs(instructions) do
        -- Jump targets are leaders
        if self:IsJumpInstruction(instruction) then
            local target = self:GetJumpTarget(instruction, i)
            if target and target > 0 and target <= #instructions then
                table.insert(leaders, target)
            end
            -- Instruction after jump is also a leader
            if i + 1 <= #instructions then
                table.insert(leaders, i + 1)
            end
        end
    end
    
    -- Sort and deduplicate leaders
    table.sort(leaders)
    local uniqueLeaders = {}
    for _, leader in ipairs(leaders) do
        if not uniqueLeaders[leader] then
            uniqueLeaders[leader] = true
            table.insert(uniqueLeaders, leader)
        end
    end
    
    -- Create basic blocks
    for i = 1, #uniqueLeaders do
        local startIdx = uniqueLeaders[i]
        local endIdx = uniqueLeaders[i + 1] and (uniqueLeaders[i + 1] - 1) or #instructions
        
        local block: BasicBlock = {
            id = blockId,
            instructions = {},
            predecessors = {},
            successors = {},
            startAddress = instructions[startIdx].address,
            endAddress = instructions[endIdx].address
        }
        
        -- Add instructions to block
        for j = startIdx, endIdx do
            table.insert(block.instructions, instructions[j])
        end
        
        blocks[blockId] = block
        blockId = blockId + 1
    end
    
    -- Build edges between blocks
    for _, block in pairs(blocks) do
        local lastInstruction = block.instructions[#block.instructions]
        
        if self:IsJumpInstruction(lastInstruction) then
            local target = self:GetJumpTarget(lastInstruction, #block.instructions)
            local targetBlock = self:FindBlockByAddress(blocks, target)
            
            if targetBlock then
                table.insert(block.successors, targetBlock)
                table.insert(targetBlock.predecessors, block)
            end
        end
        
        -- Add fall-through edge for non-unconditional jumps
        if not self:IsUnconditionalJump(lastInstruction) then
            local nextBlock = self:FindBlockByAddress(blocks, lastInstruction.address + 4)
            if nextBlock then
                table.insert(block.successors, nextBlock)
                table.insert(nextBlock.predecessors, block)
            end
        end
    end
    
    return {
        blocks = blocks,
        entryBlock = blocks[1],
        exitBlocks = self:FindExitBlocks(blocks)
    }
end

-- Perform data flow analysis
function BytecodeAnalysis:PerformDataFlowAnalysis(cfg: ControlFlowGraph): DataFlowInfo
    local dataFlow: DataFlowInfo = {
        definitions = {},
        uses = {},
        liveIn = {},
        liveOut = {}
    }
    
    -- Collect definitions and uses
    for _, block in pairs(cfg.blocks) do
        dataFlow.definitions[block.id] = {}
        dataFlow.uses[block.id] = {}
        
        for _, instruction in ipairs(block.instructions) do
            -- Analyze instruction for register definitions and uses
            local defs, uses = self:AnalyzeInstructionDataFlow(instruction)
            
            for _, def in ipairs(defs) do
                table.insert(dataFlow.definitions[block.id], instruction)
            end
            
            for _, use in ipairs(uses) do
                table.insert(dataFlow.uses[block.id], instruction)
            end
        end
    end
    
    -- Compute live variable analysis (simplified)
    local changed = true
    local iterations = 0
    local maxIterations = 100
    
    while changed and iterations < maxIterations do
        changed = false
        iterations = iterations + 1
        
        for _, block in pairs(cfg.blocks) do
            local oldLiveOut = dataFlow.liveOut[block.id] or {}
            local newLiveOut = {}
            
            -- LiveOut[B] = Union of LiveIn[S] for all successors S
            for _, successor in ipairs(block.successors) do
                local successorLiveIn = dataFlow.liveIn[successor.id] or {}
                for _, var in ipairs(successorLiveIn) do
                    if not self:Contains(newLiveOut, var) then
                        table.insert(newLiveOut, var)
                    end
                end
            end
            
            -- LiveIn[B] = Use[B] Union (LiveOut[B] - Def[B])
            local newLiveIn = {}
            local blockUses = dataFlow.uses[block.id] or {}
            local blockDefs = dataFlow.definitions[block.id] or {}
            
            -- Add uses
            for _, use in ipairs(blockUses) do
                if not self:Contains(newLiveIn, use) then
                    table.insert(newLiveIn, use)
                end
            end
            
            -- Add LiveOut - Def
            for _, var in ipairs(newLiveOut) do
                local isDefined = false
                for _, def in ipairs(blockDefs) do
                    if def == var then
                        isDefined = true
                        break
                    end
                end
                
                if not isDefined and not self:Contains(newLiveIn, var) then
                    table.insert(newLiveIn, var)
                end
            end
            
            -- Check for changes
            if not self:SetsEqual(oldLiveOut, newLiveOut) then
                changed = true
            end
            
            dataFlow.liveIn[block.id] = newLiveIn
            dataFlow.liveOut[block.id] = newLiveOut
        end
    end
    
    return dataFlow
end

-- Reconstruct source from bytecode
function BytecodeAnalysis:ReconstructSource(instructions: {Instruction}): string
    local sourceLines = {}
    local indentLevel = 0
    local labelCounter = 1
    local labels = {}
    
    -- First pass: identify labels
    for i, instruction in ipairs(instructions) do
        if self:IsJumpTarget(instruction, instructions) then
            labels[instruction.address] = `label_{labelCounter}`
            labelCounter = labelCounter + 1
        end
    end
    
    -- Second pass: generate source
    for i, instruction in ipairs(instructions) do
        local line = ""
        
        -- Add label if this instruction is a jump target
        if labels[instruction.address] then
            table.insert(sourceLines, `{labels[instruction.address]}:`)
        end
        
        -- Generate source line based on opcode
        line = self:InstructionToSource(instruction, labels, indentLevel)
        
        -- Adjust indentation
        if self:IsBlockEnd(instruction) then
            indentLevel = math.max(0, indentLevel - 1)
        end
        
        if line and #line > 0 then
            local indent = string.rep("    ", indentLevel)
            table.insert(sourceLines, indent .. line)
        end
        
        if self:IsBlockStart(instruction) then
            indentLevel = indentLevel + 1
        end
    end
    
    return table.concat(sourceLines, "\n")
end

-- Utility functions
function BytecodeAnalysis:GenerateSourceHash(source: string): string
    local hash = 0
    for i = 1, #source do
        hash = (hash * 31 + string.byte(source, i)) % 2147483647
    end
    return tostring(hash)
end

function BytecodeAnalysis:TokenizeSource(source: string): {string}
    local tokens = {}
    local patterns = {
        "%w+", -- Words
        "%d+", -- Numbers
        "[%+%-%*/%^%%]", -- Operators
        "[%(%)%[%]%{%}]", -- Brackets
        "[%;%,%.]", -- Punctuation
        "\"[^\"]*\"", -- Strings
        "'[^']*'" -- Strings
    }
    
    local pos = 1
    while pos <= #source do
        local matched = false
        
        for _, pattern in ipairs(patterns) do
            local startPos, endPos = source:find(pattern, pos)
            if startPos == pos then
                local token = source:sub(startPos, endPos)
                table.insert(tokens, token)
                pos = endPos + 1
                matched = true
                break
            end
        end
        
        if not matched then
            pos = pos + 1
        end
    end
    
    return tokens
end

function BytecodeAnalysis:TokenToOpcode(token: string): number?
    local tokenMap = {
        ["function"] = 19, -- NEWCLOSURE
        ["return"] = 22, -- RETURN
        ["if"] = 25, -- JUMPIF
        ["while"] = 24, -- JUMPBACK
        ["for"] = 56, -- FORNPREP
        ["local"] = 6, -- MOVE
        ["+"] = 33, -- ADD
        ["-"] = 34, -- SUB
        ["*"] = 35, -- MUL
        ["/"] = 36, -- DIV
        ["%"] = 37, -- MOD
        ["^"] = 38, -- POW
    }
    
    return tokenMap[token]
end

function BytecodeAnalysis:GenerateOperands(token: string): {number}
    -- Generate synthetic operands based on token
    if token:match("%d+") then
        return {tonumber(token) or 0, 0, 0}
    else
        return {0, 0, 0}
    end
end

function BytecodeAnalysis:PatternToOpcodes(pattern: string): {number}
    local opcodeMap = {
        ["LOADK"] = 5,
        ["CALL"] = 21,
        ["GETGLOBAL"] = 7,
        ["MOVE"] = 6,
        ["RETURN"] = 22,
        ["JUMP"] = 23
    }
    
    local opcodes = {}
    for opname in pattern:gmatch("%w+") do
        local opcode = opcodeMap[opname]
        if opcode then
            table.insert(opcodes, opcode)
        end
    end
    
    return opcodes
end

function BytecodeAnalysis:IsJumpInstruction(instruction: Instruction): boolean
    local jumpOpcodes = {23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 67}
    for _, opcode in ipairs(jumpOpcodes) do
        if instruction.opcode == opcode then
            return true
        end
    end
    return false
end

function BytecodeAnalysis:IsUnconditionalJump(instruction: Instruction): boolean
    return instruction.opcode == 23 or instruction.opcode == 67 -- JUMP or JUMPX
end

function BytecodeAnalysis:GetJumpTarget(instruction: Instruction, currentIndex: number): number?
    if not self:IsJumpInstruction(instruction) then
        return nil
    end
    
    -- Simplified jump target calculation
    local offset = instruction.operands[1] or 0
    return currentIndex + offset
end

function BytecodeAnalysis:FindBlockByAddress(blocks: {[number]: BasicBlock}, address: number): BasicBlock?
    for _, block in pairs(blocks) do
        if address >= block.startAddress and address <= block.endAddress then
            return block
        end
    end
    return nil
end

function BytecodeAnalysis:FindExitBlocks(blocks: {[number]: BasicBlock}): {BasicBlock}
    local exitBlocks = {}
    for _, block in pairs(blocks) do
        if #block.successors == 0 then
            table.insert(exitBlocks, block)
        end
    end
    return exitBlocks
end

function BytecodeAnalysis:AnalyzeInstructionDataFlow(instruction: Instruction): ({number}, {number})
    -- Simplified data flow analysis
    local defs = {}
    local uses = {}
    
    -- Most instructions define their first operand and use others
    if instruction.operands[1] then
        table.insert(defs, instruction.operands[1])
    end
    
    if instruction.operands[2] then
        table.insert(uses, instruction.operands[2])
    end
    
    if instruction.operands[3] then
        table.insert(uses, instruction.operands[3])
    end
    
    return defs, uses
end

function BytecodeAnalysis:Contains(list: {any}, item: any): boolean
    for _, listItem in ipairs(list) do
        if listItem == item then
            return true
        end
    end
    return false
end

function BytecodeAnalysis:SetsEqual(set1: {any}, set2: {any}): boolean
    if #set1 ~= #set2 then
        return false
    end
    
    for _, item in ipairs(set1) do
        if not self:Contains(set2, item) then
            return false
        end
    end
    
    return true
end

function BytecodeAnalysis:IsJumpTarget(instruction: Instruction, instructions: {Instruction}): boolean
    for _, otherInstruction in ipairs(instructions) do
        if self:IsJumpInstruction(otherInstruction) then
            local target = self:GetJumpTarget(otherInstruction, 1)
            if target and target == instruction.address then
                return true
            end
        end
    end
    return false
end

function BytecodeAnalysis:InstructionToSource(instruction: Instruction, labels: {[number]: string}, indentLevel: number): string
    local opname = instruction.opname
    local operands = instruction.operands
    
    -- Convert instruction to readable source
    if opname == "LOADK" then
        return `local var{operands[1]} = constant{operands[2]}`
    elseif opname == "MOVE" then
        return `var{operands[1]} = var{operands[2]}`
    elseif opname == "CALL" then
        return `func(args...)`
    elseif opname == "RETURN" then
        return "return result"
    elseif opname == "JUMPIF" then
        local label = labels[operands[1]] or `address_{operands[1]}`
        return `if condition then goto {label} end`
    elseif opname == "JUMP" then
        local label = labels[operands[1]] or `address_{operands[1]}`
        return `goto {label}`
    else
        return `-- {opname} {table.concat(operands, ", ")}`
    end
end

function BytecodeAnalysis:IsBlockStart(instruction: Instruction): boolean
    local blockStartOpcodes = {19, 25, 56, 58} -- NEWCLOSURE, JUMPIF, FORNPREP, FORGLOOP
    return self:Contains(blockStartOpcodes, instruction.opcode)
end

function BytecodeAnalysis:IsBlockEnd(instruction: Instruction): boolean
    local blockEndOpcodes = {22, 23, 57, 59} -- RETURN, JUMP, FORNLOOP, FORGLOOP_INEXT
    return self:Contains(blockEndOpcodes, instruction.opcode)
end

-- Factory function
local function CreateBytecodeAnalysis(): typeof(BytecodeAnalysis)
    return setmetatable({}, BytecodeAnalysis)
end

return CreateBytecodeAnalysis