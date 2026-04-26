local TweenService = game:GetService("TweenService")

local Elements = {}

function Elements.CreateTab(Sidebar, PageContainer, Pages, name, emoji, ShowPage)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 30)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = emoji .. " " .. name
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.TextSize = 14
    TabBtn.Font = Enum.Font.SourceSans
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = Sidebar
    Instance.new("UIPadding", TabBtn).PaddingLeft = UDim.new(0, 10)

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.BackgroundTransparency = 1
    Page.Parent = PageContainer

    local Canvas = Instance.new("CanvasGroup")
    Canvas.Size = UDim2.new(1, 0, 1, 0)
    Canvas.GroupTransparency = 1
    Canvas.Parent = Page
    Page.Canvas = Canvas

    local Left = Instance.new("Frame", Canvas)
    Left.Size = UDim2.new(0.5, -5, 1, 0)
    Left.BackgroundTransparency = 1
    Instance.new("UIListLayout", Left).Padding = UDim.new(0, 2)

    local Right = Instance.new("Frame", Canvas)
    Right.Size = UDim2.new(0.5, -5, 1, 0)
    Right.Position = UDim2.new(0.5, 5, 0, 0)
    Right.BackgroundTransparency = 1
    Instance.new("UIListLayout", Right).Padding = UDim.new(0, 2)

    Pages[name] = Page
    TabBtn.MouseButton1Click:Connect(function()
        ShowPage(name)
    end)

    return Page, Left, Right
end

function Elements.AddToggle(parent, text, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, 0, 0, 22)
    Frame.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -30, 1, 0)
    Label.Position = UDim2.new(0, 5, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(180, 180, 180)
    Label.TextSize = 13
    Label.Font = Enum.Font.SourceSans
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Box = Instance.new("TextButton", Frame)
    Box.Size = UDim2.new(0, 14, 0, 14)
    Box.Position = UDim2.new(1, -20, 0.5, -7)
    Box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Box.Text = ""
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 3)

    local Stroke = Instance.new("UIStroke", Box)
    Stroke.Color = Color3.fromRGB(60, 60, 60)

    local enabled = false
    Box.MouseButton1Click:Connect(function()
        enabled = not enabled
        TweenService:Create(Box, TweenInfo.new(0.2), {
            BackgroundColor3 = enabled and Color3.fromRGB(80,255,80) or Color3.fromRGB(40,40,40)
        }):Play()
        TweenService:Create(Stroke, TweenInfo.new(0.2), {
            Color = enabled and Color3.fromRGB(100,255,100) or Color3.fromRGB(60,60,60)
        }):Play()
        callback(enabled)
    end)
end

function Elements.AddButton(parent, text, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, 0, 0, 28)
    Frame.BackgroundTransparency = 1

    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(1, -10, 0, 22)
    Btn.Position = UDim2.new(0, 5, 0.5, -11)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.TextSize = 13
    Btn.Font = Enum.Font.SourceSans
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", Btn).Color = Color3.fromRGB(65, 65, 65)

    Btn.MouseButton1Click:Connect(function()
        Btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        task.wait(0.1)
        Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        callback()
    end)
end

return Elements
