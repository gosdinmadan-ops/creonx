-- Main.lua - Creon X v2.1
local MainModule = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Система проверки текущей игры
MainModule.CurrentGame = {
    GameName = nil,
    GameChanged = Instance.new("BindableEvent")
}

-- Функция для проверки текущей игры
function MainModule.CheckCurrentGame()
    pcall(function()
        if Workspace:FindFirstChild("Values") then
            local currentGame = Workspace.Values:FindFirstChild("CurrentGame")
            if currentGame then
                local oldGame = MainModule.CurrentGame.GameName
                MainModule.CurrentGame.GameName = currentGame.Value
                if oldGame ~= MainModule.CurrentGame.GameName then
                    MainModule.CurrentGame.GameChanged:Fire(MainModule.CurrentGame.GameName)
                end
            end
        end
    end)
end

-- Автоматическая проверка игры
task.spawn(function()
    while true do
        MainModule.CheckCurrentGame()
        task.wait(1)
    end
end)

-- Проверка, доступна ли игра для функций
function MainModule.IsGameActive(gameName)
    if MainModule.CurrentGame.GameName == gameName then
        return true
    end
    
    -- Дополнительные проверки для игр без значения CurrentGame
    pcall(function()
        if gameName == "HNS" then
            local hideAndSeekMap = Workspace:FindFirstChild("HideAndSeekMap")
            if hideAndSeekMap then return true end
        elseif gameName == "Guards" then
            local weaponsFolder = ReplicatedStorage:FindFirstChild("Weapons")
            if weaponsFolder then return true end
        elseif gameName == "Dalgona" then
            local dalgonaModule = ReplicatedStorage:FindFirstChild("Modules") and 
                                 ReplicatedStorage.Modules:FindFirstChild("Games") and
                                 ReplicatedStorage.Modules.Games:FindFirstChild("DalgonaClient")
            if dalgonaModule then return true end
        elseif gameName == "GlassBridge" then
            local glassBridge = Workspace:FindFirstChild("GlassBridge")
            if glassBridge then return true end
        elseif gameName == "JumpRope" then
            local jumpRope = Workspace:FindFirstChild("Effects") and Workspace.Effects:FindFirstChild("rope")
            if jumpRope then return true end
        elseif gameName == "RLGL" then
            -- Проверка по координатам
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local pos = character.HumanoidRootPart.Position
                if pos.Y > 1020 and math.abs(pos.X + 55) < 100 and math.abs(pos.Z + 545) < 100 then
                    return true
                end
            end
        elseif gameName == "SkySquid" then
            local skySquidGame = Workspace:FindFirstChild("SkySquidGame")
            if skySquidGame then return true end
        end
    end)
    
    return false
end

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
    InfAmmo = false,
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
    OriginalHitboxes = {} -- Для восстановления хитбоксов
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
    FakeGlassEnabled = false,
    FakeGlassParts = {},
    AntiFallEnabled = false,
    AntiFallPlatform = nil
}

MainModule.JumpRope = {
    AntiFail = false,
    TeleportToStart = false,
    TeleportToEnd = false,
    AntiFallEnabled = false,
    AntiFallPlatform = nil,
    NoBalance = false
}

