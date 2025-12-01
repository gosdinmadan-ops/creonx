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
    OriginalHeight = nil,
    RemoveInjured = false
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
    GlassPlatform = false,
    FakeGlassCover = false
}

MainModule.JumpRope = {
    AntiFail = false,
    TeleportToStart = false,
    TeleportToEnd = false,
    AutoJump = false,
    FreezeRope = false,
    SafePlatform = false,
    AntiFall = false
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

-- ESP System (сильно оптимизированная без лагов)
MainModule.ESPTable = {}
MainModule.ESPFolder = nil
MainModule.ESPUpdateRate = 1.0 -- Очень большое время обновления для оптимизации
MainModule.LastESPUpdate = 0
MainModule.ESPConnection = nil

-- HNS шипы
MainModule.HNSSpikes = {
    Positions = {},
    OriginalPositions = {},
    Disabled = false
}

-- Glass Bridge платформы
MainModule.GlassBridgePlatforms = {}
MainModule.GlassBridgeCover = nil
MainModule.GlassBridgeAntiFallPlatform = nil

-- Jump Rope платформы
MainModule.JumpRopePlatform = nil
MainModule.JumpRopeAntiFallPlatform = nil
MainModule.JumpRopeFreezeConnection = nil

-- RLGL объекты
MainModule.RLGLObjects = {}

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
local rlglRemoveInjuredConnection = nil
local jumpRopeAutoJumpConnection = nil
local jumpRopeAntiFallConnection = nil

-- Локальный игрок
local LocalPlayer = Players.LocalPlayer

-- Оптимизированная ESP System (без лагов, обновление каждые 1+ секунд)
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
        
        -- Сильно оптимизированное обновление ESP (1 раз в секунду)
        MainModule.ESPConnection = RunService.Heartbeat:Connect(function()
            local currentTime = tick()
            if currentTime - MainModule.LastESPUpdate < MainModule.ESPUpdateRate then
                return
            end
            MainModule.LastESPUpdate = currentTime
            
            -- Обновляем ESP только раз в 1 секунду для оптимизации
            pcall(function()
                -- Очищаем старые ESP
                for _, esp in pairs(MainModule.ESPTable) do
                    if esp and esp.Destroy then
                        pcall(function() esp:Destroy() end)
                    end
                end
                MainModule.ESPTable = {}
                
                -- ESP для игроков (только живые)
                if MainModule.Misc.ESPPlayers then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                            if humanoid and humanoid.Health > 0 then
                                -- Только подсветка для оптимизации
                                if MainModule.Misc.ESPHighlight and MainModule.Misc.ESPBoxes then
                                    local highlight = Instance.new("Highlight")
                                    highlight.Name = "ESP_Highlight"
                                    highlight.Adornee = player.Character
                                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    highlight.FillColor = Color3.fromRGB(0, 170, 255)
                                    highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
                                    highlight.OutlineColor = Color3.fromRGB(0, 170, 255)
                                    highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
                                    highlight.Parent = MainModule.ESPFolder
                                    
                                    MainModule.ESPTable[player] = {
                                        Highlight = highlight,
                                        Destroy = function()
                                            if highlight then highlight:Destroy() end
                                        end
                                    }
                                end
                                
                                -- Billboard только если нужно
                                if MainModule.Misc.ESPNames then
                                    local billboard = Instance.new("BillboardGui")
                                    billboard.Name = "ESP_Billboard"
                                    local root = player.Character:FindFirstChild("HumanoidRootPart") or player.Character.PrimaryPart
                                    if root then
                                        billboard.Adornee = root
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
                                        
                                        MainModule.ESPTable[player .. "_text"] = {
                                            Billboard = billboard,
                                            Destroy = function()
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
                pcall(function() esp:Destroy() end)
            end
        end
        MainModule.ESPTable = {}
        
        if MainModule.ESPFolder then
            MainModule.ESPFolder:Destroy()
            MainModule.ESPFolder = nil
        end
    end
end

-- Функция для удаления Injured и Stun объектов
function MainModule.RemoveInjuredStun()
    local count = 0
    
    -- Проходим по всем объектам в workspace
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local nameLower = obj.Name:lower()
        
        -- Проверяем, содержит ли имя "injuredwalking" или "stun"
        if nameLower == "injuredwalking" or nameLower == "stun" then
            pcall(function() obj:Destroy() end)
            count += 1
        end
    end
    
    return count
end

-- Toggle для постоянного удаления Injured/Stun
function MainModule.ToggleRemoveInjured(enabled)
    MainModule.RLGL.RemoveInjured = enabled
    
    if rlglRemoveInjuredConnection then
        rlglRemoveInjuredConnection:Disconnect()
        rlglRemoveInjuredConnection = nil
    end
    
    if enabled then
        rlglRemoveInjuredConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.RLGL.RemoveInjured then return end
            
            pcall(function()
                -- Ищем и удаляем Injured/Stun каждые 0.5 секунд
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    local nameLower = obj.Name:lower()
                    if nameLower == "injuredwalking" or nameLower == "stun" then
                        obj:Destroy()
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
        player.Character.HumanoidRootPart.CFrame = CFrame.new(615.284424, 192.274277, 920.952515)
    end
end

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

function MainModule.ToggleAutoJump(enabled)
    MainModule.JumpRope.AutoJump = enabled
    
    if jumpRopeAutoJumpConnection then
        jumpRopeAutoJumpConnection:Disconnect()
        jumpRopeAutoJumpConnection = nil
    end
    
    if enabled then
        jumpRopeAutoJumpConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.JumpRope.AutoJump then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if not humanoid or humanoid.Health <= 0 then return end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if not rootPart then return end
                
                -- Проверяем позицию для автоматического прыжка
                if rootPart.Position.Y > 190 and rootPart.Position.Y < 210 then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end)
    end
end

function MainModule.ToggleFreezeRope(enabled)
    MainModule.JumpRope.FreezeRope = enabled
    
    if MainModule.JumpRopeFreezeConnection then
        MainModule.JumpRopeFreezeConnection:Disconnect()
        MainModule.JumpRopeFreezeConnection = nil
    end
    
    if enabled then
        MainModule.JumpRopeFreezeConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.JumpRope.FreezeRope then return end
            
            pcall(function()
                local rope = Workspace:FindFirstChild("Effects") and Workspace.Effects:FindFirstChild("rope")
                if rope then
                    for _, v in ipairs(rope:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.Anchored = true
                            v.Velocity = Vector3.zero
                            v.RotVelocity = Vector3.zero
                        elseif v:IsA("Constraint") or v:IsA("RopeConstraint") or v:IsA("Motor6D") then
                            v.Enabled = false
                        end
                    end
                end
            end)
        end)
    else
        -- Размораживаем веревку
        pcall(function()
            local rope = Workspace:FindFirstChild("Effects") and Workspace.Effects:FindFirstChild("rope")
            if rope then
                for _, v in ipairs(rope:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.Anchored = false
                    elseif v:IsA("Constraint") or v:IsA("RopeConstraint") or v:IsA("Motor6D") then
                        v.Enabled = true
                    end
                end
            end
        end)
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
                -- Удаляем объекты FailDetection
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj.Name == "FailDetection" or obj.Name:lower():find("fail") then
                        obj:Destroy()
                    end
                end
            end)
        end)
    end
end

function MainModule.ToggleJumpRopeAntiFall(enabled)
    MainModule.JumpRope.AntiFall = enabled
    
    if jumpRopeAntiFallConnection then
        jumpRopeAntiFallConnection:Disconnect()
        jumpRopeAntiFallConnection = nil
    end
    
    if enabled then
        jumpRopeAntiFallConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.JumpRope.AntiFall then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if not rootPart then return end
                
                -- Анти-падение для Jump Rope
                if rootPart.Position.Y < 190 then
                    rootPart.CFrame = CFrame.new(720.896057, 198.628311, 921.170654)
                end
            end)
        end)
    end
end

function MainModule.ToggleJumpRopeSafePlatform(enabled)
    MainModule.JumpRope.SafePlatform = enabled
    
    if MainModule.JumpRopePlatform then
        MainModule.JumpRopePlatform:Destroy()
        MainModule.JumpRopePlatform = nil
    end
    
    if enabled then
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local HRP = character:WaitForChild("HumanoidRootPart")
        
        MainModule.JumpRopePlatform = Instance.new("Part")
        MainModule.JumpRopePlatform.Name = "JumpRopePlatform"
        MainModule.JumpRopePlatform.Size = Vector3.new(50, 1, 50)
        MainModule.JumpRopePlatform.Anchored = true
        MainModule.JumpRopePlatform.CanCollide = true
        MainModule.JumpRopePlatform.Transparency = 0.6
        MainModule.JumpRopePlatform.Material = Enum.Material.Neon
        MainModule.JumpRopePlatform.Color = Color3.fromRGB(0, 255, 0)
        MainModule.JumpRopePlatform.Position = Vector3.new(720.896057, 192, 921.170654)
        MainModule.JumpRopePlatform.Parent = Workspace
    end
end

-- Glass Bridge функции
function MainModule.TeleportToGlassBridgeEnd()
    local player = LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-196.372467, 522.192139, -1534.20984)
    end
