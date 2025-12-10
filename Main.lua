local MainModule = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer

-- Функция для алертов
function MainModule.Alert(message)
    if game:GetService("CoreGui"):FindFirstChild("CreonXAlert") then
        game:GetService("CoreGui").CreonXAlert:Destroy()
    end
    
    local alertGui = Instance.new("ScreenGui")
    alertGui.Name = "CreonXAlert"
    alertGui.Parent = CoreGui
    
    local alertFrame = Instance.new("Frame")
    alertFrame.Size = UDim2.new(0, 300, 0, 100)
    alertFrame.Position = UDim2.new(0.5, -150, 0.8, -50)
    alertFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    alertFrame.BorderSizePixel = 0
    alertFrame.Parent = alertGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = alertFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 100)
    stroke.Thickness = 2
    stroke.Parent = alertFrame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.9, 0, 0.8, 0)
    textLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = message
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextWrapped = true
    textLabel.Parent = alertFrame
    
    task.delay(3, function()
        if alertGui and alertGui.Parent then
            alertGui:Destroy()
        end
    end)
end

-- Функции проверки игр
function MainModule.CheckRLGLGame()
    for _, player in pairs(Players:GetPlayers()) do
        if player:FindFirstChild("Backpack") then
            for _, tool in pairs(player.Backpack:GetChildren()) do
                if tool:IsA("Tool") and (tool.Name == "Pocket Sand" or tool.Name == "PocketSand") then
                    return true
                end
            end
        end
        if player.Character then
            for _, tool in pairs(player.Character:GetChildren()) do
                if tool:IsA("Tool") and (tool.Name == "Pocket Sand" or tool.Name == "PocketSand") then
                    return true
                end
            end
        end
    end
    return false
end

function MainModule.CheckHNSGame()
    for _, player in pairs(Players:GetPlayers()) do
        local hasKnife = false
        local hasDodge = false
        
        if player:FindFirstChild("Backpack") then
            for _, tool in pairs(player.Backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    if tool.Name == "Knife" or tool.Name:lower():find("knife") then
                        hasKnife = true
                    elseif tool.Name == "DODGE!" then
                        hasDodge = true
                    end
                end
            end
        end
        
        if player.Character then
            for _, tool in pairs(player.Character:GetChildren()) do
                if tool:IsA("Tool") then
                    if tool.Name == "Knife" or tool.Name:lower():find("knife") then
                        hasKnife = true
                    elseif tool.Name == "DODGE!" then
                        hasDodge = true
                    end
                end
            end
        end
        
        if hasKnife or hasDodge then
            return true, hasKnife, hasDodge
        end
    end
    return false, false, false
end

function MainModule.CheckZoneKill()
    local player = LocalPlayer
    if not player then return false end
    
    if player:FindFirstChild("Backpack") then
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name == "Knife" or tool.Name:lower():find("knife")) then
                return true
            end
        end
    end
    
    if player.Character then
        for _, tool in pairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name == "Knife" or tool.Name:lower():find("knife")) then
                return true
            end
        end
    end
    
    return false
end

function MainModule.GetHider()
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        if not player:GetAttribute("IsHider") then continue end
        
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") and 
           character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
            return character
        end
    end
    return nil
end

MainModule.SpeedHack = {
    Enabled = false,
    DefaultSpeed = 16,
    CurrentSpeed = 16,
    MaxSpeed = 150,
    MinSpeed = 16
}

MainModule.Noclip = {
    Enabled = false,
    Connection = nil,
    NoclipParts = {}
}

MainModule.AutoDodge = {
    Enabled = false,
    AnimationIds = {
        "rbxassetid://88451099342711",
        "rbxassetid://79649041083405", 
        "rbxassetid://73242877658272",
        "rbxassetid://114928327045353",
        "rbxassetid://135690448001690", 
        "rbxassetid://103355259844069",
        "rbxassetid://125906547773381"
    },
    Connections = {},
    LastDodgeTime = 0,
    DodgeCooldown = 0.6,
    Range = 5,
    RangeSquared = 7 * 7,
    AnimationIdsSet = {},
    PlayersInRange = {},
    LastRangeUpdate = 0,
    RangeUpdateInterval = 0.5
}

MainModule.AutoQTE = {
    AntiStunEnabled = false
}

MainModule.Rebel = {
    Enabled = false,
    Connection = nil,
    LastKillTime = 0,
    KillCooldown = 0.1,
    LastCheckTime = 0,
    CheckCooldown = 0.5
}

MainModule.RLGL = {
    GodMode = false,
    OriginalHeight = nil,
    OriginalPosition = nil,
    LastDamageTime = 0,
    DamageCheckRate = 0.1,
    LastHealth = 100,
    GodModeHeight = 160,
    NormalHeight = 120,
    DamageTeleportPosition = Vector3.new(-903.4, 1184.9, -556),
    StartPosition = Vector3.new(-55.3, 1023.1, -545.8),
    EndPosition = Vector3.new(-214.4, 1023.1, 146.7),
    Connection = nil,
    PocketSandCheckConnection = nil,
    NoPocketSandTime = 0,
    PocketSandActive = false
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
    Connections = {}
}

MainModule.Dalgona = {
    CompleteEnabled = false,
    FreeLighterEnabled = false
}

MainModule.GlassBridge = {
    AntiBreakEnabled = false,
    AntiBreakConnection = nil,
    AntiFallEnabled = false,
    GlassPlatforms = {},
    GlassAntiFallPlatform = nil,
    GlassESPEnabled = false,
    GlassESPConnection = nil,
    EndPosition = Vector3.new(-196.372467, 522.192139, -1534.20984),
    BridgeHeight = 520.4,
    PlatformSize = Vector3.new(10000, 1, 10000)
}

MainModule.TugOfWar = {
    AutoPull = false,
    Connection = nil
}

MainModule.JumpRope = {
    TeleportToEnd = false,
    AntiFallPlatform = nil,
    Connection = nil,
    PlatformSize = Vector3.new(10000, 1, 10000)
}

MainModule.SkySquid = {
    AntiFallPlatform = nil,
    SafePlatform = nil,
    Connection = nil,
    PlatformSize = Vector3.new(10000, 1, 10000)
}

MainModule.VoidKill = {
    Enabled = false,
    AnimationId = "rbxassetid://107989020363293",
    ReturnDelay = 1,
    SavedCFrame = nil,
    ActiveAnimation = false,
    AnimationStartTime = 0,
    AnimationConnection = nil,
    CharacterAddedConnection = nil,
    AnimationStoppedConnections = {},
    AnimationCheckConnection = nil,
    TrackedAnimations = {},
    AntiFallEnabled = false,
    AntiFallPlatform = nil
}

MainModule.SpikesKill = {
    Enabled = false,
    AnimationId = "rbxassetid://105341857343164",
    SpikesPosition = nil,
    PlatformHeightOffset = 5,
    ReturnDelay = 1,
    SavedCFrame = nil,
    ActiveAnimation = false,
    AnimationStartTime = 0,
    AnimationConnection = nil,
    CharacterAddedConnection = nil,
    AnimationStoppedConnections = {},
    AnimationCheckConnection = nil,
    TrackedAnimations = {},
    SafetyCheckConnection = nil,
    OriginalSpikes = {},
    SpikesRemoved = false
}

MainModule.ZoneKill = {
    Enabled = false,
    AnimationId = "rbxassetid://105341857343164",
    TargetPosition = Vector3.new(127.2, 54.6, 4.3),
    ReturnDelay = 1,
    SavedCFrame = nil,
    ActiveAnimation = false,
    AnimationStartTime = 0,
    AnimationConnection = nil,
    CharacterAddedConnection = nil,
    AnimationStoppedConnections = {},
    AnimationCheckConnection = nil,
    TrackedAnimations = {}
}

MainModule.AntiTimeStop = {
    Enabled = false,
    Connection = nil,
    OriginalProperties = {}
}

MainModule.Hitbox = {
    Size = 150,
    Enabled = false,
    Connection = nil,
    ModifiedParts = {}
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
    BypassRagdollEnabled = false,
    RemoveInjuredEnabled = false,
    RemoveStunEnabled = false,
    UnlockDashEnabled = false,
    UnlockPhantomStepEnabled = false,
    LastInjuredNotify = 0,
    LastESPUpdate = 0
}

MainModule.HNS = {
    InfinityStaminaEnabled = false,
    InfinityStaminaConnection = nil,
    HasKnife = false,
    HasDodge = false
}

MainModule.ESP = {
    Players = {},
    Objects = {},
    Connections = {},
    Folder = nil,
    MainConnection = nil,
    UpdateRate = 0.1
}

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