MainModule.SkySquid = {
    AntiFallEnabled = false,
    AntiFallPlatform = nil,
    SafePlatformEnabled = false,
    VoidKillEnabled = false
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
MainModule.ESPUpdateRate = 2 -- Увеличено для оптимизации
MainModule.LastESPUpdate = 0
MainModule.ESPConnection = nil

-- HNS шипы
MainModule.HNSSpikes = {
    Positions = {},
    OriginalPositions = {},
    Disabled = false
}

-- Glass Bridge улучшенный AntiBreak
MainModule.GlassBridgeDummyParts = {}

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
local jumpRopeAntiFallConnection = nil
local glassBridgeAntiFallConnection = nil
local gameCheckConnection = nil

-- Локальный игрок
local LocalPlayer = Players.LocalPlayer

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
    
    if MainModule.ESPConnection then
        MainModule.ESPConnection:Disconnect()
        MainModule.ESPConnection = nil
    end
    
    -- Очищаем старые ESP
    for _, esp in pairs(MainModule.ESPTable) do
        if esp and esp.Destroy then
            esp:Destroy()
        end
    end
    MainModule.ESPTable = {}
    
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
        
        -- Оптимизированное обновление ESP (редкие обновления)
        MainModule.ESPConnection = RunService.RenderStepped:Connect(function()
            local currentTime = tick()
            if currentTime - MainModule.LastESPUpdate < MainModule.ESPUpdateRate then
                return
            end
            MainModule.LastESPUpdate = currentTime
            
            -- Обновляем ESP раз в 2 секунды для оптимизации
            pcall(function()
                -- ESP для игроков
                if MainModule.Misc.ESPPlayers then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                            local humanoid = player.Character.Humanoid
                            if humanoid.Health > 0 then
                                if not MainModule.ESPTable[player] then
                                    local highlight = Instance.new("Highlight")
                                    highlight.Name = "ESP_Highlight"
                                    highlight.Adornee = player.Character
                                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    highlight.FillColor = Color3.fromRGB(0, 170, 255)
                                    highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
                                    highlight.OutlineColor = Color3.fromRGB(0, 170, 255)
                                    highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
                                    highlight.Enabled = MainModule.Misc.ESPHighlight and MainModule.Misc.ESPBoxes
                                    highlight.Parent = player.Character
                                    
                                    local billboard = Instance.new("BillboardGui")
                                    billboard.Name = "ESP_Billboard"
                                    billboard.Adornee = player.Character:FindFirstChild("HumanoidRootPart") or player.Character.PrimaryPart
                                    billboard.AlwaysOnTop = true
                                    billboard.Size = UDim2.new(0, 200, 0, 50)
                                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                                    billboard.Parent = MainModule.ESPFolder
                                    
                                    local textLabel = Instance.new("TextLabel")
                                    textLabel.Name = "ESP_Text"
                                    textLabel.BackgroundTransparency = 1
                                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                                    textLabel.Text = player.DisplayName .. " [HP: " .. math.floor(humanoid.Health) .. "]"
                                    textLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
                                    textLabel.TextSize = MainModule.Misc.ESPTextSize
                                    textLabel.Font = Enum.Font.GothamBold
                                    textLabel.TextStrokeTransparency = 0.3
                                    textLabel.Parent = billboard
                                    
                                    -- Сохраняем в таблицу
                                    MainModule.ESPTable[player] = {
                                        Highlight = highlight,
                                        Billboard = billboard,
                                        TextLabel = textLabel,
                                        Destroy = function()
                                            if highlight then highlight:Destroy() end
                                            if billboard then billboard:Destroy() end
                                        end
                                    }
                                else
                                    -- Обновляем существующий ESP
                                    local espData = MainModule.ESPTable[player]
                                    if espData and espData.TextLabel then
                                        espData.TextLabel.Text = player.DisplayName .. " [HP: " .. math.floor(humanoid.Health) .. "]"
                                    end
                                end
                            elseif MainModule.ESPTable[player] then
                                MainModule.ESPTable[player]:Destroy()
                                MainModule.ESPTable[player] = nil
                            end
                        elseif MainModule.ESPTable[player] then
                            MainModule.ESPTable[player]:Destroy()
                            MainModule.ESPTable[player] = nil
                        end
                    end
                end
                
                -- ESP для HNS (Hiders и Seekers)
                if MainModule.Misc.ESPHiders or MainModule.Misc.ESPSeekers then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local isHider = player:GetAttribute("IsHider")
                            local isHunter = player:GetAttribute("IsHunter")
                            
                            if (isHider and MainModule.Misc.ESPHiders) or (isHunter and MainModule.Misc.ESPSeekers) then
                                local espKey = player .. "_hns"
                                if not MainModule.ESPTable[espKey] then
                                    local color = isHider and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                                    local text = player.DisplayName .. (isHider and " (Hider)" or " (Seeker)")
                                    
                                    local highlight = Instance.new("Highlight")
                                    highlight.Name = "ESP_Highlight"
                                    highlight.Adornee = player.Character
                                    highlight.FillColor = color
                                    highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
                                    highlight.OutlineColor = color
                                    highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
                                    highlight.Enabled = MainModule.Misc.ESPHighlight and MainModule.Misc.ESPBoxes
                                    highlight.Parent = player.Character
                                    
                                    local billboard = Instance.new("BillboardGui")
                                    billboard.Name = "ESP_Billboard"
                                    billboard.Adornee = player.Character:FindFirstChild("HumanoidRootPart") or player.Character.PrimaryPart
                                    billboard.AlwaysOnTop = true
                                    billboard.Size = UDim2.new(0, 200, 0, 50)
                                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                                    billboard.Parent = MainModule.ESPFolder
                                    
                                    local textLabel = Instance.new("TextLabel")
                                    textLabel.Name = "ESP_Text"
                                    textLabel.BackgroundTransparency = 1
                                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                                    textLabel.Text = text
                                    textLabel.TextColor3 = color
                                    textLabel.TextSize = MainModule.Misc.ESPTextSize
                                    textLabel.Font = Enum.Font.GothamBold
                                    textLabel.TextStrokeTransparency = 0.3
                                    textLabel.Parent = billboard
                                    
                                    MainModule.ESPTable[espKey] = {
                                        Highlight = highlight,
                                        Billboard = billboard,
                                        TextLabel = textLabel,
                                        Destroy = function()
                                            if highlight then highlight:Destroy() end
                                            if billboard then billboard:Destroy() end
                                        end
                                    }
                                end
                            elseif MainModule.ESPTable[player .. "_hns"] then
                                MainModule.ESPTable[player .. "_hns"]:Destroy()
                                MainModule.ESPTable[player .. "_hns"] = nil
                            end
                        end
                    end
                end
                
                -- ESP для объектов (обновляем редко)
                if MainModule.Misc.ESPCandies or MainModule.Misc.ESPKeys or MainModule.Misc.ESPGuards then
                    -- Проверяем только каждые 10 секунд
                    if math.random(1, 10) == 1 then
                        -- ESP для конфет
                        if MainModule.Misc.ESPCandies then
                            for _, obj in pairs(Workspace:GetDescendants()) do
                                if obj:IsA("Model") and obj.Name:lower():find("candy") and obj.PrimaryPart then
                                    if not MainModule.ESPTable[obj] then
                                        local billboard = Instance.new("BillboardGui")
                                        billboard.Name = "ESP_Billboard"
                                        billboard.Adornee = obj.PrimaryPart
                                        billboard.AlwaysOnTop = true
                                        billboard.Size = UDim2.new(0, 200, 0, 50)
                                        billboard.StudsOffset = Vector3.new(0, 2, 0)
                                        billboard.Parent = MainModule.ESPFolder
                                        
                                        local textLabel = Instance.new("TextLabel")
                                        textLabel.Name = "ESP_Text"
                                        textLabel.BackgroundTransparency = 1
                                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                                        textLabel.Text = "Candy"
                                        textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                                        textLabel.TextSize = MainModule.Misc.ESPTextSize
                                        textLabel.Font = Enum.Font.GothamBold
                                        textLabel.TextStrokeTransparency = 0.3
                                        textLabel.Parent = billboard
                                        
                                        MainModule.ESPTable[obj] = {
                                            Billboard = billboard,
                                            Destroy = function()
                                                if billboard then billboard:Destroy() end
                                            end
                                        }
                                    end
                                end
                            end
                        end
                        
                        -- ESP для ключей
                        if MainModule.Misc.ESPKeys then
                            for _, obj in pairs(Workspace:GetDescendants()) do
                                if obj:IsA("Model") and obj.Name:lower():find("key") and obj.PrimaryPart then
                                    if not MainModule.ESPTable[obj] then
                                        local billboard = Instance.new("BillboardGui")
                                        billboard.Name = "ESP_Billboard"
                                        billboard.Adornee = obj.PrimaryPart
                                        billboard.AlwaysOnTop = true
                                        billboard.Size = UDim2.new(0, 200, 0, 50)
                                        billboard.StudsOffset = Vector3.new(0, 2, 0)
                                        billboard.Parent = MainModule.ESPFolder
                                        
                                        local textLabel = Instance.new("TextLabel")
                                        textLabel.Name = "ESP_Text"
                                        textLabel.BackgroundTransparency = 1
                                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                                        textLabel.Text = "Key"
                                        textLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
                                        textLabel.TextSize = MainModule.Misc.ESPTextSize
                                        textLabel.Font = Enum.Font.GothamBold
                                        textLabel.TextStrokeTransparency = 0.3
                                        textLabel.Parent = billboard
                                        
                                        MainModule.ESPTable[obj] = {
                                            Billboard = billboard,
                                            Destroy = function()
                                                if billboard then billboard:Destroy() end
                                            end
                                        }
                                    end
                                end
                            end
                        end
                        
                        -- ESP для охранников
                        if MainModule.Misc.ESPGuards then
                            for _, obj in pairs(Workspace:GetDescendants()) do
                                if obj:IsA("Model") and obj.Name:lower():find("guard") and obj:FindFirstChild("HumanoidRootPart") then
                                    if not MainModule.ESPTable[obj] then
                                        local highlight = Instance.new("Highlight")
                                        highlight.Name = "ESP_Highlight"
                                        highlight.Adornee = obj
                                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                                        highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
                                        highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                                        highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
                                        highlight.Enabled = MainModule.Misc.ESPHighlight and MainModule.Misc.ESPBoxes
                                        highlight.Parent = obj
                                        
                                        local billboard = Instance.new("BillboardGui")
                                        billboard.Name = "ESP_Billboard"
                                        billboard.Adornee = obj.HumanoidRootPart
                                        billboard.AlwaysOnTop = true
                                        billboard.Size = UDim2.new(0, 200, 0, 50)
                                        billboard.StudsOffset = Vector3.new(0, 3, 0)
                                        billboard.Parent = MainModule.ESPFolder
                                        
                                        local textLabel = Instance.new("TextLabel")
                                        textLabel.Name = "ESP_Text"
                                        textLabel.BackgroundTransparency = 1
                                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                                        textLabel.Text = "Guard"
                                        textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                                        textLabel.TextSize = MainModule.Misc.ESPTextSize
                                        textLabel.Font = Enum.Font.GothamBold
                                        textLabel.TextStrokeTransparency = 0.3
                                        textLabel.Parent = billboard
                                        
                                        MainModule.ESPTable[obj] = {
                                            Highlight = highlight,
                                            Billboard = billboard,
                                            Destroy = function()
                                                if highlight then highlight:Destroy() end
                                                if billboard then billboard:Destroy() end
                                            end
                                        }
                                    end
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
                esp:Destroy()
            end
        end
        MainModule.ESPTable = {}
        
        if MainModule.ESPFolder then
            MainModule.ESPFolder:Destroy()
            MainModule.ESPFolder = nil
        end
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

-- Rebel функция с Inf Ammo и Rapid Fire
function MainModule.ToggleRebel(enabled)
    MainModule.Rebel.Enabled = enabled
    _G.InstantRebel = enabled
    
    if enabled then
        -- Включаем Inf Ammo для Rebel
        MainModule.Rebel.InfAmmo = true
        MainModule.ToggleInfiniteAmmo(true)
        
        -- Включаем Rapid Fire для Rebel
        MainModule.Rebel.RapidFire = true
        MainModule.ToggleRapidFire(true)
    else
        -- Выключаем Inf Ammo и Rapid Fire
        MainModule.Rebel.InfAmmo = false
        MainModule.Rebel.RapidFire = false
        MainModule.ToggleInfiniteAmmo(false)
        MainModule.ToggleRapidFire(false)
    end
end

-- RLGL функции
function MainModule.TeleportToEndRLGL()
    if not MainModule.IsGameActive("RLGL") then
        warn("RLGL не активна!")
        return
    end
    
    local player = LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-214.4, 1023.1, 146.7)
    end
end

function MainModule.TeleportToStartRLGL()
    if not MainModule.IsGameActive("RLGL") then
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
    
    if enabled and MainModule.IsGameActive("RLGL") then
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
    if not MainModule.IsGameActive("Guards") then
        warn("Guards не активна!")
        return
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
    
    if enabled and MainModule.IsGameActive("Guards") then
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
    
    if enabled and MainModule.IsGameActive("Guards") then
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
        -- Восстанавливаем исходные значения
        pcall(function()
            local weaponsFolder = ReplicatedStorage:FindFirstChild("Weapons")
            if weaponsFolder then
                local gunsFolder = weaponsFolder:FindFirstChild("Guns")
                if gunsFolder then
                    for obj, originalValue in pairs(MainModule.Guards.OriginalFireRates) do
                        if obj and obj.Parent then
                            obj.Value = originalValue
                        end
                    end
                end
            end
        end)
        MainModule.Guards.OriginalFireRates = {}
    end
end

-- Infinite Ammo функция
function MainModule.ToggleInfiniteAmmo(enabled)
    MainModule.Guards.InfiniteAmmo = enabled
    
    if infiniteAmmoConnection then
        infiniteAmmoConnection:Disconnect()
        infiniteAmmoConnection = nil
    end
    
    if enabled and MainModule.IsGameActive("Guards") then
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
                                    obj.Value = math.huge
                                end
                            end
                        end
                    end
                end
            end
        end)
    else
        -- Восстанавливаем исходные значения
        for obj, originalValue in pairs(MainModule.Guards.OriginalAmmo) do
            if obj and obj.Parent then
                obj.Value = originalValue
            end
        end
        MainModule.Guards.OriginalAmmo = {}
    end
end

-- Hitbox Expander функция (исправленная версия)
function MainModule.ToggleHitboxExpander(enabled)
    MainModule.Guards.HitboxExpander = enabled
    
    if hitboxConnection then
        hitboxConnection:Disconnect()
        hitboxConnection = nil
    end
    
    -- Глобальные настройки
    _G.HeadSize = 1000
    _G.Disabled = enabled
    
    if enabled and MainModule.IsGameActive("Guards") then
        -- Кэшируем часто используемые сервисы
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local LocalPlayer = Players.LocalPlayer
        
        -- Создаем таблицу для кэширования измененных частей
        local modifiedParts = {}
        
        local function modifyPart(part)
            if not modifiedParts[part] then
                if not MainModule.Guards.OriginalHitboxes[part] then
                    MainModule.Guards.OriginalHitboxes[part] = part.Size
                end
                part.Size = Vector3.new(_G.HeadSize, _G.HeadSize, _G.HeadSize)
                part.CanCollide = false
                modifiedParts[part] = true
            end
        end
        
        -- Обработчик для новых игроков
        local function onPlayerAdded(player)
            player.CharacterAdded:Connect(function(character)
                if _G.Disabled then
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
        hitboxConnection = RunService.RenderStepped:Connect(function()
            if not _G.Disabled then return end
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local root = player.Character:FindFirstChild("HumanoidRootPart")
                    if root and not modifiedParts[root] then
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
                    modifiedParts[root] = nil
                end
            end
        end)
    else
        -- Восстанавливаем оригинальные размеры
        for part, originalSize in pairs(MainModule.Guards.OriginalHitboxes) do
            if part and part.Parent and part:IsA("BasePart") then
                part.Size = originalSize
                part.CanCollide = true
            end
        end
        MainModule.Guards.OriginalHitboxes = {}
        _G.Disabled = false
    end
end

-- Dalgona функции
function MainModule.CompleteDalgona()
    if not MainModule.IsGameActive("Dalgona") then
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
    if not MainModule.IsGameActive("Dalgona") then
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
    
    if enabled and MainModule.IsGameActive("HNS") then
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
    
    if enabled and MainModule.IsGameActive("HNS") then
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

-- Кнопка Disable Spikes (одноразовое действие)
function MainModule.DisableSpikes()
    if not MainModule.IsGameActive("HNS") then
        warn("HNS не активна!")
        return
    end
    
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
    
    return "Шипы отключены!"
end

function MainModule.ToggleKillHiders(enabled)
    MainModule.HNS.KillHiders = enabled
    
    if hnsKillHidersConnection then
        hnsKillHidersConnection:Disconnect()
        hnsKillHidersConnection = nil
    end
    
    if enabled and MainModule.IsGameActive("HNS") then
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
    
    if enabled and MainModule.IsGameActive("TugOfWar") then
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
function MainModule.ToggleAntiBreak(enabled)
    MainModule.GlassBridge.AntiBreak = enabled
    
    if antiBreakConnection then
        antiBreakConnection:Disconnect()
        antiBreakConnection = nil
    end
    
    if enabled and MainModule.IsGameActive("GlassBridge") then
        -- Очищаем старые dummy части
        for _, part in pairs(MainModule.GlassBridgeDummyParts) do
            if part and part.Parent then
                part:Destroy()
            end
        end
        MainModule.GlassBridgeDummyParts = {}
        
        -- Создаем защитные части для каждого стекла
        pcall(function()
            local GlassHolder = Workspace:FindFirstChild("GlassBridge") and Workspace.GlassBridge:FindFirstChild("GlassHolder")
            if not GlassHolder then return end
            
            for _, tilePair in pairs(GlassHolder:GetChildren()) do
                for _, tileModel in pairs(tilePair:GetChildren()) do
                    if tileModel:IsA("Model") and tileModel.PrimaryPart then
                        -- Создаем невидимую копию части
                        local dummyPart = Instance.new("Part")
                        dummyPart.Name = "AntiBreakDummy"
                        dummyPart.Size = tileModel.PrimaryPart.Size
                        dummyPart.CFrame = tileModel.PrimaryPart.CFrame
                        dummyPart.Anchored = true
                        dummyPart.CanCollide = true
                        dummyPart.Transparency = 1
                        dummyPart.Material = Enum.Material.Neon
                        dummyPart.Color = Color3.fromRGB(0, 255, 0)
                        dummyPart.Parent = tileModel
                        
                        table.insert(MainModule.GlassBridgeDummyParts, dummyPart)
                        
                        -- Отключаем атрибут взлома
                        if tileModel.PrimaryPart:GetAttribute("exploitingisevil") ~= nil then
                            tileModel.PrimaryPart:SetAttribute("exploitingisevil", nil)
                        end
                    end
                end
            end
        end)
        
        antiBreakConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.GlassBridge.AntiBreak then return end
            
            pcall(function()
                local GlassHolder = Workspace:FindFirstChild("GlassBridge") and Workspace.GlassBridge:FindFirstChild("GlassHolder")
                if not GlassHolder then return end
                
                for _, tilePair in pairs(GlassHolder:GetChildren()) do
                    for _, tileModel in pairs(tilePair:GetChildren()) do
                        if tileModel:IsA("Model") and tileModel.PrimaryPart then
                            if tileModel.PrimaryPart:GetAttribute("exploitingisevil") ~= nil then
                                tileModel.PrimaryPart:SetAttribute("exploitingisevil", nil)
                            end
                            
                            -- Обновляем позицию dummy части
                            for _, dummyPart in pairs(MainModule.GlassBridgeDummyParts) do
                                if dummyPart.Parent == tileModel then
                                    dummyPart.CFrame = tileModel.PrimaryPart.CFrame
                                end
                            end
                        end
                    end
                end
            end)
        end)
    else
        -- Удаляем dummy части
        for _, part in pairs(MainModule.GlassBridgeDummyParts) do
            if part and part.Parent then
                part:Destroy()
            end
        end
        MainModule.GlassBridgeDummyParts = {}
    end
end

-- Кнопка Glass ESP (одноразовое действие)
function MainModule.ShowGlassESP()
    if not MainModule.IsGameActive("GlassBridge") then
        warn("Glass Bridge не активна!")
        return "Игра не активна"
    end
    
    pcall(function()
        local GlassHolder = Workspace:WaitForChild("GlassBridge"):WaitForChild("GlassHolder")

        for i, v in pairs(GlassHolder:GetChildren()) do
            for g, j in pairs(v:GetChildren()) do
                if j:IsA("Model") and j.PrimaryPart then
                    local Color = j.PrimaryPart:GetAttribute("exploitingisevil") 
                        and Color3.fromRGB(248, 87, 87) 
                        or Color3.fromRGB(28, 235, 87)
                    j.PrimaryPart.Color = Color
                    j.PrimaryPart.Transparency = 0
                    j.PrimaryPart.Material = Enum.Material.Neon
                end
            end
        end
    end)
    
    return "Glass ESP активирован!"
end

-- Кнопка Fake Glass (одноразовое действие)
function MainModule.CreateFakeGlass()
    if not MainModule.IsGameActive("GlassBridge") then
        warn("Glass Bridge не активна!")
        return "Игра не активна"
    end
    
    pcall(function()
        local GlassHolder = Workspace:FindFirstChild("GlassBridge")
        if not GlassHolder then
            return
        end

        GlassHolder = GlassHolder:FindFirstChild("GlassHolder")
        if not GlassHolder then
            return
        end

        local models = GlassHolder:GetChildren()

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

        MainModule.GlassBridge.FakeGlassParts[coverPart] = true
    end)
    
    return "Fake Glass создан!"
end

-- Glass Bridge Anti-Fall
function MainModule.ToggleGlassBridgeAntiFall(enabled)
    MainModule.GlassBridge.AntiFallEnabled = enabled
    
    if glassBridgeAntiFallConnection then
        glassBridgeAntiFallConnection:Disconnect()
        glassBridgeAntiFallConnection = nil
    end
    
    if MainModule.GlassBridge.AntiFallPlatform then
        MainModule.GlassBridge.AntiFallPlatform:Destroy()
        MainModule.GlassBridge.AntiFallPlatform = nil
    end
    
    if enabled and MainModule.IsGameActive("GlassBridge") then
        -- Создаем платформу
        MainModule.GlassBridge.AntiFallPlatform = Instance.new("Part")
        MainModule.GlassBridge.AntiFallPlatform.Name = "GlassBridge_AntiFall"
        MainModule.GlassBridge.AntiFallPlatform.Size = Vector3.new(500, 5, 500)
        MainModule.GlassBridge.AntiFallPlatform.Position = Vector3.new(-200, 520, -1530)
        MainModule.GlassBridge.AntiFallPlatform.Anchored = true
        MainModule.GlassBridge.AntiFallPlatform.CanCollide = true
        MainModule.GlassBridge.AntiFallPlatform.Transparency = 0.7
        MainModule.GlassBridge.AntiFallPlatform.Material = Enum.Material.Neon
        MainModule.GlassBridge.AntiFallPlatform.Color = Color3.fromRGB(0, 170, 255)
        MainModule.GlassBridge.AntiFallPlatform.Parent = workspace
        
        glassBridgeAntiFallConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.GlassBridge.AntiFallEnabled then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if not rootPart then return end
                
                -- Проверяем, не падаем ли мы
                if rootPart.Position.Y < 500 then
                    -- Телепортируем на платформу
                    local targetPos = MainModule.GlassBridge.AntiFallPlatform.Position + Vector3.new(0, 10, 0)
                    rootPart.CFrame = CFrame.new(targetPos)
                end
            end)
        end)
    end
