-- Main.lua - Creon X v2.3 (Исправленная версия)
local MainModule = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
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

MainModule.Rebel = {
    Enabled = false
}

MainModule.RLGL = {
    GodMode = false,
    OriginalHeight = nil,
    GodModeTimeout = nil,
    LastDamageCheck = 0,
    DamageCheckRate = 0.5,
    TeleportOnDamage = false,
    LastHealth = 100
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

-- HNS System (обновлено)
MainModule.HNS = {
    KillAuraEnabled = false,
    KillSpikesEnabled = false,
    RemoveSpikesEnabled = false,
    DisableSpikesEnabled = false,
    TeleportToHiderEnabled = false,
    AutoDodgeEnabled = false,
    
    LastKillTime = 0,
    KillCooldown = 0.5,
    CurrentTarget = nil,
    AttachedToTarget = false,
    AttachmentCFrame = nil,
    
    LastDodgeTime = 0,
    DodgeCooldown = 1.0,
    DodgeRange = 10,
    
    SpikePositions = {},
    OriginalSpikeData = {}
}

-- Glass Bridge System
MainModule.GlassBridge = {
    GlassVisionEnabled = false,
    AntiFallEnabled = false,
    AntiBreakEnabled = false,
    GlassPlatformsEnabled = false,
    
    GlassPlatforms = {},
    AntiFallPlatform = nil,
    AntiFallConnection = nil,
    AntiBreakConnection = nil,
    GlassVisionConnection = nil,
    
    EndPosition = Vector3.new(-196.372467, 522.192139, -1534.20984),
    SafeHeight = 500
}

MainModule.TugOfWar = {
    AutoPull = false
}

MainModule.JumpRope = {
    TeleportToEnd = false,
    DeleteRope = false,
    AntiFallPlatform = nil,
    JumpRopeConnection = nil
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
    ESPFillTransparency = 0.3,
    ESPOutlineTransparency = 0,
    ESPTextSize = 14,
    BypassRagdollEnabled = false,
    RemoveInjuredEnabled = false,
    RemoveStunEnabled = false,
    UnlockDashEnabled = false,
    UnlockPhantomStepEnabled = false,
    LastInjuredNotify = 0,
    LastESPUpdate = 0,
    AntiRagdollLoop = nil,
    RagdollBlockConn = nil
}

-- ESP System
MainModule.ESPTable = {
    Player = {},
    Seeker = {},
    Hider = {},
    Guard = {},
    Door = {},
    None = {},
    Key = {},
    EscapeDoor = {}
}
MainModule.ESPFolder = nil
MainModule.ESPUpdateRate = 0.1
MainModule.ESPCache = {}
MainModule.ESPConnection = nil
MainModule.PlayerESPConnections = {}
MainModule.ESPHighlights = {}

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
local bypassRagdollConnection = nil
local hnsKillAuraConnection = nil
local hnsKillSpikesConnection = nil
local hnsAutoDodgeConnection = nil
local jumpRopeConnection = nil
local espUpdateConnection = nil

-- Локальный игрок
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Вспомогательные функции
local function SafeDestroy(obj)
    if obj and obj.Parent then
        pcall(function() obj:Destroy() end)
    end
end

-- Оптимизированная ESP система
function MainModule.ToggleESP(enabled)
    MainModule.Misc.ESPEnabled = enabled
    
    if espUpdateConnection then
        espUpdateConnection:Disconnect()
        espUpdateConnection = nil
    end
    
    -- Очищаем все ESP объекты
    if not enabled then
        for _, espList in pairs(MainModule.ESPTable) do
            for _, espManager in pairs(espList) do
                if espManager and espManager.Destroy then
                    pcall(espManager.Destroy)
                end
            end
        end
        
        -- Очищаем таблицы
        for key in pairs(MainModule.ESPTable) do
            MainModule.ESPTable[key] = {}
        end
        
        -- Очищаем хайлайты
        for _, highlight in pairs(MainModule.ESPHighlights) do
            pcall(function() highlight:Destroy() end)
        end
        MainModule.ESPHighlights = {}
        
        return
    end
    
    -- Создаем папку для ESP
    if not MainModule.ESPFolder then
        MainModule.ESPFolder = Instance.new("Folder")
        MainModule.ESPFolder.Name = "CreonESP"
        MainModule.ESPFolder.Parent = CoreGui
    end
    
    -- Основной цикл обновления ESP
    espUpdateConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.Misc.ESPEnabled then return end
        
        local currentTime = tick()
        if currentTime - MainModule.Misc.LastESPUpdate < MainModule.ESPUpdateRate then return end
        MainModule.Misc.LastESPUpdate = currentTime
        
        -- Обновляем игроков
        if MainModule.Misc.ESPPlayers then
            MainModule.UpdatePlayersESP()
        end
        
        -- Обновляем хайдеров
        if MainModule.Misc.ESPHiders then
            MainModule.UpdateHidersESP()
        end
        
        -- Обновляем сикеров
        if MainModule.Misc.ESPSeekers then
            MainModule.UpdateSeekersESP()
        end
        
        -- Обновляем ключи
        if MainModule.Misc.ESPKeys then
            MainModule.UpdateKeysESP()
        end
        
        -- Обновляем двери
        if MainModule.Misc.ESPDoors then
            MainModule.UpdateDoorsESP()
        end
        
        -- Обновляем escape двери
        if MainModule.Misc.ESPEscapeDoors then
            MainModule.UpdateEscapeDoorsESP()
        end
        
        -- Обновляем гвардов
        if MainModule.Misc.ESPGuards then
            MainModule.UpdateGuardsESP()
        end
    end)