local function SafeDestroy(obj)
    if obj and obj.Parent then
        pcall(function() obj:Destroy() end)
    end
end

local function GetCharacter()
    return LocalPlayer.Character
end

local function GetHumanoid(character)
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart(character)
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function GetDistance(position1, position2)
    if not position1 or not position2 then return math.huge end
    return (position1 - position2).Magnitude
end

local function IsHider(player)
    if not player then return false end
    return player:GetAttribute("IsHider") == true
end

local function IsSeeker(player)
    if not player then return false end
    return player:GetAttribute("IsHunter") == true
end

local function SafeTeleport(position)
    local character = GetCharacter()
    if not character then return false end
    local rootPart = GetRootPart(character)
    if not rootPart then return false end
    
    local currentPosition = rootPart.Position
    local currentCFrame = rootPart.CFrame
    
    rootPart.CFrame = CFrame.new(position)
    return true
end

function MainModule.TeleportToHider()
    if not GetCharacter() then 
        MainModule.Alert("Character not found!")
        return 
    end
    
    local hnsActive, hasKnife, hasDodge = MainModule.CheckHNSGame()
    if not hnsActive then
        MainModule.Alert("Game not running!")
        return
    end
    
    if not IsSeeker(LocalPlayer) then
        MainModule.Alert("You are not a seeker!")
        return
    end
    
    local hider = MainModule.GetHider()
    if not hider then
        MainModule.Alert("No hider found :(")
        return
    end
    
    local character = GetCharacter()
    if character and character.PrimaryPart and hider.PrimaryPart then
        character:PivotTo(hider:GetPrimaryPartCFrame())
        MainModule.Alert("Teleported to hider!")
    end
end

function MainModule.ToggleVoidKill(enabled)
    MainModule.VoidKill.Enabled = enabled
    
    if MainModule.VoidKill.AnimationConnection then
        MainModule.VoidKill.AnimationConnection:Disconnect()
        MainModule.VoidKill.AnimationConnection = nil
    end
    
    if MainModule.VoidKill.CharacterAddedConnection then
        MainModule.VoidKill.CharacterAddedConnection:Disconnect()
        MainModule.VoidKill.CharacterAddedConnection = nil
    end
    
    if MainModule.VoidKill.AnimationCheckConnection then
        MainModule.VoidKill.AnimationCheckConnection:Disconnect()
        MainModule.VoidKill.AnimationCheckConnection = nil
    end
    
    for _, conn in ipairs(MainModule.VoidKill.AnimationStoppedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.VoidKill.AnimationStoppedConnections = {}
    
    MainModule.VoidKill.SavedCFrame = nil
    MainModule.VoidKill.ActiveAnimation = false
    MainModule.VoidKill.AnimationStartTime = 0
    MainModule.VoidKill.TrackedAnimations = {}
    
    if enabled then
        MainModule.CreateSkySquidAntiFall()
        MainModule.VoidKill.AntiFallEnabled = true
    else
        if MainModule.VoidKill.AntiFallEnabled then
            MainModule.RemoveSkySquidAntiFall()
            MainModule.VoidKill.AntiFallEnabled = false
        end
    end
    
    if not enabled then
        return
    end
    
    local function checkAnimations()
        local character = GetCharacter()
        if not character then return end
        
        local humanoid = GetHumanoid(character)
        if not humanoid then return end
        
        local activeTracks = humanoid:GetPlayingAnimationTracks()
        for _, track in pairs(activeTracks) do
            if track.Animation and track.Animation.AnimationId == MainModule.VoidKill.AnimationId then
                if not MainModule.VoidKill.TrackedAnimations[track] then
                    MainModule.VoidKill.TrackedAnimations[track] = true
                    
                    if not MainModule.VoidKill.ActiveAnimation then
                        MainModule.VoidKill.ActiveAnimation = true
                        MainModule.VoidKill.AnimationStartTime = tick()
                        MainModule.VoidKill.SavedCFrame = character:GetPrimaryPartCFrame()
                        
                        local currentCFrame = character:GetPrimaryPartCFrame()
                        local lookVector = currentCFrame.LookVector
                        local backOffset = lookVector * -10
                        local targetPosition = currentCFrame.Position + backOffset
                        character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
                        
                        local stoppedConn = track.Stopped:Connect(function()
                            task.wait(MainModule.VoidKill.ReturnDelay)
                            if MainModule.VoidKill.SavedCFrame then
                                character:SetPrimaryPartCFrame(MainModule.VoidKill.SavedCFrame)
                                MainModule.VoidKill.SavedCFrame = nil
                                MainModule.VoidKill.ActiveAnimation = false
                                MainModule.VoidKill.TrackedAnimations[track] = nil
                            end
                        end)
                        table.insert(MainModule.VoidKill.AnimationStoppedConnections, stoppedConn)
                    end
                end
            end
        end
    end
    
    local function setupCharacter(char)
        local humanoid = char:WaitForChild("Humanoid")
        MainModule.VoidKill.AnimationConnection = humanoid.AnimationPlayed:Connect(function(track)
            if track.Animation and track.Animation.AnimationId == MainModule.VoidKill.AnimationId then
                MainModule.VoidKill.TrackedAnimations[track] = true
                
                if not MainModule.VoidKill.ActiveAnimation then
                    MainModule.VoidKill.ActiveAnimation = true
                    MainModule.VoidKill.AnimationStartTime = tick()
                    MainModule.VoidKill.SavedCFrame = char:GetPrimaryPartCFrame()
                    
                    local currentCFrame = char:GetPrimaryPartCFrame()
                    local lookVector = currentCFrame.LookVector
                    local backOffset = lookVector * -10
                    local targetPosition = currentCFrame.Position + backOffset
                    char:SetPrimaryPartCFrame(CFrame.new(targetPosition))
                    
                    local stoppedConn = track.Stopped:Connect(function()
                        task.wait(MainModule.VoidKill.ReturnDelay)
                        if MainModule.VoidKill.SavedCFrame then
                            char:SetPrimaryPartCFrame(MainModule.VoidKill.SavedCFrame)
                            MainModule.VoidKill.SavedCFrame = nil
                            MainModule.VoidKill.ActiveAnimation = false
                            MainModule.VoidKill.TrackedAnimations[track] = nil
                        end
                    end)
                    table.insert(MainModule.VoidKill.AnimationStoppedConnections, stoppedConn)
                end
            end
        end)
    end
    
    local char = LocalPlayer.Character
    if char then
        setupCharacter(char)
    end
    
    MainModule.VoidKill.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(1)
        setupCharacter(char)
    end)
    
    MainModule.VoidKill.AnimationCheckConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.VoidKill.Enabled then return end
        checkAnimations()
    end)
end

