-- Main.lua - Creon X v2.3 (Полностью исправленная версия)
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
local VirtualInputManager = game:GetService("VirtualInputManager")

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
    DamageCheckRate = 0.1,
    TeleportOnDamage = false,
    OriginalPosition = nil
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
    OriginalSpikeData = {},
    
    -- Новые переменные для Kill Hiders
    TargetLocked = false,
    CurrentHider = nil,
    KillHidersRadius = 300,
    FollowingOffset = Vector3.new(0, 0, -3),
    StaticAttachment = false
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
MainModule.ESPUpdateRate = 0.05  -- Уменьшен для лучшей производительности
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
local hnsKillHidersConnection = nil

-- Локальный игрок
local LocalPlayer = Players.LocalPlayer
local Character = nil
local Humanoid = nil
local HumanoidRootPart = nil

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

-- Функция для выполнения Dodge
local function PerformDodge()
    if UserInputService.TouchEnabled then
        -- Для мобильных: симулируем нажатие на слот 1
        pcall(function()
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            local character = LocalPlayer.Character
            if backpack and character then
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
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)
        end)
    end
end

-- Bypass Ragdoll функция с улучшенной защитой
function MainModule.ToggleBypassRagdoll(enabled)
    MainModule.Misc.BypassRagdollEnabled = enabled
    
    if bypassRagdollConnection then
        bypassRagdollConnection:Disconnect()
        bypassRagdollConnection = nil
    end
    
    if enabled then
        bypassRagdollConnection = RunService.Stepped:Connect(function()
            if not MainModule.Misc.BypassRagdollEnabled then return end
            
            pcall(function()
                local Character = LocalPlayer.Character
                if not Character then return end
                
                local Humanoid = Character:FindFirstChild("Humanoid")
                local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                local Torso = Character:FindFirstChild("UpperTorso") or Character:FindFirstChild("Torso")
                
                if not (Humanoid and HumanoidRootPart and Torso) then return end

                -- Мягкое удаление Ragdoll объектов
                for _, child in ipairs(Character:GetChildren()) do
                    if child.Name == "Ragdoll" then
                        task.spawn(function()
                            for i = 1, 10 do
                                if child and child.Parent then
                                    for _, part in pairs(child:GetChildren()) do
                                        if part:IsA("BasePart") then
                                            part.Transparency = part.Transparency + 0.1
                                        end
                                    end
                                    task.wait(0.05)
                                end
                            end
                            pcall(function() child:Destroy() end)
                        end)
                        
                        Humanoid.PlatformStand = false
                        Humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end

                -- Удаляем только вредоносные папки
                local harmfulFolders = {"RotateDisabled", "RagdollWakeupImmunity"}
                for _, folderName in pairs(harmfulFolders) do
                    local folder = Character:FindFirstChild(folderName)
                    if folder then
                        folder:Destroy()
                    end
                end

                -- Основная защита от толчков
                for _, part in pairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        local currentVelocity = part.Velocity
                        local horizontalSpeed = Vector3.new(currentVelocity.X, 0, currentVelocity.Z).Magnitude
                        
                        if horizontalSpeed > 50 and part ~= HumanoidRootPart then
                            local newVelocity = Vector3.new(
                                currentVelocity.X * 0.8,
                                currentVelocity.Y,
                                currentVelocity.Z * 0.8
                            )
                            part.Velocity = newVelocity
                        end
                        
                        for _, force in pairs(part:GetChildren()) do
                            if force:IsA("BodyForce") then
                                local forceMagnitude = force.Force.Magnitude
                                if forceMagnitude > 1000 then
                                    force:Destroy()
                                end
                            elseif force:IsA("BodyVelocity") then
                                if force.Velocity.Magnitude > 30 then
                                    force:Destroy()
                                end
                            end
                        end
                    end
                end
                
                -- Защита корневого объекта
                local playerInputVelocity = HumanoidRootPart.Velocity
                local externalForces = {}
                
                for _, force in pairs(HumanoidRootPart:GetChildren()) do
                    if force:IsA("BodyForce") or force:IsA("BodyVelocity") then
                        table.insert(externalForces, force)
                    end
                end
                
                if #externalForces > 0 then
                    local filteredVelocity = Vector3.new(
                        playerInputVelocity.X,
                        HumanoidRootPart.Velocity.Y,
                        playerInputVelocity.Z
                    )
                    
                    HumanoidRootPart.Velocity = filteredVelocity
                    
                    for _, force in pairs(externalForces) do
                        task.spawn(function()
                            if force:IsA("BodyVelocity") then
                                for i = 1, 5 do
                                    if force and force.Parent then
                                        force.Velocity = force.Velocity * 0.5
                                        task.wait(0.02)
                                    end
                                end
                            end
                            pcall(function() force:Destroy() end)
                        end)
                    end
                end
            end)
        end)
        
        -- Слушатель для мгновенного удаления новых Ragdoll объектов
        local char = LocalPlayer.Character
        if char then
            char.ChildAdded:Connect(function(child)
                if child.Name == "Ragdoll" and MainModule.Misc.BypassRagdollEnabled then
                    task.wait(0.1)
                    pcall(function() child:Destroy() end)
                    
                    local humanoid = char:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid.PlatformStand = false
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end
            end)
        end
    else
        -- Очистка при выключении
        local character = LocalPlayer.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                for _, conn in pairs(getconnections(rootPart.ChildAdded)) do
                    conn:Disconnect()
                end
            end
        end
    end
