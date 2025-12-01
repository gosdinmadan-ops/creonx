-- Main.lua - Creon X v2.1 (Полная версия с исправлениями)
local MainModule = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
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
    OriginalHeight = nil
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

MainModule.HNS = {
    SpikesKill = false,
    DisableSpikes = false,
    KillHiders = false,
    AutoDodge = false,
    LastDodgeTime = 0,
    DodgeCooldown = 1.0,
    DodgeRange = 15,
    -- Новые переменные для Spike Kill
    LastSpikeKillTime = 0,
    SpikeKillCooldown = 3,
    CurrentSpikeKillTarget = nil,
    IsInSpikeKillProcess = false,
    OriginalSpikeKillPosition = nil,
    -- Новые переменные для Kill Hiders
    KillHidersRange = 100,
    CurrentKillTarget = nil,
    LastKillTime = 0,
    KillCooldown = 0.3,
    -- Переменные для плавного следования
    KillHidersTarget = nil,
    FollowingTarget = false,
    LastFollowTime = 0,
    FollowUpdateRate = 0.1,
    FollowDistance = 3, -- Дистанция перед целью
    SmoothFollowSpeed = 0.5 -- Плавность следования
}

MainModule.TugOfWar = {
    AutoPull = false
}

MainModule.GlassBridge = {
    AntiBreak = false,
    GlassESPEnabled = false,
    GlassPlatform = false,
    FakeGlassCover = false,
    AntiFallPlatform = nil
}

MainModule.JumpRope = {
    TeleportToEnd = false,
    DeleteRope = false
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
    AntiStunRagdoll = false
}

-- ESP System
MainModule.ESPTable = {}
MainModule.ESPFolder = nil
MainModule.ESPUpdateRate = 0.5
MainModule.LastESPUpdate = 0
MainModule.ESPConnection = nil
MainModule.ESPCache = {}

-- HNS шипы
MainModule.HNSSpikes = {
    Positions = {},
    OriginalPositions = {},
    Disabled = false
}

-- Glass Bridge платформы
MainModule.GlassBridgePlatforms = {}
MainModule.GlassBridgeCover = nil

-- Auto Dodge tracking
MainModule.HNSTrackedAttackers = {}

-- Kill Hiders system
MainModule.KillHidersConnection = nil
MainModule.KillHidersAttackLoop = nil

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
local hnsSpikesKillConnection = nil
local hnsAutoDodgeConnection = nil
local glassBridgeESPConnection = nil
local antiStunRagdollConnection = nil
local skySquidAntiFallConnection = nil
local skySquidVoidKillConnection = nil

-- Локальный игрок
local LocalPlayer = Players.LocalPlayer

