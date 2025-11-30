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
    OriginalHeight = nil,
    RemoveInjuredWalking = false
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
    KillAuraEnabled = false,
    SpikeTeleportEnabled = false,
    AutoTeleportEnabled = false
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
    GodMode = false,
    DeleteRope = false,
    AntiFall = false,
    AutoBalance = false
}

MainModule.Misc = {
    InstaInteract = false,
    NoCooldownProximity = false,
    EnableDash = false,
    ESPEnabled = false,
    ESPHighlight = true,
    ESPDistance = true,
    ESPFillTransparency = 0.75,
    ESPOutlineTransparency = 0,
    ESPTextSize = 22,
    PlayerESP = true,
    SeekerESP = true,
    HiderESP = true,
    GuardESP = true,
    DoorESP = true,
    KeyESP = true,
    EscapeDoorESP = true
}

-- ESP System
MainModule.ESPTable = {
    Player = {},
    Seeker = {},
    Hider = {},
    Guard = {},
    Door = {},
    None = {},
    Key = {},
    EscapeDoor = {}
}

-- ESP Colors
MainModule.ESPColors = {
    Player = Color3.fromRGB(0, 170, 255),
    Seeker = Color3.fromRGB(255, 50, 50),
    Hider = Color3.fromRGB(50, 255, 50),
    Guard = Color3.fromRGB(255, 150, 0),
    Door = Color3.fromRGB(255, 255, 0),
    Key = Color3.fromRGB(255, 0, 255),
    EscapeDoor = Color3.fromRGB(0, 255, 255)
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
local removeInjuredConnection = nil
local dashConnection = nil
local espConnection = nil
local hnsKillAuraConnection = nil
local hnsSpikeTeleportConnection = nil
local hnsAutoTeleportConnection = nil
local jumpRopeConnection = nil
local jumpRopeGodModeConnection = nil
local jumpRopeAntiFallConnection = nil
local jumpRopeAutoBalanceConnection = nil
local glassBridgeESPConnection = nil

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

-- Remove InjuredWalking функция
function MainModule.ToggleRemoveInjuredWalking(enabled)
    MainModule.RLGL.RemoveInjuredWalking = enabled
    
    if removeInjuredConnection then
        removeInjuredConnection:Disconnect()
        removeInjuredConnection = nil
    end
    
    if enabled then
        removeInjuredConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not MainModule.RLGL.RemoveInjuredWalking then return end
            
            pcall(function()
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj.Name == "InjuredWalking" or obj.Name:lower():find("stun") then
                        obj:Destroy()
                    end
                end
            end)
        end)
    end
end

-- Enable Dash функция
function MainModule.ToggleEnableDash(enabled)
    MainModule.Misc.EnableDash = enabled
    
    if dashConnection then
        dashConnection:Disconnect()
        dashConnection = nil
    end
    
    if enabled then
        local player = game:GetService("Players").LocalPlayer
        
        -- Устанавливаем максимальный уровень спринта
        pcall(function()
            if player:FindFirstChild("Boosts") and player.Boosts:FindFirstChild("Faster Sprint") then
                player.Boosts["Faster Sprint"].Value = 5
            end
        end)
        
        -- Скрываем кнопки покупки
        dashConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not MainModule.Misc.EnableDash then return end
            
            pcall(function()
                local shopGui = player.PlayerGui:FindFirstChild("ShopGui")
                if shopGui then
                    local storeHolder = shopGui:FindFirstChild("StoreHolder")
                    if storeHolder then
                        local store = storeHolder:FindFirstChild("Store")
                        if store then
                            local pages = store:FindFirstChild("PAGES")
                            if pages then
                                local boosts = pages:FindFirstChild("Boosts")
                                if boosts then
                                    local speedBoost = boosts:FindFirstChild("Faster Sprint")
                                    if speedBoost then
                                        -- Скрываем кнопки покупки
                                        if speedBoost:FindFirstChild("BuyButtonRobux") then
                                            speedBoost.BuyButtonRobux.Visible = false
                                        end
                                        if speedBoost:FindFirstChild("BuyButtonCoin") then
                                            speedBoost.BuyButtonCoin.Visible = false
                                        end
                                        -- Устанавливаем текст уровня
                                        if speedBoost:FindFirstChild("ItemLevel") then
                                            speedBoost.ItemLevel.Text = "Current Level (5)"
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end)
    else
        -- Возвращаем исходное значение
        pcall(function()
            local player = game:GetService("Players").LocalPlayer
            if player:FindFirstChild("Boosts") and player.Boosts:FindFirstChild("Faster Sprint") then
                player.Boosts["Faster Sprint"].Value = 1 -- Исходный уровень
            end
        end)
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

