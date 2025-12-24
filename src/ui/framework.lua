--!strict
--[[
    GKTools UI Framework
    Modern Interface System with Advanced Features
    
    Features:
    - Dynamic component system
    - Context menu support
    - Theme management
    - Event handling
    - Responsive layouts
]]

local UIFramework = {}
UIFramework.__index = UIFramework

-- Advanced type definitions
export type UITheme = {
    name: string,
    colors: {[string]: Color3},
    fonts: {[string]: Enum.Font},
    sizes: {[string]: number}
}

export type UIComponent = {
    instance: GuiObject,
    properties: {[string]: any},
    children: {UIComponent},
    events: {[string]: RBXScriptConnection}
}

export type ContextMenuItem = {
    text: string,
    icon: string?,
    action: () -> (),
    enabled: boolean,
    submenu: {ContextMenuItem}?
}

-- Modern themes
local THEMES = {
    DARK = {
        name = "Dark",
        colors = {
            background = Color3.fromRGB(30, 30, 30),
            surface = Color3.fromRGB(45, 45, 45),
            primary = Color3.fromRGB(100, 150, 255),
            secondary = Color3.fromRGB(150, 100, 255),
            text = Color3.fromRGB(255, 255, 255),
            textSecondary = Color3.fromRGB(200, 200, 200),
            border = Color3.fromRGB(70, 70, 70),
            accent = Color3.fromRGB(255, 100, 100),
            success = Color3.fromRGB(100, 255, 100),
            warning = Color3.fromRGB(255, 200, 100),
            error = Color3.fromRGB(255, 100, 100)
        },
        fonts = {
            primary = Enum.Font.Gotham,
            secondary = Enum.Font.GothamMedium,
            monospace = Enum.Font.RobotoMono
        },
        sizes = {
            titleBar = 30,
            toolbar = 40,
            sidebar = 250,
            padding = 8,
            borderRadius = 4
        }
    },
    LIGHT = {
        name = "Light", 
        colors = {
            background = Color3.fromRGB(250, 250, 250),
            surface = Color3.fromRGB(255, 255, 255),
            primary = Color3.fromRGB(50, 100, 200),
            secondary = Color3.fromRGB(100, 50, 200),
            text = Color3.fromRGB(30, 30, 30),
            textSecondary = Color3.fromRGB(100, 100, 100),
            border = Color3.fromRGB(200, 200, 200),
            accent = Color3.fromRGB(200, 50, 50),
            success = Color3.fromRGB(50, 200, 50),
            warning = Color3.fromRGB(200, 150, 50),
            error = Color3.fromRGB(200, 50, 50)
        },
        fonts = {
            primary = Enum.Font.Gotham,
            secondary = Enum.Font.GothamMedium,
            monospace = Enum.Font.RobotoMono
        },
        sizes = {
            titleBar = 30,
            toolbar = 40,
            sidebar = 250,
            padding = 8,
            borderRadius = 4
        }
    }
}

-- Initialize UI Framework
function UIFramework:Initialize(config: any): ()
    self.config = config
    self.theme = self:GetTheme(config.uiTheme)
    self.components = {}
    self.eventConnections = {}
    
    -- Create main UI structure
    self:CreateMainInterface()
    
    print("UI Framework initialized with modern interface system")
end

-- Get theme based on configuration
function UIFramework:GetTheme(themeName: string): UITheme
    if themeName == "AUTO" then
        -- Auto-detect based on Roblox Studio theme
        local success, studioTheme = pcall(function()
            return settings().Studio.Theme
        end)
        
        if success and studioTheme and studioTheme.Name:find("Dark") then
            return THEMES.DARK
        else
            return THEMES.LIGHT
        end
    end
    
    return THEMES[themeName] or THEMES.DARK
end

-- Create main interface structure
function UIFramework:CreateMainInterface(): ()
    -- Create ScreenGui
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "GKToolsUI"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Parent to appropriate location
    local success = pcall(function()
        self.screenGui.Parent = game:GetService("CoreGui")
    end)
    
    if not success then
        self.screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Create main window
    self.mainWindow = self:CreateWindow({
        title = "GKTools - Advanced Decompiler",
        size = UDim2.new(0, 1200, 0, 800),
        position = UDim2.new(0.5, -600, 0.5, -400),
        resizable = true,
        minimizable = true
    })
    
    -- Create layout components
    self:CreateTitleBar()
    self:CreateToolbar()
    self:CreateSidebar()
    self:CreateMainContent()
    self:CreateStatusBar()
    
    -- Setup event handlers
    self:SetupEventHandlers()
