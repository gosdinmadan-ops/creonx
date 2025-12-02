-- Main.lua - Creon X v2.1 (Исправленная версия)
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
    DodgeRange = 10,
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
    -- Новые переменные для Auto Dodge
    LastDodgeKeyTime = 0,
    DodgeKeyCooldown = 0.1
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
    ESPCandies = true,
    ESPKeys = true,
    ESPDoors = true,
    ESPEscapeDoors = true,
    ESPGuards = true,
    ESPHighlight = true,
    ESPDistance = true,
    ESPNames = true,
    ESPBoxes = true,
    ESPHealth = true,
    ESPFillTransparency = 0.3,
    ESPOutlineTransparency = 0,
    ESPTextSize = 14,
    AntiStunRagdoll = false,
    -- Новые функции
    UnlockDash = false,
    UnlockPhantomStep = false,
    AntiStun = false,
    AntiRagdoll = false
}

-- ESP System (оптимизированная без лагов)
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
MainModule.GlassBridgeWater = nil

-- Auto Dodge tracking
MainModule.HNSTrackedAttackers = {}
MainModule.KnifeHitbox = nil

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
local hnsKillHidersConnection = nil
local hnsAutoDodgeConnection = nil
local glassBridgeESPConnection = nil
local antiStunRagdollConnection = nil
local skySquidAntiFallConnection = nil
local skySquidVoidKillConnection = nil
local antiRagdollConnection = nil
local removeInjuredConnection = nil
local glassBridgeAntiFallConnection = nil
local jumpRopeAntiFallConnection = nil

-- Локальный игрок
local LocalPlayer = Players.LocalPlayer

