-- Файл: GlassScripts/AutoMailClaim.lua
return function()
    if getgenv().AutoMailLoaded then return end
    getgenv().AutoMailLoaded = true

    local network = game:GetService("ReplicatedStorage"):WaitForChild("Network")
    
    -- Функция для получения списка всех ID писем
    local function getMailIds()
        local ids = {}
        -- Обращаемся к данным игрока через библиотеку игры, чтобы увидеть почту
        local success, gifts = pcall(function()
            return require(game:GetService("ReplicatedStorage").Library.Client.Save).Get().Inventory.Mailbox
        end)
        
        if success and gifts then
            for id, _ in pairs(gifts) do
                table.insert(ids, id)
            end
        end
        return ids
    end

    task.spawn(function()
        while true do
            if getgenv().AutoClaimMail == true then
                local mailIds = getMailIds()
                
                if #mailIds > 0 then
                    -- Отправляем список ID в твой ремоут (как в твоем примере)
                    pcall(function()
                        network["Mailbox: Claim"]:InvokeServer(mailIds)
                    end)
                end
            end
            -- Проверка каждые 5 секунд, как ты и просил
            task.wait(5)
        end
    end)
end