end

function MainModule.UpdatePlayersESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                local espKey = "Player_" .. player.UserId
                
                if not MainModule.ESPCache[espKey] then
                    -- Создаем новый ESP
                    MainModule.ESPCache[espKey] = MainModule.CreateESP({
                        Object = character,
                        Text = player.DisplayName,
                        Color = Color3.fromRGB(0, 255, 0),
                        Type = "Player",
                        Player = player
                    })
                else
                    -- Обновляем существующий ESP
                    local esp = MainModule.ESPCache[espKey]
                    if esp and esp.Update then
                        esp:Update(player.DisplayName .. " [" .. math.floor(humanoid.Health) .. " HP]", 
                                  MainModule.GetDistanceFromCharacter(rootPart.Position))
                    end
                end
            else
                -- Удаляем ESP если игрок мертв
                local espKey = "Player_" .. player.UserId
                if MainModule.ESPCache[espKey] then
                    MainModule.ESPCache[espKey]:Destroy()
                    MainModule.ESPCache[espKey] = nil
                end
            end
        end
    end
end

function MainModule.UpdateHidersESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player:GetAttribute("IsHider") then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                
                if humanoid and humanoid.Health > 0 and rootPart then
                    local espKey = "Hider_" .. player.UserId
                    
                    if not MainModule.ESPCache[espKey] then
                        MainModule.ESPCache[espKey] = MainModule.CreateESP({
                            Object = character,
                            Text = player.Name .. " (Hider)",
                            Color = Color3.fromRGB(0, 255, 255),
                            Type = "Hider",
                            Player = player
                        })
                    else
                        local esp = MainModule.ESPCache[espKey]
                        if esp and esp.Update then
                            esp:Update(player.Name .. " (Hider) [" .. math.floor(humanoid.Health) .. " HP]",
                                      MainModule.GetDistanceFromCharacter(rootPart.Position))
                        end
                    end
                else
                    local espKey = "Hider_" .. player.UserId
                    if MainModule.ESPCache[espKey] then
                        MainModule.ESPCache[espKey]:Destroy()
                        MainModule.ESPCache[espKey] = nil
                    end
                end
            end
        end
    end
end

function MainModule.UpdateSeekersESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player:GetAttribute("IsHunter") then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                
                if humanoid and humanoid.Health > 0 and rootPart then
                    local espKey = "Seeker_" .. player.UserId
                    
                    if not MainModule.ESPCache[espKey] then
                        MainModule.ESPCache[espKey] = MainModule.CreateESP({
                            Object = character,
                            Text = player.Name .. " (Seeker)",
                            Color = Color3.fromRGB(255, 0, 0),
                            Type = "Seeker",
                            Player = player
                        })
                    else
                        local esp = MainModule.ESPCache[espKey]
                        if esp and esp.Update then
                            esp:Update(player.Name .. " (Seeker) [" .. math.floor(humanoid.Health) .. " HP]",
                                      MainModule.GetDistanceFromCharacter(rootPart.Position))
                        end
                    end
                else
                    local espKey = "Seeker_" .. player.UserId
                    if MainModule.ESPCache[espKey] then
                        MainModule.ESPCache[espKey]:Destroy()
                        MainModule.ESPCache[espKey] = nil
                    end
                end
            end
        end
    end
end

function MainModule.UpdateKeysESP()
    for _, key in ipairs(Workspace:GetDescendants()) do
        if key:IsA("Model") and (key.Name:lower():find("key") or key:GetAttribute("KeyType")) then
            local primaryPart = key.PrimaryPart
            if primaryPart then
                local espKey = "Key_" .. key:GetFullName()
                
                if not MainModule.ESPCache[espKey] then
                    MainModule.ESPCache[espKey] = MainModule.CreateESP({
                        Object = key,
                        Text = "Key",
                        Color = Color3.fromRGB(255, 255, 0),
                        Type = "Key"
                    })
                else
                    local esp = MainModule.ESPCache[espKey]
                    if esp and esp.Update then
                        esp:Update("Key", MainModule.GetDistanceFromCharacter(primaryPart.Position))
                    end
                end
            end
        end
    end