function MainModule.ToggleSpikesKill(enabled)
    if enabled then
        local hnsActive, hasKnife, hasDodge = MainModule.CheckHNSGame()
        if not hnsActive then
            MainModule.Alert("Game not running!")
            return false
        end
        if not hasKnife and not hasDodge then
            MainModule.Alert("Game not running!")
            return false
        end
    end
    
    MainModule.SpikesKill.Enabled = enabled
    
    if MainModule.SpikesKill.AnimationConnection then
        MainModule.SpikesKill.AnimationConnection:Disconnect()
        MainModule.SpikesKill.AnimationConnection = nil
    end
    
    if MainModule.SpikesKill.CharacterAddedConnection then
        MainModule.SpikesKill.CharacterAddedConnection:Disconnect()
        MainModule.SpikesKill.CharacterAddedConnection = nil
    end
    
    if MainModule.SpikesKill.SafetyCheckConnection then
        MainModule.SpikesKill.SafetyCheckConnection:Disconnect()
        MainModule.SpikesKill.SafetyCheckConnection = nil
    end
    
    if MainModule.SpikesKill.AnimationCheckConnection then
        MainModule.SpikesKill.AnimationCheckConnection:Disconnect()
        MainModule.SpikesKill.AnimationCheckConnection = nil
    end
    
    for _, conn in ipairs(MainModule.SpikesKill.AnimationStoppedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.SpikesKill.AnimationStoppedConnections = {}
    
    MainModule.SpikesKill.SavedCFrame = nil
    MainModule.SpikesKill.ActiveAnimation = false
    MainModule.SpikesKill.AnimationStartTime = 0
    MainModule.SpikesKill.TrackedAnimations = {}
    
    if not enabled then
        return true
    end
    
    MainModule.DisableSpikes(true)
    
    local function checkAnimations()
        local character = GetCharacter()
        if not character then return end
        
        local humanoid = GetHumanoid(character)
        if not humanoid then return end
        
        local activeTracks = humanoid:GetPlayingAnimationTracks()
        for _, track in pairs(activeTracks) do
            if track.Animation and track.Animation.AnimationId == MainModule.SpikesKill.AnimationId then
                if not MainModule.SpikesKill.TrackedAnimations[track] then
                    MainModule.SpikesKill.TrackedAnimations[track] = true
                    
                    if not MainModule.SpikesKill.ActiveAnimation then
                        MainModule.SpikesKill.ActiveAnimation = true
                        MainModule.SpikesKill.AnimationStartTime = tick()
                        MainModule.SpikesKill.SavedCFrame = character:GetPrimaryPartCFrame()
                        
                        local spikesPosition = MainModule.SpikesKill.SpikesPosition
                        if not spikesPosition then
                            local hideAndSeekMap = workspace:FindFirstChild("HideAndSeekMap")
                            local killingParts = hideAndSeekMap and hideAndSeekMap:FindFirstChild("KillingParts")
                            if killingParts and killingParts:FindFirstChildWhichIsA("BasePart") then
                                local firstSpike = killingParts:FindFirstChildWhichIsA("BasePart")
                                if firstSpike then
                                    spikesPosition = firstSpike.Position
                                    MainModule.SpikesKill.SpikesPosition = spikesPosition
                                end
                            end
                        end
                        
                        if spikesPosition then
                            local targetPosition = spikesPosition + Vector3.new(0, MainModule.SpikesKill.PlatformHeightOffset, 0)
                            character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
                        else
                            local currentPos = character:GetPrimaryPartCFrame().Position
                            local targetPosition = currentPos + Vector3.new(0, MainModule.SpikesKill.PlatformHeightOffset, 0)
                            character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
                        end
                        
                        local stoppedConn = track.Stopped:Connect(function()
                            task.wait(MainModule.SpikesKill.ReturnDelay)
                            if MainModule.SpikesKill.SavedCFrame then
                                character:SetPrimaryPartCFrame(MainModule.SpikesKill.SavedCFrame)
                                MainModule.SpikesKill.SavedCFrame = nil
                                MainModule.SpikesKill.ActiveAnimation = false
                                MainModule.SpikesKill.TrackedAnimations[track] = nil
                            end
                        end)
                        table.insert(MainModule.SpikesKill.AnimationStoppedConnections, stoppedConn)
                    end
                    
                    local stoppedConn = track.Stopped:Connect(function()
                        MainModule.SpikesKill.TrackedAnimations[track] = nil
                    end)
                    table.insert(MainModule.SpikesKill.AnimationStoppedConnections, stoppedConn)
                end
            end
        end
    end
    
    local function setupCharacter(char)
        local humanoid = char:WaitForChild("Humanoid")
        MainModule.SpikesKill.AnimationConnection = humanoid.AnimationPlayed:Connect(function(track)
            if track.Animation and track.Animation.AnimationId == MainModule.SpikesKill.AnimationId then
                MainModule.SpikesKill.TrackedAnimations[track] = true
                
                if not MainModule.SpikesKill.ActiveAnimation then
                    MainModule.SpikesKill.ActiveAnimation = true
                    MainModule.SpikesKill.AnimationStartTime = tick()
                    MainModule.SpikesKill.SavedCFrame = char:GetPrimaryPartCFrame()
                    
                    local spikesPosition = MainModule.SpikesKill.SpikesPosition
                    if not spikesPosition then
                        local hideAndSeekMap = workspace:FindFirstChild("HideAndSeekMap")
                        local killingParts = hideAndSeekMap and hideAndSeekMap:FindFirstChild("KillingParts")
                        if killingParts and killingParts:FindFirstChildWhichIsA("BasePart") then
                            local firstSpike = killingParts:FindFirstChildWhichIsA("BasePart")
                            if firstSpike then
                                spikesPosition = firstSpike.Position
                                MainModule.SpikesKill.SpikesPosition = spikesPosition
                            end
                        end
                    end
                    
                    if spikesPosition then
                        local targetPosition = spikesPosition + Vector3.new(0, MainModule.SpikesKill.PlatformHeightOffset, 0)
                        char:SetPrimaryPartCFrame(CFrame.new(targetPosition))
                    else
                        local currentPos = char:GetPrimaryPartCFrame().Position
                        local targetPosition = currentPos + Vector3.new(0, MainModule.SpikesKill.PlatformHeightOffset, 0)
                        char:SetPrimaryPartCFrame(CFrame.new(targetPosition))
                    end
                    
                    local stoppedConn = track.Stopped:Connect(function()
                        task.wait(MainModule.SpikesKill.ReturnDelay)
                        if MainModule.SpikesKill.SavedCFrame then
                            char:SetPrimaryPartCFrame(MainModule.SpikesKill.SavedCFrame)
                            MainModule.SpikesKill.SavedCFrame = nil
                            MainModule.SpikesKill.ActiveAnimation = false
                            MainModule.SpikesKill.TrackedAnimations[track] = nil
                        end
                    end)
                    table.insert(MainModule.SpikesKill.AnimationStoppedConnections, stoppedConn)
                end
            end
        end)
    end
    
    local char = LocalPlayer.Character
    if char then
        setupCharacter(char)
    end
    
    MainModule.SpikesKill.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(1)
        setupCharacter(char)
    end)
    
    MainModule.SpikesKill.AnimationCheckConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.SpikesKill.Enabled then return end
        checkAnimations()
    end)
    
    MainModule.SpikesKill.SafetyCheckConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.SpikesKill.ActiveAnimation then return end
        if tick() - MainModule.SpikesKill.AnimationStartTime >= 10 then
            MainModule.SpikesKill.ActiveAnimation = false
        end
    end)
    
    -- Проверка HNS игры
    local hnsCheckConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.SpikesKill.Enabled then return end
        
        local hnsActive, hasKnife, hasDodge = MainModule.CheckHNSGame()
        if not hnsActive then
            MainModule.ToggleSpikesKill(false)
            MainModule.Alert("Game not running!")
            if hnsCheckConnection then
                hnsCheckConnection:Disconnect()
            end
        end
    end)
    
    return true
end

function MainModule.ToggleZoneKill(enabled)
    if enabled then
        local hasKnife = MainModule.CheckZoneKill()
        if not hasKnife then
            MainModule.Alert("Game not running!")
            return false
        end
    end
    
    MainModule.ZoneKill.Enabled = enabled
    
    if MainModule.ZoneKill.AnimationConnection then
        MainModule.ZoneKill.AnimationConnection:Disconnect()
        MainModule.ZoneKill.AnimationConnection = nil
    end
    
    if MainModule.ZoneKill.CharacterAddedConnection then
        MainModule.ZoneKill.CharacterAddedConnection:Disconnect()
        MainModule.ZoneKill.CharacterAddedConnection = nil
    end
    
    if MainModule.ZoneKill.AnimationCheckConnection then
        MainModule.ZoneKill.AnimationCheckConnection:Disconnect()
        MainModule.ZoneKill.AnimationCheckConnection = nil
    end
    
    for _, conn in ipairs(MainModule.ZoneKill.AnimationStoppedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.ZoneKill.AnimationStoppedConnections = {}
    
    MainModule.ZoneKill.SavedCFrame = nil
    MainModule.ZoneKill.ActiveAnimation = false
    MainModule.ZoneKill.AnimationStartTime = 0
    MainModule.ZoneKill.TrackedAnimations = {}
    
    if not enabled then
        return true
    end
    
    local function checkAnimations()
        local character = GetCharacter()
        if not character then return end
        
        local humanoid = GetHumanoid(character)
        if not humanoid then return end
        
        local activeTracks = humanoid:GetPlayingAnimationTracks()
        for _, track in pairs(activeTracks) do
            if track.Animation and track.Animation.AnimationId == MainModule.ZoneKill.AnimationId then
                if not MainModule.ZoneKill.TrackedAnimations[track] then
                    MainModule.ZoneKill.TrackedAnimations[track] = true
                    
                    if not MainModule.ZoneKill.ActiveAnimation then
                        MainModule.ZoneKill.ActiveAnimation = true
                        MainModule.ZoneKill.AnimationStartTime = tick()
                        MainModule.ZoneKill.SavedCFrame = character:GetPrimaryPartCFrame()
                        
                        character:SetPrimaryPartCFrame(CFrame.new(MainModule.ZoneKill.TargetPosition))
                        
                        local stoppedConn = track.Stopped:Connect(function()
                            task.wait(MainModule.ZoneKill.ReturnDelay)
                            if MainModule.ZoneKill.SavedCFrame then
                                character:SetPrimaryPartCFrame(MainModule.ZoneKill.SavedCFrame)
                                MainModule.ZoneKill.SavedCFrame = nil
                                MainModule.ZoneKill.ActiveAnimation = false
                                MainModule.ZoneKill.TrackedAnimations[track] = nil
                            end
                        end)
                        table.insert(MainModule.ZoneKill.AnimationStoppedConnections, stoppedConn)
                    end
                end
            end
        end
    end
    
    local function setupCharacter(char)
        local humanoid = char:WaitForChild("Humanoid")
        MainModule.ZoneKill.AnimationConnection = humanoid.AnimationPlayed:Connect(function(track)
            if track.Animation and track.Animation.AnimationId == MainModule.ZoneKill.AnimationId then
                MainModule.ZoneKill.TrackedAnimations[track] = true
                
                if not MainModule.ZoneKill.ActiveAnimation then
                    MainModule.ZoneKill.ActiveAnimation = true
                    MainModule.ZoneKill.AnimationStartTime = tick()
                    MainModule.ZoneKill.SavedCFrame = char:GetPrimaryPartCFrame()
                    
                    char:SetPrimaryPartCFrame(CFrame.new(MainModule.ZoneKill.TargetPosition))
                    
                    local stoppedConn = track.Stopped:Connect(function()
                        task.wait(MainModule.ZoneKill.ReturnDelay)
                        if MainModule.ZoneKill.SavedCFrame then
                            char:SetPrimaryPartCFrame(MainModule.ZoneKill.SavedCFrame)
                            MainModule.ZoneKill.SavedCFrame = nil
                            MainModule.ZoneKill.ActiveAnimation = false
                            MainModule.ZoneKill.TrackedAnimations[track] = nil
                        end
                    end)
                    table.insert(MainModule.ZoneKill.AnimationStoppedConnections, stoppedConn)
                end
            end
        end)
    end
    
    local char = LocalPlayer.Character
    if char then
        setupCharacter(char)
    end
    
    MainModule.ZoneKill.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(1)
        setupCharacter(char)
    end)
    
    MainModule.ZoneKill.AnimationCheckConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.ZoneKill.Enabled then return end
        checkAnimations()
    end)
    
    local knifeCheckConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.ZoneKill.Enabled then return end
        
        local hasKnife = MainModule.CheckZoneKill()
        if not hasKnife then
            MainModule.ToggleZoneKill(false)
            MainModule.Alert("Game not running!")
            if knifeCheckConnection then
                knifeCheckConnection:Disconnect()
            end
        end
    end)
    
    return true
