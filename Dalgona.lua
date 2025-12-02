-- Dalgona.lua - Функции для Dalgona Game
local DalgonaModule = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Локальный игрок
local LocalPlayer = Players.LocalPlayer

-- Переменные
DalgonaModule.Dalgona = {
    CompleteEnabled = false,
    FreeLighterEnabled = false
}

-- Dalgona функции
function DalgonaModule.CompleteDalgona()
    task.spawn(function()
        local DalgonaClientModule = ReplicatedStorage:FindFirstChild("Modules") and
                                    ReplicatedStorage.Modules:FindFirstChild("Games") and
                                    ReplicatedStorage.Modules.Games:FindFirstChild("DalgonaClient")
        if not DalgonaClientModule then return end
        
        for _, func in pairs(getreg()) do
            if typeof(func) == "function" and islclosure(func) then
                local info = getinfo(func)
                if info.nups == 76 then
                    setupvalue(func, 33, 9999)
                    setupvalue(func, 34, 9999)
                end
            end
        end
    end)
end

function DalgonaModule.FreeLighter()
    LocalPlayer:SetAttribute("HasLighter", true)
end

-- Очистка
function DalgonaModule.Cleanup()
    print("Dalgona module cleanup")
    -- Ничего не нужно очищать
end

return DalgonaModule