end

function MainModule.UpdateDoorsESP()
    for _, door in ipairs(Workspace:GetDescendants()) do
        if door:IsA("Model") and door.Name == "FullDoorAnimated" then
            local primaryPart = door.PrimaryPart
            if primaryPart then
                local keyNeeded = door:GetAttribute("KeyNeeded") or "None"
                local espKey = "Door_" .. door:GetFullName()
                
                if not MainModule.ESPCache[espKey] then
                    MainModule.ESPCache[espKey] = MainModule.CreateESP({
                        Object = door,
                        Text = "Door (Key: " .. keyNeeded .. ")",
                        Color = Color3.fromRGB(255, 165, 0),
                        Type = "Door"
                    })
                else
                    local esp = MainModule.ESPCache[espKey]
                    if esp and esp.Update then
                        esp:Update("Door (Key: " .. keyNeeded .. ")", 
                                  MainModule.GetDistanceFromCharacter(primaryPart.Position))
                    end
                end
            end
        end
    end
end

function MainModule.UpdateEscapeDoorsESP()
    for _, door in ipairs(Workspace:GetDescendants()) do
        if door:IsA("Model") and door.Name == "EXITDOOR" and door:GetAttribute("CANESCAPE") then
            local primaryPart = door.PrimaryPart
            if primaryPart then
                local espKey = "EscapeDoor_" .. door:GetFullName()
                
                if not MainModule.ESPCache[espKey] then
                    MainModule.ESPCache[espKey] = MainModule.CreateESP({
                        Object = door,
                        Text = "Escape Door",
                        Color = Color3.fromRGB(0, 255, 0),
                        Type = "EscapeDoor"
                    })
                else
                    local esp = MainModule.ESPCache[espKey]
                    if esp and esp.Update then
                        esp:Update("Escape Door", MainModule.GetDistanceFromCharacter(primaryPart.Position))
                    end
                end
            end
        end
    end
end

function MainModule.UpdateGuardsESP()
    -- Поиск NPC гвардов
    for _, npc in ipairs(Workspace:GetChildren()) do
        if npc:IsA("Model") and (npc.Name:lower():find("guard") or npc:FindFirstChild("GuardAI")) then
            local humanoid = npc:FindFirstChild("Humanoid")
            local rootPart = npc:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                local espKey = "Guard_" .. npc:GetFullName()
                
                if not MainModule.ESPCache[espKey] then
                    MainModule.ESPCache[espKey] = MainModule.CreateESP({
                        Object = npc,
                        Text = "Guard",
                        Color = Color3.fromRGB(255, 0, 255),
                        Type = "Guard"
                    })
                else
                    local esp = MainModule.ESPCache[espKey]
                    if esp and esp.Update then
                        esp:Update("Guard [" .. math.floor(humanoid.Health) .. " HP]",
                                  MainModule.GetDistanceFromCharacter(rootPart.Position))
                    end
                end
            else
                local espKey = "Guard_" .. npc:GetFullName()
                if MainModule.ESPCache[espKey] then
                    MainModule.ESPCache[espKey]:Destroy()
                    MainModule.ESPCache[espKey] = nil
                end
            end
        end
    end
end

