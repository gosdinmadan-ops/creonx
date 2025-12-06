-- Main.lua - Creon X v2.5 (Исправленный AntiFall и Hitbox Size 40)
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
local TeleportService = game:GetService("TeleportService")

-- Локальный игрок
local LocalPlayer = Players.LocalPlayer

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
    Enabled = false,
    Connection = nil,
    LastKillTime = 0,
    KillCooldown = 0.1,
    LastCheckTime = 0,
    CheckCooldown = 0.5
}

-- RLGL System
MainModule.RLGL = {
    GodMode = false,
    OriginalHeight = nil,
    LastDamageTime = 0,
    DamageCheckRate = 0.1,
    LastHealth = 100,
    GodModeHeight = 160,
    NormalHeight = 80,
    DamageTeleportPosition = Vector3.new(-903.4, 1184.9, -556),
    StartPosition = Vector3.new(-55.3, 1023.1, -545.8),
    EndPosition = Vector3.new(-214.4, 1023.1, 146.7),
    Connection = nil
}

MainModule.Guards = {
    SelectedGuard = "Circle",
    AutoFarm = false,
    RapidFire = false,
    InfiniteAmmo = false,
    HitboxExpander = false,
    OriginalFireRates = {},
    OriginalAmmo = {},
    OriginalHitboxes = {},
    Connections = {}
}

MainModule.Dalgona = {
    CompleteEnabled = false,
    FreeLighterEnabled = false
}

-- Glass Bridge System
MainModule.GlassBridge = {
    AntiBreakEnabled = false,
    AntiBreakConnection = nil,
    AntiFallEnabled = false,
    GlassPlatforms = {},
    GlassAntiFallPlatform = nil,
    GlassESPEnabled = false,
    GlassESPConnection = nil,
    
    EndPosition = Vector3.new(-196.372467, 522.192139, -1534.20984),
    BridgeHeight = 520.4,
    PlatformSize = Vector3.new(10000, 1, 10000)
}

-- Tug of War System
MainModule.TugOfWar = {
    AutoPull = false,
    Connection = nil
}

-- Jump Rope System
MainModule.JumpRope = {
    TeleportToEnd = false,
    AntiFallPlatform = nil,
    Connection = nil,
    PlatformSize = Vector3.new(10000, 1, 10000)
}

-- Sky Squid System
MainModule.SkySquid = {
    AntiFallPlatform = nil,
    SafePlatform = nil,
    Connection = nil,
    PlatformSize = Vector3.new(10000, 1, 10000)
}

-- Anti Time Stop System
MainModule.AntiTimeStop = {
    Enabled = false,
    Connection = nil,
    OriginalProperties = {}
}

-- Hitbox Expander System
MainModule.Hitbox = {
    Size = 150,  -- По умолчанию 150 как в примере
    Enabled = false,
    Connection = nil,
    ModifiedParts = {}
}

-- HIDE AND SEEK - Spikes Kill System (ИСПРАВЛЕННЫЙ)
MainModule.SpikesKill = {
    Enabled = false,
    AnimationId = "rbxassetid://107989020363293", -- ID анимации шипов/урона
    PlatformHeightOffset = 6, -- На сколько выше шипов телепортируемся
    MaxAnimationTime = 5, -- Максимальное время ожидания (5 секунд)
    
    -- Внутренние переменные
    SpikesPlatform = nil, -- НЕВИДИМАЯ платформа на месте шипов
    SavedCFrame = nil, -- Сохраненная позиция до телепортации
    ActiveAnimation = false,
    AnimationStartTime = 0,
    AnimationConnection = nil,
    CharacterAddedConnection = nil,
    SpikesRemoved = false,
    SpikesPosition = nil, -- Позиция найденных шипов
    
    -- Параметры платформы
    PlatformSize = Vector3.new(50, 1, 50), -- Большая платформа
    PlatformColor = Color3.fromRGB(120, 120, 120),
    PlatformTransparency = 1, -- ПОЛНАЯ невидимость
    PlatformCanCollide = false -- Проходит сквозь блоки
}

-- Misc System
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

-- HNS System
MainModule.HNS = {
    InfinityStaminaEnabled = false,
    InfinityStaminaConnection = nil
}

