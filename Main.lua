-- Main.lua - Creon X v2.2 (Исправленная версия)
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
    GodModeTimeout = nil,
    LastDamageCheck = 0,
    DamageCheckRate = 0.5,
    TeleportOnDamage = false
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

-- HNS System (обновлено)
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
    DodgeRange = 10,
    
    SpikePositions = {},
    OriginalSpikeData = {}
}

-- Glass Bridge System (исправлено)
MainModule.GlassBridge = {
    GlassVisionEnabled = false,
    AntiFallEnabled = false,
    AntiBreakEnabled = false,
    GlassPlatformsEnabled = false,
    
    GlassPlatforms = {},
    AntiFallPlatform = nil,
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
    AntiFallPlatform = nil,
    JumpRopeConnection = nil
}

MainModule.SkySquid = {
    AntiFall = false,
    VoidKill = false,
    AntiFallPlatform = nil,
    SafePlatform = nil
}

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
    LastInjuredNotify = 0,
    LastESPUpdate = 0
}

-- ESP System
MainModule.ESPTable = {}
MainModule.ESPFolder = nil
MainModule.ESPUpdateRate = 0.5
MainModule.ESPCache = {}
MainModule.ESPConnection = nil
MainModule.PlayerESPConnections = {}

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
local bypassRagdollConnection = nil
local hnsKillAuraConnection = nil
local hnsKillSpikesConnection = nil
local hnsAutoDodgeConnection = nil
local jumpRopeConnection = nil

-- Локальный игрок
local LocalPlayer = Players.LocalPlayer

-- Вспомогательные функции
local function SafeDestroy(obj)
    if obj and obj.Parent then
        pcall(function() obj:Destroy() end)
    end
end

-- Функция для проверки, есть ли у игрока нож
local function playerHasKnife(player)
    if not player or not player.Character then return false end
    
    for _, tool in pairs(player.Character:GetChildren()) do
        if tool:IsA("Tool") then
            local toolName = tool.Name:lower()
            if toolName:find("knife") or toolName:find("fork") or toolName:find("dagger") or toolName:find("нож") then
                return true
            end
        end
    end
    
    if player:FindFirstChild("Backpack") then
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local toolName = tool.Name:lower()
                if toolName:find("knife") or toolName:find("fork") or toolName:find("dagger") or toolName:find("нож") then
                    return true
                end
            end
        end
    end
    
    return false
end

