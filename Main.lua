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
    AntiStunRagdoll = false,
    RemoveInjuredEnabled = false,
    RemoveStunEnabled = false,
    UnlockDashEnabled = false,
    UnlockPhantomStepEnabled = false,
    LastInjuredNotify = 0
}

-- Новые ESP настройки для Snow/Box
MainModule.Misc.ESPSnow = {
    Enabled = true,
    ShowDistance = true,
    ShowHP = true
}

MainModule.Misc.ESPBox = {
    Enabled = true,
    ShowDistance = true,
    ShowName = true
}

-- ESP System (оптимизированная без лагов)
MainModule.ESPTable = {}
MainModule.ESPFolder = nil
MainModule.ESPUpdateRate = 1.0  -- Увеличил для оптимизации
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
MainModule.LastKnifeHitboxCheck = 0
MainModule.KnifeHitboxCheckRate = 0.1

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
local removeInjuredConnection = nil
local unlockDashConnection = nil
local unlockPhantomStepConnection = nil
local antiFallGlassBridgeConnection = nil
local antiFallJumpRopeConnection = nil

-- Локальный игрок
local LocalPlayer = Players.LocalPlayer

-- Вспомогательные функции
local function SafeDestroy(obj)
    if obj and obj.Parent then
        pcall(function() obj:Destroy() end)
    end
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
            SafeDestroy(esp)
        end
    end
    MainModule.ESPTable = {}
    MainModule.ESPCache = {}
    
    -- Удаляем папку ESP
    if MainModule.ESPFolder then
        SafeDestroy(MainModule.ESPFolder)
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
                        SafeDestroy(MainModule.ESPTable[key])
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
                                    if not MainModule.ESPCache[cacheKey] or tick() - MainModule.ESPCache[cacheKey] > 3 then
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
                                                Adornee = player.Character,
                                                Destroy = function()
                                                    SafeDestroy(highlight)
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
                                        
                                        -- Формируем текст
                                        local text = player.DisplayName
                                        if MainModule.Misc.ESPDistance then
                                            local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) 
                                                and math.floor((rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) 
                                                or 0
                                            text = text .. " [" .. distance .. "m]"
                                        end
                                        
                                        -- Добавляем HP для Snow
                                        if MainModule.Misc.ESPSnow.ShowHP and humanoid then
                                            text = text .. " HP:" .. math.floor(humanoid.Health)
                                        end
                                        
                                        textLabel.Text = text
                                        textLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
                                        textLabel.TextSize = MainModule.Misc.ESPTextSize
                                        textLabel.Font = Enum.Font.GothamBold
                                        textLabel.TextStrokeTransparency = 0.3
                                        textLabel.Parent = billboard
                                        
                                        MainModule.ESPTable[cacheKey .. "_text"] = {
                                            Billboard = billboard,
                                            Destroy = function()
                                                SafeDestroy(billboard)
                                            end
                                        }
                                    end
                                    
                                    -- Добавляем Box ESP если включено
                                    if MainModule.Misc.ESPBox.Enabled and not MainModule.ESPTable[cacheKey .. "_box"] then
                                        local box = Instance.new("BoxHandleAdornment")
                                        box.Name = "ESP_Box_" .. player.Name
                                        box.Adornee = rootPart
                                        box.AlwaysOnTop = true
                                        box.Size = rootPart.Size + Vector3.new(0.5, 0.5, 0.5)
                                        box.Color3 = Color3.fromRGB(0, 170, 255)
                                        box.Transparency = 0.7
                                        box.ZIndex = 10
                                        box.Parent = MainModule.ESPFolder
                                        
                                        MainModule.ESPTable[cacheKey .. "_box"] = {
                                            Box = box,
                                            Destroy = function()
                                                SafeDestroy(box)
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
                                    if not MainModule.ESPCache[cacheKey] or tick() - MainModule.ESPCache[cacheKey] > 3 then
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
                                                Adornee = player.Character,
                                                Destroy = function()
                                                    SafeDestroy(highlight)
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
                                    if not MainModule.ESPCache[cacheKey] or tick() - MainModule.ESPCache[cacheKey] > 3 then
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
                                                Adornee = player.Character,
                                                Destroy = function()
                                                    SafeDestroy(highlight)
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
                        if obj:IsA("Model") and (obj.Name:lower():find("candy") or obj.Name:lower():find("конфет") or obj.Name:lower():find("sweet")) then
                            local cacheKey = "candy_" .. HttpService:GenerateGUID(false)
                            local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                            
                            if primaryPart then
                                if not MainModule.ESPCache[cacheKey] or tick() - MainModule.ESPCache[cacheKey] > 5 then
                                    -- Создаем Highlight для конфеты
                                    if not MainModule.ESPTable[cacheKey] then
                                        local highlight = Instance.new("Highlight")
                                        highlight.Name = "ESP_Candy"
                                        highlight.Adornee = obj
                                        highlight.FillColor = Color3.fromRGB(255, 105, 180)
                                        highlight.FillTransparency = 0.3
                                        highlight.OutlineColor = Color3.fromRGB(255, 105, 180)
                                        highlight.OutlineTransparency = 0
                                        highlight.Enabled = true
                                        highlight.Parent = MainModule.ESPFolder
                                        
                                        -- Добавляем текст
                                        local billboard = Instance.new("BillboardGui")
                                        billboard.Name = "ESP_Candy_Text"
                                        billboard.Adornee = primaryPart
                                        billboard.AlwaysOnTop = true
                                        billboard.Size = UDim2.new(0, 150, 0, 30)
                                        billboard.StudsOffset = Vector3.new(0, 2, 0)
                                        
                                        local textLabel = Instance.new("TextLabel")
                                        textLabel.Name = "ESP_Label"
                                        textLabel.BackgroundTransparency = 1
                                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                                        textLabel.Text = "Candy"
                                        if MainModule.Misc.ESPDistance and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                            local distance = math.floor((primaryPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                                            textLabel.Text = "Candy [" .. distance .. "m]"
                                        end
                                        textLabel.TextColor3 = Color3.fromRGB(255, 105, 180)
                                        textLabel.TextSize = 14
                                        textLabel.Font = Enum.Font.GothamBold
                                        textLabel.TextStrokeTransparency = 0.3
                                        textLabel.Parent = billboard
                                        billboard.Parent = MainModule.ESPFolder
                                        
                                        MainModule.ESPTable[cacheKey] = {
                                            Highlight = highlight,
                                            Billboard = billboard,
                                            Destroy = function()
                                                SafeDestroy(highlight)
                                                SafeDestroy(billboard)
                                            end
                                        }
                                    end
                                    
                                    MainModule.ESPCache[cacheKey] = tick()
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
                                                SafeDestroy(highlight)
                                            end
                                        }
                                    end
                                    
                                    MainModule.ESPCache[cacheKey] = tick()
                                end
                            end
                        end
                    end
                end
                
                -- ESP для Guards
                if MainModule.Misc.ESPGuards then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and (obj.Name:lower():find("guard") or obj.Name:lower():find("охранник") or 
                           obj.Name:lower():find("circle") or obj.Name:lower():find("triangle") or obj.Name:lower():find("square")) then
                            local cacheKey = "guard_" .. HttpService:GenerateGUID(false)
                            local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                            
                            if primaryPart then
                                if not MainModule.ESPCache[cacheKey] or tick() - MainModule.ESPCache[cacheKey] > 5 then
                                    -- Создаем Highlight для Guard
                                    if not MainModule.ESPTable[cacheKey] then
                                        local highlight = Instance.new("Highlight")
                                        highlight.Name = "ESP_Guard"
                                        highlight.Adornee = obj
                                        highlight.FillColor = Color3.fromRGB(255, 0, 255)
                                        highlight.FillTransparency = 0.3
                                        highlight.OutlineColor = Color3.fromRGB(255, 0, 255)
                                        highlight.OutlineTransparency = 0
                                        highlight.Enabled = true
                                        highlight.Parent = MainModule.ESPFolder
                                        
                                        MainModule.ESPTable[cacheKey] = {
                                            Highlight = highlight,
                                            Destroy = function()
                                                SafeDestroy(highlight)
                                            end
                                        }
                                    end
                                    
                                    MainModule.ESPCache[cacheKey] = tick()
                                end
                            end
                        end
                    end
                end
                
                -- ESP для Doors
                if MainModule.Misc.ESPDoors then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and (obj.Name:lower():find("door") or obj.Name:lower():find("дверь")) then
                            local cacheKey = "door_" .. HttpService:GenerateGUID(false)
                            local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                            
                            if primaryPart then
                                if not MainModule.ESPCache[cacheKey] or tick() - MainModule.ESPCache[cacheKey] > 5 then
                                    -- Создаем Highlight для двери
                                    if not MainModule.ESPTable[cacheKey] then
                                        local highlight = Instance.new("Highlight")
                                        highlight.Name = "ESP_Door"
                                        highlight.Adornee = obj
                                        highlight.FillColor = Color3.fromRGB(128, 0, 128)
                                        highlight.FillTransparency = 0.3
                                        highlight.OutlineColor = Color3.fromRGB(128, 0, 128)
                                        highlight.OutlineTransparency = 0
                                        highlight.Enabled = true
                                        highlight.Parent = MainModule.ESPFolder
                                        
                                        MainModule.ESPTable[cacheKey] = {
                                            Highlight = highlight,
                                            Destroy = function()
                                                SafeDestroy(highlight)
                                            end
                                        }
                                    end
                                    
                                    MainModule.ESPCache[cacheKey] = tick()
                                end
                            end
                        end
                    end
                end
                
                -- ESP для Escape Doors
                if MainModule.Misc.ESPEscapeDoors then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and (obj.Name:lower():find("escape") and obj.Name:lower():find("door")) then
                            local cacheKey = "escape_door_" .. HttpService:GenerateGUID(false)
                            local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                            
                            if primaryPart then
                                if not MainModule.ESPCache[cacheKey] or tick() - MainModule.ESPCache[cacheKey] > 5 then
                                    -- Создаем Highlight для escape door
                                    if not MainModule.ESPTable[cacheKey] then
                                        local highlight = Instance.new("Highlight")
                                        highlight.Name = "ESP_Escape_Door"
                                        highlight.Adornee = obj
                                        highlight.FillColor = Color3.fromRGB(0, 255, 255)
                                        highlight.FillTransparency = 0.3
                                        highlight.OutlineColor = Color3.fromRGB(0, 255, 255)
                                        highlight.OutlineTransparency = 0
                                        highlight.Enabled = true
                                        highlight.Parent = MainModule.ESPFolder
                                        
                                        MainModule.ESPTable[cacheKey] = {
                                            Highlight = highlight,
                                            Destroy = function()
                                                SafeDestroy(highlight)
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
            SafeDestroy(MainModule.ESPFolder)
            MainModule.ESPFolder = nil
        end
    end
end

-- Функции для включения/выключения отдельных ESP компонентов
function MainModule.ToggleSnowESP(enabled)
    MainModule.Misc.ESPSnow.Enabled = enabled
    -- При изменении настроек Snow перезагружаем ESP
    if MainModule.Misc.ESPEnabled then
        MainModule.ToggleESP(false)
        task.wait(0.1)
        MainModule.ToggleESP(true)
    end
end

function MainModule.ToggleBoxESP(enabled)
    MainModule.Misc.ESPBox.Enabled = enabled
    -- При изменении настроек Box перезагружаем ESP
    if MainModule.Misc.ESPEnabled then
        MainModule.ToggleESP(false)
        task.wait(0.1)
        MainModule.ToggleESP(true)
    end
end

-- Jump Rope функции
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

-- HNS функции (исправленные)
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
        
        -- Запускаем процесс Spike Kill
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
                        
                        -- Если это наш текущий таргет или новый ближайший в радиусе 100
                        if (MainModule.HNS.CurrentSpikeKillTarget and player == MainModule.HNS.CurrentSpikeKillTarget) or 
                           (distance < nearestDistance and distance < 100) then
                            nearestDistance = distance
                            nearestHider = player
                            targetRootPart = targetRoot
                        end
                    end
                end
            end
            
            -- Если нашли живого прячущегося в радиусе 100
            if nearestHider and targetRootPart and nearestDistance < 100 then
                MainModule.HNS.CurrentSpikeKillTarget = nearestHider
                MainModule.HNS.IsInSpikeKillProcess = true
                
                -- Сохраняем оригинальную позицию
                local originalCFrame = rootPart.CFrame
                local originalTargetCFrame = targetRootPart.CFrame
                MainModule.HNS.OriginalSpikeKillPosition = originalCFrame
                
                -- 1. Телепортируемся за спину цели
                local teleportCFrame = targetRootPart.CFrame * CFrame.new(0, 0, -2)
                rootPart.CFrame = teleportCFrame
                
                task.wait(0.2)
                
                -- 2. Атакуем ножом
                if knifeTool then
                    local remoteEvent = knifeTool:FindFirstChild("RemoteEvent")
                    if remoteEvent then
                        pcall(function()
                            remoteEvent:FireServer()
                        end)
                    end
                    
                    -- Также кликаем мышью
                    local virtualInputManager = game:GetService("VirtualInputManager")
                    pcall(function()
                        virtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        task.wait(0.05)
                        virtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    end)
                end
                
                -- 3. Ждем немного чтобы анимация удара сработала
                task.wait(0.5)
                
                -- 4. Проверяем жив ли еще таргет
                local targetHumanoid = nearestHider.Character:FindFirstChildOfClass("Humanoid")
                if targetHumanoid and targetHumanoid.Health > 0 then
                    -- 5. Телепортируем цель к шипам (если есть позиции шипов)
                    if #MainModule.HNSSpikes.Positions > 0 then
                        local randomSpike = MainModule.HNSSpikes.Positions[math.random(1, #MainModule.HNSSpikes.Positions)]
                        targetRootPart.CFrame = CFrame.new(randomSpike)
                        
                        -- 6. Ждем 2 секунды для гарантированного убийства
                        task.wait(2)
                        
                        -- 7. Возвращаемся на оригинальную позицию
                        rootPart.CFrame = originalCFrame
                    end
                else
                    -- Если цель уже умерла, просто возвращаемся
                    rootPart.CFrame = originalCFrame
                end
                
                -- Сбрасываем состояние
                MainModule.HNS.LastSpikeKillTime = tick()
                MainModule.HNS.IsInSpikeKillProcess = false
                
                -- Проверяем умер ли таргет, если умер - сбрасываем
                if not nearestHider.Character or not nearestHider.Character:FindFirstChildOfClass("Humanoid") or 
                   nearestHider.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
                    MainModule.HNS.CurrentSpikeKillTarget = nil
                end
            end
        end)
    else
        -- Сбрасываем состояние
        MainModule.HNS.CurrentSpikeKillTarget = nil
        MainModule.HNS.IsInSpikeKillProcess = false
        MainModule.HNS.OriginalSpikeKillPosition = nil
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
                        
                        -- Если это наш текущий таргет или новый ближайший в радиусе 100
                        if (MainModule.HNS.CurrentKillTarget and player == MainModule.HNS.CurrentKillTarget) or 
                           (distance < nearestDistance and distance < 100) then
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
                
                -- Поворачиваемся к цели
                local direction = (targetRootPart.Position - rootPart.Position).Unit
                local lookVector = Vector3.new(direction.X, 0, direction.Z)
                if lookVector.Magnitude > 0 then
                    rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + lookVector)
                end
                
                -- Если близко, телепортируемся за спину
                if nearestDistance > 3 then
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
                    local virtualInputManager = game:GetService("VirtualInputManager")
                    pcall(function()
                        virtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        task.wait(0.05)
                        virtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
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

-- HNS Auto Dodge функция
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
            
            -- Проверяем кулдаун
            if currentTime - MainModule.HNS.LastDodgeTime < MainModule.HNS.DodgeCooldown then
                return
            end
            
            local character = LocalPlayer.Character
            if not character then return end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            
            if not rootPart or not humanoid or humanoid.Health <= 0 then return end
            
            -- Ищем ближайших ищущих с ножом в радиусе 10
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local targetCharacter = player.Character
                    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
                    local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
                    
                    if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                        local distance = (rootPart.Position - targetRoot.Position).Magnitude
                        
                        -- Проверяем расстояние (10 метров)
                        if distance <= MainModule.HNS.DodgeRange then
                            -- Проверяем, держит ли он нож (Knife или Fork)
                            local hasKnife = false
                            local knifeTool = nil
                            
                            -- Проверяем в руках персонажа
                            for _, tool in pairs(targetCharacter:GetChildren()) do
                                if tool:IsA("Tool") then
                                    local toolName = tool.Name:lower()
                                    if toolName:find("knife") or toolName:find("fork") or toolName:find("dagger") or toolName:find("нож") then
                                        hasKnife = true
                                        knifeTool = tool
                                        break
                                    end
                                end
                            end
                            
                            -- Проверяем в Backpack
                            if not hasKnife and player:FindFirstChild("Backpack") then
                                for _, tool in pairs(player.Backpack:GetChildren()) do
                                    if tool:IsA("Tool") then
                                        local toolName = tool.Name:lower()
                                        if toolName:find("knife") or toolName:find("fork") or toolName:find("dagger") or toolName:find("нож") then
                                            hasKnife = true
                                            knifeTool = tool
                                            break
                                        end
                                    end
                                end
                            end
                            
                            if hasKnife and knifeTool then
                                -- Проверяем, смотрит ли он на нас
                                local directionToUs = (rootPart.Position - targetRoot.Position).Unit
                                local lookDirection = targetRoot.CFrame.LookVector
                                local dotProduct = directionToUs:Dot(lookDirection)
                                
                                -- Если ищущий смотрит на нас и близко (менее 3 метров)
                                if dotProduct > 0.7 and distance < 3 then
                                    -- Проверяем активность ножа (анимация атаки)
                                    local isAttacking = false
                                    
                                    -- Проверяем хитбоксы ножа
                                    if currentTime - MainModule.LastKnifeHitboxCheck > MainModule.KnifeHitboxCheckRate then
                                        -- Ищем хитбоксы ножа в Workspace
                                        for _, obj in pairs(Workspace:GetDescendants()) do
                                            if obj:IsA("BasePart") and obj.Name:lower():find("hitbox") and obj.Name:lower():find("knife") then
                                                -- Проверяем расстояние до хитбокса
                                                local hitboxDistance = (rootPart.Position - obj.Position).Magnitude
                                                if hitboxDistance < 5 then
                                                    isAttacking = true
                                                    break
                                                end
                                            end
                                        end
                                        MainModule.LastKnifeHitboxCheck = currentTime
                                    end
                                    
                                    -- Если идет атака или мы очень близко
                                    if isAttacking or distance < 2 then
                                        -- Доджим нажатием клавиши 1
                                        pcall(function()
                                            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.One, false, game)
                                            task.wait(0.05)
                                            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.One, false, game)
                                        end)
                                        
                                        -- Телепортируемся немного в сторону
                                        local randomAngle = math.random() * 2 * math.pi
                                        local teleportDistance = 4
                                        local offset = Vector3.new(
                                            math.cos(randomAngle) * teleportDistance,
                                            0,
                                            math.sin(randomAngle) * teleportDistance
                                        )
                                        
                                        local newPosition = rootPart.Position + offset
                                        rootPart.CFrame = CFrame.new(newPosition)
                                        
                                        MainModule.HNS.LastDodgeTime = tick()
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
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
    
    if antiFallGlassBridgeConnection then
        antiFallGlassBridgeConnection:Disconnect()
        antiFallGlassBridgeConnection = nil
    end
    
    if enabled then
        -- Удаляем воду/синий цвет
        MainModule.RemoveGlassBridgeWater()
        
        -- Создаем Anti-Fall платформу
        MainModule.CreateGlassBridgeAntiFallPlatform()
        
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
        
        -- Anti-Fall для Glass Bridge
        antiFallGlassBridgeConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.GlassBridge.AntiBreak then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if not rootPart then return end
                
                -- Если упали ниже высоты 500 в Glass Bridge
                if rootPart.Position.Y < 500 then
                    rootPart.CFrame = CFrame.new(-200, 525, -1534)
                end
            end)
        end)
    else
        -- Удаляем платформу
        MainModule.RemoveGlassBridgeAntiFallPlatform()
    end
end

function MainModule.RemoveGlassBridgeWater()
    -- Удаляем воду/синий цвет
    pcall(function()
        local glassBridge = Workspace:FindFirstChild("GlassBridge")
        if glassBridge then
            for _, obj in pairs(glassBridge:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.Name:lower():find("water") or obj.Name:lower():find("blue") or obj.Color == Color3.fromRGB(0, 0, 255)) then
                    obj.Transparency = 1
                    obj.CanTouch = false
                end
            end
        end
        MainModule.GlassBridge.WaterRemoved = true
    end)
end

function MainModule.CreateGlassBridgeAntiFallPlatform()
    if MainModule.GlassBridge.AntiFallPlatform then
        SafeDestroy(MainModule.GlassBridge.AntiFallPlatform)
        MainModule.GlassBridge.AntiFallPlatform = nil
    end
    
    -- Создаем прозрачную Anti-Fall платформу
    MainModule.GlassBridge.AntiFallPlatform = Instance.new("Part")
    MainModule.GlassBridge.AntiFallPlatform.Name = "GlassBridgeAntiFallPlatform"
    MainModule.GlassBridge.AntiFallPlatform.Size = Vector3.new(200, 5, 200)
    MainModule.GlassBridge.AntiFallPlatform.Position = Vector3.new(-200, 515, -1534)
    MainModule.GlassBridge.AntiFallPlatform.Anchored = true
    MainModule.GlassBridge.AntiFallPlatform.CanCollide = true
    MainModule.GlassBridge.AntiFallPlatform.Transparency = 1  -- Полностью прозрачная
    MainModule.GlassBridge.AntiFallPlatform.Material = Enum.Material.Plastic
    MainModule.GlassBridge.AntiFallPlatform.Color = Color3.fromRGB(255, 255, 255)
    MainModule.GlassBridge.AntiFallPlatform.Parent = Workspace
end

function MainModule.RemoveGlassBridgeAntiFallPlatform()
    if MainModule.GlassBridge.AntiFallPlatform then
        SafeDestroy(MainModule.GlassBridge.AntiFallPlatform)
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
                            local targetColor = Color3.fromRGB(163, 162, 165) -- Оригинальный цвет
                            
                            if not MainModule.GlassBridge.AntiBreak then
                                -- Если AntiBreak выключен, показываем реальные цвета
                                targetColor = isBreakable and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                            else
                                -- Если AntiBreak включен, показываем все стекла как безопасные
                                targetColor = Color3.fromRGB(0, 255, 0)
                            end

                            for _, part in pairs(tileModel:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.Color = targetColor
                                    part.Transparency = 0.3
                                    part.Material = Enum.Material.Glass
                                end
                            end
                        end
                    end
                end
            end)
        end
        
        -- Однократное применение ESP
        updateGlassESP()
        
        -- Обновляем при изменениях
        glassBridgeESPConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.GlassBridge.GlassESPEnabled then return end
            updateGlassESP()
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

-- Jump Rope Anti Fall
function MainModule.ToggleJumpRopeAntiFall(enabled)
    if antiFallJumpRopeConnection then
        antiFallJumpRopeConnection:Disconnect()
        antiFallJumpRopeConnection = nil
    end
    
    if enabled then
        -- Создаем Anti-Fall платформу для Jump Rope
        MainModule.CreateJumpRopeAntiFallPlatform()
        
        antiFallJumpRopeConnection = RunService.Heartbeat:Connect(function()
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if not rootPart then return end
                
                -- Если упали ниже высоты 180 в Jump Rope
                if rootPart.Position.Y < 180 then
                    rootPart.CFrame = CFrame.new(737.156372, 193.805084, 920.952515)
                end
            end)
        end)
    else
        -- Удаляем платформу
        MainModule.RemoveJumpRopeAntiFallPlatform()
    end
