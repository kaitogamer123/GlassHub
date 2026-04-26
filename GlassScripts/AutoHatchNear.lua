-- Файл: GlassScripts/AutoHatch.lua
return function()
    -- Проверка на дубликаты
    if getgenv().AutoHatchLoaded then return end
    getgenv().AutoHatchLoaded = true

    local EggsUtil = require(game.ReplicatedStorage.Library.Util.EggsUtil)
    local EggCmds = require(game.ReplicatedStorage.Library.Client.EggCmds)

    -- Сама функция поиска и открытия
    local function hatchNearest()
        local player = game.Players.LocalPlayer
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        local rootPos = char.HumanoidRootPart.Position
        local eggsFolder = game.Workspace:WaitForChild("__THINGS"):WaitForChild("Eggs")
        
        local nearestEggData = nil
        local minDist = 50 

        for _, v in pairs(eggsFolder:GetDescendants()) do
            if v:IsA("Model") and v.Name:match("^%d+") then
                local part = v:FindFirstChild("Center") or v:FindFirstChildWhichIsA("BasePart")
                if part then
                    local dist = (rootPos - part.Position).Magnitude
                    if dist < minDist then
                        local eggNumber = tonumber(v.Name:match("^%d+"))
                        local data = EggsUtil.GetByNumber(eggNumber)
                        if data then
                            minDist = dist
                            nearestEggData = data
                        end
                    end
                end
            end
        end

        if nearestEggData then
            local maxHatch = 1
            pcall(function() maxHatch = EggCmds.GetMaxHatch() end)
            pcall(function()
                EggCmds.RequestPurchase(nearestEggData._id, maxHatch)
            end)
        end
    end

    -- Цикл, который ждет команду от кнопки
    task.spawn(function()
        while true do
            -- Используем getgenv() вместо _G для надежности во внешних экзекуторах
            if getgenv().AutoHatchNearEgg == true then
                hatchNearest()
                task.wait(0.5)
            else
                task.wait(1)
            end
        end
    end)
end