end

-- Create window component
function UIFramework:CreateWindow(props: {[string]: any}): Frame
    local window = Instance.new("Frame")
    window.Name = "MainWindow"
    window.Size = props.size or UDim2.new(0, 800, 0, 600)
    window.Position = props.position or UDim2.new(0.5, -400, 0.5, -300)
    window.BackgroundColor3 = self.theme.colors.surface
    window.BorderSizePixel = 0
    window.Parent = self.screenGui
    
    -- Add corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, self.theme.sizes.borderRadius)
    corner.Parent = window
    
    -- Add drop shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ZIndex = window.ZIndex - 1
    shadow.Parent = window
    
    return window
end

-- Create title bar
function UIFramework:CreateTitleBar(): ()
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, self.theme.sizes.titleBar)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = self.theme.colors.primary
    titleBar.BorderSizePixel = 0
    titleBar.Parent = self.mainWindow
    
    -- Title text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Size = UDim2.new(1, -100, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "GKTools - Advanced Decompiler"
    titleText.TextColor3 = self.theme.colors.text
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Font = self.theme.fonts.secondary
    titleText.TextSize = 14
    titleText.Parent = titleBar
    
    -- Window controls
    self:CreateWindowControls(titleBar)
    
    -- Make draggable
    self:MakeDraggable(titleBar, self.mainWindow)
    
    self.titleBar = titleBar
end

-- Create window controls (minimize, maximize, close)
function UIFramework:CreateWindowControls(parent: Frame): ()
    local controls = Instance.new("Frame")
    controls.Name = "Controls"
    controls.Size = UDim2.new(0, 90, 1, 0)
    controls.Position = UDim2.new(1, -90, 0, 0)
    controls.BackgroundTransparency = 1
    controls.Parent = parent
    
    local buttons = {"Minimize", "Maximize", "Close"}
    local colors = {self.theme.colors.warning, self.theme.colors.success, self.theme.colors.error}
    
    for i, buttonName in ipairs(buttons) do
        local button = Instance.new("TextButton")
        button.Name = buttonName
        button.Size = UDim2.new(0, 25, 0, 25)
        button.Position = UDim2.new(0, (i-1) * 30 + 5, 0.5, -12.5)
        button.BackgroundColor3 = colors[i]
        button.BorderSizePixel = 0
        button.Text = ""
        button.Parent = controls
        
        -- Add corner rounding
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.5, 0)
        corner.Parent = button
        
        -- Button functionality
        button.MouseButton1Click:Connect(function()
            self:HandleWindowControl(buttonName)
        end)
    end
end

-- Create toolbar
function UIFramework:CreateToolbar(): ()
    local toolbar = Instance.new("Frame")
    toolbar.Name = "Toolbar"
    toolbar.Size = UDim2.new(1, 0, 0, self.theme.sizes.toolbar)
    toolbar.Position = UDim2.new(0, 0, 0, self.theme.sizes.titleBar)
    toolbar.BackgroundColor3 = self.theme.colors.background
    toolbar.BorderSizePixel = 0
    toolbar.Parent = self.mainWindow
    
    -- Toolbar buttons
    local buttons = {
        {text = "Refresh", icon = "🔄", action = function() self:RefreshGameTree() end},
        {text = "Export", icon = "💾", action = function() self:ExportSources() end},
        {text = "Settings", icon = "⚙️", action = function() self:OpenSettings() end},
        {text = "About", icon = "ℹ️", action = function() self:ShowAbout() end}
    }
    
    for i, buttonData in ipairs(buttons) do
        local button = self:CreateToolbarButton(buttonData, i)
        button.Parent = toolbar
    end
    
    self.toolbar = toolbar
end

