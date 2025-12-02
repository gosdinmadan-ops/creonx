-- Main.lua - Creon X v2.1 (Полная исправленная версия)
local MainModule = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")

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

-- RLGL GodMode (исправленный)
MainModule.RLGL = {
    GodMode = false,
    OriginalHeight = nil,
    OriginalPosition = nil,
    GodModeConnection = nil,
    LastDamageCheck = 0,
    DamageCheckRate = 0.3,
    DamageDetected = false,
    SafePosition = Vector3.new(-856, 1184, -550)
}

MainModule.Guards = {
    SelectedGuard = "Circle",
    AutoFarm = false,
    RapidFire = false,
    InfiniteAmmo = false,
    HitboxExpander = false,
    OriginalFireRates = {},
    OriginalAmmo = {},
    OriginalHitboxes = {}
}

MainModule.Dalgona = {
    CompleteEnabled = false,
    FreeLighterEnabled = false
}

-- HNS System (исправленный)
MainModule.HNS = {
    KillAuraEnabled = false,
    KillSpikesEnabled = false,
    RemoveSpikesEnabled = false,
    DisableSpikesEnabled = false,
    TeleportToHiderEnabled = false,
    AutoDodgeEnabled = false,
    
    LastKillTime = 0,
    KillCooldown = 0.5,
    CurrentTarget = nil,
    
    LastDodgeTime = 0,
    DodgeCooldown = 1.0,
    DodgeRange = 10, -- Изменено на 10
    
    SpikePositions = {},
    OriginalSpikeData = {},
    KillSpikesConnection = nil,
    KillAuraConnection = nil,
    AutoDodgeConnection = nil,
    
    -- Для оптимизации AutoDodge
    LastHitboxCheck = 0,
    HitboxCheckRate = 0.2,
    TrackedHitboxes = {},
    TrackedPlayers = {}
}

-- Glass Bridge System
MainModule.GlassBridge = {
    GlassVisionEnabled = false,
    AntiFallEnabled = false,
    AntiBreakEnabled = false,
    GlassPlatformsEnabled = false,
    GlassCoverEnabled = false,
    
    GlassPlatforms = {},
    AntiFallPlatform = nil,
    GlassCover = nil,
    AntiFallConnection = nil,
    AntiBreakConnection = nil,
    GlassVisionConnection = nil,
    
    EndPosition = Vector3.new(-196.372467, 522.192139, -1534.20984),
    SafeHeight = 500
}

MainModule.TugOfWar = {
    AutoPull = false
}

MainModule.JumpRope = {
    TeleportToEnd = false,
    DeleteRope = false,
    AntiFallPlatform = nil
}

MainModule.SkySquid = {
    AntiFall = false,
    VoidKill = false,
    AntiFallPlatform = nil,
    SafePlatform = nil
}

-- ESP System (оптимизированная без лагов)
MainModule.Misc = {
    InstaInteract = false,
    NoCooldownProximity = false,
    ESPEnabled = false,
    ESPPlayers = true,
    ESPHiders = true,
    ESPSeekers = true,
    ESPCandies = false,
    ESPKeys = true,
    ESPDoors = true,
    ESPEscapeDoors = true,
    ESPGuards = true,
    ESPHighlight = true,
    ESPDistance = true,
    ESPNames = true,
    ESPBoxes = true,
    ESPFillTransparency = 0.7,
    ESPOutlineTransparency = 0,
    ESPTextSize = 18,
    BypassRagdollEnabled = false,
    RemoveInjuredEnabled = false,
    RemoveStunEnabled = false,
    UnlockDashEnabled = false,
    UnlockPhantomStepEnabled = false,
    LastESPUpdate = 0,
    ESPUpdateRate = 0.3,
    
    -- Цвета ESP
    PlayerEspColor = Color3.fromRGB(0, 170, 255),
    SeekerEspColor = Color3.fromRGB(255, 0, 0),
    HiderEspColor = Color3.fromRGB(0, 255, 0),
    GuardEspColor = Color3.fromRGB(255, 165, 0),
    DoorEspColor = Color3.fromRGB(255, 255, 0),
    EscapeDoorEspColor = Color3.fromRGB(255, 0, 255),
    KeyEspColor = Color3.fromRGB(255, 255, 255),
    
    -- Эффекты
    LastEffectsCleanup = 0,
    EffectsCleanupRate = 0.3
}