-- ============================
-- ОПТИМИЗИРОВАННАЯ ESP SYSTEM
-- ============================
function MainModule.ToggleESP(enabled)
    MainModule.Misc.ESPEnabled = enabled
    
    if MainModule.ESPConnection then
        MainModule.ESPConnection:Disconnect()
        MainModule.ESPConnection = nil
    end
    
    -- Очищаем старые ESP
    for _, esp in pairs(MainModule.ESPTable) do
        if esp and esp.Destroy then
            pcall(function() esp:Destroy() end)
        end
    end
    MainModule.ESPTable = {}
    MainModule.ESPCache = {}
    
    -- Удаляем папку ESP
    if MainModule.ESPFolder then
        MainModule.ESPFolder:Destroy()
        MainModule.ESPFolder = nil
    end
    
    if enabled then
        -- Создаем новую папку ESP
        MainModule.ESPFolder = Instance.new("Folder")
        MainModule.ESPFolder.Name = "CreonESP"
        MainModule.ESPFolder.Parent = Workspace
        
        -- Оптимизированное обновление ESP
        MainModule.ESPConnection = RunService.Heartbeat:Connect(function()
            local currentTime = tick()
            if currentTime - MainModule.LastESPUpdate < MainModule.ESPUpdateRate then
                return
            end
            MainModule.LastESPUpdate = currentTime
            
            -- Оптимизированное обновление ESP
            pcall(function()
                -- Удаляем старые ESP для несуществующих объектов
                local toRemove = {}
                for key, esp in pairs(MainModule.ESPTable) do
                    if esp and esp.Adornee and (not esp.Adornee.Parent or esp.Adornee.Parent == nil) then
                        table.insert(toRemove, key)
                    end
                end
                
                for _, key in ipairs(toRemove) do
                    if MainModule.ESPTable[key] and MainModule.ESPTable[key].Destroy then
                        pcall(function() MainModule.ESPTable[key]:Destroy() end)
                    end
                    MainModule.ESPTable[key] = nil
                end
                
                -- ESP для игроков
                if MainModule.Misc.ESPPlayers then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                            if humanoid and humanoid.Health > 0 then
                                local cacheKey = "player_" .. player.UserId
                                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                                
                                if rootPart then
                                    if not MainModule.ESPCache[cacheKey] or tick() - MainModule.ESPCache[cacheKey] > 2 then
                                        -- Создаем или обновляем Highlight
                                        if not MainModule.ESPTable[cacheKey] then
                                            local highlight = Instance.new("Highlight")
                                            highlight.Name = "ESP_" .. player.Name
                                            highlight.Adornee = player.Character
                                            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                            highlight.FillColor = Color3.fromRGB(0, 170, 255)
                                            highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
                                            highlight.OutlineColor = Color3.fromRGB(0, 170, 255)
                                            highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
                                            highlight.Enabled = MainModule.Misc.ESPHighlight
                                            highlight.Parent = MainModule.ESPFolder
                                            
                                            MainModule.ESPTable[cacheKey] = {
                                                Highlight = highlight,
                                                Destroy = function()
                                                    if highlight then highlight:Destroy() end
                                                end
                                            }
                                        end
                                        
                                        MainModule.ESPCache[cacheKey] = tick()
                                    end
                                    
                                    -- Добавляем billboard с информацией
                                    if MainModule.Misc.ESPNames and not MainModule.ESPTable[cacheKey .. "_text"] then
                                        local billboard = Instance.new("BillboardGui")
                                        billboard.Name = "ESP_Text_" .. player.Name
                                        billboard.Adornee = rootPart
                                        billboard.AlwaysOnTop = true
                                        billboard.Size = UDim2.new(0, 200, 0, 50)
                                        billboard.StudsOffset = Vector3.new(0, 3, 0)
                                        billboard.Parent = MainModule.ESPFolder
                                        
                                        local textLabel = Instance.new("TextLabel")
                                        textLabel.Name = "ESP_Label"
                                        textLabel.BackgroundTransparency = 1
                                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                                        textLabel.Text = player.DisplayName
                                        if MainModule.Misc.ESPDistance then
                                            local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) 
                                                and math.floor((rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) 
                                                or 0
                                            textLabel.Text = player.DisplayName .. " [" .. distance .. "m]"
                                        end
                                        textLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
                                        textLabel.TextSize = MainModule.Misc.ESPTextSize
                                        textLabel.Font = Enum.Font.GothamBold
                                        textLabel.TextStrokeTransparency = 0.3
                                        textLabel.Parent = billboard
                                        
                                        MainModule.ESPTable[cacheKey .. "_text"] = {
                                            Billboard = billboard,
                                            Destroy = function()
                                                if billboard then billboard:Destroy() end
                                            end
                                        }
                                    end
                                end
                            end
                        end
                    end
                end
                
                -- ESP для Hiders
                if MainModule.Misc.ESPHiders then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local isHider = player:GetAttribute("IsHider")
                            if isHider then
                                local cacheKey = "hider_" .. player.UserId
                                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                                
                                if rootPart then
                                    if not MainModule.ESPCache[cacheKey] or tick() - MainModule.ESPCache[cacheKey] > 2 then
                                        -- Создаем Highlight для Hider
                                        if not MainModule.ESPTable[cacheKey] then
                                            local highlight = Instance.new("Highlight")
                                            highlight.Name = "ESP_Hider_" .. player.Name
                                            highlight.Adornee = player.Character
                                            highlight.FillColor = Color3.fromRGB(0, 255, 0)
                                            highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
                                            highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                                            highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
                                            highlight.Enabled = MainModule.Misc.ESPHighlight
                                            highlight.Parent = MainModule.ESPFolder
                                            
                                            MainModule.ESPTable[cacheKey] = {
                                                Highlight = highlight,
                                                Destroy = function()
                                                    if highlight then highlight:Destroy() end
                                                end
                                            }
                                        end
                                        
                                        MainModule.ESPCache[cacheKey] = tick()
                                    end
                                end
                            end
                        end
                    end
                end
                
                -- ESP для Seekers
                if MainModule.Misc.ESPSeekers then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local isHunter = player:GetAttribute("IsHunter")
                            if isHunter then
                                local cacheKey = "seeker_" .. player.UserId
                                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                                
                                if rootPart then
                                    if not MainModule.ESPCache[cacheKey] or tick() - MainModule.ESPCache[cacheKey] > 2 then
                                        -- Создаем Highlight для Seeker
                                        if not MainModule.ESPTable[cacheKey] then
                                            local highlight = Instance.new("Highlight")
                                            highlight.Name = "ESP_Seeker_" .. player.Name
                                            highlight.Adornee = player.Character
                                            highlight.FillColor = Color3.fromRGB(255, 0, 0)
                                            highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
                                            highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                                            highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
                                            highlight.Enabled = MainModule.Misc.ESPHighlight
                                            highlight.Parent = MainModule.ESPFolder
                                            
                                            MainModule.ESPTable[cacheKey] = {
                                                Highlight = highlight,
                                                Destroy = function()
                                                    if highlight then highlight:Destroy() end
                                                end
                                            }
                                        end
                                        
                                        MainModule.ESPCache[cacheKey] = tick()
                                    end
                                end
                            end
                        end
                    end
                end
                
                -- ESP для ключей
                if MainModule.Misc.ESPKeys then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and (obj.Name:lower():find("key") or obj.Name:lower():find("ключ")) then
                            local cacheKey = "key_" .. HttpService:GenerateGUID(false)
                            local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                            
                            if primaryPart then
                                if not MainModule.ESPCache[cacheKey] or tick() - MainModule.ESPCache[cacheKey] > 5 then
                                    -- Создаем Highlight для ключа
                                    if not MainModule.ESPTable[cacheKey] then
                                        local highlight = Instance.new("Highlight")
                                        highlight.Name = "ESP_Key"
                                        highlight.Adornee = obj
                                        highlight.FillColor = Color3.fromRGB(255, 165, 0)
                                        highlight.FillTransparency = 0.3
                                        highlight.OutlineColor = Color3.fromRGB(255, 165, 0)
                                        highlight.OutlineTransparency = 0
                                        highlight.Enabled = true
                                        highlight.Parent = MainModule.ESPFolder
                                        
                                        MainModule.ESPTable[cacheKey] = {
                                            Highlight = highlight,
                                            Destroy = function()
                                                if highlight then highlight:Destroy() end
                                            end
                                        }
                                    end
                                    
                                    MainModule.ESPCache[cacheKey] = tick()
                                end
                            end
                        end
                    end
                end
            end)
        end)
    else
        -- Очищаем все ESP
        for _, esp in pairs(MainModule.ESPTable) do
            if esp and esp.Destroy then
                pcall(function() esp:Destroy() end)
            end
        end
        MainModule.ESPTable = {}
        MainModule.ESPCache = {}
        
        if MainModule.ESPFolder then
            MainModule.ESPFolder:Destroy()
            MainModule.ESPFolder = nil
        end
    end
end

