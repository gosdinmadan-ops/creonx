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
local Debris = game:GetService("Debris")

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
    OriginalHeight = nil,
    RemoveInjuredEnabled = false,
    RemoveStunEnabled = false
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
    OriginalWalkSpeeds = {}
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
    -- Конфигурация AutoDodge
    DodgeDistance = 15,
    DodgeThreshold = 10,
    UseJump = true,
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
    -- AutoDodge tracking
    AttackCheckConnection = nil,
    TrackedAttackers = {}
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
    TransparentPlatform = nil
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
    SafePlatform = nil,
    TransparentPlatform = nil
}

-- Main функции (перемещены из Misc)
MainModule.InstaInteract = false
MainModule.NoCooldownProximity = false
MainModule.AntiStunRagdoll = false
MainModule.AntiRagdoll = false
MainModule.AntiStun = false
MainModule.UnlockDash = false
MainModule.UnlockPhantomStep = false
MainModule.RemoveInjuredWalking = false
MainModule.RemoveStunEffects = false

-- ESP System (оптимизированная без лагов)
MainModule.ESPTable = {}
MainModule.ESPFolder = nil
MainModule.ESPUpdateRate = 0.8
MainModule.LastESPUpdate = 0
MainModule.ESPConnection = nil
MainModule.ESPCache = {}

-- ESP настройки
MainModule.ESPEnabled = false
MainModule.ESPPlayers = true
MainModule.ESPHiders = true
MainModule.ESPSeekers = true
MainModule.ESPCandies = false
MainModule.ESPKeys = true
MainModule.ESPDoors = true
MainModule.ESPEscapeDoors = true
MainModule.ESPGuards = true
MainModule.ESPHighlight = true
MainModule.ESPDistance = true
MainModule.ESPNames = true
MainModule.ESPBoxes = true
MainModule.ESPShowSnow = true
MainModule.ESPShowHP = true
MainModule.ESPFillTransparency = 0.7
MainModule.ESPOutlineTransparency = 0
MainModule.ESPTextSize = 18

-- HNS шипы
MainModule.HNSSpikes = {
    Positions = {},
    OriginalPositions = {},
    Disabled = false
}

-- Glass Bridge платформы
MainModule.GlassBridgePlatforms = {}
MainModule.GlassBridgeCover = nil

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
local antiRagdollConnection = nil
local antiStunConnection2 = nil

-- Локальный игрок
local LocalPlayer = Players.LocalPlayer