end

function MainModule.ToggleGodMode(enabled)
    if enabled then
        local rlglActive = MainModule.CheckRLGLGame()
        if not rlglActive then
            MainModule.Alert("Game not running!")
            return false
        end
        MainModule.RLGL.PocketSandActive = true
    end
    
    MainModule.RLGL.GodMode = enabled
    
    if MainModule.RLGL.Connection then
        MainModule.RLGL.Connection:Disconnect()
        MainModule.RLGL.Connection = nil
    end
    
    if MainModule.RLGL.PocketSandCheckConnection then
        MainModule.RLGL.PocketSandCheckConnection:Disconnect()
        MainModule.RLGL.PocketSandCheckConnection = nil
    end
    
    if enabled then
        local character = GetCharacter()
        if character then
            local rootPart = GetRootPart(character)
            if rootPart then
                -- Запоминаем текущую высоту и позицию
                MainModule.RLGL.OriginalHeight = rootPart.Position.Y
                MainModule.RLGL.OriginalPosition = rootPart.Position
                
                -- Поднимаемся на нужную высоту
                local targetPos = Vector3.new(rootPart.Position.X, MainModule.RLGL.OriginalHeight + MainModule.RLGL.GodModeHeight, rootPart.Position.Z)
                SafeTeleport(targetPos)
                
                MainModule.RLGL.LastHealth = 100
            end
        end
        
        -- Проверка урона
        MainModule.RLGL.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.RLGL.GodMode then return end
            
            local currentTime = tick()
            if currentTime - MainModule.RLGL.LastDamageTime < MainModule.RLGL.DamageCheckRate then return end
            
            pcall(function()
                local character = GetCharacter()
                if not character then return end
                
                local humanoid = GetHumanoid(character)
                local rootPart = GetRootPart(character)
                if not (humanoid and rootPart) then return end
                
                if humanoid.Health < MainModule.RLGL.LastHealth then
                    MainModule.RLGL.LastDamageTime = currentTime
                    SafeTeleport(MainModule.RLGL.DamageTeleportPosition)
                    humanoid.Health = MainModule.RLGL.LastHealth
                    task.wait(0.1)
                    MainModule.ToggleGodMode(false)
                else
                    MainModule.RLGL.LastHealth = humanoid.Health
                end
            end)
        end)
        
        -- Проверка Pocket Sand
        MainModule.RLGL.PocketSandCheckConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.RLGL.GodMode then return end
            
            local hasPocketSand = false
            if LocalPlayer:FindFirstChild("Backpack") then
                for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and (tool.Name == "Pocket Sand" or tool.Name == "PocketSand") then
                        hasPocketSand = true
                        break
                    end
                end
            end
            
            if LocalPlayer.Character then
                for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
                    if tool:IsA("Tool") and (tool.Name == "Pocket Sand" or tool.Name == "PocketSand") then
                        hasPocketSand = true
                        break
                    end
                end
            end
            
            if not hasPocketSand then
                if MainModule.RLGL.NoPocketSandTime == 0 then
                    MainModule.RLGL.NoPocketSandTime = tick()
                elseif tick() - MainModule.RLGL.NoPocketSandTime >= 3 then
                    -- Возвращаем на свою высоту и отключаем
                    local character = GetCharacter()
                    if character and MainModule.RLGL.OriginalHeight then
                        local rootPart = GetRootPart(character)
                        if rootPart then
                            local targetPos = Vector3.new(
                                rootPart.Position.X,
                                MainModule.RLGL.OriginalHeight,
                                rootPart.Position.Z
                            )
                            SafeTeleport(targetPos)
                        end
                    end
                    MainModule.ToggleGodMode(false)
                    MainModule.Alert("Game not running!")
                end
            else
                MainModule.RLGL.NoPocketSandTime = 0
            end
        end)
    else
        -- При выключении возвращаем на свою высоту
        local character = GetCharacter()
        if character and MainModule.RLGL.OriginalHeight then
            local rootPart = GetRootPart(character)
            if rootPart then
                local targetPos = Vector3.new(
                    rootPart.Position.X,
                    MainModule.RLGL.OriginalHeight,
                    rootPart.Position.Z
                )
                SafeTeleport(targetPos)
            end
        end
        
        MainModule.RLGL.OriginalHeight = nil
        MainModule.RLGL.OriginalPosition = nil
        MainModule.RLGL.LastHealth = 100
        MainModule.RLGL.PocketSandActive = false
        MainModule.RLGL.NoPocketSandTime = 0
    end
    
    return true
end

function MainModule.TeleportToEnd()
    SafeTeleport(MainModule.RLGL.EndPosition)
end

function MainModule.TeleportToStart()
    SafeTeleport(MainModule.RLGL.StartPosition)
end

