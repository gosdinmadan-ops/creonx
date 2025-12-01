-- Main.lua - Creon X v2.1
local MainModule = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

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
    InstantRebel = false,
    InfAmmo = false,
    RapidFire = false
}

MainModule.RLGL = {
    GodMode = false,
    OriginalHeight = nil,
    GameActive = false,
    TeleportToEndEnabled = false,
    TeleportToStartEnabled = false
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
    HeadSize = 1000,
    Disabled = true
}

MainModule.Dalgona = {
    CompleteEnabled = false,
    FreeLighterEnabled = false,
    GameActive = false
}

MainModule.HNS = {
    AutoPickup = false,
    SpikesKill = false,
    DisableSpikes = false,
    KillHiders = false,
    AutoDodge = false,
    GameActive = false
}

MainModule.TugOfWar = {
    AutoPull = false,
    GameActive = false
}

MainModule.GlassBridge = {
    AntiBreak = false,
    GlassESPEnabled = false,
    GlassVision = false,
    GlassPlatforms = false,
    AntiFallPlatform = false,
    GameActive = false,
    GlassBridgeCover = nil,
    GlassPlatformsTable = {},
    GlassBridgePlatform = nil
}

MainModule.JumpRope = {
    AntiFail = false,
    TeleportToStart = false,
    TeleportToEnd = false,
    AutoJumpRope = false,
    FreezeRope = false,
    NoBalance = false,
    AutoJump = false,
    AntiFall = false,
    GameActive = false,
    JumpRopePlatform = nil
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

-- ESP System (оптимизированная без лагов)
MainModule.ESPTable = {}
MainModule.ESPFolder = nil
MainModule.ESPUpdateRate = 1.0 -- Увеличено для оптимизации
MainModule.LastESPUpdate = 0

-- HNS шипы
MainModule.HNSSpikes = {
    Positions = {},
    OriginalPositions = {},
    Disabled = false
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
local jumpRopeAntiFailConnection = nil
local glassBridgeESPConnection = nil
local antiStunRagdollConnection = nil
local glassBridgeAntiBreakConnection = nil
local glassBridgeVisionConnection = nil
local glassBridgePlatformsConnection = nil
local jumpRopeAutoJumpConnection = nil
local jumpRopeFreezeConnection = nil
local jumpRopeNoBalanceConnection = nil
local jumpRopeAntiFallConnection = nil
local rebelInfAmmoConnection = nil
local rebelRapidFireConnection = nil
local gameCheckConnection = nil

-- Локальный игрок
local LocalPlayer = Players.LocalPlayer

-- Функция проверки активной игры
function MainModule.CheckCurrentGame()
    local values = Workspace:FindFirstChild("Values")
    if not values then return "Unknown" end
    
    local currentGame = values:FindFirstChild("CurrentGame")
    if not currentGame then return "Unknown" end
    
    return currentGame.Value
end

-- Функция проверки, активна ли игра
function MainModule.IsGameActive(gameName)
    return MainModule.CheckCurrentGame() == gameName
end

-- Автоматическое обновление статуса игр
function MainModule.SetupGameCheck()
    if gameCheckConnection then
        gameCheckConnection:Disconnect()
    end
    
    gameCheckConnection = RunService.Heartbeat:Connect(function()
        local currentGame = MainModule.CheckCurrentGame()
        
        -- Обновляем статусы для всех игр
        MainModule.RLGL.GameActive = (currentGame == "RedLightGreenLight")
        MainModule.Dalgona.GameActive = (currentGame == "Dalgona")
        MainModule.HNS.GameActive = (currentGame == "HideAndSeek")
        MainModule.TugOfWar.GameActive = (currentGame == "TugOfWar")
        MainModule.GlassBridge.GameActive = (currentGame == "GlassBridge")
        MainModule.JumpRope.GameActive = (currentGame == "JumpRope")
        
        -- Если игра закончилась, выключаем функции
        if currentGame ~= "GlassBridge" and MainModule.GlassBridge.GlassESPEnabled then
            MainModule.ToggleGlassBridgeESP(false)
        end
        
        if currentGame ~= "JumpRope" and MainModule.JumpRope.AntiFail then
            MainModule.ToggleAntiFailJumpRope(false)
        end
        
        -- Другие проверки для других игр...
    end)
end

-- Функция для получения расстояния
local function GetDistanceFromCharacter(object)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return 0
    end
    
    local objectPosition = object.PrimaryPart and object.PrimaryPart.Position or object.Position
    return math.floor((character.HumanoidRootPart.Position - objectPosition).Magnitude)
end

-- Оптимизированная ESP System (без лагов)
function MainModule.ToggleESP(enabled)
    MainModule.Misc.ESPEnabled = enabled
    
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end
    
    -- Очищаем старые ESP
    for _, esp in pairs(MainModule.ESPTable) do
        if esp and esp.Destroy then
            pcall(function() esp:Destroy() end)
        end
    end
    MainModule.ESPTable = {}
    
    -- Удаляем папку ESP
    if MainModule.ESPFolder then
        pcall(function() MainModule.ESPFolder:Destroy() end)
        MainModule.ESPFolder = nil
    end
    
    if enabled then
        -- Создаем новую папку ESP
        MainModule.ESPFolder = Instance.new("Folder")
        MainModule.ESPFolder.Name = "CreonESP"
        MainModule.ESPFolder.Parent = Workspace
        
        -- Функция для создания ESP объекта
        local function createESPObject(object, color, text, isPlayer)
            if not object or not object.Parent then return nil end
            
            local rootPart = object:FindFirstChild("HumanoidRootPart") or object.PrimaryPart
            if not rootPart then return nil end
            
            local espData = {}
            
            -- Highlight
            if MainModule.Misc.ESPHighlight and MainModule.Misc.ESPBoxes then
                local highlight = Instance.new("Highlight")
                highlight.Name = "ESP_Highlight"
                highlight.Adornee = object
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.FillColor = color
                highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
                highlight.OutlineColor = color
                highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
                highlight.Parent = MainModule.ESPFolder
                espData.Highlight = highlight
            end
            
            -- Billboard
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
            
            if isPlayer and MainModule.Misc.ESPNames then
                local player = Players:GetPlayerFromCharacter(object)
                if player then
                    local distance = GetDistanceFromCharacter(object)
                    textLabel.Text = player.DisplayName .. (MainModule.Misc.ESPDistance and (" [" .. distance .. "]") or "")
                else
                    textLabel.Text = text .. (MainModule.Misc.ESPDistance and (" [" .. GetDistanceFromCharacter(object) .. "]") or "")
                end
            else
                textLabel.Text = text .. (MainModule.Misc.ESPDistance and (" [" .. GetDistanceFromCharacter(object) .. "]") or "")
            end
            
            textLabel.TextColor3 = color
            textLabel.TextSize = MainModule.Misc.ESPTextSize
            textLabel.Font = Enum.Font.GothamBold
            textLabel.TextStrokeTransparency = 0.3
            textLabel.Parent = billboard
            
            espData.Billboard = billboard
            espData.TextLabel = textLabel
            
            espData.Destroy = function()
                pcall(function()
                    if espData.Highlight then espData.Highlight:Destroy() end
                    if espData.Billboard then espData.Billboard:Destroy() end
                end)
            end
            
            return espData
        end
        
        -- Оптимизированное обновление ESP
        espConnection = RunService.RenderStepped:Connect(function()
            local currentTime = tick()
            if currentTime - MainModule.LastESPUpdate < MainModule.ESPUpdateRate then
                return
            end
            MainModule.LastESPUpdate = currentTime
            
            pcall(function()
                -- Обновляем ESP раз в 1 секунду для оптимизации
                
                -- Очищаем старые ESP для удаленных объектов
                for key, esp in pairs(MainModule.ESPTable) do
                    if not esp or not esp.Billboard or not esp.Billboard.Parent then
                        if esp and esp.Destroy then
                            esp:Destroy()
                        end
                        MainModule.ESPTable[key] = nil
                    end
                end
                
                -- ESP для игроков
                if MainModule.Misc.ESPPlayers then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local humanoid = player.Character:FindFirstChild("Humanoid")
                            if humanoid and humanoid.Health > 0 then
                                local key = "player_" .. player.UserId
                                if not MainModule.ESPTable[key] then
                                    MainModule.ESPTable[key] = createESPObject(player.Character, Color3.fromRGB(0, 170, 255), player.DisplayName, true)
                                end
                            end
                        end
                    end
                end
                
                -- ESP для HNS
                if MainModule.Misc.ESPHiders or MainModule.Misc.ESPSeekers then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local isHider = player:GetAttribute("IsHider")
                            local isHunter = player:GetAttribute("IsHunter")
                            
                            if (isHider and MainModule.Misc.ESPHiders) or (isHunter and MainModule.Misc.ESPSeekers) then
                                local color = isHider and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                                local text = (isHider and "Hider" or "Hunter")
                                local key = "hns_" .. player.UserId
                                
                                if not MainModule.ESPTable[key] then
                                    MainModule.ESPTable[key] = createESPObject(player.Character, color, text, true)
                                end
                            end
                        end
                    end
                end
                
                -- ESP для охранников
                if MainModule.Misc.ESPGuards then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and obj.Name:lower():find("guard") then
                            local key = "guard_" .. obj:GetFullName()
                            if not MainModule.ESPTable[key] then
                                MainModule.ESPTable[key] = createESPObject(obj, Color3.fromRGB(255, 0, 0), "Guard", false)
                            end
                        end
                    end
                end
                
                -- ESP для ключей
                if MainModule.Misc.ESPKeys then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and obj.Name:lower():find("key") and obj.PrimaryPart then
                            local key = "key_" .. obj:GetFullName()
                            if not MainModule.ESPTable[key] then
                                MainModule.ESPTable[key] = createESPObject(obj, Color3.fromRGB(255, 165, 0), "Key", false)
                            end
                        end
                    end
                end
                
                -- ESP для конфет
                if MainModule.Misc.ESPCandies then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and obj.Name:lower():find("candy") and obj.PrimaryPart then
                            local key = "candy_" .. obj:GetFullName()
                            if not MainModule.ESPTable[key] then
                                MainModule.ESPTable[key] = createESPObject(obj, Color3.fromRGB(255, 255, 0), "Candy", false)
                            end
                        end
                    end
                end
            end)
        end)
    end
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

-- Anti Stun + Anti Ragdoll функция
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

-- Rebel функции
function MainModule.ToggleRebel(enabled)
    MainModule.Rebel.Enabled = enabled
    _G.InstantRebel = enabled
end

function MainModule.ToggleRebelInfAmmo(enabled)
    MainModule.Rebel.InfAmmo = enabled
    
    if rebelInfAmmoConnection then
        rebelInfAmmoConnection:Disconnect()
        rebelInfAmmoConnection = nil
    end
    
    if enabled then
        rebelInfAmmoConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.Rebel.InfAmmo then return end
            
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

function MainModule.ToggleRebelRapidFire(enabled)
    MainModule.Rebel.RapidFire = enabled
    
    if rebelRapidFireConnection then
        rebelRapidFireConnection:Disconnect()
        rebelRapidFireConnection = nil
    end
    
    if enabled then
        rebelRapidFireConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.Rebel.RapidFire then return end
            
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
    end
end

-- RLGL функции
function MainModule.TeleportToEndRLGL()
    if not MainModule.RLGL.GameActive then
        warn("RLGL не активна!")
        return
    end
    
    local player = LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-214.4, 1023.1, 146.7)
    end
end

function MainModule.TeleportToStartRLGL()
    if not MainModule.RLGL.GameActive then
        warn("RLGL не активна!")
        return
    end
    
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

-- Hitbox Expander функция (исправленная версия)
function MainModule.ToggleHitboxExpander(enabled)
    MainModule.Guards.HitboxExpander = enabled
    MainModule.Guards.Disabled = not enabled
    
    if hitboxConnection then
        hitboxConnection:Disconnect()
        hitboxConnection = nil
    end
    
    -- Кэшируем часто используемые сервисы
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer
    
    -- Создаем таблицу для кэширования измененных частей
    local modifiedParts = {}
    
    local function modifyPart(part)
        if not modifiedParts[part] then
            part.Size = Vector3.new(MainModule.Guards.HeadSize, MainModule.Guards.HeadSize, MainModule.Guards.HeadSize)
            part.CanCollide = false
            part.Transparency = 1
            modifiedParts[part] = true
        end
    end
    
    local function restorePart(part)
        if modifiedParts[part] then
            if MainModule.Guards.OriginalHitboxes[part] then
                part.Size = MainModule.Guards.OriginalHitboxes[part]
            else
                part.Size = Vector3.new(2, 2, 1)
            end
            part.CanCollide = true
            part.Transparency = 0
            modifiedParts[part] = nil
        end
    end
    
    -- Обработчик для новых игроков
    local function onPlayerAdded(player)
        player.CharacterAdded:Connect(function(character)
            if MainModule.Guards.HitboxExpander then
                local root = character:WaitForChild("HumanoidRootPart", 5)
                if root then
                    MainModule.Guards.OriginalHitboxes[root] = root.Size
                    modifyPart(root)
                end
            end
        end)
    end
    
    -- Восстанавливаем оригинальные размеры перед изменением
    for _, part in pairs(modifiedParts) do
        restorePart(part)
    end
    modifiedParts = {}
    
    -- Обработчик для существующих игроков
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                MainModule.Guards.OriginalHitboxes[root] = root.Size
                if enabled then
                    modifyPart(root)
                end
            end
        end
        if player ~= LocalPlayer then
            onPlayerAdded(player)
        end
    end
    
    if enabled then
        hitboxConnection = RunService.RenderStepped:Connect(function()
            if not MainModule.Guards.HitboxExpander then return end
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local root = player.Character:FindFirstChild("HumanoidRootPart")
                    if root and not modifiedParts[root] then
                        pcall(modifyPart, root)
                    end
                end
            end
        end)
    else
        -- Восстанавливаем все измененные части
        for part, _ in pairs(modifiedParts) do
            pcall(restorePart, part)
        end
    end
    
    -- Очистка при выходе игрока
    Players.PlayerRemoving:Connect(function(player)
        if player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                modifiedParts[root] = nil
            end
        end
    end)
end

-- Dalgona функции
function MainModule.CompleteDalgona()
    if not MainModule.Dalgona.GameActive then
        warn("Dalgona не активна!")
        return
    end
    
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
    if not MainModule.Dalgona.GameActive then
        warn("Dalgona не активна!")
        return
    end
    
    LocalPlayer:SetAttribute("HasLighter", true)
end

-- HNS функции
function MainModule.ToggleAutoPickup(enabled)
    MainModule.HNS.AutoPickup = enabled
    
    if hnsAutoPickupConnection then
        hnsAutoPickupConnection:Disconnect()
        hnsAutoPickupConnection = nil
    end
    
    if enabled then
        if not MainModule.HNS.GameActive then
            warn("HNS не активна!")
            MainModule.HNS.AutoPickup = false
            return
        end
        
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
        if not MainModule.HNS.GameActive then
            warn("HNS не активна!")
            MainModule.HNS.SpikesKill = false
            return
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
        if not MainModule.HNS.GameActive then
            warn("HNS не активна!")
            MainModule.HNS.DisableSpikes = false
            return
        end
        
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
        if not MainModule.HNS.GameActive then
            warn("HNS не активна!")
            MainModule.HNS.KillHiders = false
            return
        end
        
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

-- Tug Of War функции
function MainModule.ToggleAutoPull(enabled)
    MainModule.TugOfWar.AutoPull = enabled
    
    if autoPullConnection then
        autoPullConnection:Disconnect()
        autoPullConnection = nil
    end
    
    if enabled then
        if not MainModule.TugOfWar.GameActive then
            warn("Tug Of War не активна!")
            MainModule.TugOfWar.AutoPull = false
            return
        end
        
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

-- Glass Bridge функции
function MainModule.TeleportToEndGlassBridge()
    if not MainModule.GlassBridge.GameActive then
        warn("Glass Bridge не активна!")
        return
    end
    
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(-196.372467, 522.192139, -1534.20984)
    end
end

function MainModule.TPENDGlassBridge()
    if not MainModule.GlassBridge.GameActive then
        warn("Glass Bridge не активна!")
        return
    end
    
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(-211.855881, 517.039062, -1534.7373)
    end
end

-- Исправленный Anti Break для Glass Bridge
function MainModule.ToggleAntiBreak(enabled)
    MainModule.GlassBridge.AntiBreak = enabled
    
    if glassBridgeAntiBreakConnection then
        glassBridgeAntiBreakConnection:Disconnect()
        glassBridgeAntiBreakConnection = nil
    end
    
    if enabled then
        if not MainModule.GlassBridge.GameActive then
            warn("Glass Bridge не активна!")
            MainModule.GlassBridge.AntiBreak = false
            return
        end
        
        -- Создаем защитные платформы для каждой плитки
        glassBridgeAntiBreakConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.GlassBridge.AntiBreak then return end
            
            pcall(function()
                local GlassHolder = Workspace:FindFirstChild("GlassBridge") and Workspace.GlassBridge:FindFirstChild("GlassHolder")
                if not GlassHolder then return end
                
                for _, tilePair in pairs(GlassHolder:GetChildren()) do
                    for _, tileModel in pairs(tilePair:GetChildren()) do
                        if tileModel:IsA("Model") and tileModel.PrimaryPart then
                            -- Проверяем, не создали ли мы уже платформу для этой плитки
                            local platformName = "AntiBreakPlatform_" .. tileModel.Name
                            if not Workspace:FindFirstChild(platformName) then
                                -- Создаем невидимую защитную платформу
                                local platform = Instance.new("Part")
                                platform.Name = platformName
                                platform.Size = Vector3.new(7, 0.2, 7) -- Чуть больше чем плитка
                                platform.CFrame = tileModel.PrimaryPart.CFrame * CFrame.new(0, -2.5, 0) -- Под плиткой
                                platform.Anchored = true
                                platform.CanCollide = true
                                platform.Transparency = 1 -- Полностью невидимая
                                platform.CastShadow = false
                                platform.Material = Enum.Material.SmoothPlastic
                                platform.Parent = Workspace
                                
                                -- Сохраняем ссылку
                                table.insert(MainModule.GlassBridge.GlassPlatformsTable, platform)
                            end
                        end
                    end
                end
            end)
        end)
    else
        -- Удаляем все созданные платформы
        for _, platform in ipairs(MainModule.GlassBridge.GlassPlatformsTable) do
            if platform and platform.Parent then
                platform:Destroy()
            end
        end
        MainModule.GlassBridge.GlassPlatformsTable = {}
    end