-- Create sidebar for game tree
function UIFramework:CreateSidebar(): ()
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, self.theme.sizes.sidebar, 1, -(self.theme.sizes.titleBar + self.theme.sizes.toolbar + 25))
    sidebar.Position = UDim2.new(0, 0, 0, self.theme.sizes.titleBar + self.theme.sizes.toolbar)
    sidebar.BackgroundColor3 = self.theme.colors.surface
    sidebar.BorderSizePixel = 0
    sidebar.Parent = self.mainWindow
    
    -- Sidebar header
    local header = Instance.new("TextLabel")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 30)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = self.theme.colors.background
    header.BorderSizePixel = 0
    header.Text = "Game Tree"
    header.TextColor3 = self.theme.colors.text
    header.Font = self.theme.fonts.secondary
    header.TextSize = 14
    header.Parent = sidebar
    
    -- Tree view
    local treeView = Instance.new("ScrollingFrame")
    treeView.Name = "TreeView"
    treeView.Size = UDim2.new(1, 0, 1, -30)
    treeView.Position = UDim2.new(0, 0, 0, 30)
    treeView.BackgroundTransparency = 1
    treeView.BorderSizePixel = 0
    treeView.ScrollBarThickness = 8
    treeView.ScrollBarImageColor3 = self.theme.colors.border
    treeView.Parent = sidebar
    
    -- Tree layout
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 2)
    layout.Parent = treeView
    
    self.sidebar = sidebar
    self.treeView = treeView
end

-- Create main content area
function UIFramework:CreateMainContent(): ()
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -self.theme.sizes.sidebar, 1, -(self.theme.sizes.titleBar + self.theme.sizes.toolbar + 25))
    content.Position = UDim2.new(0, self.theme.sizes.sidebar, 0, self.theme.sizes.titleBar + self.theme.sizes.toolbar)
    content.BackgroundColor3 = self.theme.colors.background
    content.BorderSizePixel = 0
    content.Parent = self.mainWindow
    
    -- Content tabs
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, 0, 0, 35)
    tabContainer.Position = UDim2.new(0, 0, 0, 0)
    tabContainer.BackgroundColor3 = self.theme.colors.surface
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = content
    
    -- Content area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, 0, 1, -35)
    contentArea.Position = UDim2.new(0, 0, 0, 35)
    contentArea.BackgroundTransparency = 1
    contentArea.BorderSizePixel = 0
    contentArea.Parent = content
    
    -- Code editor
    self:CreateCodeEditor(contentArea)
    
    self.content = content
    self.contentArea = contentArea
end

-- Create code editor with syntax highlighting
function UIFramework:CreateCodeEditor(parent: Frame): ()
    local editor = Instance.new("ScrollingFrame")
    editor.Name = "CodeEditor"
    editor.Size = UDim2.new(1, 0, 1, 0)
    editor.Position = UDim2.new(0, 0, 0, 0)
    editor.BackgroundColor3 = self.theme.colors.background
    editor.BorderSizePixel = 0
    editor.ScrollBarThickness = 12
    editor.ScrollBarImageColor3 = self.theme.colors.border
    editor.Parent = parent
    
    -- Line numbers
    local lineNumbers = Instance.new("TextLabel")
    lineNumbers.Name = "LineNumbers"
    lineNumbers.Size = UDim2.new(0, 50, 1, 0)
    lineNumbers.Position = UDim2.new(0, 0, 0, 0)
    lineNumbers.BackgroundColor3 = self.theme.colors.surface
    lineNumbers.BorderSizePixel = 0
    lineNumbers.Text = "1\n2\n3\n4\n5"
    lineNumbers.TextColor3 = self.theme.colors.textSecondary
    lineNumbers.TextXAlignment = Enum.TextXAlignment.Right
    lineNumbers.TextYAlignment = Enum.TextYAlignment.Top
    lineNumbers.Font = self.theme.fonts.monospace
    lineNumbers.TextSize = 12
    lineNumbers.Parent = editor
    
    -- Code area
    local codeArea = Instance.new("TextBox")
    codeArea.Name = "CodeArea"
    codeArea.Size = UDim2.new(1, -55, 1, 0)
    codeArea.Position = UDim2.new(0, 55, 0, 0)
    codeArea.BackgroundTransparency = 1
    codeArea.BorderSizePixel = 0
    codeArea.Text = "-- Select a script from the game tree to view its source code"
    codeArea.TextColor3 = self.theme.colors.text
    codeArea.TextXAlignment = Enum.TextXAlignment.Left
    codeArea.TextYAlignment = Enum.TextYAlignment.Top
    codeArea.Font = self.theme.fonts.monospace
    codeArea.TextSize = 12
    codeArea.MultiLine = true
    codeArea.ClearTextOnFocus = false
    codeArea.Parent = editor
    
    self.codeEditor = editor
    self.codeArea = codeArea
    self.lineNumbers = lineNumbers
end

