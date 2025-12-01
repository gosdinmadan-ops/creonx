-- Main.lua - Creon X v2.1 (исправленная версия)
local MainModule = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
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
    AntiStunEnabled = false,
    SkySquidQTEEnabled = false  -- Новая переменная для Sky Squid QTE
}

MainModule.Rebel = {
    Enabled = false,
    InfiniteAmmo = false,
    RapidFire = false
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
    AutoPickup = false,
    SpikesKill = false,
    DisableSpikes = false,
    KillHiders = false,
    AutoDodge = false
}

MainModule.TugOfWar = {
    AutoPull = false
}

MainModule.GlassBridge = {
    AntiBreak = false,
    GlassESPEnabled = false,
    SafePlatforms = {}  -- Для AntiBreak
}

MainModule.JumpRope = {
    AntiFail = false,
    TeleportToStart = false,
    TeleportToEnd = false
}

-- Sky Squid Game переменные
MainModule.SkySquid = {
    AntiFall = false,
    AutoQTE = false,
    SafePlatform = false,
    VoidKill = false,
    AntiFallPlatform = nil,
    SafePlatforms = {},
    TeleportCooldown = false
}

-- Squid Game переменные
MainModule.SquidGame = {
    -- Можно добавить функции позже
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

-- ESP System (сильно оптимизированная)
MainModule.ESPTable = {}
MainModule.ESPFolder = nil
MainModule.ESPUpdateRate = 2.0  -- Обновление раз в 2 секунды (было 0.3)
MainModule.LastESPUpdate = 0
MainModule.ESPConnection = nil

-- HNS шипы
MainModule.HNSSpikes = {
    Positions = {},
    OriginalPositions = {},
    Disabled = false
}

-- Anti-Fall платформы для разных игр
MainModule.AntiFallPlatforms = {
    JumpRope = nil,
    GlassBridge = nil,
    SkySquid = nil,
    Dalgona = nil
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
local hnsAutoPickupConnection = nil
local hnsSpikesKillConnection = nil
local hnsKillHidersConnection = nil
local hnsDisableSpikesConnection = nil
local jumpRopeAntiFailConnection = nil
local glassBridgeESPConnection = nil
local antiStunRagdollConnection = nil
local skySquidAntiFallConnection = nil
local skySquidQTEConnection = nil
local skySquidVoidKillConnection = nil
local skySquidSafePlatformConnection = nil

-- Локальный игрок
local LocalPlayer = Players.LocalPlayer

-- ===================================================================
-- ОПТИМИЗИРОВАННАЯ ESP СИСТЕМА (без лагов)
-- ===================================================================
function MainModule.ToggleESP(enabled)
    MainModule.Misc.ESPEnabled = enabled
    
    -- Отключаем старое соединение
    if MainModule.ESPConnection then
        MainModule.ESPConnection:Disconnect()
        MainModule.ESPConnection = nil
    end
    
    -- Очищаем старые ESP
    for _, esp in pairs(MainModule.ESPTable) do
        if esp and esp.Destroy then
            pcall(esp.Destroy)
        end
    end
    MainModule.ESPTable = {}
    
    -- Удаляем папку ESP
    if MainModule.ESPFolder then
        pcall(function() MainModule.ESPFolder:Destroy() end)
        MainModule.ESPFolder = nil
    end
    
    if not enabled then return end
    
    -- Создаем новую папку ESP
    MainModule.ESPFolder = Instance.new("Folder")
    MainModule.ESPFolder.Name = "CreonESP"
    MainModule.ESPFolder.Parent = Workspace
    
    -- ОПТИМИЗИРОВАННОЕ обновление ESP раз в 2 секунды
    MainModule.ESPConnection = RunService.RenderStepped:Connect(function()
        local currentTime = tick()
        if currentTime - MainModule.LastESPUpdate < MainModule.ESPUpdateRate then
            return
        end
        MainModule.LastESPUpdate = currentTime
        
        -- Очищаем только если слишком много объектов
        if #MainModule.ESPTable > 50 then
            for i = 1, math.min(10, #MainModule.ESPTable) do
                local esp = MainModule.ESPTable[i]
                if esp and esp.Destroy then
                    pcall(esp.Destroy)
                end
                MainModule.ESPTable[i] = nil
            end
        end
        
        -- ESP для игроков
        if MainModule.Misc.ESPPlayers then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                        if rootPart then
                            local espId = "player_" .. player.UserId
                            
                            if not MainModule.ESPTable[espId] then
                                -- Создаем ESP только если его нет
                                local highlight = Instance.new("Highlight")
                                highlight.Name = "ESP_Highlight"
                                highlight.Adornee = player.Character
                                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                highlight.FillColor = Color3.fromRGB(0, 170, 255)
                                highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
                                highlight.OutlineColor = Color3.fromRGB(0, 170, 255)
                                highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
                                highlight.Enabled = MainModule.Misc.ESPHighlight and MainModule.Misc.ESPBoxes
                                highlight.Parent = MainModule.ESPFolder
                                
                                local billboard = Instance.new("BillboardGui")
                                billboard.Name = "ESP_Billboard"
                                billboard.Adornee = rootPart
                                billboard.AlwaysOnTop = true
                                billboard.Size = UDim2.new(0, 200, 0, 50)
                                billboard.StudsOffset = Vector3.new(0, 3, 0)
                                billboard.Parent = MainModule.ESPFolder
                                
                                local textLabel = Instance.new("TextLabel")
                                textLabel.Name = "ESP_Text"
                                textLabel.BackgroundTransparency = 1
                                textLabel.Size = UDim2.new(1, 0, 1, 0)
                                textLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
                                textLabel.TextSize = MainModule.Misc.ESPTextSize
                                textLabel.Font = Enum.Font.GothamBold
                                textLabel.TextStrokeTransparency = 0.3
                                textLabel.Parent = billboard
                                
                                MainModule.ESPTable[espId] = {
                                    Highlight = highlight,
                                    Billboard = billboard,
                                    TextLabel = textLabel,
                                    Player = player,
                                    Destroy = function()
                                        pcall(function()
                                            if highlight then highlight:Destroy() end
                                            if billboard then billboard:Destroy() end
                                        end)
                                    end
                                }
                            end
                            
                            -- Обновляем текст
                            local espData = MainModule.ESPTable[espId]
                            if espData and espData.TextLabel then
                                local name = MainModule.Misc.ESPNames and player.DisplayName or ""
                                local health = humanoid.Health
                                local distance = ""
                                
                                if MainModule.Misc.ESPDistance then
                                    local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                    if localRoot then
                                        local dist = math.floor((localRoot.Position - rootPart.Position).Magnitude)
                                        distance = " [" .. dist .. " studs]"
                                    end
                                end
                                
                                espData.TextLabel.Text = name .. " [HP: " .. math.floor(health) .. "]" .. distance
                            end
                        end
                    end
                end
            end
        end
        
        -- Удаляем ESP для игроков которые вышли
        for espId, espData in pairs(MainModule.ESPTable) do
            if espId:find("player_") then
                local playerId = tonumber(espId:match("player_(%d+)"))
                local player = Players:GetPlayerByUserId(playerId)
                if not player or not player.Character or not player.Character:FindFirstChild("Humanoid") then
                    if espData.Destroy then
                        pcall(espData.Destroy)
                    end
                    MainModule.ESPTable[espId] = nil
                end
            end
        end
    end)
end

-- ===================================================================
-- ФУНКЦИИ СКОРОСТИ
-- ===================================================================
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

-- ===================================================================
-- ТЕЛЕПОРТАЦИЯ
-- ===================================================================
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

-- ===================================================================
-- ANTI STUN QTE (для всех игр)
-- ===================================================================
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

-- ===================================================================
-- SKY SQUID AUTO QTE
-- ===================================================================
function MainModule.ToggleSkySquidQTE(enabled)
    MainModule.AutoQTE.SkySquidQTEEnabled = enabled
    
    if skySquidQTEConnection then
        skySquidQTEConnection:Disconnect()
        skySquidQTEConnection = nil
    end
    
    if enabled then
        skySquidQTEConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.AutoQTE.SkySquidQTEEnabled then return end
            
            pcall(function()
                local gui = LocalPlayer.PlayerGui
                if not gui then return end
                
                local screenGui = gui:FindFirstChild("ScreenGui") or gui:FindFirstChild("QTE")
                if screenGui then
                    for _, element in pairs(screenGui:GetDescendants()) do
                        if element:IsA("TextButton") or element:IsA("ImageButton") then
                            local buttonText = element.Text or element.Name
                            if buttonText:match("[FEQR]") or element:FindFirstChild("QTE") then
                                local absolutePosition = element.AbsolutePosition
                                local absoluteSize = element.AbsoluteSize
                                
                                local centerY = absolutePosition.Y + (absoluteSize.Y / 2)
                                if centerY > 350 and centerY < 450 then
                                    local keyToPress = nil
                                    
                                    if buttonText:find("F") then
                                        keyToPress = Enum.KeyCode.F
                                    elseif buttonText:find("E") then
                                        keyToPress = Enum.KeyCode.E
                                    elseif buttonText:find("Q") then
                                        keyToPress = Enum.KeyCode.Q
                                    elseif buttonText:find("R") then
                                        keyToPress = Enum.KeyCode.R
                                    else
                                        keyToPress = Enum.KeyCode.F
                                    end
                                    
                                    if keyToPress then
                                        VirtualInputManager:SendKeyEvent(true, keyToPress, false, game)
                                        task.wait(0.05)
                                        VirtualInputManager:SendKeyEvent(false, keyToPress, false, game)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end)
    end
end

-- ===================================================================
-- ANTI STUN + ANTI RAGDOLL
-- ===================================================================
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

-- ===================================================================
-- REBEL ФУНКЦИИ
-- ===================================================================
function MainModule.ToggleRebel(enabled)
    MainModule.Rebel.Enabled = enabled
    _G.InstantRebel = enabled
end

function MainModule.ToggleRebelInfiniteAmmo(enabled)
    MainModule.Rebel.InfiniteAmmo = enabled
    
    -- Просто передаем в Guards если нужно
    MainModule.ToggleInfiniteAmmo(enabled)
end

function MainModule.ToggleRebelRapidFire(enabled)
    MainModule.Rebel.RapidFire = enabled
    
    -- Просто передаем в Guards если нужно
    MainModule.ToggleRapidFire(enabled)
end

-- ===================================================================
-- RLGL ФУНКЦИИ
-- ===================================================================
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

-- ===================================================================
-- GUARDS ФУНКЦИИ
-- ===================================================================
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

-- ===================================================================
-- HITBOX EXPANDER (исправленная версия)
-- ===================================================================
function MainModule.ToggleHitboxExpander(enabled)
    MainModule.Guards.HitboxExpander = enabled
    
    if hitboxConnection then
        hitboxConnection:Disconnect()
        hitboxConnection = nil
    end
    
    -- Глобальные переменные для Hitbox Expander
    _G.HeadSize = 1000
    _G.HitboxExpanderEnabled = enabled
    
    if not enabled then
        -- Восстанавливаем оригинальные размеры
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root and root:IsA("BasePart") then
                    pcall(function()
                        root.Size = Vector3.new(2, 2, 1)
                        root.CanCollide = true
                        root.Transparency = 0
                    end)
                end
            end
        end
        return
    end
    
    -- Функция для изменения хитбокса
    local function modifyHitbox(rootPart)
        if not rootPart or not rootPart:IsA("BasePart") then return end
        
        pcall(function()
            rootPart.Size = Vector3.new(_G.HeadSize, _G.HeadSize, _G.HeadSize)
            rootPart.CanCollide = false
            rootPart.Transparency = 1
        end)
    end
    
    -- Обработчик для новых игроков
    local function onPlayerAdded(player)
        if player == LocalPlayer then return end
        
        player.CharacterAdded:Connect(function(character)
            if not _G.HitboxExpanderEnabled then return end
            
            local root = character:WaitForChild("HumanoidRootPart", 5)
            if root then
                modifyHitbox(root)
            end
        end)
    end
    
    -- Обработчик для существующих игроков
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                modifyHitbox(root)
            end
        end
        onPlayerAdded(player)
    end
    
    -- Основной цикл с оптимизацией
    hitboxConnection = RunService.RenderStepped:Connect(function()
        if not _G.HitboxExpanderEnabled then return end
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root and root:IsA("BasePart") then
                    pcall(function()
                        if root.Size.X < _G.HeadSize then
                            root.Size = Vector3.new(_G.HeadSize, _G.HeadSize, _G.HeadSize)
                            root.CanCollide = false
                            root.Transparency = 1
                        end
                    end)
                end
            end
        end
    end)
    
    -- Очистка при выходе игрока
    Players.PlayerRemoving:Connect(function(player)
        if player == LocalPlayer then return end
        
        if player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root and root:IsA("BasePart") then
                pcall(function()
                    root.Size = Vector3.new(2, 2, 1)
                    root.CanCollide = true
                    root.Transparency = 0
                end)
            end
        end
    end)
end

-- ===================================================================
-- DALGONA ФУНКЦИИ
-- ===================================================================
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

-- ===================================================================
-- HNS ФУНКЦИИ
-- ===================================================================
function MainModule.ToggleAutoPickup(enabled)
    MainModule.HNS.AutoPickup = enabled
    
    if hnsAutoPickupConnection then
        hnsAutoPickupConnection:Disconnect()
        hnsAutoPickupConnection = nil
    end
    
    if enabled then
        hnsAutoPickupConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.AutoPickup then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                local isHider = LocalPlayer:GetAttribute("IsHider")
                if not isHider then return end
                
                -- Ищем ключи
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj.Name:lower():find("key") and obj.PrimaryPart then
                        local distance = (character.HumanoidRootPart.Position - obj.PrimaryPart.Position).Magnitude
                        if distance < 10 then
                            character.HumanoidRootPart.CFrame = obj.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
                            task.wait(0.2)
                        end
                    end
                end
            end)
        end)
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
            local spikes = Workspace:FindFirstChild("HideAndSeekMap") and 
                          Workspace.HideAndSeekMap:FindFirstChild("KillingParts")
            
            if spikes then
                for _, spike in pairs(spikes:GetChildren()) do
                    if spike:IsA("BasePart") then
                        table.insert(MainModule.HNSSpikes.Positions, spike.Position)
                        MainModule.HNSSpikes.OriginalPositions[spike] = spike.Position
                        
                        -- Делаем шипы безопасными для нас
                        spike.CanTouch = false
                    end
                end
            end
        end)
        
        hnsSpikesKillConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.SpikesKill then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                local isHunter = LocalPlayer:GetAttribute("IsHunter")
                if isHunter and #MainModule.HNSSpikes.Positions > 0 then
                    -- Ищем хайдеров для телепортации в шипы
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player:GetAttribute("IsHider") and 
                           player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                           
                            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                            if humanoid and humanoid.Health > 0 then
                                local randomSpike = MainModule.HNSSpikes.Positions[math.random(1, #MainModule.HNSSpikes.Positions)]
                                player.Character.HumanoidRootPart.CFrame = CFrame.new(randomSpike)
                            end
                        end
                    end
                end
                
                -- Продолжаем защищать себя от шипов
                local spikes = Workspace:FindFirstChild("HideAndSeekMap") and 
                              Workspace.HideAndSeekMap:FindFirstChild("KillingParts")
                
                if spikes then
                    for _, spike in pairs(spikes:GetChildren()) do
                        if spike:IsA("BasePart") then
                            spike.CanTouch = false
                        end
                    end
                end
            end)
        end)
    else
        -- Восстанавливаем шипы
        pcall(function()
            local spikes = Workspace:FindFirstChild("HideAndSeekMap") and 
                          Workspace.HideAndSeekMap:FindFirstChild("KillingParts")
            
            if spikes then
                for _, spike in pairs(spikes:GetChildren()) do
                    if spike:IsA("BasePart") then
                        spike.CanTouch = true
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
    MainModule.HNSSpikes.Disabled = enabled
    
    if hnsDisableSpikesConnection then
        hnsDisableSpikesConnection:Disconnect()
        hnsDisableSpikesConnection = nil
    end
    
    if enabled then
        -- Сохраняем позиции шипов перед удалением
        pcall(function()
            local spikes = Workspace:FindFirstChild("HideAndSeekMap") and 
                          Workspace.HideAndSeekMap:FindFirstChild("KillingParts")
            
            if spikes then
                for _, spike in pairs(spikes:GetChildren()) do
                    if spike:IsA("BasePart") then
                        table.insert(MainModule.HNSSpikes.Positions, spike.Position)
                        MainModule.HNSSpikes.OriginalPositions[spike] = spike.Position
                        spike:Destroy() -- Удаляем шипы
                    end
                end
            end
        end)
        
        hnsDisableSpikesConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.DisableSpikes then return end
            
            pcall(function()
                local spikes = Workspace:FindFirstChild("HideAndSeekMap") and 
                              Workspace.HideAndSeekMap:FindFirstChild("KillingParts")
                
                if spikes then
                    for _, spike in pairs(spikes:GetChildren()) do
                        if spike:IsA("BasePart") then
                            spike:Destroy()
                        end
                    end
                end
            end)
        end)
    else
        -- Восстанавливаем шипы если были сохранены позиции
        pcall(function()
            local hideAndSeekMap = Workspace:FindFirstChild("HideAndSeekMap")
            if not hideAndSeekMap then return end
            
            local killingParts = hideAndSeekMap:FindFirstChild("KillingParts")
            if not killingParts then
                killingParts = Instance.new("Folder")
                killingParts.Name = "KillingParts"
                killingParts.Parent = hideAndSeekMap
            end
            
            for _, spikePos in pairs(MainModule.HNSSpikes.Positions) do
                local spike = Instance.new("Part")
                spike.Size = Vector3.new(10, 1, 10)
                spike.Position = spikePos
                spike.Anchored = true
                spike.CanCollide = true
                spike.Transparency = 0.3
                spike.Color = Color3.fromRGB(255, 0, 0)
                spike.Name = "Spike"
                spike.Parent = killingParts
            end
            
            MainModule.HNSSpikes.Positions = {}
            MainModule.HNSSpikes.OriginalPositions = {}
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
        hnsKillHidersConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.KillHiders then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                local isHunter = LocalPlayer:GetAttribute("IsHunter")
                if not isHunter then return end
                
                -- Ищем ближайшего хайдера
                local targetPlayer = nil
                local closestDistance = math.huge
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player:GetAttribute("IsHider") and 
                       player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                       
                        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            local distance = (character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                            if distance < closestDistance then
                                closestDistance = distance
                                targetPlayer = player
                            end
                        end
                    end
                end
                
                -- Телепортируемся к цели и атакуем
                if targetPlayer and targetPlayer.Character and closestDistance < 50 then
                    character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2)
                end
            end)
        end)
    end