-- ESP System
MainModule.ESP = {
    Players = {},
    Objects = {},
    Connections = {},
    Folder = nil,
    MainConnection = nil,
    UpdateRate = 0.1
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
local bypassRagdollConnection = nil

-- Вспомогательные функции
local function SafeDestroy(obj)
    if obj and obj.Parent then
        pcall(function() obj:Destroy() end)
    end
end

local function GetCharacter()
    return LocalPlayer.Character
end

local function GetHumanoid(character)
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart(character)
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function GetDistance(position1, position2)
    if not position1 or not position2 then return math.huge end
    return (position1 - position2).Magnitude
end

local function IsHider(player)
    if not player then return false end
    return player:GetAttribute("IsHider") == true
end

local function IsSeeker(player)
    if not player then return false end
    return player:GetAttribute("IsHunter") == true
end

local function SafeTeleport(position)
    local character = GetCharacter()
    if not character then return false end
    
    local rootPart = GetRootPart(character)
    if not rootPart then return false end
    
    rootPart.CFrame = CFrame.new(position)
    return true
end

local function GetSafePositionAbove(currentPosition, height)
    local rayOrigin = currentPosition + Vector3.new(0, 5, 0)
    local rayDirection = Vector3.new(0, -1, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    
    local result = workspace:Raycast(rayOrigin, rayDirection * 100, raycastParams)
    
    if result and result.Position then
        return result.Position + Vector3.new(0, height, 0)
    else
        return currentPosition + Vector3.new(0, height, 0)
    end
end

local function GetPlayerGun()
    local character = GetCharacter()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    
    if character then
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") and tool:GetAttribute("Gun") then
                return tool
            end
        end
    end
    
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool:GetAttribute("Gun") then
                return tool
            end
        end
    end
    
    return nil
end

local function GetEnemies()
    local enemies = {}
    local liveFolder = Workspace:FindFirstChild("Live")
    
    if not liveFolder then return enemies end
    
    for _, model in pairs(liveFolder:GetChildren()) do
        if model:IsA("Model") then
            local enemyTag = model:FindFirstChild("Enemy")
            local deadTag = model:FindFirstChild("Dead")
            
            if enemyTag and not deadTag then
                local isPlayer = false
                for _, player in pairs(Players:GetPlayers()) do
                    if player.Name == model.Name then
                        isPlayer = true
                        break
                    end
                end
                
                if not isPlayer then
                    table.insert(enemies, model.Name)
                    if #enemies >= 5 then
                        break
                    end
                end
            end
        end
    end
    
    return enemies
end

local function KillEnemy(enemyName)
    pcall(function()
        local liveFolder = Workspace:FindFirstChild("Live")
        if not liveFolder then return end
        
        local enemy = liveFolder:FindFirstChild(enemyName)
        if not enemy then return end
        
        local enemyTag = enemy:FindFirstChild("Enemy")
        local deadTag = enemy:FindFirstChild("Dead")
        
        if not enemyTag or deadTag then return end
        
        local gun = GetPlayerGun()
        if not gun then return end
        
        local args = {
            gun,
            {
                ["ClientRayNormal"] = Vector3.new(-1.1920928955078125e-7, 1.0000001192092896, 0),
                ["FiredGun"] = true,
                ["SecondaryHitTargets"] = {},
                ["ClientRayInstance"] = Workspace:WaitForChild("StairWalkWay"):WaitForChild("Part"),
                ["ClientRayPosition"] = Vector3.new(-220.17489624023438, 183.2957763671875, 301.07257080078125),
                ["bulletCF"] = CFrame.new(-220.5039825439453, 185.22506713867188, 302.133544921875, 0.9551116228103638, 0.2567310333251953, -0.14782091975212097, 7.450581485102248e-9, 0.4989798665046692, 0.8666135668754578, 0.2962462604045868, -0.8277127146720886, 0.4765814542770386),
                ["HitTargets"] = {
                    [enemyName] = "Head"
                },
                ["bulletSizeC"] = Vector3.new(0.009999999776482582, 0.009999999776482582, 4.452499866485596),
                ["NoMuzzleFX"] = false,
                ["FirePosition"] = Vector3.new(-72.88850402832031, -679.4803466796875, -173.31005859375)
            }
        }
        
        local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("FiredGunClient")
        remote:FireServer(unpack(args))
    end)
end

-- Исправленный RLGL GodMode
function MainModule.ToggleGodMode(enabled)
    MainModule.RLGL.GodMode = enabled
    
    if MainModule.RLGL.Connection then
        MainModule.RLGL.Connection:Disconnect()
        MainModule.RLGL.Connection = nil
    end
    
    if enabled then
        -- Запоминаем начальную позицию
        local character = GetCharacter()
        if character then
            local humanoid = GetHumanoid(character)
            local rootPart = GetRootPart(character)
            
            if humanoid and rootPart then
                MainModule.RLGL.LastHealth = humanoid.Health
                MainModule.RLGL.OriginalHeight = rootPart.Position.Y
                
                -- Телепортируем вверх на GodModeHeight
                local targetPos = Vector3.new(
                    rootPart.Position.X,
                    rootPart.Position.Y + MainModule.RLGL.GodModeHeight,
                    rootPart.Position.Z
                )
                SafeTeleport(targetPos)
                print("[RLGL GodMode] Телепортирован вверх на " .. MainModule.RLGL.GodModeHeight .. " единиц")
            end
        end
        
        -- Проверка урона
        MainModule.RLGL.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.RLGL.GodMode then return end
            
            local currentTime = tick()
            if currentTime - MainModule.RLGL.LastDamageTime < MainModule.RLGL.DamageCheckRate then return end
            
            pcall(function()
                local character = GetCharacter()
                if not character then return end
                
                local humanoid = GetHumanoid(character)
                local rootPart = GetRootPart(character)
                
                if not (humanoid and rootPart) then return end
                
                -- Проверяем, получили ли мы урон
                if humanoid.Health < MainModule.RLGL.LastHealth then
                    MainModule.RLGL.LastDamageTime = currentTime
                    
                    -- Телепортируем на указанные координаты при уроне
                    SafeTeleport(MainModule.RLGL.DamageTeleportPosition)
                    
                    -- Восстанавливаем здоровье
                    humanoid.Health = MainModule.RLGL.LastHealth
                    
                    -- Отключаем GodMode после телепортации от урона
                    task.wait(0.1)
                    MainModule.ToggleGodMode(false)
                else
                    -- Обновляем запомненное здоровье
                    MainModule.RLGL.LastHealth = humanoid.Health
                end
            end)
        end)
    else
        -- Телепортируем обратно на правильную высоту
        local character = GetCharacter()
        if character then
            local rootPart = GetRootPart(character)
            if rootPart and MainModule.RLGL.OriginalHeight then
                -- ПРАВИЛЬНАЯ ФОРМУЛА: Оригинальная высота - (GodModeHeight - NormalHeight)
                local targetHeight = MainModule.RLGL.OriginalHeight - (MainModule.RLGL.GodModeHeight - MainModule.RLGL.NormalHeight)
                
                local targetPos = Vector3.new(
                    rootPart.Position.X,
                    targetHeight,
                    rootPart.Position.Z
                )
                
                SafeTeleport(targetPos)
                print("[RLGL GodMode] Возврат на высоту: " .. targetHeight)
            end
        end
        
        -- Сбрасываем значения
        MainModule.RLGL.OriginalHeight = nil
        MainModule.RLGL.LastHealth = 100
    end
end

-- Исправленный Spikes Kill
function MainModule.ToggleSpikesKill(enabled)
    MainModule.SpikesKill.Enabled = enabled
    
    -- Очищаем предыдущие соединения
    if MainModule.SpikesKill.AnimationConnection then
        MainModule.SpikesKill.AnimationConnection:Disconnect()
        MainModule.SpikesKill.AnimationConnection = nil
    end
    
    if MainModule.SpikesKill.CharacterAddedConnection then
        MainModule.SpikesKill.CharacterAddedConnection:Disconnect()
        MainModule.SpikesKill.CharacterAddedConnection = nil
    end
    
    -- Удаляем старую платформу
    if MainModule.SpikesKill.SpikesPlatform then
        MainModule.SpikesKill.SpikesPlatform:Destroy()
        MainModule.SpikesKill.SpikesPlatform = nil
    end
    
    -- Сбрасываем переменные
    MainModule.SpikesKill.SavedCFrame = nil
    MainModule.SpikesKill.ActiveAnimation = false
    MainModule.SpikesKill.SpikesRemoved = false
    MainModule.SpikesKill.SpikesPosition = nil
    
    if not enabled then
        print("[Spikes Kill] Выключен")
        return
    end
    
    print("[Spikes Kill] Включен")
    
    -- Шаг 1: Находим шипы и создаем платформу
    local function findAndSetupSpikes()
        -- Ищем шипы в структуре HideAndSeekMap
        if workspace:FindFirstChild("HideAndSeekMap") and 
           workspace.HideAndSeekMap:FindFirstChild("KillingParts") then
            
            local killingParts = workspace.HideAndSeekMap.KillingParts
            
            -- Находим первый шип для определения позиции
            for _, spike in pairs(killingParts:GetChildren()) do
                if spike:IsA("BasePart") or spike:IsA("Model") then
                    local spikePosition
                    
                    if spike:IsA("BasePart") then
                        spikePosition = spike.Position
                    elseif spike:IsA("Model") and spike.PrimaryPart then
                        spikePosition = spike.PrimaryPart.Position
                    end
                    
                    if spikePosition then
                        -- Запоминаем позицию шипов
                        MainModule.SpikesKill.SpikesPosition = spikePosition
                        print("[Spikes Kill] Найдены шипы на позиции: " .. tostring(spikePosition))
                        
                        -- Шаг 2: Создаем НЕВИДИМУЮ платформу над шипами
                        local platform = Instance.new("Part")
                        platform.Name = "SpikesKillPlatform"
                        platform.Size = MainModule.SpikesKill.PlatformSize
                        platform.Anchored = true
                        platform.CanCollide = MainModule.SpikesKill.PlatformCanCollide
                        platform.Transparency = MainModule.SpikesKill.PlatformTransparency
                        platform.Color = MainModule.SpikesKill.PlatformColor
                        platform.Material = Enum.Material.Plastic
                        platform.CastShadow = false
                        
                        -- Позиция на 6 единиц выше шипов
                        local platformPosition = Vector3.new(
                            spikePosition.X,
                            spikePosition.Y + MainModule.SpikesKill.PlatformHeightOffset,
                            spikePosition.Z
                        )
                        
                        platform.Position = platformPosition
                        platform.Parent = workspace
                        
                        MainModule.SpikesKill.SpikesPlatform = platform
                        print("[Spikes Kill] Создана невидимая платформа над шипами")
                        
                        -- Шаг 3: Удаляем шипы
                        killingParts:ClearAllChildren()
                        MainModule.SpikesKill.SpikesRemoved = true
                        print("[Spikes Kill] Шипы удалены")
                        
                        return true
                    end
                end
            end
        end
        warn("[Spikes Kill] HideAndSeekMap или KillingParts не найдены!")
        return false
    end
    
    -- Шаг 4: Настройка системы анимации
    local function setupAnimationSystem(char)
        local humanoid = char:WaitForChild("Humanoid", 5)
        if not humanoid then return end
        
        -- Функция обработки начала анимации
        local function onAnimationStart(animTrack)
            if not MainModule.SpikesKill.Enabled then return end
            
            -- Проверяем ID анимации
            if animTrack.Animation.AnimationId ~= MainModule.SpikesKill.AnimationId then
                return
            end
            
            if MainModule.SpikesKill.ActiveAnimation then return end
            
            MainModule.SpikesKill.ActiveAnimation = true
            MainModule.SpikesKill.AnimationStartTime = tick()
            
            -- Сохраняем текущую позицию
            local rootPart = GetRootPart(char)
            if rootPart then
                MainModule.SpikesKill.SavedCFrame = rootPart.CFrame
                print("[Spikes Kill] Сохранена позиция: " .. tostring(rootPart.Position))
            end
            
            -- Телепортируем на платформу (если она существует)
            if MainModule.SpikesKill.SpikesPlatform then
                local platformPos = MainModule.SpikesKill.SpikesPlatform.Position
                rootPart.CFrame = CFrame.new(platformPos)
                print("[Spikes Kill] Телепортирован на платформу: " .. tostring(platformPos))
                
                -- Запускаем таймер для возврата через 5 секунд
                task.delay(MainModule.SpikesKill.MaxAnimationTime, function()
                    if MainModule.SpikesKill.ActiveAnimation and MainModule.SpikesKill.Enabled then
                        MainModule.SpikesKill.ActiveAnimation = false
                        
                        -- Возвращаем на сохраненную позицию
                        if MainModule.SpikesKill.SavedCFrame then
                            rootPart.CFrame = MainModule.SpikesKill.SavedCFrame
                            print("[Spikes Kill] Возвращен на исходную позицию")
                            MainModule.SpikesKill.SavedCFrame = nil
                        end
                    end
                end)
            else
                warn("[Spikes Kill] Платформа не найдена!")
            end
        end
        
        -- Слушатель начала анимаций
        MainModule.SpikesKill.AnimationConnection = humanoid.AnimationPlayed:Connect(function(animTrack)
            onAnimationStart(animTrack)
        end)
    end
    
    -- Запускаем поиск шипов
    if not findAndSetupSpikes() then
        warn("[Spikes Kill] Не удалось найти шипы")
        return
    end
    
    -- Настраиваем для текущего персонажа
    local char = LocalPlayer.Character
    if char then
        setupAnimationSystem(char)
    end
    
    -- Слушатель для нового персонажа
    MainModule.SpikesKill.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        if MainModule.SpikesKill.Enabled then
            setupAnimationSystem(newChar)
        end
    end)