-- Bypass Ragdoll функция (оптимизированная версия)
function MainModule.ToggleBypassRagdoll(enabled)
    MainModule.Misc.BypassRagdollEnabled = enabled
    
    if bypassRagdollConnection then
        bypassRagdollConnection:Disconnect()
        bypassRagdollConnection = nil
    end
    
    local ragdollDestroyConnections = {}
    local childAddedConnections = {}
    
    if enabled then
        -- Оптимизация: проверяем реже (каждые 0.1 секунды вместо каждого кадра)
        local lastCheckTime = 0
        local checkInterval = 0.1
        
        bypassRagdollConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.Misc.BypassRagdollEnabled then return end
            
            local currentTime = tick()
            if currentTime - lastCheckTime < checkInterval then return end
            lastCheckTime = currentTime
            
            pcall(function()
                local Character = LocalPlayer.Character
                if not Character then return end
                
                local Humanoid = Character:FindFirstChild("Humanoid")
                local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                
                if not (Humanoid and HumanoidRootPart) then return end
                
                -- 1. Проверяем Ragdoll (только если есть изменения)
                local ragdoll = Character:FindFirstChild("Ragdoll")
                if ragdoll then
                    -- Быстрое удаление Ragdoll без анимации
                    task.spawn(function()
                        pcall(function() ragdoll:Destroy() end)
                        Humanoid.PlatformStand = false
                        Humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end)
                end
                
                -- 2. Проверяем только если игрок получил урон или состояние изменилось
                if Humanoid.Health < Humanoid.MaxHealth then
                    -- Минимальная защита: удаляем только очевидные силы толчка
                    local rootVelocity = HumanoidRootPart.Velocity
                    local horizontalSpeed = math.sqrt(rootVelocity.X * rootVelocity.X + rootVelocity.Z * rootVelocity.Z)
                    
                    -- Если скорость слишком высокая (возможно толчок)
                    if horizontalSpeed > 40 then
                        -- Сохраняем только вертикальную скорость для прыжков
                        HumanoidRootPart.Velocity = Vector3.new(0, rootVelocity.Y, 0)
                    end
                    
                    -- Быстрая проверка внешних сил
                    for _, force in pairs(HumanoidRootPart:GetChildren()) do
                        if force:IsA("BodyForce") or force:IsA("BodyVelocity") then
                            task.spawn(function()
                                pcall(function() force:Destroy() end)
                            end)
                        end
                    end
                end
            end)
        end)
        
        -- 3. Оптимизированный слушатель для ChildAdded (один раз на подключение)
        local function setupCharacterListeners(character)
            if not character then return end
            
            -- Слушатель для Ragdoll
            local ragdollListener = character.ChildAdded:Connect(function(child)
                if not MainModule.Misc.BypassRagdollEnabled then return end
                
                if child.Name == "Ragdoll" then
                    task.wait(0.05)  -- Минимальная задержка для анимации
                    pcall(function() child:Destroy() end)
                    
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid.PlatformStand = false
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end
            end)
            
            table.insert(ragdollDestroyConnections, ragdollListener)
            
            -- Слушатель для HumanoidRootPart сил
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local forceListener = rootPart.ChildAdded:Connect(function(child)
                    if not MainModule.Misc.BypassRagdollEnabled then return end
                    
                    if child:IsA("BodyForce") or child:IsA("BodyVelocity") then
                        task.wait(0.02)
                        pcall(function() child:Destroy() end)
                    end
                end)
                
                table.insert(ragdollDestroyConnections, forceListener)
            end
        end
        
        -- Настраиваем слушатели для текущего персонажа
        local currentChar = LocalPlayer.Character
        if currentChar then
            setupCharacterListeners(currentChar)
        end
        
        -- Слушатель для смены персонажа
        local characterListener = LocalPlayer.CharacterAdded:Connect(function(character)
            if MainModule.Misc.BypassRagdollEnabled then
                setupCharacterListeners(character)
            end
        end)
        
        table.insert(childAddedConnections, characterListener)
        
    else
        -- Очистка при выключении
        for _, conn in ipairs(ragdollDestroyConnections) do
            pcall(function() conn:Disconnect() end)
        end
        
        for _, conn in ipairs(childAddedConnections) do
            pcall(function() conn:Disconnect() end)
        end
        
        ragdollDestroyConnections = {}
        childAddedConnections = {}
    end
end

-- HNS System функции (исправлено)

-- Kill Aura (автоматическое убийство хайдеров)
function MainModule.ToggleKillAura(enabled)
    MainModule.HNS.KillAuraEnabled = enabled
    
    if hnsKillAuraConnection then
        hnsKillAuraConnection:Disconnect()
        hnsKillAuraConnection = nil
    end
    
    if enabled then
        hnsKillAuraConnection = RunService.RenderStepped:Connect(function()
            if not MainModule.HNS.KillAuraEnabled then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                local HRP = character.HumanoidRootPart
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if not humanoid or humanoid.Health <= 0 then return end
                
                local targetPlayer = nil
                local closestDistance = math.huge
                
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") 
                       and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 
                       and player:GetAttribute("IsHider") then
                        
                        local distance = (HRP.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        if distance < closestDistance then
                            closestDistance = distance
                            targetPlayer = player
                        end
                    end
                end
                
                if targetPlayer and targetPlayer.Character then
                    local targetTorso = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                        or targetPlayer.Character:FindFirstChild("UpperTorso")
                        or targetPlayer.Character:FindFirstChild("Torso")
                    
                    if targetTorso then
                        -- Телепортируемся перед целью
                        local frontPos = targetTorso.CFrame * CFrame.new(0, 0, -2)
                        HRP.CFrame = frontPos
                        
                        -- Поворачиваемся к цели
                        local direction = (targetTorso.Position - HRP.Position).Unit
                        local lookVector = Vector3.new(direction.X, 0, direction.Z)
                        if lookVector.Magnitude > 0 then
                            HRP.CFrame = CFrame.new(HRP.Position, HRP.Position + lookVector)
                        end
                    end
                end
            end)
        end)
    end
