-- Скрипт который кикает (универсальный)
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Ждем немного и кикаем
task.wait(0.5)
player:Kick("Script Discontinued")