end

-- Функция для удаления шипов (отдельная кнопка)
function MainModule.RemoveSpikes()
    if workspace:FindFirstChild("HideAndSeekMap") and 
       workspace.HideAndSeekMap:FindFirstChild("KillingParts") then
        
        local killingParts = workspace.HideAndSeekMap.KillingParts
        killingParts:ClearAllChildren()
        
        -- Обновляем статус
        MainModule.SpikesKill.SpikesRemoved = true
        
        print("[Spikes Kill] Шипы удалены вручную")
        return true
    else
        warn("[Spikes Kill] HideAndSeekMap или KillingParts не найдены!")
        return false
    end
end

-- Anti Time Stop функция
function MainModule.ToggleAntiTimeStop(enabled)
    MainModule.AntiTimeStop.Enabled = enabled
    
    if MainModule.AntiTimeStop.Connection then
        MainModule.AntiTimeStop.Connection:Disconnect()
        MainModule.AntiTimeStop.Connection = nil
    end
    
    if enabled then
        MainModule.AntiTimeStop.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.AntiTimeStop.Enabled then return end
            
            pcall(function()
                local character = GetCharacter()
                if not character then return end
                
                local humanoid = GetHumanoid(character)
                if not humanoid then return end
                
                -- Сохраняем оригинальные свойства
                if not MainModule.AntiTimeStop.OriginalProperties[humanoid] then
                    MainModule.AntiTimeStop.OriginalProperties[humanoid] = {
                        WalkSpeed = humanoid.WalkSpeed,
                        JumpPower = humanoid.JumpPower
                    }
                end
                
                -- Проверяем, не заморожены ли мы
                local isFrozen = false
                
                -- Проверяем различные эффекты заморозки
                local frozenEffects = {
                    "TimeStop", "TimeStopEffect", "TimeStopDebuff", "Frozen", "Freeze", 
                    "Stopped", "TimeLock", "TimeFreeze", "ZaWarudo"
                }
                
                for _, effectName in ipairs(frozenEffects) do
                    local effect = character:FindFirstChild(effectName)
                    if effect then
                        isFrozen = true
                        break
                    end
                end
                
                -- Проверяем атрибуты
                if humanoid:GetAttribute("TimeStopped") or 
                   humanoid:GetAttribute("Frozen") or 
                   humanoid:GetAttribute("Stopped") then
                    isFrozen = true
                end
                
                -- Если мы заморожены, восстанавливаем движение
                if isFrozen then
                    -- Восстанавливаем скорость
                    humanoid.WalkSpeed = MainModule.AntiTimeStop.OriginalProperties[humanoid].WalkSpeed
                    humanoid.JumpPower = MainModule.AntiTimeStop.OriginalProperties[humanoid].JumpPower
                    
                    -- Удаляем эффекты заморозки
                    for _, effectName in ipairs(frozenEffects) do
                        local effect = character:FindFirstChild(effectName)
                        if effect then
                            effect:Destroy()
                        end
                    end
                    
                    -- Сбрасываем атрибуты
                    humanoid:SetAttribute("TimeStopped", false)
                    humanoid:SetAttribute("Frozen", false)
                    humanoid:SetAttribute("Stopped", false)
                    
                    -- Выходим из состояний заморозки
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    humanoid.PlatformStand = false
                end
            end)
        end)
        
        -- Также слушаем добавление новых эффектов
        local character = GetCharacter()
        if character then
            character.ChildAdded:Connect(function(child)
                if not MainModule.AntiTimeStop.Enabled then return end
                
                if child.Name:find("TimeStop") or child.Name:find("Freeze") then
                    task.wait(0.1)
                    pcall(function() child:Destroy() end)
                end
            end)
        end
    else
        -- Восстанавливаем оригинальные свойства
        for humanoid, properties in pairs(MainModule.AntiTimeStop.OriginalProperties) do
            if humanoid and humanoid.Parent then
                humanoid.WalkSpeed = properties.WalkSpeed
                humanoid.JumpPower = properties.JumpPower
            end
        end
        MainModule.AntiTimeStop.OriginalProperties = {}
    end
end

