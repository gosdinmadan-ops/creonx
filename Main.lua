-- Main.lua - Creon X v2.1 (Стабильная версия без крашей)
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

-- Безопасный вызов функций
local function SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[Creon] Error in " .. debug.traceback():match("in function '(.-)'") or "unknown": " .. tostring(result))
        return nil
    end
    return result
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
    LastSpikeKillTime = 0,
    SpikeKillCooldown = 3
}

MainModule.TugOfWar = {
    AutoPull = false
}

MainModule.GlassBridge = {
    AntiBreak = false,
    GlassESPEnabled = false,
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
    ESPBoxes = false, -- Box по умолчанию выключен
    ESPHealth = true,
    ESPFillTransparency = 0.3,
    ESPOutlineTransparency = 0,
    ESPTextSize = 14,
    AntiStunRagdoll = false,
    UnlockDash = false,
    UnlockPhantomStep = false,
    AntiStun = false,
    AntiRagdoll = false,
    ESPUpdateDelay = 0.5 -- Задержка обновления ESP для оптимизации
}

-- ESP System (ОПТИМИЗИРОВАННАЯ, без крашей)
MainModule.ESPTable = {}
MainModule.ESPFolder = nil
MainModule.ESPConnection = nil
MainModule.ESPCache = {}
MainModule.LastESPUpdate = 0

-- Постоянные соединения
local connections = {}
local function AddConnection(name, connection)
    connections[name] = connection
end

local function DisconnectAll()
    for name, conn in pairs(connections) do
        if conn then
            conn:Disconnect()
            connections[name] = nil
        end
    end
end

-- Локальный игрок
local LocalPlayer = Players.LocalPlayer