function MainModule.CreateESP(args)
    local ESPManager = {
        Object = args.Object,
        Type = args.Type,
        Player = args.Player,
        Highlights = {},
        Connections = {}
    }
    
    -- Создаем Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "CreonESP_Highlight"
    highlight.Adornee = ESPManager.Object
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = args.Color
    highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
    highlight.OutlineColor = args.Color
    highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
    highlight.Enabled = MainModule.Misc.ESPHighlight
    highlight.Parent = MainModule.ESPFolder
    
    table.insert(MainModule.ESPHighlights, highlight)
    table.insert(ESPManager.Highlights, highlight)
    
    -- Создаем BillboardGui для текста
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "CreonESP_Billboard"
    billboardGui.Adornee = ESPManager.Object.PrimaryPart or ESPManager.Object:FindFirstChild("HumanoidRootPart") or ESPManager.Object
    billboardGui.Size = UDim2.new(0, 200, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.MaxDistance = 1000
    billboardGui.Parent = MainModule.ESPFolder
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "CreonESP_Text"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = args.Text
    textLabel.TextColor3 = args.Color
    textLabel.TextSize = MainModule.Misc.ESPTextSize
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextWrapped = true
    textLabel.Parent = billboardGui
    
    ESPManager.BillboardGui = billboardGui
    ESPManager.TextLabel = textLabel
    
    -- Функция обновления
    function ESPManager.Update(text, distance)
        if MainModule.Misc.ESPDistance and distance then
            textLabel.Text = string.format("%s\n[%d studs]", text, math.floor(distance))
        else
            textLabel.Text = text
        end
        
        -- Обновляем видимость в зависимости от дистанции
        if distance and distance > 500 then
            billboardGui.Enabled = false
            highlight.Enabled = false
        else
            billboardGui.Enabled = true
            highlight.Enabled = MainModule.Misc.ESPHighlight
        end
        
        -- Обновляем прозрачность
        highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
        highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
        textLabel.TextSize = MainModule.Misc.ESPTextSize
    end
    
    -- Функция уничтожения
    function ESPManager.Destroy()
        for _, conn in pairs(ESPManager.Connections) do
            pcall(function() conn:Disconnect() end)
        end
        
        for _, hl in pairs(ESPManager.Highlights) do
            pcall(function() hl:Destroy() end)
        end
        
        if billboardGui then
            pcall(function() billboardGui:Destroy() end)
        end
        
        -- Удаляем из кэша
        for key, esp in pairs(MainModule.ESPCache) do
            if esp == ESPManager then
                MainModule.ESPCache[key] = nil
                break
            end
        end
    end
    
    -- Добавляем слушатель на уничтожение объекта
    local destroyedConn = ESPManager.Object.Destroying:Connect(function()
        ESPManager:Destroy()
    end)
    table.insert(ESPManager.Connections, destroyedConn)
    
    -- Если это игрок, добавляем слушатель на изменение атрибутов
    if ESPManager.Player then
        local attributeConn = ESPManager.Player:GetAttributeChangedSignal("IsHider"):Connect(function()
            ESPManager:Destroy()
        end)
        table.insert(ESPManager.Connections, attributeConn)
    end
    
    -- Первоначальное обновление
    local distance = MainModule.GetDistanceFromCharacter(ESPManager.Object.PrimaryPart and ESPManager.Object.PrimaryPart.Position or ESPManager.Object.Position)
    ESPManager:Update(args.Text, distance)
    
    -- Добавляем в таблицу
    table.insert(MainModule.ESPTable[args.Type], ESPManager)
    
    return ESPManager
end

function MainModule.GetDistanceFromCharacter(position)
    local character = LocalPlayer.Character
    if not character then return 0 end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return 0 end
    
    return (rootPart.Position - position).Magnitude
end

-- Функция для проверки, есть ли у игрока нож
local function playerHasKnife(player)
    if not player or not player.Character then return false end
    
    for _, tool in pairs(player.Character:GetChildren()) do
        if tool:IsA("Tool") then
            local toolName = tool.Name:lower()
            if toolName:find("knife") or toolName:find("fork") or toolName:find("dagger") or toolName:find("нож") then
                return true
            end
        end
    end
    
    if player:FindFirstChild("Backpack") then
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local toolName = tool.Name:lower()
                if toolName:find("knife") or toolName:find("fork") or toolName:find("dagger") or toolName:find("нож") then
                    return true
                end
            end
        end
    end
    
    return false
end

-- Bypass Ragdoll функция (исправленная)
function MainModule.ToggleBypassRagdoll(enabled)
    MainModule.Misc.BypassRagdollEnabled = enabled
    
    if bypassRagdollConnection then
        bypassRagdollConnection:Disconnect()
        bypassRagdollConnection = nil
    end
    
    if MainModule.Misc.AntiRagdollLoop then
        task.cancel(MainModule.Misc.AntiRagdollLoop)
        MainModule.Misc.AntiRagdollLoop = nil
    end
    
    if enabled then
        -- Функция Bypass Ragdoll
        local function bypassRagdollFunc()
            pcall(function()
                local Character = LocalPlayer.Character
                if not Character then return end
                
                local Humanoid = Character:FindFirstChild("Humanoid")
                local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                
                if not (Humanoid and HumanoidRootPart) then return end

                -- Мягкое удаление Ragdoll объектов
                for _, child in ipairs(Character:GetChildren()) do
                    if child.Name == "Ragdoll" then
                        task.spawn(function()
                            for i = 1, 10 do
                                if child and child.Parent then
                                    for _, part in pairs(child:GetChildren()) do
                                        if part:IsA("BasePart") then
                                            part.Transparency = part.Transparency + 0.1
                                        end
                                    end
                                    task.wait(0.05)
                                end
                            end
                            pcall(function() child:Destroy() end)
                        end)
                        
                        Humanoid.PlatformStand = false
                        Humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end

                -- Удаляем только вредоносные папки
                local harmfulFolders = {"RotateDisabled", "RagdollWakeupImmunity"}
                for _, folderName in pairs(harmfulFolders) do
                    local folder = Character:FindFirstChild(folderName)
                    if folder then
                        folder:Destroy()
                    end
                end
            end)
        end
        
        -- Создаем основной цикл
        MainModule.Misc.AntiRagdollLoop = task.spawn(function()
            while MainModule.Misc.BypassRagdollEnabled do
                bypassRagdollFunc()
                task.wait(0.1)
            end
        end)
        
        -- Слушатель для мгновенного удаления новых Ragdoll объектов
        MainModule.Misc.RagdollBlockConn = LocalPlayer.CharacterAdded:Connect(function(char)
            char.ChildAdded:Connect(function(child)
                if child.Name == "Ragdoll" and MainModule.Misc.BypassRagdollEnabled then
                    task.wait(0.1)
                    pcall(function() child:Destroy() end)
                    
                    local humanoid = char:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid.PlatformStand = false
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end
            end)
        end)
        
        -- Одноразовое выполнение
        bypassRagdollFunc()
    else
        -- Отключаем слушатели
        if MainModule.Misc.RagdollBlockConn then
            MainModule.Misc.RagdollBlockConn:Disconnect()
            MainModule.Misc.RagdollBlockConn = nil
        end
    end
end

-- Новый AutoDodge (на основе Bypass Ragdoll)
function MainModule.ToggleAutoDodge(enabled)
    MainModule.HNS.AutoDodgeEnabled = enabled
    
    if hnsAutoDodgeConnection then
        hnsAutoDodgeConnection:Disconnect()
        hnsAutoDodgeConnection = nil
    end
    
    if enabled then
        hnsAutoDodgeConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.AutoDodgeEnabled then return end
            
            local currentTime = tick()
            if currentTime - MainModule.HNS.LastDodgeTime < MainModule.HNS.DodgeCooldown then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                
                if not rootPart or not humanoid or humanoid.Health <= 0 then return end
                
                -- Проверяем, есть ли у нас нож
                local hasKnife = false
                for _, tool in pairs(character:GetChildren()) do
                    if tool:IsA("Tool") then
                        local toolName = tool.Name:lower()
                        if toolName:find("knife") or toolName:find("dagger") then
                            hasKnife = true
                            break
                        end
                    end
                end
                
                if not hasKnife then return end
                
                -- Проверяем, не пытается ли кто-то физически взаимодействовать с нами
                local shouldDodge = false
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local targetCharacter = player.Character
                        local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
                        
                        if targetRoot then
                            local distance = (rootPart.Position - targetRoot.Position).Magnitude
                            
                            -- Если игрок слишком близко и движется быстро
                            if distance < 10 and targetRoot.Velocity.Magnitude > 20 then
                                shouldDodge = true
                                break
                            end
                        end
                    end
                end
                
                -- Проверяем физические объекты
                for _, part in pairs(Workspace:GetDescendants()) do
                    if part:IsA("BasePart") and part.Velocity.Magnitude > 30 then
                        local distance = (rootPart.Position - part.Position).Magnitude
                        if distance < 15 then
                            shouldDodge = true
                            break
                        end
                    end
                end
                
                if shouldDodge then
                    -- Используем слот 1 для доджа
                    if UserInputService.TouchEnabled then
                        -- Для мобильных
                        pcall(function()
                            local backpack = LocalPlayer:FindFirstChild("Backpack")
                            if backpack then
                                local tool = backpack:FindFirstChildOfClass("Tool")
                                if tool then
                                    tool.Parent = character
                                    task.wait(0.1)
                                    tool.Parent = backpack
                                end
                            end
                        end)
                    else
                        -- Для ПК
                        pcall(function()
                            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.One, false, game)
                            task.wait(0.05)
                            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.One, false, game)
                        end)
                    end
                    
                    MainModule.HNS.LastDodgeTime = tick()
                    
                    -- Визуальная обратная связь
                    local effect = Instance.new("Part")
                    effect.Size = Vector3.new(5, 0.2, 5)
                    effect.Position = rootPart.Position - Vector3.new(0, 3, 0)
                    effect.Color = Color3.fromRGB(255, 255, 0)
                    effect.Material = Enum.Material.Neon
                    effect.Anchored = true
                    effect.CanCollide = false
                    effect.Transparency = 0.7
                    effect.Parent = Workspace
                    
                    game:GetService("Debris"):AddItem(effect, 0.3)
                end
            end)
        end)
    end