-- Instant REBEL функция (исправленная и безопасная)
function MainModule.ToggleRebel(enabled)
    MainModule.Rebel.Enabled = enabled
    
    if MainModule.Rebel.Connection then
        MainModule.Rebel.Connection:Disconnect()
        MainModule.Rebel.Connection = nil
    end
    
    if enabled then
        MainModule.Rebel.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.Rebel.Enabled then return end
            
            local currentTime = tick()
            
            -- Проверяем кулдаун проверки врагов
            if currentTime - MainModule.Rebel.LastCheckTime < MainModule.Rebel.CheckCooldown then return end
            MainModule.Rebel.LastCheckTime = currentTime
            
            -- Получаем список врагов
            local enemies = GetEnemies()
            if #enemies == 0 then return end
            
            -- Убиваем каждого врага с кулдауном
            for _, enemyName in pairs(enemies) do
                if currentTime - MainModule.Rebel.LastKillTime < MainModule.Rebel.KillCooldown then
                    task.wait(MainModule.Rebel.KillCooldown)
                end
                
                KillEnemy(enemyName)
                MainModule.Rebel.LastKillTime = tick()
                
                -- Небольшая задержка между убийствами
                task.wait(0.05)
            end
        end)
    else
        -- Сбрасываем время
        MainModule.Rebel.LastKillTime = 0
        MainModule.Rebel.LastCheckTime = 0
    end
end

-- Функции телепортации RLGL с моментальной телепортацией
function MainModule.TeleportToEnd()
    SafeTeleport(MainModule.RLGL.EndPosition)
end

function MainModule.TeleportToStart()
    SafeTeleport(MainModule.RLGL.StartPosition)
end

-- Улучшенная функция Bypass Ragdoll с дополнительными защитами
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
                local Character = GetCharacter()
                if not Character then return end
                
                local Humanoid = GetHumanoid(Character)
                local HumanoidRootPart = GetRootPart(Character)
                
                if not (Humanoid and HumanoidRootPart) then return end

                -- 1. Мягкое удаление Ragdoll объектов
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

                -- 2. Удаляем только вредоносные папки
                local harmfulFolders = {"RotateDisabled", "RagdollWakeupImmunity"}
                for _, folderName in pairs(harmfulFolders) do
                    local folder = Character:FindFirstChild(folderName)
                    if folder then
                        folder:Destroy()
                    end
                end

                -- 3. Основная защита от толчков
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
                
                -- 4. Защита корневого объекта
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
        local char = GetCharacter()
        if char then
            char.ChildAdded:Connect(function(child)
                if child.Name == "Ragdoll" and MainModule.Misc.BypassRagdollEnabled then
                    task.wait(0.1)
                    pcall(function() child:Destroy() end)
                    
                    local humanoid = GetHumanoid(char)
                    if humanoid then
                        humanoid.PlatformStand = false
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end
            end)
        end
    else
        -- При выключении очищаем слушатели
        local character = GetCharacter()
        if character then
            local rootPart = GetRootPart(character)
            if rootPart then
                for _, conn in pairs(getconnections(rootPart.ChildAdded)) do
                    conn:Disconnect()
                end
            end
        end
    end
end

-- Исправленная ESP система
function MainModule.ToggleESP(enabled)
    MainModule.Misc.ESPEnabled = enabled
    
    if MainModule.ESP.MainConnection then
        MainModule.ESP.MainConnection:Disconnect()
        MainModule.ESP.MainConnection = nil
    end
    
    -- Очищаем все ESP объекты
    MainModule.ClearESP()
    
    if enabled then
        -- Создаем папку для ESP
        MainModule.ESP.Folder = Instance.new("Folder")
        MainModule.ESP.Folder.Name = "CreonXESP"
        MainModule.ESP.Folder.Parent = CoreGui
        
        -- Функция для создания и обновления ESP игрока
        local function UpdatePlayerESP(player)
            if not player or player == LocalPlayer then return end
            
            local character = player.Character
            if not character then return end
            
            local humanoid = GetHumanoid(character)
            local rootPart = GetRootPart(character)
            
            if not (humanoid and rootPart and humanoid.Health > 0) then return end
            
            local localCharacter = GetCharacter()
            local localRoot = localCharacter and GetRootPart(localCharacter)
            
            -- Создаем или получаем данные ESP
            local espData = MainModule.ESP.Players[player]
            if not espData then
                espData = {
                    Player = player,
                    Highlight = nil,
                    Billboard = nil,
                    Label = nil
                }
                MainModule.ESP.Players[player] = espData
            end
            
            -- Создаем или обновляем Highlight
            if not espData.Highlight then
                espData.Highlight = Instance.new("Highlight")
                espData.Highlight.Name = player.Name .. "_ESP"
                espData.Highlight.Adornee = character
                espData.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                espData.Highlight.Enabled = MainModule.Misc.ESPHighlight
                espData.Highlight.Parent = MainModule.ESP.Folder
            end
            
            -- Настраиваем цвет
            if IsHider(player) and MainModule.Misc.ESPHiders then
                espData.Highlight.FillColor = Color3.fromRGB(0, 255, 0)
                espData.Highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
            elseif IsSeeker(player) and MainModule.Misc.ESPSeekers then
                espData.Highlight.FillColor = Color3.fromRGB(255, 0, 0)
                espData.Highlight.OutlineColor = Color3.fromRGB(200, 0, 0)
            elseif MainModule.Misc.ESPPlayers then
                espData.Highlight.FillColor = Color3.fromRGB(0, 120, 255)
                espData.Highlight.OutlineColor = Color3.fromRGB(0, 100, 200)
            else
                espData.Highlight.Enabled = false
            end
            
            espData.Highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
            espData.Highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
            
            -- Создаем или обновляем Billboard
            if MainModule.Misc.ESPNames then
                if not espData.Billboard then
                    espData.Billboard = Instance.new("BillboardGui")
                    espData.Billboard.Name = player.Name .. "_Text"
                    espData.Billboard.Adornee = rootPart
                    espData.Billboard.AlwaysOnTop = true
                    espData.Billboard.Size = UDim2.new(0, 200, 0, 50)
                    espData.Billboard.StudsOffset = Vector3.new(0, 3, 0)
                    espData.Billboard.Parent = MainModule.ESP.Folder
                    
                    espData.Label = Instance.new("TextLabel")
                    espData.Label.Size = UDim2.new(1, 0, 1, 0)
                    espData.Label.BackgroundTransparency = 1
                    espData.Label.TextColor3 = espData.Highlight.FillColor
                    espData.Label.TextSize = MainModule.Misc.ESPTextSize
                    espData.Label.Font = Enum.Font.GothamBold
                    espData.Label.TextStrokeColor3 = Color3.new(0, 0, 0)
                    espData.Label.TextStrokeTransparency = 0.5
                    espData.Label.Parent = espData.Billboard
                end
                
                espData.Billboard.Enabled = true
                
                -- Обновляем текст с HP и DISTANCE
                local distanceText = ""
                if MainModule.Misc.ESPDistance and localRoot then
                    local distance = math.floor(GetDistance(rootPart.Position, localRoot.Position))
                    distanceText = string.format(" [%dm]", distance)
                end
                
                local healthText = string.format("HP: %d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
                local nameText = player.DisplayName or player.Name
                
                espData.Label.Text = string.format("%s\n%s%s", nameText, healthText, distanceText)
                espData.Label.TextColor3 = espData.Highlight.FillColor
                espData.Label.TextSize = MainModule.Misc.ESPTextSize
            elseif espData.Billboard then
                espData.Billboard.Enabled = false
            end
        end
        
        -- Создаем ESP для всех игроков
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                UpdatePlayerESP(player)
                
                -- Слушатель для изменений персонажа
                player.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    UpdatePlayerESP(player)
                end)
            end
        end
        
        -- Слушатель для новых игроков
        MainModule.ESP.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
            if MainModule.Misc.ESPEnabled and player ~= LocalPlayer then
                task.wait(0.5)
                UpdatePlayerESP(player)
            end
        end)
        
        -- Основной цикл обновления ESP
        MainModule.ESP.MainConnection = RunService.RenderStepped:Connect(function()
            if not MainModule.Misc.ESPEnabled then return end
            
            for player, espData in pairs(MainModule.ESP.Players) do
                if player and player.Parent and player.Character then
                    UpdatePlayerESP(player)
                else
                    -- Удаляем ESP для вышедших игроков
                    if espData.Highlight then
                        SafeDestroy(espData.Highlight)
                    end
                    if espData.Billboard then
                        SafeDestroy(espData.Billboard)
                    end
                    MainModule.ESP.Players[player] = nil
                end
            end
        end)
    end