end

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
                
                -- Создаем защитные платформы под стеклами
                for _, v in pairs(GlassHolder:GetChildren()) do
                    for _, j in pairs(v:GetChildren()) do
                        if j:IsA("Model") and j.PrimaryPart then
                            -- Удаляем атрибут ломания
                            if j.PrimaryPart:GetAttribute("exploitingisevil") ~= nil then
                                j.PrimaryPart:SetAttribute("exploitingisevil", nil)
                            end
                            
                            -- Создаем защитную платформу под стеклом
                            local platformExists = false
                            for _, platform in pairs(MainModule.GlassBridgePlatforms) do
                                if platform and platform.Parent and platform.Name == "GlassBridgeProtection_" .. j.Name then
                                    platformExists = true
                                    break
                                end
                            end
                            
                            if not platformExists then
                                local protection = Instance.new("Part")
                                protection.Name = "GlassBridgeProtection_" .. j.Name
                                protection.Size = Vector3.new(10, 2, 10)
                                protection.CFrame = j.PrimaryPart.CFrame * CFrame.new(0, -3, 0)
                                protection.Anchored = true
                                protection.CanCollide = true
                                protection.Transparency = 0.8
                                protection.Material = Enum.Material.Neon
                                protection.Color = Color3.fromRGB(0, 255, 0)
                                protection.Parent = Workspace
                                table.insert(MainModule.GlassBridgePlatforms, protection)
                            end
                        end
                    end
                end
            end)
        end)
    else
        -- Удаляем защитные платформы
        for _, platform in pairs(MainModule.GlassBridgePlatforms) do
            if platform and platform.Parent then
                platform:Destroy()
            end
        end
        MainModule.GlassBridgePlatforms = {}
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

