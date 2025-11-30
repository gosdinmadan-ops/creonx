local MainModule = {}

-- Переменные
MainModule.SpeedHack = {
    Enabled = false,
    DefaultSpeed = 16,
    CurrentSpeed = 16,
    MaxSpeed = 150,
    MinSpeed = 16
}

MainModule.Noclip = {
    Enabled = false,
    Status = "Don't work, Disabled"
}

MainModule.AutoQTE = {
    Enabled = false
}

-- Постоянное обновление скорости
local speedConnection = nil

function MainModule.ToggleSpeedHack(enabled)
    MainModule.SpeedHack.Enabled = enabled
    local player = game:GetService("Players").LocalPlayer
    
    -- Убираем старое соединение
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
    
    if enabled then
        -- Сохраняем стандартную скорость
        local character = player.Character or player.CharacterAdded:Wait()
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                MainModule.SpeedHack.DefaultSpeed = humanoid.WalkSpeed
            end
        end
        
        -- Создаем постоянное обновление скорости
        speedConnection = game:GetService("RunService").Heartbeat:Connect(function()
            local character = player.Character
            if character and MainModule.SpeedHack.Enabled then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = MainModule.SpeedHack.CurrentSpeed
                end
            end
        end)
        
        print("SpeedHack включен: " .. MainModule.SpeedHack.CurrentSpeed)
    else
        -- Возвращаем стандартную скорость
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = MainModule.SpeedHack.DefaultSpeed
            end
        end
        print("SpeedHack выключен")
    end
end

-- Функция изменения скорости
function MainModule.SetSpeed(value)
    if value < MainModule.SpeedHack.MinSpeed then
        value = MainModule.SpeedHack.MinSpeed
    elseif value > MainModule.SpeedHack.MaxSpeed then
        value = MainModule.SpeedHack.MaxSpeed
    end
    
    MainModule.SpeedHack.CurrentSpeed = value
    
    -- Немедленно применяем скорость если включено
    if MainModule.SpeedHack.Enabled then
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = value
            end
        end
    end
    
    return value
end

-- Auto QTE функции
function MainModule.ToggleAutoQTE(enabled)
    MainModule.AutoQTE.Enabled = enabled
    
    if enabled then
        task.spawn(function()
            while MainModule.AutoQTE.Enabled do
                pcall(function()
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteForQTE")
                    if remote and remote:IsA("RemoteEvent") then
                        remote:FireServer()
                    end
                end)
                task.wait(0.2)
            end
        end)
        print("Auto QTE включен")
    else
        print("Auto QTE выключен")
    end
end

-- Заглушки для остальных функций
function MainModule.EnableRageQTE() 
    print("Rage QTE включен")
end

function MainModule.DisableRageQTE() 
    print("Rage QTE выключен")
end

function MainModule.EnableAntiStunQTE() 
    print("Anti Stun QTE включен")
end

function MainModule.DisableAntiStunQTE() 
    print("Anti Stun QTE выключен")
end

return MainModule