end

function MainModule.ToggleAutoDodge(enabled)
    MainModule.HNS.AutoDodge = enabled
    -- Временно не реализовано
end

-- ===================================================================
-- TUG OF WAR ФУНКЦИИ
-- ===================================================================
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

-- ===================================================================
-- GLASS BRIDGE ФУНКЦИИ (исправленный AntiBreak)
-- ===================================================================
function MainModule.ToggleAntiBreak(enabled)
    MainModule.GlassBridge.AntiBreak = enabled
    
    if antiBreakConnection then
        antiBreakConnection:Disconnect()
        antiBreakConnection = nil
    end
    
    -- Очищаем старые безопасные платформы
    for _, platform in pairs(MainModule.GlassBridge.SafePlatforms) do
        if platform and platform.Parent then
            platform:Destroy()
        end
    end
    MainModule.GlassBridge.SafePlatforms = {}
    
    if not enabled then return end
    
    -- Создаем безопасные платформы под каждой стеклянной плиткой
    antiBreakConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.GlassBridge.AntiBreak then return end
        
        pcall(function()
            local GlassHolder = Workspace:FindFirstChild("GlassBridge") and Workspace.GlassBridge:FindFirstChild("GlassHolder")
            if not GlassHolder then return end
            
            -- Очищаем старые безопасные платформы
            for _, platform in pairs(MainModule.GlassBridge.SafePlatforms) do
                if platform and platform.Parent then
                    platform:Destroy()
                end
            end
            MainModule.GlassBridge.SafePlatforms = {}
            
            for _, tilePair in pairs(GlassHolder:GetChildren()) do
                for _, tileModel in pairs(tilePair:GetChildren()) do
                    if tileModel:IsA("Model") and tileModel.PrimaryPart then
                        local tileName = tileModel.Name
                        local safePlatformId = "SafePlatform_" .. tileName
                        
                        -- Создаем безопасную платформу если ее нет
                        if not MainModule.GlassBridge.SafePlatforms[safePlatformId] then
                            local safePlatform = Instance.new("Part")
                            safePlatform.Name = safePlatformId
                            safePlatform.Size = Vector3.new(14, 0.5, 14)  -- Немного больше чем плитка
                            safePlatform.Position = tileModel.PrimaryPart.Position - Vector3.new(0, 3, 0)  -- Под плиткой
                            safePlatform.Anchored = true
                            safePlatform.CanCollide = true
                            safePlatform.Transparency = 0.9  -- Почти невидимая
                            safePlatform.Material = Enum.Material.Neon
                            safePlatform.Color = Color3.fromRGB(0, 255, 0)  -- Зеленая
                            safePlatform.Parent = Workspace
                            
                            MainModule.GlassBridge.SafePlatforms[safePlatformId] = safePlatform
                        end
                    end
                end
            end
        end)
    end)
