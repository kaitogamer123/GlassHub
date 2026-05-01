local Library = game:GetService("ReplicatedStorage"):WaitForChild("Library")
local Cmd = require(Library.Client.AutoFarmCmds)

getgenv().Glass_InGame_Active = false

-- ЗАЩИТА: Хукаем функцию Disable, чтобы другие скрипты не могли её вызвать
if not getgenv().FarmProtected then
    local oldDisable = Cmd.Disable
    Cmd.Disable = function(...)
        -- Если наш чит говорит "работать", то игнорируем любые попытки выключить
        if getgenv().Glass_InGame_Active then 
            return nil 
        end
        return oldDisable(...)
    end
    getgenv().FarmProtected = true
end

-- Фоновый поток, который проверяет, не слетел ли флаг Active (на всякий случай)
task.spawn(function()
    while true do
        if getgenv().Glass_InGame_Active and not Cmd.Active then
            pcall(function() Cmd.Enable() end)
        end
        task.wait(0.5)
    end
end)

return function(state)
    getgenv().Glass_InGame_Active = state
    if state then
        pcall(function() Cmd.Enable() end)
    else
        -- Теперь выключить можно только через наш рычаг, 
        -- так как мы временно отключаем защиту выше
        local oldState = getgenv().Glass_InGame_Active
        getgenv().Glass_InGame_Active = false 
        pcall(function() Cmd.Disable() end)
    end
end
