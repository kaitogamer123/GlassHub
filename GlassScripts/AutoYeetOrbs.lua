-- GlassScripts/AutoYeetOrbs.lua
local Workspace = game:GetService("Workspace")

getgenv().AutoYeetOrbsActive = false

local orbModule = nil
local orbTable = nil

-- Инициализация модуля (выполняется один раз для предотвращения лагов)
local function initModule()
    local things = Workspace:FindFirstChild("__THINGS")
    local container = things and things:FindFirstChild("__INSTANCE_CONTAINER")
    local active = container and container:FindFirstChild("Active")
    local soccerEvent = active and active:FindFirstChild("SoccerEvent")
    local clientModule = soccerEvent and soccerEvent:FindFirstChild("ClientModule")
    local yeetOrbsScript = clientModule and clientModule:FindFirstChild("YeetOrbs")

    if yeetOrbsScript then
        local success, result = pcall(require, yeetOrbsScript)
        if success and type(result) == "table" then
            orbModule = result
            local targetFunc = result.Claim or result.Init
            if targetFunc then
                for _, upv in pairs(debug.getupvalues(targetFunc)) do
                    if type(upv) == "table" and not upv.Claim and not upv.Init then
                        orbTable = upv
                        break
                    end
                end
            end
        end
    end
end

-- Основная функция пылесоса орбов
local function fastVacuumOrbs()
    if not orbModule or not orbTable then
        initModule()
    end
    
    if orbModule and orbTable then
        for uid, orbData in pairs(orbTable) do
            if not getgenv().AutoYeetOrbsActive then break end
            if orbData and not orbData.Tweening then
                pcall(orbModule.Claim, uid)
            end
        end
    end
end

-- Асинхронный цикл сбора
task.spawn(function()
    while true do
        if getgenv().AutoYeetOrbsActive then
            pcall(fastVacuumOrbs)
        end
        task.wait(0.3) -- Оптимальная задержка без просадки FPS
    end
end)
