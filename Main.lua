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

-- Anti Ragdoll функция (исправлено - добавлен цикл)
function MainModule.ToggleBypassRagdoll(enabled)
    MainModule.Misc.BypassRagdollEnabled = enabled
    
    -- Хранилище для таймеров и соединений
    if not MainModule.Misc.RagdollData then
        MainModule.Misc.RagdollData = {
            AntiRagdollLoop = nil,
            RagdollBlockConn = nil
        }
    end
    
    local function bypassRagdollFunction()
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
    end
    
    if enabled then
        -- Выполняем сразу один раз
        bypassRagdollFunction()
        
        -- Запускаем цикл проверки
        if MainModule.Misc.RagdollData.AntiRagdollLoop then
            task.cancel(MainModule.Misc.RagdollData.AntiRagdollLoop)
        end
        
        MainModule.Misc.RagdollData.AntiRagdollLoop = task.spawn(function()
            while MainModule.Misc.BypassRagdollEnabled do
                bypassRagdollFunction()
                task.wait(0.1)
            end
        end)
        
        -- Создаем соединение для мгновенного удаления новых Ragdoll объектов
        local char = LocalPlayer.Character
        if char then
            if MainModule.Misc.RagdollData.RagdollBlockConn then
                MainModule.Misc.RagdollData.RagdollBlockConn:Disconnect()
            end
            
            MainModule.Misc.RagdollData.RagdollBlockConn = char.ChildAdded:Connect(function(child)
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
        -- Отключаем все
        if MainModule.Misc.RagdollData.AntiRagdollLoop then
            task.cancel(MainModule.Misc.RagdollData.AntiRagdollLoop)
            MainModule.Misc.RagdollData.AntiRagdollLoop = nil
        end
        
        if MainModule.Misc.RagdollData.RagdollBlockConn then
            MainModule.Misc.RagdollData.RagdollBlockConn:Disconnect()
            MainModule.Misc.RagdollData.RagdollBlockConn = nil
        end
    end
end

-- Функция настройки защитника
function setupDefender(defenderChar, player)
    if defenderConnections[player] then return end
    
    defenderConnections[player] = {}
    
    -- Делаем защитника невидимым для коллизий с другими объектами
    for _, part in pairs(defenderChar:GetChildren()) do
        if part:IsA("BasePart") then
            -- Настраиваем физику для бесстолкновительности
            part.CanCollide = false
            part.CanTouch = false
            part.CanQuery = false
            
            -- Но сохраняем возможность атаковать через специальный механизм
            local attackPart = Instance.new("Part")
            attackPart.Name = "AttackCollider"
            attackPart.Size = part.Size * 1.2
            attackPart.Transparency = 1
            attackPart.CanCollide = false
            attackPart.Anchored = false
            attackPart.Parent = part
            
            -- Прикрепляем к оригинальной части
            local weld = Instance.new("Weld")
            weld.Part0 = part
            weld.Part1 = attackPart
            weld.C0 = CFrame.new()
            weld.Parent = part
            
            -- Создаем область для атаки (не сталкивается с игроком)
            local safeZone = Instance.new("Part")
            safeZone.Name = "SafeZone"
            safeZone.Size = Vector3.new(5, 5, 5)
            safeZone.Transparency = 1
            safeZone.CanCollide = false
            safeZone.Parent = defenderChar
            
            -- Делаем безопасную зону вокруг защищаемого игрока
            local safeWeld = Instance.new("Weld")
            safeWeld.Part0 = defenderChar.PrimaryPart or defenderChar:FindFirstChild("HumanoidRootPart")
            safeWeld.Part1 = safeZone
            safeWeld.C0 = CFrame.new(0, 0, 0)
            safeWeld.Parent = safeZone
        end
    end
    
    -- Настраиваем Humanoid защитника
    local defenderHumanoid = defenderChar:FindFirstChild("Humanoid")
    if defenderHumanoid then
        -- Защитник не может быть сбит с ног
        defenderHumanoid.PlatformStand = false
        defenderHumanoid.AutoRotate = true
        
        -- Добавляем слушатель для получения урона
        local damageConnection = defenderHumanoid.Damage:Connect(function()
            -- Защитник игнорирует урон, но может контратаковать
            -- Реализуйте здесь логику контратаки
        end)
        table.insert(defenderConnections[player], damageConnection)
    end
    
    -- Слушатель для обнаружения врагов
    local proximityConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.Misc.BypassRagdollEnabled then return end
        
        local myChar = LocalPlayer.Character
        if not myChar then return end
        
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        
        -- Защитник следует за нами, но на безопасном расстоянии
        local defenderRoot = defenderChar:FindFirstChild("HumanoidRootPart")
        if defenderRoot then
            -- Позиция следования (немного позади и сбоку)
            local followPosition = myRoot.Position + 
                (myRoot.CFrame.LookVector * -3) + 
                (myRoot.CFrame.RightVector * 2)
            
            -- Плавное движение к позиции
            defenderRoot.Velocity = (followPosition - defenderRoot.Position).Unit * 25
        end
    end)
    table.insert(defenderConnections[player], proximityConnection)
    
    -- Механизм атаки защитника
    local attackConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.Misc.BypassRagdollEnabled then return end
        
        -- Поиск врагов рядом
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= LocalPlayer and otherPlayer ~= player then
                local enemyChar = otherPlayer.Character
                if enemyChar then
                    local enemyRoot = enemyChar:FindFirstChild("HumanoidRootPart")
                    local defenderRoot = defenderChar:FindFirstChild("HumanoidRootPart")
                    
                    if enemyRoot and defenderRoot then
                        local distance = (enemyRoot.Position - defenderRoot.Position).Magnitude
                        
                        -- Если враг слишком близко, защитник атакует
                        if distance < 10 then
                            -- Атака без физического столкновения
                            local direction = (enemyRoot.Position - defenderRoot.Position).Unit
                            
                            -- Применяем силу к врагу (только если он агрессор)
                            if enemyRoot.Velocity.Magnitude > 15 then -- Если враг движется быстро
                                local bodyVelocity = Instance.new("BodyVelocity")
                                bodyVelocity.Velocity = -direction * 50
                                bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
                                bodyVelocity.Parent = enemyRoot
                                
                                -- Удаляем через короткое время
                                task.delay(0.2, function()
                                    pcall(function() bodyVelocity:Destroy() end)
                                end)
                            end
                        end
                    end
                end
            end
        end
    end)
    table.insert(defenderConnections[player], attackConnection)