-- ============================
-- ИСПРАВЛЕННЫЙ AUTO DODGE
-- ============================
function MainModule.ToggleAutoDodge(enabled)
    MainModule.HNS.AutoDodge = enabled
    
    if hnsAutoDodgeConnection then
        hnsAutoDodgeConnection:Disconnect()
        hnsAutoDodgeConnection = nil
    end
    
    if enabled then
        hnsAutoDodgeConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.AutoDodge then return end
            
            local currentTime = tick()
            
            -- Проверяем кулдаун (1 секунда)
            if currentTime - MainModule.HNS.LastDodgeTime < MainModule.HNS.DodgeCooldown then
                return
            end
            
            local character = LocalPlayer.Character
            if not character then return end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            
            if not rootPart or not humanoid or humanoid.Health <= 0 then return end
            
            -- Ищем ближайших ищущих с ножом
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local targetCharacter = player.Character
                    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
                    local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
                    
                    if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                        local distance = (rootPart.Position - targetRoot.Position).Magnitude
                        
                        -- Проверяем расстояние (15 метров)
                        if distance <= MainModule.HNS.DodgeRange then
                            -- Проверяем, является ли игрок ищущим
                            local isSeeker = player:GetAttribute("IsHunter") or false
                            
                            if isSeeker then
                                -- Проверяем, атакует ли он (по анимации или звуку)
                                local isAttacking = false
                                
                                -- Проверяем состояние анимации
                                local animator = targetHumanoid:FindFirstChildOfClass("Animator")
                                if animator then
                                    for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                                        local animName = track.Animation.Name:lower()
                                        if animName:find("attack") or animName:find("slash") or 
                                           animName:find("stab") or animName:find("knife") or
                                           animName:find("swing") or animName:find("hit") then
                                            isAttacking = true
                                            break
                                        end
                                    end
                                end
                                
                                -- Проверяем по звукам атаки
                                for _, sound in pairs(targetCharacter:GetDescendants()) do
                                    if sound:IsA("Sound") and sound.Playing then
                                        local soundName = sound.Name:lower()
                                        if soundName:find("attack") or soundName:find("slash") or 
                                           soundName:find("stab") or soundName:find("knife") or
                                           soundName:find("swing") or soundName:find("whoosh") then
                                            isAttacking = true
                                            break
                                        end
                                    end
                                end
                                
                                -- Проверяем в руках персонажа на нож
                                local hasKnife = false
                                for _, tool in pairs(targetCharacter:GetChildren()) do
                                    if tool:IsA("Tool") then
                                        local toolName = tool.Name:lower()
                                        if toolName:find("knife") or toolName:find("fork") or 
                                           toolName:find("dagger") or toolName:find("нож") then
                                            hasKnife = true
                                            break
                                        end
                                    end
                                end
                                
                                -- Проверяем в Backpack
                                if not hasKnife and player:FindFirstChild("Backpack") then
                                    for _, tool in pairs(player.Backpack:GetChildren()) do
                                        if tool:IsA("Tool") then
                                            local toolName = tool.Name:lower()
                                            if toolName:find("knife") or toolName:find("fork") or 
                                               toolName:find("dagger") or toolName:find("нож") then
                                                hasKnife = true
                                                break
                                            end
                                        end
                                    end
                                end
                                
                                -- Если ищущий имеет нож И атакует
                                if hasKnife and isAttacking then
                                    -- Уклоняемся независимо от того, куда он смотрит
                                    MainModule.PerformDodge()
                                    MainModule.HNS.LastDodgeTime = tick()
                                end
                            end
                        end
                    end
                end
            end
        end)
    else
        -- Очищаем отслеживаемых атакующих
        for player, data in pairs(MainModule.HNSTrackedAttackers) do
            if data.Connection then
                data.Connection:Disconnect()
            end
        end
        MainModule.HNSTrackedAttackers = {}
    end
end

function MainModule.PerformDodge()
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if not rootPart or not humanoid then return end
    
    -- 1. Прыжок
    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    
    -- 2. Быстрое движение в случайном направлении
    local randomAngle = math.random() * 2 * math.pi
    local teleportDistance = 5
    local offset = Vector3.new(
        math.cos(randomAngle) * teleportDistance,
        3,
        math.sin(randomAngle) * teleportDistance
    )
    
    local newPosition = rootPart.Position + offset
    
    -- Телепортируемся
    rootPart.CFrame = CFrame.new(newPosition)
    
    -- 3. Визуальный эффект
    task.spawn(function()
        local dodgeEffect = Instance.new("Part")
        dodgeEffect.Size = Vector3.new(1, 1, 1)
        dodgeEffect.Position = rootPart.Position
        dodgeEffect.Material = Enum.Material.Neon
        dodgeEffect.Color = Color3.fromRGB(0, 255, 255)
        dodgeEffect.Anchored = true
        dodgeEffect.CanCollide = false
        dodgeEffect.Shape = Enum.PartType.Ball
        dodgeEffect.Transparency = 0.3
        dodgeEffect.Parent = Workspace
        
        -- Анимация расширения
        TweenService:Create(
            dodgeEffect,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = Vector3.new(10, 10, 10), Transparency = 1}
        ):Play()
        
        game:GetService("Debris"):AddItem(dodgeEffect, 1)
    end)
end

