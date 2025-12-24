--!strict
--[[
    GKTools UI Components
    Advanced Interactive Components
    
    Provides:
    - Tree view components
    - Code editor enhancements
    - Modal dialogs
    - Progress indicators
    - Advanced controls
]]

local UIComponents = {}
UIComponents.__index = UIComponents

-- Advanced type definitions
export type TreeNode = {
    id: string,
    text: string,
    icon: string?,
    expanded: boolean,
    children: {TreeNode},
    data: any,
    parent: TreeNode?
}

export type TreeViewConfig = {
    showIcons: boolean,
    allowMultiSelect: boolean,
    showCheckboxes: boolean,
    indentSize: number
}

-- Initialize components
function UIComponents:Initialize(framework: any): ()
    self.framework = framework
    self.theme = framework.theme
    self.treeNodes = {}
    self.selectedNodes = {}
    
    print("UI Components initialized with advanced interactive elements")
end

-- Advanced Tree View Component
function UIComponents:CreateTreeView(parent: GuiObject, config: TreeViewConfig?): ScrollingFrame
    local defaultConfig: TreeViewConfig = {
        showIcons = true,
        allowMultiSelect = false,
        showCheckboxes = false,
        indentSize = 20
    }
    
    local treeConfig = config or defaultConfig
    
    local treeView = Instance.new("ScrollingFrame")
    treeView.Name = "TreeView"
    treeView.Size = UDim2.new(1, 0, 1, 0)
    treeView.Position = UDim2.new(0, 0, 0, 0)
    treeView.BackgroundTransparency = 1
    treeView.BorderSizePixel = 0
    treeView.ScrollBarThickness = 8
    treeView.ScrollBarImageColor3 = self.theme.colors.border
    treeView.CanvasSize = UDim2.new(0, 0, 0, 0)
    treeView.Parent = parent
    
    -- Tree layout
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 1)
    layout.Parent = treeView
    
    -- Auto-resize canvas
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        treeView.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    end)
    
    return treeView
end

-- Create tree node component
function UIComponents:CreateTreeNode(nodeData: TreeNode, parent: GuiObject, depth: number): Frame
    local node = Instance.new("Frame")
    node.Name = `TreeNode_{nodeData.id}`
    node.Size = UDim2.new(1, 0, 0, 25)
    node.BackgroundTransparency = 1
    node.BorderSizePixel = 0
    node.Parent = parent
    
    -- Node button
    local nodeButton = Instance.new("TextButton")
    nodeButton.Name = "NodeButton"
    nodeButton.Size = UDim2.new(1, 0, 1, 0)
    nodeButton.Position = UDim2.new(0, depth * 20, 0, 0)
    nodeButton.BackgroundTransparency = 1
    nodeButton.BorderSizePixel = 0
    nodeButton.Text = ""
    nodeButton.Parent = node
    
    -- Expand/collapse button
    if #nodeData.children > 0 then
        local expandButton = Instance.new("TextButton")
        expandButton.Name = "ExpandButton"
        expandButton.Size = UDim2.new(0, 15, 0, 15)
        expandButton.Position = UDim2.new(0, depth * 20, 0.5, -7.5)
        expandButton.BackgroundColor3 = self.theme.colors.primary
        expandButton.BorderSizePixel = 0
        expandButton.Text = nodeData.expanded and "−" or "+"
        expandButton.TextColor3 = self.theme.colors.text
        expandButton.Font = self.theme.fonts.primary
        expandButton.TextSize = 10
        expandButton.Parent = node
        
        -- Corner rounding
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 2)
        corner.Parent = expandButton
        
        -- Expand/collapse functionality
        expandButton.MouseButton1Click:Connect(function()
            self:ToggleNodeExpansion(nodeData, expandButton)
        end)
    end
    
    -- Node icon
    if nodeData.icon then
        local icon = Instance.new("TextLabel")
        icon.Name = "Icon"
        icon.Size = UDim2.new(0, 20, 0, 20)
        icon.Position = UDim2.new(0, depth * 20 + 20, 0.5, -10)
        icon.BackgroundTransparency = 1
        icon.Text = nodeData.icon
        icon.TextColor3 = self.theme.colors.primary
        icon.Font = self.theme.fonts.primary
        icon.TextSize = 14
        icon.Parent = node
    end
    
    -- Node text
    local nodeText = Instance.new("TextLabel")
    nodeText.Name = "NodeText"
    nodeText.Size = UDim2.new(1, -(depth * 20 + 45), 1, 0)
    nodeText.Position = UDim2.new(0, depth * 20 + 45, 0, 0)
    nodeText.BackgroundTransparency = 1
    nodeText.Text = nodeData.text
    nodeText.TextColor3 = self.theme.colors.text
    nodeText.TextXAlignment = Enum.TextXAlignment.Left
    nodeText.Font = self.theme.fonts.primary
    nodeText.TextSize = 12
    nodeText.TextTruncate = Enum.TextTruncate.AtEnd
    nodeText.Parent = node
    
    -- Selection handling
    nodeButton.MouseButton1Click:Connect(function()
        self:SelectNode(nodeData, node)
    end)
    
    -- Hover effects
    nodeButton.MouseEnter:Connect(function()
        node.BackgroundColor3 = self.theme.colors.surface
        node.BackgroundTransparency = 0.5
    end)
    
    nodeButton.MouseLeave:Connect(function()
        if not self:IsNodeSelected(nodeData) then
            node.BackgroundTransparency = 1
        end
    end)
    
    -- Store node reference
    self.treeNodes[nodeData.id] = {
        data = nodeData,
        frame = node,
        depth = depth
    }
    
    return node