end

-- Auto Dodge функция (новая версия)
function MainModule.ToggleAutoDodge(enabled)
    MainModule.HNS.AutoDodgeEnabled = enabled
    
    if hnsAutoDodgeConnection then
        hnsAutoDodgeConnection:Disconnect()
        hnsAutoDodgeConnection = nil
    end
    
    if enabled then
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
                
                -- Проверяем, есть ли у нас нож
                local hasKnife = playerHasKnife(LocalPlayer)
                if not hasKnife then return end
                
                -- Проверяем физические воздействия
                local shouldDodge = false
                
                -- Проверяем BodyForces и BodyVelocity
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        for _, force in pairs(part:GetChildren()) do
                            if force:IsA("BodyForce") then
                                local forceMagnitude = force.Force.Magnitude
                                if forceMagnitude > 500 then
                                    shouldDodge = true
                                    break
                                end
                            elseif force:IsA("BodyVelocity") then
                                if force.Velocity.Magnitude > 20 then
                                    shouldDodge = true
                                    break
                                end
                            elseif force:IsA("BodyThrust") or force:IsA("BodyAngularVelocity") then
                                shouldDodge = true
                                break
                            end
                        end
                        if shouldDodge then break end
                    end
                end
                
                -- Проверяем высокую скорость (возможно от толчка)
                if not shouldDodge and rootPart.Velocity.Magnitude > 50 then
                    shouldDodge = true
                end
                
                if shouldDodge then
                    PerformDodge()
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
    end
end