end

function MainModule.ToggleGlassBridgeESP(enabled)
    MainModule.GlassBridge.GlassESPEnabled = enabled
    
    if glassBridgeESPConnection then
        glassBridgeESPConnection:Disconnect()
        glassBridgeESPConnection = nil
    end
    
    if enabled then
        if not MainModule.GlassBridge.GameActive then
            warn("Glass Bridge не активна!")
            MainModule.GlassBridge.GlassESPEnabled = false
            return
        end
        
        glassBridgeESPConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.GlassBridge.GlassESPEnabled then return end
            
            pcall(function()
                local GlassHolder = Workspace:WaitForChild("GlassBridge"):WaitForChild("GlassHolder")

                for i, v in pairs(GlassHolder:GetChildren()) do
                    for g, j in pairs(v:GetChildren()) do
                        if j:IsA("Model") and j.PrimaryPart then
                            local isBreakable = j.PrimaryPart:GetAttribute("exploitingisevil") == true
                            local targetColor = isBreakable and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)

                            for _, part in pairs(j:GetDescendants()) do
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

-- Glass Vision функция
function MainModule.ToggleGlassVision(enabled)
    MainModule.GlassBridge.GlassVision = enabled
    
    if glassBridgeVisionConnection then
        glassBridgeVisionConnection:Disconnect()
        glassBridgeVisionConnection = nil
    end
    
    local function isRealGlass(part)
        if part:GetAttribute("GlassPart") then
            if part:GetAttribute("ActuallyKilling") ~= nil then
                return false
            end
            return true
        end
        return false
    end

    local function updateGlassColors()
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and part:GetAttribute("GlassPart") then
                if MainModule.GlassBridge.GlassVision then
                    if isRealGlass(part) then
                        part.Color = Color3.fromRGB(0, 255, 0) -- Зеленый для безопасного стекла
                    else
                        part.Color = Color3.fromRGB(255, 0, 0) -- Красный для ломающегося стекла
                    end
                    part.Material = Enum.Material.Neon
                    part:SetAttribute("ExploitingIsEvil", true)
                else
                    part.Color = Color3.fromRGB(163, 162, 165) -- Обычный цвет
                    part.Material = Enum.Material.Glass
                    part:SetAttribute("ExploitingIsEvil", nil)
                end
            end
        end
    end

    if enabled then
        if not MainModule.GlassBridge.GameActive then
            warn("Glass Bridge не активна!")
            MainModule.GlassBridge.GlassVision = false
            return
        end
        
        glassBridgeVisionConnection = RunService.Heartbeat:Connect(function()
            if MainModule.GlassBridge.GlassVision then
                updateGlassColors()
            end
        end)
    else
        updateGlassColors()
    end
