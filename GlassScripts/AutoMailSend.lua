-- Файл: GlassScripts/AutoMailSend.lua
return function()
    if getgenv().MailSendLoaded then return end
    getgenv().MailSendLoaded = true

    local network = game:GetService("ReplicatedStorage"):WaitForChild("Network")
    local save = require(game:GetService("ReplicatedStorage").Library.Client.Save)

    local function sendAllHuges()
        local target = getgenv().MailTargetUser
        if not target or target == "" then return end

        -- Получаем инвентарь петов
        local inventory = save.Get().Inventory.Pet
        if not inventory then return end

        for uid, data in pairs(inventory) do
            -- Проверяем, включена ли еще функция
            if not getgenv().AutoSendHuges then break end

            -- Проверяем данные пета через библиотеку игры (ItemCmds или Directory)
            local itemData = require(game:GetService("ReplicatedStorage").Library.Directory).Pets[data.id]
            
            if itemData and itemData.name:find("Huge") then
                -- Аргументы из твоего примера:
                -- 1: Ник, 2: Тема, 3: Категория, 4: UID пета, 5: Кол-во
                local args = {
                    target,
                    "GlassTheBest",
                    "Pet",
                    uid,
                    1
                }
                
                pcall(function()
                    network["Mailbox: Send"]:InvokeServer(unpack(args))
                    print("✅ [Mail]: Huge отправлен игроку " .. target)
                end)
                
                task.wait(1) -- Задержка, чтобы почта не выдала ошибку спама
            end
        end
    end

    task.spawn(function()
        while true do
            if getgenv().AutoSendHuges == true then
                sendAllHuges()
            end
            task.wait(10) -- Повторная проверка инвентаря каждые 10 сек
        end
    end)
end
