-- Main.lua - Creon X v2.1 (Основной файл)
local MainModule = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- Локальный игрок
local LocalPlayer = Players.LocalPlayer

-- Вспомогательные функции
local function SafeDestroy(obj)
    if obj and obj.Parent then
        pcall(function() obj:Destroy() end)
    end
end

-- Функция для загрузки модулей
function MainModule.LoadModule(moduleName)
    local module = {}
    
    if moduleName == "Misc" then
        module = loadstring(game:HttpGet("https://raw.githubusercontent.com/gosdinmadan-ops/creonx/main/Misc.lua"))()
    elseif moduleName == "RLGL" then
        module = loadstring(game:HttpGet("https://raw.githubusercontent.com/gosdinmadan-ops/creonx/main/RLGL.lua"))()
    elseif moduleName == "SkySquid" then
        module = loadstring(game:HttpGet("https://raw.githubusercontent.com/gosdinmadan-ops/creonx/main/SkySquid.lua"))()
    elseif moduleName == "JumpRope" then
        module = loadstring(game:HttpGet("https://raw.githubusercontent.com/gosdinmadan-ops/creonx/main/JumpRope.lua"))()
    elseif moduleName == "Dalgona" then
        module = loadstring(game:HttpGet("https://raw.githubusercontent.com/gosdinmadan-ops/creonx/main/Dalgona.lua"))()
    elseif moduleName == "TugOfWar" then
        module = loadstring(game:HttpGet("https://raw.githubusercontent.com/gosdinmadan-ops/creonx/main/TugOfWar.lua"))()
    end
    
    return module
end

-- Экспорт функций
MainModule.SafeDestroy = SafeDestroy
MainModule.LocalPlayer = LocalPlayer

-- Очистка при закрытии
function MainModule.Cleanup()
    print("Main module cleanup")
end

-- Автоматическая очистка при выходе
game:GetService("Players").LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not game:GetService("Players").LocalPlayer.Parent then
        MainModule.Cleanup()
    end
end)

return MainModule