end

-- Glass Platforms функция
function MainModule.ToggleGlassPlatforms(enabled)
    MainModule.GlassBridge.GlassPlatforms = enabled
    
    if glassBridgePlatformsConnection then
        glassBridgePlatformsConnection:Disconnect()
        glassBridgePlatformsConnection = nil
    end
    
    local function isFakeGlass(part) 
        return part:GetAttribute("GlassPart") and part:GetAttribute("ActuallyKilling") ~= nil 
    end

    local function createPlatforms()
        -- Очищаем старые платформы
        for _, platform in ipairs(MainModule.GlassBridge.GlassPlatformsTable) do 
            if platform and platform.Parent then 
                platform:Destroy() 
            end 
        end
        MainModule.GlassBridge.GlassPlatformsTable = {}
        
        -- Создаем новые платформы
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and isFakeGlass(part) then
                local platform = Instance.new("Part")
                platform.Size = Vector3.new(10, 0.5, 10)
                platform.CFrame = part.CFrame * CFrame.new(0, 2, 0)
                platform.Anchored = true
                platform.CanCollide = true
                platform.Transparency = 0.3
                platform.Material = Enum.Material.Neon
                platform.Color = Color3.fromRGB(255, 0, 0) -- Красные платформы для опасного стекла
                platform.Parent = workspace
                table.insert(MainModule.GlassBridge.GlassPlatformsTable, platform)
            end
        end
    end

    if enabled then
        if not MainModule.GlassBridge.GameActive then
            warn("Glass Bridge не активна!")
            MainModule.GlassBridge.GlassPlatforms = false
            return
        end
        
        glassBridgePlatformsConnection = RunService.Heartbeat:Connect(function()
            if MainModule.GlassBridge.GlassPlatforms then
                createPlatforms()
            end
        end)
    else
        -- Удаляем платформы
        for _, platform in ipairs(MainModule.GlassBridge.GlassPlatformsTable) do 
            if platform and platform.Parent then 
                platform:Destroy() 
            end 
        end
        MainModule.GlassBridge.GlassPlatformsTable = {}
    end