-- ОПТИМИЗИРОВАННАЯ ESP System (без лагов, без крашей)
function MainModule.ToggleESP(enabled)
    MainModule.Misc.ESPEnabled = enabled
    
    if MainModule.ESPConnection then
        MainModule.ESPConnection:Disconnect()
        MainModule.ESPConnection = nil
    end
    
    -- Очищаем старые ESP
    for _, esp in pairs(MainModule.ESPTable) do
        if esp and type(esp) == "table" and esp.Destroy then
            SafeCall(esp.Destroy)
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
        
        -- Оптимизированное обновление ESP с защитой от крашей
        MainModule.ESPConnection = RunService.Heartbeat:Connect(function()
            local currentTime = tick()
            if currentTime - MainModule.LastESPUpdate < MainModule.Misc.ESPUpdateDelay then
                return
            end
            MainModule.LastESPUpdate = currentTime
            
            SafeCall(function()
                local localCharacter = LocalPlayer.Character
                local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
                
                -- ESP для игроков
                if MainModule.Misc.ESPPlayers then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local character = player.Character
                            local humanoid = character:FindFirstChildOfClass("Humanoid")
                            local rootPart = character:FindFirstChild("HumanoidRootPart")
                            
                            if humanoid and humanoid.Health > 0 and rootPart then
                                local cacheKey = "player_" .. player.UserId
                                
                                if not MainModule.ESPCache[cacheKey] then
                                    -- Создаем Highlight
                                    local highlight = Instance.new("Highlight")
                                    highlight.Name = "ESP_" .. player.Name
                                    highlight.Adornee = character
                                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    
                                    -- Определяем цвет по роли
                                    local isHider = player:GetAttribute("IsHider") or false
                                    local isHunter = player:GetAttribute("IsHunter") or false
                                    
                                    if isHider then
                                        highlight.FillColor = Color3.fromRGB(0, 255, 0)
                                    elseif isHunter then
                                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                                    else
                                        highlight.FillColor = Color3.fromRGB(0, 170, 255)
                                    end
                                    
                                    highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
                                    highlight.OutlineColor = highlight.FillColor
                                    highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
                                    highlight.Enabled = MainModule.Misc.ESPHighlight
                                    highlight.Parent = MainModule.ESPFolder
                                    
                                    MainModule.ESPTable[cacheKey] = {
                                        Highlight = highlight,
                                        Destroy = function()
                                            highlight:Destroy()
                                        end
                                    }
                                    
                                    -- Создаем billboard
                                    if MainModule.Misc.ESPNames then
                                        local billboard = Instance.new("BillboardGui")
                                        billboard.Name = "ESP_Text_" .. player.Name
                                        billboard.Adornee = rootPart
                                        billboard.AlwaysOnTop = true
                                        billboard.Size = UDim2.new(0, 200, 0, 40)
                                        billboard.StudsOffset = Vector3.new(0, 3.5, 0)
                                        billboard.MaxDistance = 500
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
                                        
                                        local infoLabel = Instance.new("TextLabel")
                                        infoLabel.Name = "ESP_Info"
                                        infoLabel.BackgroundTransparency = 1
                                        infoLabel.Size = UDim2.new(1, 0, 0.5, 0)
                                        infoLabel.Position = UDim2.new(0, 0, 0.5, 0)
                                        infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                                        infoLabel.TextSize = MainModule.Misc.ESPTextSize - 2
                                        infoLabel.Font = Enum.Font.Gotham
                                        infoLabel.TextStrokeTransparency = 0
                                        infoLabel.Parent = billboard
                                        
                                        MainModule.ESPTable[cacheKey .. "_text"] = {
                                            Billboard = billboard,
                                            Destroy = function()
                                                billboard:Destroy()
                                            end
                                        }
                                    end
                                    
                                    -- Создаем Box если включено
                                    if MainModule.Misc.ESPBoxes then
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
                                                box:Destroy()
                                            end
                                        }
                                    end
                                    
                                    MainModule.ESPCache[cacheKey] = true
                                end
                                
                                -- Обновляем информацию
                                if MainModule.ESPTable[cacheKey .. "_text"] then
                                    local billboard = MainModule.ESPTable[cacheKey .. "_text"].Billboard
                                    if billboard and billboard:FindFirstChild("ESP_Info") then
                                        local infoText = ""
                                        
                                        if MainModule.Misc.ESPHealth then
                                            infoText = math.floor(humanoid.Health) .. " HP"
                                        end
                                        
                                        if MainModule.Misc.ESPDistance and localRoot then
                                            local distance = math.floor((rootPart.Position - localRoot.Position).Magnitude)
                                            if infoText ~= "" then
                                                infoText = infoText .. " | " .. distance .. "m"
                                            else
                                                infoText = distance .. "m"
                                            end
                                        end
                                        
                                        billboard.ESP_Info.Text = infoText
                                    end
                                end
                            end
                        end
                    end
                end
                
                -- ESP для конфет
                if MainModule.Misc.ESPCandies then
                    local candies = Workspace:FindFirstChild("Candies") or Workspace
                    for _, obj in pairs(candies:GetChildren()) do
                        if obj:IsA("Model") and (obj.Name:lower():find("candy") or obj.Name:lower():find("sweet")) then
                            local cacheKey = "candy_" .. obj.Name
                            
                            if not MainModule.ESPCache[cacheKey] then
                                local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                                if primaryPart then
                                    local highlight = Instance.new("Highlight")
                                    highlight.Name = "ESP_Candy_" .. obj.Name
                                    highlight.Adornee = obj
                                    highlight.FillColor = Color3.fromRGB(255, 105, 180)
                                    highlight.FillTransparency = 0.2
                                    highlight.OutlineColor = Color3.fromRGB(255, 105, 180)
                                    highlight.OutlineTransparency = 0
                                    highlight.Enabled = true
                                    highlight.Parent = MainModule.ESPFolder
                                    
                                    MainModule.ESPTable[cacheKey] = {
                                        Highlight = highlight,
                                        Destroy = function()
                                            highlight:Destroy()
                                        end
                                    }
                                    
                                    MainModule.ESPCache[cacheKey] = true
                                end
                            end
                        end
                    end
                end
                
                -- ESP для ключей
                if MainModule.Misc.ESPKeys then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and obj.Name:lower():find("key") then
                            local cacheKey = "key_" .. obj.Name
                            
                            if not MainModule.ESPCache[cacheKey] then
                                local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                                if primaryPart then
                                    local highlight = Instance.new("Highlight")
                                    highlight.Name = "ESP_Key_" .. obj.Name
                                    highlight.Adornee = obj
                                    highlight.FillColor = Color3.fromRGB(255, 215, 0)
                                    highlight.FillTransparency = 0.2
                                    highlight.OutlineColor = Color3.fromRGB(255, 215, 0)
                                    highlight.OutlineTransparency = 0
                                    highlight.Enabled = true
                                    highlight.Parent = MainModule.ESPFolder
                                    
                                    MainModule.ESPTable[cacheKey] = {
                                        Highlight = highlight,
                                        Destroy = function()
                                            highlight:Destroy()
                                        end
                                    }
                                    
                                    MainModule.ESPCache[cacheKey] = true
                                end
                            end
                        end
                    end
                end
                
                -- ESP для гуардов
                if MainModule.Misc.ESPGuards then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and (obj.Name:lower():find("guard") or 
                           obj.Name:lower():find("circle") or obj.Name:lower():find("triangle") or 
                           obj.Name:lower():find("square")) then
                            local cacheKey = "guard_" .. obj.Name
                            
                            if not MainModule.ESPCache[cacheKey] then
                                local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                                if primaryPart then
                                    local highlight = Instance.new("Highlight")
                                    highlight.Name = "ESP_Guard_" .. obj.Name
                                    highlight.Adornee = obj
                                    highlight.FillColor = Color3.fromRGB(255, 69, 0)
                                    highlight.FillTransparency = 0.3
                                    highlight.OutlineColor = Color3.fromRGB(255, 69, 0)
                                    highlight.OutlineTransparency = 0
                                    highlight.Enabled = true
                                    highlight.Parent = MainModule.ESPFolder
                                    
                                    MainModule.ESPTable[cacheKey] = {
                                        Highlight = highlight,
                                        Destroy = function()
                                            highlight:Destroy()
                                        end
                                    }
                                    
                                    MainModule.ESPCache[cacheKey] = true
                                end
                            end
                        end
                    end
                end
                
                -- ESP для дверей
                if MainModule.Misc.ESPDoors then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and obj.Name:lower():find("door") then
                            local cacheKey = "door_" .. obj.Name
                            
                            if not MainModule.ESPCache[cacheKey] then
                                local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                                if primaryPart then
                                    local highlight = Instance.new("Highlight")
                                    highlight.Name = "ESP_Door_" .. obj.Name
                                    highlight.Adornee = obj
                                    highlight.FillColor = Color3.fromRGB(147, 112, 219)
                                    highlight.FillTransparency = 0.4
                                    highlight.OutlineColor = Color3.fromRGB(147, 112, 219)
                                    highlight.OutlineTransparency = 0
                                    highlight.Enabled = true
                                    highlight.Parent = MainModule.ESPFolder
                                    
                                    MainModule.ESPTable[cacheKey] = {
                                        Highlight = highlight,
                                        Destroy = function()
                                            highlight:Destroy()
                                        end
                                    }
                                    
                                    MainModule.ESPCache[cacheKey] = true
                                end
                            end
                        end
                    end
                end
                
                -- Очистка старых ESP объектов
                for cacheKey, _ in pairs(MainModule.ESPCache) do
                    local espData = MainModule.ESPTable[cacheKey]
                    if espData and espData.Highlight and not espData.Highlight.Adornee then
                        SafeCall(espData.Destroy)
                        MainModule.ESPTable[cacheKey] = nil
                        MainModule.ESPCache[cacheKey] = nil
                    end
                end
            end)
        end)
    else
        -- Очищаем все ESP
        for _, esp in pairs(MainModule.ESPTable) do
            if esp and type(esp) == "table" and esp.Destroy then
                SafeCall(esp.Destroy)
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
    
    if setting == "ESPBoxes" and MainModule.Misc.ESPEnabled then
        -- Удаляем или добавляем Box ESP
        for cacheKey, espData in pairs(MainModule.ESPTable) do
            if cacheKey:find("_box") then
                if value then
                    -- Нужно создать Box, но сделаем это при следующем обновлении ESP
                else
                    -- Удаляем Box
                    if espData and espData.Destroy then
                        SafeCall(espData.Destroy)
                        MainModule.ESPTable[cacheKey] = nil
                    end
                end
            end
        end
    end
