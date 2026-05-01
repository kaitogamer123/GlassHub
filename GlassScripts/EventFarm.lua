local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Network = RS:WaitForChild("Network"):WaitForChild("Breakables_JoinPetBulk")
local player = game:GetService("Players").LocalPlayer
local things = workspace:WaitForChild("__THINGS")
local breakables = things:WaitForChild("Breakables")
local petsFolder = things:WaitForChild("Pets")

getgenv().EventFarmActive = false
getgenv().EventLockedPos = nil 
getgenv().EventFarmRadius = 50 

local lastCircle = nil
local lastChangeTime = 0
local connection = nil

-- Функция плавного удаления круга
local function fadeOutCircle(circle)
	if not circle then return end
	local tween = TweenService:Create(circle, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Transparency = 1,
		Size = Vector3.new(0, 0, 0)
	})
	tween:Play()
	tween.Completed:Connect(function() circle:Destroy() end)
end

local function showVisualRadius()
	lastChangeTime = tick() -- Обновляем время последнего изменения
	
	-- Если круг уже есть, просто меняем его размер
	if lastCircle and lastCircle.Parent then
		local d = getgenv().EventFarmRadius * 2
		TweenService:Create(lastCircle, TweenInfo.new(0.2), {Size = Vector3.new(0.2, d, d)}):Play()
		return 
	end

	-- Создаем новый круг, если его нет
	local circle = Instance.new("Part")
	circle.Name = "GlassHub_VisualRadius"
	circle.Shape = Enum.PartType.Cylinder
	circle.Anchored = true
	circle.CanCollide = false
	circle.Transparency = 1
	circle.Color = Color3.fromRGB(80, 120, 255)
	circle.Material = Enum.Material.Neon
	
	local d = getgenv().EventFarmRadius * 2
	circle.Size = Vector3.new(0.2, d, d)
	circle.Parent = workspace
	lastCircle = circle

	TweenService:Create(circle, TweenInfo.new(0.4), {Transparency = 0.7}):Play()

	-- Логика следования и авто-удаления
	if connection then connection:Disconnect() end
	connection = RunService.RenderStepped:Connect(function()
		if not circle or not circle.Parent then 
			if connection then connection:Disconnect() end
			return 
		end

		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local pos = getgenv().EventLockedPos or (root and root.Position)

		if pos then
			circle.CFrame = CFrame.new(pos - Vector3.new(0, 2.8, 0)) * CFrame.Angles(0, 0, math.rad(90))
		end

		-- Если прошло 5 секунд с последнего изменения/показа
		if tick() - lastChangeTime > 5 then
			connection:Disconnect()
			lastCircle = nil
			fadeOutCircle(circle)
		end
	end)
end

-- Основной цикл фарма (оставлен без изменений)
task.spawn(function()
	while true do
		if getgenv().EventFarmActive then
			local char = player.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local farmPos = getgenv().EventLockedPos or (root and root.Position)
			
			if farmPos and #petIds > 0 then
				local targets = {}
				local radiusSq = getgenv().EventFarmRadius^2 
				local allBreakables = breakables:GetChildren()
				
				for i = 1, #allBreakables do
					local obj = allBreakables[i]
					local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
					if part then
						local pPos = part.Position
						local dx, dz = pPos.X - farmPos.X, pPos.Z - farmPos.Z
						if (dx*dx + dz*dz) <= radiusSq then
							table.insert(targets, obj.Name)
						end
					end
					if #targets >= 40 then break end 
				end

				if #targets > 0 then
					local data = {}
					-- Тут твоя логика отправки Network...
					-- Network:FireServer(data)
				end
			end
		end
		task.wait(0.12)
	end
end)

return {
	Toggle = function(v) getgenv().EventFarmActive = v end,
	SetRadius = function(v) 
		getgenv().EventFarmRadius = v 
		showVisualRadius() -- Вызываем обновление при каждом движении слайдера!
	end,
	Show = function() showVisualRadius() end,
	Lock = function()
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if root then getgenv().EventLockedPos = root.Position end
	end,
	Reset = function() getgenv().EventLockedPos = nil end
}