end

-- Anti-Fall Platform для Glass Bridge
function MainModule.ToggleAntiFallPlatformGlassBridge(enabled)
    MainModule.GlassBridge.AntiFallPlatform = enabled
    
    if enabled then
        if not MainModule.GlassBridge.GameActive then
            warn("Glass Bridge не активна!")
            MainModule.GlassBridge.AntiFallPlatform = false
            return
        end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        -- Удаляем старую платформу если есть
        if MainModule.GlassBridge.GlassBridgePlatform then
            MainModule.GlassBridge.GlassBridgePlatform:Destroy()
        end
        
        -- Создаем новую платформу
        local platform = Instance.new("Part")
        platform.Name = "GlassBridgeAntiFallPlatform"
        platform.Size = Vector3.new(500, 5, 500)
        platform.Position = Vector3.new(rootPart.Position.X, 520, rootPart.Position.Z)
        platform.Anchored = true
        platform.CanCollide = true
        platform.Transparency = 0.7
        platform.Material = Enum.Material.Neon
        platform.Color = Color3.fromRGB(0, 120, 255)
        platform.Parent = workspace
        
        MainModule.GlassBridge.GlassBridgePlatform = platform
    else
        -- Удаляем платформу
        if MainModule.GlassBridge.GlassBridgePlatform then
            MainModule.GlassBridge.GlassBridgePlatform:Destroy()
            MainModule.GlassBridge.GlassBridgePlatform = nil
        end
    end
