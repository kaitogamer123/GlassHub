-- Файл: GlassScripts/EggAnimationSkipper.lua
return function()
    if getgenv().EggSkipLoaded then return end
    getgenv().EggSkipLoaded = true

    local Library = require(game:GetService("ReplicatedStorage"):WaitForChild("Library"))
    local originals = {} -- Тут храним настоящие функции игры
    getgenv().DisableEggAnim = false

    -- 1. ПОИСК И ХРАНЕНИЕ ОРИГИНАЛОВ
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "Play") and type(v.Play) == "function" then
            local info = debug.getinfo(v.Play)
            if info.source:find("Egg") or info.source:find("Hatch") then
                originals[v] = v.Play -- Сохраняем оригинал
            end
        end
    end

    -- 2. ЦИКЛ ДЛЯ ГИБКОГО ПЕРЕКЛЮЧЕНИЯ
    task.spawn(function()
        while task.wait(0.5) do
            if getgenv().DisableEggAnim then
                -- ПОДМЕНЯЕМ НА ПУСТОТУ
                for tbl, func in pairs(originals) do
                    tbl.Play = function() return end
                end
                
                -- УДАЛЯЕМ GUI АНИМАЦИИ
                local pGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
                if pGui then
                    for _, gui in pairs(pGui:GetChildren()) do
                        if gui:IsA("ScreenGui") and (gui.Name:find("Egg") or gui.Name:find("Hatch") or gui.Name:find("Scene")) then
                            gui.Enabled = false -- Лучше выключать, чем удалять (безопаснее)
                        end
                    end
                end

                -- ОБМАНЫВАЕМ БИБЛИОТЕКУ
                if Library.Variables then
                    Library.Variables.OpeningEgg = false
                end
            else
                -- ВОЗВРАЩАЕМ КАК БЫЛО
                for tbl, func in pairs(originals) do
                    tbl.Play = func
                end
            end
        end
    end)
end

-- В ЛОАДЕРЕ ИСПОЛЬЗУЙ ТАК:
-- EggTab:AddToggle("Left", "Skip Egg Animation", function(v)
--     getgenv().DisableEggAnim = v
-- end)