-- ОПТИМИЗИРОВАННАЯ ESP System (без лагов, с полным контролем)
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
                    MainModule.ESPCache[key] = nil
                end
                
                -- ESP для игроков
                if MainModule.Misc.ESPPlayers then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local character = player.Character
                            local humanoid = character:FindFirstChildOfClass("Humanoid")
                            local rootPart = character:FindFirstChild("HumanoidRootPart")
                            
                            if humanoid and humanoid.Health > 0 and rootPart then
                                local cacheKey = "player_" .. player.UserId
                                
                                if not MainModule.ESPCache[cacheKey] or tick() - MainModule.ESPCache[cacheKey] > 2 then
                                    -- Создаем или обновляем Highlight
                                    if not MainModule.ESPTable[cacheKey] then
                                        local highlight = Instance.new("Highlight")
                                        highlight.Name = "ESP_" .. player.Name
                                        highlight.Adornee = character
                                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                        
                                        -- Определяем цвет по роли
                                        local isHider = player:GetAttribute("IsHider") or false
                                        local isHunter = player:GetAttribute("IsHunter") or false
                                        
                                        if isHider then
                                            highlight.FillColor = Color3.fromRGB(0, 255, 0) -- Зеленый для хайдеров
                                        elseif isHunter then
                                            highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Красный для сикеров
                                        else
                                            highlight.FillColor = Color3.fromRGB(0, 170, 255) -- Синий для остальных
                                        end
                                        
                                        highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
                                        highlight.OutlineColor = highlight.FillColor
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
                                    
                                    -- Создаем billboard с информацией
                                    if MainModule.Misc.ESPNames and not MainModule.ESPTable[cacheKey .. "_text"] then
                                        local billboard = Instance.new("BillboardGui")
                                        billboard.Name = "ESP_Text_" .. player.Name
                                        billboard.Adornee = rootPart
                                        billboard.AlwaysOnTop = true
                                        billboard.Size = UDim2.new(0, 200, 0, 50)
                                        billboard.StudsOffset = Vector3.new(0, 4, 0)
                                        billboard.MaxDistance = 1000
                                        billboard.Parent = MainModule.ESPFolder
                                        
                                        local textLabel = Instance.new("TextLabel")
                                        textLabel.Name = "ESP_Label"
                                        textLabel.BackgroundTransparency = 1
                                        textLabel.Size = UDim2.new(1, 0, 0.5, 0)
                                        textLabel.Text = player.DisplayName
                                        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                                        textLabel.TextSize = MainModule.Misc.ESPTextSize
                                        textLabel.Font = Enum.Font.GothamBold
                                        textLabel.TextStrokeTransparency = 0
                                        textLabel.Parent = billboard
                                        
                                        local distanceLabel = Instance.new("TextLabel")
                                        distanceLabel.Name = "ESP_Distance"
                                        distanceLabel.BackgroundTransparency = 1
                                        distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
                                        distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
                                        distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                                        distanceLabel.TextSize = MainModule.Misc.ESPTextSize - 2
                                        distanceLabel.Font = Enum.Font.Gotham
                                        distanceLabel.TextStrokeTransparency = 0
                                        distanceLabel.Parent = billboard
                                        
                                        MainModule.ESPTable[cacheKey .. "_text"] = {
                                            Billboard = billboard,
                                            Destroy = function()
                                                if billboard then billboard:Destroy() end
                                            end
                                        }
                                    end
                                    
                                    -- Обновляем информацию
                                    if MainModule.ESPTable[cacheKey .. "_text"] then
                                        local billboard = MainModule.ESPTable[cacheKey .. "_text"].Billboard
                                        if billboard and billboard:FindFirstChild("ESP_Distance") then
                                            local ourRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                            if ourRoot then
                                                local distance = math.floor((rootPart.Position - ourRoot.Position).Magnitude)
                                                billboard.ESP_Distance.Text = MainModule.Misc.ESPDistance and (distance .. "m") or ""
                                                
                                                -- Показываем здоровье если включено
                                                if MainModule.Misc.ESPHealth and humanoid then
                                                    local healthText = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                                                    billboard.ESP_Label.Text = player.DisplayName .. " (" .. healthText .. " HP)"
                                                else
                                                    billboard.ESP_Label.Text = player.DisplayName
                                                end
                                            end
                                        end
                                    end
                                    
                                    -- Добавляем Box ESP если включено
                                    if MainModule.Misc.ESPBoxes and not MainModule.ESPTable[cacheKey .. "_box"] then
                                        local box = Instance.new("BoxHandleAdornment")
                                        box.Name = "ESP_Box_" .. player.Name
                                        box.Adornee = rootPart
                                        box.AlwaysOnTop = true
                                        box.Size = Vector3.new(4, 6, 2)
                                        box.Color3 = Color3.fromRGB(255, 255, 255)
                                        box.Transparency = 0.5
                                        box.ZIndex = 2
                                        box.Parent = MainModule.ESPFolder
                                        
                                        MainModule.ESPTable[cacheKey .. "_box"] = {
                                            Box = box,
                                            Destroy = function()
                                                if box then box:Destroy() end
                                            end
                                        }
                                    end
                                    
                                    MainModule.ESPCache[cacheKey] = tick()
                                end
                            end
                        end
                    end
                end
                
                -- ESP для конфет (Candies)
                if MainModule.Misc.ESPCandies then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and (obj.Name:lower():find("candy") or obj.Name:lower():find("конфет") or obj.Name:lower():find("sweet")) then
                            local cacheKey = "candy_" .. HttpService:GenerateGUID(false)
                            local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                            
                            if primaryPart and not MainModule.ESPCache[cacheKey] then
                                local highlight = Instance.new("Highlight")
                                highlight.Name = "ESP_Candy"
                                highlight.Adornee = obj
                                highlight.FillColor = Color3.fromRGB(255, 105, 180) -- Розовый для конфет
                                highlight.FillTransparency = 0.2
                                highlight.OutlineColor = Color3.fromRGB(255, 105, 180)
                                highlight.OutlineTransparency = 0
                                highlight.Enabled = true
                                highlight.Parent = MainModule.ESPFolder
                                
                                MainModule.ESPTable[cacheKey] = {
                                    Highlight = highlight,
                                    Destroy = function()
                                        if highlight then highlight:Destroy() end
                                    end
                                }
                                
                                MainModule.ESPCache[cacheKey] = tick()
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
                            
                            if primaryPart and not MainModule.ESPCache[cacheKey] then
                                local highlight = Instance.new("Highlight")
                                highlight.Name = "ESP_Key"
                                highlight.Adornee = obj
                                highlight.FillColor = Color3.fromRGB(255, 215, 0) -- Золотой для ключей
                                highlight.FillTransparency = 0.2
                                highlight.OutlineColor = Color3.fromRGB(255, 215, 0)
                                highlight.OutlineTransparency = 0
                                highlight.Enabled = true
                                highlight.Parent = MainModule.ESPFolder
                                
                                MainModule.ESPTable[cacheKey] = {
                                    Highlight = highlight,
                                    Destroy = function()
                                        if highlight then highlight:Destroy() end
                                    end
                                }
                                
                                MainModule.ESPCache[cacheKey] = tick()
                            end
                        end
                    end
                end
                
                -- ESP для гуардов
                if MainModule.Misc.ESPGuards then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and (obj.Name:lower():find("guard") or obj.Name:lower():find("гуард") or 
                           obj.Name:lower():find("circle") or obj.Name:lower():find("triangle") or obj.Name:lower():find("square")) then
                            local cacheKey = "guard_" .. HttpService:GenerateGUID(false)
                            local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                            
                            if primaryPart and not MainModule.ESPCache[cacheKey] then
                                local highlight = Instance.new("Highlight")
                                highlight.Name = "ESP_Guard"
                                highlight.Adornee = obj
                                highlight.FillColor = Color3.fromRGB(255, 69, 0) -- Оранжево-красный для гуардов
                                highlight.FillTransparency = 0.3
                                highlight.OutlineColor = Color3.fromRGB(255, 69, 0)
                                highlight.OutlineTransparency = 0
                                highlight.Enabled = true
                                highlight.Parent = MainModule.ESPFolder
                                
                                MainModule.ESPTable[cacheKey] = {
                                    Highlight = highlight,
                                    Destroy = function()
                                        if highlight then highlight:Destroy() end
                                    end
                                }
                                
                                MainModule.ESPCache[cacheKey] = tick()
                            end
                        end
                    end
                end
                
                -- ESP для дверей
                if MainModule.Misc.ESPDoors then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and (obj.Name:lower():find("door") or obj.Name:lower():find("дверь")) then
                            local cacheKey = "door_" .. HttpService:GenerateGUID(false)
                            local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                            
                            if primaryPart and not MainModule.ESPCache[cacheKey] then
                                local highlight = Instance.new("Highlight")
                                highlight.Name = "ESP_Door"
                                highlight.Adornee = obj
                                highlight.FillColor = Color3.fromRGB(147, 112, 219) -- Фиолетовый для дверей
                                highlight.FillTransparency = 0.4
                                highlight.OutlineColor = Color3.fromRGB(147, 112, 219)
                                highlight.OutlineTransparency = 0
                                highlight.Enabled = true
                                highlight.Parent = MainModule.ESPFolder
                                
                                MainModule.ESPTable[cacheKey] = {
                                    Highlight = highlight,
                                    Destroy = function()
                                        if highlight then highlight:Destroy() end
                                    end
                                }
                                
                                MainModule.ESPCache[cacheKey] = tick()
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