end

-- Создание Fake Glass
function MainModule.CreateGlassBridgeCover()
    if not MainModule.GlassBridge.GameActive then
        warn("Glass Bridge не активна!")
        return
    end
    
    local glassHolder = Workspace:FindFirstChild("GlassBridge")
    if not glassHolder then
        return
    end

    glassHolder = glassHolder:FindFirstChild("GlassHolder")
    if not glassHolder then
        return
    end

    local models = glassHolder:GetChildren()
    if #models == 0 then
        return
    end

    local minX, minY, minZ = math.huge, math.huge, math.huge
    local maxX, maxY, maxZ = -math.huge, -math.huge, -math.huge

    for _, model in ipairs(models) do
        if model:IsA("Model") or model:IsA("BasePart") then
            local cframe, size

            if model:IsA("Model") then
                cframe, size = model:GetBoundingBox()
            else
                cframe = model.CFrame
                size = model.Size
            end

            local halfSize = size / 2
            local corners = {
                cframe * CFrame.new(-halfSize.X, -halfSize.Y, -halfSize.Z),
                cframe * CFrame.new(halfSize.X, -halfSize.Y, -halfSize.Z),
                cframe * CFrame.new(-halfSize.X, halfSize.Y, -halfSize.Z),
                cframe * CFrame.new(halfSize.X, halfSize.Y, -halfSize.Z),
                cframe * CFrame.new(-halfSize.X, -halfSize.Y, halfSize.Z),
                cframe * CFrame.new(halfSize.X, -halfSize.Y, halfSize.Z),
                cframe * CFrame.new(-halfSize.X, halfSize.Y, halfSize.Z),
                cframe * CFrame.new(halfSize.X, halfSize.Y, halfSize.Z),
            }

            for _, corner in ipairs(corners) do
                local pos = corner.Position
                minX = math.min(minX, pos.X)
                minY = math.min(minY, pos.Y)
                minZ = math.min(minZ, pos.Z)
                maxX = math.max(maxX, pos.X)
                maxY = math.max(maxY, pos.Y)
                maxZ = math.max(maxZ, pos.Z)
            end
        end
    end

    -- Удаляем старый cover если есть
    if MainModule.GlassBridge.GlassBridgeCover then
        MainModule.GlassBridge.GlassBridgeCover:Destroy()
    end

    local coverPart = Instance.new("Part")
    coverPart.Name = "GlassBridgeCover"
    coverPart.Anchored = true
    coverPart.CanCollide = true
    coverPart.Material = Enum.Material.SmoothPlastic
    coverPart.Color = Color3.fromRGB(100, 100, 255)
    coverPart.Transparency = 0.3

    local sizeX = maxX - minX + 2
    local sizeY = maxY - minY + 2
    local sizeZ = maxZ - minZ + 2

    local centerX = (minX + maxX) / 2
    local centerY = (minY + maxY) / 2
    local centerZ = (minZ + maxZ) / 2

    coverPart.Size = Vector3.new(sizeX, sizeY, sizeZ)
    coverPart.CFrame = CFrame.new(centerX, centerY, centerZ)
    coverPart.Parent = workspace

    MainModule.GlassBridge.GlassBridgeCover = coverPart
    return coverPart
