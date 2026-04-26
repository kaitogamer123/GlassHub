local TweenService = game:GetService("TweenService")

local Elements = {}

function Elements.AddToggle(column, text, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 22)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = column

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -30, 1, 0)
    Label.Position = UDim2.new(0, 5, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(180, 180, 180)
    Label.TextSize = 13
    Label.Font = Enum.Font.SourceSans
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    local Box = Instance.new("TextButton")
    Box.Size = UDim2.new(0, 14, 0, 14)
    Box.Position = UDim2.new(1, -20, 0.5, -7)
    Box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Box.BorderSizePixel = 0
    Box.Text = ""
    Box.Parent = ToggleFrame

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 3)
    Corner.Parent = Box

    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1
    Stroke.Color = Color3.fromRGB(60, 60, 60)
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = Box

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

function Elements.AddButton(column, text, callback)
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Size = UDim2.new(1, 0, 0, 28)
    ButtonFrame.BackgroundTransparency = 1
    ButtonFrame.Parent = column

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 22)
    Btn.Position = UDim2.new(0, 5, 0.5, -11)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.TextSize = 13
    Btn.Font = Enum.Font.SourceSans
    Btn.Parent = ButtonFrame

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Btn

    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1
    Stroke.Color = Color3.fromRGB(65, 65, 65)
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = Btn

    Btn.MouseButton1Click:Connect(function()
        Btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        task.wait(0.1)
        Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        callback()
    end)
end

return Elements
