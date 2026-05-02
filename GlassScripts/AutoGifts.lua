-- Файл: GlassScripts/AutoGifts.lua
return function()
    if getgenv().AutoGiftsLoaded then return end
    getgenv().AutoGiftsLoaded = true

    local network = game:GetService("ReplicatedStorage"):WaitForChild("Network")
    local giftRemote = network:WaitForChild("Redeem Free Gift")

    task.spawn(function()
        while true do
            -- Работаем только если кнопка включена
            if getgenv().AutoCollectGifts == true then
                for i = 1, 12 do
                    if not getgenv().AutoCollectGifts then break end
                    
                    -- Собираем подарки по очереди
                    pcall(function()
                        giftRemote:InvokeServer(i)
                    end)
                    task.wait(0.5) 
                end
            end
            -- Ждем 2 минуты перед следующей проверкой (подарки в PS99 копятся долго)
            task.wait(120) 
        end
    end)
end