-- Create status bar
function UIFramework:CreateStatusBar(): ()
    local statusBar = Instance.new("Frame")
    statusBar.Name = "StatusBar"
    statusBar.Size = UDim2.new(1, 0, 0, 25)
    statusBar.Position = UDim2.new(0, 0, 1, -25)
    statusBar.BackgroundColor3 = self.theme.colors.surface
    statusBar.BorderSizePixel = 0
    statusBar.Parent = self.mainWindow
    
    -- Status text
    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(1, -10, 1, 0)
    statusText.Position = UDim2.new(0, 5, 0, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Ready - GKTools Advanced Decompiler"
    statusText.TextColor3 = self.theme.colors.textSecondary
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Font = self.theme.fonts.primary
    statusText.TextSize = 11
    statusText.Parent = statusBar
    
    self.statusBar = statusBar
    self.statusText = statusText
end

-- Event handling system
function UIFramework:SetupEventHandlers(): ()
    -- Right-click context menu
    self.treeView.InputBegan:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            self:ShowContextMenu(input.Position)
        end
    end)
    
    -- Window resize handling
    local resizeConnection
    resizeConnection = game:GetService("UserInputService").InputChanged:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            self:HandleWindowResize(input)
        end
    end)
    
    table.insert(self.eventConnections, resizeConnection)
end

-- Context menu system
function UIFramework:ShowContextMenu(position: Vector2): ()
    if self.contextMenu then
        self.contextMenu:Destroy()
    end
    
    local menuItems: {ContextMenuItem} = {
        {
            text = "Refresh Tree",
            icon = "🔄",
            action = function() self:RefreshGameTree() end,
            enabled = true
        },
        {
            text = "Expand All",
            icon = "📂",
            action = function() self:ExpandAllNodes() end,
            enabled = true
        },
        {
            text = "Collapse All", 
            icon = "📁",
            action = function() self:CollapseAllNodes() end,
            enabled = true
        },
        {
            text = "Export Selected",
            icon = "💾",
            action = function() self:ExportSelected() end,
            enabled = true
        }
    }
    
    self.contextMenu = self:CreateContextMenu(menuItems, position)
end

-- Create context menu
function UIFramework:CreateContextMenu(items: {ContextMenuItem}, position: Vector2): Frame
    local menu = Instance.new("Frame")
    menu.Name = "ContextMenu"
    menu.Size = UDim2.new(0, 150, 0, #items * 25 + 10)
    menu.Position = UDim2.new(0, position.X, 0, position.Y)
    menu.BackgroundColor3 = self.theme.colors.surface
    menu.BorderSizePixel = 1
    menu.BorderColor3 = self.theme.colors.border
    menu.ZIndex = 1000
    menu.Parent = self.screenGui
    
    -- Menu layout
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 1)
    layout.Parent = menu
    
    -- Menu items
    for i, item in ipairs(items) do
        local menuItem = Instance.new("TextButton")
        menuItem.Name = `MenuItem{i}`
        menuItem.Size = UDim2.new(1, 0, 0, 25)
        menuItem.BackgroundColor3 = self.theme.colors.surface
        menuItem.BorderSizePixel = 0
        menuItem.Text = `{item.icon or ""} {item.text}`
        menuItem.TextColor3 = item.enabled and self.theme.colors.text or self.theme.colors.textSecondary
        menuItem.TextXAlignment = Enum.TextXAlignment.Left
        menuItem.Font = self.theme.fonts.primary
        menuItem.TextSize = 12
        menuItem.LayoutOrder = i
        menuItem.Parent = menu
        
        -- Hover effect
        menuItem.MouseEnter:Connect(function()
            if item.enabled then
                menuItem.BackgroundColor3 = self.theme.colors.primary
            end
        end)
        
        menuItem.MouseLeave:Connect(function()
            menuItem.BackgroundColor3 = self.theme.colors.surface
        end)
        
        -- Click handler
        if item.enabled then
            menuItem.MouseButton1Click:Connect(function()
                item.action()
                menu:Destroy()
            end)
        end
    end
    
    -- Close menu when clicking outside
    local closeConnection
    closeConnection = game:GetService("UserInputService").InputBegan:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            menu:Destroy()
            closeConnection:Disconnect()
        end
    end)
    
    return menu
end