end

function MainModule.ToggleGlassBridgeESP(enabled)
    MainModule.GlassBridge.GlassESPEnabled = enabled
    
    if glassBridgeESPConnection then
        glassBridgeESPConnection:Disconnect()
        glassBridgeESPConnection = nil
    end
    
    if enabled then
        glassBridgeESPConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.GlassBridge.GlassESPEnabled then return end
            
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
                                    TweenService:Create(part, TweenInfo.new(0.5), {
                                        Transparency = 0.5,
                                        Color = targetColor
                                    }):Play()
                                end
                            end
                        end
                    end
                end
            end)
        end)
    end
end

-- ===================================================================
-- JUMP ROPE ФУНКЦИИ
-- ===================================================================
function MainModule.TeleportToJumpRopeStart()
    local player = LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(700.123, 198.456, 920.789)
    end
end

function MainModule.TeleportToJumpRopeEnd()
    local player = LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(750.654, 198.512, 921.234)
    end
end

function MainModule.ToggleAntiFailJumpRope(enabled)
    MainModule.JumpRope.AntiFail = enabled
    
    if jumpRopeAntiFailConnection then
        jumpRopeAntiFailConnection:Disconnect()
        jumpRopeAntiFailConnection = nil
    end
    
    if enabled then
        jumpRopeAntiFailConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.JumpRope.AntiFail then return end
            
            pcall(function()
                if Workspace:FindFirstChild("Values") then
                    local currentGame = Workspace.Values:FindFirstChild("CurrentGame")
                    if currentGame and currentGame.Value == "JumpRope" then
                        for _, obj in pairs(Workspace:GetDescendants()) do
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

-- ===================================================================
-- SKY SQUID GAME ФУНКЦИИ
-- ===================================================================
-- Anti Fall для Sky Squid
function MainModule.ToggleSkySquidAntiFall(enabled)
    MainModule.SkySquid.AntiFall = enabled
    
    if skySquidAntiFallConnection then
        skySquidAntiFallConnection:Disconnect()
        skySquidAntiFallConnection = nil
    end
    
    -- Удаляем старую платформу
    if MainModule.AntiFallPlatforms.SkySquid then
        MainModule.AntiFallPlatforms.SkySquid:Destroy()
        MainModule.AntiFallPlatforms.SkySquid = nil
    end
    
    if not enabled then return end
    
    -- Функция для поиска ближайшего живого игрока
    local function findNearestAlivePlayer()
        local character = LocalPlayer.Character
        if not character then return nil end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return nil end
        
        local nearestPlayer = nil
        local nearestDistance = math.huge
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                local targetHumanoid = player.Character:FindFirstChild("Humanoid")
                
                if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                    local distance = (rootPart.Position - targetRoot.Position).Magnitude
                    if distance < nearestDistance then
                        nearestDistance = distance
                        nearestPlayer = player
                    end
                end
            end
        end
        
        return nearestPlayer
    end
    
    skySquidAntiFallConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.SkySquid.AntiFall then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        
        if not rootPart or not humanoid or humanoid.Health <= 0 then return end
        
        -- Проверяем падение
        if rootPart.Position.Y < 50 then
            local targetPlayer = findNearestAlivePlayer()
            if targetPlayer and targetPlayer.Character then
                local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    rootPart.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
                    
                    -- Эффект телепортации
                    task.spawn(function()
                        local flash = Instance.new("Part")
                        flash.Size = Vector3.new(8, 0.2, 8)
                        flash.Position = rootPart.Position - Vector3.new(0, 3, 0)
                        flash.BrickColor = BrickColor.new("Bright blue")
                        flash.Material = Enum.Material.Neon
                        flash.Anchored = true
                        flash.CanCollide = false
                        flash.Transparency = 0.5
                        flash.Parent = workspace
                        
                        game:GetService("Debris"):AddItem(flash, 0.5)
                    end)
                end
            end
        end
    end)