-- HNS Kill Hiders функция (исправлено)
function MainModule.ToggleKillHiders(enabled)
    MainModule.HNS.KillAuraEnabled = enabled
    MainModule.HNS.TargetLocked = false
    MainModule.HNS.CurrentHider = nil
    
    if hnsKillHidersConnection then
        hnsKillHidersConnection:Disconnect()
        hnsKillHidersConnection = nil
    end
    
    -- Отключаем шипы при включении
    if enabled then
        MainModule.ToggleDisableSpikes(true)
    else
        MainModule.ToggleDisableSpikes(false)
    end
    
    if enabled then
        hnsKillHidersConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.KillAuraEnabled then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                local HRP = character.HumanoidRootPart
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if not humanoid or humanoid.Health <= 0 then return end
                
                -- Проверяем текущую цель
                if MainModule.HNS.TargetLocked and MainModule.HNS.CurrentHider then
                    local targetPlayer = MainModule.HNS.CurrentHider
                    
                    -- Проверяем, жива ли цель
                    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") 
                       and targetPlayer.Character:FindFirstChildOfClass("Humanoid") and targetPlayer.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                        
                        local targetHRP = targetPlayer.Character.HumanoidRootPart
                        
                        -- Телепортируемся к цели (статично спереди)
                        local targetCFrame = targetHRP.CFrame
                        local offsetPosition = targetCFrame.Position + (targetCFrame.LookVector * MainModule.HNS.FollowingOffset.Z)
                        offsetPosition = Vector3.new(offsetPosition.X, targetHRP.Position.Y, offsetPosition.Z)
                        
                        -- Сохраняем вертикальную позицию
                        local currentY = HRP.Position.Y
                        local newPosition = Vector3.new(offsetPosition.X, currentY, offsetPosition.Z)
                        
                        -- Мгновенная телепортация без анимации
                        HRP.CFrame = CFrame.new(newPosition, targetHRP.Position)
                        
                        -- Поворачиваемся к цели
                        local lookDirection = (targetHRP.Position - newPosition).Unit
                        if lookDirection.Magnitude > 0 then
                            HRP.CFrame = CFrame.new(newPosition, newPosition + lookDirection)
                        end
                        
                        return
                    else
                        -- Цель мертва или не существует, сбрасываем
                        MainModule.HNS.TargetLocked = false
                        MainModule.HNS.CurrentHider = nil
                    end
                end
                
                -- Поиск новой цели
                local nearestHider = nil
                local nearestDistance = math.huge
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local targetCharacter = player.Character
                        local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
                        local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
                        
                        if targetRoot and targetHumanoid and targetHumanoid.Health > 0 and player:GetAttribute("IsHider") then
                            local distance = (HRP.Position - targetRoot.Position).Magnitude
                            
                            if distance < MainModule.HNS.KillHidersRadius and distance < nearestDistance then
                                nearestDistance = distance
                                nearestHider = player
                            end
                        end
                    end
                end
                
                -- Блокируем новую цель
                if nearestHider then
                    MainModule.HNS.TargetLocked = true
                    MainModule.HNS.CurrentHider = nearestHider
                    
                    -- Немедленная телепортация к новой цели
                    local targetHRP = nearestHider.Character.HumanoidRootPart
                    local targetCFrame = targetHRP.CFrame
                    local offsetPosition = targetCFrame.Position + (targetCFrame.LookVector * MainModule.HNS.FollowingOffset.Z)
                    offsetPosition = Vector3.new(offsetPosition.X, HRP.Position.Y, offsetPosition.Z)
                    
                    HRP.CFrame = CFrame.new(offsetPosition, targetHRP.Position)
                end
            end)
        end)
    end
end

-- Kill Spikes функция
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

-- RLGL GodMode функция (исправлено)
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
            MainModule.RLGL.OriginalPosition = character.HumanoidRootPart.CFrame
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
            
            -- Проверяем, получили ли мы урон (в режиме GodMode)
            if humanoid.Health < humanoid.MaxHealth then
                -- Запоминаем, что нужно отключить GodMode
                MainModule.RLGL.TeleportOnDamage = true
                
                -- Телепортируем на указанные координаты
                character.HumanoidRootPart.CFrame = CFrame.new(186.7, 54.3, -100.6)
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