-- ESP Table structure
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

MainModule.ESPFolder = nil
MainModule.ESPConnections = {}
MainModule.PlayerESPConnections = {}

-- Локальный игрок
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Вспомогательные функции
local function SafeDestroy(obj)
    if obj and obj.Parent then
        pcall(function() obj:Destroy() end)
    end
end

local function GetDistance(position)
    local character = LocalPlayer.Character
    if not character then return 0 end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return 0 end
    
    if typeof(position) == "Instance" then
        if position:IsA("BasePart") then
            position = position.Position
        elseif position:IsA("Model") and position.PrimaryPart then
            position = position.PrimaryPart.Position
        else
            return 0
        end
    end
    
    return math.floor((rootPart.Position - position).Magnitude)
end

-- Bypass Ragdoll (исправленный - предотвращает откидывание)
function MainModule.ToggleBypassRagdoll(enabled)
    MainModule.Misc.BypassRagdollEnabled = enabled
    
    if enabled then
        local function preventRagdoll()
            local character = LocalPlayer.Character
            if not character then return end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            
            -- Предотвращаем отбрасывание
            pcall(function()
                -- Отключаем физические силы
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        -- Блокируем силы
                        part.Velocity = Vector3.new(0, 0, 0)
                        part.RotVelocity = Vector3.new(0, 0, 0)
                        part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                        
                        -- Увеличиваем массу для устойчивости
                        part.CustomPhysicalProperties = PhysicalProperties.new(999, 0.3, 0.5)
                    end
                end
                
                -- Блокируем Ragdoll состояния
                if humanoid:GetState() == Enum.HumanoidStateType.FallingDown or 
                   humanoid:GetState() == Enum.HumanoidStateType.Ragdoll then
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    humanoid.PlatformStand = false
                end
                
                -- Удаляем Ragdoll объекты
                for _, child in ipairs(character:GetChildren()) do
                    if child.Name:lower():find("ragdoll") or 
                       child.Name:lower():find("stun") or
                       child.Name:lower():find("knockback") then
                        pcall(function() child:Destroy() end)
                    end
                end
                
                -- Отключаем BodyVelocity и BodyForce
                for _, obj in pairs(character:GetDescendants()) do
                    if obj:IsA("BodyVelocity") or obj:IsA("BodyForce") or 
                       obj:IsA("BodyAngularVelocity") or obj:IsA("VectorForce") then
                        pcall(function() 
                            obj.Velocity = Vector3.new(0, 0, 0)
                            obj.Force = Vector3.new(0, 0, 0)
                            obj:Destroy()
                        end)
                    end
                end
                
                -- Сохраняем позицию
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    -- Фиксируем позицию
                    local currentCFrame = rootPart.CFrame
                    task.wait(0.05)
                    rootPart.CFrame = currentCFrame
                end
            end)
        end
        
        -- Немедленная очистка
        preventRagdoll()
        
        -- Периодическая очистка
        local cleanupConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.Misc.BypassRagdollEnabled then return end
            preventRagdoll()
        end)
        
        table.insert(MainModule.ESPConnections, cleanupConnection)
    else
        -- Восстанавливаем нормальную физику
        local character = LocalPlayer.Character
        if character then
            pcall(function()
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CustomPhysicalProperties = nil
                    end
                end
            end)
        end
    end
end