-- ============================
-- ИСПРАВЛЕННЫЙ SPIKE KILL
-- ============================
function MainModule.ToggleSpikesKill(enabled)
    MainModule.HNS.SpikesKill = enabled
    
    if hnsSpikesKillConnection then
        hnsSpikesKillConnection:Disconnect()
        hnsSpikesKillConnection = nil
    end
    
    if enabled then
        -- При включении Spike Kill автоматически выключаем Disable Spikes если он был включен
        if MainModule.HNS.DisableSpikes then
            MainModule.HNS.DisableSpikes = false
            MainModule.ToggleDisableSpikes(false)
        end
        
        -- Сохраняем позиции шипов
        MainModule.HNSSpikes.Positions = {}
        MainModule.HNSSpikes.OriginalPositions = {}
        
        pcall(function()
            local spikes = Workspace:FindFirstChild("HideAndSeekMap") and 
                          Workspace.HideAndSeekMap:FindFirstChild("KillingParts")
            
            if spikes then
                for _, spike in pairs(spikes:GetChildren()) do
                    if spike:IsA("BasePart") then
                        table.insert(MainModule.HNSSpikes.Positions, spike.Position)
                        MainModule.HNSSpikes.OriginalPositions[spike] = spike.Position
                    end
                end
            end
        end)
        
        -- Запускаем процесс Spike Kill (только при анимации ножа)
        hnsSpikesKillConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.SpikesKill then return end
            if MainModule.HNS.IsInSpikeKillProcess then return end
            
            local character = LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then return end
            
            -- Проверяем, есть ли у нас нож и анимированы ли мы для атаки
            local hasKnife = false
            local isKnifeAnimating = false
            
            -- Проверяем анимацию ножа у нашего персонажа
            local animator = humanoid:FindFirstChildOfClass("Animator")
            if animator then
                for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                    local animName = track.Animation.Name:lower()
                    if animName:find("attack") or animName:find("slash") or 
                       animName:find("stab") or animName:find("knife") then
                        isKnifeAnimating = true
                        break
                    end
                end
            end
            
            -- Проверяем звуки атаки
            for _, sound in pairs(character:GetDescendants()) do
                if sound:IsA("Sound") and sound.Playing then
                    local soundName = sound.Name:lower()
                    if soundName:find("attack") or soundName:find("slash") or 
                       soundName:find("stab") or soundName:find("knife") then
                        isKnifeAnimating = true
                        break
                    end
                end
            end
            
            -- Если нет анимации ножа, выходим
            if not isKnifeAnimating then return end
            
            -- Проверяем, держим ли мы нож
            for _, tool in pairs(character:GetChildren()) do
                if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("dagger") or 
                   tool.Name:lower():find("fork") or tool.Name:lower():find("нож")) then
                    hasKnife = true
                    break
                end
            end
            
            -- Также проверяем Backpack
            if not hasKnife and LocalPlayer:FindFirstChild("Backpack") then
                for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("dagger") or 
                       tool.Name:lower():find("fork") or tool.Name:lower():find("нож")) then
                        hasKnife = true
                        break
                    end
                end
            end
            
            if not hasKnife then return end
            
            -- Ищем ближайшего живого игрока-прячущегося в радиусе удара (5 метров)
            local nearestHider = nil
            local nearestDistance = math.huge
            local targetRootPart = nil
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local targetCharacter = player.Character
                    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
                    local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
                    
                    -- Проверяем, является ли игрок прячущимся
                    local isHider = player:GetAttribute("IsHider") or false
                    
                    if targetRoot and targetHumanoid and targetHumanoid.Health > 0 and isHider then
                        local distance = (rootPart.Position - targetRoot.Position).Magnitude
                        
                        if distance < nearestDistance and distance < 5 then
                            nearestDistance = distance
                            nearestHider = player
                            targetRootPart = targetRoot
                        end
                    end
                end
            end
            
            -- Если нашли прячущегося в радиусе удара И у нас анимация ножа
            if nearestHider and targetRootPart and nearestDistance < 5 and isKnifeAnimating then
                MainModule.HNS.CurrentSpikeKillTarget = nearestHider
                MainModule.HNS.IsInSpikeKillProcess = true
                
                -- Телепортируем цель к шипам (если есть позиции шипов)
                if #MainModule.HNSSpikes.Positions > 0 then
                    local randomSpike = MainModule.HNSSpikes.Positions[math.random(1, #MainModule.HNSSpikes.Positions)]
                    targetRootPart.CFrame = CFrame.new(randomSpike)
                    
                    -- Ждем 0.5 секунды
                    task.wait(0.5)
                end
                
                -- Сбрасываем состояние
                MainModule.HNS.IsInSpikeKillProcess = false
            end
        end)
    else
        -- Сбрасываем состояние
        MainModule.HNS.CurrentSpikeKillTarget = nil
        MainModule.HNS.IsInSpikeKillProcess = false
        MainModule.HNS.OriginalSpikeKillPosition = nil
    end
end

-- ============================
-- ИСПРАВЛЕННЫЙ KILL HIDERS (KILLAURA SYSTEM)
-- ============================
function MainModule.ToggleKillHiders(enabled)
    MainModule.HNS.KillHiders = enabled
    
    if MainModule.KillHidersConnection then
        MainModule.KillHidersConnection:Disconnect()
        MainModule.KillHidersConnection = nil
    end
    
    if MainModule.KillHidersAttackLoop then
        MainModule.KillHidersAttackLoop:Disconnect()
        MainModule.KillHidersAttackLoop = nil
    end
    
    if enabled then
        -- Основной цикл для поиска целей
        MainModule.KillHidersConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.KillHiders then return end
            
            local character = LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then return end
            
            -- Ищем ближайшего живого игрока-прячущегося (радиус 100)
            local nearestHider = nil
            local nearestDistance = math.huge
            local targetRootPart = nil
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local targetCharacter = player.Character
                    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
                    local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
                    
                    -- Проверяем, является ли игрок прячущимся (хайдером)
                    local isHider = player:GetAttribute("IsHider") or false
                    
                    if targetRoot and targetHumanoid and targetHumanoid.Health > 0 and isHider then
                        local distance = (rootPart.Position - targetRoot.Position).Magnitude
                        
                        if distance < nearestDistance and distance < MainModule.HNS.KillHidersRange then
                            nearestDistance = distance
                            nearestHider = player
                            targetRootPart = targetRoot
                        end
                    end
                end
            end
            
            -- Если нашли новую цель
            if nearestHider and targetRootPart then
                MainModule.HNS.KillHidersTarget = nearestHider
                
                -- Если не следим за целью, начинаем слежение
                if not MainModule.HNS.FollowingTarget then
                    MainModule.HNS.FollowingTarget = true
                    MainModule.StartSmoothFollowing()
                end
            else
                -- Нет целей - останавливаем слежение
                MainModule.HNS.KillHidersTarget = nil
                MainModule.HNS.FollowingTarget = false
            end
        end)
        
        -- Цикл атаки
        MainModule.KillHidersAttackLoop = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.KillHiders then return end
            
            local currentTime = tick()
            if currentTime - MainModule.HNS.LastKillTime < MainModule.HNS.KillCooldown then return end
            
            local character = LocalPlayer.Character
            if not character then return end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then return end
            
            -- Проверяем, держим ли мы нож
            local hasKnife = false
            
            for _, tool in pairs(character:GetChildren()) do
                if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("dagger") or 
                   tool.Name:lower():find("fork") or tool.Name:lower():find("нож")) then
                    hasKnife = true
                    break
                end
            end
            
            -- Также проверяем Backpack
            if not hasKnife and LocalPlayer:FindFirstChild("Backpack") then
                for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("dagger") or 
                       tool.Name:lower():find("fork") or tool.Name:lower():find("нож")) then
                        hasKnife = true
                        break
                    end
                end
            end
            
            if not hasKnife then return end
            
            -- Если есть цель и мы следим за ней
            if MainModule.HNS.KillHidersTarget and MainModule.HNS.FollowingTarget then
                local targetCharacter = MainModule.HNS.KillHidersTarget.Character
                if not targetCharacter then
                    MainModule.HNS.KillHidersTarget = nil
                    MainModule.HNS.FollowingTarget = false
                    return
                end
                
                local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
                local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
                
                if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                    local distance = (character:FindFirstChild("HumanoidRootPart").Position - targetRoot.Position).Magnitude
                    
                    -- Атакуем если близко (до 5 метров)
                    if distance < 5 then
                        -- Атака ножом
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        task.wait(0.05)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                        
                        -- Специальные атаки
                        local attackKeys = {Enum.KeyCode.E, Enum.KeyCode.F, Enum.KeyCode.Q, Enum.KeyCode.R}
                        for _, key in pairs(attackKeys) do
                            VirtualInputManager:SendKeyEvent(true, key, false, game)
                            task.wait(0.02)
                            VirtualInputManager:SendKeyEvent(false, key, false, game)
                        end
                        
                        MainModule.HNS.LastKillTime = tick()
                    end
                else
                    -- Цель умерла или невалидна
                    MainModule.HNS.KillHidersTarget = nil
                    MainModule.HNS.FollowingTarget = false
                end
            end
        end)
    else
        -- Отключаем систему
        MainModule.HNS.KillHidersTarget = nil
        MainModule.HNS.FollowingTarget = false
    end