end

-- Kill Spikes (телепортация хайдеров к шипам)
function MainModule.ToggleKillSpikes(enabled)
    MainModule.HNS.KillSpikesEnabled = enabled
    
    if hnsKillSpikesConnection then
        hnsKillSpikesConnection:Disconnect()
        hnsKillSpikesConnection = nil
    end
    
    if enabled then
        -- Собираем позиции шипов
        pcall(function()
            MainModule.HNS.SpikePositions = {}
            
            local spikes = Workspace:FindFirstChild("HideAndSeekMap") and 
                          Workspace.HideAndSeekMap:FindFirstChild("KillingParts")
            
            if spikes then
                for _, spike in pairs(spikes:GetChildren()) do
                    if spike:IsA("BasePart") then
                        table.insert(MainModule.HNS.SpikePositions, spike.Position)
                    end
                end
            end
        end)
        
        hnsKillSpikesConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.KillSpikesEnabled then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                local HRP = character.HumanoidRootPart
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if not humanoid or humanoid.Health <= 0 then return end
                
                -- Проверяем, держим ли мы нож
                local hasKnife = false
                local knifeTool = nil
                
                for _, tool in pairs(character:GetChildren()) do
                    if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("dagger") or tool.Name:lower():find("fork") or tool.Name:lower():find("нож")) then
                        hasKnife = true
                        knifeTool = tool
                        break
                    end
                end
                
                if not hasKnife and LocalPlayer:FindFirstChild("Backpack") then
                    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                        if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("dagger") or tool.Name:lower():find("fork") or tool.Name:lower():find("нож")) then
                            hasKnife = true
                            knifeTool = tool
                            break
                        end
                    end
                end
                
                if not hasKnife then return end
                
                -- Ищем ближайшего хайдера
                local nearestHider = nil
                local nearestDistance = math.huge
                local targetRootPart = nil
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local targetCharacter = player.Character
                        local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
                        local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
                        
                        if targetRoot and targetHumanoid and targetHumanoid.Health > 0 and player:GetAttribute("IsHider") then
                            local distance = (HRP.Position - targetRoot.Position).Magnitude
                            
                            if distance < nearestDistance and distance < 50 then
                                nearestDistance = distance
                                nearestHider = player
                                targetRootPart = targetRoot
                            end
                        end
                    end
                end
                
                if nearestHider and targetRootPart and #MainModule.HNS.SpikePositions > 0 then
                    -- Сохраняем позицию для возврата
                    local originalPosition = HRP.CFrame
                    
                    -- Телепортируемся к цели
                    local teleportCFrame = targetRootPart.CFrame * CFrame.new(0, 0, -2)
                    HRP.CFrame = teleportCFrame
                    
                    -- Атакуем
                    if knifeTool then
                        local remoteEvent = knifeTool:FindFirstChild("RemoteEvent")
                        if remoteEvent then
                            remoteEvent:FireServer()
                        end
                    end
                    
                    task.wait(0.3)
                    
                    -- Телепортируем цель к случайным шипам
                    local randomSpike = MainModule.HNS.SpikePositions[math.random(1, #MainModule.HNS.SpikePositions)]
                    targetRootPart.CFrame = CFrame.new(randomSpike)
                    
                    -- Ждем 4 секунды
                    task.wait(4)
                    
                    -- Возвращаемся на оригинальную позицию
                    HRP.CFrame = originalPosition
                end
            end)
        end)
    end
end