-- Функция для обновления конкретных настроек ESP
function MainModule.UpdateESPSetting(setting, value)
    MainModule.Misc[setting] = value
    
    if MainModule.Misc.ESPEnabled then
        -- Перезапускаем ESP для применения изменений
        MainModule.ToggleESP(false)
        task.wait(0.1)
        MainModule.ToggleESP(true)
    end
end

-- Jump Rope функции
function MainModule.TeleportToJumpRopeEnd()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(737.156372, 193.805084, 920.952515)
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

-- HNS функции (исправленные)
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
                    end
                end
            end
        end)
    end
end

function MainModule.ToggleDisableSpikes(enabled)
    MainModule.HNS.DisableSpikes = enabled
    
    -- Одноразовая функция
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

function MainModule.ToggleKillHiders(enabled)
    MainModule.HNS.KillHiders = enabled
    
    if hnsKillHidersConnection then
        hnsKillHidersConnection:Disconnect()
        hnsKillHidersConnection = nil
    end
    
    if enabled then
        hnsKillHidersConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.KillHiders then return end
            
            local currentTime = tick()
            if currentTime - MainModule.HNS.LastKillTime < MainModule.HNS.KillCooldown then return end
            
            local character = LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
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
            
            -- Также проверяем Backpack
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
                        
                        if distance < nearestDistance and distance < 100 then
                            nearestDistance = distance
                            nearestHider = player
                            targetRootPart = targetRoot
                        end
                    end
                end
            end
            
            -- Если нашли живого прячущегося в радиусе 100
            if nearestHider and targetRootPart and nearestDistance < 100 then
                MainModule.HNS.CurrentKillTarget = nearestHider
                
                -- Телепортируемся за спину
                if nearestDistance > 2 then
                    local teleportCFrame = targetRootPart.CFrame * CFrame.new(0, 0, -2)
                    rootPart.CFrame = teleportCFrame
                end
                
                -- Атакуем ножом
                if knifeTool then
                    local remoteEvent = knifeTool:FindFirstChild("RemoteEvent")
                    if remoteEvent then
                        pcall(function()
                            remoteEvent:FireServer()
                        end)
                    end
                    
                    -- Также кликаем мышью
                    pcall(function()
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        task.wait(0.05)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    end)
                end
                
                MainModule.HNS.LastKillTime = tick()
                
                -- Проверяем умер ли таргет, если умер - сбрасываем
                if not nearestHider.Character or not nearestHider.Character:FindFirstChildOfClass("Humanoid") or 
                   nearestHider.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
                    MainModule.HNS.CurrentKillTarget = nil
                end
            end
        end)
    else
        MainModule.HNS.CurrentKillTarget = nil
    end