end

-- Функция для создания/назначения защитника
function MainModule.AssignDefender(player)
    if player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:SetAttribute("IsProtecting", LocalPlayer.Name)
        end
    end
end
-- HNS System функции (исправлено)

-- HNS Kill Aura функция (полностью исправлено)
function MainModule.ToggleKillAura(enabled)
    MainModule.HNS.KillAuraEnabled = enabled
    
    -- Автоматически отключаем шипы при включении Kill Hiders
    if enabled and MainModule.HNS.DisableSpikesEnabled then
        MainModule.ToggleDisableSpikes(true)
    end
    
    if hnsKillAuraConnection then
        hnsKillAuraConnection:Disconnect()
        hnsKillAuraConnection = nil
        MainModule.HNS.CurrentTarget = nil
        MainModule.HNS.TargetAttached = false
    end
    
    if enabled then
        hnsKillAuraConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.KillAuraEnabled then return end
            
            local character = GetCharacter(LocalPlayer)
            if not character or not GetRootPart(LocalPlayer) then return end
            
            local HRP = GetRootPart(LocalPlayer)
            local humanoid = GetHumanoid(LocalPlayer)
            if not humanoid or humanoid.Health <= 0 then return end
            
            -- Проверяем, есть ли у нас нож
            if not playerHasKnife(LocalPlayer) then
                if MainModule.HNS.CurrentTarget then
                    MainModule.HNS.CurrentTarget = nil
                    MainModule.HNS.TargetAttached = false
                end
                return
            end
            
            -- Если у нас уже есть цель
            if MainModule.HNS.CurrentTarget and MainModule.HNS.TargetAttached then
                local targetChar = GetCharacter(MainModule.HNS.CurrentTarget)
                if targetChar then
                    local targetRoot = GetRootPart(MainModule.HNS.CurrentTarget)
                    local targetHumanoid = GetHumanoid(MainModule.HNS.CurrentTarget)
                    
                    -- Проверяем, жива ли цель и является ли хайдером
                    if targetRoot and targetHumanoid and targetHumanoid.Health > 0 and MainModule.HNS.CurrentTarget:GetAttribute("IsHider") then
                        -- Статично прикрепляемся спереди от цели
                        local attachCFrame = targetRoot.CFrame * MainModule.HNS.AttachOffset
                        HRP.CFrame = attachCFrame
                        HRP.Anchored = false -- Важно: не закрепляем, чтобы двигаться с целью
                        
                        -- Поворачиваемся лицом к цели
                        local direction = (targetRoot.Position - HRP.Position).Unit
                        local lookVector = Vector3.new(direction.X, 0, direction.Z)
                        if lookVector.Magnitude > 0 then
                            HRP.CFrame = CFrame.new(HRP.Position, HRP.Position + lookVector)
                        end
                        return
                    else
                        -- Цель умерла или больше не хайдер
                        MainModule.HNS.CurrentTarget = nil
                        MainModule.HNS.TargetAttached = false
                    end
                else
                    MainModule.HNS.CurrentTarget = nil
                    MainModule.HNS.TargetAttached = false
                end
            end
            
            -- Ищем новую цель в радиусе 300
            local targetPlayer = nil
            local closestDistance = math.huge
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player:GetAttribute("IsHider") then
                    local char = GetCharacter(player)
                    if char then
                        local root = GetRootPart(player)
                        local hum = GetHumanoid(player)
                        
                        if root and hum and hum.Health > 0 then
                            local distance = (HRP.Position - root.Position).Magnitude
                            
                            if distance <= 300 and distance < closestDistance then
                                closestDistance = distance
                                targetPlayer = player
                            end
                        end
                    end
                end
            end
            
            -- Если нашли цель
            if targetPlayer then
                MainModule.HNS.CurrentTarget = targetPlayer
                MainModule.HNS.TargetAttached = true
                
                -- Телепортируемся к цели
                local targetRoot = GetRootPart(targetPlayer)
                if targetRoot then
                    local attachCFrame = targetRoot.CFrame * MainModule.HNS.AttachOffset
                    HRP.CFrame = attachCFrame
                    HRP.Anchored = false
                    
                    -- Поворачиваемся к цели
                    local direction = (targetRoot.Position - HRP.Position).Unit
                    local lookVector = Vector3.new(direction.X, 0, direction.Z)
                    if lookVector.Magnitude > 0 then
                        HRP.CFrame = CFrame.new(HRP.Position, HRP.Position + lookVector)
                    end
                end
            end
        end)
    else
        MainModule.HNS.CurrentTarget = nil
        MainModule.HNS.TargetAttached = false
        
        -- При отключении Kill Hiders возвращаем шипы если они были
        if MainModule.HNS.DisableSpikesEnabled then
            MainModule.ToggleDisableSpikes(false)
        end
    end