end

-- Исправленный HNS Kill Aura
function MainModule.ToggleKillAura(enabled)
    MainModule.HNS.KillAuraEnabled = enabled
    MainModule.HNS.CurrentTarget = nil
    MainModule.HNS.AttachedToTarget = false
    
    if hnsKillAuraConnection then
        hnsKillAuraConnection:Disconnect()
        hnsKillAuraConnection = nil
    end
    
    -- Отключаем шипы при включении
    if enabled then
        MainModule.ToggleDisableSpikes(true)
    else
        MainModule.ToggleDisableSpikes(false)
    end
    
    if enabled then
        hnsKillAuraConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.KillAuraEnabled then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                local HRP = character.HumanoidRootPart
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if not humanoid or humanoid.Health <= 0 then return end
                
                -- Проверяем, держим ли мы нож
                local hasKnife = false
                local knifeTool = nil
                
                for _, tool in pairs(character:GetChildren()) do
                    if tool:IsA("Tool") then
                        local toolName = tool.Name:lower()
                        if toolName:find("knife") or toolName:find("dagger") then
                            hasKnife = true
                            knifeTool = tool
                            break
                        end
                    end
                end
                
                if not hasKnife then return end
                
                -- Если нет цели или цель умерла, ищем новую
                if not MainModule.HNS.CurrentTarget or not MainModule.HNS.CurrentTarget.Character or 
                   not MainModule.HNS.CurrentTarget.Character:FindFirstChild("HumanoidRootPart") or
                   MainModule.HNS.CurrentTarget.Character.Humanoid.Health <= 0 then
                    
                    MainModule.HNS.CurrentTarget = nil
                    MainModule.HNS.AttachedToTarget = false
                    
                    -- Ищем ближайшего хайдера в радиусе 300
                    local nearestDistance = 300
                    local nearestHider = nil
                    
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player:GetAttribute("IsHider") then
                            local targetCharacter = player.Character
                            if targetCharacter then
                                local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
                                local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
                                
                                if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                                    local distance = (HRP.Position - targetRoot.Position).Magnitude
                                    
                                    if distance < nearestDistance then
                                        nearestDistance = distance
                                        nearestHider = player
                                    end
                                end
                            end
                        end
                    end
                    
                    if nearestHider then
                        MainModule.HNS.CurrentTarget = nearestHider
                        -- Сохраняем относительную позицию
                        local targetRoot = nearestHider.Character.HumanoidRootPart
                        MainModule.HNS.AttachmentCFrame = targetRoot.CFrame:Inverse() * HRP.CFrame
                        MainModule.HNS.AttachedToTarget = true
                    end
                end
                
                -- Если есть цель, прикрепляемся к ней
                if MainModule.HNS.CurrentTarget and MainModule.HNS.CurrentTarget.Character then
                    local targetRoot = MainModule.HNS.CurrentTarget.Character.HumanoidRootPart
                    if targetRoot then
                        -- Обновляем позицию относительно цели
                        HRP.CFrame = targetRoot.CFrame * MainModule.HNS.AttachmentCFrame
                        
                        -- Поворачиваемся к цели
                        local direction = (targetRoot.Position - HRP.Position).Unit
                        local lookVector = Vector3.new(direction.X, 0, direction.Z)
                        if lookVector.Magnitude > 0 then
                            HRP.CFrame = CFrame.new(HRP.Position, HRP.Position + lookVector)
                        end
                        
                        -- Периодически атакуем
                        local currentTime = tick()
                        if currentTime - MainModule.HNS.LastKillTime > MainModule.HNS.KillCooldown then
                            if knifeTool then
                                local remoteEvent = knifeTool:FindFirstChild("RemoteEvent")
                                if remoteEvent then
                                    remoteEvent:FireServer()
                                end
                            end
                            MainModule.HNS.LastKillTime = currentTime
                        end
                    end
                end
            end)
        end)
    end