end

-- Функция для очистки всего ESP
function MainModule.ClearESP()
    for player, espData in pairs(MainModule.ESP.Players) do
        if espData.Highlight then
            SafeDestroy(espData.Highlight)
        end
        if espData.Billboard then
            SafeDestroy(espData.Billboard)
        end
    end
    MainModule.ESP.Players = {}
    
    if MainModule.ESP.Connections then
        for name, connection in pairs(MainModule.ESP.Connections) do
            if connection then
                pcall(function() connection:Disconnect() end)
                MainModule.ESP.Connections[name] = nil
            end
        end
    end
    
    if MainModule.ESP.Folder then
        SafeDestroy(MainModule.ESP.Folder)
        MainModule.ESP.Folder = nil
    end
    
    if MainModule.ESP.MainConnection then
        MainModule.ESP.MainConnection:Disconnect()
        MainModule.ESP.MainConnection = nil
    end
end

-- Функции скорости
function MainModule.ToggleSpeedHack(enabled)
    MainModule.SpeedHack.Enabled = enabled
    
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
    
    if enabled then
        speedConnection = RunService.Heartbeat:Connect(function()
            if MainModule.SpeedHack.Enabled then
                local character = GetCharacter()
                if character then
                    local humanoid = GetHumanoid(character)
                    if humanoid then
                        humanoid.WalkSpeed = MainModule.SpeedHack.CurrentSpeed
                    end
                end
            end
        end)
    else
        local character = GetCharacter()
        if character then
            local humanoid = GetHumanoid(character)
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
        local character = GetCharacter()
        if character then
            local humanoid = GetHumanoid(character)
            if humanoid then
                humanoid.WalkSpeed = value
            end
        end
    end
    
    return value
end

-- Функции телепортации с моментальной телепортацией
function MainModule.TeleportUp100()
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            local targetPos = rootPart.Position + Vector3.new(0, 100, 0)
            SafeTeleport(targetPos)
        end
    end
end

function MainModule.TeleportDown40()
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            local targetPos = rootPart.Position + Vector3.new(0, -40, 0)
            SafeTeleport(targetPos)
        end
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

-- Функция для установки типа Guard
function MainModule.SetGuardType(guardType)
    if guardType == "Circle" then
        MainModule.Guards.SelectedGuard = "Circle"
    elseif guardType == "Triangle" then
        MainModule.Guards.SelectedGuard = "Triangle"
    elseif guardType == "Square" then
        MainModule.Guards.SelectedGuard = "Square"
    else
        MainModule.Guards.SelectedGuard = "Circle"
    end
end

-- Guards функции
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
                
                local character = GetCharacter()
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

-- Infinite Ammo функция (исправленная)
function MainModule.ToggleInfiniteAmmo(enabled)
    MainModule.Guards.InfiniteAmmo = enabled
    
    if infiniteAmmoConnection then
        infiniteAmmoConnection:Disconnect()
        infiniteAmmoConnection = nil
    end
    
    if enabled then
        infiniteAmmoConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.Guards.InfiniteAmmo then return end
            
            task.spawn(function()
                local character = GetCharacter()
                if character then
                    for _, tool in pairs(character:GetChildren()) do
                        if tool:IsA("Tool") then
                            for _, obj in pairs(tool:GetDescendants()) do
                                if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                                    -- Ищем значения патронов
                                    local nameLower = obj.Name:lower()
                                    if nameLower:find("ammo") or 
                                       nameLower:find("bullet") or
                                       nameLower:find("clip") or
                                       nameLower:find("munition") then
                                        
                                        -- Сохраняем оригинальное значение
                                        if not MainModule.Guards.OriginalAmmo[obj] then
                                            MainModule.Guards.OriginalAmmo[obj] = obj.Value
                                        end
                                        
                                        -- Устанавливаем значение в math.huge (бесконечность)
                                        if obj.Value < 999 then  -- Если значение изменилось на что-то меньшее
                                            obj.Value = math.huge
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                
                -- Проверяем бэкпак
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                if backpack then
                    for _, tool in pairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") then
                            for _, obj in pairs(tool:GetDescendants()) do
                                if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                                    local nameLower = obj.Name:lower()
                                    if nameLower:find("ammo") or 
                                       nameLower:find("bullet") or
                                       nameLower:find("clip") then
                                        
                                        if not MainModule.Guards.OriginalAmmo[obj] then
                                            MainModule.Guards.OriginalAmmo[obj] = obj.Value
                                        end
                                        
                                        if obj.Value < 999 then
                                            obj.Value = math.huge
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
    MainModule.Hitbox.Enabled = enabled
    
    if MainModule.Hitbox.Connection then
        MainModule.Hitbox.Connection:Disconnect()
        MainModule.Hitbox.Connection = nil
    end
    
    -- Очистка кэша при отключении
    if not enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root and MainModule.Hitbox.ModifiedParts[root] then
                    -- Восстанавливаем оригинальный размер
                    root.Size = MainModule.Hitbox.ModifiedParts[root]
                    root.CanCollide = true
                    MainModule.Hitbox.ModifiedParts[root] = nil
                end
            end
        end
        MainModule.Hitbox.ModifiedParts = {}
        return
    end
    
    -- Функция для изменения части
    local function modifyPart(part)
        if not MainModule.Hitbox.ModifiedParts[part] then
            -- Сохраняем оригинальный размер
            MainModule.Hitbox.ModifiedParts[part] = part.Size
            -- Устанавливаем новый размер хитбокса
            part.Size = Vector3.new(MainModule.Hitbox.Size, MainModule.Hitbox.Size, MainModule.Hitbox.Size)
            part.CanCollide = false
        end
    end
    
    -- Обработчик для новых игроков
    local function onPlayerAdded(player)
        player.CharacterAdded:Connect(function(character)
            if MainModule.Hitbox.Enabled then
                local root = character:WaitForChild("HumanoidRootPart", 5)
                if root then
                    modifyPart(root)
                end
            end
        end)
    end
    
    -- Обработчик для существующих игроков
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                modifyPart(root)
            end
        end
        if player ~= LocalPlayer then
            onPlayerAdded(player)
        end
    end
    
    -- Основной цикл с оптимизацией
    MainModule.Hitbox.Connection = RunService.RenderStepped:Connect(function()
        if not MainModule.Hitbox.Enabled then return end
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root and not MainModule.Hitbox.ModifiedParts[root] then
                    pcall(modifyPart, root)
                end
            end
        end
    end)
    
    -- Очистка при выходе игрока
    Players.PlayerRemoving:Connect(function(player)
        if player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                MainModule.Hitbox.ModifiedParts[root] = nil
            end
        end
    end)
    
    -- Слушатель для новых игроков
    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            onPlayerAdded(player)
        end
    end)
