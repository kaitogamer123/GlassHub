local Library = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

function Library:CreateWindow(hubName)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "GlassHub_PS99"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MiniFrame = Instance.new("Frame")
    MiniFrame.Name = "MiniFrame"
    MiniFrame.Size = UDim2.new(0, 60, 0, 60)
    MiniFrame.Position = UDim2.new(0.5, -30, 0.1, 0)
    MiniFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MiniFrame.Visible = false
    MiniFrame.Active = true
    MiniFrame.Parent = ScreenGui

    local MiniCorner = Instance.new("UICorner")
    MiniCorner.CornerRadius = UDim.new(0, 12)
    MiniCorner.Parent = MiniFrame

    local MiniTitle = Instance.new("TextLabel")
    MiniTitle.Size = UDim2.new(1, 0, 1, 0)
    MiniTitle.BackgroundTransparency = 1
    MiniTitle.Text = "🧊"
    MiniTitle.TextSize = 30
    MiniTitle.ZIndex = 2
    MiniTitle.Parent = MiniFrame

    local MiniBtn = Instance.new("TextButton")
    MiniBtn.Size = UDim2.new(1, 0, 1, 0)
    MiniBtn.BackgroundTransparency = 1
    MiniBtn.Text = ""
    MiniBtn.ZIndex = 3
    MiniBtn.Parent = MiniFrame

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 35)
    TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = hubName or "🧊 GlassHub Pet Sim 99"
    Title.TextColor3 = Color3.fromRGB(200, 200, 200)
    Title.TextSize = 14
    Title.Font = Enum.Font.SourceSans
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 45, 0, 35)
    MinimizeBtn.Position = UDim2.new(1, -45, 0, 0)
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.Text = "-"
    MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    MinimizeBtn.TextSize = 30
    MinimizeBtn.Parent = TopBar

    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 130, 1, -35)
    Sidebar.Position = UDim2.new(0, 0, 0, 35)
    Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Parent = Sidebar
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -131, 1, -35)
    PageContainer.Position = UDim2.new(0, 131, 0, 35)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = MainFrame

    -- Drag
    local function MakeDraggable(obj, dragHandle)
        local dragging, dragStart, startPos
        dragHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = obj.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                obj.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end

    MakeDraggable(MainFrame, TopBar)
    MakeDraggable(MiniFrame, MiniBtn)

    -- Open animation
    TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 600, 0, 350),
        Position = UDim2.new(0.5, -300, 0.5, -175)
    }):Play()

    local Pages = {}
    local firstTab = nil

    local function ShowPage(name)
        for _, v in pairs(Pages) do
            v.Visible = false
            local canvas = v:FindFirstChild("Canvas")
            if canvas then
                if canvas:IsA("CanvasGroup") then
                    canvas.GroupTransparency = 1
                else
                    canvas.BackgroundTransparency = 1
                end
            end
        end

        if Pages[name] then
            Pages[name].Visible = true
            local canvas = Pages[name]:FindFirstChild("Canvas")

            if canvas then
                if canvas:IsA("CanvasGroup") then
                    TweenService:Create(canvas, TweenInfo.new(0.4), {
                        GroupTransparency = 0
                    }):Play()
                else
                    canvas.BackgroundTransparency = 1
                    TweenService:Create(canvas, TweenInfo.new(0.4), {
                        BackgroundTransparency = 0
                    }):Play()
                end
            end
        end
    end

    local WindowLogic = {}

    function WindowLogic:CreateTab(name, emoji)
        if Pages[name] then
            warn("Tab already exists:", name)
            return
        end

        local TabBtn = Instance.new("TextButton")
        TabBtn.Parent = Sidebar
        TabBtn.BackgroundTransparency = 1
        TabBtn.Size = UDim2.new(1, 0, 0, 30)
        TabBtn.Text = (emoji or "") .. " " .. name
        TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabBtn.TextSize = 14
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UIPadding", TabBtn).PaddingLeft = UDim.new(0, 10)

        local Page = Instance.new("ScrollingFrame")
        Page.Name = name .. "Page"
        Page.Parent = PageContainer
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y

        -- Canvas fallback
        local Canvas
        local ok = pcall(function()
            Canvas = Instance.new("CanvasGroup")
        end)

        if not ok or not Canvas then
            Canvas = Instance.new("Frame")
        end

        Canvas.Name = "Canvas"
        Canvas.Size = UDim2.new(1, 0, 1, 0)
        Canvas.BackgroundTransparency = 1

        if Canvas:IsA("CanvasGroup") then
            Canvas.GroupTransparency = 1
        end

        Canvas.Parent = Page

        local LeftCol = Instance.new("Frame")
        LeftCol.Size = UDim2.new(0.5, -5, 1, 0)
        LeftCol.BackgroundTransparency = 1
        LeftCol.Parent = Canvas
        Instance.new("UIListLayout", LeftCol).Padding = UDim.new(0, 2)

        local RightCol = Instance.new("Frame")
        RightCol.Size = UDim2.new(0.5, -5, 1, 0)
        RightCol.Position = UDim2.new(0.5, 5, 0, 0)
        RightCol.BackgroundTransparency = 1
        RightCol.Parent = Canvas
        Instance.new("UIListLayout", RightCol).Padding = UDim.new(0, 2)

        Pages[name] = Page

        if not firstTab then
            firstTab = name
            task.defer(function()
                ShowPage(name)
            end)
        end

        TabBtn.MouseButton1Click:Connect(function()
            ShowPage(name)
        end)

        local TabLogic = {}

        function TabLogic:AddToggle(side, text, callback)
            local column = (side == "Left" and LeftCol or RightCol)
            local Box = Instance.new("TextButton")
            Box.Size = UDim2.new(0, 14, 0, 14)
            Box.Text = text or "Toggle"
            Box.Parent = column

            local enabled = false
            Box.MouseButton1Click:Connect(function()
                enabled = not enabled
                if callback then
                    callback(enabled)
                end
            end)
        end

        function TabLogic:AddButton(side, text, callback)
            local column = (side == "Left" and LeftCol or RightCol)
            local Btn = Instance.new("TextButton")
            Btn.Text = text
            Btn.Size = UDim2.new(1, -10, 0, 22)
            Btn.Parent = column

            Btn.MouseButton1Click:Connect(function()
                if callback then
                    callback()
                end
            end)
        end

        return TabLogic
    end

    function WindowLogic:Show(name)
        ShowPage(name)
    end

    return WindowLogic
end

return Library
