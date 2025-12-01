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
    AntiFallEnabled = false,
    GlassPlatforms = {},
    SafePlatforms = {}
}

MainModule.JumpRope = {
    AntiFail = false,
    AntiFallEnabled = false,
    NoBalance = false,
    AutoJump = false
}

MainModule.SkySquid = {
    AntiFallEnabled = false,
    VoidKill = false
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
MainModule.ESPUpdateRate = 1.0 -- Увеличил для оптимизации
MainModule.LastESPUpdate = 0

-- Game detection system
MainModule.CurrentGame = nil
MainModule.GameCheckConnection = nil

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
local jumpRopeAntiFailConnection = nil
local glassBridgeESPConnection = nil
local antiStunRagdollConnection = nil
local jumpRopeAntiFallConnection = nil
local skySquidAntiFallConnection = nil
local voidKillConnection = nil
local glassBridgeAntiFallConnection = nil
local noBalanceConnection = nil
local autoJumpConnection = nil

-- Функция проверки текущей игры
function MainModule.CheckCurrentGame()
    local workspaceValues = Workspace:FindFirstChild("Values")
    if not workspaceValues then
        MainModule.CurrentGame = nil
        return nil
    end
    
    local currentGameValue = workspaceValues:FindFirstChild("CurrentGame")
    if currentGameValue then
        MainModule.CurrentGame = currentGameValue.Value
        return currentGameValue.Value
    end
    
    -- Проверка по имени объектов
    if Workspace:FindFirstChild("GlassBridge") then
        MainModule.CurrentGame = "GlassBridge"
    elseif Workspace:FindFirstChild("Effects") and Workspace.Effects:FindFirstChild("rope") then
        MainModule.CurrentGame = "JumpRope"
    elseif Workspace:FindFirstChild("HideAndSeekMap") then
        MainModule.CurrentGame = "HideAndSeek"
    elseif Workspace:FindFirstChild("Dalgona") then
        MainModule.CurrentGame = "Dalgona"
    elseif Workspace:FindFirstChild("RedLightGreenLight") then
        MainModule.CurrentGame = "RedLightGreenLight"
    else
        MainModule.CurrentGame = nil
    end
    
    return MainModule.CurrentGame
end

-- Функция проверки доступности функции
function MainModule.IsGameActive(gameName)
    local currentGame = MainModule.CheckCurrentGame()
    return currentGame == gameName
end

-- Функция отключения функций при завершении игры
function MainModule.DisableFunctionsOnGameEnd()
    local previousGame = MainModule.CurrentGame
    local currentGame = MainModule.CheckCurrentGame()
    
    if previousGame and not currentGame then
        -- Игра завершилась, отключаем все функции этой игры
        if previousGame == "GlassBridge" then
            MainModule.ToggleAntiBreak(false)
            MainModule.ToggleGlassBridgeESP(false)
            MainModule.ToggleGlassBridgeAntiFall(false)
        elseif previousGame == "JumpRope" then
            MainModule.ToggleAntiFailJumpRope(false)
            MainModule.ToggleJumpRopeAntiFall(false)
            MainModule.ToggleNoBalance(false)
            MainModule.ToggleAutoJump(false)
        elseif previousGame == "HideAndSeek" then
            MainModule.ToggleAutoPickup(false)
            MainModule.ToggleSpikesKill(false)
            MainModule.ToggleKillHiders(false)
        elseif previousGame == "Dalgona" then
            -- Dalgona функции одноразовые
        elseif previousGame == "RedLightGreenLight" then
            MainModule.ToggleGodMode(false)
        end
    end
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
        
        -- Оптимизированное обновление ESP (раз в секунду)
        espConnection = RunService.Heartbeat:Connect(function()
            local currentTime = tick()
            if currentTime - MainModule.LastESPUpdate < MainModule.ESPUpdateRate then
                return
            end
            MainModule.LastESPUpdate = currentTime
            
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

-- Rebel функции
function MainModule.ToggleRebel(enabled)
    MainModule.Rebel.Enabled = enabled
end

function MainModule.ToggleRebelInfAmmo(enabled)
    MainModule.Rebel.InfAmmo = enabled
    -- Здесь можно добавить логику Infinite Ammo для Rebel
end

function MainModule.ToggleRebelRapidFire(enabled)
    MainModule.Rebel.RapidFire = enabled
    -- Здесь можно добавить логику Rapid Fire для Rebel
end

-- RLGL функции
function MainModule.TeleportToEndRLGL()
    if not MainModule.IsGameActive("RedLightGreenLight") then
        warn("Red Light Green Light не активна!")
        return
    end
    
    local player = LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-214.4, 1023.1, 146.7)
    end
end

function MainModule.TeleportToStartRLGL()
    if not MainModule.IsGameActive("RedLightGreenLight") then
        warn("Red Light Green Light не активна!")
        return
    end
    
    local player = LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-55.3, 1023.1, -545.8)
    end