-- Оптимизированная ESP System (без лагов)
function MainModule.ToggleESP(enabled)
    MainModule.ESPEnabled = enabled
    
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
                
                local playerRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                -- ESP для игроков
                if MainModule.ESPPlayers then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                            if humanoid and humanoid.Health > 0 then
                                local cacheKey = "player_" .. player.UserId
                                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                                
                                if rootPart then
                                    if not MainModule.ESPCache[cacheKey] or tick() - MainModule.ESPCache[cacheKey] > 2 then
                                        -- Определяем цвет ESP
                                        local isHider = player:GetAttribute("IsHider") or false
                                        local isHunter = player:GetAttribute("IsHunter") or false
                                        local isGuard = player:GetAttribute("IsGuard") or false
                                        local espColor = Color3.fromRGB(0, 170, 255) -- Синий по умолчанию
                                        
                                        if isHider and MainModule.ESPHiders then
                                            espColor = Color3.fromRGB(0, 255, 0) -- Зеленый для прячущихся
                                        elseif isHunter and MainModule.ESPSeekers then
                                            espColor = Color3.fromRGB(255, 0, 0) -- Красный для ищущих
                                        elseif isGuard and MainModule.ESPGuards then
                                            espColor = Color3.fromRGB(255, 165, 0) -- Оранжевый для охранников
                                        end
                                        
                                        -- Создаем или обновляем Highlight
                                        if not MainModule.ESPTable[cacheKey] then
                                            local highlight = Instance.new("Highlight")
                                            highlight.Name = "ESP_" .. player.Name
                                            highlight.Adornee = player.Character
                                            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                            highlight.FillColor = espColor
                                            highlight.FillTransparency = MainModule.ESPFillTransparency
                                            highlight.OutlineColor = espColor
                                            highlight.OutlineTransparency = MainModule.ESPOutlineTransparency
                                            highlight.Enabled = MainModule.ESPHighlight
                                            highlight.Parent = MainModule.ESPFolder
                                            
                                            MainModule.ESPTable[cacheKey] = {
                                                Highlight = highlight,
                                                Destroy = function()
                                                    if highlight then highlight:Destroy() end
                                                end
                                            }
                                        else
                                            -- Обновляем цвет
                                            MainModule.ESPTable[cacheKey].Highlight.FillColor = espColor
                                            MainModule.ESPTable[cacheKey].Highlight.OutlineColor = espColor
                                        end
                                        
                                        MainModule.ESPCache[cacheKey] = tick()
                                    end
                                    
                                    -- Добавляем billboard с информацией
                                    if MainModule.ESPNames and not MainModule.ESPTable[cacheKey .. "_text"] then
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
                                        
                                        local displayText = player.DisplayName
                                        
                                        -- Добавляем расстояние
                                        if MainModule.ESPDistance and playerRoot then
                                            local distance = math.floor((rootPart.Position - playerRoot.Position).Magnitude)
                                            displayText = displayText .. " [" .. distance .. "m]"
                                        end
                                        
                                        -- Добавляем HP
                                        if MainModule.ESPShowHP then
                                            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                                            if humanoid then
                                                displayText = displayText .. " HP: " .. math.floor(humanoid.Health)
                                            end
                                        end
                                        
                                        -- Добавляем Snow
                                        if MainModule.ESPShowSnow then
                                            local snowAmount = player:GetAttribute("SnowAmount") or 0
                                            if snowAmount > 0 then
                                                displayText = displayText .. " ❄" .. snowAmount
                                            end
                                        end
                                        
                                        textLabel.Text = displayText
                                        textLabel.TextColor3 = espColor
                                        textLabel.TextSize = MainModule.ESPTextSize
                                        textLabel.Font = Enum.Font.GothamBold
                                        textLabel.TextStrokeTransparency = 0.3
                                        textLabel.Parent = billboard
                                        
                                        MainModule.ESPTable[cacheKey .. "_text"] = {
                                            Billboard = billboard,
                                            Destroy = function()
                                                if billboard then billboard:Destroy() end
                                            end
                                        }
                                    elseif MainModule.ESPTable[cacheKey .. "_text"] then
                                        -- Обновляем текст
                                        local billboard = MainModule.ESPTable[cacheKey .. "_text"].Billboard
                                        if billboard and billboard:FindFirstChild("ESP_Label") then
                                            local textLabel = billboard.ESP_Label
                                            local displayText = player.DisplayName
                                            
                                            if MainModule.ESPDistance and playerRoot then
                                                local distance = math.floor((rootPart.Position - playerRoot.Position).Magnitude)
                                                displayText = displayText .. " [" .. distance .. "m]"
                                            end
                                            
                                            if MainModule.ESPShowHP then
                                                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                                                if humanoid then
                                                    displayText = displayText .. " HP: " .. math.floor(humanoid.Health)
                                                end
                                            end
                                            
                                            if MainModule.ESPShowSnow then
                                                local snowAmount = player:GetAttribute("SnowAmount") or 0
                                                if snowAmount > 0 then
                                                    displayText = displayText .. " ❄" .. snowAmount
                                                end
                                            end
                                            
                                            textLabel.Text = displayText
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                
                -- ESP для ключей
                if MainModule.ESPKeys then
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
                                        
                                        -- Добавляем текст
                                        local billboard = Instance.new("BillboardGui")
                                        billboard.Name = "ESP_Key_Text"
                                        billboard.Adornee = primaryPart
                                        billboard.AlwaysOnTop = true
                                        billboard.Size = UDim2.new(0, 150, 0, 30)
                                        billboard.StudsOffset = Vector3.new(0, 2, 0)
                                        billboard.Parent = MainModule.ESPFolder
                                        
                                        local textLabel = Instance.new("TextLabel")
                                        textLabel.Name = "Key_Label"
                                        textLabel.BackgroundTransparency = 1
                                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                                        textLabel.Text = "🔑 Key"
                                        textLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
                                        textLabel.TextSize = 14
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
                                    
                                    MainModule.ESPCache[cacheKey] = tick()
                                end
                            end
                        end
                    end
                end
                
                -- ESP для конфет (если включено)
                if MainModule.ESPCandies then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and (obj.Name:lower():find("candy") or obj.Name:lower():find("конфет")) then
                            local cacheKey = "candy_" .. HttpService:GenerateGUID(false)
                            local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                            
                            if primaryPart then
                                if not MainModule.ESPCache[cacheKey] or tick() - MainModule.ESPCache[cacheKey] > 5 then
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
                
                -- ESP для дверей
                if MainModule.ESPDoors then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and (obj.Name:lower():find("door") or obj.Name:lower():find("двер")) then
                            local cacheKey = "door_" .. HttpService:GenerateGUID(false)
                            local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                            
                            if primaryPart then
                                if not MainModule.ESPCache[cacheKey] or tick() - MainModule.ESPCache[cacheKey] > 5 then
                                    if not MainModule.ESPTable[cacheKey] then
                                        local highlight = Instance.new("Highlight")
                                        highlight.Name = "ESP_Door"
                                        highlight.Adornee = obj
                                        highlight.FillColor = Color3.fromRGB(160, 32, 240)
                                        highlight.FillTransparency = 0.3
                                        highlight.OutlineColor = Color3.fromRGB(160, 32, 240)
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
                
                -- ESP для Exit Doors (Escape Doors)
                if MainModule.ESPEscapeDoors then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and (obj.Name:lower():find("exit") or obj.Name:lower():find("escape") or 
                           obj.Name:lower():find("выход") or obj.Name:lower():find("эскейп")) then
                            local cacheKey = "exit_" .. HttpService:GenerateGUID(false)
                            local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                            
                            if primaryPart then
                                if not MainModule.ESPCache[cacheKey] or tick() - MainModule.ESPCache[cacheKey] > 5 then
                                    if not MainModule.ESPTable[cacheKey] then
                                        local highlight = Instance.new("Highlight")
                                        highlight.Name = "ESP_Exit"
                                        highlight.Adornee = obj
                                        highlight.FillColor = Color3.fromRGB(50, 205, 50)
                                        highlight.FillTransparency = 0.3
                                        highlight.OutlineColor = Color3.fromRGB(50, 205, 50)
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