end

function MainModule.StartSmoothFollowing()
    task.spawn(function()
        while MainModule.HNS.KillHiders and MainModule.HNS.FollowingTarget and MainModule.HNS.KillHidersTarget do
            local currentTime = tick()
            
            -- Обновляем позицию каждые FollowUpdateRate секунд
            if currentTime - MainModule.HNS.LastFollowTime >= MainModule.HNS.FollowUpdateRate then
                MainModule.HNS.LastFollowTime = currentTime
                
                local character = LocalPlayer.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then break end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                
                if not humanoid or humanoid.Health <= 0 then break end
                
                local targetCharacter = MainModule.HNS.KillHidersTarget.Character
                if not targetCharacter then
                    MainModule.HNS.KillHidersTarget = nil
                    MainModule.HNS.FollowingTarget = false
                    break
                end
                
                local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
                local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
                
                if not targetRoot or not targetHumanoid or targetHumanoid.Health <= 0 then
                    MainModule.HNS.KillHidersTarget = nil
                    MainModule.HNS.FollowingTarget = false
                    break
                end
                
                local distance = (rootPart.Position - targetRoot.Position).Magnitude
                
                -- Если далеко (>10 метров), телепортируемся
                if distance > 10 then
                    -- Телепортируемся перед целью на расстоянии FollowDistance
                    local targetFront = targetRoot.CFrame.LookVector
                    local positionInFront = targetRoot.Position + (targetFront * MainModule.HNS.FollowDistance)
                    positionInFront = Vector3.new(positionInFront.X, targetRoot.Position.Y, positionInFront.Z)
                    
                    rootPart.CFrame = CFrame.new(positionInFront, targetRoot.Position)
                else
                    -- Плавно следуем перед целью
                    local targetFront = targetRoot.CFrame.LookVector
                    local desiredPosition = targetRoot.Position + (targetFront * MainModule.HNS.FollowDistance)
                    desiredPosition = Vector3.new(desiredPosition.X, targetRoot.Position.Y, desiredPosition.Z)
                    
                    -- Плавное перемещение
                    local currentPosition = rootPart.Position
                    local newPosition = currentPosition:Lerp(desiredPosition, MainModule.HNS.SmoothFollowSpeed)
                    
                    -- Поворачиваемся лицом к цели
                    rootPart.CFrame = CFrame.new(newPosition, targetRoot.Position)
                    
                    -- Идем к цели
                    humanoid:MoveTo(desiredPosition)
                end
            end
            
            task.wait(0.01)
        end
    end)
end

-- ============================
-- НЕВИДИМЫЕ ANTI-FALL ПЛАТФОРМЫ
-- ============================
function MainModule.CreateHugeAntiFallPlatform()
    if MainModule.GlassBridge.AntiFallPlatform then
        MainModule.GlassBridge.AntiFallPlatform:Destroy()
        MainModule.GlassBridge.AntiFallPlatform = nil
    end
    
    -- Создаем ОГРОМНУЮ платформу (200%) - НЕВИДИМУЮ
    MainModule.GlassBridge.AntiFallPlatform = Instance.new("Part")
    MainModule.GlassBridge.AntiFallPlatform.Name = "HugeGlassBridgeAntiFallPlatform"
    MainModule.GlassBridge.AntiFallPlatform.Size = Vector3.new(1000, 10, 1000)
    MainModule.GlassBridge.AntiFallPlatform.Position = Vector3.new(-200, 510, -1534)
    MainModule.GlassBridge.AntiFallPlatform.Anchored = true
    MainModule.GlassBridge.AntiFallPlatform.CanCollide = true
    MainModule.GlassBridge.AntiFallPlatform.Transparency = 1 -- Полностью прозрачная
    MainModule.GlassBridge.AntiFallPlatform.Material = Enum.Material.Plastic
    MainModule.GlassBridge.AntiFallPlatform.Color = Color3.fromRGB(0, 0, 0)
    MainModule.GlassBridge.AntiFallPlatform.Parent = Workspace
end

function MainModule.CreateSkySquidAntiFallPlatform()
    if MainModule.SkySquid.AntiFallPlatform then
        MainModule.SkySquid.AntiFallPlatform:Destroy()
        MainModule.SkySquid.AntiFallPlatform = nil
    end
    
    -- Создаем ОГРОМНУЮ Anti-Fall платформу для Sky Squid (200%) - НЕВИДИМУЮ
    MainModule.SkySquid.AntiFallPlatform = Instance.new("Part")
    MainModule.SkySquid.AntiFallPlatform.Name = "HugeSkySquidAntiFallPlatform"
    MainModule.SkySquid.AntiFallPlatform.Size = Vector3.new(500, 10, 500)
    MainModule.SkySquid.AntiFallPlatform.Position = Vector3.new(0, 90, 0)
    MainModule.SkySquid.AntiFallPlatform.Anchored = true
    MainModule.SkySquid.AntiFallPlatform.CanCollide = true
    MainModule.SkySquid.AntiFallPlatform.Transparency = 1 -- Полностью прозрачная
    MainModule.SkySquid.AntiFallPlatform.Material = Enum.Material.Plastic
    MainModule.SkySquid.AntiFallPlatform.Color = Color3.fromRGB(0, 0, 0)
    MainModule.SkySquid.AntiFallPlatform.Parent = Workspace
end

-- ============================
-- DISABLE SPIKES
-- ============================
function MainModule.ToggleDisableSpikes(enabled)
    MainModule.HNS.DisableSpikes = enabled
    
    if enabled then
        pcall(function()
            local spikes = Workspace:FindFirstChild("HideAndSeekMap") and 
                          Workspace.HideAndSeekMap:FindFirstChild("KillingParts")
            
            if spikes then
                for _, spike in pairs(spikes:GetChildren()) do
                    if spike:IsA("BasePart") then
                        spike.CanTouch = false
                        spike.Transparency = 1
                    end
                end
            end
        end)
    else
        pcall(function()
            local spikes = Workspace:FindFirstChild("HideAndSeekMap") and 
                          Workspace.HideAndSeekMap:FindFirstChild("KillingParts")
            
            if spikes then
                for _, spike in pairs(spikes:GetChildren()) do
                    if spike:IsA("BasePart") then
                        spike.CanTouch = true
                        spike.Transparency = 0
                    end
                end
            end
        end)
    end
