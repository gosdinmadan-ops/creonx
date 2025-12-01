-- Main.lua - Creon X v2.1 (полностью оптимизированный)
local MainModule = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
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
    AntiStunEnabled = false
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
    HitboxExpander = false
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

-- Sky Squid Game переменные (оптимизированные)
MainModule.SkySquid = {
    AntiFall = false,
    SafePlatform = false,
    VoidKill = false
}

MainModule.Misc = {
    InstaInteract = false,
    NoCooldownProximity = false,
    ESPEnabled = false,
    ESPPlayers = true,
    ESPHiders = true,
    ESPSeekers = true,
    ESPCandies = false,  -- Отключено
    ESPKeys = true,
    ESPDoors = false,    -- Отключено
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

-- ESP System (оптимизированная - обновление раз в 5 секунд)
MainModule.ESPTable = {}
MainModule.ESPFolder = nil
MainModule.ESPUpdateRate = 5.0
MainModule.LastESPUpdate = 0
MainModule.ESPConnection = nil

-- Соединения
local speedConnection = nil
local antiStunConnection = nil
local rebelConnection = nil
local godModeConnection = nil
local autoFarmConnection = nil
local rapidFireConnection = nil
local infiniteAmmoConnection = nil
local hitboxConnection = nil
local autoPickupConnection = nil
local spikesKillConnection = nil
local killHidersConnection = nil
local disableSpikesConnection = nil
local autoPullConnection = nil
local antiBreakConnection = nil
local glassBridgeESPConnection = nil
local jumpRopeAntiFailConnection = nil
local antiStunRagdollConnection = nil
local instaInteractConnection = nil
local noCooldownConnection = nil

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
    
    -- ОПТИМИЗИРОВАННОЕ обновление ESP раз в 5 секунд
    MainModule.ESPConnection = RunService.RenderStepped:Connect(function()
        local currentTime = tick()
        if currentTime - MainModule.LastESPUpdate < MainModule.ESPUpdateRate then
            return
        end
        MainModule.LastESPUpdate = currentTime
        
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
                                -- Создаем только Highlight (без Billboard)
                                local highlight = Instance.new("Highlight")
                                highlight.Name = "ESP_Highlight_" .. player.Name
                                highlight.Adornee = player.Character
                                highlight.FillColor = Color3.fromRGB(0, 170, 255)
                                highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
                                highlight.OutlineColor = Color3.fromRGB(0, 170, 255)
                                highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
                                highlight.Parent = MainModule.ESPFolder
                                
                                MainModule.ESPTable[espId] = {
                                    Highlight = highlight,
                                    Player = player,
                                    Destroy = function()
                                        pcall(function()
                                            if highlight then highlight:Destroy() end
                                        end)
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
                        local espId = "hider_" .. player.UserId
                        if not MainModule.ESPTable[espId] then
                            local highlight = Instance.new("Highlight")
                            highlight.Name = "ESP_Hider_" .. player.Name
                            highlight.Adornee = player.Character
                            highlight.FillColor = Color3.fromRGB(0, 255, 0) -- Зеленый для хайдеров
                            highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
                            highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                            highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
                            highlight.Parent = MainModule.ESPFolder
                            
                            MainModule.ESPTable[espId] = {
                                Highlight = highlight,
                                Destroy = function()
                                    pcall(function()
                                        if highlight then highlight:Destroy() end
                                    end)
                                end
                            }
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
                        local espId = "seeker_" .. player.UserId
                        if not MainModule.ESPTable[espId] then
                            local highlight = Instance.new("Highlight")
                            highlight.Name = "ESP_Seeker_" .. player.Name
                            highlight.Adornee = player.Character
                            highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Красный для сикеров
                            highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
                            highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                            highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
                            highlight.Parent = MainModule.ESPFolder
                            
                            MainModule.ESPTable[espId] = {
                                Highlight = highlight,
                                Destroy = function()
                                    pcall(function()
                                        if highlight then highlight:Destroy() end
                                    end)
                                end
                            }
                        end
                    end
                end
            end
        end
        
        -- ESP для ключей
        if MainModule.Misc.ESPKeys then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and (obj.Name:lower():find("key") or obj.Name:lower():find("ключ")) and obj.PrimaryPart then
                    local espId = "key_" .. obj:GetFullName()
                    if not MainModule.ESPTable[espId] then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "ESP_Key"
                        highlight.Adornee = obj
                        highlight.FillColor = Color3.fromRGB(255, 165, 0) -- Оранжевый для ключей
                        highlight.FillTransparency = 0.8
                        highlight.OutlineColor = Color3.fromRGB(255, 165, 0)
                        highlight.OutlineTransparency = 0
                        highlight.Parent = MainModule.ESPFolder
                        
                        MainModule.ESPTable[espId] = {
                            Highlight = highlight,
                            Destroy = function()
                                pcall(function()
                                    if highlight then highlight:Destroy() end
                                end)
                            end
                        }
                    end
                end
            end
        end
        
        -- ESP для выходных дверей
        if MainModule.Misc.ESPEscapeDoors then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and (obj.Name:lower():find("escape") or obj.Name:lower():find("выход") or obj.Name:lower():find("door")) and obj.PrimaryPart then
                    local espId = "escape_door_" .. obj:GetFullName()
                    if not MainModule.ESPTable[espId] then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "ESP_EscapeDoor"
                        highlight.Adornee = obj
                        highlight.FillColor = Color3.fromRGB(0, 255, 255) -- Голубой для выходных дверей
                        highlight.FillTransparency = 0.8
                        highlight.OutlineColor = Color3.fromRGB(0, 255, 255)
                        highlight.OutlineTransparency = 0
                        highlight.Parent = MainModule.ESPFolder
                        
                        MainModule.ESPTable[espId] = {
                            Highlight = highlight,
                            Destroy = function()
                                pcall(function()
                                    if highlight then highlight:Destroy() end
                                end)
                            end
                        }
                    end
                end
            end
        end
        
        -- ESP для охранников
        if MainModule.Misc.ESPGuards then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and (obj.Name:lower():find("guard") or obj.Name:lower():find("охранник")) and obj:FindFirstChild("HumanoidRootPart") then
                    local espId = "guard_" .. obj:GetFullName()
                    if not MainModule.ESPTable[espId] then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "ESP_Guard"
                        highlight.Adornee = obj
                        highlight.FillColor = Color3.fromRGB(255, 50, 50) -- Темно-красный для охранников
                        highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
                        highlight.OutlineColor = Color3.fromRGB(255, 50, 50)
                        highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
                        highlight.Parent = MainModule.ESPFolder
                        
                        MainModule.ESPTable[espId] = {
                            Highlight = highlight,
                            Destroy = function()
                                pcall(function()
                                    if highlight then highlight:Destroy() end
                                end)
                            end
                        }
                    end
                end
            end
        end
        
        -- Очистка устаревших ESP
        for espId, espData in pairs(MainModule.ESPTable) do
            if espId:find("player_") then
                local playerId = tonumber(espId:match("player_(%d+)"))
                local player = Players:GetPlayerByUserId(playerId)
                if not player or not player.Character then
                    if espData.Destroy then
                        pcall(espData.Destroy)
                    end
                    MainModule.ESPTable[espId] = nil
                end
            elseif espId:find("hider_") then
                local playerId = tonumber(espId:match("hider_(%d+)"))
                local player = Players:GetPlayerByUserId(playerId)
                if not player or not player.Character then
                    if espData.Destroy then
                        pcall(espData.Destroy)
                    end
                    MainModule.ESPTable[espId] = nil
                end
            elseif espId:find("seeker_") then
                local playerId = tonumber(espId:match("seeker_(%d+)"))
                local player = Players:GetPlayerByUserId(playerId)
                if not player or not player.Character then
                    if espData.Destroy then
                        pcall(espData.Destroy)
                    end
                    MainModule.ESPTable[espId] = nil
                end
            elseif espId:find("key_") then
                local objectPath = espId:match("key_(.+)")
                local object = Workspace
                for part in string.gmatch(objectPath, "([^.]+)") do
                    object = object:FindFirstChild(part)
                    if not object then break end
                end
                if not object or not object.Parent then
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
    
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
    
    if enabled then
        speedConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.SpeedHack.Enabled then return end
            
            local character = LocalPlayer.Character
            if character then
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
                humanoid.WalkSpeed = 16
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
-- ANTI STUN QTE
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
                
                for _, child in pairs(impactFrames:GetChildren()) do
                    if child.Name == "OuterRingTemplate" and child:IsA("Frame") then
                        -- Нажимаем любую кнопку для QTE
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                        task.wait(0.05)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                        break
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
            
            local character = LocalPlayer.Character
            if not character then return end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            
            -- Восстанавливаем из рагдолла/стана
            if humanoid:GetState() == Enum.HumanoidStateType.FallingDown or 
               humanoid:GetState() == Enum.HumanoidStateType.Ragdoll then
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
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
    -- Используем общую функцию Infinite Ammo
    MainModule.ToggleInfiniteAmmo(enabled)
end

function MainModule.ToggleRebelRapidFire(enabled)
    MainModule.Rebel.RapidFire = enabled
    -- Используем общую функцию Rapid Fire
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
        godModeConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.RLGL.GodMode then return end
            
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                -- Держим игрока на высоте
                local currentPos = character.HumanoidRootPart.Position
                if currentPos.Y < 1180 then
                    character.HumanoidRootPart.CFrame = CFrame.new(currentPos.X, 1184.9, currentPos.Z)
                end
            end
        end)
    end
end

-- ===================================================================
-- GUARDS ФУНКЦИИ
-- ===================================================================
function MainModule.SetGuardType(guardType)
    MainModule.Guards.SelectedGuard = guardType
end

function MainModule.SpawnAsGuard()
    pcall(function()
        local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlayableGuardRemote")
        remote:FireServer({
            AttemptToSpawnAsGuard = MainModule.Guards.SelectedGuard
        })
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
            if not MainModule.Guards.AutoFarm then return end
            
            pcall(function()
                local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("VideoGameRemote")
                remote:FireServer("GameOver", 4450)
            end)
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
            end)
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
                            if obj:IsA("NumberValue") and (obj.Name:lower():find("ammo") or obj.Name:lower():find("bullet")) then
                                obj.Value = 999
                            end
                        end
                    end
                end
            end
        end)
    end
end

-- ===================================================================
-- HITBOX EXPANDER (оптимизированный)
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
    
    -- Основной цикл
    hitboxConnection = RunService.RenderStepped:Connect(function()
        if not _G.HitboxExpanderEnabled then return end
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root and root:IsA("BasePart") then
                    pcall(function()
                        root.Size = Vector3.new(_G.HeadSize, _G.HeadSize, _G.HeadSize)
                        root.CanCollide = false
                        root.Transparency = 1
                    end)
                end
            end
        end
    end)
end

-- ===================================================================
-- DALGONA ФУНКЦИИ
-- ===================================================================
function MainModule.CompleteDalgona()
    task.spawn(function()
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
    
    if autoPickupConnection then
        autoPickupConnection:Disconnect()
        autoPickupConnection = nil
    end
    
    if enabled then
        autoPickupConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.AutoPickup then return end
            
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
                        break
                    end
                end
            end
        end)
    end
end

function MainModule.ToggleSpikesKill(enabled)
    MainModule.HNS.SpikesKill = enabled
    
    if spikesKillConnection then
        spikesKillConnection:Disconnect()
        spikesKillConnection = nil
    end
    
    if enabled then
        spikesKillConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.SpikesKill then return end
            
            local character = LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local isHunter = LocalPlayer:GetAttribute("IsHunter")
            if not isHunter then return end
            
            -- Телепортируем хайдеров в шипы
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player:GetAttribute("IsHider") and 
                   player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                   
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        -- Создаем временную позицию шипа
                        player.Character.HumanoidRootPart.CFrame = CFrame.new(0, -100, 0)
                    end
                end
            end
        end)
    end
