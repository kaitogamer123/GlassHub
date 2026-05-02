-- Файл: GlassScripts/EggAnimationSkipper.lua
return function()
    -- Защита, чтобы не хукать по сто раз при повторном нажатии кнопки
    if getgenv().EggSkipApplied then 
        print("🧊 [GlassHub]: Анимации уже удалены.")
        return 
    end
    getgenv().EggSkipApplied = true

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Network = ReplicatedStorage:WaitForChild("Network")
    
    -- 1. ХУК ФУНКЦИЙ (ОДНОРАЗОВЫЙ)
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "Play") and type(v.Play) == "function" then
            local info = getinfo(v.Play)
            if info.source:find("Egg") or info.source:find("Hatch") then
                v.Play = function() return end
            end
        elseif type(v) == "function" then
            local info = getinfo(v)
            if info.name == "PlayEggAnimation" or info.name == "ShowHatch" then
                hookfunction(v, function() return end)
            end
        end
    end

    -- 2. ЦИКЛ ОЧИСТКИ ЭКРАНА (Запускается один раз и работает в фоне)
    task.spawn(function()
        while task.wait(0.1) do
            local pGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
            if pGui then
                for _, gui in pairs(pGui:GetChildren()) do
                    if gui:IsA("ScreenGui") and (gui.Name:find("Egg") or gui.Name:find("Hatch") or gui.Name:find("Scene")) then
                        gui:Destroy()
                    end
                end
            end
        end
    end)

    -- 3. РАЗБЛОКИРОВКА ИНТЕРФЕЙСА
    task.spawn(function()
        local Library = require(ReplicatedStorage:WaitForChild("Library"))
        game:GetService("RunService").RenderStepped:Connect(function()
            if Library.Variables then
                Library.Variables.OpeningEgg = false
            end
        end)
    end)

    -- 4. ТВОЯ ФУНКЦИЯ ФЛАГОВ (Доступна для использования в других скриптах)
    getgenv().PlaceFlag = function(zoneName)
        local args = {"Coins Flag", "33ca54bee6434c91b8703448c8369ade", 40}
        pcall(function()
            Network:WaitForChild("FlexibleFlags_Consume"):InvokeServer(unpack(args))
            print("Флаг успешно установлен в зоне: " .. zoneName)
        end)
    end

    print("✅ [GlassHub]: Анимации яиц успешно вырезаны!")
end