end

-- ============================
-- JUMP ROPE ФУНКЦИИ
-- ============================
function MainModule.TeleportToJumpRopeEnd()
    local player = LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(737.156372, 193.805084, 920.952515)
    end
end

function MainModule.DeleteJumpRope()
    if Workspace:FindFirstChild("Effects") then
        local rope = Workspace.Effects:FindFirstChild("rope")
        if rope then
            rope:Destroy()
        end
    end
end

-- ============================
-- GLASS BRIDGE ФУНКЦИИ
-- ============================
function MainModule.ToggleAntiBreak(enabled)
    MainModule.GlassBridge.AntiBreak = enabled
    
    if antiBreakConnection then
        antiBreakConnection:Disconnect()
        antiBreakConnection = nil
    end
    
    if enabled then
        -- Создаем Fake Glass автоматически
        MainModule.CreateGlassBridgeCover()
        
        -- Создаем огромную Anti-Fall платформу (невидимую)
        MainModule.CreateHugeAntiFallPlatform()
        
        antiBreakConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.GlassBridge.AntiBreak then return end
            
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
        -- Удаляем покрытие и платформу
        MainModule.RemoveGlassBridgeCover()
        MainModule.RemoveHugeAntiFallPlatform()
    end
end

function MainModule.CreateGlassBridgeCover()
    if MainModule.GlassBridgeCover then
        MainModule.GlassBridgeCover:Destroy()
        MainModule.GlassBridgeCover = nil
    end
    
    local glassHolder = Workspace:FindFirstChild("GlassBridge") and Workspace.GlassBridge:FindFirstChild("GlassHolder")
    if not glassHolder then return end

    -- Создаем защитное покрытие
    MainModule.GlassBridgeCover = Instance.new("Part")
    MainModule.GlassBridgeCover.Name = "GlassBridgeCover"
    MainModule.GlassBridgeCover.Size = Vector3.new(150, 0.5, 150)
    MainModule.GlassBridgeCover.Position = Vector3.new(-200, 525, -1534)
    MainModule.GlassBridgeCover.Anchored = true
    MainModule.GlassBridgeCover.CanCollide = true
    MainModule.GlassBridgeCover.Transparency = 0.3
    MainModule.GlassBridgeCover.Material = Enum.Material.Glass
    MainModule.GlassBridgeCover.Color = Color3.fromRGB(100, 100, 255)
    MainModule.GlassBridgeCover.Parent = Workspace
    
    MainModule.GlassBridge.FakeGlassCover = true
end

function MainModule.RemoveGlassBridgeCover()
    if MainModule.GlassBridgeCover then
        MainModule.GlassBridgeCover:Destroy()
        MainModule.GlassBridgeCover = nil
    end
    
    MainModule.GlassBridge.FakeGlassCover = false
end

function MainModule.RemoveHugeAntiFallPlatform()
    if MainModule.GlassBridge.AntiFallPlatform then
        MainModule.GlassBridge.AntiFallPlatform:Destroy()
        MainModule.GlassBridge.AntiFallPlatform = nil
    end
end

function MainModule.ToggleGlassBridgeESP(enabled)
    MainModule.GlassBridge.GlassESPEnabled = enabled
    
    if glassBridgeESPConnection then
        glassBridgeESPConnection:Disconnect()
        glassBridgeESPConnection = nil
    end
    
    if enabled then
        local function updateGlassESP()
            pcall(function()
                local glassHolder = Workspace:FindFirstChild("GlassBridge") and Workspace.GlassBridge:FindFirstChild("GlassHolder")
                if not glassHolder then return end

                for _, tilePair in pairs(glassHolder:GetChildren()) do
                    for _, tileModel in pairs(tilePair:GetChildren()) do
                        if tileModel:IsA("Model") and tileModel.PrimaryPart then
                            local isBreakable = tileModel.PrimaryPart:GetAttribute("exploitingisevil") == true
                            local targetColor = isBreakable and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)

                            for _, part in pairs(tileModel:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.Color = targetColor
                                    part.Transparency = 0.5
                                    part.Material = Enum.Material.Neon
                                end
                            end
                        end
                    end
                end
            end)
        end
        
        -- Однократное применение ESP
        updateGlassESP()
    else
        -- Восстанавливаем оригинальный вид
        pcall(function()
            local glassHolder = Workspace:FindFirstChild("GlassBridge") and Workspace.GlassBridge:FindFirstChild("GlassHolder")
            if not glassHolder then return end

            for _, tilePair in pairs(glassHolder:GetChildren()) do
                for _, tileModel in pairs(tilePair:GetChildren()) do
                    if tileModel:IsA("Model") and tileModel.PrimaryPart then
                        for _, part in pairs(tileModel:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.Color = Color3.fromRGB(163, 162, 165)
                                part.Transparency = 0
                                part.Material = Enum.Material.Glass
                            end
                        end
                    end
                end
            end
        end)
    end
end

-- ============================
-- SKY SQUID ФУНКЦИИ
-- ============================
function MainModule.ToggleSkySquidAntiFall(enabled)
    MainModule.SkySquid.AntiFall = enabled
    
    if skySquidAntiFallConnection then
        skySquidAntiFallConnection:Disconnect()
        skySquidAntiFallConnection = nil
    end
    
    if enabled then
        -- Создаем огромную Anti-Fall платформу для Sky Squid (невидимую)
        MainModule.CreateSkySquidAntiFallPlatform()
        
        skySquidAntiFallConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.SkySquid.AntiFall then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if not rootPart then return end
                
                -- Если упали ниже высоты 50
                if rootPart.Position.Y < 50 then
                    rootPart.CFrame = CFrame.new(0, 200, 0)
                end
            end)
        end)
    else
        -- Удаляем платформу
        if MainModule.SkySquid.AntiFallPlatform then
            MainModule.SkySquid.AntiFallPlatform:Destroy()
            MainModule.SkySquid.AntiFallPlatform = nil
        end
    end
end

