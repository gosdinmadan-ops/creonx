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
    OriginalTransparency = {},
    OriginalCanCollide = {},
    AffectedParts = {},
    CheckDistance = 20,
    CheckInterval = 0.1
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
    DodgeCooldown = 0.4,
    Range = 4.8,
    RangeSquared = 7 * 7,
    AnimationIdsSet = {},
    PlayersInRange = {},
    LastRangeUpdate = 0,
    RangeUpdateInterval = 0.5
}

MainModule.Fly = {
    Enabled = false,
    Speed = 50, -- Фиксированная скорость 50
    Connection = nil,
    BodyVelocity = nil,
    HumanoidDiedConnection = nil,
    CharacterAddedConnection = nil,
    SpeedChangeConnection = nil,
    WasRagdollEnabled = false,
    
    -- НОВЫЕ ПОЛЯ ДЛЯ ИСПРАВЛЕННОГО КОДА:
    LastUpdate = 0,
    LastPosition = Vector3.new(0, 0, 0),
    OriginalStates = nil,
    FakeParts = {},
    LastGroundCheck = 0,
    GroundCheckInterval = 2, -- Интервал проверки земли для античита
    FakeFloorSize = Vector3.new(10, 1, 10) -- Размер fake floor
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
    LastDamageTime = 0,
    DamageCheckRate = 0.1,
    LastHealth = 100,
    GodModeHeight = 160,
    NormalHeight = 120,
    DamageTeleportPosition = Vector3.new(-903.4, 1184.9, -556),
    StartPosition = Vector3.new(-55.3, 1023.1, -545.8),
    EndPosition = Vector3.new(-214.4, 1023.1, 146.7),
    Connection = nil,
    PocketSandCheck = nil,
    NoPocketSandTimer = 0,
    NoPocketSandCooldown = 3
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

-- Изменены названия переменных для устранения конфликтов
MainModule.SpikesKillFeature = {
    Enabled = false,
    AnimationId = "rbxassetid://105341857343164",
    SpikesPosition = nil,
    PlatformHeightOffset = 5,
    ReturnDelay = 0.6,
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
    SpikesRemoved = false,
    KnifeCheckConnection = nil,
    LastKnifeCheckTime = 0,
    KnifeCheckCooldown = 0.5,
    HasKnife = false,
    NoKnifeTimer = 0,
    NoKnifeTimeout = 2
}

MainModule.VoidKillFeature = {
    Enabled = false,
    AnimationIds = {
        "rbxassetid://105341857343164",
        "rbxassetid://71619354165195"
    },
    ZonePosition = Vector3.new(-95.1, 964.6, 67.6),
    PlatformYOffset = -4,
    PlatformSize = Vector3.new(10, 1, 10),
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
    AntiFallPlatform = nil,
    AnimationIdsSet = {}
}

MainModule.ZoneKillFeature = {
    Enabled = false,
    AnimationId = "rbxassetid://105341857343164", -- Исправленная анимация для Zone Kill
    ZonePosition = Vector3.new(127.2, 54.6, 4.3),
    ReturnDelay = 0.6,
    SavedCFrame = nil,
    ActiveAnimation = false,
    AnimationStartTime = 0,
    AnimationConnection = nil,
    CharacterAddedConnection = nil,
    AnimationStoppedConnections = {},
    AnimationCheckConnection = nil,
    TrackedAnimations = {},
    ZoneCheckConnection = nil,
    LastAnimationCheckTime = 0
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

-- Новые функции
MainModule.FreeDash = {
    Enabled = false,
    OriginalSprintValue = 4,
    RemoteDestroyed = false
}

MainModule.FreeDashGuards = {
    Enabled = false,
    OriginalSprintValue = 4
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
    InfinityStaminaConnection = nil
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

local function playerHasKnife(player)
    if not player or not player.Character then return false end
    for _, tool in pairs(player.Character:GetChildren()) do
        if tool:IsA("Tool") then
            local toolName = tool.Name:lower()
            if toolName:find("knife") or toolName:find("fork") or toolName:find("dagger") or toolName:find("нож") then
                return true, tool
            end
        end
    end
    if player:FindFirstChild("Backpack") then
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local toolName = tool.Name:lower()
                if toolName:find("knife") or toolName:find("fork") or toolName:find("dagger") or toolName:find("нож") then
                    return true, tool
                end
            end
        end
    end
    return false, nil
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
    local tempPart = Instance.new("Part")
    tempPart.Size = Vector3.new(1, 1, 1)
    tempPart.Transparency = 1
    tempPart.Anchored = true
    tempPart.CanCollide = false
    tempPart.Position = currentPosition
    tempPart.Parent = workspace
    Debris:AddItem(tempPart, 0.1)
    local fakeVelocity = Instance.new("BodyVelocity")
    fakeVelocity.Velocity = (position - currentPosition).Unit * 100
    fakeVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
    fakeVelocity.Parent = rootPart
    Debris:AddItem(fakeVelocity, 0.1)
    rootPart.CFrame = CFrame.new(position)
    task.delay(0.05, function()
        if fakeVelocity and fakeVelocity.Parent then
            fakeVelocity:Destroy()
        end
    end)
    return true
end

local function GetSafePositionAbove(currentPosition, height)
    local rayOrigin = currentPosition + Vector3.new(0, 5, 0)
    local rayDirection = Vector3.new(0, -1, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    local result = workspace:Raycast(rayOrigin, rayDirection * 100, raycastParams)
    if result and result.Position then
        return result.Position + Vector3.new(0, height, 0)
    else
        return currentPosition + Vector3.new(0, height, 0)
    end
end

local function GetPlayerGun()
    local character = GetCharacter()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if character then
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") and tool:GetAttribute("Gun") then
                return tool
            end
        end
    end
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool:GetAttribute("Gun") then
                return tool
            end
        end
    end
    return nil
end

local function GetEnemies()
    local enemies = {}
    local liveFolder = Workspace:FindFirstChild("Live")
    if not liveFolder then return enemies end
    for _, model in pairs(liveFolder:GetChildren()) do
        if model:IsA("Model") then
            local enemyTag = model:FindFirstChild("Enemy")
            local deadTag = model:FindFirstChild("Dead")
            if enemyTag and not deadTag then
                local isPlayer = false
                for _, player in pairs(Players:GetPlayers()) do
                    if player.Name == model.Name then
                        isPlayer = true
                        break
                    end
                end
                if not isPlayer then
                    table.insert(enemies, model.Name)
                    if #enemies >= 5 then
                        break
                    end
                end
            end
        end
    end
    return enemies
end

local function KillEnemy(enemyName)
    pcall(function()
        local liveFolder = Workspace:FindFirstChild("Live")
        if not liveFolder then return end
        local enemy = liveFolder:FindFirstChild(enemyName)
        if not enemy then return end
        local enemyTag = enemy:FindFirstChild("Enemy")
        local deadTag = enemy:FindFirstChild("Dead")
        if not enemyTag or deadTag then return end
        local gun = GetPlayerGun()
        if not gun then return end
        local args = {
            gun,
            {
                ["ClientRayNormal"] = Vector3.new(-1.1920928955078125e-7, 1.0000001192092896, 0),
                ["FiredGun"] = true,
                ["SecondaryHitTargets"] = {},
                ["ClientRayInstance"] = Workspace:WaitForChild("StairWalkWay"):WaitForChild("Part"),
                ["ClientRayPosition"] = Vector3.new(-220.17489624023438, 183.2957763671875, 301.07257080078125),
                ["bulletCF"] = CFrame.new(-220.5039825439453, 185.22506713867188, 302.133544921875, 0.9551116228103638, 0.2567310333251953, -0.14782091975212097, 7.450581485102248e-9, 0.4989798665046692, 0.8666135668754578, 0.2962462604045868, -0.8277127146720886, 0.4765814542770386),
                ["HitTargets"] = {
                    [enemyName] = "Head"
                },
                ["bulletSizeC"] = Vector3.new(0.009999999776482582, 0.009999999776482582, 4.452499866485596),
                ["NoMuzzleFX"] = false,
                ["FirePosition"] = Vector3.new(-72.88850402832031, -679.4803466796875, -173.31005859375)
            }
        }
        local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("FiredGunClient")
        remote:FireServer(unpack(args))
    end)
end

-- Новые функции FreeDash и FreeDashGuards
function MainModule.ToggleFreeDash(enabled)
    MainModule.FreeDash.Enabled = enabled
    
    if enabled then
        -- Сохраняем оригинальное значение
        local boosts = LocalPlayer:FindFirstChild("Boosts")
        if boosts then
            local fasterSprint = boosts:FindFirstChild("Faster Sprint")
            if fasterSprint then
                MainModule.FreeDash.OriginalSprintValue = fasterSprint.Value
                fasterSprint.Value = 5
            end
        end
        
        -- Уничтожаем Remote если существует
        local remote = ReplicatedStorage:FindFirstChild("Remotes")
        if remote then
            remote = remote:FindFirstChild("DashRequest")
            if remote then
                remote:Destroy()
                MainModule.FreeDash.RemoteDestroyed = true
            end
        end
    else
        -- Восстанавливаем оригинальное значение
        local boosts = LocalPlayer:FindFirstChild("Boosts")
        if boosts then
            local fasterSprint = boosts:FindFirstChild("Faster Sprint")
            if fasterSprint then
                fasterSprint.Value = MainModule.FreeDash.OriginalSprintValue
            end
        end
    end
end

function MainModule.ToggleFreeDashGuards(enabled)
    MainModule.FreeDashGuards.Enabled = enabled
    
    if enabled then
        -- Сохраняем оригинальное значение
        local boosts = LocalPlayer:FindFirstChild("Boosts")
        if boosts then
            local fasterSprint = boosts:FindFirstChild("Faster Sprint")
            if fasterSprint then
                MainModule.FreeDashGuards.OriginalSprintValue = fasterSprint.Value
                fasterSprint.Value = 5
            end
        end
    else
        -- Восстанавливаем оригинальное значение
        local boosts = LocalPlayer:FindFirstChild("Boosts")
        if boosts then
            local fasterSprint = boosts:FindFirstChild("Faster Sprint")
            if fasterSprint then
                fasterSprint.Value = MainModule.FreeDashGuards.OriginalSprintValue
            end
        end
    end
end

function MainModule.ToggleAntiTimeStop(enabled)
    MainModule.AntiTimeStop.Enabled = enabled
    if MainModule.AntiTimeStop.Connection then
        MainModule.AntiTimeStop.Connection:Disconnect()
        MainModule.AntiTimeStop.Connection = nil
    end
    if enabled then
        MainModule.AntiTimeStop.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.AntiTimeStop.Enabled then return end
            pcall(function()
                local character = GetCharacter()
                if not character then return end
                local humanoid = GetHumanoid(character)
                if not humanoid then return end
                if not MainModule.AntiTimeStop.OriginalProperties[humanoid] then
                    MainModule.AntiTimeStop.OriginalProperties[humanoid] = {
                        WalkSpeed = humanoid.WalkSpeed,
                        JumpPower = humanoid.JumpPower
                    }
                end
                local isFrozen = false
                local frozenEffects = {
                    "TimeStop", "TimeStopEffect", "TimeStopDebuff", "Frozen", "Freeze", 
                    "Stopped", "TimeLock", "TimeFreeze", "ZaWarudo"
                }
                for _, effectName in ipairs(frozenEffects) do
                    local effect = character:FindFirstChild(effectName)
                    if effect then
                        isFrozen = true
                        break
                    end
                end
                if humanoid:GetAttribute("TimeStopped") or 
                   humanoid:GetAttribute("Frozen") or 
                   humanoid:GetAttribute("Stopped") then
                    isFrozen = true
                end
                if isFrozen then
                    humanoid.WalkSpeed = MainModule.AntiTimeStop.OriginalProperties[humanoid].WalkSpeed
                    humanoid.JumpPower = MainModule.AntiTimeStop.OriginalProperties[humanoid].JumpPower
                    for _, effectName in ipairs(frozenEffects) do
                        local effect = character:FindFirstChild(effectName)
                        if effect then
                            effect:Destroy()
                        end
                    end
                    humanoid:SetAttribute("TimeStopped", false)
                    humanoid:SetAttribute("Frozen", false)
                    humanoid:SetAttribute("Stopped", false)
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    humanoid.PlatformStand = false
                end
            end)
        end)
        local character = GetCharacter()
        if character then
            character.ChildAdded:Connect(function(child)
                if not MainModule.AntiTimeStop.Enabled then return end
                if child.Name:find("TimeStop") or child.Name:find("Freeze") then
                    task.wait(0.1)
                    pcall(function() child:Destroy() end)
                end
            end)
        end
    else
        for humanoid, properties in pairs(MainModule.AntiTimeStop.OriginalProperties) do
            if humanoid and humanoid.Parent then
                humanoid.WalkSpeed = properties.WalkSpeed
                humanoid.JumpPower = properties.JumpPower
            end
        end
        MainModule.AntiTimeStop.OriginalProperties = {}
    end
end

function MainModule.ToggleRebel(enabled)
    MainModule.Rebel.Enabled = enabled
    if MainModule.Rebel.Connection then
        MainModule.Rebel.Connection:Disconnect()
        MainModule.Rebel.Connection = nil
    end
    if enabled then
        MainModule.Rebel.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.Rebel.Enabled then return end
            local currentTime = tick()
            if currentTime - MainModule.Rebel.LastCheckTime < MainModule.Rebel.CheckCooldown then return end
            MainModule.Rebel.LastCheckTime = currentTime
            local enemies = GetEnemies()
            if #enemies == 0 then return end
            for _, enemyName in pairs(enemies) do
                if currentTime - MainModule.Rebel.LastKillTime < MainModule.Rebel.KillCooldown then
                    task.wait(MainModule.Rebel.KillCooldown)
                end
                KillEnemy(enemyName)
                MainModule.Rebel.LastKillTime = tick()
                task.wait(0.05)
            end
        end)
    else
        MainModule.Rebel.LastKillTime = 0
        MainModule.Rebel.LastCheckTime = 0
    end
end

function MainModule.HasPocketSand()
    local character = GetCharacter()
    if character then
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == "Pocket Sand" then
                return true
            end
        end
    end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == "Pocket Sand" then
                return true
            end
        end
    end
    
    return false
end

function MainModule.ToggleGodMode(enabled)
    MainModule.RLGL.GodMode = enabled
    
    if MainModule.RLGL.Connection then
        MainModule.RLGL.Connection:Disconnect()
        MainModule.RLGL.Connection = nil
    end
    
    if MainModule.RLGL.PocketSandCheck then
        MainModule.RLGL.PocketSandCheck:Disconnect()
        MainModule.RLGL.PocketSandCheck = nil
    end
    
    if enabled then
        local character = GetCharacter()
        if character then
            local rootPart = GetRootPart(character)
            if rootPart then
                MainModule.RLGL.OriginalHeight = rootPart.Position.Y
                local targetHeight = rootPart.Position.Y + MainModule.RLGL.GodModeHeight
                local targetPos = Vector3.new(rootPart.Position.X, targetHeight, rootPart.Position.Z)
                SafeTeleport(targetPos)
            end
        end
        
        MainModule.RLGL.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.RLGL.GodMode then return end
            
            if not MainModule.HasPocketSand() then
                MainModule.RLGL.NoPocketSandTimer = MainModule.RLGL.NoPocketSandTimer + task.wait()
                if MainModule.RLGL.NoPocketSandTimer >= MainModule.RLGL.NoPocketSandCooldown then
                    MainModule.ToggleGodMode(false)
                    return
                end
            else
                MainModule.RLGL.NoPocketSandTimer = 0
            end
            
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
        
        MainModule.RLGL.PocketSandCheck = RunService.Heartbeat:Connect(function()
            if not MainModule.RLGL.GodMode then return end
            
            if not MainModule.HasPocketSand() then
                MainModule.RLGL.NoPocketSandTimer = MainModule.RLGL.NoPocketSandTimer + task.wait()
                if MainModule.RLGL.NoPocketSandTimer >= MainModule.RLGL.NoPocketSandCooldown then
                    MainModule.ToggleGodMode(false)
                end
            else
                MainModule.RLGL.NoPocketSandTimer = 0
            end
        end)
    else
        if MainModule.RLGL.OriginalHeight then
            local character = GetCharacter()
            if character then
                local rootPart = GetRootPart(character)
                if rootPart then
                    local targetPos = Vector3.new(rootPart.Position.X, MainModule.RLGL.OriginalHeight, rootPart.Position.Z)
                    SafeTeleport(targetPos)
                end
            end
        end
        
        MainModule.RLGL.LastHealth = 100
        MainModule.RLGL.OriginalHeight = nil
        MainModule.RLGL.NoPocketSandTimer = 0
    end
end

function MainModule.TeleportToEnd()
    SafeTeleport(MainModule.RLGL.EndPosition)
end

function MainModule.TeleportToStart()
    SafeTeleport(MainModule.RLGL.StartPosition)
end

function MainModule.ToggleBypassRagdoll(enabled)
    if MainModule.Fly.Enabled then
        MainModule.Fly.WasRagdollEnabled = enabled
        return
    end
    
    MainModule.Misc.BypassRagdollEnabled = enabled
    if bypassRagdollConnection then
        bypassRagdollConnection:Disconnect()
        bypassRagdollConnection = nil
    end
    if enabled then
        bypassRagdollConnection = RunService.Stepped:Connect(function()
            if not MainModule.Misc.BypassRagdollEnabled then return end
            pcall(function()
                local Character = GetCharacter()
                if not Character then return end
                local Humanoid = GetHumanoid(Character)
                local HumanoidRootPart = GetRootPart(Character)
                if not (Humanoid and HumanoidRootPart) then return end
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
                local harmfulFolders = {"RotateDisabled", "RagdollWakeupImmunity"}
                for _, folderName in pairs(harmfulFolders) do
                    local folder = Character:FindFirstChild(folderName)
                    if folder then
                        folder:Destroy()
                    end
                end
                for _, part in pairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        local currentVelocity = part.Velocity
                        local horizontalSpeed = Vector3.new(currentVelocity.X, 0, currentVelocity.Z).Magnitude
                        if horizontalSpeed > 50 and part ~= HumanoidRootPart then
                            local newVelocity = Vector3.new(
                                currentVelocity.X * 0.8,
                                currentVelocity.Y,
                                currentVelocity.Z * 0.8
                            )
                            part.Velocity = newVelocity
                        end
                        for _, force in pairs(part:GetChildren()) do
                            if force:IsA("BodyForce") then
                                local forceMagnitude = force.Force.Magnitude
                                if forceMagnitude > 1000 then
                                    force:Destroy()
                                end
                            elseif force:IsA("BodyVelocity") then
                                if force.Velocity.Magnitude > 30 then
                                    force:Destroy()
                                end
                            end
                        end
                    end
                end
                local playerInputVelocity = HumanoidRootPart.Velocity
                local externalForces = {}
                for _, force in pairs(HumanoidRootPart:GetChildren()) do
                    if force:IsA("BodyForce") or force:IsA("BodyVelocity") then
                        table.insert(externalForces, force)
                    end
                end
                if #externalForces > 0 then
                    local filteredVelocity = Vector3.new(
                        playerInputVelocity.X,
                        HumanoidRootPart.Velocity.Y,
                        playerInputVelocity.Z
                    )
                    HumanoidRootPart.Velocity = filteredVelocity
                    for _, force in pairs(externalForces) do
                        task.spawn(function()
                            if force:IsA("BodyVelocity") then
                                for i = 1, 5 do
                                    if force and force.Parent then
                                        force.Velocity = force.Velocity * 0.5
                                        task.wait(0.02)
                                    end
                                end
                            end
                            pcall(function() force:Destroy() end)
                        end)
                    end
                end
            end)
        end)
        local char = GetCharacter()
        if char then
            char.ChildAdded:Connect(function(child)
                if child.Name == "Ragdoll" and MainModule.Misc.BypassRagdollEnabled then
                    task.wait(0.1)
                    pcall(function() child:Destroy() end)
                    local humanoid = GetHumanoid(char)
                    if humanoid then
                        humanoid.PlatformStand = false
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end
            end)
        end
        task.wait(0.5)
        MainModule.StartEnhancedProtection()
        MainModule.StartJointCleaning()
    else
        local character = GetCharacter()
        if character then
            local rootPart = GetRootPart(character)
            if rootPart then
                for _, conn in pairs(getconnections(rootPart.ChildAdded)) do
                    conn:Disconnect()
                end
            end
        end
        MainModule.StopEnhancedProtection()
        MainModule.StopJointCleaning()
    end
end

local harmfulEffectsList = {
    "RagdollStun", "Stun", "Stunned", "StunEffect", "StunHit",
    "Knockback", "Knockdown", "Knockout", "KB_Effect",
    "Dazed", "Paralyzed", "Paralyze", "Freeze", "Frozen", 
    "Sleep", "Sleeping", "SleepEffect", "Confusion", "Confused",
    "Slow", "Slowed", "Root", "Rooted", "Immobilized",
    "Bleed", "Bleeding", "Poison", "Poisoned", "Burn", "Burning",
    "Shock", "Shocked", "Electrocuted", "Silence", "Silenced",
    "Disarm", "Disarmed", "Blind", "Blinded", "Fear", "Feared",
    "Taunt", "Taunted", "Charm", "Charmed", "Petrify", "Petrified"
}

local enhancedProtectionConnection = nil
local jointCleaningConnection = nil
local ragdollBlockConnection = nil

local function CleanNegativeEffects(character)
    if not character or not MainModule.Misc.BypassRagdollEnabled then return end
    pcall(function()
        for _, effectName in ipairs(harmfulEffectsList) do
            local effect = character:FindFirstChild(effectName)
            if effect then
                if effect:IsA("BasePart") then
                    task.spawn(function()
                        for i = 1, 5 do
                            if effect and effect.Parent then
                                effect.Transparency = effect.Transparency + 0.2
                                task.wait(0.02)
                            end
                        end
                        pcall(function() effect:Destroy() end)
                    end)
                else
                    pcall(function() effect:Destroy() end)
                end
            end
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local badAttributes = {"Stunned", "Paralyzed", "Frozen", "Asleep", "Confused", 
                                   "Slowed", "Rooted", "Silenced", "Disarmed", "Blinded", "Feared"}
            for _, attr in ipairs(badAttributes) do
                if humanoid:GetAttribute(attr) then
                    humanoid:SetAttribute(attr, false)
                end
            end
        end
    end)
end

local function CleanJointsAndConstraints(character)
    if not character then return end
    pcall(function()
        local Humanoid = character:FindFirstChild("Humanoid")
        local HumanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local Torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
        if not (Humanoid and HumanoidRootPart and Torso) then return end
        for _, child in ipairs(character:GetChildren()) do
            if child.Name == "Ragdoll" then
                pcall(function() child:Destroy() end)
            end
        end
        for _, folderName in pairs({"Stun", "RotateDisabled", "RagdollWakeupImmunity", "InjuredWalking"}) do
            local folder = character:FindFirstChild(folderName)
            if folder then
                folder:Destroy()
            end
        end
        for _, obj in pairs(HumanoidRootPart:GetChildren()) do
            if obj:IsA("BallSocketConstraint") or obj.Name:match("^CacheAttachment") then
                obj:Destroy()
            end
        end
        local joints = {"Left Hip", "Left Shoulder", "Neck", "Right Hip", "Right Shoulder"}
        for _, jointName in pairs(joints) do
            local motor = Torso:FindFirstChild(jointName)
            if motor and motor:IsA("Motor6D") and not motor.Part0 then
                motor.Part0 = Torso
            end
        end
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and part:FindFirstChild("BoneCustom") then
                part.BoneCustom:Destroy()
            end
        end
    end)
end

local function SetupRagdollListener(character)
    if not character then return end
    if ragdollBlockConnection then
        ragdollBlockConnection:Disconnect()
        ragdollBlockConnection = nil
    end
    local Humanoid = character:FindFirstChild("Humanoid")
    if not Humanoid then return end
    ragdollBlockConnection = character.ChildAdded:Connect(function(child)
        if child.Name == "Ragdoll" then
            pcall(function() child:Destroy() end)
            pcall(function()
                Humanoid.PlatformStand = false
                Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            end)
        end
    end)
end

function MainModule.StartEnhancedProtection()
    if enhancedProtectionConnection then
        enhancedProtectionConnection:Disconnect()
    end
    enhancedProtectionConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.Misc.BypassRagdollEnabled then return end
        local character = GetCharacter()
        if character then
            CleanNegativeEffects(character)
        end
    end)
end

function MainModule.StopEnhancedProtection()
    if enhancedProtectionConnection then
        enhancedProtectionConnection:Disconnect()
        enhancedProtectionConnection = nil
    end
end

function MainModule.StartJointCleaning()
    if jointCleaningConnection then
        jointCleaningConnection:Disconnect()
    end
    local character = GetCharacter()
    if character then
        CleanJointsAndConstraints(character)
        SetupRagdollListener(character)
    end
    jointCleaningConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.Misc.BypassRagdollEnabled then return end
        local character = GetCharacter()
        if character then
            CleanJointsAndConstraints(character)
        end
    end)
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        SetupRagdollListener(newChar)
        CleanJointsAndConstraints(newChar)
    end)