end

-- Функция для установки размера хитбокса
function MainModule.SetHitboxSize(size)
    MainModule.Hitbox.Size = size
    
    -- Обновляем существующие хитбоксы
    if MainModule.Hitbox.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root and MainModule.Hitbox.ModifiedParts[root] then
                    root.Size = Vector3.new(size, size, size)
                end
            end
        end
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
function MainModule.DeleteJumpRope()
    local ropeFound = false
    
    -- Ищем веревку в workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        -- Ищем по имени "Rope"
        if obj.Name == "Rope" then
            if obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart") then
                obj:Destroy()
                ropeFound = true
                break
            end
        end
    end
    
    -- Если не нашли по точному имени, ищем по части имени
    if not ropeFound then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("rope") and 
               (obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart")) then
                obj:Destroy()
                ropeFound = true
                break
            end
        end
    end
    
    -- Проверяем в папке Effects
    if not ropeFound then
        local effects = workspace:FindFirstChild("Effects")
        if effects then
            for _, obj in pairs(effects:GetDescendants()) do
                if obj.Name:lower():find("rope") and 
                   (obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart")) then
                    obj:Destroy()
                    ropeFound = true
                    break
                end
            end
        end
    end
    
    return ropeFound
end

function MainModule.TeleportToJumpRopeEnd()
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            SafeTeleport(Vector3.new(720.896057, 198.628311, 921.170654))
        end
    end
end

function MainModule.TeleportToJumpRopeStart()
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            SafeTeleport(Vector3.new(615.284424, 192.274277, 920.952515))
        end
    end
end

-- Функция для создания AntiFall платформы Glass Bridge (-5 Y) - ПОЛНОСТЬЮ НЕВИДИМАЯ
function MainModule.CreateGlassBridgeAntiFall()
    -- Удаляем старую платформу если она есть
    if MainModule.GlassBridge.GlassAntiFallPlatform and MainModule.GlassBridge.GlassAntiFallPlatform.Parent then
        MainModule.GlassBridge.GlassAntiFallPlatform:Destroy()
        MainModule.GlassBridge.GlassAntiFallPlatform = nil
    end
    
    local character = GetCharacter()
    if not character then return nil end
    
    local rootPart = GetRootPart(character)
    if not rootPart then return nil end
    
    local currentPosition = rootPart.Position
    
    -- Создание ПОЛНОСТЬЮ НЕВИДИМОЙ платформы
    local platform = Instance.new("Part")
    platform.Name = "GlassBridgeAntiFall"
    platform.Size = MainModule.GlassBridge.PlatformSize
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 1 -- ПОЛНАЯ НЕВИДИМОСТЬ
    platform.Material = Enum.Material.Plastic
    platform.CastShadow = false
    platform.CanQuery = false -- Отключаем запросы
    
    -- Позиция на 5 единиц ниже игрока
    platform.Position = Vector3.new(
        currentPosition.X,
        currentPosition.Y - 5,
        currentPosition.Z
    )
    platform.Parent = workspace
    
    MainModule.GlassBridge.GlassAntiFallPlatform = platform
    MainModule.GlassBridge.AntiFallEnabled = true
    
    print("[CreonX] Glass Bridge AntiFall создан (полностью невидимый) на высоте Y -5")
    
    return platform
end

-- Функция для удаления AntiFall платформы Glass Bridge
function MainModule.RemoveGlassBridgeAntiFall()
    if MainModule.GlassBridge.GlassAntiFallPlatform and MainModule.GlassBridge.GlassAntiFallPlatform.Parent then
        MainModule.GlassBridge.GlassAntiFallPlatform:Destroy()
        MainModule.GlassBridge.GlassAntiFallPlatform = nil
    end
    
    MainModule.GlassBridge.AntiFallEnabled = false
    print("[CreonX] Glass Bridge AntiFall удален")
    return true
end

-- Функция для создания Sky Squid AntiFall платформы (-5 Y) - ПОЛНОСТЬЮ НЕВИДИМАЯ
function MainModule.CreateSkySquidAntiFall()
    -- Удаляем старую платформу если она есть
    if MainModule.SkySquid.AntiFallPlatform and MainModule.SkySquid.AntiFallPlatform.Parent then
        MainModule.SkySquid.AntiFallPlatform:Destroy()
        MainModule.SkySquid.AntiFallPlatform = nil
    end
    
    local character = GetCharacter()
    if not character then return nil end
    
    local rootPart = GetRootPart(character)
    if not rootPart then return nil end
    
    local currentPosition = rootPart.Position
    
    -- Создание ПОЛНОСТЬЮ НЕВИДИМОЙ платформы
    local platform = Instance.new("Part")
    platform.Name = "SkySquidAntiFall"
    platform.Size = MainModule.SkySquid.PlatformSize
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 1 -- ПОЛНАЯ НЕВИДИМОСТЬ
    platform.Material = Enum.Material.Plastic
    platform.CastShadow = false
    platform.CanQuery = false -- Отключаем запросы
    
    -- Позиция на 5 единиц ниже игрока
    platform.Position = Vector3.new(
        currentPosition.X,
        currentPosition.Y - 5,
        currentPosition.Z
    )
    platform.Parent = workspace
    
    MainModule.SkySquid.AntiFallPlatform = platform
    
    print("[CreonX] Sky Squid AntiFall создан (полностью невидимый) на высоте Y -5")
    
    return platform
end

-- Функция для удаления Sky Squid AntiFall платформы
function MainModule.RemoveSkySquidAntiFall()
    if MainModule.SkySquid.AntiFallPlatform and MainModule.SkySquid.AntiFallPlatform.Parent then
        MainModule.SkySquid.AntiFallPlatform:Destroy()
        MainModule.SkySquid.AntiFallPlatform = nil
    end
    
    print("[CreonX] Sky Squid AntiFall удален")
    return true
end

-- Функция для создания Jump Rope AntiFall платформы (-5 Y) - ПОЛНОСТЬЮ НЕВИДИМАЯ
function MainModule.CreateJumpRopeAntiFall()
    -- Удаляем старую платформу если она есть
    if MainModule.JumpRope.AntiFallPlatform and MainModule.JumpRope.AntiFallPlatform.Parent then
        MainModule.JumpRope.AntiFallPlatform:Destroy()
        MainModule.JumpRope.AntiFallPlatform = nil
    end
    
    local character = GetCharacter()
    if not character then return nil end
    
    local rootPart = GetRootPart(character)
    if not rootPart then return nil end
    
    local currentPosition = rootPart.Position
    
    -- Создание ПОЛНОСТЬЮ НЕВИДИМОЙ платформы
    local platform = Instance.new("Part")
    platform.Name = "JumpRopeAntiFall"
    platform.Size = MainModule.JumpRope.PlatformSize
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 1 -- ПОЛНАЯ НЕВИДИМОСТЬ
    platform.Material = Enum.Material.Plastic
    platform.CastShadow = false
    platform.CanQuery = false -- Отключаем запросы
    
    -- Позиция на 5 единиц ниже игрока
    platform.Position = Vector3.new(
        currentPosition.X,
        currentPosition.Y - 5,
        currentPosition.Z
    )
    platform.Parent = workspace
    
    MainModule.JumpRope.AntiFallPlatform = platform
    
    print("[CreonX] Jump Rope AntiFall создан (полностью невидимый) на высоте Y -5")
    
    return platform
end

-- Функция для удаления Jump Rope AntiFall платформы
function MainModule.RemoveJumpRopeAntiFall()
    if MainModule.JumpRope.AntiFallPlatform and MainModule.JumpRope.AntiFallPlatform.Parent then
        MainModule.JumpRope.AntiFallPlatform:Destroy()
        MainModule.JumpRope.AntiFallPlatform = nil
    end
    
    print("[CreonX] Jump Rope AntiFall удален")
    return true
end

-- Функция для включения/выключения AntiFall Glass Bridge
function MainModule.ToggleGlassBridgeAntiFall(enabled)
    if enabled then
        return MainModule.CreateGlassBridgeAntiFall()
    else
        return MainModule.RemoveGlassBridgeAntiFall()
    end
end

-- Функция для включения/выключения AntiFall Sky Squid
function MainModule.ToggleSkySquidAntiFall(enabled)
    if enabled then
        return MainModule.CreateSkySquidAntiFall()
    else
        return MainModule.RemoveSkySquidAntiFall()
    end
end

-- Функция для включения/выключения AntiFall Jump Rope
function MainModule.ToggleJumpRopeAntiFall(enabled)
    if enabled then
        return MainModule.CreateJumpRopeAntiFall()
    else
        return MainModule.RemoveJumpRopeAntiFall()
    end
end

-- Glass Bridge AntiBreak функция
function MainModule.ToggleGlassBridgeAntiBreak(enabled)
    MainModule.GlassBridge.AntiBreakEnabled = enabled
    
    if MainModule.GlassBridge.AntiBreakConnection then
        MainModule.GlassBridge.AntiBreakConnection:Disconnect()
        MainModule.GlassBridge.AntiBreakConnection = nil
    end
    
    -- Удаление всех существующих платформ при отключении
    if not enabled then
        for _, platform in pairs(MainModule.GlassBridge.GlassPlatforms) do
            if platform and platform.Parent then
                platform:Destroy()
            end
        end
        MainModule.GlassBridge.GlassPlatforms = {}
        return
    end
    
    -- Функция создания платформы под стеклом
    local function createPlatformUnderGlass(glassModel)
        if not glassModel or not glassModel.PrimaryPart then return end
        
        local platformName = "AntiFallPlatform_" .. glassModel.Name
        
        -- Проверяем, существует ли уже платформа
        local existingPlatform = nil
        for _, platform in pairs(MainModule.GlassBridge.GlassPlatforms) do
            if platform and platform.Name == platformName then
                existingPlatform = platform
                break
            end
        end
        
        if existingPlatform then
            existingPlatform.CFrame = glassModel.PrimaryPart.CFrame * CFrame.new(0, -1.5, 0)
            return existingPlatform
        end
        
        -- Создание невидимой платформы
        local platform = Instance.new("Part")
        platform.Name = platformName
        platform.Size = Vector3.new(5, 1, 5)
        platform.Anchored = true
        platform.CanCollide = true
        platform.Transparency = 1
        platform.CastShadow = false
        
        -- Позиция на 1.5 ниже стекла
        platform.CFrame = glassModel.PrimaryPart.CFrame * CFrame.new(0, -1.5, 0)
        platform.Parent = workspace
        
        -- Добавление в таблицу для управления
        table.insert(MainModule.GlassBridge.GlassPlatforms, platform)
        
        return platform
    end
    
    -- Подключение Heartbeat для постоянной проверки
    MainModule.GlassBridge.AntiBreakConnection = RunService.Heartbeat:Connect(function()
        -- Поиск GlassHolder в GlassBridge
        local GlassBridge = workspace:FindFirstChild("GlassBridge")
        if not GlassBridge then return end
        
        local GlassHolder = GlassBridge:FindFirstChild("GlassHolder")
        if not GlassHolder then return end
        
        -- Проход по всем стеклянным панелям
        for _, rowFolder in pairs(GlassHolder:GetChildren()) do
            for _, glassModel in pairs(rowFolder:GetChildren()) do
                if glassModel:IsA("Model") and glassModel.PrimaryPart then
                    -- Удаление атрибута, который отвечает за взрыв/поломку стекла
                    if glassModel.PrimaryPart:GetAttribute("exploitingisevil") ~= nil then
                        glassModel.PrimaryPart:SetAttribute("exploitingisevil", nil)
                    end
                    
                    -- Дополнительная защита: делаем стекло неразрушаемым
                    if glassModel.PrimaryPart:IsA("BasePart") then
                        glassModel.PrimaryPart.CanCollide = true
                        glassModel.PrimaryPart.Anchored = true
                        
                        -- Защита от удаления стекла
                        for _, descendant in pairs(glassModel:GetDescendants()) do
                            if descendant:IsA("BasePart") then
                                descendant.CanCollide = true
                                descendant.Anchored = true
                                descendant.Transparency = 0
                            end
                        end
                    end
                end
            end
        end
    end)
    
    -- Сразу создаем платформы при включении
    task.spawn(function()
        task.wait(1)
        local GlassBridge = workspace:FindFirstChild("GlassBridge")
        if GlassBridge and GlassBridge:FindFirstChild("GlassHolder") then
            local GlassHolder = GlassBridge.GlassHolder
            for _, rowFolder in pairs(GlassHolder:GetChildren()) do
                for _, glassModel in pairs(rowFolder:GetChildren()) do
                    if glassModel:IsA("Model") and glassModel.PrimaryPart then
                        createPlatformUnderGlass(glassModel)
                    end
                end
            end
        end
    end)
end

-- Glass Bridge ESP функция
function MainModule.RevealGlassBridge()
    local Effects = ReplicatedStorage:FindFirstChild("Modules") and 
                   ReplicatedStorage.Modules:FindFirstChild("Effects")
    
    local glassHolder = workspace:FindFirstChild("GlassBridge") and workspace.GlassBridge:FindFirstChild("GlassHolder")
    if not glassHolder then
        warn("GlassHolder not found in workspace.GlassBridge")
        return
    end

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
                        TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
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

    -- Создаем уведомление
    if Effects then
        local success, result = pcall(function()
            return require(Effects)
        end)
        
        if success and result and result.AnnouncementTween then
            result.AnnouncementTween({
                AnnouncementOneLine = true,
                FasterTween = true,
                DisplayTime = 10,
                AnnouncementDisplayText = "[CreonHub]: Safe tiles are green, breakable tiles are red!"
            })
        end
    end
    
    -- Также создаем текстовое уведомление
    print("[CreonHub]: Safe tiles are green, breakable tiles are red!")
end

-- Teleport to End для Glass Bridge
function MainModule.TeleportToGlassBridgeEnd()
    SafeTeleport(MainModule.GlassBridge.EndPosition)
end

-- HNS Infinity Stamina функция
function MainModule.ToggleHNSInfinityStamina(enabled)
    MainModule.HNS.InfinityStaminaEnabled = enabled
    
    if MainModule.HNS.InfinityStaminaConnection then
        MainModule.HNS.InfinityStaminaConnection:Disconnect()
        MainModule.HNS.InfinityStaminaConnection = nil
    end
    
    if enabled then
        MainModule.HNS.InfinityStaminaConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.InfinityStaminaEnabled then return end
            
            task.spawn(function()
                if LocalPlayer.Character then
                    local stamina = LocalPlayer.Character:FindFirstChild("StaminaVal")
                    if stamina then
                        stamina.Value = 100
                    end
                end
            end)
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
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            local position = rootPart.Position
            return string.format("X: %.1f, Y: %.1f, Z: %.1f", position.X, position.Y, position.Z)
        end
    end
    return "Не доступно"
end

-- Очистка при закрытии
function MainModule.Cleanup()
    -- Отключаем все соединения
    local connections = {
        speedConnection, autoFarmConnection, godModeConnection, instaInteractConnection,
        noCooldownConnection, antiStunConnection, rapidFireConnection, infiniteAmmoConnection,
        hitboxConnection, autoPullConnection, bypassRagdollConnection
    }
    
    for _, conn in pairs(connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    
    -- Отключаем ESP
    MainModule.ClearESP()
    
    -- Отключаем RLGL
    if MainModule.RLGL.Connection then
        MainModule.RLGL.Connection:Disconnect()
        MainModule.RLGL.Connection = nil
    end
    
    -- Отключаем REBEL
    if MainModule.Rebel.Connection then
        MainModule.Rebel.Connection:Disconnect()
        MainModule.Rebel.Connection = nil
    end
    
    -- Отключаем HNS соединения
    if MainModule.HNS.InfinityStaminaConnection then
        MainModule.HNS.InfinityStaminaConnection:Disconnect()
        MainModule.HNS.InfinityStaminaConnection = nil
    end
    
    -- Отключаем Spikes Kill
    if MainModule.SpikesKill.AnimationConnection then
        MainModule.SpikesKill.AnimationConnection:Disconnect()
        MainModule.SpikesKill.AnimationConnection = nil
    end
    
    if MainModule.SpikesKill.CharacterAddedConnection then
        MainModule.SpikesKill.CharacterAddedConnection:Disconnect()
        MainModule.SpikesKill.CharacterAddedConnection = nil
    end
    
    -- Удаляем платформу Spikes Kill
    if MainModule.SpikesKill.SpikesPlatform then
        MainModule.SpikesKill.SpikesPlatform:Destroy()
        MainModule.SpikesKill.SpikesPlatform = nil
    end
    
    -- Отключаем Glass Bridge соединения
    if MainModule.GlassBridge.AntiBreakConnection then
        MainModule.GlassBridge.AntiBreakConnection:Disconnect()
        MainModule.GlassBridge.AntiBreakConnection = nil
    end
    
    -- Отключаем Glass ESP соединения
    if MainModule.GlassBridge.GlassESPConnection then
        MainModule.GlassBridge.GlassESPConnection:Disconnect()
        MainModule.GlassBridge.GlassESPConnection = nil
    end
    
    -- Отключаем Jump Rope соединения
    if MainModule.JumpRope.Connection then
        MainModule.JumpRope.Connection:Disconnect()
        MainModule.JumpRope.Connection = nil
    end
    
    -- Отключаем Sky Squid соединения
    if MainModule.SkySquid.Connection then
        MainModule.SkySquid.Connection:Disconnect()
        MainModule.SkySquid.Connection = nil
    end
    
    -- Отключаем Tug of War соединения
    if MainModule.TugOfWar.Connection then
        MainModule.TugOfWar.Connection:Disconnect()
        MainModule.TugOfWar.Connection = nil
    end
    
    -- Отключаем Hitbox Expander
    if MainModule.Hitbox.Connection then
        MainModule.Hitbox.Connection:Disconnect()
        MainModule.Hitbox.Connection = nil
    end
    
    -- Отключаем Anti Time Stop
    if MainModule.AntiTimeStop.Connection then
        MainModule.AntiTimeStop.Connection:Disconnect()
        MainModule.AntiTimeStop.Connection = nil
    end
    
    -- Восстанавливаем хитбоксы
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root and MainModule.Hitbox.ModifiedParts[root] then
                root.Size = MainModule.Hitbox.ModifiedParts[root]
                root.CanCollide = true
            end
        end
    end
    MainModule.Hitbox.ModifiedParts = {}
    
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
    
    -- Восстанавливаем Anti Time Stop свойства
    for humanoid, properties in pairs(MainModule.AntiTimeStop.OriginalProperties) do
        if humanoid and humanoid.Parent then
            humanoid.WalkSpeed = properties.WalkSpeed
            humanoid.JumpPower = properties.JumpPower
        end
    end
    MainModule.AntiTimeStop.OriginalProperties = {}
    
    -- Удаляем платформы Glass Bridge
    for _, platform in pairs(MainModule.GlassBridge.GlassPlatforms) do
        if platform and platform.Parent then
            platform:Destroy()
        end
    end
    MainModule.GlassBridge.GlassPlatforms = {}
    
    -- Удаляем Anti Fall платформы
    if MainModule.GlassBridge.GlassAntiFallPlatform and MainModule.GlassBridge.GlassAntiFallPlatform.Parent then
        MainModule.RemoveGlassBridgeAntiFall()
    end
    
    if MainModule.SkySquid.AntiFallPlatform and MainModule.SkySquid.AntiFallPlatform.Parent then
        MainModule.RemoveSkySquidAntiFall()
    end
    
    if MainModule.JumpRope.AntiFallPlatform and MainModule.JumpRope.AntiFallPlatform.Parent then
        MainModule.RemoveJumpRopeAntiFall()
    end
    
    -- Восстанавливаем скорость
    if MainModule.SpeedHack.Enabled then
        MainModule.ToggleSpeedHack(false)
    end
    
    -- Сбрасываем переменные
    MainModule.SpeedHack.Enabled = false
    MainModule.SpeedHack.CurrentSpeed = 16
    MainModule.Noclip.Enabled = false
    MainModule.AutoQTE.AntiStunEnabled = false
    MainModule.Rebel.Enabled = false
    MainModule.RLGL.GodMode = false
    MainModule.Guards.AutoFarm = false
    MainModule.Guards.RapidFire = false
    MainModule.Guards.InfiniteAmmo = false
    MainModule.Guards.HitboxExpander = false
    MainModule.Hitbox.Enabled = false
    MainModule.AntiTimeStop.Enabled = false
    MainModule.HNS.InfinityStaminaEnabled = false
    MainModule.Misc.ESPEnabled = false
    MainModule.Misc.InstaInteract = false
    MainModule.Misc.NoCooldownProximity = false
    MainModule.Misc.BypassRagdollEnabled = false
    MainModule.TugOfWar.AutoPull = false
    MainModule.Dalgona.CompleteEnabled = false
    MainModule.Dalgona.FreeLighterEnabled = false
    MainModule.GlassBridge.AntiBreakEnabled = false
    MainModule.GlassBridge.AntiFallEnabled = false
    MainModule.GlassBridge.GlassESPEnabled = false
    MainModule.SpikesKill.Enabled = false
    
    print("Creon X cleanup complete")
end

-- Автоматическая очистка при выходе
LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not LocalPlayer.Parent then
        MainModule.Cleanup()
    end
end)

return MainModule