end

function MainModule.ToggleDisableSpikes(enabled)
    MainModule.HNS.DisableSpikes = enabled
    
    if disableSpikesConnection then
        disableSpikesConnection:Disconnect()
        disableSpikesConnection = nil
    end
    
    if enabled then
        disableSpikesConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.DisableSpikes then return end
            
            pcall(function()
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
    end
end

function MainModule.ToggleKillHiders(enabled)
    MainModule.HNS.KillHiders = enabled
    
    if killHidersConnection then
        killHidersConnection:Disconnect()
        killHidersConnection = nil
    end
    
    if enabled then
        killHidersConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.KillHiders then return end
            
            local character = LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local isHunter = LocalPlayer:GetAttribute("IsHunter")
            if not isHunter then return end
            
            -- Ищем ближайшего хайдера
            local targetPlayer = nil
            local closestDistance = 50
            
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
            
            -- Телепортируемся к цели
            if targetPlayer and targetPlayer.Character then
                character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2)
            end
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
            if not MainModule.TugOfWar.AutoPull then return end
            
            pcall(function()
                local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TemporaryReachedBindable")
                Remote:FireServer({ IHateYou = true })
            end)
        end)
    end
end

-- ===================================================================
-- GLASS BRIDGE ФУНКЦИИ
-- ===================================================================
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
                            
                            for _, part in pairs(tileModel:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    if isBreakable then
                                        part.Color = Color3.fromRGB(255, 0, 0)
                                        part.Transparency = 0.5
                                    else
                                        part.Color = Color3.fromRGB(0, 255, 0)
                                        part.Transparency = 0.5
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
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj.Name == "FailDetection" or obj.Name:lower():find("fail") then
                        obj:Destroy()
                    end
                end
            end)
        end)
    end
