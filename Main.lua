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
    AntiStunEnabled = false
}

MainModule.Rebel = {
    Enabled = false
}

MainModule.RLGL = {
    GodMode = false,
    OriginalHeight = nil
}

MainModule.Guards = {
    SelectedGuard = "Circle",
    AutoFarm = false,
    RapidFire = false,
    InfiniteAmmo = false,
    HitboxExpander = false
}

MainModule.Dalgona = {
    CompleteEnabled = false,
    FreeLighterEnabled = false
}

MainModule.HNS = {
    ESPHiders = false,
    ESPSeekers = false,
    AutoPickup = false,
    SpikesKill = false,
    DeleteSpikes = false,
    KillHiders = false,
    AutoDodge = false
}

MainModule.TugOfWar = {
    AutoPull = false
}

MainModule.GlassBridge = {
    AntiBreak = false
}

MainModule.Misc = {
    InstaInteract = false,
    NoCooldownProximity = false
}

-- Постоянное обновление скорости
local speedConnection = nil
local autoFarmConnection = nil
local godModeConnection = nil
local instaInteractConnection = nil
local noCooldownConnection = nil
local antiStunConnection = nil
local rapidFireConnection = nil
local infiniteAmmoConnection = nil
local hitboxConnection = nil
local autoPullConnection = nil
local antiBreakConnection = nil

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

-- Функции телепортации
function MainModule.TeleportUp100()
    local player = game:GetService("Players").LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 100, 0)
    end
end

function MainModule.TeleportDown40()
    local player = game:GetService("Players").LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, -40, 0)
    end
end

-- Anti Stun QTE функция (исправленная без лагов)
function MainModule.ToggleAntiStunQTE(enabled)
    MainModule.AutoQTE.AntiStunEnabled = enabled
    
    if antiStunConnection then
        antiStunConnection:Disconnect()
        antiStunConnection = nil
    end
    
    if enabled then
        antiStunConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not MainModule.AutoQTE.AntiStunEnabled then return end
            
            pcall(function()
                local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
                local impactFrames = playerGui:FindFirstChild("ImpactFrames")
                if not impactFrames then return end
                
                local replicatedStorage = game:GetService("ReplicatedStorage")
                
                -- Безопасная проверка модуля
                local success, hbgModule = pcall(function()
                    return require(replicatedStorage.Modules.HBGQTE)
                end)
                
                if not success then return end
                
                -- Проверяем только активные QTE
                for _, child in pairs(impactFrames:GetChildren()) do
                    if child.Name == "OuterRingTemplate" and child:IsA("Frame") then
                        for _, innerChild in pairs(impactFrames:GetChildren()) do
                            if innerChild.Name == "InnerTemplate" and innerChild.Position == child.Position 
                               and not innerChild:GetAttribute("Failed") and not innerChild:GetAttribute("Tweening") then
                               
                                -- Безопасное нажатие QTE
                                pcall(function()
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
                    end
                end
            end)
        end)
    end
end

-- Rebel функция
function MainModule.ToggleRebel(enabled)
    MainModule.Rebel.Enabled = enabled
    _G.InstantRebel = enabled
end

-- RLGL функции
function MainModule.TeleportToEnd()
    local player = game:GetService("Players").LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-214.4, 1023.1, 146.7)
    end
end

function MainModule.TeleportToStart()
    local player = game:GetService("Players").LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-55.3, 1023.1, -545.8)
    end
end

function MainModule.ToggleGodMode(enabled)
    MainModule.RLGL.GodMode = enabled
    
    if godModeConnection then
        godModeConnection:Disconnect()
        godModeConnection = nil
    end
    
    if enabled then
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            MainModule.RLGL.OriginalHeight = character.HumanoidRootPart.Position.Y
            local currentPos = character.HumanoidRootPart.Position
            character.HumanoidRootPart.CFrame = CFrame.new(currentPos.X, 1184.9, currentPos.Z)
        end
    else
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") and MainModule.RLGL.OriginalHeight then
            local currentPos = character.HumanoidRootPart.Position
            character.HumanoidRootPart.CFrame = CFrame.new(currentPos.X, MainModule.RLGL.OriginalHeight, currentPos.Z)
        end
    end
end

-- Guards функции
function MainModule.SetGuardType(guardType)
    MainModule.Guards.SelectedGuard = guardType
end