end

-- Glass Bridge функции (исправленные)
function MainModule.ToggleAntiBreak(enabled)
    MainModule.GlassBridge.AntiBreak = enabled
    
    if antiBreakConnection then
        antiBreakConnection:Disconnect()
        antiBreakConnection = nil
    end
    
    if glassBridgeAntiFallConnection then
        glassBridgeAntiFallConnection:Disconnect()
        glassBridgeAntiFallConnection = nil
    end
    
    -- Удаляем старую воду/синий цвет
    if MainModule.GlassBridgeWater then
        MainModule.GlassBridgeWater:Destroy()
        MainModule.GlassBridgeWater = nil
    end
    
    if enabled then
        -- Создаем полностью прозрачный Anti Fall
        MainModule.CreateGlassBridgeAntiFall()
        
        -- Включаем ESP для стекол если он не включен
        if not MainModule.GlassBridge.GlassESPEnabled then
            MainModule.ToggleGlassBridgeESP(true)
        end
        
        antiBreakConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.GlassBridge.AntiBreak then return end
            
            pcall(function()
                local GlassHolder = Workspace:FindFirstChild("GlassBridge") and Workspace.GlassBridge:FindFirstChild("GlassHolder")
                if not GlassHolder then return end
                
                for _, v in pairs(GlassHolder:GetChildren()) do
                    for _, j in pairs(v:GetChildren()) do
                        if j:IsA("Model") and j.PrimaryPart then
                            -- Удаляем атрибут, который делает стекло ломающимся
                            j.PrimaryPart:SetAttribute("exploitingisevil", nil)
                            
                            -- Делаем все стекла неломающимися
                            for _, part in pairs(j:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = true
                                    part.Anchored = true
                                    part.Transparency = 0.5
                                    part.Material = Enum.Material.Glass
                                    part.Color = Color3.fromRGB(0, 255, 0) -- Зеленый для безопасных стекол
                                end
                            end
                        end
                    end
                end
            end)
        end)
    else
        -- Удаляем Anti Fall платформу
        MainModule.RemoveGlassBridgeAntiFall()
        
        -- Восстанавливаем нормальный вид стекол
        pcall(function()
            local GlassHolder = Workspace:FindFirstChild("GlassBridge") and Workspace.GlassBridge:FindFirstChild("GlassHolder")
            if not GlassHolder then return end
            
            for _, v in pairs(GlassHolder:GetChildren()) do
                for _, j in pairs(v:GetChildren()) do
                    if j:IsA("Model") and j.PrimaryPart then
                        for _, part in pairs(j:GetDescendants()) do
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

function MainModule.CreateGlassBridgeAntiFall()
    if MainModule.GlassBridge.AntiFallPlatform then
        MainModule.GlassBridge.AntiFallPlatform:Destroy()
        MainModule.GlassBridge.AntiFallPlatform = nil
    end
    
    -- Создаем полностью прозрачную Anti-Fall платформу для Glass Bridge
    MainModule.GlassBridge.AntiFallPlatform = Instance.new("Part")
    MainModule.GlassBridge.AntiFallPlatform.Name = "GlassBridgeAntiFallPlatform"
    MainModule.GlassBridge.AntiFallPlatform.Size = Vector3.new(500, 1, 150)
    MainModule.GlassBridge.AntiFallPlatform.Position = Vector3.new(-200, 510, -1534)
    MainModule.GlassBridge.AntiFallPlatform.Anchored = true
    MainModule.GlassBridge.AntiFallPlatform.CanCollide = true
    MainModule.GlassBridge.AntiFallPlatform.Transparency = 1 -- Полностью прозрачный
    MainModule.GlassBridge.AntiFallPlatform.Material = Enum.Material.Plastic
    MainModule.GlassBridge.AntiFallPlatform.Color = Color3.fromRGB(255, 255, 255)
    MainModule.GlassBridge.AntiFallPlatform.Parent = Workspace
    
    -- Постоянная проверка, чтобы игрок не упал
    glassBridgeAntiFallConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.GlassBridge.AntiBreak then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        -- Если игрок ниже уровня платформы, телепортируем его на нее
        if rootPart.Position.Y < 515 then
            rootPart.CFrame = CFrame.new(rootPart.Position.X, 525, rootPart.Position.Z)
        end
    end)
