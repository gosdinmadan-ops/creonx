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
    HitboxExpander = false,
    OriginalFireRates = {},
    OriginalAmmo = {}
}

MainModule.Dalgona = {
    CompleteEnabled = false,
    FreeLighterEnabled = false
}

MainModule.HNS = {
    AutoPickup = false,
    SpikesKill = false,
    DeleteSpikes = false,
    KillHiders = false,
    AutoDodge = false,
    DisableSpikes = false
}

MainModule.TugOfWar = {
    AutoPull = false
}

MainModule.GlassBridge = {
    AntiBreak = false,
    GlassESPEnabled = false
}

MainModule.JumpRope = {
    AutoJump = false,
    AntiFail = false,
    TeleportToStart = false,
    TeleportToEnd = false
}

MainModule.Misc = {
    InstaInteract = false,
    NoCooldownProximity = false,
    ESPEnabled = false,
    ESPHighlight = true,
    ESPDistance = true,
    ESPFillTransparency = 0.7,
    ESPOutlineTransparency = 0,
    ESPTextSize = 18,
    ESPPlayers = true,
    ESPNPCs = true,
    ESPItems = true,
    AntiStunRagdoll = false
}

-- ESP System (оптимизированная без лагов)
MainModule.ESPTable = {}
MainModule.ESPConnections = {}

-- HNS шипы
MainModule.HNSSpikes = {
    Positions = {},
    OriginalPositions = {}
}

-- Постоянные соединения
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
local espConnection = nil
local hnsAutoPickupConnection = nil
local hnsSpikesKillConnection = nil
local hnsKillHidersConnection = nil
local hnsDisableSpikesConnection = nil
local jumpRopeConnection = nil
local jumpRopeAntiFailConnection = nil
local glassBridgeESPConnection = nil
local antiStunRagdollConnection = nil

-- Функции скорости
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

-- Anti Stun QTE функция
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
                
                local success, hbgModule = pcall(function()
                    return require(replicatedStorage.Modules.HBGQTE)
                end)
                
                if not success then return end
                
                for _, child in pairs(impactFrames:GetChildren()) do
                    if child.Name == "OuterRingTemplate" and child:IsA("Frame") then
                        for _, innerChild in pairs(impactFrames:GetChildren()) do
                            if innerChild.Name == "InnerTemplate" and innerChild.Position == child.Position 
                               and not innerChild:GetAttribute("Failed") and not innerChild:GetAttribute("Tweening") then
                               
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