function MainModule.SpawnAsGuard()
    local args = {
        {
            AttemptToSpawnAsGuard = MainModule.Guards.SelectedGuard
        }
    }
    
    pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PlayableGuardRemote"):FireServer(unpack(args))
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
    end
end

-- Rapid Fire функция
function MainModule.ToggleRapidFire(enabled)
    MainModule.Guards.RapidFire = enabled
    
    if rapidFireConnection then
        rapidFireConnection:Disconnect()
        rapidFireConnection = nil
    end
    
    if enabled then
        -- Применяем один раз при включении
        pcall(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local weaponsFolder = ReplicatedStorage:FindFirstChild("Weapons")
            if not weaponsFolder then return end
            local gunsFolder = weaponsFolder:FindFirstChild("Guns")
            if not gunsFolder then return end
            
            local function findFireRateCDObjects(parent)
                local results = {}
                for _, obj in ipairs(parent:GetDescendants()) do
                    if obj.Name == "FireRateCD" then
                        table.insert(results, obj)
                    end
                end
                return results
            end
            
            local fireRateCDs = findFireRateCDObjects(gunsFolder)
            for _, valObject in ipairs(fireRateCDs) do
                if valObject:IsA("NumberValue") or valObject:IsA("IntValue") or valObject:IsA("BoolValue") then
                    valObject.Value = 0
                end
            end
        end)
        
        -- Постоянное обновление
        rapidFireConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if MainModule.Guards.RapidFire then
                pcall(function()
                    local ReplicatedStorage = game:GetService("ReplicatedStorage")
                    local weaponsFolder = ReplicatedStorage:FindFirstChild("Weapons")
                    if not weaponsFolder then return end
                    local gunsFolder = weaponsFolder:FindFirstChild("Guns")
                    if not gunsFolder then return end
                    
                    for _, obj in ipairs(gunsFolder:GetDescendants()) do
                        if obj.Name == "FireRateCD" and (obj:IsA("NumberValue") or obj:IsA("IntValue") or obj:IsA("BoolValue")) then
                            obj.Value = 0
                        end
                    end
                end)
            end
        end)
    end
end

-- Infinite Ammo функция
function MainModule.ToggleInfiniteAmmo(enabled)
    MainModule.Guards.InfiniteAmmo = enabled
    
    if infiniteAmmoConnection then
        infiniteAmmoConnection:Disconnect()
        infiniteAmmoConnection = nil
    end
    
    if enabled then
        infiniteAmmoConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not MainModule.Guards.InfiniteAmmo then return end
            
            local player = game:GetService("Players").LocalPlayer
            local character = player.Character
            if character then
                for _, tool in pairs(character:GetChildren()) do
                    if tool:IsA("Tool") then
                        for _, obj in pairs(tool:GetDescendants()) do
                            if obj:IsA("NumberValue") then
                                if obj.Name:lower():find("ammo") or 
                                   obj.Name:lower():find("bullet") or
                                   obj.Name:lower():find("clip") then
                                    obj.Value = 9999
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end

-- Hitbox Expander функция
function MainModule.ToggleHitboxExpander(enabled)
    MainModule.Guards.HitboxExpander = enabled
    
    if hitboxConnection then
        hitboxConnection:Disconnect()
        hitboxConnection = nil
    end
    
    if enabled then
        _G.HeadSize = 30
        
        local function UpdateHeadHitboxes()
            local Players = game:GetService("Players")
            local player = Players.LocalPlayer
            
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= player and v.Character and v.Character:FindFirstChild("Head") then
                    pcall(function()
                        v.Character.Head.Size = Vector3.new(_G.HeadSize, _G.HeadSize, _G.HeadSize)
                        v.Character.Head.Transparency = 0.5
                        v.Character.Head.BrickColor = BrickColor.new("Red")
                        v.Character.Head.Material = "Neon"
                        v.Character.Head.CanCollide = false
                    end)
                end
            end
        end
        
        hitboxConnection = game:GetService("RunService").RenderStepped:Connect(UpdateHeadHitboxes)
    else
        -- Восстанавливаем оригинальные размеры
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("Head") then
                pcall(function()
                    v.Character.Head.Size = Vector3.new(2, 1, 1)
                    v.Character.Head.Transparency = 0
                    v.Character.Head.Material = "Plastic"
                    v.Character.Head.BrickColor = BrickColor.new("Medium stone grey")
                end)
            end
        end
    end