function MainModule.ToggleAutoDodge(enabled)
    if enabled then
        local hnsActive, hasKnife, hasDodge = MainModule.CheckHNSGame()
        if not hnsActive then
            MainModule.Alert("Game not running!")
            return false
        end
        if not hasDodge then
            MainModule.Alert("This function is not available, You Seeker.")
            return false
        end
    end
    
    MainModule.AutoDodge.Enabled = false
    
    for _, conn in pairs(MainModule.AutoDodge.Connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    MainModule.AutoDodge.Connections = {}
    
    MainModule.AutoDodge.PlayersInRange = {}
    MainModule.AutoDodge.LastDodgeTime = 0
    MainModule.AutoDodge.LastRangeUpdate = 0
    
    if enabled then
        MainModule.AutoDodge.Enabled = true
        
        for _, id in ipairs(MainModule.AutoDodge.AnimationIds) do
            MainModule.AutoDodge.AnimationIdsSet[id] = true
        end
        
        local function executeInstantDodge()
            if not MainModule.AutoDodge.Enabled then return false end
            
            local currentTime = tick()
            local autoDodge = MainModule.AutoDodge
            
            if currentTime - autoDodge.LastDodgeTime < autoDodge.DodgeCooldown then
                return false
            end
            
            local remote = game.ReplicatedStorage:FindFirstChild("Remotes")
            if remote then
                remote = remote:FindFirstChild("UsedTool")
            end
            
            if not remote then return false end
            
            local tool = nil
            local char = LocalPlayer.Character
            if char then
                tool = char:FindFirstChild("DODGE!")
                if not tool then
                    local backpack = LocalPlayer:FindFirstChild("Backpack")
                    if backpack then
                        tool = backpack:FindFirstChild("DODGE!")
                    end
                end
            end
            
            if tool then
                local fireSuccess = pcall(function()
                    remote:FireServer("UsingMoveCustom", tool, nil, {Clicked = true})
                end)
                
                if fireSuccess then
                    autoDodge.LastDodgeTime = currentTime
                    return true
                end
            end
            
            return false
        end
        
        local function createFastAnimationHandler(player)
            return function(track)
                if not MainModule.AutoDodge.Enabled then return end
                if player == LocalPlayer then return end
                
                local animId
                if track and track.Animation then
                    animId = track.Animation.AnimationId
                end
                
                if not animId then return end
                
                if not MainModule.AutoDodge.AnimationIdsSet[animId] then
                    return
                end
                
                if not LocalPlayer or not LocalPlayer.Character then return end
                if not player or not player.Character then return end
                
                local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                
                if not (localRoot and targetRoot) then return end
                
                local diff = targetRoot.Position - localRoot.Position
                local distanceSquared = diff.X * diff.X + diff.Y * diff.Y + diff.Z * diff.Z
                
                if distanceSquared <= MainModule.AutoDodge.RangeSquared then
                    executeInstantDodge()
                end
            end
        end
        
        local function setupFastPlayerTracking(player)
            if player == LocalPlayer then return end
            
            local function setupCharacter(character)
                if not character or not MainModule.AutoDodge.Enabled then return end
                
                for i = 1, 2 do
                    if character:FindFirstChild("Humanoid") then break end
                    task.wait(0.1)
                end
                
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    local handler = createFastAnimationHandler(player)
                    local conn = humanoid.AnimationPlayed:Connect(handler)
                    table.insert(MainModule.AutoDodge.Connections, conn)
                end
            end
            
            if player.Character then
                task.spawn(setupCharacter, player.Character)
            end
            
            local charConn = player.CharacterAdded:Connect(function(character)
                if MainModule.AutoDodge.Enabled then
                    task.spawn(setupCharacter, character)
                end
            end)
            table.insert(MainModule.AutoDodge.Connections, charConn)
        end
        
        for _, player in pairs(Players:GetPlayers()) do
            task.spawn(setupFastPlayerTracking, player)
        end
        
        local playerAddedConn = Players.PlayerAdded:Connect(function(player)
            if MainModule.AutoDodge.Enabled then
                task.spawn(setupFastPlayerTracking, player)
            end
        end)
        table.insert(MainModule.AutoDodge.Connections, playerAddedConn)
        
        local function fastUpdatePlayersInRange()
            if not LocalPlayer or not LocalPlayer.Character then 
                MainModule.AutoDodge.PlayersInRange = {}
                return 
            end
            
            local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not localRoot then 
                MainModule.AutoDodge.PlayersInRange = {}
                return 
            end
            
            local playersInRange = {}
            local rangeSquared = MainModule.AutoDodge.RangeSquared
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    if playerRoot then
                        local diff = playerRoot.Position - localRoot.Position
                        local distanceSquared = diff.X * diff.X + diff.Y * diff.Y + diff.Z * diff.Z
                        
                        if distanceSquared <= rangeSquared then
                            table.insert(playersInRange, player.Name)
                        end
                    end
                end
            end
            
            MainModule.AutoDodge.PlayersInRange = playersInRange
            return playersInRange
        end
        
        local heartbeatConn = RunService.Heartbeat:Connect(function()
            if not MainModule.AutoDodge.Enabled then return end
            
            local currentTime = tick()
            if currentTime - MainModule.AutoDodge.LastRangeUpdate > MainModule.AutoDodge.RangeUpdateInterval then
                fastUpdatePlayersInRange()
                MainModule.AutoDodge.LastRangeUpdate = currentTime
            end
        end)
        table.insert(MainModule.AutoDodge.Connections, heartbeatConn)
        
        -- Проверка DODGE!
        local dodgeCheckConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.AutoDodge.Enabled then return end
            
            local hasDodge = false
            if LocalPlayer:FindFirstChild("Backpack") then
                for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool.Name == "DODGE!" then
                        hasDodge = true
                        break
                    end
                end
            end
            
            if LocalPlayer.Character then
                for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
                    if tool:IsA("Tool") and tool.Name == "DODGE!" then
                        hasDodge = true
                        break
                    end
                end
            end
            
            if not hasDodge then
                MainModule.ToggleAutoDodge(false)
                MainModule.Alert("Game not running!")
                if dodgeCheckConnection then
                    dodgeCheckConnection:Disconnect()
                end
            end
        end)
        
        return true
    end
    
    return true
end

function MainModule.ToggleHNSInfinityStamina(enabled)
    if enabled then
        local hnsActive, hasKnife, hasDodge = MainModule.CheckHNSGame()
        if not hnsActive then
            MainModule.Alert("Game not running!")
            return false
        end
        if not hasDodge then
            MainModule.Alert("This function is not available, You Seeker.")
            return false
        end
    end
    
    MainModule.HNS.InfinityStaminaEnabled = enabled
    
    if MainModule.HNS.InfinityStaminaConnection then
        MainModule.HNS.InfinityStaminaConnection:Disconnect()
        MainModule.HNS.InfinityStaminaConnection = nil
    end
    
    if enabled then
        MainModule.HNS.InfinityStaminaConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.InfinityStaminaEnabled then return end
            
            task.spawn(function()
                if LocalPlayer.Character then
                    local stamina = LocalPlayer.Character:FindFirstChild("StaminaVal")
                    if stamina then
                        stamina.Value = 100
                    end
                end
            end)
        end)
        
        -- Проверка DODGE!
        local dodgeCheckConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.InfinityStaminaEnabled then return end
            
            local hasDodge = false
            if LocalPlayer:FindFirstChild("Backpack") then
                for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool.Name == "DODGE!" then
                        hasDodge = true
                        break
                    end
                end
            end
            
            if LocalPlayer.Character then
                for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
                    if tool:IsA("Tool") and tool.Name == "DODGE!" then
                        hasDodge = true
                        break
                    end
                end
            end
            
            if not hasDodge then
                MainModule.ToggleHNSInfinityStamina(false)
                MainModule.Alert("Game not running!")
                if dodgeCheckConnection then
                    dodgeCheckConnection:Disconnect()
                end
            end
        end)
        
        return true
    end
    
    return true
end

-- Остальные функции остаются без изменений
function MainModule.ToggleSpeedHack(enabled)
    MainModule.SpeedHack.Enabled = enabled
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
    if enabled then
        speedConnection = RunService.Heartbeat:Connect(function()
            if MainModule.SpeedHack.Enabled then
                local character = GetCharacter()
                if character then
                    local humanoid = GetHumanoid(character)
                    if humanoid then
                        humanoid.WalkSpeed = MainModule.SpeedHack.CurrentSpeed
                    end
                end
            end
        end)
    else
        local character = GetCharacter()
        if character then
            local humanoid = GetHumanoid(character)
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
        local character = GetCharacter()
        if character then
            local humanoid = GetHumanoid(character)
            if humanoid then
                humanoid.WalkSpeed = value
            end
        end
    end
    return value
end

function MainModule.TeleportUp100()
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            local targetPos = rootPart.Position + Vector3.new(0, 100, 0)
            SafeTeleport(targetPos)
        end
    end
end

function MainModule.TeleportDown40()
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            local targetPos = rootPart.Position + Vector3.new(0, -40, 0)
            SafeTeleport(targetPos)
        end
    end
end

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

function MainModule.SetGuardType(guardType)
    if guardType == "Circle" then
        MainModule.Guards.SelectedGuard = "Circle"
    elseif guardType == "Triangle" then
        MainModule.Guards.SelectedGuard = "Triangle"
    elseif guardType == "Square" then
        MainModule.Guards.SelectedGuard = "Square"
    else
        MainModule.Guards.SelectedGuard = "Circle"
    end
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
                local character = GetCharacter()
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