end

-- Jump Rope функции
function MainModule.TeleportToJumpRopeStart()
    if not MainModule.JumpRope.GameActive then
        warn("Jump Rope не активна!")
        return
    end
    
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(700.123, 198.456, 920.789)
    end
end

function MainModule.TeleportToJumpRopeEnd()
    if not MainModule.JumpRope.GameActive then
        warn("Jump Rope не активна!")
        return
    end
    
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(720.896057, 198.628311, 921.170654)
    end
end

function MainModule.TeleportToJumpRopeEnd2()
    if not MainModule.JumpRope.GameActive then
        warn("Jump Rope не активна!")
        return
    end
    
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(737.156372, 193.805084, 920.952515)
    end
end

function MainModule.TeleportToJumpRopeStart2()
    if not MainModule.JumpRope.GameActive then
        warn("Jump Rope не активна!")
        return
    end
    
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(615.284424, 192.274277, 920.952515)
    end
end

function MainModule.DeleteJumpRope()
    if not MainModule.JumpRope.GameActive then
        warn("Jump Rope не активна!")
        return
    end
    
    if workspace:FindFirstChild("Effects") then
        local rope = workspace.Effects:FindFirstChild("rope")
        if rope then
            rope:Destroy()
        end
    end
end

function MainModule.RemoveRope()
    if not MainModule.JumpRope.GameActive then
        warn("Jump Rope не активна!")
        return
    end
    
    local rope = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("rope")
    if rope then
        rope:Destroy()
    end
