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
    GlassESPEnabled = false
}

MainModule.JumpRope = {
    AntiFail = false,
    TeleportToStart = false,
    TeleportToEnd = false
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
MainModule.ESPUpdateRate = 0.3 -- Больше для оптимизации
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
    
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
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
        
        -- Оптимизированное обновление ESP
        espConnection = RunService.RenderStepped:Connect(function()
            local currentTime = tick()
            if currentTime - MainModule.LastESPUpdate < MainModule.ESPUpdateRate then
                return
            end
            MainModule.LastESPUpdate = currentTime
            
            -- Обновляем ESP раз в 0.3 секунды для оптимизации
            pcall(function()
                -- Очищаем старые ESP
                for _, esp in pairs(MainModule.ESPTable) do
                    if esp and esp.Destroy then
                        esp:Destroy()
                    end
                end
                MainModule.ESPTable = {}
                
                -- ESP для игроков
                if MainModule.Misc.ESPPlayers then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                            local humanoid = player.Character.Humanoid
                            if humanoid.Health > 0 then
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
                            end
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
                                
                                MainModule.ESPTable[player .. "_hns"] = {
                                    Highlight = highlight,
                                    Billboard = billboard,
                                    TextLabel = textLabel,
                                    Destroy = function()
                                        if highlight then highlight:Destroy() end
                                        if billboard then billboard:Destroy() end
                                    end
                                }
                            end
                        end
                    end
                end
                
                -- ESP для конфет
                if MainModule.Misc.ESPCandies then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and obj.Name:lower():find("candy") and obj.PrimaryPart then
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
                
                -- ESP для ключей
                if MainModule.Misc.ESPKeys then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and obj.Name:lower():find("key") and obj.PrimaryPart then
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
                
                -- ESP для охранников
                if MainModule.Misc.ESPGuards then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and obj.Name:lower():find("guard") and obj:FindFirstChild("HumanoidRootPart") then
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

-- Hitbox Expander функция (ИСПРАВЛЕНА - изменяет тело, а не голову)
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
        local HITBOX_SIZE = 1000 -- Очень большой размер для хитбокса
        
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
                                -- Делаем полностью прозрачным чтобы не было заметно
                                part.Transparency = 1
                                -- Отключаем коллизию чтобы не мешать
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

-- HNS функции
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

-- Glass Bridge функции
function MainModule.ToggleAntiBreak(enabled)
    MainModule.GlassBridge.AntiBreak = enabled
    
    if antiBreakConnection then
        antiBreakConnection:Disconnect()
        antiBreakConnection = nil
    end
    
    if enabled then
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
    end
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

-- Jump Rope функции
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
        antiStunRagdollConnection
    }
    
    for _, conn in pairs(connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    
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
    
    -- Восстанавливаем шипы
    if MainModule.HNS.DisableSpikes then
        MainModule.ToggleDisableSpikes(false)
    end
end

-- Автоматическая очистка при выходе
game:GetService("Players").LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not game:GetService("Players").LocalPlayer.Parent then
        MainModule.Cleanup()
    end
end)

return MainModule