end

function MainModule.ToggleGodMode(enabled)
    MainModule.RLGL.GodMode = enabled
    
    if not MainModule.IsGameActive("RedLightGreenLight") then
        warn("Red Light Green Light не активна!")
        MainModule.RLGL.GodMode = false
        return
    end
    
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
                                obj.Value = 0.5
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

-- Hitbox Expander функция (исправленная)
function MainModule.ToggleHitboxExpander(enabled)
    MainModule.Guards.HitboxExpander = enabled
    
    if hitboxConnection then
        hitboxConnection:Disconnect()
        hitboxConnection = nil
    end
    
    -- Восстанавливаем оригинальные размеры
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
                        local root = player.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            -- Сохраняем оригинальные размеры если еще не сохранены
                            if not MainModule.Guards.OriginalHitboxes[player] then
                                MainModule.Guards.OriginalHitboxes[player] = {}
                                MainModule.Guards.OriginalHitboxes[player]["HumanoidRootPart"] = root.Size
                            end
                            
                            -- Увеличиваем размер
                            root.Size = Vector3.new(HITBOX_SIZE, HITBOX_SIZE, HITBOX_SIZE)
                            root.Transparency = 1
                            root.CanCollide = false
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
    if enabled and not MainModule.IsGameActive("HideAndSeek") then
        warn("Hide and Seek не активна!")
        MainModule.HNS.AutoPickup = false
        return
    end
    
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
    if enabled and not MainModule.IsGameActive("HideAndSeek") then
        warn("Hide and Seek не активна!")
        MainModule.HNS.SpikesKill = false
        return
    end
    
    MainModule.HNS.SpikesKill = enabled
    
    if hnsSpikesKillConnection then
        hnsSpikesKillConnection:Disconnect()
        hnsSpikesKillConnection = nil
    end
    
    if enabled then
        -- Сохраняем позиции шипов
        hnsSpikesKillConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.SpikesKill then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                local isHunter = LocalPlayer:GetAttribute("IsHunter")
                if isHunter then
                    local spikes = Workspace:FindFirstChild("HideAndSeekMap") and 
                                  Workspace.HideAndSeekMap:FindFirstChild("KillingParts")
                    
                    if spikes then
                        for _, spike in pairs(spikes:GetChildren()) do
                            if spike:IsA("BasePart") then
                                spike.CanTouch = false
                            end
                        end
                    end
                end
            end)
        end)
    end
end

function MainModule.DisableSpikes()
    if not MainModule.IsGameActive("HideAndSeek") then
        warn("Hide and Seek не активна!")
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
            print("Шипы отключены!")
        end
    end)
end

function MainModule.ToggleKillHiders(enabled)
    if enabled and not MainModule.IsGameActive("HideAndSeek") then
        warn("Hide and Seek не активна!")
        MainModule.HNS.KillHiders = false
        return
    end
    
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
                
                if targetPlayer and targetPlayer.Character and closestDistance < 50 then
                    character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2)
                end
            end)
        end)
    end
end

function MainModule.ToggleAutoDodge(enabled)
    MainModule.HNS.AutoDodge = enabled
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

-- Glass Bridge функции (ИСПРАВЛЕННЫЕ)
function MainModule.ToggleAntiBreak(enabled)
    if enabled and not MainModule.IsGameActive("GlassBridge") then
        warn("Glass Bridge не активна!")
        MainModule.GlassBridge.AntiBreak = false
        return
    end
    
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
                
                -- Создаем безопасные платформы под каждым стеклом
                for _, tilePair in pairs(GlassHolder:GetChildren()) do
                    for _, tileModel in pairs(tilePair:GetChildren()) do
                        if tileModel:IsA("Model") and tileModel.PrimaryPart then
                            local isBreakable = tileModel.PrimaryPart:GetAttribute("exploitingisevil") == true
                            
                            if isBreakable then
                                -- Создаем безопасную платформу под опасным стеклом
                                if not MainModule.GlassBridge.SafePlatforms[tileModel] then
                                    local safePlatform = Instance.new("Part")
                                    safePlatform.Name = "SafePlatform_" .. tileModel.Name
                                    safePlatform.Size = Vector3.new(10, 0.5, 10)
                                    safePlatform.CFrame = tileModel.PrimaryPart.CFrame * CFrame.new(0, -2, 0)
                                    safePlatform.Anchored = true
                                    safePlatform.CanCollide = true
                                    safePlatform.Transparency = 1 -- Невидимая
                                    safePlatform.Parent = tileModel
                                    
                                    MainModule.GlassBridge.SafePlatforms[tileModel] = safePlatform
                                end
                            else
                                -- Удаляем платформу если стекло безопасное
                                if MainModule.GlassBridge.SafePlatforms[tileModel] then
                                    MainModule.GlassBridge.SafePlatforms[tileModel]:Destroy()
                                    MainModule.GlassBridge.SafePlatforms[tileModel] = nil
                                end
                            end
                        end
                    end
                end
            end)
        end)
    else
        -- Удаляем все безопасные платформы
        for _, platform in pairs(MainModule.GlassBridge.SafePlatforms) do
            if platform then
                platform:Destroy()
            end
        end
        MainModule.GlassBridge.SafePlatforms = {}
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

