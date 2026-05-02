-- Файл: GlassScripts/MailLogic.lua
return function()
    if getgenv().MailLogicLoaded then return end
    getgenv().MailLogicLoaded = true

    local player = game:GetService("Players").LocalPlayer
    local runService = game:GetService("RunService")
    
    -- Безопасный поиск гуишки почтового ящика
    local mailbox = player:WaitForChild("PlayerGui"):WaitForChild("_MACHINES"):WaitForChild("MailboxMachine")
    
    getgenv().OpenMail = false

    runService.RenderStepped:Connect(function()
        local targetState = getgenv().OpenMail
        
        -- Проверка типа объекта и установка видимости
        if mailbox:IsA("ScreenGui") then
            if mailbox.Enabled ~= targetState then
                mailbox.Enabled = targetState
            end
        elseif mailbox:IsA("Frame") or mailbox:IsA("ScrollingFrame") then
            if mailbox.Visible ~= targetState then
                mailbox.Visible = targetState
            end
        end
    end)
end