end

-- Dalgona функции
function MainModule.CompleteDalgona()
    task.spawn(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        if not ReplicatedStorage then
            return
        end
        local DalgonaClientModule = ReplicatedStorage:FindFirstChild("Modules") and
                                    ReplicatedStorage.Modules:FindFirstChild("Games") and
                                    ReplicatedStorage.Modules.Games:FindFirstChild("DalgonaClient")
        if not DalgonaClientModule then
            return
        end
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

function MainModule.FreeLighter()
    local player = game:GetService("Players").LocalPlayer
    player:SetAttribute("HasLighter", true)
end

-- HNS функции
function MainModule.ToggleESPHiders(enabled)
    MainModule.HNS.ESPHiders = enabled
end

function MainModule.ToggleESPSeekers(enabled)
    MainModule.HNS.ESPSeekers = enabled
end

function MainModule.ToggleAutoPickup(enabled)
    MainModule.HNS.AutoPickup = enabled
end

function MainModule.ToggleSpikesKill(enabled)
    MainModule.HNS.SpikesKill = enabled
end

function MainModule.ToggleDeleteSpikes(enabled)
    MainModule.HNS.DeleteSpikes = enabled
end

function MainModule.ToggleKillHiders(enabled)
    MainModule.HNS.KillHiders = enabled
end

function MainModule.ToggleAutoDodge(enabled)
    MainModule.HNS.AutoDodge = enabled
end

-- Tug Of War функции
function MainModule.ToggleAutoPull(enabled)
    MainModule.TugOfWar.AutoPull = enabled
    
    if autoPullConnection then
        autoPullConnection:Disconnect()
        autoPullConnection = nil
    end
    
    if enabled then
        autoPullConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if MainModule.TugOfWar.AutoPull then
                pcall(function()
                    local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

-- Glass Bridge функции
function MainModule.ToggleAntiBreak(enabled)
    MainModule.GlassBridge.AntiBreak = enabled
    
    if antiBreakConnection then
        antiBreakConnection:Disconnect()
        antiBreakConnection = nil
    end
    
    if enabled then
        antiBreakConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not MainModule.GlassBridge.AntiBreak then return end
            
            pcall(function()
                local GlassHolder = workspace:FindFirstChild("GlassBridge") and workspace.GlassBridge:FindFirstChild("GlassHolder")
                if not GlassHolder then return end
                for _, v in pairs(GlassHolder:GetChildren()) do
                    for _, j in pairs(v:GetChildren()) do
                        if j:IsA("Model") and j.PrimaryPart then
                            if j.PrimaryPart:GetAttribute("exploitingisevil") ~= nil then
                                j.PrimaryPart:SetAttribute("exploitingisevil", nil)
                            end
                        end
                    end
                end
            end)
        end)
    end
end

-- Misc функции (исправленные без лагов)
function MainModule.ToggleInstaInteract(enabled)
    MainModule.Misc.InstaInteract = enabled
    
    if instaInteractConnection then
        instaInteractConnection:Disconnect()
        instaInteractConnection = nil
    end
    
    if enabled then
        local function makePromptInstant(prompt)
            if prompt:IsA("ProximityPrompt") then
                prompt.HoldDuration = 0
            end
        end

        -- Применяем к существующим промптам
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                makePromptInstant(obj)
            end
        end

        -- Слушаем только новые промпты
        instaInteractConnection = workspace.DescendantAdded:Connect(function(obj)
            if obj:IsA("ProximityPrompt") then
                makePromptInstant(obj)
            end
        end)
    else
        -- При выключении не делаем ничего, пусть игра сама управляет промптами
    end
end

function MainModule.ToggleNoCooldownProximity(enabled)
    MainModule.Misc.NoCooldownProximity = enabled
    
    if noCooldownConnection then
        noCooldownConnection:Disconnect()
        noCooldownConnection = nil
    end
    
    if enabled then
        for _, v in pairs(workspace:GetDescendants()) do
            if v.ClassName == "ProximityPrompt" then
                v.HoldDuration = 0
            end
        end
        
        noCooldownConnection = workspace.DescendantAdded:Connect(function(obj)
            if MainModule.Misc.NoCooldownProximity then
                if obj:IsA("ProximityPrompt") then
                    obj.HoldDuration = 0
                end
            end
        end)
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