-- Auto Dodge (исправленный)
function MainModule.ToggleAutoDodge(enabled)
    MainModule.HNS.AutoDodgeEnabled = enabled
    
    if MainModule.HNS.AutoDodgeConnection then
        MainModule.HNS.AutoDodgeConnection:Disconnect()
        MainModule.HNS.AutoDodgeConnection = nil
    end
    
    MainModule.HNS.TrackedHitboxes = {}
    MainModule.HNS.TrackedPlayers = {}
    
    if enabled then
        MainModule.HNS.AutoDodgeConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.AutoDodgeEnabled then return end
            
            local currentTime = tick()
            if currentTime - MainModule.HNS.LastHitboxCheck < MainModule.HNS.HitboxCheckRate then return end
            MainModule.HNS.LastHitboxCheck = currentTime
            
            if currentTime - MainModule.HNS.LastDodgeTime < MainModule.HNS.DodgeCooldown then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                
                if not rootPart or not humanoid or humanoid.Health <= 0 then return end
                
                -- Сначала проверяем наличие игроков с ножом в радиусе 10
                local hasKnifePlayerNearby = false
                local nearbyPlayers = {}
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local targetCharacter = player.Character
                        local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
                        
                        if targetRoot then
                            local distance = (rootPart.Position - targetRoot.Position).Magnitude
                            
                            if distance <= MainModule.HNS.DodgeRange then
                                -- Проверяем, есть ли у него нож
                                local hasKnife = false
                                
                                for _, tool in pairs(targetCharacter:GetChildren()) do
                                    if tool:IsA("Tool") then
                                        local toolName = tool.Name:lower()
                                        if toolName:find("knife") or toolName:find("fork") or toolName:find("dagger") then
                                            hasKnife = true
                                            break
                                        end
                                    end
                                end
                                
                                if hasKnife then
                                    hasKnifePlayerNearby = true
                                    table.insert(nearbyPlayers, player)
                                end
                            end
                        end
                    end
                end
                
                -- Если есть игроки с ножом рядом, отслеживаем их
                if hasKnifePlayerNearby then
                    -- Ищем новые хитбоксы (не от игроков) в радиусе
                    local foundNewHitbox = false
                    
                    -- Собираем все части в радиусе
                    for _, part in pairs(Workspace:GetDescendants()) do
                        if part:IsA("BasePart") and not part:IsDescendantOf(character) then
                            local distance = (rootPart.Position - part.Position).Magnitude
                            
                            if distance <= MainModule.HNS.DodgeRange then
                                -- Пропускаем части игроков
                                local isPlayerPart = false
                                for _, player in pairs(Players:GetPlayers()) do
                                    if player.Character and part:IsDescendantOf(player.Character) then
                                        isPlayerPart = true
                                        break
                                    end
                                end
                                
                                if not isPlayerPart then
                                    local hitboxId = tostring(part:GetDebugId())
                                    if not MainModule.HNS.TrackedHitboxes[hitboxId] then
                                        -- Новый хитбокс найден
                                        MainModule.HNS.TrackedHitboxes[hitboxId] = true
                                        foundNewHitbox = true
                                        break
                                    end
                                end
                            end
                        end
                    end
                    
                    -- Если найден новый хитбокс (не от игрока), делаем додж
                    if foundNewHitbox then
                        -- Используем слот 1 для доджа
                        pcall(function()
                            if UserInputService.TouchEnabled then
                                -- Для мобильных
                                local backpack = LocalPlayer:FindFirstChild("Backpack")
                                if backpack then
                                    local tool = backpack:FindFirstChildOfClass("Tool")
                                    if tool then
                                        tool.Parent = character
                                        task.wait(0.1)
                                        tool.Parent = backpack
                                    end
                                end
                            else
                                -- Для ПК
                                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.One, false, game)
                                task.wait(0.05)
                                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.One, false, game)
                            end
                        end)
                        
                        -- Телепортируемся в случайном направлении
                        local randomAngle = math.random() * 2 * math.pi
                        local teleportDistance = 5
                        local offset = Vector3.new(
                            math.cos(randomAngle) * teleportDistance,
                            0,
                            math.sin(randomAngle) * teleportDistance
                        )
                        
                        local newPosition = rootPart.Position + offset
                        rootPart.CFrame = CFrame.new(newPosition)
                        
                        MainModule.HNS.LastDodgeTime = currentTime
                    end
                end
                
                -- Очищаем старые хитбоксы
                local trackedCount = 0
                for _ in pairs(MainModule.HNS.TrackedHitboxes) do
                    trackedCount = trackedCount + 1
                end
                
                if trackedCount > 50 then
                    local newTable = {}
                    local counter = 0
                    for k, v in pairs(MainModule.HNS.TrackedHitboxes) do
                        if counter < 25 then
                            newTable[k] = v
                            counter = counter + 1
                        end
                    end
                    MainModule.HNS.TrackedHitboxes = newTable
                end
            end)
        end)
    end