-- Функции для управления ESP
function MainModule.UpdateESPSettings()
    if MainModule.ESPEnabled then
        MainModule.ToggleESP(false)
        wait(0.1)
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

function MainModule.CreateJumpRopeAntiFall()
    if MainModule.JumpRope.AntiFallPlatform then
        MainModule.JumpRope.AntiFallPlatform:Destroy()
        MainModule.JumpRope.AntiFallPlatform = nil
    end
    
    -- Создаем полностью прозрачную AntiFall платформу
    MainModule.JumpRope.AntiFallPlatform = Instance.new("Part")
    MainModule.JumpRope.AntiFallPlatform.Name = "JumpRopeAntiFallPlatform"
    MainModule.JumpRope.AntiFallPlatform.Size = Vector3.new(500, 5, 500)
    MainModule.JumpRope.AntiFallPlatform.Position = Vector3.new(737.156372, 180, 920.952515)
    MainModule.JumpRope.AntiFallPlatform.Anchored = true
    MainModule.JumpRope.AntiFallPlatform.CanCollide = true
    MainModule.JumpRope.AntiFallPlatform.Transparency = 1 -- Полностью прозрачная
    MainModule.JumpRope.AntiFallPlatform.Material = Enum.Material.Plastic
    MainModule.JumpRope.AntiFallPlatform.Color = Color3.fromRGB(0, 0, 0)
    MainModule.JumpRope.AntiFallPlatform.Parent = Workspace
end

-- AutoDodge функции (исправленные)
function MainModule.ToggleAutoDodge(enabled)
    MainModule.HNS.AutoDodge = enabled
    
    if MainModule.HNS.AttackCheckConnection then
        MainModule.HNS.AttackCheckConnection:Disconnect()
        MainModule.HNS.AttackCheckConnection = nil
    end
    
    -- Очищаем отслеживаемых атакующих
    for _, data in pairs(MainModule.HNS.TrackedAttackers) do
        if data.Connection then
            data.Connection:Disconnect()
        end
    end
    MainModule.HNS.TrackedAttackers = {}
    
    if enabled then
        -- Конфигурация AutoDodge
        local DodgeDistance = MainModule.HNS.DodgeDistance
        local DodgeThreshold = MainModule.HNS.DodgeThreshold
        local UseJump = MainModule.HNS.UseJump
        
        -- Функция для отслеживания атакующих игроков
        local function trackAttacker(player, tool)
            if not MainModule.HNS.TrackedAttackers[player] then
                MainModule.HNS.TrackedAttackers[player] = {
                    Tool = tool,
                    LastAttackTime = 0,
                    Connection = nil
                }
                
                -- Отслеживаем активацию инструмента
                local remoteEvent = tool:FindFirstChild("RemoteEvent")
                if remoteEvent then
                    MainModule.HNS.TrackedAttackers[player].Connection = remoteEvent.OnClientEvent:Connect(function(...)
                        MainModule.HNS.TrackedAttackers[player].LastAttackTime = tick()
                        MainModule.CheckKnifeHitbox(player, tool)
                    end)
                end
            end
        end
        
        -- Функция проверки хитбокса ножа
        function MainModule.CheckKnifeHitbox(attacker, knifeTool)
            if not MainModule.HNS.AutoDodge then return end
            
            local currentTime = tick()
            if currentTime - MainModule.HNS.LastDodgeTime < MainModule.HNS.DodgeCooldown then return end
            
            local character = LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local attackerChar = attacker.Character
            if not attackerChar or not attackerChar:FindFirstChild("HumanoidRootPart") then return end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local attackerRoot = attackerChar:FindFirstChild("HumanoidRootPart")
            
            -- Рассчитываем дистанцию
            local distance = (rootPart.Position - attackerRoot.Position).Magnitude
            
            -- Если нож в пределах дистанции DodgeThreshold
            if distance <= DodgeThreshold then
                -- Рассчитываем предполагаемый хитбокс атаки ножом
                local attackRange = 5 -- Предполагаемый диапазон ножа
                local attackDirection = attackerRoot.CFrame.LookVector
                local attackStart = attackerRoot.Position
                local attackEnd = attackStart + attackDirection * attackRange
                
                -- Проверяем пересечение линии атаки с нашим персонажем
                local toPlayer = rootPart.Position - attackStart
                local projection = toPlayer:Dot(attackDirection)
                
                if projection > 0 and projection < attackRange then
                    local closestPoint = attackStart + attackDirection * projection
                    local distanceToLine = (rootPart.Position - closestPoint).Magnitude
                    
                    -- Если хитбокс ножа достает до нас
                    if distanceToLine < 3 then
                        MainModule.PerformDodge()
                        MainModule.HNS.LastDodgeTime = tick()
                    end
                end
            end
        end
        
        -- Основной цикл AutoDodge
        MainModule.HNS.AttackCheckConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.AutoDodge then return end
            
            local character = LocalPlayer.Character
            if not character then return end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart then return end
            
            -- Ищем игроков с ножом
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local targetChar = player.Character
                    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                    
                    if targetRoot then
                        local distance = (rootPart.Position - targetRoot.Position).Magnitude
                        
                        -- Если игрок в пределах DodgeDistance
                        if distance <= DodgeDistance then
                            -- Проверяем наличие ножа
                            local hasKnife = false
                            local knifeTool = nil
                            
                            -- Проверяем в руках
                            for _, tool in pairs(targetChar:GetChildren()) do
                                if tool:IsA("Tool") then
                                    local toolName = tool.Name:lower()
                                    if toolName:find("knife") or toolName:find("fork") or toolName:find("dagger") or toolName:find("нож") then
                                        hasKnife = true
                                        knifeTool = tool
                                        trackAttacker(player, knifeTool)
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
                            
                            -- Если у игрока был нож и он недавно атаковал
                            if hasKnife and knifeTool and MainModule.HNS.TrackedAttackers[player] then
                                local lastAttackTime = MainModule.HNS.TrackedAttackers[player].LastAttackTime
                                if tick() - lastAttackTime < 1.0 then -- Проверяем атаки за последнюю секунду
                                    MainModule.CheckKnifeHitbox(player, knifeTool)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end