-- Anti Stun + Anti Ragdoll функция (оптимизированная)
function MainModule.ToggleAntiStunRagdoll(enabled)
    MainModule.Misc.AntiStunRagdoll = enabled
    
    if antiStunRagdollConnection then
        antiStunRagdollConnection:Disconnect()
        antiStunRagdollConnection = nil
    end
    
    if enabled then
        antiStunRagdollConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not MainModule.Misc.AntiStunRagdoll then return end
            
            pcall(function()
                local player = game:GetService("Players").LocalPlayer
                local character = player.Character
                if not character then return end
                
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if not humanoid then return end
                
                -- Быстрое восстановление из рагдолла/стана
                if humanoid:GetState() == Enum.HumanoidStateType.FallingDown or 
                   humanoid:GetState() == Enum.HumanoidStateType.Ragdoll then
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                end
                
                -- Включаем моторы если отключены
                for _, v in pairs(character:GetDescendants()) do
                    if v:IsA("Motor6D") and not v.Enabled then 
                        v.Enabled = true 
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
        -- Сохраняем исходные значения
        pcall(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local weaponsFolder = ReplicatedStorage:FindFirstChild("Weapons")
            if weaponsFolder then
                local gunsFolder = weaponsFolder:FindFirstChild("Guns")
                if gunsFolder then
                    for _, obj in ipairs(gunsFolder:GetDescendants()) do
                        if obj.Name == "FireRateCD" and (obj:IsA("NumberValue") or obj:IsA("IntValue")) then
                            MainModule.Guards.OriginalFireRates[obj] = obj.Value
                        end
                    end
                end
            end
        end)
        
        rapidFireConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not MainModule.Guards.RapidFire then return end
            
            pcall(function()
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local weaponsFolder = ReplicatedStorage:FindFirstChild("Weapons")
                if not weaponsFolder then return end
                local gunsFolder = weaponsFolder:FindFirstChild("Guns")
                if not gunsFolder then return end
                
                for _, obj in ipairs(gunsFolder:GetDescendants()) do
                    if obj.Name == "FireRateCD" and (obj:IsA("NumberValue") or obj:IsA("IntValue")) then
                        obj.Value = 0
                    end
                end
                
                local player = game:GetService("Players").LocalPlayer
                local character = player.Character
                if character then
                    for _, tool in pairs(character:GetChildren()) do
                        if tool:IsA("Tool") then
                            for _, obj in pairs(tool:GetDescendants()) do
                                if obj.Name == "FireRateCD" and (obj:IsA("NumberValue") or obj:IsA("IntValue")) then
                                    obj.Value = 0
                                end
                            end
                        end
                    end
                end
            end)
        end)
    else
        -- Восстанавливаем исходные значения
        pcall(function()
            for obj, originalValue in pairs(MainModule.Guards.OriginalFireRates) do
                if obj and obj.Parent then
                    obj.Value = originalValue
                end
            end
            MainModule.Guards.OriginalFireRates = {}
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
        -- Сохраняем исходные значения патронов
        pcall(function()
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
                                    MainModule.Guards.OriginalAmmo[obj] = obj.Value
                                end
                            end
                        end
                    end
                end
            end
        end)
        
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
                                    obj.Value = math.huge
                                end
                            end
                        end
                    end
                end
            end
        end)
    else
        -- Восстанавливаем исходные значения патронов
        pcall(function()
            for obj, originalValue in pairs(MainModule.Guards.OriginalAmmo) do
                if obj and obj.Parent then
                    obj.Value = originalValue
                end
            end
            MainModule.Guards.OriginalAmmo = {}
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
                        -- Увеличиваем хитбокс но делаем его полностью прозрачным
                        v.Character.Head.Size = Vector3.new(_G.HeadSize, _G.HeadSize, _G.HeadSize)
                        v.Character.Head.Transparency = 1
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

-- HNS функции (исправленные)
function MainModule.ToggleAutoPickup(enabled)
    MainModule.HNS.AutoPickup = enabled
    
    if hnsAutoPickupConnection then
        hnsAutoPickupConnection:Disconnect()
        hnsAutoPickupConnection = nil
    end
    
    if enabled then
        local originalPosition = nil
        local hasKey = false
        
        hnsAutoPickupConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not MainModule.HNS.AutoPickup then return end
            
            pcall(function()
                local player = game:GetService("Players").LocalPlayer
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                -- Проверяем, синий ли мы (хайдер)
                local isHider = player:GetAttribute("IsHider")
                if not isHider then return end -- Только для хайдеров
                
                -- Проверяем, есть ли у нас уже ключ
                local foundKey = false
                for _, item in pairs(character:GetChildren()) do
                    if item:IsA("Tool") and item.Name:lower():find("key") then
                        foundKey = true
                        break
                    end
                end
                
                hasKey = foundKey
                
                -- Если ключа нет, ищем его
                if not hasKey then
                    -- Сохраняем оригинальную позицию при первом запуске
                    if not originalPosition then
                        originalPosition = character.HumanoidRootPart.Position
                    end
                    
                    local closestKey = nil
                    local closestDistance = math.huge
                    
                    -- Ищем ключи в workspace
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("Model") and obj.Name:lower():find("key") and obj.PrimaryPart then
                            local distance = (character.HumanoidRootPart.Position - obj.PrimaryPart.Position).Magnitude
                            if distance < closestDistance then
                                closestDistance = distance
                                closestKey = obj
                            end
                        end
                    end
                    
                    -- Телепортируемся к ключу если он близко
                    if closestKey and closestDistance < 50 then
                        -- Телепортируемся к ключу
                        character.HumanoidRootPart.CFrame = closestKey.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
                        
                        -- Ждем для поднятия ключа
                        task.wait(0.3)
                        
                        -- Возвращаемся на оригинальную позицию
                        if originalPosition then
                            character.HumanoidRootPart.CFrame = CFrame.new(originalPosition)
                        end
                    end
                else
                    -- Если ключ есть, сбрасываем оригинальную позицию
                    originalPosition = nil
                end
            end)
        end)
    else
        hasKey = false
        originalPosition = nil
    end
