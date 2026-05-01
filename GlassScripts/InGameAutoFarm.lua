local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Library = ReplicatedStorage:WaitForChild("Library")
local AutoFarmCmds = require(Library.Client.AutoFarmCmds)

-- Используем getgenv() вместо _G, так как в хабах это надежнее
getgenv().Glass_InGameEnabled = false

task.spawn(function()
    while true do
        -- Проверяем, активен ли переключатель в твоем UI
        if getgenv().Glass_InGameEnabled then
            -- Проверяем статус через .Active (так надежнее в текущем API игры)
            local isActive = false
            pcall(function()
                isActive = AutoFarmCmds.Active or AutoFarmCmds.IsEnabled()
            end)

            if not isActive then
                pcall(function()
                    AutoFarmCmds.Enable()
                end)
            end
        else
            -- Выключаем, если в UI галочка снята
            local isActive = false
            pcall(function()
                isActive = AutoFarmCmds.Active or AutoFarmCmds.IsEnabled()
            end)

            if isActive then
                pcall(function()
                    AutoFarmCmds.Disable()
                end)
            end
        end
        task.wait(1)
    end
end)

-- Возвращаем функцию для твоего лоадера/кнопки
return function(state)
    getgenv().Glass_InGameEnabled = state
    print("🧊 [GlassHub]: In-Game Farm state ->", state)
end