end

function MainModule.CreateJumpRopeAntiFallPlatform()
    if MainModule.JumpRope.AntiFallPlatform then
        SafeDestroy(MainModule.JumpRope.AntiFallPlatform)
        MainModule.JumpRope.AntiFallPlatform = nil
    end
    
    -- Создаем прозрачную Anti-Fall платформу для Jump Rope
    MainModule.JumpRope.AntiFallPlatform = Instance.new("Part")
    MainModule.JumpRope.AntiFallPlatform.Name = "JumpRopeAntiFallPlatform"
    MainModule.JumpRope.AntiFallPlatform.Size = Vector3.new(100, 5, 100)
    MainModule.JumpRope.AntiFallPlatform.Position = Vector3.new(737.156372, 188.805084, 920.952515)
    MainModule.JumpRope.AntiFallPlatform.Anchored = true
    MainModule.JumpRope.AntiFallPlatform.CanCollide = true
    MainModule.JumpRope.AntiFallPlatform.Transparency = 1  -- Полностью прозрачная
    MainModule.JumpRope.AntiFallPlatform.Material = Enum.Material.Plastic
    MainModule.JumpRope.AntiFallPlatform.Color = Color3.fromRGB(255, 255, 255)
    MainModule.JumpRope.AntiFallPlatform.Parent = Workspace