-- Rapid Fire функция (исправленная)
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

-- Infinite Ammo функция (исправленная)
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

-- Hitbox Expander функция (исправленная)
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
                        v.Character.Head.Transparency = 1 -- Полностью прозрачный
                        v.Character.Head.CanCollide = false
                    end)
                end
            end
        end
        
        hitboxConnection = game:GetService("RunService").RenderStepped:Connect(UpdateHeadHitboxes)
    else
        -- Восстанавливаем оригинальные размеры и прозрачность
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
function MainModule.ToggleAutoPickup(enabled)
    MainModule.HNS.AutoPickup = enabled
end

function MainModule.ToggleSpikesKill(enabled)
    MainModule.HNS.SpikesKill = enabled
    
    if hnsSpikeTeleportConnection then
        hnsSpikeTeleportConnection:Disconnect()
        hnsSpikeTeleportConnection = nil
    end
    
    if enabled then
        -- Функция телепортации на шипы
        local function SetupSpikeTeleport()
            local player = game:GetService("Players").LocalPlayer
            local character = player.Character
            if not character then return end
            
            local humanoid = character:FindFirstChild("Humanoid")
            if not humanoid then return end
            
            -- Ищем шипы в workspace
            local spikes = workspace:FindFirstChild("HideAndSeekMap") and 
                          workspace.HideAndSeekMap:FindFirstChild("KillingParts")
            
            if spikes then
                -- Телепортируем к ближайшему шипу
                local closestSpike = nil
                local closestDistance = math.huge
                
                for _, spike in pairs(spikes:GetChildren()) do
                    if spike:IsA("BasePart") then
                        local distance = (character.HumanoidRootPart.Position - spike.Position).Magnitude
                        if distance < closestDistance then
                            closestDistance = distance
                            closestSpike = spike
                        end
                    end
                end
                
                if closestSpike then
                    character.HumanoidRootPart.CFrame = closestSpike.CFrame + Vector3.new(0, 3, 0)
                end
            end
        end
        
        hnsSpikeTeleportConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not MainModule.HNS.SpikesKill then return end
            SetupSpikeTeleport()
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
    
    if hnsKillAuraConnection then
        hnsKillAuraConnection:Disconnect()
        hnsKillAuraConnection = nil
    end
    
    if enabled then
        hnsKillAuraConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not MainModule.HNS.KillHiders then return end
            
            local player = game:GetService("Players").LocalPlayer
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local HRP = character.HumanoidRootPart
            
            -- Ищем ближайшего хайдера
            for _, targetPlayer in pairs(game:GetService("Players"):GetPlayers()) do
                if targetPlayer ~= player and targetPlayer.Character and 
                   targetPlayer.Character:FindFirstChild("HumanoidRootPart") and
                   targetPlayer:GetAttribute("IsHider") then
                   
                    local targetHRP = targetPlayer.Character.HumanoidRootPart
                    local distance = (HRP.Position - targetHRP.Position).Magnitude
                    
                    if distance < 20 then
                        -- Телепортируемся к хайдеру
                        HRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, -3)
                        break
                    end
                end
            end
        end)
    end
end

function MainModule.ToggleAutoDodge(enabled)
    MainModule.HNS.AutoDodge = enabled
    
    if hnsAutoTeleportConnection then
        hnsAutoTeleportConnection:Disconnect()
        hnsAutoTeleportConnection = nil
    end
    
    if enabled then
        hnsAutoTeleportConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not MainModule.HNS.AutoDodge then return end
            
            -- Автоматическая телепортация от опасностей
            local player = game:GetService("Players").LocalPlayer
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            -- Ищем безопасное место для телепортации
            local safePosition = Vector3.new(0, 50, 0) -- Пример безопасной позиции
            character.HumanoidRootPart.CFrame = CFrame.new(safePosition)
        end)
    end
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
        
        -- Показываем сообщение
        pcall(function()
            local Effects = require(game:GetService("ReplicatedStorage").Modules.Effects)
            Effects.AnnouncementTween({
                AnnouncementOneLine = true,
                FasterTween = true,
                DisplayTime = 10,
                AnnouncementDisplayText = "[CreonX]: Safe tiles are green, breakable tiles are red!"
            })
        end)
    end
