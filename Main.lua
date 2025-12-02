-- Main.lua - Creon X v2.1 (исправленная версия)
local MainModule = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

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

-- Отдельные настройки для Anti Stun и Anti Ragdoll
MainModule.AntiStun = {
    Enabled = false,
    RemoveInjured = true,
    RemoveStun = true,
    RemoveSlow = true,
    ImmuneToDebuffs = true
}

MainModule.AntiRagdoll = {
    Enabled = false,
    PreventFalling = true,
    KeepUpright = true,
    ForceStand = true
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
    OriginalHitboxes = {},
    HitboxSize = 1000
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
    KillCooldown = 0.3
}

MainModule.TugOfWar = {
    AutoPull = false
}

MainModule.GlassBridge = {
    AntiBreak = false,
    GlassESPEnabled = false,
    GlassPlatform = false,
    FakeGlassCover = false,
    AntiFallPlatform = nil,
    WaterRemoved = false
}

MainModule.JumpRope = {
    TeleportToEnd = false,
    DeleteRope = false,
    AntiFall = false,
    AntiFallPlatform = nil
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
    UnlockDash = false,
    UnlockPhantomStep = false,
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
    ESPSnow = true,
    ESPHP = true,
    ESPFillTransparency = 0.3,
    ESPOutlineTransparency = 0,
    ESPTextSize = 18
}

-- ESP System (полностью оптимизированная без лагов)
MainModule.ESPTable = {}
MainModule.ESPFolder = nil
MainModule.ESPUpdateRate = 0.5
MainModule.LastESPUpdate = 0
MainModule.ESPConnection = nil
MainModule.ESPCache = {}

-- Постоянные соединения
local speedConnection = nil
local autoFarmConnection = nil
local godModeConnection = nil
local instaInteractConnection = nil
local noCooldownConnection = nil
local antiStunConnection = nil
local antiRagdollConnection = nil
local antiStunEffectsConnection = nil
local rapidFireConnection = nil
local infiniteAmmoConnection = nil
local hitboxConnection = nil
local autoPullConnection = nil
local antiBreakConnection = nil
local glassBridgeESPConnection = nil
local hnsSpikesKillConnection = nil
local hnsKillHidersConnection = nil
local jumpRopeAntiFallConnection = nil

-- Локальный игрок
local LocalPlayer = Players.LocalPlayer

