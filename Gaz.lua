--!optimize 2
-- Zillow--7 GazTeam

local Iris = {}

Iris._started = false
Iris._globalRefreshRequested = false
Iris._widgets = {}
Iris._rootConfig = {}
Iris._config = Iris._rootConfig
Iris._rootInstance = nil
Iris._rootWidget = { ID = "R", type = "Root", ZIndex = 0 }
Iris._states = {}
Iris._connectedFunctions = {}
Iris._IDStack = {"R"}
Iris._usedIDs = {}
Iris._stackIndex = 1
Iris._cycleTick = 0
Iris._widgetCount = 0

-- ==================== CONFIG ====================

Iris._config = {
    UseScreenGUIs = true,
    Parent = nil,
    
    -- Стили (можно менять)
    TextColor = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    FrameBgColor = Color3.fromRGB(30, 30, 30),
    FrameBgTransparency = 0.05,
    BorderColor = Color3.fromRGB(60, 60, 60),
    BorderActiveColor = Color3.fromRGB(0, 162, 255),
    ButtonColor = Color3.fromRGB(45, 45, 45),
    ButtonHoveredColor = Color3.fromRGB(60, 60, 60),
    ButtonActiveColor = Color3.fromRGB(35, 35, 35),
    WindowBgColor = Color3.fromRGB(20, 20, 20),
    WindowBorderSize = 1,
}

-- ==================== CORE ====================

function Iris._getID()
    local i = 2
    local ID = ""
    local info = debug.info(i, "l")
    while info do
        ID = ID .. "+" .. info
        i += 1
        info = debug.info(i, "l")
    end
    Iris._usedIDs[ID] = (Iris._usedIDs[ID] or 0) + 1
    return ID .. ":" .. Iris._usedIDs[ID]
end

function Iris.State(initialValue)
    local ID = Iris._getID()
    if Iris._states[ID] then return Iris._states[ID] end
    
    local state = {
        value = initialValue,
        ConnectedWidgets = {}
    }
    setmetatable(state, {
        __index = {
            get = function(self) return self.value end,
            set = function(self, new)
                self.value = new
                for _, w in next, self.ConnectedWidgets do
                    if w.UpdateState then w.UpdateState(w) end
                end
            end
        }
    })
    Iris._states[ID] = state
    return state
end

function Iris.ForceRefresh()
    Iris._globalRefreshRequested = true
end

-- ==================== WIDGETS ====================

local function ApplyFrameStyle(frame)
    frame.BackgroundColor3 = Iris._config.FrameBgColor
    frame.BackgroundTransparency = Iris._config.FrameBgTransparency
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = frame
end

Iris.WidgetConstructor = function(name, widget)
    Iris._widgets[name] = widget
end

-- Window
Iris.WidgetConstructor("Window", {
    hasChildren = true,
    hasState = true,
    Generate = function(thisWidget)
        local Window = Instance.new("ScreenGui")
        Window.Name = "ZillowWindow"
        Window.ResetOnSpawn = false
        Window.DisplayOrder = 100

        local Main = Instance.new("Frame")
        Main.Name = "Window"
        Main.Size = UDim2.new(0, 400, 0, 300)
        Main.Position = UDim2.new(0.5, -200, 0.5, -150)
        Main.BackgroundColor3 = Iris._config.WindowBgColor
        Main.BorderSizePixel = Iris._config.WindowBorderSize
        Main.BorderColor3 = Iris._config.BorderColor
        Main.Parent = Window
        ApplyFrameStyle(Main)

        local TitleBar = Instance.new("Frame")
        TitleBar.Name = "TitleBar"
        TitleBar.Size = UDim2.new(1, 0, 0, 30)
        TitleBar.BackgroundTransparency = 1
        TitleBar.Parent = Main

        local Title = Instance.new("TextLabel")
        Title.Name = "Title"
        Title.Size = UDim2.new(1, -30, 1, 0)
        Title.BackgroundTransparency = 1
        Title.Text = "Window"
        Title.TextColor3 = Iris._config.TextColor
        Title.TextSize = Iris._config.TextSize
        Title.Font = Enum.Font.GothamSemibold
        Title.Parent = TitleBar

        local Content = Instance.new("ScrollingFrame")
        Content.Name = "Content"
        Content.Position = UDim2.new(0, 0, 0, 30)
        Content.Size = UDim2.new(1, 0, 1, -30)
        Content.BackgroundTransparency = 1
        Content.BorderSizePixel = 0
        Content.ScrollBarThickness = 6
        Content.Parent = Main

        local Layout = Instance.new("UIListLayout")
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 6)
        Layout.Parent = Content

        thisWidget.Instance = Window
        thisWidget.Content = Content
        thisWidget.Title = Title

        return Window
    end,
    Update = function(thisWidget)
        thisWidget.Title.Text = thisWidget.arguments.Title or "Window"
    end,
    ChildAdded = function(thisWidget)
        return thisWidget.Content
    end
})