end

function MainModule.RemoveGlassBridgeAntiFall()
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
        glassBridgeESPConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.GlassBridge.GlassESPEnabled then return end
            
            pcall(function()
                local glassHolder = Workspace:FindFirstChild("GlassBridge") and Workspace.GlassBridge:FindFirstChild("GlassHolder")
                if not glassHolder then return end

                for _, tilePair in pairs(glassHolder:GetChildren()) do
                    for _, tileModel in pairs(tilePair:GetChildren()) do
                        if tileModel:IsA("Model") and tileModel.PrimaryPart then
                            -- Определяем цвет в зависимости от того, является ли стекло ломающимся
                            -- Только если AntiBreak не включен
                            local targetColor = nil
                            
                            if MainModule.GlassBridge.AntiBreak then
                                -- При включенном AntiBreak все стекла зеленые (безопасные)
                                targetColor = Color3.fromRGB(0, 255, 0)
                            else
                                -- При выключенном AntiBreak показываем реальное состояние
                                local isBreakable = tileModel.PrimaryPart:GetAttribute("exploitingisevil") == true
                                targetColor = isBreakable and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                            end

                            for _, part in pairs(tileModel:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.Color = targetColor
                                    part.Transparency = 0.3
                                    part.Material = Enum.Material.Neon
                                end
                            end
                        end
                    end
                end
            end)
        end)
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

-- Sky Squid функции
function MainModule.ToggleSkySquidAntiFall(enabled)
    MainModule.SkySquid.AntiFall = enabled
    
    if skySquidAntiFallConnection then
        skySquidAntiFallConnection:Disconnect()
        skySquidAntiFallConnection = nil
    end
    
    if enabled then
        -- Создаем Anti-Fall платформу для Sky Squid
        if MainModule.SkySquid.AntiFallPlatform then
            MainModule.SkySquid.AntiFallPlatform:Destroy()
        end
        
        MainModule.SkySquid.AntiFallPlatform = Instance.new("Part")
        MainModule.SkySquid.AntiFallPlatform.Name = "SkySquidAntiFallPlatform"
        MainModule.SkySquid.AntiFallPlatform.Size = Vector3.new(500, 1, 500)
        MainModule.SkySquid.AntiFallPlatform.Position = Vector3.new(0, 90, 0)
        MainModule.SkySquid.AntiFallPlatform.Anchored = true
        MainModule.SkySquid.AntiFallPlatform.CanCollide = true
        MainModule.SkySquid.AntiFallPlatform.Transparency = 1
        MainModule.SkySquid.AntiFallPlatform.Parent = Workspace
        
        skySquidAntiFallConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.SkySquid.AntiFall then return end
            
            local character = LocalPlayer.Character
            if not character then return end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart then return end
            
            -- Если упали ниже высоты 50
            if rootPart.Position.Y < 50 then
                rootPart.CFrame = CFrame.new(0, 200, 0)
            end
        end)
    else
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
        -- Создаем Safe Platform
        if MainModule.SkySquid.SafePlatform then
            MainModule.SkySquid.SafePlatform:Destroy()
        end
        
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
        
        skySquidVoidKillConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.SkySquid.VoidKill then return end
            
            local character = LocalPlayer.Character
            if not character then return end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart then return end
            
            -- Телепортируем других игроков в бездну
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        local distance = (rootPart.Position - targetRoot.Position).Magnitude
                        
                        if distance < 15 then
                            targetRoot.CFrame = CFrame.new(0, -10000, 0)
                        end
                    end
                end
            end
        end)
    else
        if MainModule.SkySquid.SafePlatform then
            MainModule.SkySquid.SafePlatform:Destroy()
            MainModule.SkySquid.SafePlatform = nil
        end
    end