function MainModule.ToggleInfiniteAmmo(enabled)
    MainModule.Guards.InfiniteAmmo = enabled
    if infiniteAmmoConnection then
        infiniteAmmoConnection:Disconnect()
        infiniteAmmoConnection = nil
    end
    if enabled then
        infiniteAmmoConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.Guards.InfiniteAmmo then return end
            task.spawn(function()
                local character = GetCharacter()
                if character then
                    for _, tool in pairs(character:GetChildren()) do
                        if tool:IsA("Tool") then
                            for _, obj in pairs(tool:GetDescendants()) do
                                if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                                    local nameLower = obj.Name:lower()
                                    if nameLower:find("ammo") or 
                                       nameLower:find("bullet") or
                                       nameLower:find("clip") or
                                       nameLower:find("munition") then
                                        if not MainModule.Guards.OriginalAmmo[obj] then
                                            MainModule.Guards.OriginalAmmo[obj] = obj.Value
                                        end
                                        if obj.Value < 999 then
                                            obj.Value = math.huge
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                if backpack then
                    for _, tool in pairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") then
                            for _, obj in pairs(tool:GetDescendants()) do
                                if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                                    local nameLower = obj.Name:lower()
                                    if nameLower:find("ammo") or 
                                       nameLower:find("bullet") or
                                       nameLower:find("clip") then
                                        if not MainModule.Guards.OriginalAmmo[obj] then
                                            MainModule.Guards.OriginalAmmo[obj] = obj.Value
                                        end
                                        if obj.Value < 999 then
                                            obj.Value = math.huge
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
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

function MainModule.ToggleHitboxExpander(enabled)
    MainModule.Hitbox.Enabled = enabled
    if MainModule.Hitbox.Connection then
        MainModule.Hitbox.Connection:Disconnect()
        MainModule.Hitbox.Connection = nil
    end
    if not enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root and MainModule.Hitbox.ModifiedParts[root] then
                    root.Size = MainModule.Hitbox.ModifiedParts[root]
                    root.CanCollide = true
                    MainModule.Hitbox.ModifiedParts[root] = nil
                end
            end
        end
        MainModule.Hitbox.ModifiedParts = {}
        return
    end
    local function modifyPart(part)
        if not MainModule.Hitbox.ModifiedParts[part] then
            MainModule.Hitbox.ModifiedParts[part] = part.Size
            part.Size = Vector3.new(MainModule.Hitbox.Size, MainModule.Hitbox.Size, MainModule.Hitbox.Size)
            part.CanCollide = false
        end
    end
    local function onPlayerAdded(player)
        player.CharacterAdded:Connect(function(character)
            if MainModule.Hitbox.Enabled then
                local root = character:WaitForChild("HumanoidRootPart", 5)
                if root then
                    modifyPart(root)
                end
            end
        end)
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                modifyPart(root)
            end
        end
        if player ~= LocalPlayer then
            onPlayerAdded(player)
        end
    end
    MainModule.Hitbox.Connection = RunService.RenderStepped:Connect(function()
        if not MainModule.Hitbox.Enabled then return end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root and not MainModule.Hitbox.ModifiedParts[root] then
                    pcall(modifyPart, root)
                end
            end
        end
    end)
    Players.PlayerRemoving:Connect(function(player)
        if player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                MainModule.Hitbox.ModifiedParts[root] = nil
            end
        end
    end)
    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            onPlayerAdded(player)
        end
    end)
end

function MainModule.SetHitboxSize(size)
    MainModule.Hitbox.Size = size
    if MainModule.Hitbox.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root and MainModule.Hitbox.ModifiedParts[root] then
                    root.Size = Vector3.new(size, size, size)
                end
            end
        end
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

function MainModule.DeleteJumpRope()
    local ropeFound = false
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Rope" then
            if obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart") then
                obj:Destroy()
                ropeFound = true
                break
            end
        end
    end
    if not ropeFound then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("rope") and 
               (obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart")) then
                obj:Destroy()
                ropeFound = true
                break
            end
        end
    end
    if not ropeFound then
        local effects = workspace:FindFirstChild("Effects")
        if effects then
            for _, obj in pairs(effects:GetDescendants()) do
                if obj.Name:lower():find("rope") and 
                   (obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart")) then
                    obj:Destroy()
                    ropeFound = true
                    break
                end
            end
        end
    end
    return ropeFound
end

function MainModule.TeleportToJumpRopeEnd()
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            SafeTeleport(Vector3.new(720.896057, 198.628311, 921.170654))
        end
    end
end

function MainModule.TeleportToJumpRopeStart()
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            SafeTeleport(Vector3.new(615.284424, 192.274277, 920.952515))
        end
    end
end

function MainModule.CreateGlassBridgeAntiFall()
    if MainModule.GlassBridge.GlassAntiFallPlatform and MainModule.GlassBridge.GlassAntiFallPlatform.Parent then
        MainModule.GlassBridge.GlassAntiFallPlatform:Destroy()
        MainModule.GlassBridge.GlassAntiFallPlatform = nil
    end
    local character = GetCharacter()
    if not character then return nil end
    local rootPart = GetRootPart(character)
    if not rootPart then return nil end
    local currentPosition = rootPart.Position
    local platform = Instance.new("Part")
    platform.Name = "GlassBridgeAntiFall"
    platform.Size = MainModule.GlassBridge.PlatformSize
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 1
    platform.Material = Enum.Material.Plastic
    platform.CastShadow = false
    platform.CanQuery = false
    platform.Position = Vector3.new(
        currentPosition.X,
        currentPosition.Y - 5,
        currentPosition.Z
    )
    platform.Parent = workspace
    MainModule.GlassBridge.GlassAntiFallPlatform = platform
    MainModule.GlassBridge.AntiFallEnabled = true
    return platform
end

function MainModule.RemoveGlassBridgeAntiFall()
    if MainModule.GlassBridge.GlassAntiFallPlatform and MainModule.GlassBridge.GlassAntiFallPlatform.Parent then
        MainModule.GlassBridge.GlassAntiFallPlatform:Destroy()
        MainModule.GlassBridge.GlassAntiFallPlatform = nil
    end
    MainModule.GlassBridge.AntiFallEnabled = false
    return true
end

function MainModule.CreateSkySquidAntiFall()
    if MainModule.SkySquid.AntiFallPlatform and MainModule.SkySquid.AntiFallPlatform.Parent then
        MainModule.SkySquid.AntiFallPlatform:Destroy()
        MainModule.SkySquid.AntiFallPlatform = nil
    end
    local character = GetCharacter()
    if not character then return nil end
    local rootPart = GetRootPart(character)
    if not rootPart then return nil end
    local currentPosition = rootPart.Position
    local platform = Instance.new("Part")
    platform.Name = "SkySquidAntiFall"
    platform.Size = MainModule.SkySquid.PlatformSize
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 1
    platform.Material = Enum.Material.Plastic
    platform.CastShadow = false
    platform.CanQuery = false
    platform.Position = Vector3.new(
        currentPosition.X,
        currentPosition.Y - 5,
        currentPosition.Z
    )
    platform.Parent = workspace
    MainModule.SkySquid.AntiFallPlatform = platform
    return platform
end

function MainModule.RemoveSkySquidAntiFall()
    if MainModule.SkySquid.AntiFallPlatform and MainModule.SkySquid.AntiFallPlatform.Parent then
        MainModule.SkySquid.AntiFallPlatform:Destroy()
        MainModule.SkySquid.AntiFallPlatform = nil
    end
    return true
end

function MainModule.CreateJumpRopeAntiFall()
    if MainModule.JumpRope.AntiFallPlatform and MainModule.JumpRope.AntiFallPlatform.Parent then
        MainModule.JumpRope.AntiFallPlatform:Destroy()
        MainModule.JumpRope.AntiFallPlatform = nil
    end
    local character = GetCharacter()
    if not character then return nil end
    local rootPart = GetRootPart(character)
    if not rootPart then return nil end
    local currentPosition = rootPart.Position
    local platform = Instance.new("Part")
    platform.Name = "JumpRopeAntiFall"
    platform.Size = MainModule.JumpRope.PlatformSize
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 1
    platform.Material = Enum.Material.Plastic
    platform.CastShadow = false
    platform.CanQuery = false
    platform.Position = Vector3.new(
        currentPosition.X,
        currentPosition.Y - 5,
        currentPosition.Z
    )
    platform.Parent = workspace
    MainModule.JumpRope.AntiFallPlatform = platform
    return platform
end

function MainModule.RemoveJumpRopeAntiFall()
    if MainModule.JumpRope.AntiFallPlatform and MainModule.JumpRope.AntiFallPlatform.Parent then
        MainModule.JumpRope.AntiFallPlatform:Destroy()
        MainModule.JumpRope.AntiFallPlatform = nil
    end
    return true
end

function MainModule.ToggleGlassBridgeAntiFall(enabled)
    if enabled then
        return MainModule.CreateGlassBridgeAntiFall()
    else
        return MainModule.RemoveGlassBridgeAntiFall()
    end
end

function MainModule.ToggleSkySquidAntiFall(enabled)
    if enabled then
        return MainModule.CreateSkySquidAntiFall()
    else
        return MainModule.RemoveSkySquidAntiFall()
    end
end

function MainModule.ToggleJumpRopeAntiFall(enabled)
    if enabled then
        return MainModule.CreateJumpRopeAntiFall()
    else
        return MainModule.RemoveJumpRopeAntiFall()
    end
end

function MainModule.ToggleGlassBridgeAntiBreak(enabled)
    MainModule.GlassBridge.AntiBreakEnabled = enabled
    if MainModule.GlassBridge.AntiBreakConnection then
        MainModule.GlassBridge.AntiBreakConnection:Disconnect()
        MainModule.GlassBridge.AntiBreakConnection = nil
    end
    if not enabled then
        for _, platform in pairs(MainModule.GlassBridge.GlassPlatforms) do
            if platform and platform.Parent then
                platform:Destroy()
            end
        end
        MainModule.GlassBridge.GlassPlatforms = {}
        return
    end
    local function createPlatformUnderGlass(glassModel)
        if not glassModel or not glassModel.PrimaryPart then return end
        local platformName = "AntiFallPlatform_" .. glassModel.Name
        local existingPlatform = nil
        for _, platform in pairs(MainModule.GlassBridge.GlassPlatforms) do
            if platform and platform.Name == platformName then
                existingPlatform = platform
                break
            end
        end
        if existingPlatform then
            existingPlatform.CFrame = glassModel.PrimaryPart.CFrame * CFrame.new(0, -1.5, 0)
            return existingPlatform
        end
        local platform = Instance.new("Part")
        platform.Name = platformName
        platform.Size = Vector3.new(5, 1, 5)
        platform.Anchored = true
        platform.CanCollide = true
        platform.Transparency = 1
        platform.CastShadow = false
        platform.CFrame = glassModel.PrimaryPart.CFrame * CFrame.new(0, -1.5, 0)
        platform.Parent = workspace
        table.insert(MainModule.GlassBridge.GlassPlatforms, platform)
        return platform
    end
    MainModule.GlassBridge.AntiBreakConnection = RunService.Heartbeat:Connect(function()
        local GlassBridge = workspace:FindFirstChild("GlassBridge")
        if not GlassBridge then return end
        local GlassHolder = GlassBridge:FindFirstChild("GlassHolder")
        if not GlassHolder then return end
        for _, rowFolder in pairs(GlassHolder:GetChildren()) do
            for _, glassModel in pairs(rowFolder:GetChildren()) do
                if glassModel:IsA("Model") and glassModel.PrimaryPart then
                    if glassModel.PrimaryPart:GetAttribute("exploitingisevil") ~= nil then
                        glassModel.PrimaryPart:SetAttribute("exploitingisevil", nil)
                    end
                    if glassModel.PrimaryPart:IsA("BasePart") then
                        glassModel.PrimaryPart.CanCollide = true
                        glassModel.PrimaryPart.Anchored = true
                        for _, descendant in pairs(glassModel:GetDescendants()) do
                            if descendant:IsA("BasePart") then
                                descendant.CanCollide = true
                                descendant.Anchored = true
                                descendant.Transparency = 0
                            end
                        end
                    end
                end
            end
        end
    end)
    task.spawn(function()
        task.wait(1)
        local GlassBridge = workspace:FindFirstChild("GlassBridge")
        if GlassBridge and GlassBridge:FindFirstChild("GlassHolder") then
            local GlassHolder = GlassBridge.GlassHolder
            for _, rowFolder in pairs(GlassHolder:GetChildren()) do
                for _, glassModel in pairs(rowFolder:GetChildren()) do
                    if glassModel:IsA("Model") and glassModel.PrimaryPart then
                        createPlatformUnderGlass(glassModel)
                    end
                end
            end
        end
    end)
end

function MainModule.RevealGlassBridge()
    local Effects = ReplicatedStorage:FindFirstChild("Modules") and 
                   ReplicatedStorage.Modules:FindFirstChild("Effects")
    local glassHolder = workspace:FindFirstChild("GlassBridge") and workspace.GlassBridge:FindFirstChild("GlassHolder")
    if not glassHolder then
        return
    end
    for _, tilePair in pairs(glassHolder:GetChildren()) do
        for _, tileModel in pairs(tilePair:GetChildren()) do
            if tileModel:IsA("Model") and tileModel.PrimaryPart then
                local primaryPart = tileModel.PrimaryPart
                for _, child in ipairs(tileModel:GetChildren()) do
                    if child:IsA("Highlight") then
                        child:Destroy()
                    end
                end
                local isBreakable = primaryPart:GetAttribute("exploitingisevil") == true
                local targetColor = isBreakable and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                local transparency = 0.5
                for _, part in pairs(tileModel:GetDescendants()) do
                    if part:IsA("BasePart") then
                        TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
                            Transparency = transparency,
                            Color = targetColor
                        }):Play()
                    end
                end
                local highlight = Instance.new("Highlight")
                highlight.FillColor = targetColor
                highlight.FillTransparency = 0.7
                highlight.OutlineTransparency = 0.5
                highlight.Parent = tileModel
            end
        end
    end
    if Effects then
        local success, result = pcall(function()
            return require(Effects)
        end)
        if success and result and result.AnnouncementTween then
            result.AnnouncementTween({
                AnnouncementOneLine = true,
                FasterTween = true,
                DisplayTime = 10,
                AnnouncementDisplayText = "[CreonHub]: Safe tiles are green, breakable tiles are red!"
            })
        end
    end