function MainModule.ToggleSkySquidVoidKill(enabled)
    MainModule.SkySquid.VoidKill = enabled
    
    if skySquidVoidKillConnection then
        skySquidVoidKillConnection:Disconnect()
        skySquidVoidKillConnection = nil
    end
    
    if enabled then
        -- Создаем Safe Platform при включении Void Kill
        MainModule.CreateSkySquidSafePlatform()
        
        skySquidVoidKillConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.SkySquid.VoidKill then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if not rootPart then return end
                
                -- Ищем ближайших игроков для телепортации в бездну
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                        if targetRoot then
                            local distance = (rootPart.Position - targetRoot.Position).Magnitude
                            
                            -- Если игрок в радиусе 15 метров
                            if distance < 15 then
                                -- Телепортируем его в бездну
                                local voidPosition = Vector3.new(0, -10000, 0)
                                targetRoot.CFrame = CFrame.new(voidPosition)
                                
                                -- Создаем платформу под ним
                                local platform = Instance.new("Part")
                                platform.Name = "VoidPlatform_" .. player.Name
                                platform.Size = Vector3.new(20, 5, 20)
                                platform.Position = voidPosition - Vector3.new(0, 3, 0)
                                platform.Anchored = true
                                platform.CanCollide = true
                                platform.Transparency = 0.5
                                platform.Material = Enum.Material.Neon
                                platform.Color = Color3.fromRGB(255, 0, 255)
                                platform.Parent = Workspace
                                
                                -- Удаляем платформу через 10 секунд
                                delay(10, function()
                                    if platform and platform.Parent then
                                        platform:Destroy()
                                    end
                                end)
                            end
                        end
                    end
                end
            end)
        end)
    else
        -- Удаляем Safe Platform
        if MainModule.SkySquid.SafePlatform then
            MainModule.SkySquid.SafePlatform:Destroy()
            MainModule.SkySquid.SafePlatform = nil
        end
    end
end

function MainModule.CreateSkySquidSafePlatform()
    if MainModule.SkySquid.SafePlatform then
        MainModule.SkySquid.SafePlatform:Destroy()
        MainModule.SkySquid.SafePlatform = nil
    end
    
    -- Создаем Safe Platform
    MainModule.SkySquid.SafePlatform = Instance.new("Part")
    MainModule.SkySquid.SafePlatform.Name = "SkySquidSafePlatform"
    MainModule.SkySquid.SafePlatform.Size = Vector3.new(50, 5, 50)
    MainModule.SkySquid.SafePlatform.Position = Vector3.new(0, 200, 0)
    MainModule.SkySquid.SafePlatform.Anchored = true
    MainModule.SkySquid.SafePlatform.CanCollide = true
    MainModule.SkySquid.SafePlatform.Transparency = 0.3
    MainModule.SkySquid.SafePlatform.Material = Enum.Material.Neon
    MainModule.SkySquid.SafePlatform.Color = Color3.fromRGB(0, 0, 255)
    MainModule.SkySquid.SafePlatform.Parent = Workspace
end

-- ============================
-- ВСПОМОГАТЕЛЬНАЯ ФУНКЦИЯ ЗАДЕРЖКИ
-- ============================
local function delay(seconds, callback)
    task.spawn(function()
        task.wait(seconds)
        pcall(callback)
    end)
end

-- ============================
-- ФУНКЦИИ СКОРОСТИ
-- ============================
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

-- ============================
-- ФУНКЦИИ ТЕЛЕПОРТАЦИИ
-- ============================
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

-- ============================
-- ANTI STUN QTE ФУНКЦИЯ
-- ============================
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

-- ============================
-- ANTI STUN + ANTI RAGDOLL ФУНКЦИЯ
-- ============================
function MainModule.ToggleAntiStunRagdoll(enabled)
    MainModule.Misc.AntiStunRagdoll = enabled
    
    if antiStunRagdollConnection then
        antiStunRagdollConnection:Disconnect()
        antiStunRagdollConnection = nil
    end
    
    if enabled then
        antiStunRagdollConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.Misc.AntiStunRagdoll then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if not humanoid then return end
                
                -- Восстанавливаем из рагдолла/стана
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

-- ============================
-- REBEL ФУНКЦИЯ
-- ============================
function MainModule.ToggleRebel(enabled)
    MainModule.Rebel.Enabled = enabled
    _G.InstantRebel = enabled
end

-- ============================
-- RLGL ФУНКЦИИ
-- ============================
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
    
    if godModeConnection then
        godModeConnection:Disconnect()
        godModeConnection = nil
    end
    
    if enabled then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            MainModule.RLGL.OriginalHeight = character.HumanoidRootPart.Position.Y
            local currentPos = character.HumanoidRootPart.Position
            character.HumanoidRootPart.CFrame = CFrame.new(currentPos.X, 1184.9, currentPos.Z)
        end
    else
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") and MainModule.RLGL.OriginalHeight then
            local currentPos = character.HumanoidRootPart.Position
            character.HumanoidRootPart.CFrame = CFrame.new(currentPos.X, MainModule.RLGL.OriginalHeight, currentPos.Z)
        end
    end
end

-- ============================
-- GUARDS ФУНКЦИИ
-- ============================
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

-- ============================
-- RAPID FIRE ФУНКЦИЯ
-- ============================
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
            local weaponsFolder = ReplicatedStorage:FindFirstChild("Weapons")
            if weaponsFolder then
                local gunsFolder = weaponsFolder:FindFirstChild("Guns")
                if gunsFolder then
                    for _, obj in ipairs(gunsFolder:GetDescendants()) do
                        if obj.Name == "FireRateCD" and (obj:IsA("NumberValue") or obj:IsA("IntValue")) then
                            if MainModule.Guards.OriginalFireRates[obj] then
                                obj.Value = MainModule.Guards.OriginalFireRates[obj]
                            else
                                obj.Value = 0.5 -- Дефолтное значение
                            end
                        end
                    end
                end
            end
        end)
    end
end

-- ============================
-- INFINITE AMMO ФУНКЦИЯ
-- ============================
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
                                    obj.Value = math.huge
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end