end

-- HNS Auto Dodge функция (исправленная)
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
            if currentTime - MainModule.HNS.LastDodgeTime < MainModule.HNS.DodgeCooldown then
                return
            end
            
            local character = LocalPlayer.Character
            if not character then return end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            
            if not rootPart or not humanoid or humanoid.Health <= 0 then return end
            
            -- Ищем хитбоксы ножей вокруг нас
            local shouldDodge = false
            
            -- Проверяем хитбоксы в workspace
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.Name:lower():find("hit") or obj.Name:lower():find("damage") or obj.Name:lower():find("knife")) then
                    local distance = (rootPart.Position - obj.Position).Magnitude
                    
                    -- Если хитбокс рядом с нами (range 10)
                    if distance < MainModule.HNS.DodgeRange then
                        -- Проверяем, принадлежит ли хитбокс ножу
                        local parent = obj.Parent
                        while parent do
                            if parent:IsA("Tool") and (parent.Name:lower():find("knife") or parent.Name:lower():find("dagger") or parent.Name:lower():find("fork")) then
                                shouldDodge = true
                                break
                            end
                            parent = parent.Parent
                        end
                        
                        if shouldDodge then break end
                    end
                end
            end
            
            -- Если нашли хитбокс ножа рядом
            if shouldDodge then
                -- Нажимаем клавишу 1 для уклонения
                pcall(function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)
                end)
                
                MainModule.HNS.LastDodgeTime = tick()
                
                -- Визуальный эффект
                task.spawn(function()
                    local effect = Instance.new("Part")
                    effect.Size = Vector3.new(5, 5, 5)
                    effect.Position = rootPart.Position
                    effect.Material = Enum.Material.Neon
                    effect.Color = Color3.fromRGB(0, 255, 255)
                    effect.Anchored = true
                    effect.CanCollide = false
                    effect.Shape = Enum.PartType.Ball
                    effect.Transparency = 0.5
                    effect.Parent = Workspace
                    
                    TweenService:Create(effect, TweenInfo.new(0.5), {Size = Vector3.new(15, 15, 15), Transparency = 1}):Play()
                    
                    game:GetService("Debris"):AddItem(effect, 1)
                end)
            end
        end)
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
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                MainModule.SpeedHack.DefaultSpeed = humanoid.WalkSpeed
            end
        end
        
        speedConnection = RunService.Heartbeat:Connect(function()
            local character = LocalPlayer.Character
            if character and MainModule.SpeedHack.Enabled then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = MainModule.SpeedHack.CurrentSpeed
                end
            end
        end)
    else
        local character = LocalPlayer.Character
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
        local character = LocalPlayer.Character
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
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame + Vector3.new(0, 100, 0)
    end
end

function MainModule.TeleportDown40()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame + Vector3.new(0, -40, 0)
    end
end

-- Anti Stun функция (отдельная)
function MainModule.ToggleAntiStun(enabled)
    MainModule.Misc.AntiStun = enabled
    
    if antiStunConnection then
        antiStunConnection:Disconnect()
        antiStunConnection = nil
    end
    
    if enabled then
        antiStunConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.Misc.AntiStun then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if not humanoid then return end
                
                -- Удаляем эффекты стана и ранений
                for _, obj in pairs(character:GetDescendants()) do
                    if obj.Name:lower():find("stun") or obj.Name:lower():find("injured") or 
                       obj.Name:lower():find("slow") or obj.Name:lower():find("freeze") then
                        obj:Destroy()
                    end
                end
                
                -- Восстанавливаем из состояния стана
                if humanoid:GetState() == Enum.HumanoidStateType.Stunned then
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                end
                
                -- Восстанавливаем скорость ходьбы
                if humanoid.WalkSpeed < 16 then
                    humanoid.WalkSpeed = 16
                end
            end)
        end)
    end
end