end

-- Jump Rope функции
function MainModule.TeleportToJumpRopeStart()
    if not MainModule.IsGameActive("JumpRope") then
        warn("Jump Rope не активна!")
        return
    end
    
    local player = LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(615.284424, 192.274277, 920.952515)
    end
end

function MainModule.TeleportToJumpRopeEnd()
    if not MainModule.IsGameActive("JumpRope") then
        warn("Jump Rope не активна!")
        return
    end
    
    local player = LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(737.156372, 193.805084, 920.952515)
    end
end

function MainModule.ToggleAntiFailJumpRope(enabled)
    MainModule.JumpRope.AntiFail = enabled
    
    if jumpRopeAntiFailConnection then
        jumpRopeAntiFailConnection:Disconnect()
        jumpRopeAntiFailConnection = nil
    end
    
    if enabled and MainModule.IsGameActive("JumpRope") then
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

-- NO BALANCE функция
function MainModule.ToggleNoBalance(enabled)
    MainModule.JumpRope.NoBalance = enabled
    
    if enabled and MainModule.IsGameActive("JumpRope") then
        pcall(function()
            local player = Players.LocalPlayer
            if player:FindFirstChild("PlayingJumpRope") then
                player.PlayingJumpRope:Destroy()
            end
        end)
    end