-- Конфигурация AutoDodge
function MainModule.ConfigureAutoDodge(config)
    if config.DodgeDistance then
        MainModule.HNS.DodgeDistance = config.DodgeDistance
    end
    if config.DodgeThreshold then
        MainModule.HNS.DodgeThreshold = config.DodgeThreshold
    end
    if config.UseJump ~= nil then
        MainModule.HNS.UseJump = config.UseJump
    end
end

-- Быстрое уклонение
function MainModule.QuickDodge()
    MainModule.PerformDodge()
    MainModule.HNS.LastDodgeTime = tick()
end

-- Функция выполнения уклонения
function MainModule.PerformDodge()
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if not rootPart or not humanoid then return end
    
    -- 1. Используем прыжок если включено
    if MainModule.HNS.UseJump then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
    
    -- 2. Быстрое движение в сторону
    local randomAngle = math.random() * 2 * math.pi
    local teleportDistance = 5
    local offset = Vector3.new(
        math.cos(randomAngle) * teleportDistance,
        2,
        math.sin(randomAngle) * teleportDistance
    )
    
    local newPosition = rootPart.Position + offset
    
    -- Телепортируемся
    rootPart.CFrame = CFrame.new(newPosition)
    
    -- 3. Визуальный эффект уклонения
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
            {Size = Vector3.new(8, 8, 8), Transparency = 1}
        ):Play()
        
        Debris:AddItem(dodgeEffect, 1)
    end)
end