end

-- Auto QTE для Sky Squid (уже реализован выше как MainModule.ToggleSkySquidQTE)

-- Safe Platform для Sky Squid
function MainModule.ToggleSkySquidSafePlatform(enabled)
    MainModule.SkySquid.SafePlatform = enabled
    
    if skySquidSafePlatformConnection then
        skySquidSafePlatformConnection:Disconnect()
        skySquidSafePlatformConnection = nil
    end
    
    -- Удаляем старую платформу
    if MainModule.AntiFallPlatforms.SkySquid then
        MainModule.AntiFallPlatforms.SkySquid:Destroy()
        MainModule.AntiFallPlatforms.SkySquid = nil
    end
    
    if not enabled then return end
    
    -- Создаем платформу
    local function createSkySquidPlatform()
        local character = LocalPlayer.Character
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        if MainModule.AntiFallPlatforms.SkySquid then
            MainModule.AntiFallPlatforms.SkySquid:Destroy()
        end
        
        local platform = Instance.new("Part")
        platform.Name = "SkySquid_AntiFallPlatform"
        platform.Size = Vector3.new(500, 5, 500)
        platform.Position = Vector3.new(rootPart.Position.X, 100, rootPart.Position.Z)
        platform.Anchored = true
        platform.CanCollide = true
        platform.Transparency = 0.7
        platform.Material = Enum.Material.Neon
        platform.BrickColor = BrickColor.new("Bright blue")
        platform.Parent = Workspace
        
        MainModule.AntiFallPlatforms.SkySquid = platform
    end
    
    -- Создаем платформу сразу
    createSkySquidPlatform()
    
    -- Обновляем позицию платформы
    skySquidSafePlatformConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.SkySquid.SafePlatform then return end
        
        if MainModule.AntiFallPlatforms.SkySquid and MainModule.AntiFallPlatforms.SkySquid.Parent then
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local currentPos = MainModule.AntiFallPlatforms.SkySquid.Position
                local newPos = Vector3.new(character.HumanoidRootPart.Position.X, 100, character.HumanoidRootPart.Position.Z)
                
                -- Плавное перемещение платформы
                MainModule.AntiFallPlatforms.SkySquid.Position = newPos
            end
        else
            -- Пересоздаем если платформа уничтожена
            createSkySquidPlatform()
        end
    end)