-- Оптимизированная функция удаления воды и синих эффектов
local function RemoveWaterAndBlueEffects()
    pcall(function()
        -- Удаляем воду из Glass Bridge
        local glassBridge = Workspace:FindFirstChild("GlassBridge")
        if glassBridge then
            for _, obj in pairs(glassBridge:GetDescendants()) do
                if obj:IsA("BasePart") then
                    -- Убираем синий цвет
                    if obj.Color == Color3.fromRGB(0, 0, 255) or 
                       obj.Color == Color3.fromRGB(0, 170, 255) then
                        obj.Color = Color3.fromRGB(163, 162, 165)
                    end
                    
                    -- Убираем прозрачность воды
                    if obj.Transparency > 0.5 and obj.Material == Enum.Material.Water then
                        obj.Transparency = 0
                        obj.Material = Enum.Material.Glass
                    end
                end
                
                -- Удаляем водяные эффекты
                if obj.Name:lower():find("water") or 
                   obj.Name:lower():find("waterfall") or
                   obj.Name:lower():find("flow") then
                    obj:Destroy()
                end
            end
        end
        
        -- Удаляем эффекты из Workspace
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") and 
               (obj.Name:lower():find("water") or obj.Name:lower():find("spray")) then
                obj:Destroy()
            end
        end
    end)
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
                
                local localCharacter = LocalPlayer.Character
                local localRootPart = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
                
                -- ESP для игроков
                if MainModule.Misc.ESPPlayers then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local character = player.Character
                            local humanoid = character:FindFirstChildOfClass("Humanoid")
                            if humanoid and humanoid.Health > 0 then
                                local cacheKey = "player_" .. player.UserId
                                local rootPart = character:FindFirstChild("HumanoidRootPart")
                                
                                if rootPart then
                                    if not MainModule.ESPCache[cacheKey] or tick() - MainModule.ESPCache[cacheKey] > 2 then
                                        -- Создаем Highlight
                                        local highlight = MainModule.ESPTable[cacheKey .. "_highlight"]
                                        if not highlight then
                                            highlight = Instance.new("Highlight")
                                            highlight.Name = "ESP_" .. player.Name
                                            highlight.Adornee = character
                                            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                            highlight.FillColor = Color3.fromRGB(0, 170, 255)
                                            highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
                                            highlight.OutlineColor = Color3.fromRGB(0, 170, 255)
                                            highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
                                            highlight.Enabled = MainModule.Misc.ESPHighlight
                                            highlight.Parent = MainModule.ESPFolder
                                            
                                            MainModule.ESPTable[cacheKey .. "_highlight"] = {
                                                Highlight = highlight,
                                                Destroy = function()
                                                    if highlight then highlight:Destroy() end
                                                end
                                            }
                                        end
                                        
                                        -- Добавляем billboard с информацией
                                        if MainModule.Misc.ESPNames then
                                            local billboard = MainModule.ESPTable[cacheKey .. "_text"]
                                            if not billboard then
                                                billboard = Instance.new("BillboardGui")
                                                billboard.Name = "ESP_Text_" .. player.Name
                                                billboard.Adornee = rootPart
                                                billboard.AlwaysOnTop = true
                                                billboard.Size = UDim2.new(0, 200, 0, 50)
                                                billboard.StudsOffset = Vector3.new(0, 3, 0)
                                                billboard.Parent = MainModule.ESPFolder
                                                
                                                MainModule.ESPTable[cacheKey .. "_text"] = billboard
                                            end
                                            
                                            -- Обновляем текст
                                            local textLabel = billboard:FindFirstChild("ESP_Label")
                                            if not textLabel then
                                                textLabel = Instance.new("TextLabel")
                                                textLabel.Name = "ESP_Label"
                                                textLabel.BackgroundTransparency = 1
                                                textLabel.Size = UDim2.new(1, 0, 1, 0)
                                                textLabel.Text = ""
                                                textLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
                                                textLabel.TextSize = MainModule.Misc.ESPTextSize
                                                textLabel.Font = Enum.Font.GothamBold
                                                textLabel.TextStrokeTransparency = 0.3
                                                textLabel.Parent = billboard
                                            end
                                            
                                            -- Формируем текст
                                            local text = player.DisplayName
                                            
                                            if MainModule.Misc.ESPDistance and localRootPart then
                                                local distance = math.floor((rootPart.Position - localRootPart.Position).Magnitude)
                                                text = text .. " [" .. distance .. "m]"
                                            end
                                            
                                            if MainModule.Misc.ESPHP then
                                                text = text .. " HP: " .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                                            end
                                            
                                            textLabel.Text = text
                                        end
                                        
                                        -- Добавляем Box ESP если включено
                                        if MainModule.Misc.ESPBoxes then
                                            local box = MainModule.ESPTable[cacheKey .. "_box"]
                                            if not box then
                                                box = Instance.new("SelectionBox")
                                                box.Name = "ESP_Box_" .. player.Name
                                                box.Adornee = character
                                                box.Color3 = Color3.fromRGB(0, 170, 255)
                                                box.LineThickness = 0.05
                                                box.Transparency = 0.7
                                                box.Parent = MainModule.ESPFolder
                                                
                                                MainModule.ESPTable[cacheKey .. "_box"] = box
                                            end
                                        end
                                        
                                        -- Snow distance (расстояние в снегу)
                                        if MainModule.Misc.ESPSnow and localRootPart then
                                            local snowText = MainModule.ESPTable[cacheKey .. "_snow"]
                                            if not snowText then
                                                snowText = Instance.new("BillboardGui")
                                                snowText.Name = "ESP_Snow_" .. player.Name
                                                snowText.Adornee = rootPart
                                                snowText.AlwaysOnTop = true
                                                snowText.Size = UDim2.new(0, 200, 0, 30)
                                                snowText.StudsOffset = Vector3.new(0, 4, 0)
                                                snowText.Parent = MainModule.ESPFolder
                                                
                                                local snowLabel = Instance.new("TextLabel")
                                                snowLabel.Name = "Snow_Label"
                                                snowLabel.BackgroundTransparency = 1
                                                snowLabel.Size = UDim2.new(1, 0, 1, 0)
                                                snowLabel.Text = ""
                                                snowLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                                                snowLabel.TextSize = 14
                                                snowLabel.Font = Enum.Font.GothamBold
                                                snowLabel.TextStrokeTransparency = 0.3
                                                snowLabel.Parent = snowText
                                                
                                                MainModule.ESPTable[cacheKey .. "_snow"] = snowText
                                            end
                                            
                                            -- Обновляем Snow текст
                                            local snowLabel = snowText:FindFirstChild("Snow_Label")
                                            if snowLabel and localRootPart then
                                                local distance = math.floor((rootPart.Position - localRootPart.Position).Magnitude)
                                                local yDiff = math.floor(rootPart.Position.Y - localRootPart.Position.Y)
                                                snowLabel.Text = "Dist: " .. distance .. "m | Y: " .. yDiff
                                            end
                                        end
                                        
                                        MainModule.ESPCache[cacheKey] = tick()
                                    end
                                end
                            end
                        end
                    end
                end
                
                -- ESP для Hiders (прячущихся)
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
                                        local highlight = MainModule.ESPTable[cacheKey .. "_highlight"]
                                        if not highlight then
                                            highlight = Instance.new("Highlight")
                                            highlight.Name = "ESP_Hider_" .. player.Name
                                            highlight.Adornee = player.Character
                                            highlight.FillColor = Color3.fromRGB(0, 255, 0)
                                            highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
                                            highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                                            highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
                                            highlight.Enabled = MainModule.Misc.ESPHighlight
                                            highlight.Parent = MainModule.ESPFolder
                                            
                                            MainModule.ESPTable[cacheKey .. "_highlight"] = {
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
                
                -- ESP для Seekers (ищущих)
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
                                        local highlight = MainModule.ESPTable[cacheKey .. "_highlight"]
                                        if not highlight then
                                            highlight = Instance.new("Highlight")
                                            highlight.Name = "ESP_Seeker_" .. player.Name
                                            highlight.Adornee = player.Character
                                            highlight.FillColor = Color3.fromRGB(255, 0, 0)
                                            highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
                                            highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                                            highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
                                            highlight.Enabled = MainModule.Misc.ESPHighlight
                                            highlight.Parent = MainModule.ESPFolder
                                            
                                            MainModule.ESPTable[cacheKey .. "_highlight"] = {
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
                
                -- ESP для Guards (охранников)
                if MainModule.Misc.ESPGuards then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local isGuard = player:GetAttribute("IsGuard") or 
                                           player:GetAttribute("IsCircleGuard") or 
                                           player:GetAttribute("IsTriangleGuard") or 
                                           player:GetAttribute("IsSquareGuard")
                            if isGuard then
                                local cacheKey = "guard_" .. player.UserId
                                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                                
                                if rootPart then
                                    if not MainModule.ESPCache[cacheKey] or tick() - MainModule.ESPCache[cacheKey] > 2 then
                                        -- Создаем Highlight для Guard
                                        local highlight = MainModule.ESPTable[cacheKey .. "_highlight"]
                                        if not highlight then
                                            highlight = Instance.new("Highlight")
                                            highlight.Name = "ESP_Guard_" .. player.Name
                                            highlight.Adornee = player.Character
                                            highlight.FillColor = Color3.fromRGB(255, 165, 0)
                                            highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
                                            highlight.OutlineColor = Color3.fromRGB(255, 165, 0)
                                            highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
                                            highlight.Enabled = MainModule.Misc.ESPHighlight
                                            highlight.Parent = MainModule.ESPFolder
                                            
                                            MainModule.ESPTable[cacheKey .. "_highlight"] = {
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
                
                -- ESP для конфет (Candies)
                if MainModule.Misc.ESPCandies then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and (obj.Name:lower():find("candy") or 
                           obj.Name:lower():find("конфет") or obj.Name:lower():find("сладост")) then
                            local cacheKey = "candy_" .. HttpService:GenerateGUID(false)
                            local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                            
                            if primaryPart then
                                if not MainModule.ESPCache[cacheKey] or tick() - MainModule.ESPCache[cacheKey] > 5 then
                                    local highlight = MainModule.ESPTable[cacheKey .. "_highlight"]
                                    if not highlight then
                                        highlight = Instance.new("Highlight")
                                        highlight.Name = "ESP_Candy"
                                        highlight.Adornee = obj
                                        highlight.FillColor = Color3.fromRGB(255, 105, 180)
                                        highlight.FillTransparency = 0.3
                                        highlight.OutlineColor = Color3.fromRGB(255, 105, 180)
                                        highlight.OutlineTransparency = 0
                                        highlight.Enabled = true
                                        highlight.Parent = MainModule.ESPFolder
                                        
                                        MainModule.ESPTable[cacheKey .. "_highlight"] = {
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
                
                -- ESP для ключей (Keys)
                if MainModule.Misc.ESPKeys then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and (obj.Name:lower():find("key") or 
                           obj.Name:lower():find("ключ") or obj.Name:lower():find("двер")) then
                            local cacheKey = "key_" .. HttpService:GenerateGUID(false)
                            local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                            
                            if primaryPart then
                                if not MainModule.ESPCache[cacheKey] or tick() - MainModule.ESPCache[cacheKey] > 5 then
                                    local highlight = MainModule.ESPTable[cacheKey .. "_highlight"]
                                    if not highlight then
                                        highlight = Instance.new("Highlight")
                                        highlight.Name = "ESP_Key"
                                        highlight.Adornee = obj
                                        highlight.FillColor = Color3.fromRGB(255, 215, 0)
                                        highlight.FillTransparency = 0.3
                                        highlight.OutlineColor = Color3.fromRGB(255, 215, 0)
                                        highlight.OutlineTransparency = 0
                                        highlight.Enabled = true
                                        highlight.Parent = MainModule.ESPFolder
                                        
                                        MainModule.ESPTable[cacheKey .. "_highlight"] = {
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
                
                -- ESP для дверей (Doors)
                if MainModule.Misc.ESPDoors then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and (obj.Name:lower():find("door") or 
                           obj.Name:lower():find("exit") or obj.Name:lower():find("gate")) then
                            local cacheKey = "door_" .. HttpService:GenerateGUID(false)
                            local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                            
                            if primaryPart then
                                if not MainModule.ESPCache[cacheKey] or tick() - MainModule.ESPCache[cacheKey] > 5 then
                                    local highlight = MainModule.ESPTable[cacheKey .. "_highlight"]
                                    if not highlight then
                                        highlight = Instance.new("Highlight")
                                        highlight.Name = "ESP_Door"
                                        highlight.Adornee = obj
                                        highlight.FillColor = Color3.fromRGB(139, 69, 19)
                                        highlight.FillTransparency = 0.5
                                        highlight.OutlineColor = Color3.fromRGB(139, 69, 19)
                                        highlight.OutlineTransparency = 0
                                        highlight.Enabled = true
                                        highlight.Parent = MainModule.ESPFolder
                                        
                                        MainModule.ESPTable[cacheKey .. "_highlight"] = {
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
                
                -- ESP для аварийных выходов (Escape Doors)
                if MainModule.Misc.ESPEscapeDoors then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and (obj.Name:lower():find("escape") or 
                           obj.Name:lower():find("emergency") or obj.Name:lower():find("выход")) then
                            local cacheKey = "escape_door_" .. HttpService:GenerateGUID(false)
                            local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                            
                            if primaryPart then
                                if not MainModule.ESPCache[cacheKey] or tick() - MainModule.ESPCache[cacheKey] > 5 then
                                    local highlight = MainModule.ESPTable[cacheKey .. "_highlight"]
                                    if not highlight then
                                        highlight = Instance.new("Highlight")
                                        highlight.Name = "ESP_EscapeDoor"
                                        highlight.Adornee = obj
                                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                                        highlight.FillTransparency = 0.3
                                        highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                                        highlight.OutlineTransparency = 0
                                        highlight.Enabled = true
                                        highlight.Parent = MainModule.ESPFolder
                                        
                                        MainModule.ESPTable[cacheKey .. "_highlight"] = {
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

-- Jump Rope Anti Fall
function MainModule.ToggleJumpRopeAntiFall(enabled)
    MainModule.JumpRope.AntiFall = enabled
    
    if jumpRopeAntiFallConnection then
        jumpRopeAntiFallConnection:Disconnect()
        jumpRopeAntiFallConnection = nil
    end
    
    if enabled then
        -- Создаем Anti-Fall платформу для Jump Rope
        if MainModule.JumpRope.AntiFallPlatform then
            MainModule.JumpRope.AntiFallPlatform:Destroy()
            MainModule.JumpRope.AntiFallPlatform = nil
        end
        
        MainModule.JumpRope.AntiFallPlatform = Instance.new("Part")
        MainModule.JumpRope.AntiFallPlatform.Name = "JumpRopeAntiFallPlatform"
        MainModule.JumpRope.AntiFallPlatform.Size = Vector3.new(200, 5, 200)
        MainModule.JumpRope.AntiFallPlatform.Position = Vector3.new(737, 180, 920)
        MainModule.JumpRope.AntiFallPlatform.Anchored = true
        MainModule.JumpRope.AntiFallPlatform.CanCollide = true
        MainModule.JumpRope.AntiFallPlatform.Transparency = 0.9 -- Полностью прозрачный
        MainModule.JumpRope.AntiFallPlatform.Material = Enum.Material.Glass
        MainModule.JumpRope.AntiFallPlatform.Parent = Workspace
        
        jumpRopeAntiFallConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.JumpRope.AntiFall then return end
            
            local character = LocalPlayer.Character
            if not character then return end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart then return end
            
            -- Если упали ниже высоты 170
            if rootPart.Position.Y < 170 then
                rootPart.CFrame = CFrame.new(737, 195, 920)
            end
        end)
    else
        -- Удаляем платформу
        if MainModule.JumpRope.AntiFallPlatform then
            MainModule.JumpRope.AntiFallPlatform:Destroy()
            MainModule.JumpRope.AntiFallPlatform = nil
        end
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
        -- Удаляем воду и синие эффекты
        RemoveWaterAndBlueEffects()
        MainModule.GlassBridge.WaterRemoved = true
        
        -- Создаем Safe Platform на всех стеклах
        MainModule.CreateGlassBridgeSafePlatform()
        
        -- Для Anti Break делаем стекла неломающимися
        antiBreakConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.GlassBridge.AntiBreak then return end
            
            pcall(function()
                local GlassHolder = Workspace:FindFirstChild("GlassBridge") and Workspace.GlassBridge:FindFirstChild("GlassHolder")
                if not GlassHolder then return end
                
                for _, v in pairs(GlassHolder:GetChildren()) do
                    for _, j in pairs(v:GetChildren()) do
                        if j:IsA("Model") and j.PrimaryPart then
                            j.PrimaryPart:SetAttribute("exploitingisevil", false)
                            j.PrimaryPart.CanCollide = true
                            j.PrimaryPart.Transparency = 0
                            
                            -- Делаем все части неломающимися
                            for _, part in pairs(j:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = true
                                    part.Anchored = true
                                    
                                    -- Убираем атрибуты, которые могут вызывать поломку
                                    if part:GetAttribute("Breakable") then
                                        part:SetAttribute("Breakable", false)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end)
    else
        -- Удаляем Safe Platform
        MainModule.RemoveGlassBridgeSafePlatform()
        
        -- Восстанавливаем состояние стекол
        pcall(function()
            local GlassHolder = Workspace:FindFirstChild("GlassBridge") and Workspace.GlassBridge:FindFirstChild("GlassHolder")
            if GlassHolder then
                for _, v in pairs(GlassHolder:GetChildren()) do
                    for _, j in pairs(v:GetChildren()) do
                        if j:IsA("Model") and j.PrimaryPart then
                            j.PrimaryPart:SetAttribute("exploitingisevil", nil)
                        end
                    end
                end
            end
        end)
    end
end

function MainModule.CreateGlassBridgeSafePlatform()
    if MainModule.GlassBridge.AntiFallPlatform then
        MainModule.GlassBridge.AntiFallPlatform:Destroy()
        MainModule.GlassBridge.AntiFallPlatform = nil
    end
    
    -- Создаем безопасную платформу под всем Glass Bridge
    MainModule.GlassBridge.AntiFallPlatform = Instance.new("Part")
    MainModule.GlassBridge.AntiFallPlatform.Name = "GlassBridgeSafePlatform"
    MainModule.GlassBridge.AntiFallPlatform.Size = Vector3.new(300, 5, 300)
    MainModule.GlassBridge.AntiFallPlatform.Position = Vector3.new(-200, 520, -1534)
    MainModule.GlassBridge.AntiFallPlatform.Anchored = true
    MainModule.GlassBridge.AntiFallPlatform.CanCollide = true
    MainModule.GlassBridge.AntiFallPlatform.Transparency = 0.9 -- Полностью прозрачный
    MainModule.GlassBridge.AntiFallPlatform.Material = Enum.Material.Glass
    MainModule.GlassBridge.AntiFallPlatform.Color = Color3.fromRGB(255, 255, 255)
    MainModule.GlassBridge.AntiFallPlatform.Parent = Workspace
end

function MainModule.RemoveGlassBridgeSafePlatform()
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
        -- Удаляем воду и синие эффекты при включении ESP
        RemoveWaterAndBlueEffects()
        
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

                            -- Не красим все в зеленый, показываем реальное состояние
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

-- HNS Spikes Kill
function MainModule.ToggleSpikesKill(enabled)
    MainModule.HNS.SpikesKill = enabled
    
    if hnsSpikesKillConnection then
        hnsSpikesKillConnection:Disconnect()
        hnsSpikesKillConnection = nil
    end
    
    if enabled then
        -- Сохраняем позиции шипов
        MainModule.HNSSpikes = {}
        
        pcall(function()
            local spikes = Workspace:FindFirstChild("HideAndSeekMap") and 
                          Workspace.HideAndSeekMap:FindFirstChild("KillingParts")
            
            if spikes then
                for _, spike in pairs(spikes:GetChildren()) do
                    if spike:IsA("BasePart") then
                        table.insert(MainModule.HNSSpikes, spike.Position)
                    end
                end
            end
        end)
        
        -- Spike Kill процесс
        hnsSpikesKillConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.SpikesKill then return end
            if MainModule.HNS.IsInSpikeKillProcess then return end
            
            local currentTime = tick()
            if currentTime - MainModule.HNS.LastSpikeKillTime < MainModule.HNS.SpikeKillCooldown then return end
            
            local character = LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then return end
            
            -- Проверяем, есть ли нож
            local hasKnife = false
            local knifeTool = nil
            
            for _, tool in pairs(character:GetChildren()) do
                if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("dagger") or tool.Name:lower():find("fork")) then
                    hasKnife = true
                    knifeTool = tool
                    break
                end
            end
            
            if not hasKnife and LocalPlayer:FindFirstChild("Backpack") then
                for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("dagger") or tool.Name:lower():find("fork")) then
                        hasKnife = true
                        knifeTool = tool
                        break
                    end
                end
            end
            
            if not hasKnife then return end
            
            -- Ищем ближайшего живого игрока-прячущегося
            local nearestHider = nil
            local nearestDistance = math.huge
            local targetRootPart = nil
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local targetCharacter = player.Character
                    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
                    local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
                    
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
            
            if nearestHider and targetRootPart and nearestDistance < 100 then
                MainModule.HNS.CurrentSpikeKillTarget = nearestHider
                MainModule.HNS.IsInSpikeKillProcess = true
                
                local originalCFrame = rootPart.CFrame
                MainModule.HNS.OriginalSpikeKillPosition = originalCFrame
                
                -- Телепортируемся за спину цели
                local teleportCFrame = targetRootPart.CFrame * CFrame.new(0, 0, -2)
                rootPart.CFrame = teleportCFrame
                
                task.wait(0.2)
                
                -- Атакуем ножом
                if knifeTool then
                    local remoteEvent = knifeTool:FindFirstChild("RemoteEvent")
                    if remoteEvent then
                        pcall(function()
                            remoteEvent:FireServer()
                        end)
                    end
                    
                    local virtualInputManager = game:GetService("VirtualInputManager")
                    pcall(function()
                        virtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        task.wait(0.05)
                        virtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    end)
                end
                
                task.wait(0.5)
                
                -- Телепортируем цель к шипам
                if #MainModule.HNSSpikes > 0 then
                    local randomSpike = MainModule.HNSSpikes[math.random(1, #MainModule.HNSSpikes)]
                    targetRootPart.CFrame = CFrame.new(randomSpike)
                    
                    task.wait(2)
                    rootPart.CFrame = originalCFrame
                else
                    rootPart.CFrame = originalCFrame
                end
                
                MainModule.HNS.LastSpikeKillTime = tick()
                MainModule.HNS.IsInSpikeKillProcess = false
                
                if not nearestHider.Character or not nearestHider.Character:FindFirstChildOfClass("Humanoid") or 
                   nearestHider.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
                    MainModule.HNS.CurrentSpikeKillTarget = nil
                end
            end
        end)
    else
        MainModule.HNS.CurrentSpikeKillTarget = nil
        MainModule.HNS.IsInSpikeKillProcess = false
        MainModule.HNS.OriginalSpikeKillPosition = nil
    end
end

-- HNS Disable Spikes
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

-- HNS Kill Hiders
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
            
            -- Проверяем нож
            local hasKnife = false
            local knifeTool = nil
            
            for _, tool in pairs(character:GetChildren()) do
                if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("dagger") or tool.Name:lower():find("fork")) then
                    hasKnife = true
                    knifeTool = tool
                    break
                end
            end
            
            if not hasKnife and LocalPlayer:FindFirstChild("Backpack") then
                for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("dagger") or tool.Name:lower():find("fork")) then
                        hasKnife = true
                        knifeTool = tool
                        break
                    end
                end
            end
            
            if not hasKnife then return end
            
            -- Ищем ближайшего прячущегося
            local nearestHider = nil
            local nearestDistance = math.huge
            local targetRootPart = nil
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local targetCharacter = player.Character
                    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
                    local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
                    
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
            
            if nearestHider and targetRootPart and nearestDistance < 100 then
                MainModule.HNS.CurrentKillTarget = nearestHider
                
                -- Поворачиваемся к цели
                local direction = (targetRootPart.Position - rootPart.Position).Unit
                local lookVector = Vector3.new(direction.X, 0, direction.Z)
                if lookVector.Magnitude > 0 then
                    rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + lookVector)
                end
                
                -- Телепортируемся если далеко
                if nearestDistance > 3 then
                    local teleportCFrame = targetRootPart.CFrame * CFrame.new(0, 0, -2)
                    rootPart.CFrame = teleportCFrame
                end
                
                -- Атакуем
                if knifeTool then
                    local remoteEvent = knifeTool:FindFirstChild("RemoteEvent")
                    if remoteEvent then
                        pcall(function()
                            remoteEvent:FireServer()
                        end)
                    end
                    
                    local virtualInputManager = game:GetService("VirtualInputManager")
                    pcall(function()
                        virtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        task.wait(0.05)
                        virtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    end)
                end
                
                MainModule.HNS.LastKillTime = tick()
                
                -- Сбрасываем если цель умерла
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

-- Функции скорости
function MainModule.ToggleSpeedHack(enabled)
    MainModule.SpeedHack.Enabled = enabled
    
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
    
    if enabled then
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
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

-- Anti Stun функция (отдельная от Anti Ragdoll)
function MainModule.ToggleAntiStun(enabled)
    MainModule.AntiStun.Enabled = enabled
    
    if antiStunConnection then
        antiStunConnection:Disconnect()
        antiStunConnection = nil
    end
    
    if antiStunEffectsConnection then
        antiStunEffectsConnection:Disconnect()
        antiStunEffectsConnection = nil
    end
    
    if enabled then
        -- Функция для удаления эффектов
        local function RemoveStunEffects()
            local character = LocalPlayer.Character
            if not character then return end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            
            local removedCount = 0
            
            -- Удаляем эффекты из персонажа
            for _, obj in pairs(character:GetDescendants()) do
                if MainModule.AntiStun.RemoveInjured and 
                   (obj.Name == "InjuredWalking" or obj.Name:lower():find("injured")) then
                    obj:Destroy()
                    removedCount = removedCount + 1
                end
                
                if MainModule.AntiStun.RemoveStun and 
                   (obj.Name:lower():find("stun") or obj.Name:lower():find("slow")) then
                    obj:Destroy()
                    removedCount = removedCount + 1
                end
                
                if MainModule.AntiStun.RemoveSlow and 
                   (obj.Name:lower():find("freeze") or obj.Name:lower():find("paralyze") or obj.Name:lower():find("debuff")) then
                    obj:Destroy()
                    removedCount = removedCount + 1
                end
            end
            
            -- Удаляем анимации
            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                local trackName = track.Name:lower()
                if MainModule.AntiStun.RemoveInjured and trackName:find("injured") then
                    track:Stop()
                    removedCount = removedCount + 1
                end
                
                if MainModule.AntiStun.RemoveStun and trackName:find("stun") then
                    track:Stop()
                    removedCount = removedCount + 1
                end
            end
            
            -- Восстанавливаем состояния
            if humanoid:GetState() == Enum.HumanoidStateType.Stunned then
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
                removedCount = removedCount + 1
            end
            
            -- Поддерживаем максимальную скорость
            if humanoid.WalkSpeed < 16 then
                humanoid.WalkSpeed = 16
            end
            
            -- Удаляем модификаторы скорости
            for _, child in pairs(character:GetDescendants()) do
                if child:IsA("NumberValue") and child.Name:lower():find("speed") then
                    if child.Value < 1 then
                        child.Value = 1
                    end
                end
            end
            
            -- Удаляем эффекты из workspace
            for _, effect in pairs(Workspace:GetDescendants()) do
                if effect:IsA("BasePart") then
                    if (effect.Name:lower():find("injured") or effect.Name:lower():find("stun")) then
                        local rootPart = character:FindFirstChild("HumanoidRootPart")
                        if rootPart and (rootPart.Position - effect.Position).Magnitude < 20 then
                            effect:Destroy()
                            removedCount = removedCount + 1
                        end
                    end
                end
            end
            
            return removedCount
        end
        
        -- Удаляем QTE эффекты
        antiStunConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.AntiStun.Enabled then return end
            
            pcall(function()
                local playerGui = LocalPlayer:WaitForChild("PlayerGui")
                local impactFrames = playerGui:FindFirstChild("ImpactFrames")
                if not impactFrames then return end
                
                local hbgModule = require(ReplicatedStorage.Modules.HBGQTE)
                
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
        
        -- Удаляем Stun эффекты
        antiStunEffectsConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.AntiStun.Enabled then return end
            RemoveStunEffects()
        end)
        
        -- Настраиваем иммунитет
        if MainModule.AntiStun.ImmuneToDebuffs then
            local function SetupImmunity()
                local character = LocalPlayer.Character
                if not character then return end
                
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if not humanoid then return end
                
                -- Отслеживаем состояния
                humanoid.StateChanged:Connect(function(oldState, newState)
                    if newState == Enum.HumanoidStateType.Stunned then
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end)
            end
            
            if LocalPlayer.Character then
                SetupImmunity()
            end
            
            LocalPlayer.CharacterAdded:Connect(SetupImmunity)
        end
    end
end

-- Anti Ragdoll функция (отдельная от Anti Stun)
function MainModule.ToggleAntiRagdoll(enabled)
    MainModule.AntiRagdoll.Enabled = enabled
    
    if antiRagdollConnection then
        antiRagdollConnection:Disconnect()
        antiRagdollConnection = nil
    end
    
    if enabled then
        antiRagdollConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.AntiRagdoll.Enabled then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if not humanoid then return end
                
                -- Предотвращаем падение и рагдолл
                if MainModule.AntiRagdoll.PreventFalling then
                    if humanoid:GetState() == Enum.HumanoidStateType.FallingDown or 
                       humanoid:GetState() == Enum.HumanoidStateType.Ragdoll then
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end
                
                -- Включаем моторы если отключены
                if MainModule.AntiRagdoll.KeepUpright then
                    for _, v in pairs(character:GetDescendants()) do
                        if v:IsA("Motor6D") and not v.Enabled then 
                            v.Enabled = true 
                        end
                    end
                end
                
                -- Заставляем стоять
                if MainModule.AntiRagdoll.ForceStand then
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        -- Не фиксируем поворот, чтобы можно было бегать
                        local currentCFrame = rootPart.CFrame
                        local newCFrame = CFrame.new(
                            currentCFrame.Position.X,
                            currentCFrame.Position.Y,
                            currentCFrame.Position.Z
                        )
                        rootPart.CFrame = newCFrame
                    end
                end
                
                -- Убираем физические эффекты
                for _, v in pairs(character:GetDescendants()) do
                    if v:IsA("BodyForce") or v:IsA("BodyVelocity") then
                        v:Destroy()
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
        -- Сохраняем оригинальные значения
        MainModule.Guards.OriginalFireRates = {}
        
        pcall(function()
            local weaponsFolder = ReplicatedStorage:FindFirstChild("Weapons")
            if not weaponsFolder then return end
            
            local gunsFolder = weaponsFolder:FindFirstChild("Guns")
            if gunsFolder then
                for _, obj in ipairs(gunsFolder:GetDescendants()) do
                    if obj.Name == "FireRateCD" and (obj:IsA("NumberValue") or obj:IsA("IntValue")) then
                        MainModule.Guards.OriginalFireRates[obj] = obj.Value
                    end
                end
            end
        end)
        
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
        -- Восстанавливаем оригинальные значения
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
            
            local character = LocalPlayer.Character
            if character then
                for _, tool in pairs(character:GetChildren()) do
                    if tool:IsA("Tool") then
                        for _, obj in pairs(tool:GetDescendants()) do
                            if obj.Name == "FireRateCD" and (obj:IsA("NumberValue") or obj:IsA("IntValue")) then
                                obj.Value = 0.5 -- Дефолтное значение
                            end
                        end
                    end
                end
            end
        end)
        
        MainModule.Guards.OriginalFireRates = {}
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
        -- Сохраняем оригинальные значения аммо
        MainModule.Guards.OriginalAmmo = {}
        
        local function saveAmmoValues()
            local character = LocalPlayer.Character
            if character then
                for _, tool in pairs(character:GetChildren()) do
                    if tool:IsA("Tool") then
                        for _, obj in pairs(tool:GetDescendants()) do
                            if obj:IsA("NumberValue") then
                                if obj.Name:lower():find("ammo") or 
                                   obj.Name:lower():find("bullet") or
                                   obj.Name:lower():find("clip") then
                                    MainModule.Guards.OriginalAmmo[obj] = obj.Value
                                end
                            end
                        end
                    end
                end
            end
            
            if LocalPlayer:FindFirstChild("Backpack") then
                for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if tool:IsA("Tool") then
                        for _, obj in pairs(tool:GetDescendants()) do
                            if obj:IsA("NumberValue") then
                                if obj.Name:lower():find("ammo") or 
                                   obj.Name:lower():find("bullet") or
                                   obj.Name:lower():find("clip") then
                                    MainModule.Guards.OriginalAmmo[obj] = obj.Value
                                end
                            end
                        end
                    end
                end
            end
        end
        
        -- Сохраняем текущие значения
        saveAmmoValues()
        
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
            
            if LocalPlayer:FindFirstChild("Backpack") then
                for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
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
    else
        -- Восстанавливаем оригинальные значения аммо
        pcall(function()
            for obj, originalValue in pairs(MainModule.Guards.OriginalAmmo) do
                if obj and obj.Parent then
                    obj.Value = originalValue
                end
            end
        end)
        
        MainModule.Guards.OriginalAmmo = {}
    end
end

-- Hitbox Expander функция (исправленная без лагов)
function MainModule.ToggleHitboxExpander(enabled)
    MainModule.Guards.HitboxExpander = enabled
    
    if hitboxConnection then
        hitboxConnection:Disconnect()
        hitboxConnection = nil
    end
    
    -- Восстанавливаем оригинальные размеры перед изменением
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
    
    if enabled then
        local HITBOX_SIZE = MainModule.Guards.HitboxSize
        
        -- Оптимизированное обновление хитбоксов
        local lastUpdate = 0
        local updateInterval = 0.1 -- 10 обновлений в секунду
        
        hitboxConnection = RunService.RenderStepped:Connect(function()
            local currentTime = tick()
            if currentTime - lastUpdate < updateInterval then
                return
            end
            lastUpdate = currentTime
            
            pcall(function()
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local character = player.Character
                        
                        -- Проверяем жив ли персонаж
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if not humanoid or humanoid.Health <= 0 then
                            -- Если умер, восстанавливаем оригинальные размеры
                            if MainModule.Guards.OriginalHitboxes[player] then
                                for partName, originalSize in pairs(MainModule.Guards.OriginalHitboxes[player]) do
                                    local part = character:FindFirstChild(partName)
                                    if part and part:IsA("BasePart") then
                                        part.Size = originalSize
                                        part.Transparency = 0
                                        part.CanCollide = true
                                    end
                                end
                            end
                            MainModule.Guards.OriginalHitboxes[player] = nil
                            goto continue
                        end
                        
                        -- Сохраняем оригинальные размеры если еще не сохранены
                        if not MainModule.Guards.OriginalHitboxes[player] then
                            MainModule.Guards.OriginalHitboxes[player] = {}
                            
                            -- Сохраняем только основные части
                            local bodyParts = {"Head", "Torso", "HumanoidRootPart"}
                            for _, partName in pairs(bodyParts) do
                                local part = character:FindFirstChild(partName)
                                if part and part:IsA("BasePart") then
                                    MainModule.Guards.OriginalHitboxes[player][partName] = part.Size
                                end
                            end
                        end
                        
                        -- Увеличиваем размеры (без заморозки движения)
                        local bodyParts = {"Head", "Torso", "HumanoidRootPart"}
                        for _, partName in pairs(bodyParts) do
                            local part = character:FindFirstChild(partName)
                            if part and part:IsA("BasePart") then
                                -- Увеличиваем размер до HITBOX_SIZE
                                local currentSize = part.Size
                                local newSize = Vector3.new(HITBOX_SIZE, HITBOX_SIZE, HITBOX_SIZE)
                                
                                -- Меняем размер только если отличается
                                if currentSize ~= newSize then
                                    part.Size = newSize
                                end
                                
                                -- Делаем полностью прозрачным
                                if part.Transparency < 1 then
                                    part.Transparency = 1
                                end
                                
                                -- НЕ отключаем коллизию (чтобы не замораживало движение)
                                if not part.CanCollide then
                                    part.CanCollide = true
                                end
                                
                                -- НЕ делаем anchored (чтобы персонаж мог двигаться)
                                if part.Anchored then
                                    part.Anchored = false
                                end
                            end
                        end
                        
                        ::continue::
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

-- Unlock Dash (Don't work)
function MainModule.ToggleUnlockDash(enabled)
    MainModule.Misc.UnlockDash = enabled
    -- Функция не работает
end

-- Unlock Phantom Step (Don't work)
function MainModule.ToggleUnlockPhantomStep(enabled)
    MainModule.Misc.UnlockPhantomStep = enabled
    -- Функция не работает
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
        noCooldownConnection, antiStunConnection, antiRagdollConnection, antiStunEffectsConnection,
        rapidFireConnection, infiniteAmmoConnection, hitboxConnection, autoPullConnection, 
        antiBreakConnection, MainModule.ESPConnection, glassBridgeESPConnection,
        hnsSpikesKillConnection, hnsKillHidersConnection, jumpRopeAntiFallConnection
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
    
    -- Восстанавливаем Infinite Ammo
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
    
    -- Удаляем Glass Bridge объекты
    MainModule.RemoveGlassBridgeSafePlatform()
    
    -- Удаляем Jump Rope Anti Fall
    if MainModule.JumpRope.AntiFallPlatform then
        MainModule.JumpRope.AntiFallPlatform:Destroy()
        MainModule.JumpRope.AntiFallPlatform = nil
    end
    
    -- Восстанавливаем шипы
    if MainModule.HNS.DisableSpikes then
        MainModule.ToggleDisableSpikes(false)
    end
    
    -- Восстанавливаем Glass Bridge ESP
    if MainModule.GlassBridge.GlassESPEnabled then
        MainModule.ToggleGlassBridgeESP(false)
    end
    
    -- Сбрасываем HNS состояния
    MainModule.HNS.CurrentSpikeKillTarget = nil
    MainModule.HNS.IsInSpikeKillProcess = false
    MainModule.HNS.OriginalSpikeKillPosition = nil
    MainModule.HNS.CurrentKillTarget = nil
end

-- Автоматическая очистка при выходе
Players.LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not Players.LocalPlayer.Parent then
        MainModule.Cleanup()
    end
end)

return MainModule