end

-- Jump Rope Anti-Fall
function MainModule.ToggleJumpRopeAntiFall(enabled)
    MainModule.JumpRope.AntiFallEnabled = enabled
    
    if jumpRopeAntiFallConnection then
        jumpRopeAntiFallConnection:Disconnect()
        jumpRopeAntiFallConnection = nil
    end
    
    if MainModule.JumpRope.AntiFallPlatform then
        MainModule.JumpRope.AntiFallPlatform:Destroy()
        MainModule.JumpRope.AntiFallPlatform = nil
    end
    
    if enabled and MainModule.IsGameActive("JumpRope") then
        -- Создаем платформу
        MainModule.JumpRope.AntiFallPlatform = Instance.new("Part")
        MainModule.JumpRope.AntiFallPlatform.Name = "JumpRope_AntiFall"
        MainModule.JumpRope.AntiFallPlatform.Size = Vector3.new(500, 5, 500)
        MainModule.JumpRope.AntiFallPlatform.Position = Vector3.new(676, 190, 921)
        MainModule.JumpRope.AntiFallPlatform.Anchored = true
        MainModule.JumpRope.AntiFallPlatform.CanCollide = true
        MainModule.JumpRope.AntiFallPlatform.Transparency = 0.7
        MainModule.JumpRope.AntiFallPlatform.Material = Enum.Material.Neon
        MainModule.JumpRope.AntiFallPlatform.Color = Color3.fromRGB(0, 170, 255)
        MainModule.JumpRope.AntiFallPlatform.Parent = workspace
        
        jumpRopeAntiFallConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.JumpRope.AntiFallEnabled then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if not rootPart then return end
                
                -- Проверяем, не падаем ли мы
                if rootPart.Position.Y < 185 then
                    -- Телепортируем на платформу
                    local targetPos = MainModule.JumpRope.AntiFallPlatform.Position + Vector3.new(0, 10, 0)
                    rootPart.CFrame = CFrame.new(targetPos)
                end
            end)
        end)
    end