end

-- Auto Jump Rope
function MainModule.ToggleAutoJumpRope(enabled)
    MainModule.JumpRope.AutoJumpRope = enabled
    
    if jumpRopeAntiFailConnection then
        jumpRopeAntiFailConnection:Disconnect()
        jumpRopeAntiFailConnection = nil
    end
    
    if enabled then
        if not MainModule.JumpRope.GameActive then
            warn("Jump Rope не активна!")
            MainModule.JumpRope.AutoJumpRope = false
            return
        end
        
        jumpRopeAntiFailConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.JumpRope.AutoJumpRope then return end
            
            local character = LocalPlayer.Character
            if not character then return end
            
            local humanoid = character:FindFirstChild("Humanoid")
            if not humanoid then return end
            
            -- Проверяем, находимся ли мы рядом с веревкой
            local rope = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("rope")
            if rope and character:FindFirstChild("HumanoidRootPart") then
                local distance = (character.HumanoidRootPart.Position - rope.Position).Magnitude
                
                if distance <= 20 then
                    -- Автоматически прыгаем
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end
end

-- Freeze Rope
function MainModule.ToggleFreezeRope(enabled)
    MainModule.JumpRope.FreezeRope = enabled
    
    if jumpRopeFreezeConnection then
        jumpRopeFreezeConnection:Disconnect()
        jumpRopeFreezeConnection = nil
    end
    
    if enabled then
        if not MainModule.JumpRope.GameActive then
            warn("Jump Rope не активна!")
            MainModule.JumpRope.FreezeRope = false
            return
        end
        
        jumpRopeFreezeConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.JumpRope.FreezeRope then return end
            
            local rope = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("rope")
            if not rope then return end
            
            for _, v in ipairs(rope:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Anchored = true
                    v.Velocity = Vector3.zero
                    v.RotVelocity = Vector3.zero
                elseif v:IsA("Constraint") or v:IsA("RopeConstraint") or v:IsA("Motor6D") then
                    v.Enabled = false
                end
            end
        end)
    else
        local rope = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("rope")
        if rope then
            for _, v in ipairs(rope:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Anchored = false
                elseif v:IsA("Constraint") or v:IsA("RopeConstraint") or v:IsA("Motor6D") then
                    v.Enabled = true
                end
            end
        end
    end
end

-- No Balance
function MainModule.ToggleNoBalance(enabled)
    MainModule.JumpRope.NoBalance = enabled
    
    if jumpRopeNoBalanceConnection then
        jumpRopeNoBalanceConnection:Disconnect()
        jumpRopeNoBalanceConnection = nil
    end
    
    if enabled then
        if not MainModule.JumpRope.GameActive then
            warn("Jump Rope не активна!")
            MainModule.JumpRope.NoBalance = false
            return
        end
        
        jumpRopeNoBalanceConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.JumpRope.NoBalance then return end
            
            local player = Players.LocalPlayer
            if player:FindFirstChild("PlayingJumpRope") then
                player.PlayingJumpRope:Destroy()
            end
        end)
    end
end

-- Auto Jump
function MainModule.ToggleAutoJump(enabled)
    MainModule.JumpRope.AutoJump = enabled
    
    if jumpRopeAutoJumpConnection then
        jumpRopeAutoJumpConnection:Disconnect()
        jumpRopeAutoJumpConnection = nil
    end
    
    if enabled then
        if not MainModule.JumpRope.GameActive then
            warn("Jump Rope не активна!")
            MainModule.JumpRope.AutoJump = false
            return
        end
        
        jumpRopeAutoJumpConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.JumpRope.AutoJump then return end
            
            local rope = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("rope")
            if rope and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local HRP = LocalPlayer.Character.HumanoidRootPart
                local distance = (HRP.Position - rope.Position).Magnitude
                if distance <= 15 then
                    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end
        end)
    end
end