-- Kill Hiders функция (исправленная)
function MainModule.ToggleKillHiders(enabled)
    MainModule.HNS.KillHiders = enabled
    
    if hnsKillHidersConnection then
        hnsKillHidersConnection:Disconnect()
        hnsKillHidersConnection = nil
    end
    
    if enabled then
        -- Переменные для прикрепления
        local attachedTo = nil
        local attachmentOffset = Vector3.new(0, 0, -3) -- 3 range впереди
        local lastTargetPosition = nil
        
        hnsKillHidersConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.KillHiders then 
                attachedTo = nil
                lastTargetPosition = nil
                return 
            end
            
            local character = LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then return end
            
            -- Проверяем наличие ножа
            local hasKnife = false
            local knifeTool = nil
            
            for _, tool in pairs(character:GetChildren()) do
                if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("dagger") or 
                   tool.Name:lower():find("fork") or tool.Name:lower():find("нож")) then
                    hasKnife = true
                    knifeTool = tool
                    break
                end
            end
            
            if not hasKnife then 
                attachedTo = nil
                lastTargetPosition = nil
                return 
            end
            
            -- Ищем ближайшего живого Hider
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
            
            if nearestHider and targetRootPart then
                -- Если у нас уже есть прикрепленный target
                if attachedTo and attachedTo == nearestHider and attachedTo.Character then
                    local targetRoot = attachedTo.Character:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        -- Сохраняем текущую позицию цели
                        local currentTargetPos = targetRoot.Position
                        
                        -- Если цель двигается, обновляем нашу позицию
                        if not lastTargetPosition or (currentTargetPos - lastTargetPosition).Magnitude > 0.1 then
                            -- Позиция в 3 range впереди цели на той же высоте
                            local targetCFrame = targetRoot.CFrame
                            local targetLookVector = targetCFrame.LookVector
                            local newPosition = targetRoot.Position + (targetLookVector * -3)
                            
                            -- Сохраняем высоту цели
                            newPosition = Vector3.new(newPosition.X, targetRoot.Position.Y, newPosition.Z)
                            
                            -- Телепортируемся
                            rootPart.CFrame = CFrame.new(newPosition)
                            
                            -- Не поворачиваемся к цели, стоим статично
                            
                            lastTargetPosition = currentTargetPos
                            
                            -- Авто-атака
                            if knifeTool then
                                local remoteEvent = knifeTool:FindFirstChild("RemoteEvent")
                                if remoteEvent then
                                    pcall(function()
                                        remoteEvent:FireServer()
                                    end)
                                end
                                
                                -- Клик мышью
                                pcall(function()
                                    local virtualInputManager = game:GetService("VirtualInputManager")
                                    virtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                                    task.wait(0.05)
                                    virtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                                end)
                            end
                        end
                    end
                else
                    -- Прикрепляемся к новому target
                    attachedTo = nearestHider
                    lastTargetPosition = targetRootPart.Position
                    
                    -- Телепортируемся в 3 range впереди
                    local targetCFrame = targetRootPart.CFrame
                    local targetLookVector = targetCFrame.LookVector
                    local newPosition = targetRootPart.Position + (targetLookVector * -3)
                    newPosition = Vector3.new(newPosition.X, targetRootPart.Position.Y, newPosition.Z)
                    
                    rootPart.CFrame = CFrame.new(newPosition)
                end
            else
                attachedTo = nil
                lastTargetPosition = nil
            end
        end)
    else
        MainModule.HNS.CurrentKillTarget = nil
    end
end

