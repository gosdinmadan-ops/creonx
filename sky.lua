local SkySquidModule = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

SkySquidModule.AntiFallEnabled = false
SkySquidModule.VoidKillEnabled = false
SkySquidModule.AutoQTEEnabled = false
SkySquidModule.SafePlatform = nil

local skySquidAntiFallConnection = nil
local voidKillConnection = nil
local autoQTEConnection = nil

local function findNearestAlivePlayer()
    local character = LocalPlayer.Character
    if not character then return nil end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    
    local nearestPlayer = nil
    local nearestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local targetHumanoid = player.Character:FindFirstChild("Humanoid")
            
            if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                local distance = (rootPart.Position - targetRoot.Position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestPlayer = player
                end
            end
        end
    end
    
    return nearestPlayer
end

local function delay(seconds, callback)
    task.spawn(function()
        task.wait(seconds)
        callback()
    end)
end

function SkySquidModule.ToggleAntiFall(enabled)
    SkySquidModule.AntiFallEnabled = enabled
    
    if skySquidAntiFallConnection then
        skySquidAntiFallConnection:Disconnect()
        skySquidAntiFallConnection = nil
    end
    
    if enabled then
        skySquidAntiFallConnection = RunService.Heartbeat:Connect(function()
            if not SkySquidModule.AntiFallEnabled then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChild("Humanoid")
                
                if not rootPart or not humanoid or humanoid.Health <= 0 then return end
                
                if rootPart.Position.Y < 50 then
                    local targetPlayer = findNearestAlivePlayer()
                    if targetPlayer and targetPlayer.Character then
                        local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if targetRoot then
                            rootPart.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
                            
                            task.spawn(function()
                                local flash = Instance.new("Part")
                                flash.Size = Vector3.new(8, 0.2, 8)
                                flash.Position = rootPart.Position - Vector3.new(0, 3, 0)
                                flash.BrickColor = BrickColor.new("Bright blue")
                                flash.Material = Enum.Material.Neon
                                flash.Anchored = true
                                flash.CanCollide = false
                                flash.Transparency = 0.5
                                flash.Parent = workspace
                                
                                game:GetService("Debris"):AddItem(flash, 0.5)
                            end)
                        end
                    end
                end
            end)
        end)
    end
end

function SkySquidModule.ToggleVoidKill(enabled)
    SkySquidModule.VoidKillEnabled = enabled
    
    if voidKillConnection then
        voidKillConnection:Disconnect()
        voidKillConnection = nil
    end
    
    if enabled then
        voidKillConnection = RunService.Heartbeat:Connect(function()
            if not SkySquidModule.VoidKillEnabled then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChild("Humanoid")
                
                if not rootPart or not humanoid or humanoid.Health <= 0 then return end
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                        if targetRoot then
                            local distance = (rootPart.Position - targetRoot.Position).Magnitude
                            
                            if distance < 15 then
                                local voidPosition = Vector3.new(0, 10000, 0)
                                player.Character.HumanoidRootPart.CFrame = CFrame.new(voidPosition)
                                
                                local platform = Instance.new("Part")
                                platform.Name = "VoidPlatform_" .. player.Name
                                platform.Size = Vector3.new(50, 5, 50)
                                platform.Position = voidPosition - Vector3.new(0, 3, 0)
                                platform.Anchored = true
                                platform.CanCollide = true
                                platform.Transparency = 0.5
                                platform.Material = Enum.Material.Neon
                                platform.BrickColor = BrickColor.new("Bright purple")
                                platform.Parent = workspace
                                
                                SkySquidModule.SafePlatform = platform
                                
                                delay(10, function()
                                    if platform and platform.Parent then
                                        platform:Destroy()
                                        SkySquidModule.SafePlatform = nil
                                    end
                                end)
                                
                                break
                            end
                        end
                    end
                end
            end)
        end)
    else
        if SkySquidModule.SafePlatform then
            SkySquidModule.SafePlatform:Destroy()
            SkySquidModule.SafePlatform = nil
        end
    end
end

function SkySquidModule.ToggleAutoQTE(enabled)
    SkySquidModule.AutoQTEEnabled = enabled
    
    if autoQTEConnection then
        autoQTEConnection:Disconnect()
        autoQTEConnection = nil
    end
    
    if enabled then
        autoQTEConnection = RunService.Heartbeat:Connect(function()
            if not SkySquidModule.AutoQTEEnabled then return end
            
            pcall(function()
                local gui = LocalPlayer.PlayerGui
                if not gui then return end
                
                local screenGui = gui:FindFirstChild("ScreenGui") or gui:FindFirstChild("QTE")
                if screenGui then
                    for _, element in pairs(screenGui:GetDescendants()) do
                        if element:IsA("TextButton") or element:IsA("ImageButton") then
                            local buttonText = element.Text or element.Name
                            if buttonText:match("[FEQR]") or element:FindFirstChild("QTE") then
                                local absolutePosition = element.AbsolutePosition
                                local absoluteSize = element.AbsoluteSize
                                
                                local centerY = absolutePosition.Y + (absoluteSize.Y / 2)
                                if centerY > 350 and centerY < 450 then
                                    local keyToPress = nil
                                    
                                    if buttonText:find("F") then
                                        keyToPress = Enum.KeyCode.F
                                    elseif buttonText:find("E") then
                                        keyToPress = Enum.KeyCode.E
                                    elseif buttonText:find("Q") then
                                        keyToPress = Enum.KeyCode.Q
                                    elseif buttonText:find("R") then
                                        keyToPress = Enum.KeyCode.R
                                    else
                                        keyToPress = Enum.KeyCode.F
                                    end
                                    
                                    if keyToPress then
                                        VirtualInputManager:SendKeyEvent(true, keyToPress, false, game)
                                        task.wait(0.05)
                                        VirtualInputManager:SendKeyEvent(false, keyToPress, false, game)
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

function SkySquidModule.Cleanup()
    if skySquidAntiFallConnection then
        skySquidAntiFallConnection:Disconnect()
        skySquidAntiFallConnection = nil
    end
    
    if voidKillConnection then
        voidKillConnection:Disconnect()
        voidKillConnection = nil
    end
    
    if autoQTEConnection then
        autoQTEConnection:Disconnect()
        autoQTEConnection = nil
    end
    
    if SkySquidModule.SafePlatform then
        SkySquidModule.SafePlatform:Destroy()
        SkySquidModule.SafePlatform = nil
    end
    
    SkySquidModule.AntiFallEnabled = false
    SkySquidModule.VoidKillEnabled = false
    SkySquidModule.AutoQTEEnabled = false
end

return SkySquidModule