end

-- Функция для проверки, есть ли у игрока нож (оптимизированная)
local function playerHasKnife(player)
    if not player then return false end
    
    -- Сначала проверяем в инвентаре (более вероятно)
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local toolName = tool.Name:lower()
                if toolName:find("knife") or toolName:find("fork") or toolName:find("dagger") then
                    return true
                end
            end
        end
    end
    
    -- Затем проверяем в руках
    local char = GetCharacter(player)
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                local toolName = tool.Name:lower()
                if toolName:find("knife") or toolName:find("fork") or toolName:find("dagger") then
                    return true
                end
            end
        end
    end
    
    return false
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

-- ESP System (полностью оптимизированный)
MainModule.ESP = {
    Enabled = false,
    Players = {},
    Objects = {},
    Highlights = {},
    Billboards = {},
    Connections = {},
    UpdateRate = 0.2, -- Увеличена частота обновления для плавности
    LastUpdate = 0
}

-- Основная функция ESP
function MainModule.ToggleESP(enabled)
    MainModule.ESP.Enabled = enabled
    
    if MainModule.ESP.Connection then
        MainModule.ESP.Connection:Disconnect()
        MainModule.ESP.Connection = nil
    end
    
    -- Очищаем все ESP объекты
    MainModule.ClearESP()
    
    if enabled then
        -- Создаем папку для ESP
        if not MainModule.ESPFolder then
            MainModule.ESPFolder = Instance.new("Folder")
            MainModule.ESPFolder.Name = "CreonX_ESP"
            MainModule.ESPFolder.Parent = CoreGui
        end
        
        -- Основное соединение для обновления ESP
        MainModule.ESP.Connection = RunService.RenderStepped:Connect(function(deltaTime)
            if not MainModule.ESP.Enabled then return end
            
            MainModule.ESP.LastUpdate = MainModule.ESP.LastUpdate + deltaTime
            if MainModule.ESP.LastUpdate < MainModule.ESP.UpdateRate then return end
            MainModule.ESP.LastUpdate = 0
            
            MainModule.UpdateESP()
        end)
        
        -- Инициализируем ESP для всех игроков
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                MainModule.AddPlayerESP(player)
            end
        end
        
        -- Слушатель для новых игроков
        Players.PlayerAdded:Connect(function(player)
            if MainModule.ESP.Enabled then
                MainModule.AddPlayerESP(player)
            end
        end)
        
        -- Слушатель для ушедших игроков
        Players.PlayerRemoving:Connect(function(player)
            MainModule.RemovePlayerESP(player)
        end)
    else
        -- Очищаем все ESP объекты
        MainModule.ClearESP()
    end