end

function MainModule.StopJointCleaning()
    if jointCleaningConnection then
        jointCleaningConnection:Disconnect()
        jointCleaningConnection = nil
    end
    if ragdollBlockConnection then
        ragdollBlockConnection:Disconnect()
        ragdollBlockConnection = nil
    end
end

function MainModule.FullCleanup()
    local character = GetCharacter()
    if character then
        CleanNegativeEffects(character)
        CleanJointsAndConstraints(character)
        return true
    end
    return false
end

function MainModule.ToggleESP(enabled)
    MainModule.Misc.ESPEnabled = enabled
    if MainModule.ESP.MainConnection then
        MainModule.ESP.MainConnection:Disconnect()
        MainModule.ESP.MainConnection = nil
    end
    MainModule.ClearESP()
    if enabled then
        MainModule.ESP.Folder = Instance.new("Folder")
        MainModule.ESP.Folder.Name = "CreonXESP"
        MainModule.ESP.Folder.Parent = CoreGui
        local function UpdatePlayerESP(player)
            if not player or player == LocalPlayer then return end
            local character = player.Character
            if not character then return end
            local humanoid = GetHumanoid(character)
            local rootPart = GetRootPart(character)
            if not (humanoid and rootPart and humanoid.Health > 0) then return end
            local localCharacter = GetCharacter()
            local localRoot = localCharacter and GetRootPart(localCharacter)
            local espData = MainModule.ESP.Players[player]
            if not espData then
                espData = {
                    Player = player,
                    Highlight = nil,
                    Billboard = nil,
                    Label = nil
                }
                MainModule.ESP.Players[player] = espData
            end
            if not espData.Highlight then
                espData.Highlight = Instance.new("Highlight")
                espData.Highlight.Name = player.Name .. "_ESP"
                espData.Highlight.Adornee = character
                espData.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                espData.Highlight.Enabled = MainModule.Misc.ESPHighlight
                espData.Highlight.Parent = MainModule.ESP.Folder
            end
            if IsHider(player) and MainModule.Misc.ESPHiders then
                espData.Highlight.FillColor = Color3.fromRGB(0, 255, 0)
                espData.Highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
            elseif IsSeeker(player) and MainModule.Misc.ESPSeekers then
                espData.Highlight.FillColor = Color3.fromRGB(255, 0, 0)
                espData.Highlight.OutlineColor = Color3.fromRGB(200, 0, 0)
            elseif MainModule.Misc.ESPPlayers then
                espData.Highlight.FillColor = Color3.fromRGB(0, 120, 255)
                espData.Highlight.OutlineColor = Color3.fromRGB(0, 100, 200)
            else
                espData.Highlight.Enabled = false
            end
            espData.Highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
            espData.Highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
            if MainModule.Misc.ESPNames then
                if not espData.Billboard then
                    espData.Billboard = Instance.new("BillboardGui")
                    espData.Billboard.Name = player.Name .. "_Text"
                    espData.Billboard.Adornee = rootPart
                    espData.Billboard.AlwaysOnTop = true
                    espData.Billboard.Size = UDim2.new(0, 200, 0, 50)
                    espData.Billboard.StudsOffset = Vector3.new(0, 3, 0)
                    espData.Billboard.Parent = MainModule.ESP.Folder
                    espData.Label = Instance.new("TextLabel")
                    espData.Label.Size = UDim2.new(1, 0, 1, 0)
                    espData.Label.BackgroundTransparency = 1
                    espData.Label.TextColor3 = espData.Highlight.FillColor
                    espData.Label.TextSize = MainModule.Misc.ESPTextSize
                    espData.Label.Font = Enum.Font.GothamBold
                    espData.Label.TextStrokeColor3 = Color3.new(0, 0, 0)
                    espData.Label.TextStrokeTransparency = 0.5
                    espData.Label.Parent = espData.Billboard
                end
                espData.Billboard.Enabled = true
                local distanceText = ""
                if MainModule.Misc.ESPDistance and localRoot then
                    local distance = math.floor(GetDistance(rootPart.Position, localRoot.Position))
                    distanceText = string.format(" [%dm]", distance)
                end
                local healthText = string.format("HP: %d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
                local nameText = player.DisplayName or player.Name
                espData.Label.Text = string.format("%s\n%s%s", nameText, healthText, distanceText)
                espData.Label.TextColor3 = espData.Highlight.FillColor
                espData.Label.TextSize = MainModule.Misc.ESPTextSize
            elseif espData.Billboard then
                espData.Billboard.Enabled = false
            end
        end
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                UpdatePlayerESP(player)
                player.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    UpdatePlayerESP(player)
                end)
            end
        end
        MainModule.ESP.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
            if MainModule.Misc.ESPEnabled and player ~= LocalPlayer then
                task.wait(0.5)
                UpdatePlayerESP(player)
            end
        end)
        MainModule.ESP.MainConnection = RunService.RenderStepped:Connect(function()
            if not MainModule.Misc.ESPEnabled then return end
            for player, espData in pairs(MainModule.ESP.Players) do
                if player and player.Parent and player.Character then
                    UpdatePlayerESP(player)
                else
                    if espData.Highlight then
                        SafeDestroy(espData.Highlight)
                    end
                    if espData.Billboard then
                        SafeDestroy(espData.Billboard)
                    end
                    MainModule.ESP.Players[player] = nil
                end
            end
        end)
    end
