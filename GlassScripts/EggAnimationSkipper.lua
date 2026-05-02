-- Файл: GlassScripts/EggAnimationSkipper.lua
return function()
    if getgenv().EggSkipLoaded then return end
    getgenv().EggSkipLoaded = true

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Library = require(ReplicatedStorage:WaitForChild("Library"))
    
    getgenv().DisableEggAnim = false -- Переменная для кнопки

    -- 1. УМНЫЙ ХУК (Сохраняем возможность вернуть анимацию)
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "Play") and type(v.Play) == "function" then
            local info = getinfo(v.Play)
            if info.source:find("Egg") or info.source:find("Hatch") then
                local oldPlay = v.Play
                v.Play = function(...)
                    if getgenv().DisableEggAnim then return end -- Если включено, ничего не делаем
                    return oldPlay(...) -- Если выключено, запускаем оригинал
                end
            end
        elseif type(v) == "function" then
            local info = getinfo(v)
            if info.name == "PlayEggAnimation" or info.name == "ShowHatch" then
                local oldFunc = v
                hookfunction(v, function(...)
                    if getgenv().DisableEggAnim then return end
                    return oldFunc(...)
                end)
            end
        end
    end

    -- 2. УДАЛЕНИЕ GUI (Работает только при включенном Toggle)
    task.spawn(function()
        while task.wait(0.2) do
            if getgenv().DisableEggAnim then
                local pGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
                if pGui then
                    for _, gui in pairs(pGui:GetChildren()) do
                        if gui:IsA("ScreenGui") and (gui.Name:find("Egg") or gui.Name:find("Hatch") or gui.Name:find("Scene")) then
                            gui:Destroy()
                        end
                    end
                end
            end
        end
    end)

    -- 3. РАЗБЛОКИРОВКА ИНТЕРФЕЙСА
    game:GetService("RunService").RenderStepped:Connect(function()
        if getgenv().DisableEggAnim and Library.Variables then
            Library.Variables.OpeningEgg = false
        end
    end)
end