end

function MainModule.ToggleSpikesKill(enabled)
    MainModule.HNS.SpikesKill = enabled
    
    if hnsSpikesKillConnection then
        hnsSpikesKillConnection:Disconnect()
        hnsSpikesKillConnection = nil
    end
    
    if enabled then
        -- Сохраняем позиции шипов
        MainModule.HNSSpikes.Positions = {}
        MainModule.HNSSpikes.OriginalPositions = {}
        
        pcall(function()
            local spikes = workspace:FindFirstChild("HideAndSeekMap") and 
                          workspace.HideAndSeekMap:FindFirstChild("KillingParts")
            
            if spikes then
                for _, spike in pairs(spikes:GetChildren()) do
                    if spike:IsA("BasePart") then
                        table.insert(MainModule.HNSSpikes.Positions, spike.Position)
                        MainModule.HNSSpikes.OriginalPositions[spike] = spike.Position
                    end
                end
            end
        end)
        
        hnsSpikesKillConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not MainModule.HNS.SpikesKill then return end
            
            pcall(function()
                local player = game:GetService("Players").LocalPlayer
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                -- Если мы сикер, телепортируем ближайшего хайдера в шипы
                local isHunter = player:GetAttribute("IsHunter")
                if isHunter and #MainModule.HNSSpikes.Positions > 0 then
                    -- Ищем ближайшего живого хайдера
                    local targetPlayer = nil
                    local closestDistance = math.huge
                    
                    for _, target in pairs(game:GetService("Players"):GetPlayers()) do
                        if target ~= player and target:GetAttribute("IsHider") and 
                           target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                           
                            local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
                            if humanoid and humanoid.Health > 0 then
                                local distance = (character.HumanoidRootPart.Position - target.Character.HumanoidRootPart.Position).Magnitude
                                if distance < closestDistance then
                                    closestDistance = distance
                                    targetPlayer = target
                                end
                            end
                        end
                    end
                    
                    -- Телепортируем хайдера в шипы
                    if targetPlayer and targetPlayer.Character and closestDistance < 20 then
                        local randomSpike = MainModule.HNSSpikes.Positions[math.random(1, #MainModule.HNSSpikes.Positions)]
                        targetPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(randomSpike)
                    end
                end
                
                -- Делаем шипы безопасными для нас
                local spikes = workspace:FindFirstChild("HideAndSeekMap") and 
                              workspace.HideAndSeekMap:FindFirstChild("KillingParts")
                
                if spikes then
                    for _, spike in pairs(spikes:GetChildren()) do
                        if spike:IsA("BasePart") then
                            spike.CanTouch = false
                            spike.CanCollide = false
                        end
                    end
                end
            end)
        end)
    else
        -- Восстанавливаем шипы
        pcall(function()
            local spikes = workspace:FindFirstChild("HideAndSeekMap") and 
                          workspace.HideAndSeekMap:FindFirstChild("KillingParts")
            
            if spikes then
                for spike, originalPos in pairs(MainModule.HNSSpikes.OriginalPositions) do
                    if spike and spike.Parent then
                        spike.CanTouch = true
                        spike.CanCollide = true
                    end
                end
            end
            MainModule.HNSSpikes.Positions = {}
            MainModule.HNSSpikes.OriginalPositions = {}
        end)
    end
end

function MainModule.ToggleDisableSpikes(enabled)
    MainModule.HNS.DisableSpikes = enabled
    
    if hnsDisableSpikesConnection then
        hnsDisableSpikesConnection:Disconnect()
        hnsDisableSpikesConnection = nil
    end
    
    if enabled then
        hnsDisableSpikesConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not MainModule.HNS.DisableSpikes then return end
            
            pcall(function()
                local spikes = workspace:FindFirstChild("HideAndSeekMap") and 
                              workspace.HideAndSeekMap:FindFirstChild("KillingParts")
                
                if spikes then
                    for _, spike in pairs(spikes:GetChildren()) do
                        if spike:IsA("BasePart") then
                            spike.CanTouch = false
                            spike.CanCollide = false
                            spike.Transparency = 0.8
                        end
                    end
                end
            end)
        end)
    else
        pcall(function()
            local spikes = workspace:FindFirstChild("HideAndSeekMap") and 
                          workspace.HideAndSeekMap:FindFirstChild("KillingParts")
            
            if spikes then
                for _, spike in pairs(spikes:GetChildren()) do
                    if spike:IsA("BasePart") then
                        spike.CanTouch = true
                        spike.CanCollide = true
                        spike.Transparency = 0
                    end
                end
            end
        end)
    end