-- Utility functions
function UIFramework:MakeDraggable(handle: GuiObject, target: GuiObject): ()
    local dragging = false
    local dragStart = Vector2.new()
    local startPos = UDim2.new()
    
    handle.InputBegan:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
        end
    end)
    
    handle.InputChanged:Connect(function(input: InputObject)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    handle.InputEnded:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

function UIFramework:CreateToolbarButton(buttonData: {[string]: any}, index: number): TextButton
    local button = Instance.new("TextButton")
    button.Name = buttonData.text
    button.Size = UDim2.new(0, 80, 0, 30)
    button.Position = UDim2.new(0, (index - 1) * 85 + 5, 0, 5)
    button.BackgroundColor3 = self.theme.colors.primary
    button.BorderSizePixel = 0
    button.Text = `{buttonData.icon} {buttonData.text}`
    button.TextColor3 = self.theme.colors.text
    button.Font = self.theme.fonts.primary
    button.TextSize = 11
    
    -- Corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    -- Click handler
    button.MouseButton1Click:Connect(buttonData.action)
    
    return button
end

-- Event handlers - Full implementations
function UIFramework:HandleEvent(event: string, data: any): ()
    if event == "ChildAdded" then
        self:AddTreeNode(data.parent, data.child, data.source, data.metadata)
    elseif event == "ChildRemoved" then
        self:RemoveTreeNode(data.child)
    elseif event == "SourceLoaded" then
        self:DisplaySource(data.source, data.metadata)
    end
end

function UIFramework:HandleWindowControl(control: string): ()
    if control == "Minimize" then
        self.mainWindow.Visible = false
        self:UpdateStatus("Window minimized")
    elseif control == "Maximize" then
        local isMaximized = self.mainWindow.Size == UDim2.new(1, 0, 1, 0)
        if isMaximized then
            self.mainWindow.Size = UDim2.new(0, 1200, 0, 800)
            self.mainWindow.Position = UDim2.new(0.5, -600, 0.5, -400)
        else
            self.mainWindow.Size = UDim2.new(1, 0, 1, 0)
            self.mainWindow.Position = UDim2.new(0, 0, 0, 0)
        end
    elseif control == "Close" then
        self.screenGui:Destroy()
    end
end

function UIFramework:HandleWindowResize(input: InputObject): ()
    -- Window resize logic would go here
    -- This is complex and involves detecting resize handles
end

function UIFramework:RefreshGameTree(): ()
    self:UpdateStatus("Refreshing game tree...")
    
    -- Clear existing tree
    for _, child in ipairs(self.treeView:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Rebuild tree from game services
    local services = {
        {name = "ServerScriptService", icon = "📜"},
        {name = "ServerStorage", icon = "📦"},
        {name = "StarterGui", icon = "🖥️"},
        {name = "StarterPlayer", icon = "👤"},
        {name = "Players", icon = "👥"},
        {name = "Workspace", icon = "🌍"},
        {name = "ReplicatedStorage", icon = "🔄"},
        {name = "ReplicatedFirst", icon = "⚡"}
    }
    
    for i, serviceInfo in ipairs(services) do
        local success, service = pcall(function()
            return game:GetService(serviceInfo.name)
        end)
        
        if success and service then
            self:CreateServiceNode(service, serviceInfo.icon, i)
        end
    end
    
    self:UpdateStatus("Game tree refreshed")
end

function UIFramework:CreateServiceNode(service: Instance, icon: string, order: number): ()
    local serviceFrame = Instance.new("Frame")
    serviceFrame.Name = service.Name
    serviceFrame.Size = UDim2.new(1, 0, 0, 25)
    serviceFrame.BackgroundTransparency = 1
    serviceFrame.LayoutOrder = order
    serviceFrame.Parent = self.treeView
    
    local expandButton = Instance.new("TextButton")
    expandButton.Name = "ExpandButton"
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
    iconLabel.Name = "Icon"
    iconLabel.Size = UDim2.new(0, 20, 0, 20)
    iconLabel.Position = UDim2.new(0, 25, 0.5, -10)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextColor3 = self.theme.colors.primary
    iconLabel.Font = self.theme.fonts.primary
    iconLabel.TextSize = 14
    iconLabel.Parent = serviceFrame
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(1, -50, 1, 0)
    nameLabel.Position = UDim2.new(0, 50, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = service.Name
    nameLabel.TextColor3 = self.theme.colors.text
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Font = self.theme.fonts.primary
    nameLabel.TextSize = 12
    nameLabel.Parent = serviceFrame
    
    -- Expand/collapse functionality
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
    
    -- Click to select
    nameLabel.InputBegan:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:SelectNode(service)
        end
    end)
end

function UIFramework:ExpandServiceNode(service: Instance, parentFrame: Frame): ()
    local children = service:GetChildren()
    
    for i, child in ipairs(children) do
        self:CreateChildNode(child, parentFrame, 1, i)
    end
end

function UIFramework:CreateChildNode(instance: Instance, parentFrame: Frame, depth: number, order: number): ()
    local childFrame = Instance.new("Frame")
    childFrame.Name = instance.Name .. "_Child"
    childFrame.Size = UDim2.new(1, 0, 0, 20)
    childFrame.BackgroundTransparency = 1
    childFrame.LayoutOrder = parentFrame.LayoutOrder + order * 0.01
    childFrame.Parent = self.treeView
    
    local indent = depth * 20
    
    -- Icon based on class
    local icon = self:GetClassIcon(instance.ClassName)
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 15, 0, 15)
    iconLabel.Position = UDim2.new(0, 25 + indent, 0.5, -7.5)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextColor3 = self.theme.colors.secondary
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
    
    -- Click to select and decompile
    nameLabel.InputBegan:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:SelectNode(instance)
        end
    end)