-- Disable/Remove Spikes
function MainModule.ToggleDisableSpikes(enabled)
    MainModule.HNS.DisableSpikesEnabled = enabled
    
    if enabled then
        pcall(function()
            local spikes = Workspace:FindFirstChild("HideAndSeekMap") and 
                          Workspace.HideAndSeekMap:FindFirstChild("KillingParts")
            
            if spikes then
                for _, spike in pairs(spikes:GetChildren()) do
                    if spike:IsA("BasePart") then
                        MainModule.HNS.OriginalSpikeData[spike] = {
                            Transparency = spike.Transparency,
                            CanTouch = spike.CanTouch
                        }
                        spike.Transparency = 1
                        spike.CanTouch = false
                    end
                end
            end
        end)
    else
        pcall(function()
            local spikes = Workspace:FindFirstChild("HideAndSeekMap") and 
                          Workspace.HideAndSeekMap:FindFirstChild("KillingParts")
            
            if spikes then
                for spike, data in pairs(MainModule.HNS.OriginalSpikeData) do
                    if spike and spike.Parent then
                        spike.Transparency = data.Transparency
                        spike.CanTouch = data.CanTouch
                    end
                end
                MainModule.HNS.OriginalSpikeData = {}
            end
        end)
    end
end

-- Teleport to Hider
function MainModule.TeleportToHider()
    pcall(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player:GetAttribute("IsHider") and 
               player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                    return
                end
            end
        end
    end)
end

-- Auto Dodge функция (исправлено)
function MainModule.ToggleAutoDodge(enabled)
    MainModule.HNS.AutoDodgeEnabled = enabled
    
    if hnsAutoDodgeConnection then
        hnsAutoDodgeConnection:Disconnect()
        hnsAutoDodgeConnection = nil
    end
    
    if enabled then
        -- Создаем хитбокс для детекции
        local dodgeHitbox = Instance.new("Part")
        dodgeHitbox.Name = "AutoDodgeHitbox"
        dodgeHitbox.Size = Vector3.new(MainModule.HNS.DodgeRange * 2, 10, MainModule.HNS.DodgeRange * 2)
        dodgeHitbox.CFrame = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
                             LocalPlayer.Character.HumanoidRootPart.CFrame or CFrame.new(0, 0, 0)
        dodgeHitbox.Anchored = true
        dodgeHitbox.CanCollide = false
        dodgeHitbox.Transparency = 1
        dodgeHitbox.Parent = Workspace
        
        hnsAutoDodgeConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.AutoDodgeEnabled then return end
            
            local currentTime = tick()
            if currentTime - MainModule.HNS.LastDodgeTime < MainModule.HNS.DodgeCooldown then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                
                if not rootPart or not humanoid or humanoid.Health <= 0 then return end
                
                -- Обновляем позицию хитбокса
                dodgeHitbox.CFrame = rootPart.CFrame
                
                -- Проверяем, вошел ли в хитбокс игрок с ножом
                local shouldDodge = false
                local knifePlayer = nil
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local targetCharacter = player.Character
                        local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
                        
                        if targetRoot and playerHasKnife(player) then
                            -- Проверяем, находится ли игрок в хитбоксе
                            local distance = (rootPart.Position - targetRoot.Position).Magnitude
                            if distance <= MainModule.HNS.DodgeRange then
                                shouldDodge = true
                                knifePlayer = player
                                break
                            end
                        end
                    end
                end
                
                -- Дополнительно проверяем создание нового хитбокса
                for _, part in pairs(Workspace:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "AutoDodgeHitbox" then
                        local distance = (rootPart.Position - part.Position).Magnitude
                        if distance <= MainModule.HNS.DodgeRange then
                            shouldDodge = true
                            break
                        end
                    end
                end
                
                if shouldDodge then
                    -- Используем слот 1 для доджа
                    if UserInputService.TouchEnabled then
                        -- Для мобильных: симулируем нажатие на слот 1
                        pcall(function()
                            local backpack = LocalPlayer:FindFirstChild("Backpack")
                            if backpack then
                                local tool = backpack:FindFirstChildOfClass("Tool")
                                if tool then
                                    tool.Parent = character
                                    task.wait(0.1)
                                    tool.Parent = backpack
                                end
                            end
                        end)
                    else
                        -- Для ПК: нажимаем клавишу 1
                        pcall(function()
                            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.One, false, game)
                            task.wait(0.05)
                            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.One, false, game)
                        end)
                    end
                    
                    MainModule.HNS.LastDodgeTime = tick()
                    
                    -- Визуальная обратная связь
                    local feedback = Instance.new("Part")
                    feedback.Size = Vector3.new(5, 0.2, 5)
                    feedback.Position = rootPart.Position - Vector3.new(0, 3, 0)
                    feedback.Color = Color3.fromRGB(255, 255, 0)
                    feedback.Material = Enum.Material.Neon
                    feedback.Anchored = true
                    feedback.CanCollide = false
                    feedback.Transparency = 0.7
                    feedback.Parent = Workspace
                    
                    game:GetService("Debris"):AddItem(feedback, 0.3)
                end
            end)
        end)
        
        -- Очистка хитбокса при выключении
        game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
            SafeDestroy(dodgeHitbox)
        end)
    else
        -- Удаляем хитбокс
        local hitbox = Workspace:FindFirstChild("AutoDodgeHitbox")
        if hitbox then
            SafeDestroy(hitbox)
        end
    end
