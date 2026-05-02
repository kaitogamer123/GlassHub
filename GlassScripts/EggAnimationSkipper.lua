-- Файл: GlassScripts/EggAnimationSkipper.lua
return function()
    if getgenv().EggSkipLoaded then return end
    getgenv().EggSkipLoaded = true

    local Library = require(game:GetService("ReplicatedStorage"):WaitForChild("Library"))
    local EggCmds = require(game:GetService("ReplicatedStorage").Library.Client.EggCmds)
    
    getgenv().DisableEggAnim = false

    -- 1. ХУК СЕТЕВОГО СОБЫТИЯ (Самый эффективный метод)
    -- Мы перехватываем момент, когда сервер говорит клиенту "покажи анимацию"
    local EggAnim = require(game:GetService("ReplicatedStorage").Library.Client.EggOpeningFrontend)
    local oldPlay = EggAnim.Play
    
    EggAnim.Play = function(...)
        if getgenv().DisableEggAnim then
            -- Просто возвращаем пустую таблицу, как будто анимация уже закончилась
            return {
                Wait = function() return end,
                Destroy = function() return end
            }
        end
        return oldPlay(...)
    end

    -- 2. ОЧИСТКА ЭКРАНА И РАЗБЛОКИРОВКА
    task.spawn(function()
        while task.wait(0.5) do
            if getgenv().DisableEggAnim then
                -- Принудительно говорим игре, что мы НЕ открываем яйцо сейчас
                if Library.Variables then
                    Library.Variables.OpeningEgg = false
                end

                -- Удаляем черные экраны, если они появились
                local pGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
                if pGui then
                    local eggGui = pGui:FindFirstChild("EggOpen") or pGui:FindFirstChild("Hatch")
                    if eggGui then 
                        eggGui.Enabled = false 
                    end
                end
            end
        end
    end)
end