end

function MainModule.RemoveJumpRopeAntiFallPlatform()
    if MainModule.JumpRope.AntiFallPlatform then
        SafeDestroy(MainModule.JumpRope.AntiFallPlatform)
        MainModule.JumpRope.AntiFallPlatform = nil
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
            SafeDestroy(MainModule.SkySquid.AntiFallPlatform)
            MainModule.SkySquid.AntiFallPlatform = nil
        end
    end
end

function MainModule.CreateSkySquidAntiFallPlatform()
    if MainModule.SkySquid.AntiFallPlatform then
        SafeDestroy(MainModule.SkySquid.AntiFallPlatform)
        MainModule.SkySquid.AntiFallPlatform = nil
    end
    
    -- Создаем прозрачную Anti-Fall платформу для Sky Squid
    MainModule.SkySquid.AntiFallPlatform = Instance.new("Part")
    MainModule.SkySquid.AntiFallPlatform.Name = "SkySquidAntiFallPlatform"
    MainModule.SkySquid.AntiFallPlatform.Size = Vector3.new(500, 5, 500)
    MainModule.SkySquid.AntiFallPlatform.Position = Vector3.new(0, 90, 0)
    MainModule.SkySquid.AntiFallPlatform.Anchored = true
    MainModule.SkySquid.AntiFallPlatform.CanCollide = true
    MainModule.SkySquid.AntiFallPlatform.Transparency = 1  -- Полностью прозрачная
    MainModule.SkySquid.AntiFallPlatform.Material = Enum.Material.Plastic
    MainModule.SkySquid.AntiFallPlatform.Color = Color3.fromRGB(255, 255, 255)
    MainModule.SkySquid.AntiFallPlatform.Parent = Workspace
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
            SafeDestroy(MainModule.SkySquid.SafePlatform)
            MainModule.SkySquid.SafePlatform = nil
        end
    end