end

-- Jump Rope функции
function MainModule.TeleportToJumpRopeEnd()
    local player = game:GetService("Players").LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(720.896057, 198.628311, 921.170654)
    end
end

function MainModule.DeleteJumpRope()
    pcall(function()
        local rope = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("rope")
        if rope then
            rope:Destroy()
        end
    end)
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
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if not humanoid or not rootPart then return end
            
            -- Проверяем наличие веревки
            local rope = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("rope")
            if rope then
                local distance = (rootPart.Position - rope.Position).Magnitude
                
                -- Автоматически прыгаем когда близко к веревке
                if distance <= 15 then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end
end

function MainModule.ToggleJumpRopeGodMode(enabled)
    MainModule.JumpRope.GodMode = enabled
    
    if jumpRopeGodModeConnection then
        jumpRopeGodModeConnection:Disconnect()
        jumpRopeGodModeConnection = nil
    end
    
    if enabled then
        jumpRopeGodModeConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not MainModule.JumpRope.GodMode then return end
            
            local player = game:GetService("Players").LocalPlayer
            local character = player.Character
            if not character then return end
            
            -- Защита от падения
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart and rootPart.Position.Y < 190 then
                rootPart.CFrame = CFrame.new(720.896057, 198.628311, 921.170654)
            end
            
            -- Защита от веревки
            local rope = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("rope")
            if rope then
                -- Делаем веревку безопасной
                for _, part in pairs(rope:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanTouch = false
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

function MainModule.ToggleJumpRopeAntiFall(enabled)
    MainModule.JumpRope.AntiFall = enabled
    
    if jumpRopeAntiFallConnection then
        jumpRopeAntiFallConnection:Disconnect()
        jumpRopeAntiFallConnection = nil
    end
    
    if enabled then
        jumpRopeAntiFallConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not MainModule.JumpRope.AntiFall then return end
            
            local player = game:GetService("Players").LocalPlayer
            local character = player.Character
            if not character then return end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart and rootPart.Position.Y < 190 then
                rootPart.CFrame = CFrame.new(720.896057, 198.628311, 921.170654)
            end
        end)
    end
end

function MainModule.ToggleAutoBalance(enabled)
    MainModule.JumpRope.AutoBalance = enabled
    
    if jumpRopeAutoBalanceConnection then
        jumpRopeAutoBalanceConnection:Disconnect()
        jumpRopeAutoBalanceConnection = nil
    end
    
    if enabled then
        jumpRopeAutoBalanceConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not MainModule.JumpRope.AutoBalance then return end
            
            -- Автоматическое нажатие A/D для баланса
            local player = game:GetService("Players").LocalPlayer
            local playerGui = player:FindFirstChild("PlayerGui")
            
            if playerGui then
                -- Ищем интерфейс баланса
                for _, gui in pairs(playerGui:GetDescendants()) do
                    if gui:IsA("TextLabel") and (gui.Text:find("A") or gui.Text:find("D")) then
                        -- Автоматически нажимаем нужные кнопки
                        local virtualInput = game:GetService("VirtualInputManager")
                        
                        if gui.Text:find("A") then
                            for i = 1, 3 do -- Нажимаем A 3 раза
                                virtualInput:SendKeyEvent(true, Enum.KeyCode.A, false, nil)
                                task.wait(0.1)
                                virtualInput:SendKeyEvent(false, Enum.KeyCode.A, false, nil)
                                task.wait(0.1)
                            end
                        elseif gui.Text:find("D") then
                            for i = 1, 3 do -- Нажимаем D 3 раза
                                virtualInput:SendKeyEvent(true, Enum.KeyCode.D, false, nil)
                                task.wait(0.1)
                                virtualInput:SendKeyEvent(false, Enum.KeyCode.D, false, nil)
                                task.wait(0.1)
                            end
                        end
                        break
                    end
                end
            end
        end)
    end
end