end

-- Функция добавления ESP для игрока
function MainModule.AddPlayerESP(player)
    if MainModule.ESP.Players[player] then return end
    
    local espData = {
        Player = player,
        Highlight = nil,
        Billboard = nil,
        Label = nil,
        Connections = {}
    }
    
    -- Функция создания ESP
    local function createESP()
        local character = GetCharacter(player)
        if not character then return end
        
        local rootPart = GetRootPart(player)
        if not rootPart then return end
        
        local humanoid = GetHumanoid(player)
        if not humanoid or humanoid.Health <= 0 then return end
        
        -- Создаем Highlight
        if not espData.Highlight then
            espData.Highlight = Instance.new("Highlight")
            espData.Highlight.Name = player.Name .. "_Highlight"
            espData.Highlight.Adornee = character
            espData.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            espData.Highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
            espData.Highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
            espData.Highlight.Parent = MainModule.ESPFolder
            
            -- Устанавливаем цвет в зависимости от типа игрока
            if player:GetAttribute("IsHider") then
                espData.Highlight.FillColor = Color3.fromRGB(0, 255, 0) -- Зеленый для хайдеров
                espData.Highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
            elseif player:GetAttribute("IsHunter") then
                espData.Highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Красный для сикеров
                espData.Highlight.OutlineColor = Color3.fromRGB(200, 0, 0)
            else
                espData.Highlight.FillColor = Color3.fromRGB(0, 120, 255) -- Синий для остальных
                espData.Highlight.OutlineColor = Color3.fromRGB(0, 100, 200)
            end
        end
        
        -- Создаем BillboardGui
        if not espData.Billboard then
            espData.Billboard = Instance.new("BillboardGui")
            espData.Billboard.Name = player.Name .. "_Billboard"
            espData.Billboard.Adornee = rootPart
            espData.Billboard.Size = UDim2.new(0, 200, 0, 50)
            espData.Billboard.StudsOffset = Vector3.new(0, 3.5, 0)
            espData.Billboard.AlwaysOnTop = true
            espData.Billboard.MaxDistance = 1000
            espData.Billboard.Parent = MainModule.ESPFolder
            
            espData.Label = Instance.new("TextLabel")
            espData.Label.Name = "TextLabel"
            espData.Label.Size = UDim2.new(1, 0, 1, 0)
            espData.Label.BackgroundTransparency = 1
            espData.Label.TextStrokeTransparency = 0.5
            espData.Label.TextStrokeColor3 = Color3.new(0, 0, 0)
            espData.Label.Font = Enum.Font.GothamBold
            espData.Label.TextSize = MainModule.Misc.ESPTextSize
            espData.Label.Parent = espData.Billboard
        end
        
        -- Обновляем текст
        if espData.Label then
            local distance = ""
            if MainModule.Misc.ESPDistance then
                local localRoot = GetRootPart(LocalPlayer)
                if localRoot then
                    distance = string.format("[%dm]", math.floor((rootPart.Position - localRoot.Position).Magnitude))
                end
            end
            
            local healthText = string.format("HP: %d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
            local nameText = player.DisplayName or player.Name
            local roleText = ""
            
            if player:GetAttribute("IsHider") then
                roleText = " (Hider)"
            elseif player:GetAttribute("IsHunter") then
                roleText = " (Seeker)"
            end
            
            espData.Label.Text = string.format("%s%s\n%s %s", nameText, roleText, healthText, distance)
            
            -- Устанавливаем цвет текста в зависимости от здоровья
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            if healthPercent > 0.7 then
                espData.Label.TextColor3 = Color3.fromRGB(0, 255, 0)
            elseif healthPercent > 0.3 then
                espData.Label.TextColor3 = Color3.fromRGB(255, 255, 0)
            else
                espData.Label.TextColor3 = Color3.fromRGB(255, 0, 0)
            end
        end
    end
    
    -- Соединение для отслеживания появления персонажа
    espData.Connections.CharacterAdded = player.CharacterAdded:Connect(function(character)
        task.wait(0.5) -- Даем время на загрузку персонажа
        createESP()
    end)
    
    -- Соединение для отслеживания здоровья
    local character = GetCharacter(player)
    if character then
        local humanoid = GetHumanoid(player)
        if humanoid then
            espData.Connections.HealthChanged = humanoid.HealthChanged:Connect(function()
                if espData.Label then
                    createESP() -- Обновляем ESP
                end
            end)
        end
    end
    
    -- Создаем ESP если персонаж уже есть
    if GetCharacter(player) then
        createESP()
    end
    
    MainModule.ESP.Players[player] = espData
end

-- Функция удаления ESP игрока
function MainModule.RemovePlayerESP(player)
    local espData = MainModule.ESP.Players[player]
    if not espData then return end
    
    -- Отключаем все соединения
    for _, conn in pairs(espData.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    
    -- Удаляем визуальные элементы
    if espData.Highlight then
        espData.Highlight:Destroy()
    end
    if espData.Billboard then
        espData.Billboard:Destroy()
    end
    
    MainModule.ESP.Players[player] = nil
end

-- Функция обновления ESP
function MainModule.UpdateESP()
    if not MainModule.ESP.Enabled then return end
    
    for player, espData in pairs(MainModule.ESP.Players) do
        if player and player.Parent then
            local character = GetCharacter(player)
            local humanoid = GetHumanoid(player)
            
            if character and humanoid and humanoid.Health > 0 then
                local rootPart = GetRootPart(player)
                
                if espData.Highlight then
                    espData.Highlight.Adornee = character
                    espData.Highlight.Enabled = MainModule.Misc.ESPHighlight
                    espData.Highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
                    espData.Highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
                end
                
                if espData.Billboard and rootPart then
                    espData.Billboard.Adornee = rootPart
                    espData.Billboard.Enabled = MainModule.Misc.ESPNames
                    
                    if espData.Label then
                        espData.Label.TextSize = MainModule.Misc.ESPTextSize
                    end
                end
            else
                -- Игрок умер или нет персонажа
                if espData.Highlight then
                    espData.Highlight.Enabled = false
                end
                if espData.Billboard then
                    espData.Billboard.Enabled = false
                end
            end
        else
            -- Игрок вышел из игры
            MainModule.RemovePlayerESP(player)
        end
    end
end

-- Функция очистки всего ESP
function MainModule.ClearESP()
    for player, espData in pairs(MainModule.ESP.Players) do
        MainModule.RemovePlayerESP(player)
    end
    
    MainModule.ESP.Players = {}
    
    if MainModule.ESPFolder then
        MainModule.ESPFolder:Destroy()
        MainModule.ESPFolder = nil
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

-- Новый AutoDodge System (на основе кода Anti Ragdoll)
function MainModule.ToggleAutoDodge(enabled)
    MainModule.AutoDodge.Enabled = enabled
    
    if MainModule.AutoDodge.Connection then
        MainModule.AutoDodge.Connection:Disconnect()
        MainModule.AutoDodge.Connection = nil
    end
    
    if enabled then
        MainModule.AutoDodge.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.AutoDodge.Enabled then return end
            
            local currentTime = tick()
            if currentTime - MainModule.AutoDodge.LastDodgeTime < MainModule.AutoDodge.DodgeCooldown then return end
            
            local character = GetCharacter(LocalPlayer)
            if not character then return end
            
            local rootPart = GetRootPart(LocalPlayer)
            local humanoid = GetHumanoid(LocalPlayer)
            
            if not rootPart or not humanoid or humanoid.Health <= 0 then return end
            
            -- Проверяем, есть ли у нас нож
            if not playerHasKnife(LocalPlayer) then return end
            
            -- Проверяем, есть ли физическое воздействие рядом
            local shouldDodge = false
            
            -- Проверка других игроков с оружием
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local otherChar = GetCharacter(player)
                    if otherChar then
                        local otherRoot = GetRootPart(player)
                        if otherRoot then
                            local distance = (rootPart.Position - otherRoot.Position).Magnitude
                            
                            -- Если игрок близко и у него есть нож
                            if distance <= MainModule.AutoDodge.DetectionRange and playerHasKnife(player) then
                                -- Проверяем, направлен ли он к нам
                                local directionToUs = (rootPart.Position - otherRoot.Position).Unit
                                local otherLook = otherRoot.CFrame.LookVector
                                
                                local dotProduct = directionToUs:Dot(otherLook)
                                if dotProduct > 0.7 then -- Смотрит в нашу сторону
                                    shouldDodge = true
                                    break
                                end
                            end
                        end
                    end
                end
            end
            
            -- Проверка физических сил на нашем персонаже
            if not shouldDodge then
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        for _, force in pairs(part:GetChildren()) do
                            if (force:IsA("BodyVelocity") and force.Velocity.Magnitude > 25) or
                               (force:IsA("BodyForce") and force.Force.Magnitude > 500) then
                                shouldDodge = true
                                break
                            end
                        end
                        if shouldDodge then break end
                    end
                end
            end
            
            -- Если нужно доджить
            if shouldDodge then
                -- Используем додж (кнопка 1)
                pcall(function()
                    if UserInputService.TouchEnabled then
                        -- Мобильная версия: симулируем использование слота 1
                        local backpack = LocalPlayer:FindFirstChild("Backpack")
                        if backpack then
                            local tool = backpack:FindFirstChildOfClass("Tool")
                            if tool then
                                tool.Parent = character
                                task.wait(0.05)
                                tool.Parent = backpack
                            end
                        end
                    else
                        -- ПК версия: симулируем нажатие клавиши 1
                        local virtualInputManager = game:GetService("VirtualInputManager")
                        virtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
                        task.wait(0.05)
                        virtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)
                    end
                end)
                
                MainModule.AutoDodge.LastDodgeTime = tick()
                
                -- Визуальная обратная связь
                local effect = Instance.new("Part")
                effect.Size = Vector3.new(5, 0.1, 5)
                effect.Position = rootPart.Position - Vector3.new(0, 3, 0)
                effect.Color = Color3.fromRGB(255, 255, 0)
                effect.Material = Enum.Material.Neon
                effect.Anchored = true
                effect.CanCollide = false
                effect.Transparency = 0.7
                effect.Parent = Workspace
                
                game:GetService("Debris"):AddItem(effect, 0.3)
            end
        end)
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