end

-- Sky Squid функции
function MainModule.ToggleSkySquidAntiFall(enabled)
    MainModule.SkySquid.AntiFallEnabled = enabled
    
    if skySquidAntiFallConnection then
        skySquidAntiFallConnection:Disconnect()
        skySquidAntiFallConnection = nil
    end
    
    if MainModule.SkySquid.AntiFallPlatform then
        MainModule.SkySquid.AntiFallPlatform:Destroy()
        MainModule.SkySquid.AntiFallPlatform = nil
    end
    
    if enabled and MainModule.IsGameActive("SkySquid") then
        -- Создаем платформу
        MainModule.SkySquid.AntiFallPlatform = Instance.new("Part")
        MainModule.SkySquid.AntiFallPlatform.Name = "SkySquid_AntiFall"
        MainModule.SkySquid.AntiFallPlatform.Size = Vector3.new(500, 5, 500)
        MainModule.SkySquid.AntiFallPlatform.Position = Vector3.new(0, 100, 0)
        MainModule.SkySquid.AntiFallPlatform.Anchored = true
        MainModule.SkySquid.AntiFallPlatform.CanCollide = true
        MainModule.SkySquid.AntiFallPlatform.Transparency = 0.7
        MainModule.SkySquid.AntiFallPlatform.Material = Enum.Material.Neon
        MainModule.SkySquid.AntiFallPlatform.Color = Color3.fromRGB(0, 170, 255)
        MainModule.SkySquid.AntiFallPlatform.Parent = workspace
        
        skySquidAntiFallConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.SkySquid.AntiFallEnabled then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if not rootPart then return end
                
                -- Проверяем, не падаем ли мы
                if rootPart.Position.Y < 50 then
                    -- Ищем ближайшего игрока для телепортации
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
                    
                    if nearestPlayer and nearestPlayer.Character then
                        local targetRoot = nearestPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if targetRoot then
                            rootPart.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
                        end
                    else
                        -- Телепортируем на платформу
                        local targetPos = MainModule.SkySquid.AntiFallPlatform.Position + Vector3.new(0, 10, 0)
                        rootPart.CFrame = CFrame.new(targetPos)
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
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local position = character.HumanoidRootPart.Position
        return string.format("X: %.1f, Y: %.1f, Z: %.1f", position.X, position.Y, position.Z)
    end
    return "Не доступно"