function MainModule.ToggleGlassBridgeAntiFall(enabled)
    if enabled and not MainModule.IsGameActive("GlassBridge") then
        warn("Glass Bridge не активна!")
        MainModule.GlassBridge.AntiFallEnabled = false
        return
    end
    
    MainModule.GlassBridge.AntiFallEnabled = enabled
    
    if glassBridgeAntiFallConnection then
        glassBridgeAntiFallConnection:Disconnect()
        glassBridgeAntiFallConnection = nil
    end
    
    if enabled then
        glassBridgeAntiFallConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.GlassBridge.AntiFallEnabled then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChild("Humanoid")
                
                if not rootPart or not humanoid or humanoid.Health <= 0 then return end
                
                if rootPart.Position.Y < 520 then
                    local targetPlayer = findNearestAlivePlayer()
                    if targetPlayer and targetPlayer.Character then
                        local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if targetRoot then
                            rootPart.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
                        end
                    else
                        -- Телепортируем к концу моста
                        rootPart.CFrame = CFrame.new(-196.372467, 522.192139, -1534.20984)
                    end
                end
            end)
        end)
    end
end

function MainModule.TeleportToGlassBridgeEnd()
    if not MainModule.IsGameActive("GlassBridge") then
        warn("Glass Bridge не активна!")
        return
    end
    
    local player = LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-196.372467, 522.192139, -1534.20984)
    end
end

-- Jump Rope функции
function MainModule.TeleportToJumpRopeEnd()
    if not MainModule.IsGameActive("JumpRope") then
        warn("Jump Rope не активна!")
        return
    end
    
    local player = LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(720.896057, 198.628311, 921.170654)
    end
end

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

function MainModule.ToggleAntiFailJumpRope(enabled)
    if enabled and not MainModule.IsGameActive("JumpRope") then
        warn("Jump Rope не активна!")
        MainModule.JumpRope.AntiFail = false
        return
    end
    
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

function MainModule.ToggleJumpRopeAntiFall(enabled)
    if enabled and not MainModule.IsGameActive("JumpRope") then
        warn("Jump Rope не активна!")
        MainModule.JumpRope.AntiFallEnabled = false
        return
    end
    
    MainModule.JumpRope.AntiFallEnabled = enabled
    
    if jumpRopeAntiFallConnection then
        jumpRopeAntiFallConnection:Disconnect()
        jumpRopeAntiFallConnection = nil
    end
    
    if enabled then
        jumpRopeAntiFallConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.JumpRope.AntiFallEnabled then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChild("Humanoid")
                
                if not rootPart or not humanoid or humanoid.Health <= 0 then return end
                
                if rootPart.Position.Y < 190 then
                    local targetPlayer = findNearestAlivePlayer()
                    if targetPlayer and targetPlayer.Character then
                        local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if targetRoot then
                            rootPart.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
                        end
                    else
                        rootPart.CFrame = CFrame.new(720.896057, 198.628311, 921.170654)
                    end
                end
            end)
        end)
    end
end

function MainModule.ToggleNoBalance(enabled)
    if enabled and not MainModule.IsGameActive("JumpRope") then
        warn("Jump Rope не активна!")
        MainModule.JumpRope.NoBalance = false
        return
    end
    
    MainModule.JumpRope.NoBalance = enabled
    
    if noBalanceConnection then
        noBalanceConnection:Disconnect()
        noBalanceConnection = nil
    end
    
    if enabled then
        noBalanceConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.JumpRope.NoBalance then return end
            
            pcall(function()
                local player = Players.LocalPlayer
                if player:FindFirstChild("PlayingJumpRope") then
                    player.PlayingJumpRope:Destroy()
                end
            end)
        end)
    end
end

function MainModule.ToggleAutoJump(enabled)
    if enabled and not MainModule.IsGameActive("JumpRope") then
        warn("Jump Rope не активна!")
        MainModule.JumpRope.AutoJump = false
        return
    end
    
    MainModule.JumpRope.AutoJump = enabled
    
    if autoJumpConnection then
        autoJumpConnection:Disconnect()
        autoJumpConnection = nil
    end
    
    if enabled then
        autoJumpConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.JumpRope.AutoJump then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local humanoid = character:FindFirstChild("Humanoid")
                if not humanoid then return end
                
                local rope = Workspace:FindFirstChild("Effects") and Workspace.Effects:FindFirstChild("rope")
                if rope and character:FindFirstChild("HumanoidRootPart") then
                    local distance = (character.HumanoidRootPart.Position - rope.Position).Magnitude
                    
                    if distance <= 15 then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                        task.wait(0.1)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                    end
                end
            end)
        end)
    end