-- HNS Spikes Kill функция (исправленная)
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
                if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("dagger") or 
                   tool.Name:lower():find("fork") or tool.Name:lower():find("нож")) then
                    hasKnife = true
                    knifeTool = tool
                    break
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
                end
                
                task.wait(0.5)
                
                -- 3. Телепортируем цель к шипам
                if #MainModule.HNSSpikes.Positions > 0 then
                    local randomSpike = MainModule.HNSSpikes.Positions[math.random(1, #MainModule.HNSSpikes.Positions)]
                    targetRootPart.CFrame = CFrame.new(randomSpike)
                    
                    task.wait(2)
                    
                    -- 4. Возвращаемся на оригинальную позицию
                    rootPart.CFrame = originalCFrame
                end
                
                -- Сбрасываем состояние
                MainModule.HNS.LastSpikeKillTime = tick()
                MainModule.HNS.IsInSpikeKillProcess = false
                
                -- Сбрасываем target если умер
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

-- HNS Disable Spikes функция
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

-- Glass Bridge функции
function MainModule.ToggleAntiBreak(enabled)
    MainModule.GlassBridge.AntiBreak = enabled
    
    if antiBreakConnection then
        antiBreakConnection:Disconnect()
        antiBreakConnection = nil
    end
    
    if enabled then
        -- Создаем Fake Glass автоматически
        MainModule.CreateGlassBridgeCover()
        
        -- Создаем огромную прозрачную Anti-Fall платформу
        MainModule.CreateTransparentAntiFallPlatform()
        
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
        MainModule.RemoveTransparentAntiFallPlatform()
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

-- Создание прозрачной Anti-Fall платформы
function MainModule.CreateTransparentAntiFallPlatform()
    if MainModule.GlassBridge.TransparentPlatform then
        MainModule.GlassBridge.TransparentPlatform:Destroy()
        MainModule.GlassBridge.TransparentPlatform = nil
    end
    
    -- Создаем ОГРОМНУЮ полностью прозрачную платформу
    MainModule.GlassBridge.TransparentPlatform = Instance.new("Part")
    MainModule.GlassBridge.TransparentPlatform.Name = "TransparentGlassBridgeAntiFall"
    MainModule.GlassBridge.TransparentPlatform.Size = Vector3.new(1000, 10, 1000)
    MainModule.GlassBridge.TransparentPlatform.Position = Vector3.new(-200, 510, -1534)
    MainModule.GlassBridge.TransparentPlatform.Anchored = true
    MainModule.GlassBridge.TransparentPlatform.CanCollide = true
    MainModule.GlassBridge.TransparentPlatform.Transparency = 1 -- Полностью прозрачная
    MainModule.GlassBridge.TransparentPlatform.Material = Enum.Material.Plastic
    MainModule.GlassBridge.TransparentPlatform.Color = Color3.fromRGB(0, 0, 0)
    MainModule.GlassBridge.TransparentPlatform.Parent = Workspace
end

function MainModule.RemoveTransparentAntiFallPlatform()
    if MainModule.GlassBridge.TransparentPlatform then
        MainModule.GlassBridge.TransparentPlatform:Destroy()
        MainModule.GlassBridge.TransparentPlatform = nil
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

-- Sky Squid функции
function MainModule.ToggleSkySquidAntiFall(enabled)
    MainModule.SkySquid.AntiFall = enabled
    
    if skySquidAntiFallConnection then
        skySquidAntiFallConnection:Disconnect()
        skySquidAntiFallConnection = nil
    end
    
    if enabled then
        -- Создаем прозрачную Anti-Fall платформу
        MainModule.CreateSkySquidTransparentPlatform()
        
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
        MainModule.RemoveSkySquidTransparentPlatform()
    end
end

-- Создание прозрачной платформы для Sky Squid
function MainModule.CreateSkySquidTransparentPlatform()
    if MainModule.SkySquid.TransparentPlatform then
        MainModule.SkySquid.TransparentPlatform:Destroy()
        MainModule.SkySquid.TransparentPlatform = nil
    end
    
    -- Создаем прозрачную платформу
    MainModule.SkySquid.TransparentPlatform = Instance.new("Part")
    MainModule.SkySquid.TransparentPlatform.Name = "TransparentSkySquidPlatform"
    MainModule.SkySquid.TransparentPlatform.Size = Vector3.new(500, 10, 500)
    MainModule.SkySquid.TransparentPlatform.Position = Vector3.new(0, 90, 0)
    MainModule.SkySquid.TransparentPlatform.Anchored = true
    MainModule.SkySquid.TransparentPlatform.CanCollide = true
    MainModule.SkySquid.TransparentPlatform.Transparency = 1 -- Полностью прозрачная
    MainModule.SkySquid.TransparentPlatform.Material = Enum.Material.Plastic
    MainModule.SkySquid.TransparentPlatform.Color = Color3.fromRGB(0, 0, 0)
    MainModule.SkySquid.TransparentPlatform.Parent = Workspace
end

function MainModule.RemoveSkySquidTransparentPlatform()
    if MainModule.SkySquid.TransparentPlatform then
        MainModule.SkySquid.TransparentPlatform:Destroy()
        MainModule.SkySquid.TransparentPlatform = nil
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
                                task.delay(10, function()
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
        MainModule.RemoveSkySquidSafePlatform()
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

function MainModule.RemoveSkySquidSafePlatform()
    if MainModule.SkySquid.SafePlatform then
        MainModule.SkySquid.SafePlatform:Destroy()
        MainModule.SkySquid.SafePlatform = nil
    end
end

-- Hitbox Expander (исправленная версия)
function MainModule.ToggleHitboxExpander(enabled)
    MainModule.Guards.HitboxExpander = enabled
    
    if hitboxConnection then
        hitboxConnection:Disconnect()
        hitboxConnection = nil
    end
    
    -- Очищаем модифицированные части
    for part, _ in pairs(MainModule.Guards.OriginalHitboxes) do
        if part and part.Parent then
            -- Восстанавливаем оригинальный размер
            local originalSize = MainModule.Guards.OriginalHitboxes[part]
            if originalSize then
                part.Size = originalSize
            end
        end
    end
    MainModule.Guards.OriginalHitboxes = {}
    
    if enabled then
        local HITBOX_SIZE = 1000
        
        -- Функция для модификации части
        local function modifyPart(part)
            if not MainModule.Guards.OriginalHitboxes[part] then
                -- Сохраняем оригинальный размер
                MainModule.Guards.OriginalHitboxes[part] = part.Size
                
                -- Устанавливаем новый размер (только увеличение, не затрагивая позицию)
                part.Size = Vector3.new(HITBOX_SIZE, HITBOX_SIZE, HITBOX_SIZE)
                
                -- Сохраняем оригинальную позицию для правильного отображения
                local originalPosition = part.Position
                
                -- Обновляем позицию (чтобы часть не смещалась)
                part.Position = originalPosition
            end
        end
        
        -- Инициализация для существующих игроков
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    modifyPart(root)
                end
            end
        end
        
        -- Основной цикл
        hitboxConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.Guards.HitboxExpander then return end
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local root = player.Character:FindFirstChild("HumanoidRootPart")
                    if root and not MainModule.Guards.OriginalHitboxes[root] then
                        modifyPart(root)
                    end
                end
            end
        end)
        
        -- Обработчик для новых игроков
        Players.PlayerAdded:Connect(function(player)
            if player ~= LocalPlayer then
                player.CharacterAdded:Connect(function(character)
                    if MainModule.Guards.HitboxExpander then
                        task.wait(1) -- Ждем загрузки
                        local root = character:FindFirstChild("HumanoidRootPart")
                        if root then
                            modifyPart(root)
                        end
                    end
                end)
            end
        end)
    else
        -- Восстанавливаем оригинальные размеры
        for part, originalSize in pairs(MainModule.Guards.OriginalHitboxes) do
            if part and part.Parent then
                part.Size = originalSize
            end
        end
        MainModule.Guards.OriginalHitboxes = {}
    end
end

-- Infinite Ammo функция (с восстановлением)
function MainModule.ToggleInfiniteAmmo(enabled)
    MainModule.Guards.InfiniteAmmo = enabled
    
    if infiniteAmmoConnection then
        infiniteAmmoConnection:Disconnect()
        infiniteAmmoConnection = nil
    end
    
    if enabled then
        -- Сохраняем оригинальные значения
        MainModule.Guards.OriginalAmmo = {}
        
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
                                    -- Сохраняем оригинальное значение если еще не сохранено
                                    if not MainModule.Guards.OriginalAmmo[obj] then
                                        MainModule.Guards.OriginalAmmo[obj] = obj.Value
                                    end
                                    -- Устанавливаем бесконечные патроны
                                    obj.Value = math.huge
                                end
                            end
                        end
                    end
                end
            end
        end)
    else
        -- Восстанавливаем оригинальные значения
        for obj, originalValue in pairs(MainModule.Guards.OriginalAmmo) do
            if obj and obj.Parent then
                obj.Value = originalValue
            end
        end
        MainModule.Guards.OriginalAmmo = {}
    end
end

-- Anti Stun и Anti Ragdoll функции
function MainModule.ToggleAntiStun(enabled)
    MainModule.AntiStun = enabled
    
    if antiStunConnection2 then
        antiStunConnection2:Disconnect()
        antiStunConnection2 = nil
    end
    
    if enabled then
        antiStunConnection2 = RunService.Heartbeat:Connect(function()
            if not MainModule.AntiStun then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if not humanoid then return end
                
                -- Удаляем эффекты Stun из персонажа
                for _, obj in pairs(character:GetDescendants()) do
                    if obj.Name:lower():find("stun") or obj.Name:lower():find("slow") then
                        obj:Destroy()
                    end
                end
                
                -- Восстанавливаем из состояния Stun
                if humanoid:GetState() == Enum.HumanoidStateType.Stunned then
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                end
                
                -- Удаляем Injured Walking эффекты
                if MainModule.RemoveInjuredWalking then
                    for _, obj in pairs(character:GetDescendants()) do
                        if obj.Name == "InjuredWalking" or obj.Name:lower():find("injured") then
                            obj:Destroy()
                        end
                    end
                end
                
                -- Удаляем эффекты из workspace
                for _, effect in pairs(Workspace:GetDescendants()) do
                    if effect:IsA("BasePart") then
                        if effect.Name:lower():find("stun") or 
                           effect.Name:lower():find("slow") or
                           (MainModule.RemoveInjuredWalking and effect.Name == "InjuredWalking") then
                            
                            local rootPart = character:FindFirstChild("HumanoidRootPart")
                            if rootPart and (rootPart.Position - effect.Position).Magnitude < 20 then
                                effect:Destroy()
                            end
                        end
                    end
                end
                
                -- Поддерживаем максимальную скорость
                if humanoid.WalkSpeed < 16 then
                    humanoid.WalkSpeed = 16
                end
            end)
        end)
    end