end

-- Toggle node expansion
function UIComponents:ToggleNodeExpansion(nodeData: TreeNode, expandButton: TextButton): ()
    nodeData.expanded = not nodeData.expanded
    expandButton.Text = nodeData.expanded and "−" or "+"
    
    -- Refresh tree view to show/hide children
    self:RefreshTreeView()
end

-- Select node
function UIComponents:SelectNode(nodeData: TreeNode, nodeFrame: Frame): ()
    -- Clear previous selection if not multi-select
    if not self.config or not self.config.allowMultiSelect then
        for _, selectedNode in pairs(self.selectedNodes) do
            selectedNode.frame.BackgroundTransparency = 1
        end
        self.selectedNodes = {}
    end
    
    -- Add to selection
    self.selectedNodes[nodeData.id] = self.treeNodes[nodeData.id]
    nodeFrame.BackgroundColor3 = self.theme.colors.primary
    nodeFrame.BackgroundTransparency = 0.3
    
    -- Notify framework of selection
    if self.framework and self.framework.OnNodeSelected then
        self.framework:OnNodeSelected(nodeData)
    end
end

-- Check if node is selected
function UIComponents:IsNodeSelected(nodeData: TreeNode): boolean
    return self.selectedNodes[nodeData.id] ~= nil
end

-- Refresh tree view
function UIComponents:RefreshTreeView(): ()
    -- This would rebuild the tree view based on current node states
    -- Implementation would iterate through all nodes and update visibility
end