end

-- Glass Bridge System функции (исправлено)

-- Glass Vision (показывает настоящие/фейковые стекла)
function MainModule.ToggleGlassVision(enabled)
    MainModule.GlassBridge.GlassVisionEnabled = enabled
    
    local function updateGlassColors()
        pcall(function()
            for _, part in ipairs(Workspace:GetDescendants()) do
                if part:IsA("BasePart") and part:GetAttribute("GlassPart") then
                    if enabled then
                        if part:GetAttribute("ActuallyKilling") ~= nil then
                            part.Color = Color3.fromRGB(255, 0, 0)  -- Фейковое стекло
                        else
                            part.Color = Color3.fromRGB(0, 255, 0)  -- Настоящее стекло
                        end
                        part.Material = Enum.Material.Neon
                        part.Transparency = 0.3
                    else
                        part.Color = Color3.fromRGB(163, 162, 165)
                        part.Material = Enum.Material.Glass
                        part.Transparency = 0
                    end
                end
            end
        end)
    end
    
    if enabled then
        updateGlassColors()
        MainModule.GlassBridge.GlassVisionConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.GlassBridge.GlassVisionEnabled then return end
            updateGlassColors()
        end)
    else
        if MainModule.GlassBridge.GlassVisionConnection then
            MainModule.GlassBridge.GlassVisionConnection:Disconnect()
            MainModule.GlassBridge.GlassVisionConnection = nil
        end
        updateGlassColors()
    end
end