-- ESP System (исправлено)
function MainModule.ToggleESP(enabled)
    MainModule.Misc.ESPEnabled = enabled
    
    if MainModule.ESPConnection then
        MainModule.ESPConnection:Disconnect()
        MainModule.ESPConnection = nil
    end
    
    -- Очищаем существующий ESP
    for _, esp in pairs(MainModule.ESPTable) do
        if esp.Destroy then
            pcall(esp.Destroy)
        end
    end
    MainModule.ESPTable = {}
    
    if enabled then
        MainModule.ESPFolder = Instance.new("Folder")
        MainModule.ESPFolder.Name = "ESP_Folder"
        MainModule.ESPFolder.Parent = CoreGui
        
        -- Создаем ESP для всех существующих объектов
        MainModule.UpdateESP()
        
        -- Устанавливаем соединение для обновления ESP
        MainModule.ESPConnection = RunService.Heartbeat:Connect(function()
            local currentTime = tick()
            if currentTime - MainModule.Misc.LastESPUpdate >= MainModule.ESPUpdateRate then
                MainModule.Misc.LastESPUpdate = currentTime
                MainModule.UpdateESP()
            end
        end)
    else
        if MainModule.ESPFolder then
            SafeDestroy(MainModule.ESPFolder)
            MainModule.ESPFolder = nil
        end
    end
end

function MainModule.UpdateESP()
    if not MainModule.Misc.ESPEnabled then return end
    
    pcall(function()
        -- Игроки
        if MainModule.Misc.ESPPlayers then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    MainModule.CreatePlayerESP(player)
                end
            end
        end
        
        -- Хайдеры
        if MainModule.Misc.ESPHiders then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player:GetAttribute("IsHider") and player.Character then
                    MainModule.CreateHiderESP(player)
                end
            end
        end
        
        -- Сикеры
        if MainModule.Misc.ESPSeekers then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player:GetAttribute("IsHunter") and player.Character then
                    MainModule.CreateSeekerESP(player)
                end
            end
        end
        
        -- Ключи
        if MainModule.Misc.ESPKeys then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj.Name == "Key" and obj.PrimaryPart then
                    MainModule.CreateKeyESP(obj)
                end
            end
        end
        
        -- Двери
        if MainModule.Misc.ESPDoors then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj.Name == "FullDoorAnimated" and obj.PrimaryPart then
                    MainModule.CreateDoorESP(obj)
                end
            end
        end
        
        -- Выходные двери
        if MainModule.Misc.ESPEscapeDoors then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj.Name == "EXITDOOR" and obj.PrimaryPart and obj:GetAttribute("CANESCAPE") then
                    MainModule.CreateEscapeDoorESP(obj)
                end
            end
        end
    end)
end

function MainModule.CreatePlayerESP(player)
    if not player.Character then return end
    
    local character = player.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart or humanoid.Health <= 0 then return end
    
    local espId = "Player_" .. player.UserId
    local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
                     (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) or 0
    
    local text = MainModule.Misc.ESPDistance and 
                string.format("%s [%dHP]\n[%dm]", player.Name, math.floor(humanoid.Health), math.floor(distance)) or
                string.format("%s [%dHP]", player.Name, math.floor(humanoid.Health))
    
    MainModule.CreateESPObject(espId, rootPart, text, Color3.fromRGB(0, 255, 0))
end

function MainModule.CreateHiderESP(player)
    if not player.Character then return end
    
    local character = player.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart or humanoid.Health <= 0 then return end
    
    local espId = "Hider_" .. player.UserId
    local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
                     (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) or 0
    
    local text = MainModule.Misc.ESPDistance and 
                string.format("Hider: %s\n[%dm]", player.Name, math.floor(distance)) or
                string.format("Hider: %s", player.Name)
    
    MainModule.CreateESPObject(espId, rootPart, text, Color3.fromRGB(255, 165, 0))
end

function MainModule.CreateSeekerESP(player)
    if not player.Character then return end
    
    local character = player.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart or humanoid.Health <= 0 then return end
    
    local espId = "Seeker_" .. player.UserId
    local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
                     (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) or 0
    
    local text = MainModule.Misc.ESPDistance and 
                string.format("Seeker: %s\n[%dm]", player.Name, math.floor(distance)) or
                string.format("Seeker: %s", player.Name)
    
    MainModule.CreateESPObject(espId, rootPart, text, Color3.fromRGB(255, 0, 0))
end

