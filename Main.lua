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
    Enabled = false,
    RageEnabled = false,
    AntiStunEnabled = false
}

MainModule.Rebel = {
    Enabled = false
}

MainModule.RLGL = {
    GodMode = false
}

MainModule.Guards = {
    SelectedGuard = "Circle",
    AutoFarm = false
}

-- Постоянное обновление скорости
local speedConnection = nil
local autoFarmConnection = nil

function MainModule.ToggleSpeedHack(enabled)
    MainModule.SpeedHack.Enabled = enabled
    local player = game:GetService("Players").LocalPlayer
    
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
    
    if enabled then
        local character = player.Character or player.CharacterAdded:Wait()
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                MainModule.SpeedHack.DefaultSpeed = humanoid.WalkSpeed
            end
        end
        
        speedConnection = game:GetService("RunService").Heartbeat:Connect(function()
            local character = player.Character
            if character and MainModule.SpeedHack.Enabled then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = MainModule.SpeedHack.CurrentSpeed
                end
            end
        end)
    else
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = MainModule.SpeedHack.DefaultSpeed
            end
        end
    end
end

function MainModule.SetSpeed(value)
    if value < MainModule.SpeedHack.MinSpeed then
        value = MainModule.SpeedHack.MinSpeed
    elseif value > MainModule.SpeedHack.MaxSpeed then
        value = MainModule.SpeedHack.MaxSpeed
    end
    
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
    end
end

-- Rage Mode QTE функции
function MainModule.ToggleRageQTE(enabled)
    MainModule.AutoQTE.RageEnabled = enabled
    
    if enabled then
        if not MainModule.RageConnection then
            local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
            local impactFrames = playerGui:WaitForChild("ImpactFrames")
            local virtualInput = game:GetService("VirtualInputManager")
            local replicatedStorage = game:GetService("ReplicatedStorage")
            
            MainModule.RageConnection = impactFrames.ChildAdded:Connect(function(child)
                if child.Name == "OuterRingTemplate" and not (MainModule.ProcessedRage or {})[child] then
                    (MainModule.ProcessedRage or {})[child] = true
                    
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
    else
        if MainModule.RageConnection then
            MainModule.RageConnection:Disconnect()
            MainModule.RageConnection = nil
        end
        MainModule.ProcessedRage = {}
    end
end

-- Anti Stun QTE функции
function MainModule.ToggleAntiStunQTE(enabled)
    MainModule.AutoQTE.AntiStunEnabled = enabled
    
    if enabled then
        if not MainModule.AntiStunConnection then
            local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
            local impactFrames = playerGui:WaitForChild("ImpactFrames")
            local replicatedStorage = game:GetService("ReplicatedStorage")
            
            MainModule.AntiStunConnection = impactFrames.ChildAdded:Connect(function(child)
                if child.Name == "OuterRingTemplate" and not (MainModule.ProcessedAntiStun or {})[child] then
                    (MainModule.ProcessedAntiStun or {})[child] = true
                    
                    task.defer(function()
                        task.wait(0.03)
                        
                        for _, innerChild in pairs(impactFrames:GetChildren()) do
                            if innerChild.Name == "InnerTemplate" and innerChild.Position == child.Position 
                               and not innerChild:GetAttribute("Failed") then
                               
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
    else
        if MainModule.AntiStunConnection then
            MainModule.AntiStunConnection:Disconnect()
            MainModule.AntiStunConnection = nil
        end
        MainModule.ProcessedAntiStun = {}
    end
end

-- Rebel функция
function MainModule.ToggleRebel(enabled)
    MainModule.Rebel.Enabled = enabled
    _G.InstantRebel = enabled
    
    if enabled then
        print("Instant Rebel включен")
    else
        print("Instant Rebel выключен")
    end
end

-- RLGL функции
function MainModule.TeleportToEnd()
    print("TP TO END (не реализовано)")
end

function MainModule.TeleportToStart()
    print("TP TO START (не реализовано)")
end

function MainModule.ToggleGodMode(enabled)
    MainModule.RLGL.GodMode = enabled
    if enabled then
        print("GodMode включен (не реализовано)")
    else
        print("GodMode выключен (не реализовано)")
    end
end

-- Guards функции
function MainModule.SetGuardType(guardType)
    MainModule.Guards.SelectedGuard = guardType
    print("Выбран гвард: " .. guardType)
end

function MainModule.SpawnAsGuard()
    local args = {
        {
            AttemptToSpawnAsGuard = MainModule.Guards.SelectedGuard
        }
    }
    
    pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PlayableGuardRemote"):FireServer(unpack(args))
        print("Попытка стать гвардом: " .. MainModule.Guards.SelectedGuard)
    end)
end

function MainModule.ToggleAutoFarm(enabled)
    MainModule.Guards.AutoFarm = enabled
    
    if autoFarmConnection then
        autoFarmConnection:Disconnect()
        autoFarmConnection = nil
    end
    
    if enabled then
        autoFarmConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if MainModule.Guards.AutoFarm then
                local args2 = {
                    "GameOver",
                    4450
                }
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("VideoGameRemote"):FireServer(unpack(args2))
                end)
            end
        end)
        print("AutoFarm включен")
    else
        print("AutoFarm выключен")
    end
end

-- Функция для получения координат
function MainModule.GetPlayerPosition()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local position = character.HumanoidRootPart.Position
        return string.format("X: %.1f, Y: %.1f, Z: %.1f", position.X, position.Y, position.Z)
    end
    return "Не доступно"
end

return MainModule