end

-- Void Kill для Sky Squid
function MainModule.ToggleSkySquidVoidKill(enabled)
    MainModule.SkySquid.VoidKill = enabled
    
    if skySquidVoidKillConnection then
        skySquidVoidKillConnection:Disconnect()
        skySquidVoidKillConnection = nil
    end
    
    if not enabled then return end
    
    skySquidVoidKillConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.SkySquid.VoidKill then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        
        if not rootPart or not humanoid or humanoid.Health <= 0 then return end
        
        -- Проверяем близость к другим игрокам
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    local distance = (rootPart.Position - targetRoot.Position).Magnitude
                    
                    if distance < 15 then
                        -- Телепортируем врага в пустоту
                        local voidPosition = Vector3.new(0, 10000, 0)
                        targetRoot.CFrame = CFrame.new(voidPosition)
                        
                        -- Создаем платформу под ним
                        local platform = Instance.new("Part")
                        platform.Name = "VoidPlatform"
                        platform.Size = Vector3.new(50, 5, 50)
                        platform.Position = voidPosition - Vector3.new(0, 3, 0)
                        platform.Anchored = true
                        platform.CanCollide = true
                        platform.Transparency = 0.5
                        platform.Material = Enum.Material.Neon
                        platform.BrickColor = BrickColor.new("Bright purple")
                        platform.Parent = Workspace
                        
                        -- Очистка через 10 секунд
                        task.delay(10, function()
                            if platform and platform.Parent then
                                platform:Destroy()
                            end
                        end)
                        
                        break
                    end
                end
            end
        end
    end)