end

function MainModule.TeleportToGlassBridgeEnd()
    SafeTeleport(MainModule.GlassBridge.EndPosition)
end

function MainModule.DisableSpikes(remove)
    pcall(function()
        local hideAndSeekMap = workspace:FindFirstChild("HideAndSeekMap")
        local killingParts = hideAndSeekMap and hideAndSeekMap:FindFirstChild("KillingParts")
        if not killingParts then
            return false
        end
        if remove then
            MainModule.SpikesKill.OriginalSpikes = {}
            MainModule.SpikesKill.SpikesPosition = nil
            for _, spike in pairs(killingParts:GetChildren()) do
                if spike:IsA("BasePart") then
                    table.insert(MainModule.SpikesKill.OriginalSpikes, spike:Clone())
                    if not MainModule.SpikesKill.SpikesPosition then
                        MainModule.SpikesKill.SpikesPosition = spike.Position
                    end
                    spike:Destroy()
                end
            end
            MainModule.SpikesKill.SpikesRemoved = true
            return true
        else
            return true
        end
    end)
end

function MainModule.ToggleNoclip(enabled)
    MainModule.Noclip.Enabled = enabled
    
    if MainModule.Noclip.Connection then
        MainModule.Noclip.Connection:Disconnect()
        MainModule.Noclip.Connection = nil
    end
    
    local function NoclipLoop()
        if not MainModule.Noclip.Enabled then return end
        
        local character = GetCharacter()
        if not character then return end
        
        for _, child in pairs(character:GetDescendants()) do
            if child:IsA("BasePart") and child.CanCollide == true then
                child.CanCollide = false
                MainModule.Noclip.NoclipParts[child] = true
            end
        end
    end
    
    if enabled then
        MainModule.Noclip.Connection = RunService.Heartbeat:Connect(function()
            if MainModule.Noclip.Enabled then
                NoclipLoop()
            end
        end)
    else
        local character = GetCharacter()
        if character and MainModule.Noclip.NoclipParts then
            for part, _ in pairs(MainModule.Noclip.NoclipParts) do
                if part and part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
            MainModule.Noclip.NoclipParts = {}
        end
    end
end

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

function MainModule.GetPlayerPosition()
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            local position = rootPart.Position
            return string.format("X: %.1f, Y: %.1f, Z: %.1f", position.X, position.Y, position.Z)
        end
    end
    return "Не доступно"
end