-- Code Editor Component with Syntax Highlighting
function UIComponents:CreateCodeEditor(parent: GuiObject): Frame
    local editor = Instance.new("Frame")
    editor.Name = "CodeEditor"
    editor.Size = UDim2.new(1, 0, 1, 0)
    editor.Position = UDim2.new(0, 0, 0, 0)
    editor.BackgroundColor3 = self.theme.colors.background
    editor.BorderSizePixel = 0
    editor.Parent = parent
    
    -- Line numbers panel
    local lineNumbersPanel = Instance.new("Frame")
    lineNumbersPanel.Name = "LineNumbers"
    lineNumbersPanel.Size = UDim2.new(0, 50, 1, 0)
    lineNumbersPanel.Position = UDim2.new(0, 0, 0, 0)
    lineNumbersPanel.BackgroundColor3 = self.theme.colors.surface
    lineNumbersPanel.BorderSizePixel = 0
    lineNumbersPanel.Parent = editor
    
    -- Line numbers text
    local lineNumbers = Instance.new("TextLabel")
    lineNumbers.Name = "LineNumbersText"
    lineNumbers.Size = UDim2.new(1, -5, 1, 0)
    lineNumbers.Position = UDim2.new(0, 0, 0, 0)
    lineNumbers.BackgroundTransparency = 1
    lineNumbers.Text = self:GenerateLineNumbers(50)
    lineNumbers.TextColor3 = self.theme.colors.textSecondary
    lineNumbers.TextXAlignment = Enum.TextXAlignment.Right
    lineNumbers.TextYAlignment = Enum.TextYAlignment.Top
    lineNumbers.Font = self.theme.fonts.monospace
    lineNumbers.TextSize = 11
    lineNumbers.Parent = lineNumbersPanel
    
    -- Code area
    local codeArea = Instance.new("ScrollingFrame")
    codeArea.Name = "CodeArea"
    codeArea.Size = UDim2.new(1, -55, 1, 0)
    codeArea.Position = UDim2.new(0, 55, 0, 0)
    codeArea.BackgroundTransparency = 1
    codeArea.BorderSizePixel = 0
    codeArea.ScrollBarThickness = 8
    codeArea.ScrollBarImageColor3 = self.theme.colors.border
    codeArea.Parent = editor
    
    -- Code text box
    local codeText = Instance.new("TextBox")
    codeText.Name = "CodeText"
    codeText.Size = UDim2.new(1, 0, 1, 0)
    codeText.Position = UDim2.new(0, 0, 0, 0)
    codeText.BackgroundTransparency = 1
    codeText.BorderSizePixel = 0
    codeText.Text = "-- Select a script to view its source code"
    codeText.TextColor3 = self.theme.colors.text
    codeText.TextXAlignment = Enum.TextXAlignment.Left
    codeText.TextYAlignment = Enum.TextYAlignment.Top
    codeText.Font = self.theme.fonts.monospace
    codeText.TextSize = 12
    codeText.MultiLine = true
    codeText.ClearTextOnFocus = false
    codeText.TextWrapped = false
    codeText.Parent = codeArea
    
    -- Syntax highlighting overlay
    local syntaxHighlight = Instance.new("TextLabel")
    syntaxHighlight.Name = "SyntaxHighlight"
    syntaxHighlight.Size = UDim2.new(1, 0, 1, 0)
    syntaxHighlight.Position = UDim2.new(0, 0, 0, 0)
    syntaxHighlight.BackgroundTransparency = 1
    syntaxHighlight.BorderSizePixel = 0
    syntaxHighlight.Text = ""
    syntaxHighlight.TextColor3 = self.theme.colors.text
    syntaxHighlight.TextXAlignment = Enum.TextXAlignment.Left
    syntaxHighlight.TextYAlignment = Enum.TextYAlignment.Top
    syntaxHighlight.Font = self.theme.fonts.monospace
    syntaxHighlight.TextSize = 12
    syntaxHighlight.RichText = true
    syntaxHighlight.Parent = codeArea
    
    -- Update syntax highlighting when text changes
    codeText:GetPropertyChangedSignal("Text"):Connect(function()
        self:UpdateSyntaxHighlighting(codeText.Text, syntaxHighlight)
        self:UpdateLineNumbers(codeText.Text, lineNumbers)
    end)
    
    return editor
end

-- Generate line numbers
function UIComponents:GenerateLineNumbers(maxLines: number): string
    local lines = {}
    for i = 1, maxLines do
        table.insert(lines, tostring(i))
    end
    return table.concat(lines, "\n")
end

-- Update line numbers based on content
function UIComponents:UpdateLineNumbers(text: string, lineNumbersLabel: TextLabel): ()
    local lines = text:split("\n")
    local lineNumbers = {}
    
    for i = 1, #lines do
        table.insert(lineNumbers, tostring(i))
    end
    
    lineNumbersLabel.Text = table.concat(lineNumbers, "\n")
end

-- Advanced syntax highlighting
function UIComponents:UpdateSyntaxHighlighting(text: string, highlightLabel: TextLabel): ()
    local highlighted = text
    
    -- Lua keywords
    local keywords = {
        "and", "break", "do", "else", "elseif", "end", "false", "for",
        "function", "if", "in", "local", "nil", "not", "or", "repeat",
        "return", "then", "true", "until", "while"
    }
    
    -- Apply keyword highlighting
    for _, keyword in ipairs(keywords) do
        highlighted = highlighted:gsub(`%f[%w]{keyword}%f[%W]`, `<font color="rgb(100,150,255)">{keyword}</font>`)
    end
    
    -- String highlighting
    highlighted = highlighted:gsub(`"([^"]*)"`, `<font color="rgb(150,255,150)">"$1"</font>`)
    highlighted = highlighted:gsub(`'([^']*)'`, `<font color="rgb(150,255,150)">'$1'</font>`)
    
    -- Comment highlighting
    highlighted = highlighted:gsub(`(%-%-[^\n]*)`, `<font color="rgb(150,150,150)">$1</font>`)
    
    -- Number highlighting
    highlighted = highlighted:gsub(`%f[%d]%d+%.?%d*%f[%D]`, `<font color="rgb(255,150,100)">$0</font>`)
    
    highlightLabel.Text = highlighted