end

function MainModule.ToggleAntiRagdoll(enabled)
    MainModule.AntiRagdoll = enabled
    
    if antiRagdollConnection then
        antiRagdollConnection:Disconnect()
        antiRagdollConnection = nil
    end
    
    if enabled then
        antiRagdollConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.AntiRagdoll then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if not humanoid then return end
                
                -- Восстанавливаем из рагдолла
                if humanoid:GetState() == Enum.HumanoidStateType.Ragdoll or 
                   humanoid:GetState() == Enum.HumanoidStateType.FallingDown then
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                end
                
                -- Включаем все моторы
                for _, motor in pairs(character:GetDescendants()) do
                    if motor:IsA("Motor6D") and not motor.Enabled then
                        motor.Enabled = true
                    end
                end
                
                -- Убеждаемся что персонаж стоит
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local currentCFrame = rootPart.CFrame
                    rootPart.CFrame = CFrame.new(currentCFrame.Position)
                end
            end)
        end)
    end
end

-- Remove Injured Walking функция
function MainModule.ToggleRemoveInjuredWalking(enabled)
    MainModule.RemoveInjuredWalking = enabled
    
    if removeInjuredConnection then
        removeInjuredConnection:Disconnect()
        removeInjuredConnection = nil
    end
    
    if enabled then
        removeInjuredConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.RemoveInjuredWalking then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                -- Удаляем Injured Walking эффекты
                for _, obj in pairs(character:GetDescendants()) do
                    if obj.Name == "InjuredWalking" or obj.Name:lower():find("injured") then
                        obj:Destroy()
                    end
                end
                
                -- Удаляем эффекты из workspace
                for _, effect in pairs(Workspace:GetDescendants()) do
                    if effect:IsA("BasePart") and effect.Name == "InjuredWalking" then
                        local rootPart = character:FindFirstChild("HumanoidRootPart")
                        if rootPart and (rootPart.Position - effect.Position).Magnitude < 20 then
                            effect:Destroy()
                        end
                    end
                end
            end)
        end)
    end