end

-- ===================================================================
-- ANTI-FALL ФУНКЦИИ ДЛЯ ВСЕХ ИГР
-- ===================================================================
-- Создание Anti-Fall платформ для всех игр
function MainModule.CreateAntiFallPlatform(gameType)
    local platformId = gameType .. "_AntiFallPlatform"
    
    -- Удаляем старую платформу если есть
    if MainModule.AntiFallPlatforms[gameType] then
        MainModule.AntiFallPlatforms[gameType]:Destroy()
        MainModule.AntiFallPlatforms[gameType] = nil
    end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- Определяем высоту для разных игр
    local yPosition = 0
    if gameType == "JumpRope" then
        yPosition = 190
    elseif gameType == "GlassBridge" then
        yPosition = 520
    elseif gameType == "SkySquid" then
        yPosition = 100
    elseif gameType == "Dalgona" then
        yPosition = 1000
    else
        yPosition = 50  -- Дефолтная высота
    end
    
    -- Создаем платформу
    local platform = Instance.new("Part")
    platform.Name = platformId
    platform.Size = Vector3.new(500, 5, 500)
    platform.Position = Vector3.new(rootPart.Position.X, yPosition, rootPart.Position.Z)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 0.7
    platform.Material = Enum.Material.Neon
    platform.BrickColor = BrickColor.new("Bright blue")
    platform.Parent = Workspace
    
    MainModule.AntiFallPlatforms[gameType] = platform
    
    return platform