end

-- RLGL GodMode (исправленный)
function MainModule.ToggleGodMode(enabled)
    MainModule.RLGL.GodMode = enabled
    
    if MainModule.RLGL.GodModeConnection then
        MainModule.RLGL.GodModeConnection:Disconnect()
        MainModule.RLGL.GodModeConnection = nil
    end
    
    -- Сбрасываем флаг получения урона
    MainModule.RLGL.DamageDetected = false
    MainModule.RLGL.OriginalPosition = nil
    MainModule.RLGL.OriginalHeight = nil
    
    if enabled then
        -- Сохраняем оригинальную позицию
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            MainModule.RLGL.OriginalPosition = character.HumanoidRootPart.CFrame
            MainModule.RLGL.OriginalHeight = character.HumanoidRootPart.Position.Y
            
            -- Поднимаем игрока вверх
            local currentPos = character.HumanoidRootPart.Position
            character.HumanoidRootPart.CFrame = CFrame.new(currentPos.X, 1184.9, currentPos.Z)
        end
        
        -- Проверка урона
        MainModule.RLGL.GodModeConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.RLGL.GodMode then return end
            
            local currentTime = tick()
            if currentTime - MainModule.RLGL.LastDamageCheck < MainModule.RLGL.DamageCheckRate then return end
            MainModule.RLGL.LastDamageCheck = currentTime
            
            local character = LocalPlayer.Character
            if not character then return end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            
            -- Проверяем, получили ли мы урон (только после включения GodMode)
            if not MainModule.RLGL.DamageDetected and humanoid.Health < humanoid.MaxHealth then
                -- Устанавливаем флаг, что урон получен
                MainModule.RLGL.DamageDetected = true
                
                -- Телепортируем на безопасные координаты
                character.HumanoidRootPart.CFrame = CFrame.new(MainModule.RLGL.SafePosition)
                
                -- Восстанавливаем здоровье
                humanoid.Health = humanoid.MaxHealth
                
                -- Выключаем GodMode (не телепортируем обратно вниз)
                task.wait(0.5) -- Небольшая задержка
                MainModule.ToggleGodMode(false)
            end
        end)
    else
        -- Не телепортируем обратно вниз, просто выключаем
        -- Оставляем игрока на текущей позиции
    end
end

-- Функции скорости
function MainModule.ToggleSpeedHack(enabled)
    MainModule.SpeedHack.Enabled = enabled
    
    local player = LocalPlayer
    
    if enabled then
        local character = player.Character or player.CharacterAdded:Wait()
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                MainModule.SpeedHack.DefaultSpeed = humanoid.WalkSpeed
            end
        end
        
        local speedConnection = RunService.Heartbeat:Connect(function()
            local character = player.Character
            if character and MainModule.SpeedHack.Enabled then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = MainModule.SpeedHack.CurrentSpeed
                end
            end
        end)
        
        table.insert(MainModule.ESPConnections, speedConnection)
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
        local player = LocalPlayer
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
    local player = LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 100, 0)
    end
end

function MainModule.TeleportDown40()
    local player = LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, -40, 0)
    end
end