end

function MainModule.ClearESP()
    for player, espData in pairs(MainModule.ESP.Players) do
        if espData.Highlight then
            SafeDestroy(espData.Highlight)
        end
        if espData.Billboard then
            SafeDestroy(espData.Billboard)
        end
    end
    MainModule.ESP.Players = {}
    if MainModule.ESP.Connections then
        for name, connection in pairs(MainModule.ESP.Connections) do
            if connection then
                pcall(function() connection:Disconnect() end)
                MainModule.ESP.Connections[name] = nil
            end
        end
    end
    if MainModule.ESP.Folder then
        SafeDestroy(MainModule.ESP.Folder)
        MainModule.ESP.Folder = nil
    end
    if MainModule.ESP.MainConnection then
        MainModule.ESP.MainConnection:Disconnect()
        MainModule.ESP.MainConnection = nil
    end
end

function MainModule.CheckKnifeInInventory()
    local character = GetCharacter()
    if not character then return false end
    
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            local toolName = tool.Name:lower()
            if toolName:find("knife") or toolName:find("fork") or toolName:find("dagger") or toolName:find("нож") then
                return true, tool
            end
        end
    end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local toolName = tool.Name:lower()
                if toolName:find("knife") or toolName:find("fork") or toolName:find("dagger") or toolName:find("нож") then
                    return true, tool
                end
            end
        end
    end
    
    return false, nil