end

function MainModule.DeleteRope()
    if not MainModule.IsGameActive("JumpRope") then
        warn("Jump Rope не активна!")
        return
    end
    
    if Workspace:FindFirstChild("Effects") then
        local rope = Workspace.Effects:FindFirstChild("rope")
        if rope then
            rope:Destroy()
        end
    end
end

function MainModule.FreezeRope(enabled)
    if not MainModule.IsGameActive("JumpRope") then
        warn("Jump Rope не активна!")
        return
    end
    
    local rope = Workspace:FindFirstChild("Effects") and Workspace.Effects:FindFirstChild("rope")
    if not rope then return end
    
    if enabled then
        for _, v in ipairs(rope:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Anchored = true
                v.Velocity = Vector3.zero
                v.RotVelocity = Vector3.zero
            elseif v:IsA("Constraint") or v:IsA("RopeConstraint") or v:IsA("Motor6D") then
                v.Enabled = false
            end
        end
    else
        for _, v in ipairs(rope:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Anchored = false
            elseif v:IsA("Constraint") or v:IsA("RopeConstraint") or v:IsA("Motor6D") then
                v.Enabled = true
            end
        end
    end
end

-- Sky Squid функции
function MainModule.ToggleSkySquidAntiFall(enabled)
    MainModule.SkySquid.AntiFallEnabled = enabled
    
    if skySquidAntiFallConnection then
        skySquidAntiFallConnection:Disconnect()
        skySquidAntiFallConnection = nil
    end
    
    if enabled then
        skySquidAntiFallConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.SkySquid.AntiFallEnabled then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChild("Humanoid")
                
                if not rootPart or not humanoid or humanoid.Health <= 0 then return end
                
                if rootPart.Position.Y < 50 then
                    local targetPlayer = findNearestAlivePlayer()
                    if targetPlayer and targetPlayer.Character then
                        local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if targetRoot then
                            rootPart.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
                        end
                    end
                end
            end)
        end)
    end
end

function MainModule.ToggleVoidKill(enabled)
    MainModule.SkySquid.VoidKill = enabled
    
    if voidKillConnection then
        voidKillConnection:Disconnect()
        voidKillConnection = nil
    end
    
    if enabled then
        voidKillConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.SkySquid.VoidKill then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChild("Humanoid")
                
                if not rootPart or not humanoid or humanoid.Health <= 0 then return end
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                        if targetRoot then
                            local distance = (rootPart.Position - targetRoot.Position).Magnitude
                            
                            if distance < 15 then
                                local voidPosition = Vector3.new(0, 10000, 0)
                                player.Character.HumanoidRootPart.CFrame = CFrame.new(voidPosition)
                                
                                local platform = Instance.new("Part")
                                platform.Name = "VoidPlatform"
                                platform.Size = Vector3.new(50, 5, 50)
                                platform.Position = voidPosition - Vector3.new(0, 3, 0)
                                platform.Anchored = true
                                platform.CanCollide = true
                                platform.Transparency = 0.5
                                platform.Material = Enum.Material.Neon
                                platform.BrickColor = BrickColor.new("Bright purple")
                                platform.Parent = workspace
                                
                                delay(10, function()
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

-- Вспомогательные функции
function findNearestAlivePlayer()
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

function delay(seconds, callback)
    task.spawn(function()
        task.wait(seconds)
        callback()
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
        jumpRopeAntiFailConnection, glassBridgeESPConnection, antiStunRagdollConnection,
        jumpRopeAntiFallConnection, skySquidAntiFallConnection, voidKillConnection,
        glassBridgeAntiFallConnection, noBalanceConnection, autoJumpConnection,
        MainModule.GameCheckConnection
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
    
    -- Очищаем безопасные платформы Glass Bridge
    for _, platform in pairs(MainModule.GlassBridge.SafePlatforms) do
        if platform then
            platform:Destroy()
        end
    end
    MainModule.GlassBridge.SafePlatforms = {}
end

-- Запускаем проверку игры
MainModule.GameCheckConnection = RunService.Heartbeat:Connect(function()
    MainModule.DisableFunctionsOnGameEnd()
end)

-- Автоматическая очистка при выходе
game:GetService("Players").LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not game:GetService("Players").LocalPlayer.Parent then
        MainModule.Cleanup()
    end
end)

return MainModule