end

function MainModule.ToggleDeleteSpikes(enabled)
    MainModule.HNS.DeleteSpikes = enabled
    
    if enabled then
        pcall(function()
            if workspace:FindFirstChild("HideAndSeekMap") and workspace.HideAndSeekMap:FindFirstChild("KillingParts") then
                workspace.HideAndSeekMap.KillingParts:ClearAllChildren()
            end
        end)
    end
end

function MainModule.ToggleKillHiders(enabled)
    MainModule.HNS.KillHiders = enabled
    
    if hnsKillHidersConnection then
        hnsKillHidersConnection:Disconnect()
        hnsKillHidersConnection = nil
    end
    
    if enabled then
        local targetPlayer = nil
        
        hnsKillHidersConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not MainModule.HNS.KillHiders then 
                targetPlayer = nil
                return 
            end
            
            pcall(function()
                local player = game:GetService("Players").LocalPlayer
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then 
                    targetPlayer = nil
                    return 
                end
                
                -- Проверяем сикер ли мы
                local isHunter = player:GetAttribute("IsHunter")
                if not isHunter then 
                    targetPlayer = nil
                    return 
                end
                
                -- Если есть текущая цель, следим за ней
                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
                    local targetHumanoid = targetPlayer.Character:FindFirstChild("Humanoid")
                    if targetHumanoid.Health > 0 then
                        -- Телепортируемся к цели
                        character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2)
                        return
                    else
                        -- Цель умерла, ищем новую
                        targetPlayer = nil
                    end
                end
                
                -- Ищем новую цель (ближайшего живого хайдера)
                local closestDistance = math.huge
                local newTarget = nil
                
                for _, target in pairs(game:GetService("Players"):GetPlayers()) do
                    if target ~= player and target:GetAttribute("IsHider") and 
                       target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                       
                        local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            local distance = (character.HumanoidRootPart.Position - target.Character.HumanoidRootPart.Position).Magnitude
                            if distance < closestDistance then
                                closestDistance = distance
                                newTarget = target
                            end
                        end
                    end
                end
                
                -- Устанавливаем новую цель
                if newTarget then
                    targetPlayer = newTarget
                end
            end)
        end)
    else
        targetPlayer = nil
    end
end

function MainModule.ToggleAutoDodge(enabled)
    MainModule.HNS.AutoDodge = enabled
    -- Временно не реализовано
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

function MainModule.ToggleGlassBridgeESP(enabled)
    MainModule.GlassBridge.GlassESPEnabled = enabled
    
    if glassBridgeESPConnection then
        glassBridgeESPConnection:Disconnect()
        glassBridgeESPConnection = nil
    end
    
    if enabled then
        glassBridgeESPConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not MainModule.GlassBridge.GlassESPEnabled then return end
            
            pcall(function()
                local glassHolder = workspace:FindFirstChild("GlassBridge") and workspace.GlassBridge:FindFirstChild("GlassHolder")
                if not glassHolder then return end

                for _, tilePair in pairs(glassHolder:GetChildren()) do
                    for _, tileModel in pairs(tilePair:GetChildren()) do
                        if tileModel:IsA("Model") and tileModel.PrimaryPart then
                            local primaryPart = tileModel.PrimaryPart
                            for _, child in ipairs(tileModel:GetChildren()) do
                                if child:IsA("Highlight") then
                                    child:Destroy()
                                end
                            end
                            
                            local isBreakable = primaryPart:GetAttribute("exploitingisevil") == true
                            local targetColor = isBreakable and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                            local transparency = 0.5

                            for _, part in pairs(tileModel:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    game:GetService("TweenService"):Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
                                        Transparency = transparency,
                                        Color = targetColor
                                    }):Play()
                                end
                            end

                            local highlight = Instance.new("Highlight")
                            highlight.FillColor = targetColor
                            highlight.FillTransparency = 0.7
                            highlight.OutlineTransparency = 0.5
                            highlight.Parent = tileModel
                        end
                    end
                end
            end)
        end)
    end
