local Library = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- Настройки конфига
Library.Config = {}
Library.ConfigFolder = "GlassHub"
Library.ConfigFile = Library.ConfigFolder .. "/config.json"

-- Функции сохранения и загрузки
function Library.SaveConfig()
    if not isfolder(Library.ConfigFolder) then makefolder(Library.ConfigFolder) end
    writefile(Library.ConfigFile, HttpService:JSONEncode(Library.Config))
end

function Library.LoadConfig()
    if isfile(Library.ConfigFile) then
        local success, data = pcall(function() 
            return HttpService:JSONDecode(readfile(Library.ConfigFile)) 
        end)
        if success then Library.Config = data end
    end
end

-- Загружаем данные ПЕРЕД созданием окна
Library.LoadConfig()

function Library:CreateWindow(hubName)
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

	local BackgroundImage = Instance.new("ImageLabel")
	BackgroundImage.Name = "BackgroundImage"
	BackgroundImage.Parent = MainFrame

	BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
	BackgroundImage.Position = UDim2.new(0, 0, 0, 0)

	BackgroundImage.BackgroundTransparency = 1
	BackgroundImage.Image = ""
	BackgroundImage.ImageTransparency = 0.7
	BackgroundImage.ScaleType = Enum.ScaleType.Crop
	BackgroundImage.ZIndex = 0

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
	TopBar.Name = "TopBar"
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

	local TopSep = Instance.new("Frame")
	TopSep.Size = UDim2.new(1, 0, 0, 1)
	TopSep.Position = UDim2.new(0, 0, 0, 35)
	TopSep.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	TopSep.BorderSizePixel = 0
	TopSep.ZIndex = 5
	TopSep.Parent = MainFrame

	local SideSep = Instance.new("Frame")
	SideSep.Size = UDim2.new(0, 1, 1, -35)
	SideSep.Position = UDim2.new(0, 130, 0, 35)
	SideSep.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	SideSep.BorderSizePixel = 0
	SideSep.ZIndex = 5
	SideSep.Parent = MainFrame

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
	PageContainer.Name = "PageContainer"
	PageContainer.Size = UDim2.new(1, -131, 1, -35)
	PageContainer.Position = UDim2.new(0, 131, 0, 35)
	PageContainer.BackgroundTransparency = 1
	PageContainer.Parent = MainFrame

	local function MakeDraggable(obj, dragHandle)
		local dragging, dragInput, dragStart, startPos

		dragHandle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				dragStart = input.Position
				startPos = obj.Position

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
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
	end

	MakeDraggable(MainFrame, TopBar)
	MakeDraggable(MiniFrame, MiniBtn)

	local uiVisible = true

	UserInputService.InputBegan:Connect(function(input, gp)
		if not gp and input.KeyCode == Enum.KeyCode.RightShift then
			uiVisible = not uiVisible
			ScreenGui.Enabled = uiVisible
		end
	end)

	local isAnimating = false

	MinimizeBtn.MouseButton1Click:Connect(function()
		if isAnimating then return end
		isAnimating = true

		local centerX = MainFrame.Position.X.Offset + (MainFrame.Size.X.Offset / 2)
		local centerY = MainFrame.Position.Y.Offset + (MainFrame.Size.Y.Offset / 2)

		TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(MainFrame.Position.X.Scale, centerX, MainFrame.Position.Y.Scale, centerY)
		}):Play()

		task.wait(0.4)

		MainFrame.Visible = false
		MiniFrame.Visible = true
		MiniFrame.Size = UDim2.new(0, 0, 0, 0)
		MiniFrame.Position = UDim2.new(MainFrame.Position.X.Scale, centerX, MainFrame.Position.Y.Scale, centerY)
		MiniTitle.TextSize = 0

		TweenService:Create(MiniFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 60, 0, 60),
			Position = UDim2.new(MainFrame.Position.X.Scale, centerX - 30, MainFrame.Position.Y.Scale, centerY - 30)
		}):Play()

		TweenService:Create(MiniTitle, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			TextSize = 30
		}):Play()

		task.wait(0.4)
		isAnimating = false
	end)

	MiniBtn.MouseButton1Click:Connect(function()
		if isAnimating then return end
		isAnimating = true

		local centerX = MiniFrame.Position.X.Offset + (MiniFrame.Size.X.Offset / 2)
		local centerY = MiniFrame.Position.Y.Offset + (MiniFrame.Size.Y.Offset / 2)

		TweenService:Create(MiniTitle, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			TextSize = 0
		}):Play()

		local hideMini = TweenService:Create(MiniFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(MiniFrame.Position.X.Scale, centerX, MiniFrame.Position.Y.Scale, centerY)
		})

		hideMini:Play()

		hideMini.Completed:Connect(function()
			MiniFrame.Visible = false
			MainFrame.Visible = true
			MainFrame.Size = UDim2.new(0, 0, 0, 0)
			MainFrame.Position = UDim2.new(MiniFrame.Position.X.Scale, centerX, MiniFrame.Position.Y.Scale, centerY)

			TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 600, 0, 350),
				Position = UDim2.new(MiniFrame.Position.X.Scale, centerX - 300, MiniFrame.Position.Y.Scale, centerY - 175)
			}):Play()

			task.wait(0.5)
			isAnimating = false
		end)
	end)

	TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 600, 0, 350),
		Position = UDim2.new(0.5, -300, 0.5, -175)
	}):Play()

	local Pages = {}

	local function ShowPage(name)
		for _, v in pairs(Pages) do
			v.Visible = false
			v.Canvas.GroupTransparency = 1
		end

		if Pages[name] then
			Pages[name].Visible = true

			TweenService:Create(
				Pages[name].Canvas,
				TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{ GroupTransparency = 0 }
			):Play()
		end
	end

	local WindowLogic = {}

	function WindowLogic:CreateTab(name, emoji)
		local TabBtn = Instance.new("TextButton")
		TabBtn.Name = name .. "Tab"
		TabBtn.Parent = Sidebar
		TabBtn.BackgroundTransparency = 1
		TabBtn.BorderSizePixel = 0
		TabBtn.Size = UDim2.new(1, 0, 0, 30)
		TabBtn.Font = Enum.Font.SourceSans
		TabBtn.Text = emoji .. " " .. name
		TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
		TabBtn.TextSize = 14
		TabBtn.TextXAlignment = Enum.TextXAlignment.Left

		local Padding = Instance.new("UIPadding")
		Padding.PaddingLeft = UDim.new(0, 10)
		Padding.Parent = TabBtn

		TabBtn.MouseEnter:Connect(function()
			TabBtn.BackgroundTransparency = 0.8
		end)

		TabBtn.MouseLeave:Connect(function()
			TabBtn.BackgroundTransparency = 1
		end)

		local Page = Instance.new("ScrollingFrame")
		Page.Name = name .. "Page"
		Page.Parent = PageContainer
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.Visible = false
		Page.ScrollBarThickness = 2
		Page.BorderSizePixel = 0
		Page.CanvasSize = UDim2.new(0, 0, 0, 0)
		Page.AutomaticCanvasSize = Enum.AutomaticSize.Y

		local Canvas
		local isCanvasGroup = true

		local success = pcall(function()
			Canvas = Instance.new("CanvasGroup")
		end)

		if not success or not Canvas then
			isCanvasGroup = false
			Canvas = Instance.new("Frame")
		end

		Canvas.Name = "Canvas"
		Canvas.Size = UDim2.new(1, 0, 1, 0)
		Canvas.BackgroundTransparency = 1

		if isCanvasGroup then
			Canvas.GroupTransparency = 1
		else
			Canvas.BackgroundTransparency = 1
		end

		Canvas.Parent = Page

		local LeftCol = Instance.new("Frame")
		LeftCol.Name = "LeftCol"
		LeftCol.Size = UDim2.new(0.5, -5, 1, 0)
		LeftCol.BackgroundTransparency = 1
		LeftCol.Parent = Canvas

		local L_Layout = Instance.new("UIListLayout")
		L_Layout.Parent = LeftCol
		L_Layout.Padding = UDim.new(0, 2)

		local RightCol = Instance.new("Frame")
		RightCol.Name = "RightCol"
		RightCol.Size = UDim2.new(0.5, -5, 1, 0)
		RightCol.Position = UDim2.new(0.5, 5, 0, 0)
		RightCol.BackgroundTransparency = 1
		RightCol.Parent = Canvas

		local R_Layout = Instance.new("UIListLayout")
		R_Layout.Parent = RightCol
		R_Layout.Padding = UDim.new(0, 2)

		Pages[name] = Page

		TabBtn.MouseButton1Click:Connect(function()
			ShowPage(name)
		end)

		local TabLogic = {}

		function TabLogic:AddToggle(side, text, callback)
			local column = (side == "Left" and LeftCol or RightCol)

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

			local Gradient = Instance.new("UIGradient")
			Gradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 120, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 80, 255))
			})
			Gradient.Rotation = 45
			Gradient.Enabled = false
			Gradient.Parent = Box

			local Corner = Instance.new("UICorner")
			Corner.CornerRadius = UDim.new(0, 3)
			Corner.Parent = Box

			local Stroke = Instance.new("UIStroke")
			Stroke.Thickness = 1
			Stroke.Color = Color3.fromRGB(60, 60, 60)
			Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			Stroke.Parent = Box

			local enabled = Config[text] or false

			local function UpdateVisuals()
				Gradient.Enabled = enabled
				Box.BackgroundColor3 = enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 40)

				local targetStroke = enabled and Color3.fromRGB(140, 100, 255) or Color3.fromRGB(60, 60, 60)
				TweenService:Create(Stroke, TweenInfo.new(0.2), {
					Color = targetStroke
				}):Play()
			end

			    
    		Box.MouseButton1Click:Connect(function()
        		enabled = not enabled
        		Library.Config[text] = enabled -- СЮДА
        		Library:SaveConfig() -- И СЮДА
        		UpdateVisuals()
        		callback(enabled)
    		end)
		end

			if enabled then
				task.spawn(function()
					callback(true)
				end)
			end

			Box.MouseButton1Click:Connect(function()
				enabled = not enabled
				Config[text] = enabled
				SaveConfig()
				UpdateVisuals()
				callback(enabled)
			end)
		end
		function TabLogic:AddDropdown(side, text, list, callback)
			local column = (side == "Left" and LeftCol or RightCol)
			local isMulti = (text == "Upgrades" or text == "Luck Boosts")
			
			local DropFrame = Instance.new("Frame")
			DropFrame.Size = UDim2.new(1, 0, 0, 26)
			DropFrame.BackgroundTransparency = 1
			DropFrame.ClipsDescendants = true
			DropFrame.Parent = column
			
			local MainBtn = Instance.new("TextButton")
			MainBtn.Size = UDim2.new(1, -10, 0, 22)
			MainBtn.Position = UDim2.new(0, 5, 0, 2)
			MainBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			MainBtn.Text = text .. " ▼"
			MainBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
			MainBtn.TextSize = 12
			MainBtn.Font = Enum.Font.SourceSans
			MainBtn.Parent = DropFrame
			Instance.new("UICorner", MainBtn).CornerRadius = UDim.new(0, 4)
			
			local Stroke = Instance.new("UIStroke", MainBtn)
			Stroke.Color = Color3.fromRGB(65, 65, 65)
			Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

			local opened = false
			local selectedItems = Library.Config[text] or {}
			if type(selectedItems) ~= "table" then selectedItems = {} end

			local function updateMainText()
				if isMulti then
					local count = 0
					for _, s in pairs(selectedItems) do if s then count = count + 1 end end
					MainBtn.Text = text .. " (" .. count .. ") " .. (opened and "▲" or "▼")
				else
					local current = "None"
					for k, v in pairs(selectedItems) do if v then current = k break end end
					MainBtn.Text = (current == "None") and (text .. " ▼") or (text .. ": " .. current .. (opened and " ▲" or " ▼"))
				end
			end

			MainBtn.MouseButton1Click:Connect(function()
				opened = not opened
				TweenService:Create(DropFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Size = UDim2.new(1, 0, 0, opened and (#list * 22 + 28) or 26)
				}):Play()
				updateMainText()
			end)

			local itemButtons = {}

			for i, v in pairs(list) do
				local Item = Instance.new("TextButton")
				Item.Size = UDim2.new(1, -10, 0, 20)
				Item.Position = UDim2.new(0, 5, 0, i * 22 + 4)
				Item.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
				Item.Text = v
				Item.TextColor3 = selectedItems[v] and Color3.fromRGB(140, 100, 255) or Color3.fromRGB(180, 180, 180)
				Item.TextSize = 12
				Item.Font = Enum.Font.SourceSans
				Item.Parent = DropFrame
				Instance.new("UICorner", Item).CornerRadius = UDim.new(0, 4)
				itemButtons[v] = Item

				Item.MouseButton1Click:Connect(function()
					if isMulti then
						selectedItems[v] = not selectedItems[v]
					else
						for name, _ in pairs(selectedItems) do 
							selectedItems[name] = false 
							if itemButtons[name] then itemButtons[name].TextColor3 = Color3.fromRGB(180, 180, 180) end
						end
						selectedItems[v] = true
						opened = false
						TweenService:Create(DropFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 26)}):Play()
					end

					Library.Config[text] = selectedItems
					if Library.SaveConfig then Library.SaveConfig() end
					
					local targetColor = selectedItems[v] and Color3.fromRGB(140, 100, 255) or Color3.fromRGB(180, 180, 180)
					TweenService:Create(Item, TweenInfo.new(0.2), {TextColor3 = targetColor}):Play()
					
					updateMainText()
					callback(v, selectedItems[v])
				end)
			end

			updateMainText()
			for name, state in pairs(selectedItems) do
				if state then task.spawn(function() callback(name, true) end) end
			end
		end

		function TabLogic:AddToggle(side, text, callback)
			local column = (side == "Left" and LeftCol or RightCol)
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
			local Gradient = Instance.new("UIGradient")
			Gradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 120, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 80, 255))
			})
			Gradient.Rotation = 45
			Gradient.Enabled = false
			Gradient.Parent = Box
			local Corner = Instance.new("UICorner")
			Corner.CornerRadius = UDim.new(0, 3)
			Corner.Parent = Box
			local Stroke = Instance.new("UIStroke")
			Stroke.Thickness = 1
			Stroke.Color = Color3.fromRGB(60, 60, 60)
			Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			Stroke.Parent = Box

			-- Использование Library.Config вместо локального
			local enabled = Library.Config[text] or false
			
			local function UpdateVisuals()
				Gradient.Enabled = enabled
				Box.BackgroundColor3 = enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 40)
				local targetStroke = enabled and Color3.fromRGB(140, 100, 255) or Color3.fromRGB(60, 60, 60)
				TweenService:Create(Stroke, TweenInfo.new(0.2), {Color = targetStroke}):Play()
			end
			
			UpdateVisuals()
			if enabled then task.spawn(function() callback(true) end) end

			Box.MouseButton1Click:Connect(function()
				enabled = not enabled
				Library.Config[text] = enabled
				if Library.SaveConfig then Library.SaveConfig() end
				UpdateVisuals()
				callback(enabled)
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
	