-- Anti Stun QTE функция
function MainModule.ToggleAntiStunQTE(enabled)
    MainModule.AutoQTE.AntiStunEnabled = enabled
    
    if enabled then
        local antiStunConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.AutoQTE.AntiStunEnabled then return end
            
            pcall(function()
                local playerGui = LocalPlayer:WaitForChild("PlayerGui")
                local impactFrames = playerGui:FindFirstChild("ImpactFrames")
                if not impactFrames then return end
                
                local replicatedStorage = ReplicatedStorage
                
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
        
        table.insert(MainModule.ESPConnections, antiStunConnection)
    end
end

-- Remove Stun функция
function MainModule.ToggleRemoveStun(enabled)
    MainModule.Misc.RemoveStunEnabled = enabled
    
    if enabled then
        local function cleanupStun()
            local character = LocalPlayer.Character
            if not character then return end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then return end
            
            -- Удаляем эффекты Stun
            for _, child in pairs(character:GetDescendants()) do
                local childName = child.Name:lower()
                if string.find(childName, "stun") or 
                   string.find(childName, "slow") or 
                   string.find(childName, "freeze") then
                    pcall(function() child:Destroy() end)
                end
            end
            
            -- Убираем состояние Stun у Humanoid
            if humanoid:GetState() == Enum.HumanoidStateType.Stunned then
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
        
        -- Немедленная очистка
        cleanupStun()
        
        -- Периодическая очистка
        local cleanupConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.Misc.RemoveStunEnabled then return end
            cleanupStun()
        end)
        
        table.insert(MainModule.ESPConnections, cleanupConnection)
    end
end

-- Rebel функция
function MainModule.ToggleRebel(enabled)
    MainModule.Rebel.Enabled = enabled
    _G.InstantRebel = enabled
end

-- RLGL функции
function MainModule.TeleportToEnd()
    local player = LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-214.4, 1023.1, 146.7)
    end
end

function MainModule.TeleportToStart()
    local player = LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-55.3, 1023.1, -545.8)
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
        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlayableGuardRemote"):FireServer(unpack(args))
    end)
end

function MainModule.ToggleAutoFarm(enabled)
    MainModule.Guards.AutoFarm = enabled
    
    if enabled then
        local autoFarmConnection = RunService.Heartbeat:Connect(function()
            if MainModule.Guards.AutoFarm then
                local args2 = {
                    "GameOver",
                    4450
                }
                pcall(function()
                    ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("VideoGameRemote"):FireServer(unpack(args2))
                end)
            end
        end)
        
        table.insert(MainModule.ESPConnections, autoFarmConnection)
    end
end