-- RLGL функции (исправлено)
function MainModule.ToggleGodMode(enabled)
    MainModule.RLGL.GodMode = enabled
    
    if MainModule.RLGL.GodModeTimeout then
        MainModule.RLGL.GodModeTimeout:Disconnect()
        MainModule.RLGL.GodModeTimeout = nil
    end
    
    if enabled then
        -- Сохраняем текущее здоровье при включении
        local char = GetCharacter(LocalPlayer)
        if char then
            local humanoid = GetHumanoid(LocalPlayer)
            if humanoid then
                MainModule.RLGL.LastHealth = humanoid.Health
            end
        end
        
        -- Поднимаемся на высоту GodMode
        local char = GetCharacter(LocalPlayer)
        if char and GetRootPart(LocalPlayer) then
            local rootPart = GetRootPart(LocalPlayer)
            local currentPos = rootPart.Position
            rootPart.CFrame = CFrame.new(currentPos.X, 1184.9, currentPos.Z)
        end
        
        -- Создаем соединение для проверки урона ТОЛЬКО в режиме GodMode
        MainModule.RLGL.GodModeTimeout = RunService.Heartbeat:Connect(function()
            if not MainModule.RLGL.GodMode then return end
            
            local char = GetCharacter(LocalPlayer)
            if not char then return end
            
            local humanoid = GetHumanoid(LocalPlayer)
            local rootPart = GetRootPart(LocalPlayer)
            
            if not humanoid or not rootPart then return end
            
            -- Проверяем, получили ли мы урон (сравниваем с сохраненным здоровьем)
            local currentHealth = humanoid.Health
            
            if currentHealth < MainModule.RLGL.LastHealth then
                -- Получили урон В РЕЖИМЕ GodMode - телепортируем на указанные координаты
                rootPart.CFrame = CFrame.new(186.7, 54.3, -100.6)
                
                -- Восстанавливаем здоровье
                humanoid.Health = humanoid.MaxHealth
                
                -- Отключаем GodMode после телепортации
                task.wait(0.1)
                MainModule.ToggleGodMode(false)
                return
            end
            
            -- Обновляем последнее известное здоровье
            MainModule.RLGL.LastHealth = currentHealth
            
            -- Поддерживаем высоту GodMode
            if rootPart.Position.Y < 1100 then
                local currentPos = rootPart.Position
                rootPart.CFrame = CFrame.new(currentPos.X, 1184.9, currentPos.Z)
            end
        end)
    else
        -- Возвращаем на нормальную высоту
        local char = GetCharacter(LocalPlayer)
        if char and GetRootPart(LocalPlayer) then
            local rootPart = GetRootPart(LocalPlayer)
            local currentPos = rootPart.Position
            rootPart.CFrame = CFrame.new(currentPos.X, 100, currentPos.Z)
        end
    end
end

-- Guards функции (исправлено - убран Z-Index)
function MainModule.SetGuardType(guardType)
    -- Очищаем предыдущие значения и устанавливаем новый
    MainModule.Guards.SelectedGuard = guardType
    
    -- Проверяем, что тип корректный
    local validTypes = {"Circle", "Triangle", "Square"}
    if not table.find(validTypes, guardType) then
        MainModule.Guards.SelectedGuard = "Circle"
    end
end

function MainModule.SpawnAsGuard()
    if not MainModule.Guards.SelectedGuard then
        MainModule.Guards.SelectedGuard = "Circle"
    end
    
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