end

-- Jump Rope функции
function MainModule.TeleportToJumpRopeEnd()
    SafeCall(function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(737.156372, 193.805084, 920.952515)
        end
    end)
end

function MainModule.DeleteJumpRope()
    SafeCall(function()
        local effects = Workspace:FindFirstChild("Effects")
        if effects then
            local rope = effects:FindFirstChild("rope")
            if rope then
                rope:Destroy()
            end
        end
    end)
end

-- HNS функции
function MainModule.ToggleSpikesKill(enabled)
    MainModule.HNS.SpikesKill = enabled
    print("Spikes Kill: " .. (enabled and "Enabled" or "Disabled"))
end

function MainModule.ToggleDisableSpikes(enabled)
    MainModule.HNS.DisableSpikes = enabled
    
    SafeCall(function()
        local hideAndSeekMap = Workspace:FindFirstChild("HideAndSeekMap")
        if hideAndSeekMap then
            local killingParts = hideAndSeekMap:FindFirstChild("KillingParts")
            if killingParts then
                for _, spike in pairs(killingParts:GetChildren()) do
                    if spike:IsA("BasePart") then
                        spike.CanTouch = not enabled
                        spike.Transparency = enabled and 1 or 0
                    end
                end
            end
        end
    end)
end

function MainModule.ToggleKillHiders(enabled)
    MainModule.HNS.KillHiders = enabled
    print("Kill Hiders: " .. (enabled and "Enabled" or "Disabled"))