-- Rapid Fire функция
function MainModule.ToggleRapidFire(enabled)
    MainModule.Guards.RapidFire = enabled
    
    if enabled then
        local rapidFireConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.Guards.RapidFire then return end
            
            pcall(function()
                local weaponsFolder = ReplicatedStorage:FindFirstChild("Weapons")
                if not weaponsFolder then return end
                
                local gunsFolder = weaponsFolder:FindFirstChild("Guns")
                if gunsFolder then
                    for _, obj in ipairs(gunsFolder:GetDescendants()) do
                        if obj.Name == "FireRateCD" and (obj:IsA("NumberValue") or obj:IsA("IntValue")) then
                            if not MainModule.Guards.OriginalFireRates[obj] then
                                MainModule.Guards.OriginalFireRates[obj] = obj.Value
                            end
                            obj.Value = 0
                        end
                    end
                end
                
                local character = LocalPlayer.Character
                if character then
                    for _, tool in pairs(character:GetChildren()) do
                        if tool:IsA("Tool") then
                            for _, obj in pairs(tool:GetDescendants()) do
                                if obj.Name == "FireRateCD" and (obj:IsA("NumberValue") or obj:IsA("IntValue")) then
                                    if not MainModule.Guards.OriginalFireRates[obj] then
                                        MainModule.Guards.OriginalFireRates[obj] = obj.Value
                                    end
                                    obj.Value = 0
                                end
                            end
                        end
                    end
                end
            end)
        end)
        
        table.insert(MainModule.ESPConnections, rapidFireConnection)
    else
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
    
    if enabled then
        local infiniteAmmoConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.Guards.InfiniteAmmo then return end
            
            local character = LocalPlayer.Character
            if character then
                for _, tool in pairs(character:GetChildren()) do
                    if tool:IsA("Tool") then
                        for _, obj in pairs(tool:GetDescendants()) do
                            if obj:IsA("NumberValue") then
                                if obj.Name:lower():find("ammo") or 
                                   obj.Name:lower():find("bullet") or
                                   obj.Name:lower():find("clip") then
                                    if not MainModule.Guards.OriginalAmmo[obj] then
                                        MainModule.Guards.OriginalAmmo[obj] = obj.Value
                                    end
                                    obj.Value = 9999
                                end
                            end
                        end
                    end
                end
            end
        end)
        
        table.insert(MainModule.ESPConnections, infiniteAmmoConnection)
    else
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
    
    if enabled then
        local HITBOX_SIZE = 10
        
        local hitboxConnection = RunService.Stepped:Connect(function()
            if not MainModule.Guards.HitboxExpander then 
                for player, originalSizes in pairs(MainModule.Guards.OriginalHitboxes) do
                    if player and player.Character then
                        for partName, originalSize in pairs(originalSizes) do
                            local part = player.Character:FindFirstChild(partName)
                            if part and part:IsA("BasePart") then
                                part.Size = originalSize
                                part.CanCollide = true
                            end
                        end
                    end
                end
                MainModule.Guards.OriginalHitboxes = {}
                return 
            end
            
            pcall(function()
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        if not MainModule.Guards.OriginalHitboxes[player] then
                            MainModule.Guards.OriginalHitboxes[player] = {}
                            
                            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                            if rootPart and rootPart:IsA("BasePart") then
                                MainModule.Guards.OriginalHitboxes[player]["HumanoidRootPart"] = rootPart.Size
                            end
                        end
                        
                        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                        if rootPart and rootPart:IsA("BasePart") then
                            if MainModule.Guards.OriginalHitboxes[player] and MainModule.Guards.OriginalHitboxes[player]["HumanoidRootPart"] then
                                rootPart.Size = Vector3.new(HITBOX_SIZE, HITBOX_SIZE, HITBOX_SIZE)
                                rootPart.CanCollide = true
                            end
                        end
                    end
                end
            end)
        end)
        
        table.insert(MainModule.ESPConnections, hitboxConnection)
    else
        pcall(function()
            for player, originalSizes in pairs(MainModule.Guards.OriginalHitboxes) do
                if player and player.Character then
                    for partName, originalSize in pairs(originalSizes) do
                        local part = player.Character:FindFirstChild(partName)
                        if part and part:IsA("BasePart") then
                            part.Size = originalSize
                            part.CanCollide = true
                        end
                    end
                end
            end
            MainModule.Guards.OriginalHitboxes = {}
        end)
    end
end

-- Dalgona функции
function MainModule.CompleteDalgona()
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

function MainModule.FreeLighter()
    LocalPlayer:SetAttribute("HasLighter", true)
end

