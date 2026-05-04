--!optimize 2
-- Zillow--7 GazTeam

local Iris = {}

-- ==================== CONFIG ====================
Iris._config = {
    UseScreenGUIs = true,
    TextColor = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    WindowBgColor = Color3.fromRGB(20, 20, 20),
    WindowBorderColor = Color3.fromRGB(60, 60, 60),
    ButtonColor = Color3.fromRGB(45, 45, 45),
    ButtonHoveredColor = Color3.fromRGB(55, 55, 55),
    ButtonActiveColor = Color3.fromRGB(35, 35, 35),
}

Iris._started = false
Iris._connectedFunctions = {}
Iris._widgets = {}

-- ==================== WIDGET SYSTEM ====================
function Iris._Insert(widgetType, args)
    local widgetClass = Iris._widgets[widgetType]
    if not widgetClass then return end
    
    local widget = {
        type = widgetType,
        arguments = args or {},
    }
    
    widget.Instance = widgetClass.Generate(widget)
    widgetClass.Update(widget)
    
    return widget
end

-- Window
Iris.WidgetConstructor = function(name, class)
    Iris._widgets[name] = class
end

Iris.WidgetConstructor("Window", {
    hasChildren = true,
    Generate = function(this)
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "ZillowGUI"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.Parent = Iris.parentInstance or game.Players.LocalPlayer.PlayerGui

        local Window = Instance.new("Frame")
        Window.Name = "Window"
        Window.Size = UDim2.new(0, 420, 0, 320)
        Window.Position = UDim2.new(0.5, -210, 0.5, -160)
        Window.BackgroundColor3 = Iris._config.WindowBgColor
        Window.BorderSizePixel = 1
        Window.BorderColor3 = Iris._config.WindowBorderColor
        Window.Parent = ScreenGui

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = Window

        local TitleBar = Instance.new("Frame")
        TitleBar.Name = "TitleBar"
        TitleBar.Size = UDim2.new(1, 0, 0, 36)
        TitleBar.BackgroundTransparency = 1
        TitleBar.Parent = Window

        local Title = Instance.new("TextLabel")
        Title.Name = "Title"
        Title.Size = UDim2.new(1, -50, 1, 0)
        Title.BackgroundTransparency = 1
        Title.Text = "Zillow"
        Title.TextColor3 = Iris._config.TextColor
        Title.TextSize = 15
        Title.Font = Enum.Font.GothamSemibold
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = TitleBar

        local Content = Instance.new("ScrollingFrame")
        Content.Name = "Content"
        Content.Position = UDim2.new(0, 10, 0, 44)
        Content.Size = UDim2.new(1, -20, 1, -54)
        Content.BackgroundTransparency = 1
        Content.ScrollBarThickness = 6
        Content.Parent = Window

        local UIListLayout = Instance.new("UIListLayout")
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.Padding = UDim.new(0, 8)
        UIListLayout.Parent = Content

        this.Instance = ScreenGui
        this.Content = Content
        this.Title = Title

        return ScreenGui
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
        local TextLabel = Instance.new("TextLabel")
        TextLabel.BackgroundTransparency = 1
        TextLabel.TextColor3 = Iris._config.TextColor
        TextLabel.TextSize = Iris._config.TextSize
        TextLabel.Font = Enum.Font.Gotham
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.AutomaticSize = Enum.AutomaticSize.Y
        TextLabel.Size = UDim2.new(1, 0, 0, 0)
        return TextLabel
    end,
    Update = function(this)
        this.Instance.Text = this.arguments.Text or ""
    end
})

-- Button
Iris.WidgetConstructor("Button", {
    Generate = function()
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 0, 36)
        Button.BackgroundColor3 = Iris._config.ButtonColor
        Button.TextColor3 = Iris._config.TextColor
        Button.TextSize = Iris._config.TextSize
        Button.Font = Enum.Font.GothamSemibold

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 5)
        Corner.Parent = Button

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
    Update = function(this)
        this.Instance.Text = this.arguments.Text or "Button"
    end
})

-- ==================== INIT ====================
function Iris.Init()
    if Iris._started then return end
    Iris._started = true

    Iris.parentInstance = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    game:GetService("RunService").Heartbeat:Connect(function()
        for _, func in ipairs(Iris._connectedFunctions) do
            func()
        end
    end)
end

function Iris:Connect(callback)
    table.insert(Iris._connectedFunctions, callback)
end

-- Shortcuts
Iris.Window = function(args) return Iris._Insert("Window", args) end
Iris.Text   = function(args) return Iris._Insert("Text", args) end
Iris.Button = function(args) return Iris._Insert("Button", args) end

return Iris
