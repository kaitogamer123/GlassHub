local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Elements = require(script.Parent.Elements)

local Window = {}

function Window.Create(hubName)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "GlassHub_PS99"
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

    local MiniCorner = Instance.new("UICorner", MiniFrame)
    MiniCorner.CornerRadius = UDim.new(0, 12)

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
    Title.Text = hubName or "🧊 GlassHub Pet Sim 99 (right shift to hide ui)"
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

    Instance.new("UIListLayout", Sidebar)

    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -131, 1, -35)
    PageContainer.Position = UDim2.new(0, 131, 0, 35)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = MainFrame

    local function MakeDraggable(obj, handle)
        local dragging, dragStart, startPos
        handle.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = i.Position
                startPos = obj.Position
                i.Changed:Connect(function()
                    if i.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = i.Position - dragStart
                obj.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
    end

    MakeDraggable(MainFrame, TopBar)
    MakeDraggable(MiniFrame, MiniBtn)

    local Pages = {}

    local function ShowPage(name)
        for _, p in pairs(Pages) do
            p.Visible = false
            p.Canvas.GroupTransparency = 1
        end
        if Pages[name] then
            Pages[name].Visible = true
            TweenService:Create(
                Pages[name].Canvas,
                TweenInfo.new(0.4, Enum.EasingStyle.Quart),
                { GroupTransparency = 0 }
            ):Play()
        end
    end

    local WindowLogic = {}

    function WindowLogic:CreateTab(name, emoji)
        local Page, Left, Right = Elements.CreateTab(
            Sidebar,
            PageContainer,
            Pages,
            name,
            emoji,
            ShowPage
        )

        local TabLogic = {}

        function TabLogic:AddToggle(side, text, callback)
            Elements.AddToggle(side == "Left" and Left or Right, text, callback)
        end

        function TabLogic:AddButton(side, text, callback)
            Elements.AddButton(side == "Left" and Left or Right, text, callback)
        end

        return TabLogic
    end

    function WindowLogic:Show(name)
        ShowPage(name)
    end

    TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quart), {
        Size = UDim2.new(0, 600, 0, 350),
        Position = UDim2.new(0.5, -300, 0.5, -175)
    }):Play()

    return WindowLogic
end

return Window