end

function MainModule.ToggleSpikesKill(enabled)
    if enabled then
        local hasKnife = MainModule.CheckKnifeInInventory()
        if not hasKnife then
            print("[CreonX] Spikes Kill: No knife in inventory")
            MainModule.SpikesKillFeature.Enabled = false
            return
        end
        MainModule.SpikesKillFeature.HasKnife = true
    end
    
    MainModule.SpikesKillFeature.Enabled = enabled
    
    if MainModule.SpikesKillFeature.AnimationConnection then
        MainModule.SpikesKillFeature.AnimationConnection:Disconnect()
        MainModule.SpikesKillFeature.AnimationConnection = nil
    end
    if MainModule.SpikesKillFeature.CharacterAddedConnection then
        MainModule.SpikesKillFeature.CharacterAddedConnection:Disconnect()
        MainModule.SpikesKillFeature.CharacterAddedConnection = nil
    end
    if MainModule.SpikesKillFeature.SafetyCheckConnection then
        MainModule.SpikesKillFeature.SafetyCheckConnection:Disconnect()
        MainModule.SpikesKillFeature.SafetyCheckConnection = nil
    end
    if MainModule.SpikesKillFeature.AnimationCheckConnection then
        MainModule.SpikesKillFeature.AnimationCheckConnection:Disconnect()
        MainModule.SpikesKillFeature.AnimationCheckConnection = nil
    end
    if MainModule.SpikesKillFeature.KnifeCheckConnection then
        MainModule.SpikesKillFeature.KnifeCheckConnection:Disconnect()
        MainModule.SpikesKillFeature.KnifeCheckConnection = nil
    end
    
    for _, conn in ipairs(MainModule.SpikesKillFeature.AnimationStoppedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.SpikesKillFeature.AnimationStoppedConnections = {}
    
    MainModule.SpikesKillFeature.SavedCFrame = nil
    MainModule.SpikesKillFeature.ActiveAnimation = false
    MainModule.SpikesKillFeature.AnimationStartTime = 0
    MainModule.SpikesKillFeature.TrackedAnimations = {}
    MainModule.SpikesKillFeature.NoKnifeTimer = 0
    
    if not enabled then
        MainModule.SpikesKillFeature.HasKnife = false
        return
    end
    
    MainModule.DisableSpikes(true)
    
    local function checkAnimations()
        if not MainModule.SpikesKillFeature.Enabled then return end
        
        local character = GetCharacter()
        if not character then return end
        local humanoid = GetHumanoid(character)
        if not humanoid then return end
        
        local activeTracks = humanoid:GetPlayingAnimationTracks()
        for _, track in pairs(activeTracks) do
            if track.Animation and track.Animation.AnimationId == MainModule.SpikesKillFeature.AnimationId then
                if not MainModule.SpikesKillFeature.TrackedAnimations[track] then
                    MainModule.SpikesKillFeature.TrackedAnimations[track] = true
                    
                    if not MainModule.SpikesKillFeature.ActiveAnimation then
                        MainModule.SpikesKillFeature.ActiveAnimation = true
                        MainModule.SpikesKillFeature.AnimationStartTime = tick()
                        
                        MainModule.SpikesKillFeature.SavedCFrame = character:GetPrimaryPartCFrame()
                        
                        local spikesPosition = MainModule.SpikesKillFeature.SpikesPosition
                        if not spikesPosition then
                            local hideAndSeekMap = workspace:FindFirstChild("HideAndSeekMap")
                            local killingParts = hideAndSeekMap and hideAndSeekMap:FindFirstChild("KillingParts")
                            if killingParts and killingParts:FindFirstChildWhichIsA("BasePart") then
                                local firstSpike = killingParts:FindFirstChildWhichIsA("BasePart")
                                if firstSpike then
                                    spikesPosition = firstSpike.Position
                                    MainModule.SpikesKillFeature.SpikesPosition = spikesPosition
                                end
                            end
                        end
                        
                        if spikesPosition then
                            local targetPosition = spikesPosition + Vector3.new(0, MainModule.SpikesKillFeature.PlatformHeightOffset, 0)
                            character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
                        else
                            local currentPos = character:GetPrimaryPartCFrame().Position
                            local targetPosition = currentPos + Vector3.new(0, MainModule.SpikesKillFeature.PlatformHeightOffset, 0)
                            character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
                        end
                        
                        local stoppedConn = track.Stopped:Connect(function()
                            task.wait(MainModule.SpikesKillFeature.ReturnDelay)
                            
                            if MainModule.SpikesKillFeature.ActiveAnimation and MainModule.SpikesKillFeature.SavedCFrame then
                                character:SetPrimaryPartCFrame(MainModule.SpikesKillFeature.SavedCFrame)
                                MainModule.SpikesKillFeature.SavedCFrame = nil
                                MainModule.SpikesKillFeature.ActiveAnimation = false
                                MainModule.SpikesKillFeature.TrackedAnimations = {}
                            end
                        end)
                        table.insert(MainModule.SpikesKillFeature.AnimationStoppedConnections, stoppedConn)
                    end
                end
            end
        end
    end
    
    local function setupCharacter(char)
        local humanoid = char:WaitForChild("Humanoid")
        
        MainModule.SpikesKillFeature.AnimationConnection = humanoid.AnimationPlayed:Connect(function(track)
            if not MainModule.SpikesKillFeature.Enabled then return end
            
            if track.Animation and track.Animation.AnimationId == MainModule.SpikesKillFeature.AnimationId then
                MainModule.SpikesKillFeature.TrackedAnimations[track] = true
                
                if not MainModule.SpikesKillFeature.ActiveAnimation then
                    MainModule.SpikesKillFeature.ActiveAnimation = true
                    MainModule.SpikesKillFeature.AnimationStartTime = tick()
                    
                    MainModule.SpikesKillFeature.SavedCFrame = char:GetPrimaryPartCFrame()
                    
                    local spikesPosition = MainModule.SpikesKillFeature.SpikesPosition
                    if not spikesPosition then
                        local hideAndSeekMap = workspace:FindFirstChild("HideAndSeekMap")
                        local killingParts = hideAndSeekMap and hideAndSeekMap:FindFirstChild("KillingParts")
                        if killingParts and killingParts:FindFirstChildWhichIsA("BasePart") then
                            local firstSpike = killingParts:FindFirstChildWhichIsA("BasePart")
                            if firstSpike then
                                spikesPosition = firstSpike.Position
                                MainModule.SpikesKillFeature.SpikesPosition = spikesPosition
                            end
                        end
                    end
                    
                    if spikesPosition then
                        local targetPosition = spikesPosition + Vector3.new(0, MainModule.SpikesKillFeature.PlatformHeightOffset, 0)
                        char:SetPrimaryPartCFrame(CFrame.new(targetPosition))
                    else
                        local currentPos = char:GetPrimaryPartCFrame().Position
                        local targetPosition = currentPos + Vector3.new(0, MainModule.SpikesKillFeature.PlatformHeightOffset, 0)
                        char:SetPrimaryPartCFrame(CFrame.new(targetPosition))
                    end
                    
                    local stoppedConn = track.Stopped:Connect(function()
                        task.wait(MainModule.SpikesKillFeature.ReturnDelay)
                        
                        if MainModule.SpikesKillFeature.SavedCFrame then
                            char:SetPrimaryPartCFrame(MainModule.SpikesKillFeature.SavedCFrame)
                            MainModule.SpikesKillFeature.SavedCFrame = nil
                            MainModule.SpikesKillFeature.ActiveAnimation = false
                            MainModule.SpikesKillFeature.TrackedAnimations = {}
                        end
                    end)
                    table.insert(MainModule.SpikesKillFeature.AnimationStoppedConnections, stoppedConn)
                end
            end
        end)
    end
    
    local char = LocalPlayer.Character
    if char then
        setupCharacter(char)
    end
    
    MainModule.SpikesKillFeature.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        setupCharacter(newChar)
    end)
    
    MainModule.SpikesKillFeature.AnimationCheckConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.SpikesKillFeature.Enabled then return end
        checkAnimations()
    end)
    
    MainModule.SpikesKillFeature.SafetyCheckConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.SpikesKillFeature.ActiveAnimation then return end
        if tick() - MainModule.SpikesKillFeature.AnimationStartTime >= 10 then
            MainModule.SpikesKillFeature.ActiveAnimation = false
        end
    end)
    
    MainModule.SpikesKillFeature.KnifeCheckConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.SpikesKillFeature.Enabled then return end
        
        local currentTime = tick()
        if currentTime - MainModule.SpikesKillFeature.LastKnifeCheckTime < MainModule.SpikesKillFeature.KnifeCheckCooldown then
            return
        end
        MainModule.SpikesKillFeature.LastKnifeCheckTime = currentTime
        
        local hasKnife = MainModule.CheckKnifeInInventory()
        
        if hasKnife then
            MainModule.SpikesKillFeature.HasKnife = true
            MainModule.SpikesKillFeature.NoKnifeTimer = 0
        else
            MainModule.SpikesKillFeature.NoKnifeTimer = MainModule.SpikesKillFeature.NoKnifeTimer + MainModule.SpikesKillFeature.KnifeCheckCooldown
            
            if MainModule.SpikesKillFeature.NoKnifeTimer >= MainModule.SpikesKillFeature.NoKnifeTimeout then
                print("[CreonX] Spikes Kill: Knife lost, disabling...")
                MainModule.ToggleSpikesKill(false)
            end
        end
    end)
