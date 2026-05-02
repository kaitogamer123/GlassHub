-- Файл: GlassScripts/AutoGifts.lua
return function()
    if getgenv().AutoGiftsLoaded then return end
    getgenv().AutoGiftsLoaded = true

    local network = game:GetService("ReplicatedStorage"):WaitForChild("Network")
    local giftRemote = network:WaitForChild("Redeem Free Gift")

    task.spawn(function()
        while true do
            if getgenv().AutoCollectGifts == true then
                -- В PS99 всего 12 слотов подарков
                for i = 1, 12 do
                    if not getgenv().AutoCollectGifts then break end
                    
                    -- Используем pcall, чтобы не было ошибок, если подарок еще не готов
                    pcall(function()
                        giftRemote:InvokeServer(i)
                    end)
                    task.wait(0.5) 
                end
            end
            task.wait(60) -- Проверяем раз в минуту, чтобы не спамить
        end
    end)
end