-- Anti Ragdoll функция (отдельная, без лагов)
function MainModule.ToggleAntiRagdoll(enabled)
    MainModule.Misc.AntiRagdoll = enabled
    
    if antiRagdollConnection then
        antiRagdollConnection:Disconnect()
        antiRagdollConnection = nil
    end
    
    if enabled then
        antiRagdollConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.Misc.AntiRagdoll then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if not humanoid then return end
                
                -- Восстанавливаем из рагдолла
                if humanoid:GetState() == Enum.HumanoidStateType.Ragdoll or 
                   humanoid:GetState() == Enum.HumanoidStateType.FallingDown then
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    
                    -- Включаем все моторы
                    for _, motor in pairs(character:GetDescendants()) do
                        if motor:IsA("Motor6D") and not motor.Enabled then
                            motor.Enabled = true
                        end
                    end
                end
            end)
        end)
    end
end

-- Убрать функцию Anti Stun + Ragdoll вместе
function MainModule.ToggleAntiStunRagdoll(enabled)
    MainModule.Misc.AntiStunRagdoll = false -- Отключаем старую функцию
    print("Anti Stun+Ragdoll заменен на отдельные функции Anti Stun и Anti Ragdoll")
end

-- Rebel функция
function MainModule.ToggleRebel(enabled)
    MainModule.Rebel.Enabled = enabled
end

-- RLGL функции
function MainModule.TeleportToEnd()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(-214.4, 1023.1, 146.7)
    end
end

function MainModule.TeleportToStart()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(-55.3, 1023.1, -545.8)
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

-- Guards функции (исправленные)
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
            end)
        end)
    else
        -- Восстанавливаем исходные значения
        pcall(function()
            for obj, originalValue in pairs(MainModule.Guards.OriginalFireRates) do
                if obj and obj.Parent then
                    obj.Value = originalValue
                end
            end
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
            
            local character = LocalPlayer.Character
            if character then
                for _, tool in pairs(character:GetChildren()) do
                    if tool:IsA("Tool") then
                        for _, obj in pairs(tool:GetDescendants()) do
                            if obj:IsA("NumberValue") then
                                if obj.Name:lower():find("ammo") or 
                                   obj.Name:lower():find("bullet") or
                                   obj.Name:lower():find("clip") then
                                    -- Сохраняем оригинальное значение
                                    if not MainModule.Guards.OriginalAmmo[obj] then
                                        MainModule.Guards.OriginalAmmo[obj] = obj.Value
                                    end
                                    -- Устанавливаем максимальное значение
                                    obj.Value = 9999
                                end
                            end
                        end
                    end
                end
            end
        end)
    else
        -- Восстанавливаем оригинальные значения
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