end

function MainModule.DisableSpikes(remove)
    pcall(function()
        local hideAndSeekMap = workspace:FindFirstChild("HideAndSeekMap")
        local killingParts = hideAndSeekMap and hideAndSeekMap:FindFirstChild("KillingParts")
        if not killingParts then
            return false
        end
        if remove then
            MainModule.SpikesKillFeature.OriginalSpikes = {}
            MainModule.SpikesKillFeature.SpikesPosition = nil
            for _, spike in pairs(killingParts:GetChildren()) do
                if spike:IsA("BasePart") then
                    table.insert(MainModule.SpikesKillFeature.OriginalSpikes, spike:Clone())
                    if not MainModule.SpikesKillFeature.SpikesPosition then
                        MainModule.SpikesKillFeature.SpikesPosition = spike.Position
                    end
                    spike:Destroy()
                end
            end
            MainModule.SpikesKillFeature.SpikesRemoved = true
            return true
        else
            return true
        end
    end)
end

-- Инициализируем set
for _, id in ipairs(MainModule.VoidKillFeature.AnimationIds) do
    MainModule.VoidKillFeature.AnimationIdsSet[id] = true
end

function MainModule.ToggleVoidKill(enabled)
    MainModule.VoidKillFeature.Enabled = enabled
    
    if MainModule.VoidKillFeature.AnimationConnection then
        MainModule.VoidKillFeature.AnimationConnection:Disconnect()
        MainModule.VoidKillFeature.AnimationConnection = nil
    end
    if MainModule.VoidKillFeature.CharacterAddedConnection then
        MainModule.VoidKillFeature.CharacterAddedConnection:Disconnect()
        MainModule.VoidKillFeature.CharacterAddedConnection = nil
    end
    if MainModule.VoidKillFeature.AnimationCheckConnection then
        MainModule.VoidKillFeature.AnimationCheckConnection:Disconnect()
        MainModule.VoidKillFeature.AnimationCheckConnection = nil
    end
    
    for _, conn in ipairs(MainModule.VoidKillFeature.AnimationStoppedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.VoidKillFeature.AnimationStoppedConnections = {}
    
    MainModule.VoidKillFeature.SavedCFrame = nil
    MainModule.VoidKillFeature.ActiveAnimation = false
    MainModule.VoidKillFeature.AnimationStartTime = 0
    MainModule.VoidKillFeature.TrackedAnimations = {}
    
    if not enabled then
        if MainModule.VoidKillFeature.AntiFallPlatform then
            MainModule.VoidKillFeature.AntiFallPlatform:Destroy()
            MainModule.VoidKillFeature.AntiFallPlatform = nil
        end
        MainModule.VoidKillFeature.AntiFallEnabled = false
        return
    end
    
    local function checkAnimations()
        if not MainModule.VoidKillFeature.Enabled then return end
        
        local character = GetCharacter()
        if not character then return end
        local humanoid = GetHumanoid(character)
        if not humanoid then return end
        
        local activeTracks = humanoid:GetPlayingAnimationTracks()
        for _, track in pairs(activeTracks) do
            if track and track.Animation then
                local animId = track.Animation.AnimationId
                
                if MainModule.VoidKillFeature.AnimationIdsSet[animId] then
                    local trackKey = animId .. "_" .. tostring(track)
                    if not MainModule.VoidKillFeature.TrackedAnimations[trackKey] then
                        MainModule.VoidKillFeature.TrackedAnimations[trackKey] = true
                        
                        if not MainModule.VoidKillFeature.ActiveAnimation then
                            MainModule.VoidKillFeature.ActiveAnimation = true
                            MainModule.VoidKillFeature.AnimationStartTime = tick()
                            
                            MainModule.VoidKillFeature.SavedCFrame = character:GetPrimaryPartCFrame()
                            
                            local platformPosition = MainModule.VoidKillFeature.ZonePosition + 
                                                    Vector3.new(0, MainModule.VoidKillFeature.PlatformYOffset, 0)
                            
                            MainModule.VoidKillFeature.AntiFallPlatform = Instance.new("Part")
                            MainModule.VoidKillFeature.AntiFallPlatform.Name = "VoidKillAntiFall"
                            MainModule.VoidKillFeature.AntiFallPlatform.Size = MainModule.VoidKillFeature.PlatformSize
                            MainModule.VoidKillFeature.AntiFallPlatform.Anchored = true
                            MainModule.VoidKillFeature.AntiFallPlatform.CanCollide = true
                            MainModule.VoidKillFeature.AntiFallPlatform.Transparency = 1
                            MainModule.VoidKillFeature.AntiFallPlatform.Material = Enum.Material.Plastic
                            MainModule.VoidKillFeature.AntiFallPlatform.CastShadow = false
                            MainModule.VoidKillFeature.AntiFallPlatform.CanQuery = false
                            MainModule.VoidKillFeature.AntiFallPlatform.Position = platformPosition
                            MainModule.VoidKillFeature.AntiFallPlatform.Parent = workspace
                            
                            character:SetPrimaryPartCFrame(CFrame.new(MainModule.VoidKillFeature.ZonePosition))
                            
                            local stoppedConn = track.Stopped:Connect(function()
                                task.wait(MainModule.VoidKillFeature.ReturnDelay)
                                
                                if MainModule.VoidKillFeature.SavedCFrame then
                                    character:SetPrimaryPartCFrame(MainModule.VoidKillFeature.SavedCFrame)
                                    MainModule.VoidKillFeature.SavedCFrame = nil
                                end
                                
                                MainModule.VoidKillFeature.ActiveAnimation = false
                                MainModule.VoidKillFeature.TrackedAnimations = {}
                                
                                if MainModule.VoidKillFeature.AntiFallPlatform then
                                    MainModule.VoidKillFeature.AntiFallPlatform:Destroy()
                                    MainModule.VoidKillFeature.AntiFallPlatform = nil
                                end
                            end)
                            
                            table.insert(MainModule.VoidKillFeature.AnimationStoppedConnections, stoppedConn)
                        end
                    end
                end
            end
        end
    end
    
    local function setupCharacter(char)
        local humanoid = char:WaitForChild("Humanoid", 5)
        if not humanoid then return end
        
        MainModule.VoidKillFeature.AnimationConnection = humanoid.AnimationPlayed:Connect(function(track)
            if not MainModule.VoidKillFeature.Enabled then return end
            
            if track and track.Animation then
                local animId = track.Animation.AnimationId
                
                if MainModule.VoidKillFeature.AnimationIdsSet[animId] then
                    local trackKey = animId .. "_" .. tostring(track)
                    MainModule.VoidKillFeature.TrackedAnimations[trackKey] = true
                    
                    if not MainModule.VoidKillFeature.ActiveAnimation then
                        MainModule.VoidKillFeature.ActiveAnimation = true
                        MainModule.VoidKillFeature.AnimationStartTime = tick()
                        
                        MainModule.VoidKillFeature.SavedCFrame = char:GetPrimaryPartCFrame()
                        
                        local platformPosition = MainModule.VoidKillFeature.ZonePosition + 
                                                Vector3.new(0, MainModule.VoidKillFeature.PlatformYOffset, 0)
                        
                        MainModule.VoidKillFeature.AntiFallPlatform = Instance.new("Part")
                        MainModule.VoidKillFeature.AntiFallPlatform.Name = "VoidKillAntiFall"
                        MainModule.VoidKillFeature.AntiFallPlatform.Size = MainModule.VoidKillFeature.PlatformSize
                        MainModule.VoidKillFeature.AntiFallPlatform.Anchored = true
                        MainModule.VoidKillFeature.AntiFallPlatform.CanCollide = true
                        MainModule.VoidKillFeature.AntiFallPlatform.Transparency = 1
                        MainModule.VoidKillFeature.AntiFallPlatform.Material = Enum.Material.Plastic
                        MainModule.VoidKillFeature.AntiFallPlatform.CastShadow = false
                        MainModule.VoidKillFeature.AntiFallPlatform.CanQuery = false
                        MainModule.VoidKillFeature.AntiFallPlatform.Position = platformPosition
                        MainModule.VoidKillFeature.AntiFallPlatform.Parent = workspace
                        
                        char:SetPrimaryPartCFrame(CFrame.new(MainModule.VoidKillFeature.ZonePosition))
                        
                        local stoppedConn = track.Stopped:Connect(function()
                            task.wait(MainModule.VoidKillFeature.ReturnDelay)
                            
                            if MainModule.VoidKillFeature.SavedCFrame then
                                char:SetPrimaryPartCFrame(MainModule.VoidKillFeature.SavedCFrame)
                                MainModule.VoidKillFeature.SavedCFrame = nil
                            end
                            
                            MainModule.VoidKillFeature.ActiveAnimation = false
                            MainModule.VoidKillFeature.TrackedAnimations = {}
                            
                            if MainModule.VoidKillFeature.AntiFallPlatform then
                                MainModule.VoidKillFeature.AntiFallPlatform:Destroy()
                                MainModule.VoidKillFeature.AntiFallPlatform = nil
                            end
                        end)
                        
                        table.insert(MainModule.VoidKillFeature.AnimationStoppedConnections, stoppedConn)
                    end
                end
            end
        end)
    end
    
    local char = LocalPlayer.Character
    if char then
        task.spawn(setupCharacter, char)
    end
    
    MainModule.VoidKillFeature.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        if MainModule.VoidKillFeature.Enabled then
            task.spawn(setupCharacter, newChar)
        end
    end)
    
    MainModule.VoidKillFeature.AnimationCheckConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.VoidKillFeature.Enabled then return end
        checkAnimations()
    end)