end

-- Disable/Remove Spikes
function MainModule.ToggleDisableSpikes(enabled)
    MainModule.HNS.DisableSpikesEnabled = enabled
    
    if enabled then
        pcall(function()
            local spikes = Workspace:FindFirstChild("HideAndSeekMap") and 
                          Workspace.HideAndSeekMap:FindFirstChild("KillingParts")
            
            if spikes then
                for _, spike in pairs(spikes:GetChildren()) do
                    if spike:IsA("BasePart") then
                        MainModule.HNS.OriginalSpikeData[spike] = {
                            Transparency = spike.Transparency,
                            CanTouch = spike.CanTouch
                        }
                        spike.Transparency = 1
                        spike.CanTouch = false
                    end
                end
            end
        end)
    else
        pcall(function()
            local spikes = Workspace:FindFirstChild("HideAndSeekMap") and 
                          Workspace.HideAndSeekMap:FindFirstChild("KillingParts")
            
            if spikes then
                for spike, data in pairs(MainModule.HNS.OriginalSpikeData) do
                    if spike and spike.Parent then
                        spike.Transparency = data.Transparency
                        spike.CanTouch = data.CanTouch
                    end
                end
                MainModule.HNS.OriginalSpikeData = {}
            end
        end)
    end
end

-- Исправленный Guards
function MainModule.SetGuardType(guardType)
    -- Исправляем выбор гварда
    local guardTypes = {
        "Circle",
        "Triangle", 
        "Square"
    }
    
    -- Проверяем, есть ли тип в списке
    for _, typeName in ipairs(guardTypes) do
        if typeName:lower() == guardType:lower() then
            MainModule.Guards.SelectedGuard = typeName
            return typeName
        end
    end
    
    -- Если не нашли, используем Circle по умолчанию
    MainModule.Guards.SelectedGuard = "Circle"
    return "Circle"