-- Anti Fall для Jump Rope
function MainModule.ToggleAntiFallJumpRope(enabled)
    MainModule.JumpRope.AntiFall = enabled
    
    if jumpRopeAntiFallConnection then
        jumpRopeAntiFallConnection:Disconnect()
        jumpRopeAntiFallConnection = nil
    end
    
    if enabled then
        if not MainModule.JumpRope.GameActive then
            warn("Jump Rope не активна!")
            MainModule.JumpRope.AntiFall = false
            return
        end
        
        jumpRopeAntiFallConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.JumpRope.AntiFall then return end
            
            local character = LocalPlayer.Character
            if not character then return end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChild("Humanoid")
            
            if not rootPart or not humanoid or humanoid.Health <= 0 then return end
            
            if rootPart.Position.Y < 190 then
                -- Телепортируем обратно на старт
                rootPart.CFrame = CFrame.new(700.123, 198.456, 920.789)
            end
        end)
    end
end

-- Anti-Fall Platform для Jump Rope
function MainModule.ToggleAntiFallPlatformJumpRope(enabled)
    if enabled then
        if not MainModule.JumpRope.GameActive then
            warn("Jump Rope не активна!")
            return
        end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        -- Удаляем старую платформу если есть
        if MainModule.JumpRope.JumpRopePlatform then
            MainModule.JumpRope.JumpRopePlatform:Destroy()
        end
        
        -- Создаем новую платформу
        local platform = Instance.new("Part")
        platform.Name = "JumpRopeAntiFallPlatform"
        platform.Size = Vector3.new(500, 5, 500)
        platform.Position = Vector3.new(rootPart.Position.X, 190, rootPart.Position.Z)
        platform.Anchored = true
        platform.CanCollide = true
        platform.Transparency = 0.7
        platform.Material = Enum.Material.Neon
        platform.Color = Color3.fromRGB(0, 120, 255)
        platform.Parent = workspace
        
        MainModule.JumpRope.JumpRopePlatform = platform
    else
        -- Удаляем платформу
        if MainModule.JumpRope.JumpRopePlatform then
            MainModule.JumpRope.JumpRopePlatform:Destroy()
            MainModule.JumpRope.JumpRopePlatform = nil
        end
    end
end

function MainModule.ToggleAntiFailJumpRope(enabled)
    MainModule.JumpRope.AntiFail = enabled
    -- Оставлено для совместимости
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
    -- Отключаем все соединения
    local connections = {
        speedConnection, autoFarmConnection, godModeConnection, instaInteractConnection,
        noCooldownConnection, antiStunConnection, rapidFireConnection, infiniteAmmoConnection,
        hitboxConnection, autoPullConnection, antiBreakConnection, espConnection,
        hnsAutoPickupConnection, hnsSpikesKillConnection, hnsKillHidersConnection,
        hnsDisableSpikesConnection, jumpRopeAntiFailConnection, glassBridgeESPConnection,
        antiStunRagdollConnection, glassBridgeAntiBreakConnection, glassBridgeVisionConnection,
        glassBridgePlatformsConnection, jumpRopeAutoJumpConnection, jumpRopeFreezeConnection,
        jumpRopeNoBalanceConnection, jumpRopeAntiFallConnection, rebelInfAmmoConnection,
        rebelRapidFireConnection, gameCheckConnection
    }
    
    for _, conn in pairs(connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    
    -- Восстанавливаем хитбоксы
    if MainModule.Guards.OriginalHitboxes then
        for part, originalSize in pairs(MainModule.Guards.OriginalHitboxes) do
            if part and part.Parent then
                part.Size = originalSize
                part.Transparency = 0
                part.CanCollide = true
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
        pcall(function() MainModule.ESPFolder:Destroy() end)
        MainModule.ESPFolder = nil
    end
    
    -- Восстанавливаем шипы
    if MainModule.HNS.DisableSpikes then
        MainModule.ToggleDisableSpikes(false)
    end
    
    -- Удаляем Glass Bridge платформы
    if MainModule.GlassBridge.GlassBridgeCover then
        MainModule.GlassBridge.GlassBridgeCover:Destroy()
        MainModule.GlassBridge.GlassBridgeCover = nil
    end
    
    for _, platform in ipairs(MainModule.GlassBridge.GlassPlatformsTable) do
        if platform then
            platform:Destroy()
        end
    end
    MainModule.GlassBridge.GlassPlatformsTable = {}
    
    if MainModule.GlassBridge.GlassBridgePlatform then
        MainModule.GlassBridge.GlassBridgePlatform:Destroy()
        MainModule.GlassBridge.GlassBridgePlatform = nil
    end
    
    -- Удаляем Jump Rope платформы
    if MainModule.JumpRope.JumpRopePlatform then
        MainModule.JumpRope.JumpRopePlatform:Destroy()
        MainModule.JumpRope.JumpRopePlatform = nil
    end
    
    print("Creon X очищен!")
end

-- Запускаем проверку игр
MainModule.SetupGameCheck()

-- Автоматическая очистка при выходе
game:GetService("Players").LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not game:GetService("Players").LocalPlayer.Parent then
        MainModule.Cleanup()
    end
end)

return MainModule