end

-- ===================================================================
-- SKY SQUID GAME ФУНКЦИИ (оптимизированные)
-- ===================================================================
function MainModule.ToggleSkySquidAntiFall(enabled)
    MainModule.SkySquid.AntiFall = enabled
    
    if not enabled then return end
    
    -- Создаем платформу под игроком
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local platform = Instance.new("Part")
    platform.Name = "SkySquid_AntiFallPlatform"
    platform.Size = Vector3.new(200, 5, 200)
    platform.Position = Vector3.new(rootPart.Position.X, 50, rootPart.Position.Z)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 0.9
    platform.Color = Color3.fromRGB(0, 170, 255)
    platform.Parent = Workspace
end

function MainModule.ToggleSkySquidSafePlatform(enabled)
    MainModule.SkySquid.SafePlatform = enabled
    -- Используем ту же функцию что и AntiFall
    MainModule.ToggleSkySquidAntiFall(enabled)
end

function MainModule.ToggleSkySquidVoidKill(enabled)
    MainModule.SkySquid.VoidKill = enabled
    
    if not enabled then return end
    
    -- Однократная телепортация врагов в пустоту
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CFrame = CFrame.new(0, 10000, 0)
            end
        end
    end
    
    -- Выключаем после использования
    MainModule.SkySquid.VoidKill = false
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
        instaInteractConnection = Workspace.DescendantAdded:Connect(function(obj)
            if obj:IsA("ProximityPrompt") then
                obj.HoldDuration = 0
            end
        end)
        
        -- Обрабатываем существующие
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                obj.HoldDuration = 0
            end
        end
    end
