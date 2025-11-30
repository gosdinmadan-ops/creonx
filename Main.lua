local MainModule = {}

-- Переменные
MainModule.SpeedHack = {
    Enabled = false,
    DefaultSpeed = 16,
    CurrentSpeed = 16,
    MaxSpeed = 150
}

MainModule.Noclip = {
    Enabled = false,
    Status = "Don't work, Disabled"
}

MainModule.AutoQTE = {
    Enabled = false,
    QTEHandler = nil
}

-- Функция SpeedHack
function MainModule.ToggleSpeedHack(enabled)
    MainModule.SpeedHack.Enabled = enabled
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if enabled then
                MainModule.SpeedHack.DefaultSpeed = humanoid.WalkSpeed
                humanoid.WalkSpeed = MainModule.SpeedHack.CurrentSpeed
            else
                humanoid.WalkSpeed = MainModule.SpeedHack.DefaultSpeed
            end
        end
    end
end

-- Функция изменения скорости
function MainModule.SetSpeed(value)
    MainModule.SpeedHack.CurrentSpeed = value
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
end

-- Auto QTE функции
function MainModule.ToggleAutoQTE(enabled)
    MainModule.AutoQTE.Enabled = enabled
    
    if enabled then
        -- Запускаем Auto QTE
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
        
        -- Запускаем Rage Mode QTE
        MainModule.EnableRageQTE()
        
        -- Запускаем Anti Stun QTE
        MainModule.EnableAntiStunQTE()
        
    else
        -- Отключаем все QTE функции
        MainModule.DisableRageQTE()
        MainModule.DisableAntiStunQTE()
    end
end

-- Rage Mode QTE функции
function MainModule.EnableRageQTE()
    if not MainModule.RageConnection then
        local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
        local impactFrames = playerGui:WaitForChild("ImpactFrames")
        local replicatedStorage = game:GetService("ReplicatedStorage")
        local virtualInput = game:GetService("VirtualInputManager")
        
        MainModule.RageConnection = impactFrames.ChildAdded:Connect(function(child)
            if child.Name == "OuterRingTemplate" and not MainModule.ProcessedRage[child] then
                MainModule.ProcessedRage[child] = true
                
                task.defer(function()
                    task.wait(0.03)
                    
                    for _, innerChild in pairs(impactFrames:GetChildren()) do
                        if innerChild.Name == "InnerTemplate" and innerChild.Position == child.Position 
                           and not innerChild:GetAttribute("Failed") then
                           
                            local qteMain = innerChild:FindFirstChild("QTEMain")
                            if qteMain and qteMain:FindFirstChild("Button") then
                                local buttonInfo = qteMain.Button.Inner.Info
                                if buttonInfo and buttonInfo.Text then
                                    local key = buttonInfo.Text
                                    
                                    task.wait(0.02)
                                    virtualInput:SendKeyEvent(true, Enum.KeyCode[key], false, game)
                                    task.wait(0.03)
                                    virtualInput:SendKeyEvent(false, Enum.KeyCode[key], false, game)
                                end
                            end
                            break
                        end
                    end
                end)
            end
        end)
        
        MainModule.ProcessedRage = {}
    end
end

function MainModule.DisableRageQTE()
    if MainModule.RageConnection then
        MainModule.RageConnection:Disconnect()
        MainModule.RageConnection = nil
    end
    MainModule.ProcessedRage = {}
end

-- Anti Stun QTE функции
function MainModule.EnableAntiStunQTE()
    if not MainModule.AntiStunConnection then
        local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
        local impactFrames = playerGui:WaitForChild("ImpactFrames")
        local replicatedStorage = game:GetService("ReplicatedStorage")
        
        MainModule.AntiStunConnection = impactFrames.ChildAdded:Connect(function(child)
            if child.Name == "OuterRingTemplate" and not MainModule.ProcessedAntiStun[child] then
                MainModule.ProcessedAntiStun[child] = true
                
                task.defer(function()
                    task.wait(0.03)
                    
                    for _, innerChild in pairs(impactFrames:GetChildren()) do
                        if innerChild.Name == "InnerTemplate" and innerChild.Position == child.Position 
                           and not innerChild:GetAttribute("Failed") then
                           
                            -- Автоматически нажимаем QTE
                            pcall(function()
                                local hbgModule = require(replicatedStorage.Modules.HBGQTE)
                                local qteData = {
                                    Inner = innerChild,
                                    Outer = child,
                                    Duration = 2,
                                    StartedAt = tick()
                                }
                                hbgModule.Pressed(false, qteData)
                            end)
                            break
                        end
                    end
                end)
            end
        end)
        
        MainModule.ProcessedAntiStun = {}
    end
end

function MainModule.DisableAntiStunQTE()
    if MainModule.AntiStunConnection then
        MainModule.AntiStunConnection:Disconnect()
        MainModule.AntiStunConnection = nil
    end
    MainModule.ProcessedAntiStun = {}
end

return MainModule