function MainModule.CreateKeyESP(keyModel)
    if not keyModel or not keyModel.PrimaryPart then return end
    
    local espId = "Key_" .. keyModel:GetFullName()
    local rootPart = keyModel.PrimaryPart
    local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
                     (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) or 0
    
    local text = MainModule.Misc.ESPDistance and 
                string.format("Key\n[%dm]", math.floor(distance)) or "Key"
    
    MainModule.CreateESPObject(espId, rootPart, text, Color3.fromRGB(255, 255, 0))
end

function MainModule.CreateDoorESP(doorModel)
    if not doorModel or not doorModel.PrimaryPart then return end
    
    local espId = "Door_" .. doorModel:GetFullName()
    local rootPart = doorModel.PrimaryPart
    local keyNeeded = doorModel:GetAttribute("KeyNeeded") or "None"
    local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
                     (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) or 0
    
    local text = MainModule.Misc.ESPDistance and 
                string.format("Door (Key: %s)\n[%dm]", keyNeeded, math.floor(distance)) or
                string.format("Door (Key: %s)", keyNeeded)
    
    MainModule.CreateESPObject(espId, rootPart, text, Color3.fromRGB(0, 191, 255))
end

function MainModule.CreateEscapeDoorESP(doorModel)
    if not doorModel or not doorModel.PrimaryPart then return end
    
    local espId = "EscapeDoor_" .. doorModel:GetFullName()
    local rootPart = doorModel.PrimaryPart
    local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
                     (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) or 0
    
    local text = MainModule.Misc.ESPDistance and 
                string.format("Escape Door\n[%dm]", math.floor(distance)) or "Escape Door"
    
    MainModule.CreateESPObject(espId, rootPart, text, Color3.fromRGB(0, 255, 127))
end

function MainModule.CreateESPObject(id, adornee, text, color)
    if not MainModule.ESPFolder then return end
    
    -- Проверяем существующий ESP
    if MainModule.ESPTable[id] then
        local esp = MainModule.ESPTable[id]
        if esp.Adornee ~= adornee or not esp.Adornee.Parent then
            esp.Destroy()
            MainModule.ESPTable[id] = nil
        else
            -- Обновляем текст
            esp.UpdateText(text)
            return
        end
    end
    
    local esp = {}
    
    -- Создаем Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = id
    highlight.Adornee = adornee
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = color
    highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
    highlight.OutlineColor = color
    highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
    highlight.Enabled = MainModule.Misc.ESPHighlight
    highlight.Parent = MainModule.ESPFolder
    
    -- Создаем BillboardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Name = id .. "_Billboard"
    billboard.Adornee = adornee
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = MainModule.ESPFolder
    
    -- Создаем TextLabel
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = id .. "_Text"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = color
    textLabel.TextSize = MainModule.Misc.ESPTextSize
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.Parent = billboard
    
    -- Функции ESP
    function esp.UpdateText(newText)
        textLabel.Text = newText
    end
    
    function esp.Destroy()
        pcall(function()
            highlight:Destroy()
            billboard:Destroy()
        end)
    end
    
    -- Сохраняем ссылки
    esp.Highlight = highlight
    esp.Billboard = billboard
    esp.TextLabel = textLabel
    esp.Adornee = adornee
    
    MainModule.ESPTable[id] = esp
    
    -- Соединение для автоматического удаления при исчезновении объекта
    coroutine.wrap(function()
        while esp and esp.Adornee and esp.Adornee.Parent do
            task.wait(1)
        end
        if esp then
            esp.Destroy()
            MainModule.ESPTable[id] = nil
        end
    end)()
end