end

function MainModule.SpawnAsGuard()
    local guardType = MainModule.Guards.SelectedGuard
    
    -- Исправляем название гварда для сервера
    if guardType == "Triangle" then
        guardType = "Triangle"
    elseif guardType == "Square" then
        guardType = "Square"
    else
        guardType = "Circle"
    end
    
    local args = {
        {
            AttemptToSpawnAsGuard = guardType
        }
    }
    
    pcall(function()
        local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlayableGuardRemote")
        if remote then
            remote:FireServer(unpack(args))
        end
    end)
    
    return guardType
end

-- Исправленный Hitbox Expander (без Z-Index)
function MainModule.ToggleHitboxExpander(enabled)
    MainModule.Guards.HitboxExpander = enabled
    
    if hitboxConnection then
        hitboxConnection:Disconnect()
        hitboxConnection = nil
    end
    
    if enabled then
        local HITBOX_SIZE = 10
        
        hitboxConnection = RunService.Stepped:Connect(function()
            if not MainModule.Guards.HitboxExpander then 
                -- Восстанавливаем оригинальные размеры
                for player, originalSizes in pairs(MainModule.Guards.OriginalHitboxes) do
                    if player and player.Character then
                        for partName, originalSize in pairs(originalSizes) do
                            local part = player.Character:FindFirstChild(partName)
                            if part and part:IsA("BasePart") then
                                part.Size = originalSize
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
                        -- Сохраняем оригинальные размеры если еще не сохранили
                        if not MainModule.Guards.OriginalHitboxes[player] then
                            MainModule.Guards.OriginalHitboxes[player] = {}
                            
                            local torso = player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("Torso")
                            if torso and torso:IsA("BasePart") then
                                MainModule.Guards.OriginalHitboxes[player]["Torso"] = torso.Size
                            end
                            
                            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                            if rootPart and rootPart:IsA("BasePart") then
                                MainModule.Guards.OriginalHitboxes[player]["HumanoidRootPart"] = rootPart.Size
                            end
                        end
                        
                        -- Увеличиваем хитбоксы
                        local torso = player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("Torso")
                        if torso and torso:IsA("BasePart") then
                            torso.Size = Vector3.new(HITBOX_SIZE, HITBOX_SIZE, HITBOX_SIZE)
                        end
                        
                        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                        if rootPart and rootPart:IsA("BasePart") then
                            rootPart.Size = Vector3.new(HITBOX_SIZE, HITBOX_SIZE, HITBOX_SIZE)
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
                        end
                    end
                end
            end
            MainModule.Guards.OriginalHitboxes = {}
        end)
    end
end

-- Исправленный RLGL GodMode
function MainModule.ToggleGodMode(enabled)
    MainModule.RLGL.GodMode = enabled
    
    if godModeConnection then
        godModeConnection:Disconnect()
        godModeConnection = nil
    end
    
    if enabled then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                MainModule.RLGL.LastHealth = humanoid.Health
                MainModule.RLGL.OriginalHeight = character.HumanoidRootPart.Position.Y
                
                -- Поднимаемся на высоту GodMode
                local currentPos = character.HumanoidRootPart.Position
                character.HumanoidRootPart.CFrame = CFrame.new(currentPos.X, 1184.9, currentPos.Z)
            end
        end
        
        godModeConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.RLGL.GodMode then return end
            
            local currentTime = tick()
            if currentTime - MainModule.RLGL.LastDamageCheck < MainModule.RLGL.DamageCheckRate then return end
            MainModule.RLGL.LastDamageCheck = currentTime
            
            local character = LocalPlayer.Character
            if not character then return end
            
            local humanoid = character:FindFirstChild("Humanoid")
            if not humanoid then return end
            
            -- Проверяем, получили ли мы урон (сравниваем с последним сохраненным здоровьем)
            if humanoid.Health < MainModule.RLGL.LastHealth then
                -- Получили урон в режиме GodMode - телепортируем
                MainModule.RLGL.TeleportOnDamage = true
                
                -- Телепортируем на указанные координаты
                character.HumanoidRootPart.CFrame = CFrame.new(186.7, 54.3, -100.6)
                humanoid.Health = humanoid.MaxHealth
                
                -- Отключаем GodMode
                task.wait(0.5)
                MainModule.ToggleGodMode(false)
                return
            end
            
            -- Обновляем последнее здоровье
            MainModule.RLGL.LastHealth = humanoid.Health
            
            -- Поддерживаем высоту GodMode
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart and rootPart.Position.Y < 1100 then
                local currentPos = rootPart.Position
                rootPart.CFrame = CFrame.new(currentPos.X, 1184.9, currentPos.Z)
            end
        end)
    else
        -- Только если это не выключение из-за урона
        if not MainModule.RLGL.TeleportOnDamage then
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") and MainModule.RLGL.OriginalHeight then
                local currentPos = character.HumanoidRootPart.Position
                character.HumanoidRootPart.CFrame = CFrame.new(currentPos.X, MainModule.RLGL.OriginalHeight, currentPos.Z)
            end
        end
        MainModule.RLGL.TeleportOnDamage = false
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