end

-- Функция для получения текущей игры
function MainModule.GetCurrentGame()
    return MainModule.CurrentGame.GameName or "Неизвестно"
end

-- Очистка всех функций при смене игры
MainModule.CurrentGame.GameChanged:Connect(function(gameName)
    print("Игра сменилась на: " .. (gameName or "Неизвестно"))
    
    -- Автоматически отключаем функции, если игра закончилась
    if not gameName or gameName == "" then
        -- Отключаем все специфичные функции игр
        if MainModule.GlassBridge.AntiBreak then
            MainModule.ToggleAntiBreak(false)
        end
        
        if MainModule.JumpRope.AntiFail then
            MainModule.ToggleAntiFailJumpRope(false)
        end
        
        if MainModule.GlassBridge.AntiFallEnabled then
            MainModule.ToggleGlassBridgeAntiFall(false)
        end
        
        if MainModule.JumpRope.AntiFallEnabled then
            MainModule.ToggleJumpRopeAntiFall(false)
        end
        
        if MainModule.SkySquid.AntiFallEnabled then
            MainModule.ToggleSkySquidAntiFall(false)
        end
        
        if MainModule.HNS.AutoPickup then
            MainModule.ToggleAutoPickup(false)
        end
        
        if MainModule.HNS.SpikesKill then
            MainModule.ToggleSpikesKill(false)
        end
        
        if MainModule.HNS.KillHiders then
            MainModule.ToggleKillHiders(false)
        end
        
        if MainModule.Guards.AutoFarm then
            MainModule.ToggleAutoFarm(false)
        end
        
        if MainModule.Guards.RapidFire then
            MainModule.ToggleRapidFire(false)
        end
        
        if MainModule.Guards.InfiniteAmmo then
            MainModule.ToggleInfiniteAmmo(false)
        end
        
        if MainModule.Guards.HitboxExpander then
            MainModule.ToggleHitboxExpander(false)
        end
        
        if MainModule.Rebel.Enabled then
            MainModule.ToggleRebel(false)
        end
        
        if MainModule.TugOfWar.AutoPull then
            MainModule.ToggleAutoPull(false)
        end
        
        warn("Все функции выключены, игра окончена.")
    end
end)