end

function MainModule.CreateSkySquidSafePlatform()
    if MainModule.SkySquid.SafePlatform then
        SafeDestroy(MainModule.SkySquid.SafePlatform)
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

-- Anti Stun + Anti Ragdoll функция (исправленная)
function MainModule.ToggleAntiStunRagdoll(enabled)
    MainModule.Misc.AntiStunRagdoll = enabled
    
    if antiStunRagdollConnection then
        antiStunRagdollConnection:Disconnect()
        antiStunRagdollConnection = nil
    end
    
    if enabled then
        antiStunRagdollConnection = RunService.Stepped:Connect(function()
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
                
                -- Убираем дебаффы
                for _, v in pairs(character:GetDescendants()) do
                    if v:IsA("StringValue") or v:IsA("BoolValue") then
                        if v.Name:lower():find("stun") or v.Name:lower():find("ragdoll") or v.Name:lower():find("injured") then
                            v:Destroy()
                        end
                    end
                end
            end)
        end)
    end
end

-- Remove Injured функция
function MainModule.ToggleRemoveInjured(enabled)
    MainModule.Misc.RemoveInjuredEnabled = enabled
    
    if removeInjuredConnection then
        removeInjuredConnection:Disconnect()
        removeInjuredConnection = nil
    end
    
    if enabled then
        local function RemoveInjuredEffects()
            local character = LocalPlayer.Character
            if not character then return end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            
            -- Удаляем эффекты из персонажа
            for _, obj in pairs(character:GetDescendants()) do
                if obj.Name == "InjuredWalking" or obj.Name:lower():find("injured") then
                    obj:Destroy()
                end
            end
            
            -- Восстанавливаем скорость
            if humanoid.WalkSpeed < 16 then
                humanoid.WalkSpeed = 16
            end
        end
        
        removeInjuredConnection = RunService.Heartbeat:Connect(function()
            if MainModule.Misc.RemoveInjuredEnabled then
                RemoveInjuredEffects()
            end
        end)
    end