end

function MainModule.ToggleZoneKill(enabled)
    MainModule.ZoneKillFeature.Enabled = enabled
    
    -- Отключаем существующие соединения
    if MainModule.ZoneKillFeature.AnimationConnection then
        MainModule.ZoneKillFeature.AnimationConnection:Disconnect()
        MainModule.ZoneKillFeature.AnimationConnection = nil
    end
    if MainModule.ZoneKillFeature.CharacterAddedConnection then
        MainModule.ZoneKillFeature.CharacterAddedConnection:Disconnect()
        MainModule.ZoneKillFeature.CharacterAddedConnection = nil
    end
    if MainModule.ZoneKillFeature.AnimationCheckConnection then
        MainModule.ZoneKillFeature.AnimationCheckConnection:Disconnect()
        MainModule.ZoneKillFeature.AnimationCheckConnection = nil
    end
    if MainModule.ZoneKillFeature.ZoneCheckConnection then
        MainModule.ZoneKillFeature.ZoneCheckConnection:Disconnect()
        MainModule.ZoneKillFeature.ZoneCheckConnection = nil
    end
    
    -- Очищаем список соединений анимаций
    for _, conn in ipairs(MainModule.ZoneKillFeature.AnimationStoppedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.ZoneKillFeature.AnimationStoppedConnections = {}
    
    -- Сбрасываем состояние
    MainModule.ZoneKillFeature.SavedCFrame = nil
    MainModule.ZoneKillFeature.ActiveAnimation = false
    MainModule.ZoneKillFeature.AnimationStartTime = 0
    MainModule.ZoneKillFeature.TrackedAnimations = {}
    MainModule.ZoneKillFeature.LastAnimationCheckTime = 0
    
    if not enabled then return end
    
    -- Функция для проверки анимаций Zone Kill (от нашего персонажа)
    local function checkAnimations()
        if not MainModule.ZoneKillFeature.Enabled then return end
        
        local character = GetCharacter()
        if not character then return end
        local humanoid = GetHumanoid(character)
        if not humanoid then return end
        
        local currentTime = tick()
        if currentTime - MainModule.ZoneKillFeature.LastAnimationCheckTime < 0.05 then
            return
        end
        MainModule.ZoneKillFeature.LastAnimationCheckTime = currentTime
        
        -- Проверяем текущие анимации нашего персонажа
        local activeTracks = humanoid:GetPlayingAnimationTracks()
        
        for _, track in pairs(activeTracks) do
            if track and track.Animation and track.Animation.AnimationId == MainModule.ZoneKillFeature.AnimationId then
                -- Проверяем, не отслеживаем ли мы уже эту анимацию
                local trackKey = tostring(track)
                if not MainModule.ZoneKillFeature.TrackedAnimations[trackKey] then
                    MainModule.ZoneKillFeature.TrackedAnimations[trackKey] = true
                    
                    -- Если анимация активна, но мы еще не начали обработку
                    if not MainModule.ZoneKillFeature.ActiveAnimation then
                        MainModule.ZoneKillFeature.ActiveAnimation = true
                        MainModule.ZoneKillFeature.AnimationStartTime = tick()
                        
                        -- Сохраняем текущую позицию для возврата
                        MainModule.ZoneKillFeature.SavedCFrame = character:GetPrimaryPartCFrame()
                        
                        -- Телепортируем на указанные координаты
                        character:SetPrimaryPartCFrame(CFrame.new(MainModule.ZoneKillFeature.ZonePosition))
                        
                        -- Отслеживаем окончание анимации
                        local stoppedConn = track.Stopped:Connect(function()
                            task.wait(MainModule.ZoneKillFeature.ReturnDelay)
                            
                            -- Возвращаем на сохраненную позицию
                            if MainModule.ZoneKillFeature.SavedCFrame then
                                character:SetPrimaryPartCFrame(MainModule.ZoneKillFeature.SavedCFrame)
                                MainModule.ZoneKillFeature.SavedCFrame = nil
                            end
                            
                            -- Очищаем состояние
                            MainModule.ZoneKillFeature.ActiveAnimation = false
                            MainModule.ZoneKillFeature.TrackedAnimations = {}
                        end)
                        
                        -- Добавляем соединение в список
                        table.insert(MainModule.ZoneKillFeature.AnimationStoppedConnections, stoppedConn)
                    end
                end
            end
        end
    end
    
    -- Функция для настройки обработки анимаций нашего персонажа
    local function setupCharacter(char)
        local humanoid = char:WaitForChild("Humanoid", 5)
        if not humanoid then return end
        
        -- Подключаемся к событию проигрывания анимации нашего персонажа
        MainModule.ZoneKillFeature.AnimationConnection = humanoid.AnimationPlayed:Connect(function(track)
            if not MainModule.ZoneKillFeature.Enabled then return end
            
            if track and track.Animation and track.Animation.AnimationId == MainModule.ZoneKillFeature.AnimationId then
                -- Отмечаем анимацию как отслеживаемую
                local trackKey = tostring(track)
                MainModule.ZoneKillFeature.TrackedAnimations[trackKey] = true
                
                -- Если анимация активна, но мы еще не начали обработку
                if not MainModule.ZoneKillFeature.ActiveAnimation then
                    MainModule.ZoneKillFeature.ActiveAnimation = true
                    MainModule.ZoneKillFeature.AnimationStartTime = tick()
                    
                    -- Сохраняем текущую позицию для возврата
                    MainModule.ZoneKillFeature.SavedCFrame = char:GetPrimaryPartCFrame()
                    
                    -- Телепортируем на указанные координаты
                    char:SetPrimaryPartCFrame(CFrame.new(MainModule.ZoneKillFeature.ZonePosition))
                    
                    -- Отслеживаем окончание анимации
                    local stoppedConn = track.Stopped:Connect(function()
                        task.wait(MainModule.ZoneKillFeature.ReturnDelay)
                        
                        -- Возвращаем на сохраненную позицию
                        if MainModule.ZoneKillFeature.SavedCFrame then
                            char:SetPrimaryPartCFrame(MainModule.ZoneKillFeature.SavedCFrame)
                            MainModule.ZoneKillFeature.SavedCFrame = nil
                        end
                        
                        -- Очищаем состояние
                        MainModule.ZoneKillFeature.ActiveAnimation = false
                        MainModule.ZoneKillFeature.TrackedAnimations = {}
                    end)
                    
                    -- Добавляем соединение в список
                    table.insert(MainModule.ZoneKillFeature.AnimationStoppedConnections, stoppedConn)
                end
            end
        end)
    end
    
    -- Настраиваем текущий персонаж
    local char = LocalPlayer.Character
    if char then
        task.spawn(setupCharacter, char)
    end
    
    -- Настраиваем обработку для нового персонажа
    MainModule.ZoneKillFeature.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(1) -- Даем время на загрузку персонажа
        if MainModule.ZoneKillFeature.Enabled then
            task.spawn(setupCharacter, newChar)
        end
    end)
    
    -- Запускаем проверку анимаций
    MainModule.ZoneKillFeature.AnimationCheckConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.ZoneKillFeature.Enabled then return end
        checkAnimations()
    end)
    
    -- Также запускаем дополнительную проверку в RenderStepped для более быстрого реагирования
    MainModule.ZoneKillFeature.ZoneCheckConnection = RunService.RenderStepped:Connect(function()
        if not MainModule.ZoneKillFeature.Enabled then return end
        checkAnimations()
    end)
