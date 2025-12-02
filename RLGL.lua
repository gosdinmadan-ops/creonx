
-- RLGL.lua - Функции для Red Light Green Light
local RLGLModule = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Локальный игрок
local LocalPlayer = Players.LocalPlayer

-- Переменные
RLGLModule.RLGL = {
    GodMode = false,
    OriginalHeight = nil,
    GodModeTimeout = nil,
    LastDamageCheck = 0,
    DamageCheckRate = 0.5
}

-- RLGL функции
function RLGLModule.TeleportToEnd()
    local player = LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-214.4, 1023.1, 146.7)
    end
end

function RLGLModule.TeleportToStart()
    local player = LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-55.3, 1023.1, -545.8)
    end
end

function RLGLModule.ToggleGodMode(enabled)
    RLGLModule.RLGL.GodMode = enabled
    
    if RLGLModule.GodModeConnection then
        RLGLModule.GodModeConnection:Disconnect()
        RLGLModule.GodModeConnection = nil
        if RLGLModule.RLGL.GodModeTimeout then
            RLGLModule.RLGL.GodModeTimeout:Disconnect()
            RLGLModule.RLGL.GodModeTimeout = nil
        end
    end
    
    if enabled then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            RLGLModule.RLGL.OriginalHeight = character.HumanoidRootPart.Position.Y
            local currentPos = character.HumanoidRootPart.Position
            character.HumanoidRootPart.CFrame = CFrame.new(currentPos.X, 1184.9, currentPos.Z)
        end
        
        -- Проверка урона
        RLGLModule.GodModeConnection = RunService.Heartbeat:Connect(function()
            if not RLGLModule.RLGL.GodMode then return end
            
            local currentTime = tick()
            if currentTime - RLGLModule.RLGL.LastDamageCheck < RLGLModule.RLGL.DamageCheckRate then return end
            RLGLModule.RLGL.LastDamageCheck = currentTime
            
            local character = LocalPlayer.Character
            if not character then return end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            
            -- Проверяем, получили ли мы урон
            if humanoid.Health < humanoid.MaxHealth then
                -- Телепортируем на безопасные координаты
                character.HumanoidRootPart.CFrame = CFrame.new(-856, 1184, -550)
                
                -- Восстанавливаем здоровье
                humanoid.Health = humanoid.MaxHealth
                
                -- Автоматически выключаем GodMode через 10 секунд
                if RLGLModule.RLGL.GodModeTimeout then
                    RLGLModule.RLGL.GodModeTimeout:Disconnect()
                end
                
                RLGLModule.RLGL.GodModeTimeout = RunService.Heartbeat:Connect(function()
                    task.wait(10)
                    RLGLModule.ToggleGodMode(false)
                    if RLGLModule.RLGL.GodModeTimeout then
                        RLGLModule.RLGL.GodModeTimeout:Disconnect()
                        RLGLModule.RLGL.GodModeTimeout = nil
                    end
                end)
            end
        end)
    else
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") and RLGLModule.RLGL.OriginalHeight then
            local currentPos = character.HumanoidRootPart.Position
            character.HumanoidRootPart.CFrame = CFrame.new(currentPos.X, RLGLModule.RLGL.OriginalHeight, currentPos.Z)
        end
    end
end

-- Очистка
function RLGLModule.Cleanup()
    print("RLGL module cleanup")
    
    if RLGLModule.GodModeConnection then
        RLGLModule.GodModeConnection:Disconnect()
        RLGLModule.GodModeConnection = nil
    end
    
    if RLGLModule.RLGL.GodModeTimeout then
        RLGLModule.RLGL.GodModeTimeout:Disconnect()
        RLGLModule.RLGL.GodModeTimeout = nil
    end
end

return RLGLModule