-- ESP System функции
function MainModule.CreateESP(args)
    if not args.Object then return end

    local ESPManager = {
        Object = args.Object,
        Text = args.Text or "No Text",
        TextParent = args.TextParent,
        Color = args.Color or Color3.new(),
        Offset = args.Offset or Vector3.zero,
        IsEntity = args.IsEntity or false,
        Type = args.Type or "None",
        Highlights = {},
        Humanoid = nil,
        Connections = {}
    }

    local tableIndex = #MainModule.ESPTable[ESPManager.Type] + 1

    if ESPManager.IsEntity and ESPManager.Object.PrimaryPart then
        ESPManager.Object:SetAttribute("Transparency", ESPManager.Object.PrimaryPart.Transparency)
        ESPManager.Humanoid = Instance.new("Humanoid", ESPManager.Object)
        ESPManager.Object.PrimaryPart.Transparency = 0.99
    end

    local highlight = Instance.new("Highlight")
    highlight.Adornee = ESPManager.Object
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = ESPManager.Color
    highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
    highlight.OutlineColor = ESPManager.Color
    highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
    highlight.Enabled = MainModule.Misc.ESPHighlight
    highlight.Parent = ESPManager.Object

    table.insert(ESPManager.Highlights, highlight)
    
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Adornee = ESPManager.TextParent or ESPManager.Object
    billboardGui.AlwaysOnTop = true
    billboardGui.ClipsDescendants = false
    billboardGui.Size = UDim2.new(0, 1, 0, 1)
    billboardGui.StudsOffset = ESPManager.Offset
    billboardGui.Parent = ESPManager.TextParent or ESPManager.Object

    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.Oswald
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Text = ESPManager.Text
    textLabel.TextColor3 = ESPManager.Color
    textLabel.TextSize = MainModule.Misc.ESPTextSize
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.TextStrokeTransparency = 0.75
    textLabel.Parent = billboardGui

    function ESPManager.Destroy()
        if ESPManager.IsEntity and ESPManager.Object then
            if ESPManager.Object.PrimaryPart then
                ESPManager.Object.PrimaryPart.Transparency = ESPManager.Object.PrimaryPart:GetAttribute("Transparency")
            end
            if ESPManager.Humanoid then
                ESPManager.Humanoid:Destroy()
            end
        end

        for _, highlight in pairs(ESPManager.Highlights) do
            highlight:Destroy()
        end
        if billboardGui then billboardGui:Destroy() end

        if MainModule.ESPTable[ESPManager.Type][tableIndex] then
            MainModule.ESPTable[ESPManager.Type][tableIndex] = nil
        end

        for _, conn in pairs(ESPManager.Connections) do
            pcall(function()
                conn:Disconnect()
            end)
        end
        ESPManager.Connections = {}
    end

    function ESPManager.GiveSignal(signal)
        table.insert(ESPManager.Connections, signal)
    end

    MainModule.ESPTable[ESPManager.Type][tableIndex] = ESPManager
    return ESPManager
end

function MainModule.DistanceFromCharacter(obj)
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") and obj and obj:IsA("BasePart") then
        return (character.HumanoidRootPart.Position - obj.Position).Magnitude
    end
    return 0
end

-- ESP для игроков
function MainModule.CreatePlayerESP(player)
    if not (player.Character and player.Character.PrimaryPart and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0) then return end

    local playerEsp = MainModule.CreateESP({
        Type = "Player",
        Object = player.Character,
        Text = string.format("%s [%s]", player.DisplayName, player.Character.Humanoid.Health),
        TextParent = player.Character.PrimaryPart,
        Color = MainModule.ESPColors.Player
    })

    if playerEsp then
        playerEsp.GiveSignal(player.Character.Humanoid.HealthChanged:Connect(function(newHealth)
            if newHealth > 0 then
                playerEsp.Text = string.format("%s [%s]", player.DisplayName, newHealth)
            else
                playerEsp.Destroy()
            end
        end))
    end
end

-- ESP для Hide & Seek
function MainModule.CreateSeekerESP(player)
    if player:GetAttribute("IsHunter") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local esp = MainModule.CreateESP({
            Object = player.Character,
            Text = player.Name .. " (Seeker)",
            Color = MainModule.ESPColors.Seeker,
            Offset = Vector3.new(0, 3, 0),
            Type = "Seeker"
        })
    end
end