end

-- Jump Rope функции
function MainModule.TeleportToJumpRopeStart()
    local player = game:GetService("Players").LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(700.123, 198.456, 920.789)
    end
end

function MainModule.TeleportToJumpRopeEnd()
    local player = game:GetService("Players").LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(750.654, 198.512, 921.234)
    end
end

function MainModule.ToggleAutoJump(enabled)
    MainModule.JumpRope.AutoJump = enabled
    
    if jumpRopeConnection then
        jumpRopeConnection:Disconnect()
        jumpRopeConnection = nil
    end
    
    if enabled then
        jumpRopeConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not MainModule.JumpRope.AutoJump then return end
            
            local player = game:GetService("Players").LocalPlayer
            local character = player.Character
            if not character then return end
            
            local humanoid = character:FindFirstChild("Humanoid")
            if not humanoid then return end
            
            -- Автоматическое прыганье
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            
            -- Ждем перед следующим прыжком
            task.wait(0.5)
        end)
    end
end

function MainModule.ToggleAntiFailJumpRope(enabled)
    MainModule.JumpRope.AntiFail = enabled
    
    if jumpRopeAntiFailConnection then
        jumpRopeAntiFailConnection:Disconnect()
        jumpRopeAntiFailConnection = nil
    end
    
    if enabled then
        jumpRopeAntiFailConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not MainModule.JumpRope.AntiFail then return end
            
            pcall(function()
                -- Защита от провала
                if workspace:FindFirstChild("Values") then
                    local currentGame = workspace.Values:FindFirstChild("CurrentGame")
                    if currentGame and currentGame.Value == "JumpRope" then
                        -- Предотвращаем обнаружение провала
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj.Name == "FailDetection" or obj.Name:lower():find("fail") then
                                obj:Destroy()
                            end
                        end
                    end
                end
            end)
        end)
    end
end

-- ESP System (оптимизированная без лагов)
function MainModule.ToggleESP(enabled)
    MainModule.Misc.ESPEnabled = enabled
    
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end
    
    -- Очищаем старые ESP
    for _, esp in pairs(MainModule.ESPTable) do
        if esp and esp.Destroy then
            esp:Destroy()
        end
    end
    MainModule.ESPTable = {}
    
    if enabled then
        -- Оптимизированная ESP с минимальной нагрузкой
        espConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not MainModule.Misc.ESPEnabled then return end
            
            pcall(function()
                local player = game:GetService("Players").LocalPlayer
                
                -- ESP для игроков (оптимизированная)
                if MainModule.Misc.ESPPlayers and tick() % 0.3 < 0.05 then
                    for _, targetPlayer in pairs(game:GetService("Players"):GetPlayers()) do
                        if targetPlayer ~= player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local character = targetPlayer.Character
                            local humanoid = character:FindFirstChild("Humanoid")
                            
                            if humanoid and humanoid.Health > 0 then
                                local espKey = "player_" .. targetPlayer.Name
                                
                                if not MainModule.ESPTable[espKey] then
                                    local highlight = Instance.new("Highlight")
                                    highlight.Adornee = character
                                    highlight.FillColor = Color3.fromRGB(0, 170, 255)
                                    highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
                                    highlight.OutlineColor = Color3.fromRGB(0, 170, 255)
                                    highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
                                    highlight.Parent = character
                                    
                                    MainModule.ESPTable[espKey] = highlight
                                end
                            else
                                -- Удаляем ESP если игрок мертв
                                local espKey = "player_" .. targetPlayer.Name
                                if MainModule.ESPTable[espKey] then
                                    MainModule.ESPTable[espKey]:Destroy()
                                    MainModule.ESPTable[espKey] = nil
                                end
                            end
                        end
                    end
                end
            end)
        end)
    else
        -- Очищаем все ESP при выключении
        for _, esp in pairs(MainModule.ESPTable) do
            if esp then
                esp:Destroy()
            end
        end
        MainModule.ESPTable = {}
    end
end

-- Misc функции
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

        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                makePromptInstant(obj)
            end
        end

        instaInteractConnection = workspace.DescendantAdded:Connect(function(obj)
            if obj:IsA("ProximityPrompt") then
                makePromptInstant(obj)
            end
        end)
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
