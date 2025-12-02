-- JumpRope.lua - Функции для Jump Rope Game
local JumpRopeModule = {}

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Локальный игрок
local LocalPlayer = Players.LocalPlayer

-- Переменные
JumpRopeModule.JumpRope = {
    TeleportToEnd = false,
    DeleteRope = false,
    AntiFallPlatform = nil
}

-- Jump Rope функции
function JumpRopeModule.TeleportToJumpRopeEnd()
    local player = LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(737.156372, 193.805084, 920.952515)
    end
end

function JumpRopeModule.DeleteJumpRope()
    if Workspace:FindFirstChild("Effects") then
        local rope = Workspace.Effects:FindFirstChild("rope")
        if rope then
            rope:Destroy()
        end
    end
end

-- Jump Rope Anti Fall
function JumpRopeModule.ToggleJumpRopeAntiFall(enabled)
    if enabled then
        JumpRopeModule.CreateJumpRopeAntiFallPlatform()
    else
        JumpRopeModule.RemoveJumpRopeAntiFallPlatform()
    end
end

function JumpRopeModule.CreateJumpRopeAntiFallPlatform()
    if JumpRopeModule.JumpRope.AntiFallPlatform then
        JumpRopeModule.SafeDestroy(JumpRopeModule.JumpRope.AntiFallPlatform)
        JumpRopeModule.JumpRope.AntiFallPlatform = nil
    end
    
    -- Создаем белую Anti-Fall платформу для Jump Rope
    JumpRopeModule.JumpRope.AntiFallPlatform = Instance.new("Part")
    JumpRopeModule.JumpRope.AntiFallPlatform.Name = "JumpRopeAntiFallPlatform"
    JumpRopeModule.JumpRope.AntiFallPlatform.Size = Vector3.new(100, 5, 100)
    JumpRopeModule.JumpRope.AntiFallPlatform.Position = Vector3.new(737.156372, 188.805084, 920.952515)
    JumpRopeModule.JumpRope.AntiFallPlatform.Anchored = true
    JumpRopeModule.JumpRope.AntiFallPlatform.CanCollide = true
    JumpRopeModule.JumpRope.AntiFallPlatform.Transparency = 0  -- Видимая
    JumpRopeModule.JumpRope.AntiFallPlatform.Material = Enum.Material.Plastic
    JumpRopeModule.JumpRope.AntiFallPlatform.Color = Color3.fromRGB(255, 255, 255)  -- Белый цвет
    JumpRopeModule.JumpRope.AntiFallPlatform.Parent = Workspace
end

function JumpRopeModule.RemoveJumpRopeAntiFallPlatform()
    if JumpRopeModule.JumpRope.AntiFallPlatform then
        JumpRopeModule.SafeDestroy(JumpRopeModule.JumpRope.AntiFallPlatform)
        JumpRopeModule.JumpRope.AntiFallPlatform = nil
    end
end

-- Вспомогательные функции
function JumpRopeModule.SafeDestroy(obj)
    if obj and obj.Parent then
        pcall(function() obj:Destroy() end)
    end
end

-- Очистка
function JumpRopeModule.Cleanup()
    print("JumpRope module cleanup")
    
    if JumpRopeModule.JumpRope.AntiFallPlatform then
        JumpRopeModule.SafeDestroy(JumpRopeModule.JumpRope.AntiFallPlatform)
        JumpRopeModule.JumpRope.AntiFallPlatform = nil
    end
end

return JumpRopeModule