-- Tug Of War функции
function MainModule.ToggleAutoPull(enabled)
    MainModule.TugOfWar.AutoPull = enabled
    
    if enabled then
        local autoPullConnection = RunService.Heartbeat:Connect(function()
            if MainModule.TugOfWar.AutoPull then
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
        
        table.insert(MainModule.ESPConnections, autoPullConnection)
    end
end

-- Misc функции
function MainModule.ToggleInstaInteract(enabled)
    MainModule.Misc.InstaInteract = enabled
    
    if enabled then
        local function makePromptInstant(prompt)
            if prompt:IsA("ProximityPrompt") then
                prompt.HoldDuration = 0
            end
        end

        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                makePromptInstant(obj)
            end
        end

        local instaInteractConnection = Workspace.DescendantAdded:Connect(function(obj)
            if obj:IsA("ProximityPrompt") then
                makePromptInstant(obj)
            end
        end)
        
        table.insert(MainModule.ESPConnections, instaInteractConnection)
    end
end

function MainModule.ToggleNoCooldownProximity(enabled)
    MainModule.Misc.NoCooldownProximity = enabled
    
    if enabled then
        for _, v in pairs(Workspace:GetDescendants()) do
            if v.ClassName == "ProximityPrompt" then
                v.HoldDuration = 0
            end
        end
        
        local noCooldownConnection = Workspace.DescendantAdded:Connect(function(obj)
            if MainModule.Misc.NoCooldownProximity then
                if obj:IsA("ProximityPrompt") then
                    obj.HoldDuration = 0
                end
            end
        end)
        
        table.insert(MainModule.ESPConnections, noCooldownConnection)
    end
end

-- Функция для получения координат
function MainModule.GetPlayerPosition()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local position = character.HumanoidRootPart.Position
        return string.format("X: %.1f, Y: %.1f, Z: %.1f", position.X, position.Y, position.Z)
    end
    return "Не доступно"
end

-- Очистка при закрытии
function MainModule.Cleanup()
    -- Очищаем все соединения
    for _, conn in pairs(MainModule.ESPConnections) do
        if conn and conn.Disconnect then
            pcall(function() conn:Disconnect() end)
        end
    end
    MainModule.ESPConnections = {}
    
    -- Очищаем HNS
    MainModule.HNS.KillAuraEnabled = false
    MainModule.HNS.KillSpikesEnabled = false
    MainModule.HNS.DisableSpikesEnabled = false
    MainModule.HNS.AutoDodgeEnabled = false
    
    if MainModule.HNS.KillAuraConnection then
        pcall(function() MainModule.HNS.KillAuraConnection:Disconnect() end)
        MainModule.HNS.KillAuraConnection = nil
    end
    
    if MainModule.HNS.KillSpikesConnection then
        pcall(function() MainModule.HNS.KillSpikesConnection:Disconnect() end)
        MainModule.HNS.KillSpikesConnection = nil
    end
    
    if MainModule.HNS.AutoDodgeConnection then
        pcall(function() MainModule.HNS.AutoDodgeConnection:Disconnect() end)
        MainModule.HNS.AutoDodgeConnection = nil
    end
    
    -- Очищаем RLGL
    if MainModule.RLGL.GodMode then
        MainModule.ToggleGodMode(false)
    end
    
    -- Восстанавливаем хитбоксы
    if MainModule.Guards.OriginalHitboxes then
        for player, originalSizes in pairs(MainModule.Guards.OriginalHitboxes) do
            if player and player.Character then
                for partName, originalSize in pairs(originalSizes) do
                    local part = player.Character:FindFirstChild(partName)
                    if part and part:IsA("BasePart") then
                        part.Size = originalSize
                        part.CanCollide = true
                    end
                end
            end
        end
        MainModule.Guards.OriginalHitboxes = {}
    end
    
    -- Восстанавливаем Infinite Ammo
    for obj, originalValue in pairs(MainModule.Guards.OriginalAmmo) do
        if obj and obj.Parent then
            obj.Value = originalValue
        end
    end
    MainModule.Guards.OriginalAmmo = {}
    
    -- Восстанавливаем Rapid Fire
    for obj, originalValue in pairs(MainModule.Guards.OriginalFireRates) do
        if obj and obj.Parent then
            obj.Value = originalValue
        end
    end
    MainModule.Guards.OriginalFireRates = {}
    
    -- Сбрасываем HNS состояния
    MainModule.HNS.TrackedHitboxes = {}
    MainModule.HNS.TrackedPlayers = {}
end

-- Автоматическая очистка при выходе
game:GetService("Players").LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not game:GetService("Players").LocalPlayer.Parent then
        MainModule.Cleanup()
    end
end)

return MainModule
