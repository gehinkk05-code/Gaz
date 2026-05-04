--!optimize 2
-- Zillow--7 GazTeam

local = {}

-- ==================== CONFIG ====================
Iris._config = {
    UseScreenGUIs = true,
    TextColor = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    WindowBgColor = Color3.fromRGB(20, 20, 20),
    WindowBorderColor = Color3.fromRGB(60, 60, 60),
    FrameBgColor = Color3.fromRGB(30, 30, 30),
    ButtonColor = Color3.fromRGB(45, 45, 45),
    ButtonHoveredColor = Color3.fromRGB(55, 55, 55),
    ButtonActiveColor = Color3.fromRGB(35, 35, 35),
}

Iris._started = false
Iris._connectedFunctions = {}
Iris._widgets = {}
Iris._states = {}
Iris._cycleTick = 0

-- ==================== STATE ====================
local State = {}
State.__index = State

function State.new(initial)
    local self = setmetatable({}, State)
    self.value = initial
    self.Connected = {}
    return self
end

function State:get() return self.value end
function State:set(new)
    self.value = new
    for _, w in pairs(self.Connected) do
        if w.UpdateState then w.UpdateState(w) end
    end
end

function Iris.State(initial)
    local id = "state_" .. tick() .. math.random()
    Iris._states[id] = State.new(initial)
    return Iris._states[id]
end

-- ==================== WIDGETS ====================
function Iris._Insert(widgetType, args)
    local widgetClass = Iris._widgets[widgetType]
    local widget = {
        type = widgetType,
        arguments = args or {},
    }
    widget.Instance = widgetClass.Generate(widget)
    widgetClass.Update(widget)
    return widget
end

-- Window
Iris.WidgetConstructor("Window", {
    hasChildren = true,
    Generate = function(this)
        local gui = Instance.new("ScreenGui")
        gui.Name = "ZillowGUI"
        gui.ResetOnSpawn = false

        local window = Instance.new("Frame")
        window.Name = "Window"
        window.Size = UDim2.new(0, 420, 0, 320)
        window.Position = UDim2.new(0.5, -210, 0.5, -160)
        window.BackgroundColor3 = Iris._config.WindowBgColor
        window.BorderSizePixel = 1
        window.BorderColor3 = Iris._config.WindowBorderColor
        window.Parent = gui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = window

        local titleBar = Instance.new("Frame")
        titleBar.Name = "TitleBar"
        titleBar.Size = UDim2.new(1, 0, 0, 34)
        titleBar.BackgroundTransparency = 1
        titleBar.Parent = window

        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1, -40, 1, 0)
        title.BackgroundTransparency = 1
        title.Text = "Zillow"
        title.TextColor3 = Iris._config.TextColor
        title.TextSize = 15
        title.Font = Enum.Font.GothamSemibold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = titleBar

        local content = Instance.new("ScrollingFrame")
        content.Name = "Content"
        content.Position = UDim2.new(0, 8, 0, 42)
        content.Size = UDim2.new(1, -16, 1, -50)
        content.BackgroundTransparency = 1
        content.BorderSizePixel = 0
        content.ScrollBarThickness = 5
        content.Parent = window

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 6)
        layout.Parent = content

        this.Instance = gui
        this.Content = content
        this.Title = title

        return gui
    end,
    Update = function(this)
        this.Title.Text = this.arguments.Title or "Window"
    end,
    ChildAdded = function(this)
        return this.Content
    end
})

-- Text
Iris.WidgetConstructor("Text", {
    Generate = function()
        local t = Instance.new("TextLabel")
        t.BackgroundTransparency = 1
        t.TextColor3 = Iris._config.TextColor
        t.TextSize = Iris._config.TextSize
        t.Font = Enum.Font.Gotham
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.AutomaticSize = Enum.AutomaticSize.Y
        t.Size = UDim2.new(1, 0, 0, 0)
        return t
    end,
    Update = function(this)
        this.Instance.Text = this.arguments.Text or ""
    end
})

-- Button
Iris.WidgetConstructor("Button", {
    Generate = function()
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 34)
        b.BackgroundColor3 = Iris._config.ButtonColor
        b.TextColor3 = Iris._config.TextColor
        b.TextSize = Iris._config.TextSize
        b.Font = Enum.Font.GothamSemibold

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = b

        b.MouseEnter:Connect(function() b.BackgroundColor3 = Iris._config.ButtonHoveredColor end)
        b.MouseLeave:Connect(function() b.BackgroundColor3 = Iris._config.ButtonColor end)
        b.MouseButton1Down:Connect(function() b.BackgroundColor3 = Iris._config.ButtonActiveColor end)
        b.MouseButton1Up:Connect(function() b.BackgroundColor3 = Iris._config.ButtonHoveredColor end)

        return b
    end,
    Update = function(this)
        this.Instance.Text = this.arguments.Text or "Button"
    end
})

-- ==================== INIT ====================
function Iris.Init(parent)
    if Iris._started then return end
    Iris._started = true

    Iris.parentInstance = parent or game.Players.LocalPlayer:WaitForChild("PlayerGui")

    game:GetService("RunService").Heartbeat:Connect(function()
        Iris._cycle()
    end)
end

function Iris:Connect(func)
    table.insert(Iris._connectedFunctions, func)
end

function Iris._cycle()
    for _, f in ipairs(Iris._connectedFunctions) do
        f()
    end
end

-- Shortcuts
function Iris.Window(args)   return Iris._Insert("Window", args) end
function Iris.Text(args)     return Iris._Insert("Text", args) end
function Iris.Button(args)   return Iris._Insert("Button", args) end

return Iris