end

function MainModule.ToggleAutoDodge(enabled)
    MainModule.HNS.AutoDodge = enabled
    print("Auto Dodge: " .. (enabled and "Enabled" or "Disabled"))
end

-- Glass Bridge функции
function MainModule.ToggleAntiBreak(enabled)
    MainModule.GlassBridge.AntiBreak = enabled
    
    if connections["antiBreak"] then
        connections["antiBreak"]:Disconnect()
        connections["antiBreak"] = nil
    end
    
    SafeCall(function()
        local glassBridge = Workspace:FindFirstChild("GlassBridge")
        if glassBridge then
            local glassHolder = glassBridge:FindFirstChild("GlassHolder")
            if glassHolder then
                for _, tilePair in pairs(glassHolder:GetChildren()) do
                    for _, tileModel in pairs(tilePair:GetChildren()) do
                        if tileModel:IsA("Model") and tileModel.PrimaryPart then
                            for _, part in pairs(tileModel:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = enabled
                                    part.Transparency = enabled and 0.3 or 0
                                    part.Color = enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(163, 162, 165)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

function MainModule.ToggleGlassBridgeESP(enabled)
    MainModule.GlassBridge.GlassESPEnabled = enabled
    
    if connections["glassBridgeESP"] then
        connections["glassBridgeESP"]:Disconnect()
        connections["glassBridgeESP"] = nil
    end
    
    SafeCall(function()
        local glassBridge = Workspace:FindFirstChild("GlassBridge")
        if glassBridge then
            local glassHolder = glassBridge:FindFirstChild("GlassHolder")
            if glassHolder then
                for _, tilePair in pairs(glassHolder:GetChildren()) do
                    for _, tileModel in pairs(tilePair:GetChildren()) do
                        if tileModel:IsA("Model") and tileModel.PrimaryPart then
                            for _, part in pairs(tileModel:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    if enabled then
                                        local isBreakable = tileModel.PrimaryPart:GetAttribute("exploitingisevil") == true
                                        part.Color = isBreakable and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                                        part.Transparency = 0.3
                                        part.Material = Enum.Material.Neon
                                    else
                                        part.Color = Color3.fromRGB(163, 162, 165)
                                        part.Transparency = 0
                                        part.Material = Enum.Material.Glass
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- Sky Squid функции
function MainModule.ToggleSkySquidAntiFall(enabled)
    MainModule.SkySquid.AntiFall = enabled
    
    if connections["skySquidAntiFall"] then
        connections["skySquidAntiFall"]:Disconnect()
        connections["skySquidAntiFall"] = nil
    end
    
    SafeCall(function()
        if enabled then
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
            
            connections["skySquidAntiFall"] = RunService.Heartbeat:Connect(function()
                SafeCall(function()
                    local character = LocalPlayer.Character
                    if character then
                        local rootPart = character:FindFirstChild("HumanoidRootPart")
                        if rootPart and rootPart.Position.Y < 50 then
                            rootPart.CFrame = CFrame.new(0, 200, 0)
                        end
                    end
                end)
            end)
        else
            if MainModule.SkySquid.AntiFallPlatform then
                MainModule.SkySquid.AntiFallPlatform:Destroy()
                MainModule.SkySquid.AntiFallPlatform = nil
            end
        end
    end)
end

function MainModule.ToggleSkySquidVoidKill(enabled)
    MainModule.SkySquid.VoidKill = enabled
    
    if connections["skySquidVoidKill"] then
        connections["skySquidVoidKill"]:Disconnect()
        connections["skySquidVoidKill"] = nil
    end
    
    if enabled then
        connections["skySquidVoidKill"] = RunService.Heartbeat:Connect(function()
            SafeCall(function()
                local character = LocalPlayer.Character
                if character then
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
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
                    end
                end
            end)
        end)
    end
end

-- Функции скорости
function MainModule.ToggleSpeedHack(enabled)
    MainModule.SpeedHack.Enabled = enabled
    
    if connections["speedHack"] then
        connections["speedHack"]:Disconnect()
        connections["speedHack"] = nil
    end
    
    SafeCall(function()
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                MainModule.SpeedHack.DefaultSpeed = humanoid.WalkSpeed
            end
        end
    end)
    
    if enabled then
        connections["speedHack"] = RunService.Heartbeat:Connect(function()
            SafeCall(function()
                local character = LocalPlayer.Character
                if character and MainModule.SpeedHack.Enabled then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.WalkSpeed = MainModule.SpeedHack.CurrentSpeed
                    end
                end
            end)
        end)
    else
        SafeCall(function()
            local character = LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = MainModule.SpeedHack.DefaultSpeed
                end
            end
        end)
    end
end

function MainModule.SetSpeed(value)
    value = math.clamp(value, MainModule.SpeedHack.MinSpeed, MainModule.SpeedHack.MaxSpeed)
    MainModule.SpeedHack.CurrentSpeed = value
    
    SafeCall(function()
        if MainModule.SpeedHack.Enabled then
            local character = LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = value
                end
            end
        end
    end)
    
    return value
end

-- Функции телепортации
function MainModule.TeleportUp100()
    SafeCall(function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame + Vector3.new(0, 100, 0)
        end
    end)
end

function MainModule.TeleportDown40()
    SafeCall(function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame + Vector3.new(0, -40, 0)
        end
    end)
end

-- Anti Stun функция
function MainModule.ToggleAntiStun(enabled)
    MainModule.Misc.AntiStun = enabled
    
    if connections["antiStun"] then
        connections["antiStun"]:Disconnect()
        connections["antiStun"] = nil
    end
    
    if enabled then
        connections["antiStun"] = RunService.Heartbeat:Connect(function()
            SafeCall(function()
                local character = LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        -- Восстанавливаем из стана
                        if humanoid:GetState() == Enum.HumanoidStateType.Stunned then
                            humanoid:ChangeState(Enum.HumanoidStateType.Running)
                        end
                        
                        -- Восстанавливаем скорость
                        if humanoid.WalkSpeed < 16 then
                            humanoid.WalkSpeed = 16
                        end
                        
                        -- Удаляем эффекты стана
                        for _, obj in pairs(character:GetDescendants()) do
                            if obj.Name:lower():find("stun") then
                                obj:Destroy()
                            end
                        end
                    end
                end
            end)
        end)
    end
end

-- Anti Ragdoll функция
function MainModule.ToggleAntiRagdoll(enabled)
    MainModule.Misc.AntiRagdoll = enabled
    
    if connections["antiRagdoll"] then
        connections["antiRagdoll"]:Disconnect()
        connections["antiRagdoll"] = nil
    end
    
    if enabled then
        connections["antiRagdoll"] = RunService.Heartbeat:Connect(function()
            SafeCall(function()
                local character = LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        -- Восстанавливаем из рагдолла
                        if humanoid:GetState() == Enum.HumanoidStateType.Ragdoll or 
                           humanoid:GetState() == Enum.HumanoidStateType.FallingDown then
                            humanoid:ChangeState(Enum.HumanoidStateType.Running)
                        end
                    end
                end
            end)
        end)
    end
end

-- Убрать старую функцию
function MainModule.ToggleAntiStunRagdoll(enabled)
    MainModule.Misc.AntiStunRagdoll = false
    print("Use separate Anti Stun and Anti Ragdoll functions")
end

-- Rebel функция
function MainModule.ToggleRebel(enabled)
    MainModule.Rebel.Enabled = enabled
end

-- RLGL функции
function MainModule.TeleportToEnd()
    SafeCall(function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(-214.4, 1023.1, 146.7)
        end
    end)
end

function MainModule.TeleportToStart()
    SafeCall(function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(-55.3, 1023.1, -545.8)
        end
    end)
end

function MainModule.ToggleGodMode(enabled)
    MainModule.RLGL.GodMode = enabled
    
    if enabled then
        SafeCall(function()
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                MainModule.RLGL.OriginalHeight = character.HumanoidRootPart.Position.Y
                character.HumanoidRootPart.CFrame = CFrame.new(
                    character.HumanoidRootPart.Position.X, 
                    1184.9, 
                    character.HumanoidRootPart.Position.Z
                )
            end
        end)
    else
        SafeCall(function()
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") and MainModule.RLGL.OriginalHeight then
                character.HumanoidRootPart.CFrame = CFrame.new(
                    character.HumanoidRootPart.Position.X, 
                    MainModule.RLGL.OriginalHeight, 
                    character.HumanoidRootPart.Position.Z
                )
            end
        end)
    end
end

-- Guards функции
function MainModule.SetGuardType(guardType)
    MainModule.Guards.SelectedGuard = guardType
end

function MainModule.SpawnAsGuard()
    SafeCall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local guardRemote = remotes:FindFirstChild("PlayableGuardRemote")
            if guardRemote then
                guardRemote:FireServer({
                    AttemptToSpawnAsGuard = MainModule.Guards.SelectedGuard
                })
            end
        end
    end)
end

function MainModule.ToggleAutoFarm(enabled)
    MainModule.Guards.AutoFarm = enabled
    
    if connections["autoFarm"] then
        connections["autoFarm"]:Disconnect()
        connections["autoFarm"] = nil
    end
    
    if enabled then
        connections["autoFarm"] = RunService.Heartbeat:Connect(function()
            SafeCall(function()
                local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                if remotes and MainModule.Guards.AutoFarm then
                    local videoGameRemote = remotes:FindFirstChild("VideoGameRemote")
                    if videoGameRemote then
                        videoGameRemote:FireServer("GameOver", 4450)
                    end
                end
            end)
        end)
    end
end

-- Rapid Fire функция
function MainModule.ToggleRapidFire(enabled)
    MainModule.Guards.RapidFire = enabled
    
    if connections["rapidFire"] then
        connections["rapidFire"]:Disconnect()
        connections["rapidFire"] = nil
    end
    
    if enabled then
        connections["rapidFire"] = RunService.Heartbeat:Connect(function()
            SafeCall(function()
                local weapons = ReplicatedStorage:FindFirstChild("Weapons")
                if weapons then
                    local guns = weapons:FindFirstChild("Guns")
                    if guns then
                        for _, obj in pairs(guns:GetDescendants()) do
                            if obj.Name == "FireRateCD" and (obj:IsA("NumberValue") or obj:IsA("IntValue")) then
                                if not MainModule.Guards.OriginalFireRates[obj] then
                                    MainModule.Guards.OriginalFireRates[obj] = obj.Value
                                end
                                obj.Value = 0
                            end
                        end
                    end
                end
            end)
        end)
    else
        SafeCall(function()
            for obj, originalValue in pairs(MainModule.Guards.OriginalFireRates) do
                if obj and obj.Parent then
                    obj.Value = originalValue
                end
            end
        end)
    end
end

-- Infinite Ammo функция
function MainModule.ToggleInfiniteAmmo(enabled)
    MainModule.Guards.InfiniteAmmo = enabled
    
    if connections["infiniteAmmo"] then
        connections["infiniteAmmo"]:Disconnect()
        connections["infiniteAmmo"] = nil
    end
    
    if enabled then
        connections["infiniteAmmo"] = RunService.Heartbeat:Connect(function()
            SafeCall(function()
                local character = LocalPlayer.Character
                if character then
                    for _, tool in pairs(character:GetChildren()) do
                        if tool:IsA("Tool") then
                            for _, obj in pairs(tool:GetDescendants()) do
                                if obj:IsA("NumberValue") and obj.Name:lower():find("ammo") then
                                    if not MainModule.Guards.OriginalAmmo[obj] then
                                        MainModule.Guards.OriginalAmmo[obj] = obj.Value
                                    end
                                    obj.Value = 999
                                end
                            end
                        end
                    end
                end
            end)
        end)
    else
        SafeCall(function()
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
    
    if connections["hitboxExpander"] then
        connections["hitboxExpander"]:Disconnect()
        connections["hitboxExpander"] = nil
    end
    
    -- Восстанавливаем оригинальные размеры
    SafeCall(function()
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
    end)
    
    MainModule.Guards.OriginalHitboxes = {}
    
    if enabled then
        connections["hitboxExpander"] = RunService.Heartbeat:Connect(function()
            SafeCall(function()
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local character = player.Character
                        
                        -- Сохраняем оригинальные размеры
                        if not MainModule.Guards.OriginalHitboxes[player] then
                            MainModule.Guards.OriginalHitboxes[player] = {}
                            
                            local parts = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"}
                            for _, partName in ipairs(parts) do
                                local part = character:FindFirstChild(partName)
                                if part and part:IsA("BasePart") then
                                    MainModule.Guards.OriginalHitboxes[player][partName] = part.Size
                                end
                            end
                        end
                        
                        -- Увеличиваем хитбоксы
                        local parts = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"}
                        for _, partName in ipairs(parts) do
                            local part = character:FindFirstChild(partName)
                            if part and part:IsA("BasePart") then
                                part.Size = Vector3.new(5, 5, 5)
                                part.Transparency = 0.8
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end)
        end)
    else
        SafeCall(function()
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
    print("Dalgona Complete: Not implemented")
end

function MainModule.FreeLighter()
    LocalPlayer:SetAttribute("HasLighter", true)
end

-- Tug Of War функции
function MainModule.ToggleAutoPull(enabled)
    MainModule.TugOfWar.AutoPull = enabled
    
    if connections["autoPull"] then
        connections["autoPull"]:Disconnect()
        connections["autoPull"] = nil
    end
    
    if enabled then
        connections["autoPull"] = RunService.Heartbeat:Connect(function()
            SafeCall(function()
                if MainModule.TugOfWar.AutoPull then
                    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                    if remotes then
                        local tempRemote = remotes:FindFirstChild("TemporaryReachedBindable")
                        if tempRemote then
                            tempRemote:FireServer({ IHateYou = true })
                        end
                    end
                    wait(0.25)
                end
            end)
        end)
    end
end

-- Misc функции
function MainModule.ToggleInstaInteract(enabled)
    MainModule.Misc.InstaInteract = enabled
    
    if connections["instaInteract"] then
        connections["instaInteract"]:Disconnect()
        connections["instaInteract"] = nil
    end
    
    if enabled then
        connections["instaInteract"] = Workspace.DescendantAdded:Connect(function(obj)
            SafeCall(function()
                if obj:IsA("ProximityPrompt") then
                    obj.HoldDuration = 0
                end
            end)
        end)
        
        SafeCall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    obj.HoldDuration = 0
                end
            end
        end)
    end
end

function MainModule.ToggleNoCooldownProximity(enabled)
    MainModule.Misc.NoCooldownProximity = enabled
    
    if connections["noCooldown"] then
        connections["noCooldown"]:Disconnect()
        connections["noCooldown"] = nil
    end
    
    if enabled then
        connections["noCooldown"] = Workspace.DescendantAdded:Connect(function(obj)
            SafeCall(function()
                if obj:IsA("ProximityPrompt") then
                    obj.HoldDuration = 0
                end
            end)
        end)
        
        SafeCall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    obj.HoldDuration = 0
                end
            end
        end)
    end
end

-- Не работающие функции
function MainModule.ToggleUnlockDash(enabled)
    MainModule.Misc.UnlockDash = enabled
    print("Unlock Dash: Don't work yet")
end

function MainModule.ToggleUnlockPhantomStep(enabled)
    MainModule.Misc.UnlockPhantomStep = enabled
    print("Unlock Phantom Step: Don't work yet")
end

-- Функция для получения координат
function MainModule.GetPlayerPosition()
    return SafeCall(function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local position = character.HumanoidRootPart.Position
            return string.format("X: %.1f, Y: %.1f, Z: %.1f", position.X, position.Y, position.Z)
        end
        return "Не доступно"
    end) or "Ошибка"
end

-- Очистка при закрытии
function MainModule.Cleanup()
    print("[Creon] Cleaning up...")
    
    -- Отключаем все соединения
    DisconnectAll()
    if MainModule.ESPConnection then
        MainModule.ESPConnection:Disconnect()
        MainModule.ESPConnection = nil
    end
    
    -- Восстанавливаем хитбоксы
    SafeCall(function()
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
    
    -- Восстанавливаем патроны
    SafeCall(function()
        for obj, originalValue in pairs(MainModule.Guards.OriginalAmmo) do
            if obj and obj.Parent then
                obj.Value = originalValue
            end
        end
        MainModule.Guards.OriginalAmmo = {}
    end)
    
    -- Восстанавливаем скорострельность
    SafeCall(function()
        for obj, originalValue in pairs(MainModule.Guards.OriginalFireRates) do
            if obj and obj.Parent then
                obj.Value = originalValue
            end
        end
        MainModule.Guards.OriginalFireRates = {}
    end)
    
    -- Очищаем ESP
    if MainModule.Misc.ESPEnabled then
        MainModule.ToggleESP(false)
    end
    
    -- Удаляем Sky Squid объекты
    SafeCall(function()
        if MainModule.SkySquid.AntiFallPlatform then
            MainModule.SkySquid.AntiFallPlatform:Destroy()
            MainModule.SkySquid.AntiFallPlatform = nil
        end
        if MainModule.SkySquid.SafePlatform then
            MainModule.SkySquid.SafePlatform:Destroy()
            MainModule.SkySquid.SafePlatform = nil
        end
    end)
    
    -- Восстанавливаем шипы
    if MainModule.HNS.DisableSpikes then
        MainModule.ToggleDisableSpikes(false)
    end
    
    -- Восстанавливаем Glass Bridge
    if MainModule.GlassBridge.AntiBreak then
        MainModule.ToggleAntiBreak(false)
    end
    
    print("[Creon] Cleanup completed")
end

-- Автоматическая очистка при выходе
LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not LocalPlayer.Parent then
        MainModule.Cleanup()
    end
end)

-- Инициализация
print("[Creon] Main module loaded successfully")

return MainModule