end

-- Остальные функции (без изменений)
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
                humanoid.WalkSpeed = MainModule.SpeedHack.CurrentSpeed
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

function MainModule.ToggleAntiStunQTE(enabled)
    MainModule.AutoQTE.AntiStunEnabled = enabled
end

function MainModule.ToggleRebel(enabled)
    MainModule.Rebel.Enabled = enabled
    _G.InstantRebel = enabled
end

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

function MainModule.SetGuardType(guardType)
    MainModule.Guards.SelectedGuard = guardType
end

function MainModule.SpawnAsGuard()
    local args = {{AttemptToSpawnAsGuard = MainModule.Guards.SelectedGuard}}
    
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
                local args2 = {"GameOver", 4450}
                pcall(function()
                    ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("VideoGameRemote"):FireServer(unpack(args2))
                end)
            end
        end)
    end
end

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
                                obj.Value = 0.5
                            end
                        end
                    end
                end
            end
        end)
    end
end

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
                    local args = {{IHateYou = true}}
                    Remote:FireServer(unpack(args))
                end)
                task.wait(0.25)
            end
        end)
    end
end

function MainModule.ToggleInstaInteract(enabled)
    MainModule.InstaInteract = enabled
    
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
    MainModule.NoCooldownProximity = enabled
    
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
            if MainModule.NoCooldownProximity then
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

-- Удаление всех дебаффов
function MainModule.RemoveAllDebuffs()
    local removedCount = 0
    local character = LocalPlayer.Character
    
    if not character then return 0 end
    
    -- Список эффектов для удаления
    local effectsToRemove = {
        "InjuredWalking", "Injured", "Stun", "Slow", 
        "Freeze", "Paralyze", "Debuff"
    }
    
    -- Удаляем из персонажа
    for _, child in pairs(character:GetDescendants()) do
        for _, effectName in ipairs(effectsToRemove) do
            if string.find(child.Name:lower(), effectName:lower()) then
                child:Destroy()
                removedCount = removedCount + 1
                break
            end
        end
    end
    
    -- Восстанавливаем скорость
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 16
    end
    
    return removedCount
end

-- Очистка при закрытии
function MainModule.Cleanup()
    -- Отключаем все соединения
    local connections = {
        speedConnection, autoFarmConnection, godModeConnection, 
        instaInteractConnection, noCooldownConnection, antiStunConnection, 
        rapidFireConnection, infiniteAmmoConnection, hitboxConnection, 
        autoPullConnection, antiBreakConnection, MainModule.ESPConnection,
        hnsSpikesKillConnection, hnsKillHidersConnection, hnsAutoDodgeConnection,
        glassBridgeESPConnection, antiStunRagdollConnection, skySquidAntiFallConnection,
        skySquidVoidKillConnection, removeInjuredConnection, antiRagdollConnection,
        antiStunConnection2
    }
    
    for _, conn in pairs(connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    
    -- Очищаем AutoDodge tracking
    for player, data in pairs(MainModule.HNS.TrackedAttackers) do
        if data.Connection then
            pcall(function() data.Connection:Disconnect() end)
        end
    end
    MainModule.HNS.TrackedAttackers = {}
    
    -- Восстанавливаем хитбоксы
    if MainModule.Guards.OriginalHitboxes then
        for part, originalSize in pairs(MainModule.Guards.OriginalHitboxes) do
            if part and part.Parent then
                part.Size = originalSize
            end
        end
        MainModule.Guards.OriginalHitboxes = {}
    end
    
    -- Восстанавливаем патроны
    for obj, originalValue in pairs(MainModule.Guards.OriginalAmmo) do
        if obj and obj.Parent then
            obj.Value = originalValue
        end
    end
    MainModule.Guards.OriginalAmmo = {}
    
    -- Очищаем ESP
    if MainModule.ESPEnabled then
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
    
    if MainModule.GlassBridge.TransparentPlatform then
        MainModule.GlassBridge.TransparentPlatform:Destroy()
        MainModule.GlassBridge.TransparentPlatform = nil
    end
    
    -- Удаляем Sky Squid объекты
    if MainModule.SkySquid.TransparentPlatform then
        MainModule.SkySquid.TransparentPlatform:Destroy()
        MainModule.SkySquid.TransparentPlatform = nil
    end
    
    if MainModule.SkySquid.SafePlatform then
        MainModule.SkySquid.SafePlatform:Destroy()
        MainModule.SkySquid.SafePlatform = nil
    end
    
    -- Удаляем Jump Rope платформу
    if MainModule.JumpRope.AntiFallPlatform then
        MainModule.JumpRope.AntiFallPlatform:Destroy()
        MainModule.JumpRope.AntiFallPlatform = nil
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
end

-- Автоматическая очистка при выходе
game:GetService("Players").LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not game:GetService("Players").LocalPlayer.Parent then
        MainModule.Cleanup()
    end
end)

return MainModule