-- ============================
-- HITBOX EXPANDER ФУНКЦИЯ
-- ============================
function MainModule.ToggleHitboxExpander(enabled)
    MainModule.Guards.HitboxExpander = enabled
    
    if hitboxConnection then
        hitboxConnection:Disconnect()
        hitboxConnection = nil
    end
    
    -- Восстанавливаем оригинальные размеры перед изменением
    if MainModule.Guards.OriginalHitboxes then
        for player, originalSizes in pairs(MainModule.Guards.OriginalHitboxes) do
            if player and player.Character then
                for partName, originalSize in pairs(originalSizes) do
                    local part = player.Character:FindFirstChild(partName)
                    if part and part:IsA("BasePart") then
                        part.Size = originalSize
                        part.Transparency = 0
                        part.CanCollide = true
                    end
                end
            end
        end
        MainModule.Guards.OriginalHitboxes = {}
    end
    
    if enabled then
        local HITBOX_SIZE = 1000
        
        hitboxConnection = RunService.RenderStepped:Connect(function()
            if not MainModule.Guards.HitboxExpander then return end
            
            pcall(function()
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        -- Сохраняем оригинальные размеры если еще не сохранены
                        if not MainModule.Guards.OriginalHitboxes[player] then
                            MainModule.Guards.OriginalHitboxes[player] = {}
                            
                            -- Сохраняем размеры всех основных частей тела
                            local bodyParts = {"Head", "Torso", "HumanoidRootPart", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
                            for _, partName in pairs(bodyParts) do
                                local part = player.Character:FindFirstChild(partName)
                                if part and part:IsA("BasePart") then
                                    MainModule.Guards.OriginalHitboxes[player][partName] = part.Size
                                end
                            end
                        end
                        
                        -- Увеличиваем размеры всех основных частей тела
                        local bodyParts = {"Head", "Torso", "HumanoidRootPart", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
                        for _, partName in pairs(bodyParts) do
                            local part = player.Character:FindFirstChild(partName)
                            if part and part:IsA("BasePart") then
                                -- Увеличиваем размер до HITBOX_SIZE
                                part.Size = Vector3.new(HITBOX_SIZE, HITBOX_SIZE, HITBOX_SIZE)
                                -- Делаем полностью прозрачным
                                part.Transparency = 1
                                -- Отключаем коллизию
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end)
        end)
    else
        -- Восстанавливаем оригинальные размеры
        pcall(function()
            for player, originalSizes in pairs(MainModule.Guards.OriginalHitboxes) do
                if player and player.Character then
                    for partName, originalSize in pairs(originalSizes) do
                        local part = player.Character:FindFirstChild(partName)
                        if part and part:IsA("BasePart") then
                            part.Size = originalSize
                            part.Transparency = 0
                            part.CanCollide = true
                        end
                    end
                end
            end
            MainModule.Guards.OriginalHitboxes = {}
        end)
    end
end

-- ============================
-- DALGONA ФУНКЦИИ
-- ============================
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

-- ============================
-- TUG OF WAR ФУНКЦИИ
-- ============================
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

-- ============================
-- MISC ФУНКЦИИ
-- ============================
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

-- ============================
-- ФУНКЦИЯ ДЛЯ ПОЛУЧЕНИЯ КООРДИНАТ
-- ============================
function MainModule.GetPlayerPosition()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local position = character.HumanoidRootPart.Position
        return string.format("X: %.1f, Y: %.1f, Z: %.1f", position.X, position.Y, position.Z)
    end
    return "Не доступно"
end

-- ============================
-- ОЧИСТКА ПРИ ЗАКРЫТИИ
-- ============================
function MainModule.Cleanup()
    -- Отключаем все соединения
    local connections = {
        speedConnection, autoFarmConnection, godModeConnection, instaInteractConnection,
        noCooldownConnection, antiStunConnection, rapidFireConnection, infiniteAmmoConnection,
        hitboxConnection, autoPullConnection, antiBreakConnection, MainModule.ESPConnection,
        hnsSpikesKillConnection, hnsAutoDodgeConnection, glassBridgeESPConnection,
        antiStunRagdollConnection, skySquidAntiFallConnection, skySquidVoidKillConnection,
        MainModule.KillHidersConnection, MainModule.KillHidersAttackLoop
    }
    
    for _, conn in pairs(connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    
    -- Очищаем Auto Dodge tracking
    for player, data in pairs(MainModule.HNSTrackedAttackers) do
        if data.Connection then
            pcall(function() data.Connection:Disconnect() end)
        end
    end
    MainModule.HNSTrackedAttackers = {}
    
    -- Восстанавливаем хитбоксы
    if MainModule.Guards.OriginalHitboxes then
        for player, originalSizes in pairs(MainModule.Guards.OriginalHitboxes) do
            if player and player.Character then
                for partName, originalSize in pairs(originalSizes) do
                    local part = player.Character:FindFirstChild(partName)
                    if part and part:IsA("BasePart") then
                        part.Size = originalSize
                        part.Transparency = 0
                        part.CanCollide = true
                    end
                end
            end
        end
        MainModule.Guards.OriginalHitboxes = {}
    end
    
    -- Очищаем ESP
    if MainModule.Misc.ESPEnabled then
        MainModule.ToggleESP(false)
    end
    
    -- Удаляем папку ESP
    if MainModule.ESPFolder then
        MainModule.ESPFolder:Destroy()
        MainModule.ESPFolder = nil
    end
    
    -- Удаляем Glass Bridge объекты
    if MainModule.GlassBridgeCover then
        MainModule.GlassBridgeCover:Destroy()
        MainModule.GlassBridgeCover = nil
    end
    
    if MainModule.GlassBridge.AntiFallPlatform then
        MainModule.GlassBridge.AntiFallPlatform:Destroy()
        MainModule.GlassBridge.AntiFallPlatform = nil
    end
    
    -- Удаляем Sky Squid объекты
    if MainModule.SkySquid.AntiFallPlatform then
        MainModule.SkySquid.AntiFallPlatform:Destroy()
        MainModule.SkySquid.AntiFallPlatform = nil
    end
    
    if MainModule.SkySquid.SafePlatform then
        MainModule.SkySquid.SafePlatform:Destroy()
        MainModule.SkySquid.SafePlatform = nil
    end
    
    -- Восстанавливаем шипы
    if MainModule.HNS.DisableSpikes then
        MainModule.ToggleDisableSpikes(false)
    end
    
    -- Удаляем Glass Bridge защитные платформы
    for _, platform in pairs(MainModule.GlassBridgePlatforms) do
        if platform and platform.Parent then
            platform:Destroy()
        end
    end
    MainModule.GlassBridgePlatforms = {}
    
    -- Сбрасываем HNS состояния
    MainModule.HNS.CurrentSpikeKillTarget = nil
    MainModule.HNS.IsInSpikeKillProcess = false
    MainModule.HNS.OriginalSpikeKillPosition = nil
    MainModule.HNS.CurrentKillTarget = nil
    MainModule.HNS.KillHidersTarget = nil
    MainModule.HNS.FollowingTarget = false
end

-- ============================
-- АВТОМАТИЧЕСКАЯ ОЧИСТКА ПРИ ВЫХОДЕ
-- ============================
game:GetService("Players").LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not game:GetService("Players").LocalPlayer.Parent then
        MainModule.Cleanup()
    end
end)

return MainModule