function MainModule.CreateHiderESP(player)
    if player:GetAttribute("IsHider") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local esp = MainModule.CreateESP({
            Object = player.Character,
            Text = player.Name .. " (Hider)",
            Color = MainModule.ESPColors.Hider,
            Offset = Vector3.new(0, 3, 0),
            Type = "Hider"
        })
        
        if esp then
            player:GetAttributeChangedSignal("IsHider"):Once(function()
                if not player:GetAttribute("IsHider") then
                    esp.Destroy()
                end
            end)
        end
    end
end

-- ESP для предметов
function MainModule.CreateKeyESP(key)
    if key:IsA("Model") and key.PrimaryPart then
        local esp = MainModule.CreateESP({
            Object = key,
            Text = key.Name .. " (Key)",
            Color = MainModule.ESPColors.Key,
            Offset = Vector3.new(0, 1, 0),
            Type = "Key",
            IsEntity = true
        })
    end
end

function MainModule.CreateDoorESP(door)
    if door:IsA("Model") and door.Name == "FullDoorAnimated" and door.PrimaryPart then
        local keyNeeded = door:GetAttribute("KeyNeeded") or "None"
        local esp = MainModule.CreateESP({
            Object = door,
            Text = "Door (Key: " .. keyNeeded .. ")",
            Color = MainModule.ESPColors.Door,
            Offset = Vector3.new(0, 2, 0),
            Type = "Door",
            IsEntity = true
        })
    end
end

function MainModule.CreateEscapeDoorESP(door)
    if door:IsA("Model") and door.Name == "EXITDOOR" and door.PrimaryPart and door:GetAttribute("CANESCAPE") then
        local esp = MainModule.CreateESP({
            Object = door,
            Text = "Escape Door",
            Color = MainModule.ESPColors.EscapeDoor,
            Offset = Vector3.new(0, 2, 0),
            Type = "EscapeDoor",
            IsEntity = true
        })
    end
end

function MainModule.CreateGuardESP(character)
    if character and character:FindFirstChild("HumanoidRootPart") then
        local esp = MainModule.CreateESP({
            Object = character,
            Text = "Guard",
            Color = MainModule.ESPColors.Guard,
            Offset = Vector3.new(0, 3, 0),
            Type = "Guard"
        })
        
        if esp then
            table.insert(esp.Connections, character.ChildAdded:Connect(function(v)
                if v.Name == "Dead" and v.ClassName == "Folder" then
                    esp.Destroy()
                end
            end))
        end
    end
end

-- Основная функция ESP
function MainModule.ToggleESP(enabled)
    MainModule.Misc.ESPEnabled = enabled
    
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end
    
    -- Очищаем старые ESP
    for _, espType in pairs(MainModule.ESPTable) do
        for _, esp in pairs(espType) do
            if esp.Destroy then
                esp:Destroy()
            end
        end
    end
    
    if enabled then
        espConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not MainModule.Misc.ESPEnabled then return end
            
            -- ESP для игроков
            if MainModule.Misc.PlayerESP then
                for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                    if player ~= game:GetService("Players").LocalPlayer then
                        MainModule.CreatePlayerESP(player)
                    end
                end
            end
            
            -- ESP для Hide & Seek
            if MainModule.Misc.SeekerESP then
                for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                    if player:GetAttribute("IsHunter") then
                        MainModule.CreateSeekerESP(player)
                    end
                end
            end
            
            if MainModule.Misc.HiderESP then
                for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                    if player:GetAttribute("IsHider") then
                        MainModule.CreateHiderESP(player)
                    end
                end
            end
            
            -- ESP для Guards
            if MainModule.Misc.GuardESP then
                -- Ищем охранников в workspace
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
                        if obj.Name:lower():find("guard") or obj:GetAttribute("IsGuard") then
                            MainModule.CreateGuardESP(obj)
                        end
                    end
                end
            end
            
            -- ESP для предметов
            if MainModule.Misc.DoorESP then
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj.Name == "FullDoorAnimated" then
                        MainModule.CreateDoorESP(obj)
                    end
                end
            end
            
            if MainModule.Misc.KeyESP then
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj.Name:lower():find("key") then
                        MainModule.CreateKeyESP(obj)
                    end
                end
            end
            
            if MainModule.Misc.EscapeDoorESP then
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj.Name == "EXITDOOR" then
                        MainModule.CreateEscapeDoorESP(obj)
                    end
                end
            end
        end)
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