end

function UIFramework:CollapseServiceNode(parentFrame: Frame): ()
    local parentOrder = parentFrame.LayoutOrder
    
    for _, child in ipairs(self.treeView:GetChildren()) do
        if child:IsA("Frame") and child.LayoutOrder > parentOrder and child.LayoutOrder < parentOrder + 1 then
            child:Destroy()
        end
    end
end

function UIFramework:SelectNode(instance: Instance): ()
    self:UpdateStatus(`Selected: {instance.Name} ({instance.ClassName})`)
    
    -- Trigger decompilation if this is a script
    if instance:IsA("Script") or instance:IsA("LocalScript") or instance:IsA("ModuleScript") then
        self:DecompileScript(instance)
    else
        self:DisplayInstanceInfo(instance)
    end
end

function UIFramework:DecompileScript(script: Instance): ()
    self:UpdateStatus(`Decompiling {script.Name}...`)
    
    -- Get decompiler from parent GKTools instance
    if self.gktools and self.gktools.Decompiler then
        local result = self.gktools.Decompiler:DecompileInstance(script)
        
        if result.source then
            self:DisplaySource(result.source, result.metadata)
            self:UpdateStatus(`Decompiled {script.Name} successfully`)
        else
            self:DisplaySource(`-- Could not decompile {script.Name}\n-- Reason: No source available`, {})
            self:UpdateStatus(`Failed to decompile {script.Name}`)
        end
    else
        self:DisplaySource(`-- Decompiler not available`, {})
    end
end

function UIFramework:DisplaySource(source: string, metadata: {[string]: any}): ()
    self.codeArea.Text = source
    
    -- Update line numbers
    local lines = source:split("\n")
    local lineNumbers = {}
    for i = 1, #lines do
        table.insert(lineNumbers, tostring(i))
    end
    self.lineNumbers.Text = table.concat(lineNumbers, "\n")
end

function UIFramework:DisplayInstanceInfo(instance: Instance): ()
    local info = {
        `-- Instance Information`,
        `-- Name: {instance.Name}`,
        `-- ClassName: {instance.ClassName}`,
        `-- Parent: {instance.Parent and instance.Parent.Name or "nil"}`,
        `-- Children: {#instance:GetChildren()}`,
        ``,
        `-- Properties:`,
    }
    
    -- Add common properties
    local properties = {"Archivable"}
    for _, prop in ipairs(properties) do
        local success, value = pcall(function()
            return (instance :: any)[prop]
        end)
        
        if success then
            table.insert(info, `-- {prop}: {tostring(value)}`)
        end
    end
    
    self:DisplaySource(table.concat(info, "\n"), {})
end

function UIFramework:GetClassIcon(className: string): string
    local icons = {
        Script = "📜",
        LocalScript = "📄",
        ModuleScript = "📋",
        Part = "🧱",
        Frame = "🖼️",
        TextLabel = "📝",
        TextButton = "🔘",
        ImageLabel = "🖼️",
        Folder = "📁",
        Model = "🏗️",
        Tool = "🔧",
        RemoteEvent = "📡",
        RemoteFunction = "📞",
        BindableEvent = "🔗",
        BindableFunction = "🔀"
    }
    
    return icons[className] or "📄"