-- Instant Rebel функция
function MainModule.ToggleRebel(enabled)
    MainModule.Rebel.Enabled = enabled
    
    if enabled then
        _G.InstantRebel = true
        
        task.spawn(function()
            while _G.InstantRebel and MainModule.Rebel.Enabled do
                pcall(function()
                    local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlayableGuardRemote")
                    local args = {
                        {
                            AttemptToSpawnAsGuard = "Rebel"
                        }
                    }
                    remote:FireServer(unpack(args))
                end)
                task.wait(0.1)
            end
            _G.InstantRebel = nil
        end)
    else
        _G.InstantRebel = nil
    end
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

-- Guards функции
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

-- Jump Rope функции
function MainModule.ToggleDeleteRope(enabled)
    MainModule.JumpRope.DeleteRope = enabled
    
    if enabled then
        local function deleteRope()
            pcall(function()
                local rope = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("rope")
                if rope then
                    rope:Destroy()
                else
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj.Name:lower() == "rope" or obj.Name:lower():find("jump") then
                            obj:Destroy()
                            break
                        end
                    end
                end
            end)
        end
        
        deleteRope()
        
        if MainModule.JumpRope.JumpRopeConnection then
            MainModule.JumpRope.JumpRopeConnection:Disconnect()
        end
        
        MainModule.JumpRope.JumpRopeConnection = RunService.Heartbeat:Connect(function()
            if MainModule.JumpRope.DeleteRope then
                deleteRope()
            end
        end)
    else
        if MainModule.JumpRope.JumpRopeConnection then
            MainModule.JumpRope.JumpRopeConnection:Disconnect()
            MainModule.JumpRope.JumpRopeConnection = nil
        end
    end
end

function MainModule.TeleportToJumpRopeEnd()
    pcall(function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(720.896057, 198.628311, 921.170654)
        end
    end)
end

function MainModule.TeleportToJumpRopeStart()
    pcall(function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(615.284424, 192.274277, 920.952515)
        end
    end)
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
        noCoondownConnection = nil
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
    local connections = {
        speedConnection, autoFarmConnection, godModeConnection, instaInteractConnection,
        noCooldownConnection, antiStunConnection, rapidFireConnection, infiniteAmmoConnection,
        hitboxConnection, autoPullConnection, bypassRagdollConnection,
        hnsKillAuraConnection, hnsKillSpikesConnection, hnsAutoDodgeConnection,
        MainModule.GlassBridge.AntiFallConnection, MainModule.GlassBridge.AntiBreakConnection,
        MainModule.GlassBridge.GlassVisionConnection, MainModule.JumpRope.JumpRopeConnection,
        espUpdateConnection
    }
    
    for _, conn in pairs(connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    
    -- Отменяем задачи
    if MainModule.Misc.AntiRagdollLoop then
        task.cancel(MainModule.Misc.AntiRagdollLoop)
        MainModule.Misc.AntiRagdollLoop = nil
    end
    
    -- Очищаем HNS
    MainModule.HNS.KillAuraEnabled = false
    MainModule.HNS.KillSpikesEnabled = false
    MainModule.HNS.DisableSpikesEnabled = false
    MainModule.HNS.AutoDodgeEnabled = false
    
    -- Восстанавливаем хитбоксы
    if MainModule.Guards.OriginalHitboxes then
        for player, originalSizes in pairs(MainModule.Guards.OriginalHitboxes) do
            if player and player.Character then
                for partName, originalSize in pairs(originalSizes) do
                    local part = player.Character:FindFirstChild(partName)
                    if part and part:IsA("BasePart") then
                        part.Size = originalSize
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
    
    -- Восстанавливаем шипы
    MainModule.ToggleDisableSpikes(false)
    
    -- Очищаем ESP
    MainModule.ToggleESP(false)
end

-- Автоматическая очистка при выходе
game:GetService("Players").LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not game:GetService("Players").LocalPlayer.Parent then
        MainModule.Cleanup()
    end
end)

return MainModule