-- Anti Break (предотвращает поломку стекла)
function MainModule.ToggleAntiBreak(enabled)
    MainModule.GlassBridge.AntiBreakEnabled = enabled
    
    if MainModule.GlassBridge.AntiBreakConnection then
        MainModule.GlassBridge.AntiBreakConnection:Disconnect()
        MainModule.GlassBridge.AntiBreakConnection = nil
    end
    
    if enabled then
        -- Создаем невидимые платформы под фейковыми стеклами
        MainModule.CreateGlassBridgePlatforms()
        
        MainModule.GlassBridge.AntiBreakConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.GlassBridge.AntiBreakEnabled then return end
            
            pcall(function()
                local GlassHolder = Workspace:FindFirstChild("GlassBridge") and Workspace.GlassBridge:FindFirstChild("GlassHolder")
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
    else
        -- Удаляем платформы
        MainModule.RemoveGlassBridgePlatforms()
    end
end

-- Создание платформ на фейковых стеклах (исправлено)
function MainModule.CreateGlassBridgePlatforms()
    MainModule.RemoveGlassBridgePlatforms()
    
    pcall(function()
        local glassBridge = Workspace:FindFirstChild("GlassBridge")
        if not glassBridge then return end
        
        local glassHolder = glassBridge:FindFirstChild("GlassHolder")
        if not glassHolder then return end
        
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and part:GetAttribute("GlassPart") and 
               part:GetAttribute("ActuallyKilling") ~= nil then
                
                local platform = Instance.new("Part")
                platform.Name = "GlassBridgePlatform"
                platform.Size = Vector3.new(9, 0.1, 9)
                platform.CFrame = part.CFrame * CFrame.new(0, -1.5, 0)
                platform.Anchored = true
                platform.CanCollide = true
                platform.Transparency = 0.8  -- Полупрозрачный как стекло
                platform.Material = Enum.Material.Glass
                platform.Color = Color3.fromRGB(255, 255, 255)
                platform.Parent = Workspace
                
                table.insert(MainModule.GlassBridge.GlassPlatforms, platform)
            end
        end
    end)
end

function MainModule.RemoveGlassBridgePlatforms()
    for _, platform in ipairs(MainModule.GlassBridge.GlassPlatforms) do
        SafeDestroy(platform)
    end
    MainModule.GlassBridge.GlassPlatforms = {}
end

-- Anti Fall защита (исправлено)
function MainModule.ToggleAntiFall(enabled)
    MainModule.GlassBridge.AntiFallEnabled = enabled
    
    if MainModule.GlassBridge.AntiFallConnection then
        MainModule.GlassBridge.AntiFallConnection:Disconnect()
        MainModule.GlassBridge.AntiFallConnection = nil
    end
    
    if enabled then
        -- Создаем Anti-Fall платформу как стекло
        MainModule.CreateGlassBridgeAntiFallPlatform()
        
        MainModule.GlassBridge.AntiFallConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.GlassBridge.AntiFallEnabled then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                
                if not rootPart or not humanoid or humanoid.Health <= 0 then return end
                
                -- Проверяем падение ниже безопасной высоты
                if rootPart.Position.Y < MainModule.GlassBridge.SafeHeight then
                    -- Телепортируем к концу моста
                    rootPart.CFrame = CFrame.new(MainModule.GlassBridge.EndPosition)
                    
                    -- Эффект телепортации
                    local effect = Instance.new("Part")
                    effect.Size = Vector3.new(6, 0.1, 6)
                    effect.Position = rootPart.Position - Vector3.new(0, 3, 0)
                    effect.Color = Color3.fromRGB(0, 255, 0)
                    effect.Material = Enum.Material.Neon
                    effect.Anchored = true
                    effect.CanCollide = false
                    effect.Transparency = 0.5
                    effect.Parent = Workspace
                    
                    game:GetService("Debris"):AddItem(effect, 0.5)
                end
            end)
        end)
    else
        MainModule.RemoveGlassBridgeAntiFallPlatform()
    end
end

-- Создание Anti-Fall платформы (как стекло)
function MainModule.CreateGlassBridgeAntiFallPlatform()
    MainModule.RemoveGlassBridgeAntiFallPlatform()
    
    pcall(function()
        MainModule.GlassBridge.AntiFallPlatform = Instance.new("Part")
        MainModule.GlassBridge.AntiFallPlatform.Name = "GlassBridgeAntiFallPlatform"
        MainModule.GlassBridge.AntiFallPlatform.Size = Vector3.new(400, 2, 50)
        MainModule.GlassBridge.AntiFallPlatform.Position = Vector3.new(-200, MainModule.GlassBridge.SafeHeight - 10, -1534)
        MainModule.GlassBridge.AntiFallPlatform.Anchored = true
        MainModule.GlassBridge.AntiFallPlatform.CanCollide = true
        MainModule.GlassBridge.AntiFallPlatform.Transparency = 0.7  -- Как стекло
        MainModule.GlassBridge.AntiFallPlatform.Material = Enum.Material.Glass
        MainModule.GlassBridge.AntiFallPlatform.Color = Color3.fromRGB(200, 200, 255)
        MainModule.GlassBridge.AntiFallPlatform.Parent = Workspace
    end)
end

function MainModule.RemoveGlassBridgeAntiFallPlatform()
    if MainModule.GlassBridge.AntiFallPlatform then
        SafeDestroy(MainModule.GlassBridge.AntiFallPlatform)
        MainModule.GlassBridge.AntiFallPlatform = nil
    end
end

-- Teleport to End
function MainModule.TeleportToGlassBridgeEnd()
    pcall(function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(MainModule.GlassBridge.EndPosition)
        end
    end)
end

