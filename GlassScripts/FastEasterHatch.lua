-- Файл: GlassScripts/FastEasterHatch.lua
return function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Network = ReplicatedStorage:WaitForChild("Network", 10)
    local remote = Network and Network:WaitForChild("Instancing_InvokeCustomFromClient", 10)
    
    if not remote then 
        warn("--- [HATCHER ERROR]: Remote не найден! ---")
        return 
    end

    -- НАСТРОЙКИ СКОРОСТИ
    local THREADS = 30 -- Максимальное количество потоков
    local DELAY = 0.0  -- Без задержки (максимальный спам)

    local function hatch()
        pcall(function()
            -- Основной запрос
            remote:InvokeServer("EasterHatchEvent", "HatchRequest")
            
            -- Рандомный доп. запрос
            if math.random() < 0.125 then
                remote:InvokeServer("EasterHatchEvent", "HatchRequest", math.random(1, 3))
            end
        end)
    end

    print("--- [HATCHER]: Запуск " .. THREADS .. " потоков... ---")
    
    for i = 1, THREADS do
        task.spawn(function()
            while true do
                -- Проверяем глобальную переменную из Toggle
                if getgenv().FastEasterHatch then
                    hatch()
                    -- Если задержка 0, task.wait() все равно нужен, чтобы не крашнуть клиент
                    if DELAY == 0 then task.wait() else task.wait(DELAY) end
                else
                    task.wait(0.5) -- Спим, когда выключено
                end
            end
        end)
    end
end