end

-- Modal Dialog Component
function UIComponents:CreateModal(title: string, content: GuiObject, size: UDim2?): Frame
    -- Background overlay
    local overlay = Instance.new("Frame")
    overlay.Name = "ModalOverlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.Position = UDim2.new(0, 0, 0, 0)
    overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 500
    overlay.Parent = self.framework.screenGui
    
    -- Modal window
    local modal = Instance.new("Frame")
    modal.Name = "Modal"
    modal.Size = size or UDim2.new(0, 400, 0, 300)
    modal.Position = UDim2.new(0.5, -200, 0.5, -150)
    modal.BackgroundColor3 = self.theme.colors.surface
    modal.BorderSizePixel = 0
    modal.ZIndex = 501
    modal.Parent = overlay
    
    -- Corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = modal
    
    -- Modal title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = self.theme.colors.primary
    titleBar.BorderSizePixel = 0
    titleBar.Parent = modal
    
    -- Title text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Size = UDim2.new(1, -40, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = title
    titleText.TextColor3 = self.theme.colors.text
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Font = self.theme.fonts.secondary
    titleText.TextSize = 14
    titleText.Parent = titleBar
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = self.theme.colors.error
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextColor3 = self.theme.colors.text
    closeButton.Font = self.theme.fonts.primary
    closeButton.TextSize = 16
    closeButton.Parent = titleBar
    
    -- Close button corner
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeButton
    
    -- Content area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -20, 1, -60)
    contentArea.Position = UDim2.new(0, 10, 0, 50)
    contentArea.BackgroundTransparency = 1
    contentArea.BorderSizePixel = 0
    contentArea.Parent = modal
    
    -- Add content
    if content then
        content.Parent = contentArea
    end
    
    -- Close functionality
    closeButton.MouseButton1Click:Connect(function()
        overlay:Destroy()
    end)
    
    -- Close on overlay click
    overlay.InputBegan:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            overlay:Destroy()
        end
    end)
    
    return modal
end

-- Progress Bar Component
function UIComponents:CreateProgressBar(parent: GuiObject, initialValue: number?): Frame
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.new(1, 0, 0, 20)
    progressBar.Position = UDim2.new(0, 0, 0, 0)
    progressBar.BackgroundColor3 = self.theme.colors.surface
    progressBar.BorderSizePixel = 1
    progressBar.BorderColor3 = self.theme.colors.border
    progressBar.Parent = parent
    
    -- Progress fill
    local progressFill = Instance.new("Frame")
    progressFill.Name = "ProgressFill"
    progressFill.Size = UDim2.new(initialValue or 0, 0, 1, 0)
    progressFill.Position = UDim2.new(0, 0, 0, 0)
    progressFill.BackgroundColor3 = self.theme.colors.primary
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressBar
    
    -- Progress text
    local progressText = Instance.new("TextLabel")
    progressText.Name = "ProgressText"
    progressText.Size = UDim2.new(1, 0, 1, 0)
    progressText.Position = UDim2.new(0, 0, 0, 0)
    progressText.BackgroundTransparency = 1
    progressText.Text = `{math.floor((initialValue or 0) * 100)}%`
    progressText.TextColor3 = self.theme.colors.text
    progressText.Font = self.theme.fonts.primary
    progressText.TextSize = 11
    progressText.Parent = progressBar
    
    -- Update function
    progressBar.UpdateProgress = function(value: number)
        value = math.clamp(value, 0, 1)
        progressFill.Size = UDim2.new(value, 0, 1, 0)
        progressText.Text = `{math.floor(value * 100)}%`
    end
    
    return progressBar
end

-- Factory function
local function CreateUIComponents(): typeof(UIComponents)
    return setmetatable({}, UIComponents)
end

return CreateUIComponents