-- Hitbox Expander функция (исправленная, без лагов)
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
    end
    
    MainModule.Guards.OriginalHitboxes = {}
    
    if enabled then
        -- Используем более редкое обновление для оптимизации
        hitboxConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.Guards.HitboxExpander then return end
            
            pcall(function()
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local character = player.Character
                        
                        -- Сохраняем оригинальные размеры если еще не сохранены
                        if not MainModule.Guards.OriginalHitboxes[player] then
                            MainModule.Guards.OriginalHitboxes[player] = {}
                            
                            -- Сохраняем размеры только основных частей
                            local bodyParts = {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"}
                            for _, partName in pairs(bodyParts) do
                                local part = character:FindFirstChild(partName)
                                if part and part:IsA("BasePart") then
                                    MainModule.Guards.OriginalHitboxes[player][partName] = part.Size
                                end
                            end
                        end
                        
                        -- Увеличиваем размеры основных частей (без влияния на движение)
                        local bodyParts = {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"}
                        for _, partName in pairs(bodyParts) do
                            local part = character:FindFirstChild(partName)
                            if part and part:IsA("BasePart") then
                                -- Увеличиваем размер для хитбокса
                                local newSize = Vector3.new(10, 10, 10)
                                part.Size = newSize
                                part.Transparency = 1
                                part.CanCollide = false -- Отключаем коллизию чтобы не мешать движению
                            end
                        end
                    end
                end
            end)
        end)
    else
        -- Восстанавливаем оригинальные размеры при выключении
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
            if v:IsA("ProximityPrompt") then
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

-- Unlock Dash функция (пока не работает)
function MainModule.ToggleUnlockDash(enabled)
    MainModule.Misc.UnlockDash = enabled
    if enabled then
        print("Unlock Dash: Don't work yet")
    end
end

-- Unlock Phantom Step функция (пока не работает)
function MainModule.ToggleUnlockPhantomStep(enabled)
    MainModule.Misc.UnlockPhantomStep = enabled
    if enabled then
        print("Unlock Phantom Step: Don't work yet")
    end
end

-- Jump Rope Anti Fall функция
function MainModule.ToggleJumpRopeAntiFall(enabled)
    if jumpRopeAntiFallConnection then
        jumpRopeAntiFallConnection:Disconnect()
        jumpRopeAntiFallConnection = nil
    end
    
    if enabled then
        -- Создаем Anti Fall для Jump Rope
        local platform = Instance.new("Part")
        platform.Name = "JumpRopeAntiFallPlatform"
        platform.Size = Vector3.new(200, 1, 200)
        platform.Position = Vector3.new(737.156372, 185, 920.952515)
        platform.Anchored = true
        platform.CanCollide = true
        platform.Transparency = 1
        platform.Parent = Workspace
        
        jumpRopeAntiFallConnection = RunService.Heartbeat:Connect(function()
            local character = LocalPlayer.Character
            if not character then return end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart then return end
            
            -- Если упали ниже определенной высоты
            if rootPart.Position.Y < 180 then
                rootPart.CFrame = CFrame.new(737.156372, 195, 920.952515)
            end
        end)
    else
        -- Удаляем платформу
        local platform = Workspace:FindFirstChild("JumpRopeAntiFallPlatform")
        if platform then
            platform:Destroy()
        end
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
        hitboxConnection, autoPullConnection, antiBreakConnection, MainModule.ESPConnection,
        hnsSpikesKillConnection, hnsKillHidersConnection, hnsAutoDodgeConnection,
        glassBridgeESPConnection, antiStunRagdollConnection, skySquidAntiFallConnection,
        skySquidVoidKillConnection, antiRagdollConnection, removeInjuredConnection,
        glassBridgeAntiFallConnection, jumpRopeAntiFallConnection
    }
    
    for _, conn in pairs(connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    
    -- Очищаем Auto Dodge tracking
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
    
    -- Восстанавливаем патроны
    if MainModule.Guards.OriginalAmmo then
        for obj, originalValue in pairs(MainModule.Guards.OriginalAmmo) do
            if obj and obj.Parent then
                obj.Value = originalValue
            end
        end
        MainModule.Guards.OriginalAmmo = {}
    end
    
    -- Восстанавливаем скорострельность
    if MainModule.Guards.OriginalFireRates then
        for obj, originalValue in pairs(MainModule.Guards.OriginalFireRates) do
            if obj and obj.Parent then
                obj.Value = originalValue
            end
        end
        MainModule.Guards.OriginalFireRates = {}
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
    MainModule.RemoveGlassBridgeAntiFall()
    
    -- Удаляем Sky Squid объекты
    if MainModule.SkySquid.AntiFallPlatform then
        MainModule.SkySquid.AntiFallPlatform:Destroy()
        MainModule.SkySquid.AntiFallPlatform = nil
    end
    
    if MainModule.SkySquid.SafePlatform then
        MainModule.SkySquid.SafePlatform:Destroy()
        MainModule.SkySquid.SafePlatform = nil
    end
    
    -- Удаляем Jump Rope Anti Fall
    if jumpRopeAntiFallConnection then
        jumpRopeAntiFallConnection:Disconnect()
    end
    local jrPlatform = Workspace:FindFirstChild("JumpRopeAntiFallPlatform")
    if jrPlatform then
        jrPlatform:Destroy()
    end
    
    -- Восстанавливаем шипы
    if MainModule.HNS.DisableSpikes then
        MainModule.ToggleDisableSpikes(false)
    end
    
    -- Сбрасываем HNS состояния
    MainModule.HNS.CurrentSpikeKillTarget = nil
    MainModule.HNS.IsInSpikeKillProcess = false
    MainModule.HNS.OriginalSpikeKillPosition = nil
    MainModule.HNS.CurrentKillTarget = nil
end

-- Автоматическая очистка при выходе
LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not LocalPlayer.Parent then
        MainModule.Cleanup()
    end
end)

return MainModule