end

function MainModule.RemoveAntiFallPlatform(gameType)
    if MainModule.AntiFallPlatforms[gameType] then
        MainModule.AntiFallPlatforms[gameType]:Destroy()
        MainModule.AntiFallPlatforms[gameType] = nil
    end
end

-- Включаем/выключаем Anti-Fall для конкретной игры
function MainModule.ToggleAntiFall(gameType, enabled)
    if enabled then
        MainModule.CreateAntiFallPlatform(gameType)
    else
        MainModule.RemoveAntiFallPlatform(gameType)
    end
end

-- ===================================================================
-- MISC ФУНКЦИИ
-- ===================================================================
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

-- ===================================================================
-- ОЧИСТКА ПРИ ЗАКРЫТИИ
-- ===================================================================
function MainModule.Cleanup()
    -- Отключаем все соединения
    local connections = {
        speedConnection, autoFarmConnection, godModeConnection, instaInteractConnection,
        noCooldownConnection, antiStunConnection, rapidFireConnection, infiniteAmmoConnection,
        hitboxConnection, autoPullConnection, antiBreakConnection, hnsAutoPickupConnection,
        hnsSpikesKillConnection, hnsKillHidersConnection, hnsDisableSpikesConnection,
        jumpRopeAntiFailConnection, glassBridgeESPConnection, antiStunRagdollConnection,
        skySquidAntiFallConnection, skySquidQTEConnection, skySquidVoidKillConnection,
        skySquidSafePlatformConnection, MainModule.ESPConnection
    }
    
    for _, conn in pairs(connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    
    -- Очищаем ESP
    if MainModule.ESPConnection then
        MainModule.ESPConnection:Disconnect()
        MainModule.ESPConnection = nil
    end
    
    for _, esp in pairs(MainModule.ESPTable) do
        if esp and esp.Destroy then
            pcall(esp.Destroy)
        end
    end
    MainModule.ESPTable = {}
    
    if MainModule.ESPFolder then
        pcall(function() MainModule.ESPFolder:Destroy() end)
        MainModule.ESPFolder = nil
    end
    
    -- Восстанавливаем хитбоксы
    _G.HitboxExpanderEnabled = false
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root and root:IsA("BasePart") then
                pcall(function()
                    root.Size = Vector3.new(2, 2, 1)
                    root.CanCollide = true
                    root.Transparency = 0
                end)
            end
        end
    end
    
    -- Удаляем Anti-Fall платформы
    for gameType, platform in pairs(MainModule.AntiFallPlatforms) do
        if platform and platform.Parent then
            pcall(function() platform:Destroy() end)
        end
    end
    MainModule.AntiFallPlatforms = {}
    
    -- Удаляем безопасные платформы Glass Bridge
    for _, platform in pairs(MainModule.GlassBridge.SafePlatforms) do
        if platform and platform.Parent then
            pcall(function() platform:Destroy() end)
        end
    end
    MainModule.GlassBridge.SafePlatforms = {}
    
    -- Восстанавливаем шипы
    if MainModule.HNS.DisableSpikes then
        MainModule.ToggleDisableSpikes(false)
    end
    
    print("Creon X v2.1 - Все функции очищены")
end

-- Автоматическая очистка при выходе
Players.LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not Players.LocalPlayer.Parent then
        MainModule.Cleanup()
    end
end)

return MainModule
