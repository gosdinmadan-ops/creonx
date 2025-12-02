-- TugOfWar.lua - Функции для Tug of War Game
local TugOfWarModule = {}

-- Services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Переменные
TugOfWarModule.TugOfWar = {
    AutoPull = false
}

-- Соединения
local autoPullConnection = nil

-- Tug Of War функции
function TugOfWarModule.ToggleAutoPull(enabled)
    TugOfWarModule.TugOfWar.AutoPull = enabled
    
    if autoPullConnection then
        autoPullConnection:Disconnect()
        autoPullConnection = nil
    end
    
    if enabled then
        autoPullConnection = RunService.Heartbeat:Connect(function()
            if TugOfWarModule.TugOfWar.AutoPull then
                pcall(function()
                    local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TemporaryReachedBindable")
                    local args = {
                        { IHateYou = true }
                    }
                    Remote:FireServer(unpack(args))
                end)
                task.wait(0.25)
            end
        end)
    end
end

-- Очистка
function TugOfWarModule.Cleanup()
    print("TugOfWar module cleanup")
    
    if autoPullConnection then
        autoPullConnection:Disconnect()
        autoPullConnection = nil
    end
end

return TugOfWarModule