-- Text
Iris.WidgetConstructor("Text", {
    hasChildren = false,
    Generate = function(thisWidget)
        local Text = Instance.new("TextLabel")
        Text.BackgroundTransparency = 1
        Text.TextColor3 = Iris._config.TextColor
        Text.TextSize = Iris._config.TextSize
        Text.Font = Enum.Font.Gotham
        Text.TextXAlignment = Enum.TextXAlignment.Left
        Text.AutomaticSize = Enum.AutomaticSize.Y
        Text.Size = UDim2.new(1, 0, 0, 0)
        return Text
    end,
    Update = function(thisWidget)
        thisWidget.Instance.Text = thisWidget.arguments.Text or ""
    end
})

-- Button
Iris.WidgetConstructor("Button", {
    hasChildren = false,
    Generate = function(thisWidget)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 0, 32)
        Button.BackgroundColor3 = Iris._config.ButtonColor
        Button.TextColor3 = Iris._config.TextColor
        Button.TextSize = Iris._config.TextSize
        Button.Font = Enum.Font.GothamSemibold
        ApplyFrameStyle(Button)
        
        Button.MouseEnter:Connect(function()
            Button.BackgroundColor3 = Iris._config.ButtonHoveredColor
        end)
        Button.MouseLeave:Connect(function()
            Button.BackgroundColor3 = Iris._config.ButtonColor
        end)
        Button.MouseButton1Down:Connect(function()
            Button.BackgroundColor3 = Iris._config.ButtonActiveColor
        end)
        Button.MouseButton1Up:Connect(function()
            Button.BackgroundColor3 = Iris._config.ButtonHoveredColor
        end)
        
        return Button
    end,
    Update = function(thisWidget)
        thisWidget.Instance.Text = thisWidget.arguments.Text or "Button"
    end
})

-- ==================== INIT ====================

function Iris.Init(parent)
    if Iris._started then return end
    Iris._started = true
    
    if parent then
        Iris.parentInstance = parent
    else
        Iris.parentInstance = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    Iris._generateRootInstance = function()
        local Root = Instance.new("ScreenGui")
        Root.Name = "ZillowGUI"
        Root.ResetOnSpawn = false
        Root.Parent = Iris.parentInstance
        Iris._rootInstance = Root
    end

    Iris._generateRootInstance()

    task.spawn(function()
        game:GetService("RunService").Heartbeat:Connect(function()
            Iris._cycle()
        end)
    end)
end

function Iris:Connect(func)
    table.insert(Iris._connectedFunctions, func)
end

function Iris._cycle()
    for _, func in ipairs(Iris._connectedFunctions) do
        func()
    end
end

-- Экспорт виджетов
Iris.Window = function(args) return Iris._Insert("Window", args) end
Iris.Text   = function(args) return Iris._Insert("Text",   args) end
Iris.Button = function(args) return Iris._Insert("Button", args) end

function Iris._Insert(widgetType, args)
    local ID = Iris._getID()
    local widgetClass = Iris._widgets[widgetType]
    
    local widget = {
        ID = ID,
        type = widgetType,
        arguments = args or {},
        Instance = widgetClass.Generate({ID = ID, arguments = args})
    }
    
    widget.Instance.Parent = Iris._rootInstance
    widgetClass.Update(widget)
    
    return widget
end

return Iris