function MainModule.ToggleGlassBridgePlatform(enabled)
    MainModule.GlassBridge.GlassPlatform = enabled
    
    if enabled then
        -- Создаем защитную платформу под всем мостом
        if MainModule.GlassBridgeAntiFallPlatform then
            MainModule.GlassBridgeAntiFallPlatform:Destroy()
        end
        
        MainModule.GlassBridgeAntiFallPlatform = Instance.new("Part")
        MainModule.GlassBridgeAntiFallPlatform.Name = "GlassBridgeAntiFallPlatform"
        MainModule.GlassBridgeAntiFallPlatform.Size = Vector3.new(200, 5, 200)
        MainModule.GlassBridgeAntiFallPlatform.Position = Vector3.new(-200, 510, -1534)
        MainModule.GlassBridgeAntiFallPlatform.Anchored = true
        MainModule.GlassBridgeAntiFallPlatform.CanCollide = true
        MainModule.GlassBridgeAntiFallPlatform.Transparency = 0.7
        MainModule.GlassBridgeAntiFallPlatform.Material = Enum.Material.Neon
        MainModule.GlassBridgeAntiFallPlatform.Color = Color3.fromRGB(0, 0, 255)
        MainModule.GlassBridgeAntiFallPlatform.Parent = Workspace
    else
        if MainModule.GlassBridgeAntiFallPlatform then
            MainModule.GlassBridgeAntiFallPlatform:Destroy()
            MainModule.GlassBridgeAntiFallPlatform = nil
        end
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
    MainModule.GlassBridgeCover.Transparency = 0.5
    MainModule.GlassBridgeCover.Material = Enum.Material.SmoothPlastic
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

-- Остальные функции остаются без изменений (Speed, Guards, HNS, Dalgona, etc.)
-- ...

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

-- Hitbox Expander функция
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
        local HITBOX_SIZE = 1000
        
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
                                -- Делаем полностью прозрачным
                                part.Transparency = 1
                                -- Отключаем коллизию
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
                        spike:Destroy()
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

-- Очистка при закрытии
function MainModule.Cleanup()
    -- Отключаем все соединения
    local connections = {
        speedConnection, autoFarmConnection, godModeConnection, instaInteractConnection,
        noCooldownConnection, antiStunConnection, rapidFireConnection, infiniteAmmoConnection,
        hitboxConnection, autoPullConnection, antiBreakConnection, MainModule.ESPConnection,
        hnsAutoPickupConnection, hnsSpikesKillConnection, hnsKillHidersConnection,
        hnsDisableSpikesConnection, jumpRopeAntiFailConnection, glassBridgeESPConnection,
        antiStunRagdollConnection, rlglRemoveInjuredConnection, jumpRopeAutoJumpConnection,
        jumpRopeAntiFallConnection, MainModule.JumpRopeFreezeConnection
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
    
    -- Удаляем платформы
    if MainModule.JumpRopePlatform then
        MainModule.JumpRopePlatform:Destroy()
        MainModule.JumpRopePlatform = nil
    end
    
    if MainModule.GlassBridgeCover then
        MainModule.GlassBridgeCover:Destroy()
        MainModule.GlassBridgeCover = nil
    end
    
    if MainModule.GlassBridgeAntiFallPlatform then
        MainModule.GlassBridgeAntiFallPlatform:Destroy()
        MainModule.GlassBridgeAntiFallPlatform = nil
    end
    
    -- Удаляем защитные платформы Glass Bridge
    for _, platform in pairs(MainModule.GlassBridgePlatforms) do
        if platform and platform.Parent then
            platform:Destroy()
        end
    end
    MainModule.GlassBridgePlatforms = {}
end

-- Автоматическая очистка при выходе
game:GetService("Players").LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not game:GetService("Players").LocalPlayer.Parent then
        MainModule.Cleanup()
    end
end)

return MainModule