-- Функции скорости
function MainModule.ToggleSpeedHack(enabled)
    MainModule.SpeedHack.Enabled = enabled
    local player = LocalPlayer
    
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
        
        speedConnection = RunService.Heartbeat:Connect(function()
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
    
    if antiStunConnection then
        antiStunConnection:Disconnect()
        antiStunConnection = nil
    end
    
    if enabled then
        antiStunConnection = RunService.Heartbeat:Connect(function()
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
    end
end

-- Instant Rebel функция (исправлено)
function MainModule.ToggleRebel(enabled)
    MainModule.Rebel.Enabled = enabled
    
    if enabled then
        -- Простая функция Instant Rebel
        _G.InstantRebel = true
        
        task.spawn(function()
            while _G.InstantRebel and MainModule.Rebel.Enabled do
                pcall(function()
                    local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlayableGuardRemote")
                    local args = {
                        {
                            AttemptToSpawnAsGuard = "Rebel"
                        }
                    }
                    remote:FireServer(unpack(args))
                end)
                task.wait(0.1)
            end
            _G.InstantRebel = nil
        end)
    else
        _G.InstantRebel = nil
    end
end

-- RLGL функции (исправлено)
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

function MainModule.ToggleGodMode(enabled)
    MainModule.RLGL.GodMode = enabled
    MainModule.RLGL.TeleportOnDamage = false
    
    if godModeConnection then
        godModeConnection:Disconnect()
        godModeConnection = nil
        if MainModule.RLGL.GodModeTimeout then
            MainModule.RLGL.GodModeTimeout:Disconnect()
            MainModule.RLGL.GodModeTimeout = nil
        end
    end
    
    if enabled then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            MainModule.RLGL.OriginalHeight = character.HumanoidRootPart.Position.Y
            -- Поднимаемся на высоту GodMode
            local currentPos = character.HumanoidRootPart.Position
            character.HumanoidRootPart.CFrame = CFrame.new(currentPos.X, 1184.9, currentPos.Z)
        end
        
        godModeConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.RLGL.GodMode then return end
            
            local currentTime = tick()
            if currentTime - MainModule.RLGL.LastDamageCheck < MainModule.RLGL.DamageCheckRate then return end
            MainModule.RLGL.LastDamageCheck = currentTime
            
            local character = LocalPlayer.Character
            if not character then return end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            
            -- Проверяем, получили ли мы урон
            if humanoid.Health < humanoid.MaxHealth then
                -- Запоминаем, что нужно отключить GodMode
                MainModule.RLGL.TeleportOnDamage = true
                
                -- Телепортируем на указанные координаты
                character.HumanoidRootPart.CFrame = CFrame.new(-856, 1184, -550)
                humanoid.Health = humanoid.MaxHealth
                
                -- Отключаем GodMode
                task.wait(0.5)
                MainModule.ToggleGodMode(false)
            else
                -- Поддерживаем высоту GodMode
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart and rootPart.Position.Y < 1100 then
                    local currentPos = rootPart.Position
                    rootPart.CFrame = CFrame.new(currentPos.X, 1184.9, currentPos.Z)
                end
            end
        end)
    else
        -- Только если это не выключение из-за урона
        if not MainModule.RLGL.TeleportOnDamage then
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") and MainModule.RLGL.OriginalHeight then
                local currentPos = character.HumanoidRootPart.Position
                character.HumanoidRootPart.CFrame = CFrame.new(currentPos.X, MainModule.RLGL.OriginalHeight, currentPos.Z)
            end
        end
        MainModule.RLGL.TeleportOnDamage = false
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
    
    if autoFarmConnection then
        autoFarmConnection:Disconnect()
        autoFarmConnection = nil
    end
    
    if enabled then
        autoFarmConnection = RunService.Heartbeat:Connect(function()
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
        rapidFireConnection = RunService.Heartbeat:Connect(function()
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
    
    if infiniteAmmoConnection then
        infiniteAmmoConnection:Disconnect()
        infiniteAmmoConnection = nil
    end
    
    if enabled then
        infiniteAmmoConnection = RunService.Heartbeat:Connect(function()
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

-- Hitbox Expander функция (исправлено - убран Z-Index)
function MainModule.ToggleHitboxExpander(enabled)
    MainModule.Guards.HitboxExpander = enabled
    
    if hitboxConnection then
        hitboxConnection:Disconnect()
        hitboxConnection = nil
    end
    
    if enabled then
        local HITBOX_SIZE = 10
        
        hitboxConnection = RunService.Stepped:Connect(function()
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
    
    if autoPullConnection then
        autoPullConnection:Disconnect()
        autoPullConnection = nil
    end
    
    if enabled then
        autoPullConnection = RunService.Heartbeat:Connect(function()
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
    end
end

-- Jump Rope функции (исправлено)
function MainModule.ToggleDeleteRope(enabled)
    MainModule.JumpRope.DeleteRope = enabled
    
    if enabled then
        -- Функция удаления веревки
        local function deleteRope()
            pcall(function()
                local rope = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("rope")
                if rope then
                    rope:Destroy()
                    print("Jump Rope deleted successfully")
                else
                    -- Альтернативный поиск
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj.Name:lower() == "rope" or obj.Name:lower():find("jump") then
                            obj:Destroy()
                            print("Found and deleted rope object")
                            break
                        end
                    end
                end
            end)
        end
        
        -- Немедленно удаляем веревку
        deleteRope()
        
        -- Устанавливаем соединение для постоянного удаления
        if MainModule.JumpRope.JumpRopeConnection then
            MainModule.JumpRope.JumpRopeConnection:Disconnect()
        end
        
        MainModule.JumpRope.JumpRopeConnection = RunService.Heartbeat:Connect(function()
            if MainModule.JumpRope.DeleteRope then
                deleteRope()
            end
        end)
    else
        if MainModule.JumpRope.JumpRopeConnection then
            MainModule.JumpRope.JumpRopeConnection:Disconnect()
            MainModule.JumpRope.JumpRopeConnection = nil
        end
    end
end

function MainModule.TeleportToJumpRopeEnd()
    pcall(function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(720.896057, 198.628311, 921.170654)
            print("Teleported to Jump Rope end position")
        end
    end)
end

function MainModule.TeleportToJumpRopeStart()
    pcall(function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(615.284424, 192.274277, 920.952515)
            print("Teleported to Jump Rope start position")
        end
    end)
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

        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                makePromptInstant(obj)
            end
        end

        instaInteractConnection = Workspace.DescendantAdded:Connect(function(obj)
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
        for _, v in pairs(Workspace:GetDescendants()) do
            if v.ClassName == "ProximityPrompt" then
                v.HoldDuration = 0
            end
        end
        
        noCooldownConnection = Workspace.DescendantAdded:Connect(function(obj)
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
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local position = character.HumanoidRootPart.Position
        return string.format("X: %.1f, Y: %.1f, Z: %.1f", position.X, position.Y, position.Z)
    end
    return "Не доступно"
end

-- Очистка при закрытии
function MainModule.Cleanup()
    local connections = {
        speedConnection, autoFarmConnection, godModeConnection, instaInteractConnection,
        noCooldownConnection, antiStunConnection, rapidFireConnection, infiniteAmmoConnection,
        hitboxConnection, autoPullConnection, bypassRagdollConnection,
        hnsKillAuraConnection, hnsKillSpikesConnection, hnsAutoDodgeConnection,
        MainModule.GlassBridge.AntiFallConnection, MainModule.GlassBridge.AntiBreakConnection,
        MainModule.GlassBridge.GlassVisionConnection, MainModule.JumpRope.JumpRopeConnection
    }
    
    for _, conn in pairs(connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    
    -- Очищаем HNS
    MainModule.HNS.KillAuraEnabled = false
    MainModule.HNS.KillSpikesEnabled = false
    MainModule.HNS.DisableSpikesEnabled = false
    MainModule.HNS.AutoDodgeEnabled = false
    
    -- Очищаем Glass Bridge
    MainModule.RemoveGlassBridgePlatforms()
    MainModule.RemoveGlassBridgeAntiFallPlatform()
    
    -- Очищаем хитбокс AutoDodge
    local dodgeHitbox = Workspace:FindFirstChild("AutoDodgeHitbox")
    if dodgeHitbox then
        SafeDestroy(dodgeHitbox)
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
    
    -- Восстанавливаем шипы
    MainModule.ToggleDisableSpikes(false)
end

-- Автоматическая очистка при выходе
game:GetService("Players").LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not game:GetService("Players").LocalPlayer.Parent then
        MainModule.Cleanup()
    end
end)

return MainModule