end

-- Remove Stun функция
function MainModule.ToggleRemoveStun(enabled)
    MainModule.Misc.RemoveStunEnabled = enabled
end

-- Unlock Dash функция (Don't work)
function MainModule.ToggleUnlockDash(enabled)
    MainModule.Misc.UnlockDashEnabled = enabled
    if enabled then
        warn("Unlock Dash: Don't work (Coming Soon)")
    end
end

-- Unlock Phantom Step функция (Don't work)
function MainModule.ToggleUnlockPhantomStep(enabled)
    MainModule.Misc.UnlockPhantomStepEnabled = enabled
    if enabled then
        warn("Unlock Phantom Step: Don't work (Coming Soon)")
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
                            -- Сохраняем оригинальное значение
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
                                    -- Сохраняем оригинальное значение
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
            
            local character = LocalPlayer.Character
            if character then
                for _, tool in pairs(character:GetChildren()) do
                    if tool:IsA("Tool") then
                        for _, obj in pairs(tool:GetDescendants()) do
                            if obj:IsA("NumberValue") then
                                if obj.Name:lower():find("ammo") or 
                                   obj.Name:lower():find("bullet") or
                                   obj.Name:lower():find("clip") or
                                   obj.Name:lower():find("патрон") then
                                    -- Сохраняем оригинальное значение
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
        -- Восстанавливаем исходные значения
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

-- Hitbox Expander функция (исправленная без лагов)
function MainModule.ToggleHitboxExpander(enabled)
    MainModule.Guards.HitboxExpander = enabled
    
    if hitboxConnection then
        hitboxConnection:Disconnect()
        hitboxConnection = nil
    end
    
    if enabled then
        local HITBOX_SIZE = 10  -- Уменьшил размер для оптимизации
        
        hitboxConnection = RunService.Stepped:Connect(function()
            if not MainModule.Guards.HitboxExpander then 
                -- Восстанавливаем оригинальные размеры при выключении
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
                        -- Сохраняем оригинальные размеры если еще не сохранены
                        if not MainModule.Guards.OriginalHitboxes[player] then
                            MainModule.Guards.OriginalHitboxes[player] = {}
                            
                            -- Сохраняем размеры только HumanoidRootPart для оптимизации
                            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                            if rootPart and rootPart:IsA("BasePart") then
                                MainModule.Guards.OriginalHitboxes[player]["HumanoidRootPart"] = rootPart.Size
                            end
                        end
                        
                        -- Увеличиваем размер только HumanoidRootPart
                        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                        if rootPart and rootPart:IsA("BasePart") then
                            -- Восстанавливаем оригинальный размер перед изменением
                            if MainModule.Guards.OriginalHitboxes[player] and MainModule.Guards.OriginalHitboxes[player]["HumanoidRootPart"] then
                                rootPart.Size = Vector3.new(HITBOX_SIZE, HITBOX_SIZE, HITBOX_SIZE)
                                -- Не меняем прозрачность и коллизию чтобы игроки могли двигаться
                                rootPart.CanCollide = true
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

-- Функция для получения координат
function MainModule.GetPlayerPosition()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local position = character.HumanoidRootPart.Position
        return string.format("X: %.1f, Y: %.1f, Z: %.1f", position.X, position.Y, position.Z)
    end
    return "Не доступно"
end

-- Вспомогательная функция задержки
local function delay(seconds, callback)
    task.spawn(function()
        task.wait(seconds)
        pcall(callback)
    end)
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
        skySquidVoidKillConnection, removeInjuredConnection, unlockDashConnection,
        unlockPhantomStepConnection, antiFallGlassBridgeConnection, antiFallJumpRopeConnection
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
    
    -- Очищаем ESP
    if MainModule.Misc.ESPEnabled then
        MainModule.ToggleESP(false)
    end
    
    -- Удаляем папку ESP
    if MainModule.ESPFolder then
        SafeDestroy(MainModule.ESPFolder)
        MainModule.ESPFolder = nil
    end
    
    -- Удаляем Glass Bridge объекты
    if MainModule.GlassBridgeCover then
        SafeDestroy(MainModule.GlassBridgeCover)
        MainModule.GlassBridgeCover = nil
    end
    
    if MainModule.GlassBridge.AntiFallPlatform then
        SafeDestroy(MainModule.GlassBridge.AntiFallPlatform)
        MainModule.GlassBridge.AntiFallPlatform = nil
    end
    
    -- Удаляем Jump Rope объекты
    if MainModule.JumpRope.AntiFallPlatform then
        SafeDestroy(MainModule.JumpRope.AntiFallPlatform)
        MainModule.JumpRope.AntiFallPlatform = nil
    end
    
    -- Удаляем Sky Squid объекты
    if MainModule.SkySquid.AntiFallPlatform then
        SafeDestroy(MainModule.SkySquid.AntiFallPlatform)
        MainModule.SkySquid.AntiFallPlatform = nil
    end
    
    if MainModule.SkySquid.SafePlatform then
        SafeDestroy(MainModule.SkySquid.SafePlatform)
        MainModule.SkySquid.SafePlatform = nil
    end
    
    -- Восстанавливаем шипы
    if MainModule.HNS.DisableSpikes then
        MainModule.ToggleDisableSpikes(false)
    end
    
    -- Удаляем Glass Bridge защитные платформы
    for _, platform in pairs(MainModule.GlassBridgePlatforms) do
        if platform and platform.Parent then
            SafeDestroy(platform)
        end
    end
    MainModule.GlassBridgePlatforms = {}
    
    -- Сбрасываем HNS состояния
    MainModule.HNS.CurrentSpikeKillTarget = nil
    MainModule.HNS.IsInSpikeKillProcess = false
    MainModule.HNS.OriginalSpikeKillPosition = nil
    MainModule.HNS.CurrentKillTarget = nil
end

-- Автоматическая очистка при выходе
game:GetService("Players").LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not game:GetService("Players").LocalPlayer.Parent then
        MainModule.Cleanup()
    end
end)

return MainModule