end

function MainModule.ToggleNoCooldownProximity(enabled)
    MainModule.Misc.NoCooldownProximity = enabled
    
    if noCooldownConnection then
        noCooldownConnection:Disconnect()
        noCooldownConnection = nil
    end
    
    if enabled then
        noCooldownConnection = Workspace.DescendantAdded:Connect(function(obj)
            if obj:IsA("ProximityPrompt") then
                obj.HoldDuration = 0
            end
        end)
        
        -- Обрабатываем существующие
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                v.HoldDuration = 0
            end
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

-- ===================================================================
-- ОЧИСТКА ПРИ ЗАКРЫТИИ
-- ===================================================================
function MainModule.Cleanup()
    -- Отключаем все соединения
    local connections = {
        speedConnection, antiStunConnection, godModeConnection, autoFarmConnection,
        rapidFireConnection, infiniteAmmoConnection, hitboxConnection, autoPickupConnection,
        spikesKillConnection, killHidersConnection, disableSpikesConnection, autoPullConnection,
        antiBreakConnection, glassBridgeESPConnection, jumpRopeAntiFailConnection,
        antiStunRagdollConnection, instaInteractConnection, noCooldownConnection,
        MainModule.ESPConnection
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
    
    -- Удаляем платформы Sky Squid
    local skyPlatform = Workspace:FindFirstChild("SkySquid_AntiFallPlatform")
    if skyPlatform then
        pcall(function() skyPlatform:Destroy() end)
    end
    
    local voidPlatform = Workspace:FindFirstChild("VoidPlatform")
    if voidPlatform then
        pcall(function() voidPlatform:Destroy() end)
    end
end

return MainModule