end

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
    local GlassHolder = Workspace:WaitForChild("GlassBridge"):WaitForChild("GlassHolder")
    
    for _, tilePair in pairs(GlassHolder:GetChildren()) do
        for _, tileModel in pairs(tilePair:GetChildren()) do
            if tileModel:IsA("Model") and tileModel.PrimaryPart then
                local primaryPart = tileModel.PrimaryPart
                
                for _, child in ipairs(tileModel:GetChildren()) do
                    if child:IsA("Highlight") then
                        child:Destroy()
                    end
                end
                
                local Color = primaryPart:GetAttribute("exploitingisevil") 
                    and Color3.fromRGB(248, 87, 87)
                    or Color3.fromRGB(28, 235, 87)
                
                primaryPart.Color = Color
                primaryPart.Transparency = 0
                primaryPart.Material = Enum.Material.Neon
                
                for _, part in pairs(tileModel:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Color = Color
                        part.Transparency = 0
                        part.Material = Enum.Material.Neon
                    end
                end
            end
        end
    end
    
    local Effects = ReplicatedStorage:FindFirstChild("Modules") and 
                   ReplicatedStorage.Modules:FindFirstChild("Effects")
    if Effects then
        local success, result = pcall(function()
            return require(Effects)
        end)
        if success and result and result.AnnouncementTween then
            result.AnnouncementTween({
                AnnouncementOneLine = true,
                FasterTween = true,
                DisplayTime = 10,
                AnnouncementDisplayText = "[CreonHub]: Glass ESP Activated! Red = Breakable, Green = Safe"
            })
        end
    end
end

function MainModule.TeleportToGlassBridgeEnd()
    SafeTeleport(MainModule.GlassBridge.EndPosition)
end

function MainModule.ToggleHNSInfinityStamina(enabled)
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

function MainModule.ToggleNoclip(enabled)
    MainModule.Noclip.Enabled = enabled
    
    if MainModule.Noclip.Connection then
        MainModule.Noclip.Connection:Disconnect()
        MainModule.Noclip.Connection = nil
    end
    
    for part in pairs(MainModule.Noclip.AffectedParts) do
        if part and part.Parent then
            part.CanCollide = true
        end
    end
    MainModule.Noclip.AffectedParts = {}
    
    if not enabled then return end
    
    local actualRadius = math.min(MainModule.Noclip.CheckDistance, 10)
    
    MainModule.Noclip.Connection = RunService.Heartbeat:Connect(function()
        if not MainModule.Noclip.Enabled then return end
        
        local character = GetCharacter()
        if not character then return end
        
        local rootPart = GetRootPart(character)
        if not rootPart then return end
        
        local pos = rootPart.Position
        
        local region = Region3.new(
            pos - Vector3.new(actualRadius, 3, actualRadius),
            pos + Vector3.new(actualRadius, 5, actualRadius)
        )
        
        local parts = workspace:FindPartsInRegion3(region, character, 100)
        
        for i = 1, #parts do
            local part = parts[i]
            
            if part.Position.Y > pos.Y - 2 then
                if not MainModule.Noclip.AffectedParts[part] then
                    MainModule.Noclip.AffectedParts[part] = true
                    part.CanCollide = false
                end
            end
        end
    end)
end

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
    
    -- Получение игрока
    local player = nil
    if game:GetService("Players").LocalPlayer then
        player = game:GetService("Players").LocalPlayer
    elseif game.Players and game.Players.LocalPlayer then
        player = game.Players.LocalPlayer
    else
        return false
    end
    
    -- Поиск RemoteEvent
    local remote = nil
    local remoteContainer = game:GetService("ReplicatedStorage")
    
    if remoteContainer:FindFirstChild("Remotes") then
        local remotesFolder = remoteContainer:FindFirstChild("Remotes")
        if remotesFolder:FindFirstChild("UsedTool") then
            remote = remotesFolder:FindFirstChild("UsedTool")
        end
    end
    
    if not remote then 
        return false
    end
    
    -- Поиск инструмента DODGE!
    local tool = nil
    
    -- Сначала проверяем Character
    if player.Character then
        tool = player.Character:FindFirstChild("DODGE!")
        if tool then
            -- Инструмент найден в Character
        end
    end
    
    -- Если не нашли, проверяем Backpack
    if not tool and player:FindFirstChild("Backpack") then
        local backpack = player:FindFirstChild("Backpack")
        tool = backpack:FindFirstChild("DODGE!")
    end
    
    if not tool then 
        return false 
    end
    
    -- ТОЛЬКО 2-й способ вызова: UsingMoveCustom без имени (как в примере с Push)
    local success = pcall(function() 
        remote:FireServer("UsingMoveCustom", tool, nil, {Clicked = true}) 
    end)
    
    if success then
        autoDodge.LastDodgeTime = currentTime
        return true
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

function MainModule.ToggleAutoDodge(enabled)
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
        
        for _, player in pairs(Players:GetPlayers()) do
            task.spawn(setupFastPlayerTracking, player)
        end
        
        local playerAddedConn = Players.PlayerAdded:Connect(function(player)
            if MainModule.AutoDodge.Enabled then
                task.spawn(setupFastPlayerTracking, player)
            end
        end)
        table.insert(MainModule.AutoDodge.Connections, playerAddedConn)
        
        local heartbeatConn = RunService.Heartbeat:Connect(function()
            if not MainModule.AutoDodge.Enabled then return end
            
            local currentTime = tick()
            if currentTime - MainModule.AutoDodge.LastRangeUpdate > MainModule.AutoDodge.RangeUpdateInterval then
                fastUpdatePlayersInRange()
                MainModule.AutoDodge.LastRangeUpdate = currentTime
            end
        end)
        table.insert(MainModule.AutoDodge.Connections, heartbeatConn)
        
        task.spawn(fastUpdatePlayersInRange)
    end
end

Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        MainModule.ToggleAutoDodge(false)
    end
end)

function MainModule.GetHider()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if not plr.Character then continue end
        if not IsHider(plr) then continue end
        if plr.Character ~= nil and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            return plr.Character
        else
            continue
        end
    end
    return nil
end

function MainModule.TeleportToHider()
    if not LocalPlayer.Character then return end
    
    local hider = MainModule.GetHider()
    if not hider then
        return false
    end
    
    LocalPlayer.Character:PivotTo(hider:GetPrimaryPartCFrame())
    return true
end

-- Fly функция с улучшенной защитой и исправленным движением
function MainModule.ToggleFly(enabled)
    if enabled then
        MainModule.EnableFlight()
    else
        MainModule.DisableFlight()
    end
end

function MainModule.EnableFlight()
    if MainModule.Fly.Enabled then return end
    
    -- Сохраняем состояние AntiRagdoll
    MainModule.Fly.WasRagdollEnabled = MainModule.Misc.BypassRagdollEnabled
    
    -- Если AntiRagdoll включен, выключаем его временно
    if MainModule.Misc.BypassRagdollEnabled then
        MainModule.ToggleBypassRagdoll(false)
    end
    
    MainModule.Fly.Enabled = true
    
    if MainModule.Fly.Connection then
        MainModule.Fly.Connection:Disconnect()
        MainModule.Fly.Connection = nil
    end
    
    if MainModule.Fly.SpeedChangeConnection then
        MainModule.Fly.SpeedChangeConnection:Disconnect()
        MainModule.Fly.SpeedChangeConnection = nil
    end
    
    local character = GetCharacter()
    if not character then return end
    
    local humanoid = GetHumanoid(character)
    local rootPart = GetRootPart(character)
    if not (humanoid and rootPart) then return end
    
    -- Сохраняем оригинальное состояние для античита
    MainModule.Fly.OriginalStates = {
        WalkSpeed = humanoid.WalkSpeed,
        JumpPower = humanoid.JumpPower,
        PlatformStand = false
    }
    
    -- Создаем скрытые части для обмана античита
    MainModule.Fly.FakeParts = {}
    local function createFakePart(position)
        local part = Instance.new("Part")
        part.Name = "FakeFloor"
        part.Size = Vector3.new(4, 1, 4)
        part.Transparency = 1
        part.Anchored = true
        part.CanCollide = false
        part.Position = position - Vector3.new(0, 3, 0)
        part.Parent = workspace
        table.insert(MainModule.Fly.FakeParts, part)
        return part
    end
    
    MainModule.Fly.LastUpdate = tick()
    MainModule.Fly.LastPosition = rootPart.Position
    
    MainModule.Fly.Connection = RunService.Heartbeat:Connect(function()
        if not MainModule.Fly.Enabled or not character or not character.Parent then 
            if MainModule.Fly.Connection then
                MainModule.Fly.Connection:Disconnect()
                MainModule.Fly.Connection = nil
            end
            return 
        end
        
        rootPart = GetRootPart(character)
        if not rootPart then return end
        
        local Camera = workspace.CurrentCamera
        if not Camera then return end
        
        -- Улучшенное управление движением (без плавания)
        local moveDirection = Vector3.new(0, 0, 0)
        local isMoving = false
        local speedMultiplier = 1.0
        
        -- Движение вперед/назад
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + Camera.CFrame.LookVector
            isMoving = true
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - Camera.CFrame.LookVector
            isMoving = true
        end
        
        -- Движение влево/вправо
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - Camera.CFrame.RightVector
            isMoving = true
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + Camera.CFrame.RightVector
            isMoving = true
        end
        
        -- Движение вверх/вниз
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
            isMoving = true
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.C) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
            isMoving = true
        end
        
        -- Нормализуем направление и применяем скорость 50
        if isMoving then
            if moveDirection.Magnitude > 0 then
                moveDirection = moveDirection.Unit
            end
            
            -- Прямое движение без "плавания"
            local targetVelocity = moveDirection * 50 -- Исправленная скорость 50
            
            -- Плавное применение скорости
            local currentVelocity = rootPart.Velocity
            local newVelocity = Vector3.new(
                (currentVelocity.X * 0.3 + targetVelocity.X * 0.7),
                (currentVelocity.Y * 0.3 + targetVelocity.Y * 0.7),
                (currentVelocity.Z * 0.3 + targetVelocity.Z * 0.7)
            )
            
            -- Используем BodyVelocity для более контролируемого движения
            local bv = rootPart:FindFirstChild("FlightBV")
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.Name = "FlightBV"
                bv.MaxForce = Vector3.new(4000, 4000, 4000)
                bv.P = 1250
                bv.Velocity = Vector3.new(0, 0, 0)
                bv.Parent = rootPart
            end
            
            bv.Velocity = newVelocity
            
            -- Античит защита: обнуляем реальную velocity rootPart
            rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            
        else
            -- Если не двигаемся, останавливаемся плавно
            local bv = rootPart:FindFirstChild("FlightBV")
            if bv then
                local currentVelocity = rootPart.Velocity
                local deceleratedVelocity = Vector3.new(
                    currentVelocity.X * 0.8,
                    currentVelocity.Y * 0.8,
                    currentVelocity.Z * 0.8
                )
                
                bv.Velocity = deceleratedVelocity
                rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end
        
        -- Античит защита: обманываем проверки
        local currentTime = tick()
        if currentTime - MainModule.Fly.LastUpdate > 0.1 then
            MainModule.Fly.LastUpdate = currentTime
            
            -- Обновляем fake floor под нами
            for _, part in ipairs(MainModule.Fly.FakeParts) do
                part:Destroy()
            end
            MainModule.Fly.FakeParts = {}
            
            -- Создаем невидимый пол под нами
            createFakePart(rootPart.Position)
            
            -- Обманываем физику: устанавливаем небольшое смещение вместо полета
            local delta = rootPart.Position - MainModule.Fly.LastPosition
            if delta.Magnitude < 10 then  -- Ограничиваем скорость для античита
                rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.new(0, 0.1, 0)
            end
            
            MainModule.Fly.LastPosition = rootPart.Position
            
            -- Обманываем гуманода
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
                humanoid.PlatformStand = false
                humanoid.WalkSpeed = MainModule.Fly.OriginalStates.WalkSpeed
                humanoid.JumpPower = MainModule.Fly.OriginalStates.JumpPower
                
                -- Скрываем эффекты полета
                for _, child in ipairs(character:GetChildren()) do
                    if child:IsA("BodyVelocity") and child ~= rootPart:FindFirstChild("FlightBV") then
                        child:Destroy()
                    end
                end
            end
        end
    end)
    
    -- Античит: периодически имитируем приземление
    MainModule.Fly.SpeedChangeConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.Fly.Enabled then return end
        
        local rootPart = GetRootPart(character)
        if not rootPart then return end
        
        -- Имитация приземления каждые 2 секунды
        local currentTime = tick()
        if currentTime - MainModule.Fly.LastGroundCheck > 2 then
            MainModule.Fly.LastGroundCheck = currentTime
            
            -- Создаем невидимый пол
            local fakeGround = Instance.new("Part")
            fakeGround.Name = "FlyGround"
            fakeGround.Size = Vector3.new(10, 1, 10)
            fakeGround.Transparency = 1
            fakeGround.Anchored = true
            fakeGround.CanCollide = true
            fakeGround.Position = rootPart.Position - Vector3.new(0, 3, 0)
            fakeGround.Parent = workspace
            
            task.delay(0.5, function()
                if fakeGround and fakeGround.Parent then
                    fakeGround:Destroy()
                end
            end)
        end
    end)
    
    if MainModule.Fly.HumanoidDiedConnection then
        MainModule.Fly.HumanoidDiedConnection:Disconnect()
    end
    MainModule.Fly.HumanoidDiedConnection = humanoid.Died:Connect(function()
        MainModule.DisableFlight()
    end)
    
    if MainModule.Fly.CharacterAddedConnection then
        MainModule.Fly.CharacterAddedConnection:Disconnect()
    end
    MainModule.Fly.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        task.wait(1)
        
        if MainModule.Fly.Enabled then
            task.wait(0.5)
            MainModule.DisableFlight()
            task.wait(0.1)
            MainModule.EnableFlight()
        end
    end)
    
    MainModule.Fly.LastGroundCheck = tick()