function MainModule.Cleanup()
    -- Очистка всех соединений и состояний
    local connections = {
        speedConnection, autoFarmConnection, godModeConnection, instaInteractConnection,
        noCooldownConnection, antiStunConnection, rapidFireConnection, infiniteAmmoConnection,
        hitboxConnection, autoPullConnection, bypassRagdollConnection
    }
    
    for _, conn in pairs(connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    
    if MainModule.RLGL.Connection then
        MainModule.RLGL.Connection:Disconnect()
        MainModule.RLGL.Connection = nil
    end
    
    if MainModule.RLGL.PocketSandCheckConnection then
        MainModule.RLGL.PocketSandCheckConnection:Disconnect()
        MainModule.RLGL.PocketSandCheckConnection = nil
    end
    
    if MainModule.Rebel.Connection then
        MainModule.Rebel.Connection:Disconnect()
        MainModule.Rebel.Connection = nil
    end
    
    if MainModule.HNS.InfinityStaminaConnection then
        MainModule.HNS.InfinityStaminaConnection:Disconnect()
        MainModule.HNS.InfinityStaminaConnection = nil
    end
    
    if MainModule.SpikesKill.AnimationConnection then
        MainModule.SpikesKill.AnimationConnection:Disconnect()
        MainModule.SpikesKill.AnimationConnection = nil
    end
    
    if MainModule.SpikesKill.CharacterAddedConnection then
        MainModule.SpikesKill.CharacterAddedConnection:Disconnect()
        MainModule.SpikesKill.CharacterAddedConnection = nil
    end
    
    if MainModule.SpikesKill.SafetyCheckConnection then
        MainModule.SpikesKill.SafetyCheckConnection:Disconnect()
        MainModule.SpikesKill.SafetyCheckConnection = nil
    end
    
    if MainModule.SpikesKill.AnimationCheckConnection then
        MainModule.SpikesKill.AnimationCheckConnection:Disconnect()
        MainModule.SpikesKill.AnimationCheckConnection = nil
    end
    
    for _, conn in ipairs(MainModule.SpikesKill.AnimationStoppedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.SpikesKill.AnimationStoppedConnections = {}
    
    if MainModule.VoidKill.AnimationConnection then
        MainModule.VoidKill.AnimationConnection:Disconnect()
        MainModule.VoidKill.AnimationConnection = nil
    end
    
    if MainModule.VoidKill.CharacterAddedConnection then
        MainModule.VoidKill.CharacterAddedConnection:Disconnect()
        MainModule.VoidKill.CharacterAddedConnection = nil
    end
    
    if MainModule.VoidKill.AnimationCheckConnection then
        MainModule.VoidKill.AnimationCheckConnection:Disconnect()
        MainModule.VoidKill.AnimationCheckConnection = nil
    end
    
    for _, conn in ipairs(MainModule.VoidKill.AnimationStoppedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.VoidKill.AnimationStoppedConnections = {}
    
    if MainModule.ZoneKill.AnimationConnection then
        MainModule.ZoneKill.AnimationConnection:Disconnect()
        MainModule.ZoneKill.AnimationConnection = nil
    end
    
    if MainModule.ZoneKill.CharacterAddedConnection then
        MainModule.ZoneKill.CharacterAddedConnection:Disconnect()
        MainModule.ZoneKill.CharacterAddedConnection = nil
    end
    
    if MainModule.ZoneKill.AnimationCheckConnection then
        MainModule.ZoneKill.AnimationCheckConnection:Disconnect()
        MainModule.ZoneKill.AnimationCheckConnection = nil
    end
    
    for _, conn in ipairs(MainModule.ZoneKill.AnimationStoppedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.ZoneKill.AnimationStoppedConnections = {}
    
    if MainModule.GlassBridge.AntiBreakConnection then
        MainModule.GlassBridge.AntiBreakConnection:Disconnect()
        MainModule.GlassBridge.AntiBreakConnection = nil
    end
    
    if MainModule.GlassBridge.GlassESPConnection then
        MainModule.GlassBridge.GlassESPConnection:Disconnect()
        MainModule.GlassBridge.GlassESPConnection = nil
    end
    
    if MainModule.JumpRope.Connection then
        MainModule.JumpRope.Connection:Disconnect()
        MainModule.JumpRope.Connection = nil
    end
    
    if MainModule.SkySquid.Connection then
        MainModule.SkySquid.Connection:Disconnect()
        MainModule.SkySquid.Connection = nil
    end
    
    if MainModule.TugOfWar.Connection then
        MainModule.TugOfWar.Connection:Disconnect()
        MainModule.TugOfWar.Connection = nil
    end
    
    if MainModule.Hitbox.Connection then
        MainModule.Hitbox.Connection:Disconnect()
        MainModule.Hitbox.Connection = nil
    end
    
    if MainModule.AntiTimeStop.Connection then
        MainModule.AntiTimeStop.Connection:Disconnect()
        MainModule.AntiTimeStop.Connection = nil
    end
    
    for _, conn in pairs(MainModule.AutoDodge.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.AutoDodge.Connections = {}
    
    if MainModule.Noclip.Connection then
        MainModule.Noclip.Connection:Disconnect()
        MainModule.Noclip.Connection = nil
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root and MainModule.Hitbox.ModifiedParts[root] then
                root.Size = MainModule.Hitbox.ModifiedParts[root]
                root.CanCollide = true
            end
        end
    end
    MainModule.Hitbox.ModifiedParts = {}
    
    for obj, originalValue in pairs(MainModule.Guards.OriginalAmmo) do
        if obj and obj.Parent then
            obj.Value = originalValue
        end
    end
    MainModule.Guards.OriginalAmmo = {}
    
    for obj, originalValue in pairs(MainModule.Guards.OriginalFireRates) do
        if obj and obj.Parent then
            obj.Value = originalValue
        end
    end
    MainModule.Guards.OriginalFireRates = {}
    
    for humanoid, properties in pairs(MainModule.AntiTimeStop.OriginalProperties) do
        if humanoid and humanoid.Parent then
            humanoid.WalkSpeed = properties.WalkSpeed
            humanoid.JumpPower = properties.JumpPower
        end
    end
    MainModule.AntiTimeStop.OriginalProperties = {}
    
    for _, platform in pairs(MainModule.GlassBridge.GlassPlatforms) do
        if platform and platform.Parent then
            platform:Destroy()
        end
    end
    MainModule.GlassBridge.GlassPlatforms = {}
    
    if MainModule.GlassBridge.GlassAntiFallPlatform and MainModule.GlassBridge.GlassAntiFallPlatform.Parent then
        MainModule.RemoveGlassBridgeAntiFall()
    end
    
    if MainModule.SkySquid.AntiFallPlatform and MainModule.SkySquid.AntiFallPlatform.Parent then
        MainModule.RemoveSkySquidAntiFall()
    end
    
    if MainModule.JumpRope.AntiFallPlatform and MainModule.JumpRope.AntiFallPlatform.Parent then
        MainModule.RemoveJumpRopeAntiFall()
    end
    
    if MainModule.VoidKill.AntiFallEnabled then
        MainModule.RemoveSkySquidAntiFall()
        MainModule.VoidKill.AntiFallEnabled = false
    end
    
    if MainModule.SpeedHack.Enabled then
        MainModule.ToggleSpeedHack(false)
    end
    
    if MainModule.Noclip.Enabled then
        MainModule.ToggleNoclip(false)
    end
    
    -- Сброс всех состояний
    MainModule.SpeedHack.Enabled = false
    MainModule.SpeedHack.CurrentSpeed = 16
    MainModule.Noclip.Enabled = false
    MainModule.AutoDodge.Enabled = false
    MainModule.AutoQTE.AntiStunEnabled = false
    MainModule.Rebel.Enabled = false
    MainModule.RLGL.GodMode = false
    MainModule.Guards.AutoFarm = false
    MainModule.Guards.RapidFire = false
    MainModule.Guards.InfiniteAmmo = false
    MainModule.Guards.HitboxExpander = false
    MainModule.Hitbox.Enabled = false
    MainModule.AntiTimeStop.Enabled = false
    MainModule.HNS.InfinityStaminaEnabled = false
    MainModule.Misc.ESPEnabled = false
    MainModule.Misc.InstaInteract = false
    MainModule.Misc.NoCooldownProximity = false
    MainModule.Misc.BypassRagdollEnabled = false
    MainModule.TugOfWar.AutoPull = false
    MainModule.Dalgona.CompleteEnabled = false
    MainModule.Dalgona.FreeLighterEnabled = false
    MainModule.GlassBridge.AntiBreakEnabled = false
    MainModule.GlassBridge.AntiFallEnabled = false
    MainModule.GlassBridge.GlassESPEnabled = false
    MainModule.SpikesKill.Enabled = false
    MainModule.SpikesKill.TrackedAnimations = {}
    MainModule.SpikesKill.SpikesRemoved = false
    MainModule.SpikesKill.OriginalSpikes = {}
    MainModule.SpikesKill.SpikesPosition = nil
    MainModule.VoidKill.Enabled = false
    MainModule.VoidKill.TrackedAnimations = {}
    MainModule.ZoneKill.Enabled = false
    MainModule.ZoneKill.TrackedAnimations = {}
    
    MainModule.RLGL.OriginalHeight = nil
    MainModule.RLGL.OriginalPosition = nil
    MainModule.RLGL.LastHealth = 100
    MainModule.RLGL.PocketSandActive = false
    MainModule.RLGL.NoPocketSandTime = 0
    
    MainModule.HNS.HasKnife = false
    MainModule.HNS.HasDodge = false
end

LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not LocalPlayer.Parent then
        MainModule.Cleanup()
    end
end)

return MainModule