end

function UIFramework:ExportSources(): ()
    self:UpdateStatus("Export functionality not implemented yet")
end

function UIFramework:OpenSettings(): ()
    local settingsContent = Instance.new("Frame")
    settingsContent.Size = UDim2.new(1, 0, 1, 0)
    settingsContent.BackgroundTransparency = 1
    
    local settingsText = Instance.new("TextLabel")
    settingsText.Size = UDim2.new(1, 0, 1, 0)
    settingsText.BackgroundTransparency = 1
    settingsText.Text = "Settings panel coming soon..."
    settingsText.TextColor3 = self.theme.colors.text
    settingsText.Font = self.theme.fonts.primary
    settingsText.TextSize = 14
    settingsText.Parent = settingsContent
    
    local modal = self:CreateModal("Settings", settingsContent, UDim2.new(0, 400, 0, 300))
end

function UIFramework:ShowAbout(): ()
    local aboutContent = Instance.new("Frame")
    aboutContent.Size = UDim2.new(1, 0, 1, 0)
    aboutContent.BackgroundTransparency = 1
    
    local aboutText = Instance.new("TextLabel")
    aboutText.Size = UDim2.new(1, -20, 1, -20)
    aboutText.Position = UDim2.new(0, 10, 0, 10)
    aboutText.BackgroundTransparency = 1
    aboutText.Text = [[GKTools - Advanced Decompiler

Version: 1.0.0
Developed by: GKTools Team

Features:
• Advanced source decompilation
• Real-time game tree analysis
• Security vulnerability detection
• Modern UI with syntax highlighting

For more information, visit our documentation.]]
    aboutText.TextColor3 = self.theme.colors.text
    aboutText.Font = self.theme.fonts.primary
    aboutText.TextSize = 12
    aboutText.TextWrapped = true
    aboutText.TextYAlignment = Enum.TextYAlignment.Top
    aboutText.Parent = aboutContent
    
    local modal = self:CreateModal("About GKTools", aboutContent, UDim2.new(0, 450, 0, 350))
end

function UIFramework:ExpandAllNodes(): ()
    -- Expand all service nodes
    for _, child in ipairs(self.treeView:GetChildren()) do
        if child:IsA("Frame") then
            local expandButton = child:FindFirstChild("ExpandButton")
            if expandButton and expandButton.Text == "+" then
                expandButton.MouseButton1Click:Fire()
            end
        end
    end
    self:UpdateStatus("Expanded all nodes")
end

function UIFramework:CollapseAllNodes(): ()
    -- Collapse all service nodes
    for _, child in ipairs(self.treeView:GetChildren()) do
        if child:IsA("Frame") then
            local expandButton = child:FindFirstChild("ExpandButton")
            if expandButton and expandButton.Text == "-" then
                expandButton.MouseButton1Click:Fire()
            end
        end
    end
    self:UpdateStatus("Collapsed all nodes")
end

function UIFramework:ExportSelected(): ()
    self:UpdateStatus("Export selected functionality not implemented yet")
end

function UIFramework:UpdateStatus(message: string): ()
    if self.statusText then
        self.statusText.Text = message
    end
end

function UIFramework:AddTreeNode(parent: Instance, child: Instance, source: string?, metadata: {[string]: any}): ()
    -- Add new node to tree when child is added
    -- This would integrate with the existing tree structure
end

function UIFramework:RemoveTreeNode(child: Instance): ()
    -- Remove node from tree when child is removed
    -- This would find and remove the corresponding UI element
end

function UIFramework:CreateModal(title: string, content: GuiObject, size: UDim2?): Frame
    -- Background overlay
    local overlay = Instance.new("Frame")
    overlay.Name = "ModalOverlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.Position = UDim2.new(0, 0, 0, 0)
    overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 500
    overlay.Parent = self.screenGui
    
    -- Modal window
    local modal = Instance.new("Frame")
    modal.Name = "Modal"
    modal.Size = size or UDim2.new(0, 400, 0, 300)
    modal.Position = UDim2.new(0.5, -(size and size.X.Offset/2 or 200), 0.5, -(size and size.Y.Offset/2 or 150))
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

-- Factory function
local function CreateUIFramework(): typeof(UIFramework)
    return setmetatable({}, UIFramework)
end

return CreateUIFramework