end

function MainModule.DisableFlight()
    if not MainModule.Fly.Enabled then return end
    
    MainModule.Fly.Enabled = false
    
    if MainModule.Fly.Connection then
        MainModule.Fly.Connection:Disconnect()
        MainModule.Fly.Connection = nil
    end
    
    if MainModule.Fly.SpeedChangeConnection then
        MainModule.Fly.SpeedChangeConnection:Disconnect()
        MainModule.Fly.SpeedChangeConnection = nil
    end
    
    if MainModule.Fly.HumanoidDiedConnection then
        MainModule.Fly.HumanoidDiedConnection:Disconnect()
        MainModule.Fly.HumanoidDiedConnection = nil
    end
    
    if MainModule.Fly.CharacterAddedConnection then
        MainModule.Fly.CharacterAddedConnection:Disconnect()
        MainModule.Fly.CharacterAddedConnection = nil
    end
    
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            local bv = rootPart:FindFirstChild("FlightBV")
            if bv then
                bv:Destroy()
            end
            
            -- Удаляем AssemblyLinearVelocity
            rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
        
        local humanoid = GetHumanoid(character)
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
    
    -- Удаляем fake parts
    if MainModule.Fly.FakeParts then
        for _, part in ipairs(MainModule.Fly.FakeParts) do
            if part and part.Parent then
                part:Destroy()
            end
        end
        MainModule.Fly.FakeParts = {}
    end
    
    -- Восстанавливаем оригинальные состояния
    if MainModule.Fly.OriginalStates and character then
        local humanoid = GetHumanoid(character)
        if humanoid then
            humanoid.WalkSpeed = MainModule.Fly.OriginalStates.WalkSpeed
            humanoid.JumpPower = MainModule.Fly.OriginalStates.JumpPower
        end
    end
    MainModule.Fly.OriginalStates = nil
    
    -- Восстанавливаем состояние AntiRagdoll если он был включен
    if MainModule.Fly.WasRagdollEnabled then
        MainModule.ToggleBypassRagdoll(true)
        MainModule.Fly.WasRagdollEnabled = false
    end
end

function MainModule.SetFlySpeed(speed)
    -- Для совместимости оставляем, но используем фиксированную скорость 50
    return 50
end

function MainModule.Cleanup()
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
    
    MainModule.ClearESP()
    
    if MainModule.RLGL.Connection then
        MainModule.RLGL.Connection:Disconnect()
        MainModule.RLGL.Connection = nil
    end
    
    if MainModule.RLGL.PocketSandCheck then
        MainModule.RLGL.PocketSandCheck:Disconnect()
        MainModule.RLGL.PocketSandCheck = nil
    end
    
    if MainModule.Rebel.Connection then
        MainModule.Rebel.Connection:Disconnect()
        MainModule.Rebel.Connection = nil
    end
    
    if MainModule.HNS.InfinityStaminaConnection then
        MainModule.HNS.InfinityStaminaConnection:Disconnect()
        MainModule.HNS.InfinityStaminaConnection = nil
    end
    
    if MainModule.SpikesKillFeature.AnimationConnection then
        MainModule.SpikesKillFeature.AnimationConnection:Disconnect()
        MainModule.SpikesKillFeature.AnimationConnection = nil
    end
    
    if MainModule.SpikesKillFeature.CharacterAddedConnection then
        MainModule.SpikesKillFeature.CharacterAddedConnection:Disconnect()
        MainModule.SpikesKillFeature.CharacterAddedConnection = nil
    end
    
    if MainModule.SpikesKillFeature.SafetyCheckConnection then
        MainModule.SpikesKillFeature.SafetyCheckConnection:Disconnect()
        MainModule.SpikesKillFeature.SafetyCheckConnection = nil
    end
    
    if MainModule.SpikesKillFeature.AnimationCheckConnection then
        MainModule.SpikesKillFeature.AnimationCheckConnection:Disconnect()
        MainModule.SpikesKillFeature.AnimationCheckConnection = nil
    end
    
    if MainModule.SpikesKillFeature.KnifeCheckConnection then
        MainModule.SpikesKillFeature.KnifeCheckConnection:Disconnect()
        MainModule.SpikesKillFeature.KnifeCheckConnection = nil
    end
    
    for _, conn in ipairs(MainModule.SpikesKillFeature.AnimationStoppedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.SpikesKillFeature.AnimationStoppedConnections = {}
    
    if MainModule.VoidKillFeature.AnimationConnection then
        MainModule.VoidKillFeature.AnimationConnection:Disconnect()
        MainModule.VoidKillFeature.AnimationConnection = nil
    end
    
    if MainModule.VoidKillFeature.CharacterAddedConnection then
        MainModule.VoidKillFeature.CharacterAddedConnection:Disconnect()
        MainModule.VoidKillFeature.CharacterAddedConnection = nil
    end
    
    if MainModule.VoidKillFeature.AnimationCheckConnection then
        MainModule.VoidKillFeature.AnimationCheckConnection:Disconnect()
        MainModule.VoidKillFeature.AnimationCheckConnection = nil
    end
    
    for _, conn in ipairs(MainModule.VoidKillFeature.AnimationStoppedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.VoidKillFeature.AnimationStoppedConnections = {}
    
    if MainModule.ZoneKillFeature.AnimationConnection then
        MainModule.ZoneKillFeature.AnimationConnection:Disconnect()
        MainModule.ZoneKillFeature.AnimationConnection = nil
    end
    
    if MainModule.ZoneKillFeature.CharacterAddedConnection then
        MainModule.ZoneKillFeature.CharacterAddedConnection:Disconnect()
        MainModule.ZoneKillFeature.CharacterAddedConnection = nil
    end
    
    if MainModule.ZoneKillFeature.AnimationCheckConnection then
        MainModule.ZoneKillFeature.AnimationCheckConnection:Disconnect()
        MainModule.ZoneKillFeature.AnimationCheckConnection = nil
    end
    
    if MainModule.ZoneKillFeature.ZoneCheckConnection then
        MainModule.ZoneKillFeature.ZoneCheckConnection:Disconnect()
        MainModule.ZoneKillFeature.ZoneCheckConnection = nil
    end
    
    for _, conn in ipairs(MainModule.ZoneKillFeature.AnimationStoppedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.ZoneKillFeature.AnimationStoppedConnections = {}
    
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
    
    if globalAnimationHandler then
        globalAnimationHandler:Disconnect()
        globalAnimationHandler = nil
    end
    
    MainModule.DisableFlight()
    
    MainModule.Fly.Enabled = false
    MainModule.Fly.Speed = 39
    MainModule.Fly.Connection = nil
    MainModule.Fly.BodyVelocity = nil
    MainModule.Fly.HumanoidDiedConnection = nil
    MainModule.Fly.CharacterAddedConnection = nil
    MainModule.Fly.SpeedChangeConnection = nil
    
    if MainModule.Noclip.Connection then
        MainModule.Noclip.Connection:Disconnect()
        MainModule.Noclip.Connection = nil
    end
    
    MainModule.StopEnhancedProtection()
    MainModule.StopJointCleaning()
    
    for part, properties in pairs(MainModule.Noclip.OriginalTransparency) do
        if part and part.Parent then
            pcall(function()
                part.Transparency = properties.Transparency
                part.CanCollide = properties.CanCollide
            end)
        end
    end
    MainModule.Noclip.OriginalTransparency = {}
    MainModule.Noclip.AffectedParts = {}
    
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
    
    if MainModule.VoidKillFeature.AntiFallEnabled then
        MainModule.RemoveSkySquidAntiFall()
        MainModule.VoidKillFeature.AntiFallEnabled = false
    end
    
    if MainModule.SpeedHack.Enabled then
        MainModule.ToggleSpeedHack(false)
    end
    
    if MainModule.Noclip.Enabled then
        MainModule.ToggleNoclip(false)
    end
    
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
    MainModule.SpikesKillFeature.Enabled = false
    MainModule.SpikesKillFeature.TrackedAnimations = {}
    MainModule.SpikesKillFeature.SpikesRemoved = false
    MainModule.SpikesKillFeature.OriginalSpikes = {}
    MainModule.SpikesKillFeature.SpikesPosition = nil
    MainModule.SpikesKillFeature.HasKnife = false
    MainModule.VoidKillFeature.Enabled = false
    MainModule.VoidKillFeature.TrackedAnimations = {}
    MainModule.ZoneKillFeature.Enabled = false
    MainModule.ZoneKillFeature.TrackedAnimations = {}
    MainModule.FreeDash.Enabled = false
    MainModule.FreeDashGuards.Enabled = false
end

LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not LocalPlayer.Parent then
        MainModule.Cleanup()
    end
end)

return MainModule