-- Glass Bridge System функции
function MainModule.ToggleGlassVision(enabled)
    MainModule.GlassBridge.GlassVisionEnabled = enabled
    
    local function updateGlassColors()
        pcall(function()
            for _, part in ipairs(Workspace:GetDescendants()) do
                if part:IsA("BasePart") and part:GetAttribute("GlassPart") then
                    if enabled then
                        if part:GetAttribute("ActuallyKilling") ~= nil then
                            part.Color = Color3.fromRGB(255, 0, 0)
                        else
                            part.Color = Color3.fromRGB(0, 255, 0)
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

function MainModule.ToggleAntiBreak(enabled)
    MainModule.GlassBridge.AntiBreakEnabled = enabled
    
    if MainModule.GlassBridge.AntiBreakConnection then
        MainModule.GlassBridge.AntiBreakConnection:Disconnect()
        MainModule.GlassBridge.AntiBreakConnection = nil
    end
    
    if enabled then
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
        MainModule.RemoveGlassBridgePlatforms()
    end
end

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
                platform.Transparency = 0.8
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

function MainModule.ToggleAntiFall(enabled)
    MainModule.GlassBridge.AntiFallEnabled = enabled
    
    if MainModule.GlassBridge.AntiFallConnection then
        MainModule.GlassBridge.AntiFallConnection:Disconnect()
        MainModule.GlassBridge.AntiFallConnection = nil
    end
    
    if enabled then
        MainModule.CreateGlassBridgeAntiFallPlatform()
        
        MainModule.GlassBridge.AntiFallConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.GlassBridge.AntiFallEnabled then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                
                if not rootPart or not humanoid or humanoid.Health <= 0 then return end
                
                if rootPart.Position.Y < MainModule.GlassBridge.SafeHeight then
                    rootPart.CFrame = CFrame.new(MainModule.GlassBridge.EndPosition)
                    
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

function MainModule.CreateGlassBridgeAntiFallPlatform()
    MainModule.RemoveGlassBridgeAntiFallPlatform()
    
    pcall(function()
        MainModule.GlassBridge.AntiFallPlatform = Instance.new("Part")
        MainModule.GlassBridge.AntiFallPlatform.Name = "GlassBridgeAntiFallPlatform"
        MainModule.GlassBridge.AntiFallPlatform.Size = Vector3.new(400, 2, 50)
        MainModule.GlassBridge.AntiFallPlatform.Position = Vector3.new(-200, MainModule.GlassBridge.SafeHeight - 10, -1534)
        MainModule.GlassBridge.AntiFallPlatform.Anchored = true
        MainModule.GlassBridge.AntiFallPlatform.CanCollide = true
        MainModule.GlassBridge.AntiFallPlatform.Transparency = 0.7
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

-- Instant Rebel функция
function MainModule.ToggleRebel(enabled)
    MainModule.Rebel.Enabled = enabled
    
    if enabled then
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

-- Hitbox Expander функция
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

-- Jump Rope функции
function MainModule.ToggleDeleteRope(enabled)
    MainModule.JumpRope.DeleteRope = enabled
    
    if enabled then
        local function deleteRope()
            pcall(function()
                local rope = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("rope")
                if rope then
                    rope:Destroy()
                else
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj.Name:lower() == "rope" or obj.Name:lower():find("jump") then
                            obj:Destroy()
                            break
                        end
                    end
                end
            end)
        end
        
        deleteRope()
        
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
        end
    end)
end

function MainModule.TeleportToJumpRopeStart()
    pcall(function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(615.284424, 192.274277, 920.952515)
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
        hnsKillHidersConnection,
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
    MainModule.HNS.TargetLocked = false
    MainModule.HNS.CurrentHider = nil
    
    -- Очищаем Glass Bridge
    MainModule.RemoveGlassBridgePlatforms()
    MainModule.RemoveGlassBridgeAntiFallPlatform()
    
    -- Восстанавливаем шипы
    MainModule.ToggleDisableSpikes(false)
    
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
    
    -- Очищаем ESP
    MainModule.ToggleESP(false)
end

-- Автоматическая очистка при выходе
game:GetService("Players").LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not game:GetService("Players").LocalPlayer.Parent then
        MainModule.Cleanup()
    end
end)

return MainModule