-- Очистка при закрытии
function MainModule.Cleanup()
    -- Отключаем все соединения
    local connections = {
        speedConnection, autoFarmConnection, godModeConnection, instaInteractConnection,
        noCooldownConnection, antiStunConnection, rapidFireConnection, infiniteAmmoConnection,
        hitboxConnection, autoPullConnection, antiBreakConnection, MainModule.ESPConnection,
        hnsAutoPickupConnection, hnsSpikesKillConnection, hnsKillHidersConnection,
        hnsDisableSpikesConnection, jumpRopeAntiFailConnection, glassBridgeESPConnection,
        antiStunRagdollConnection, skySquidAntiFallConnection, jumpRopeAntiFallConnection,
        glassBridgeAntiFallConnection, gameCheckConnection
    }
    
    for _, conn in pairs(connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    
    -- Восстанавливаем хитбоксы
    if MainModule.Guards.OriginalHitboxes then
        for part, originalSize in pairs(MainModule.Guards.OriginalHitboxes) do
            if part and part.Parent and part:IsA("BasePart") then
                part.Size = originalSize
                part.CanCollide = true
            end
        end
        MainModule.Guards.OriginalHitboxes = {}
    end
    
    -- Восстанавливаем rapid fire
    if MainModule.Guards.OriginalFireRates then
        for obj, originalValue in pairs(MainModule.Guards.OriginalFireRates) do
            if obj and obj.Parent then
                obj.Value = originalValue
            end
        end
        MainModule.Guards.OriginalFireRates = {}
    end
    
    -- Восстанавливаем ammo
    if MainModule.Guards.OriginalAmmo then
        for obj, originalValue in pairs(MainModule.Guards.OriginalAmmo) do
            if obj and obj.Parent then
                obj.Value = originalValue
            end
        end
        MainModule.Guards.OriginalAmmo = {}
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
    
    -- Восстанавливаем шипы
    if MainModule.HNS.DisableSpikes then
        MainModule.ToggleDisableSpikes(false)
    end
    
    -- Удаляем fake glass
    for part, _ in pairs(MainModule.GlassBridge.FakeGlassParts) do
        if part and part.Parent then
            part:Destroy()
        end
    end
    MainModule.GlassBridge.FakeGlassParts = {}
    
    -- Удаляем dummy части
    for _, part in pairs(MainModule.GlassBridgeDummyParts) do
        if part and part.Parent then
            part:Destroy()
        end
    end
    MainModule.GlassBridgeDummyParts = {}
    
    -- Удаляем платформы
    if MainModule.GlassBridge.AntiFallPlatform then
        MainModule.GlassBridge.AntiFallPlatform:Destroy()
        MainModule.GlassBridge.AntiFallPlatform = nil
    end
    
    if MainModule.JumpRope.AntiFallPlatform then
        MainModule.JumpRope.AntiFallPlatform:Destroy()
        MainModule.JumpRope.AntiFallPlatform = nil
    end
    
    if MainModule.SkySquid.AntiFallPlatform then
        MainModule.SkySquid.AntiFallPlatform:Destroy()
        MainModule.SkySquid.AntiFallPlatform = nil
    end
    
    print("Creon X v2.1 очищен!")
end

-- Автоматическая очистка при выходе
game:GetService("Players").LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not game:GetService("Players").LocalPlayer.Parent then
        MainModule.Cleanup()
    end
end)

return MainModule
