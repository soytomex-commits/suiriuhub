-- SUIRIU HUB | TSB (Modo Definitivo de Alto Rendimiento)

-- Limpiar versiones anteriores en CoreGui y PlayerGui
pcall(function()
    if game.CoreGui:FindFirstChild("SUIRIU_HUB_FINAL") then game.CoreGui.SUIRIU_HUB_FINAL:Destroy() end
    if game.Players.LocalPlayer.PlayerGui:FindFirstChild("SUIRIU_HUB_FINAL") then game.Players.LocalPlayer.PlayerGui.SUIRIU_HUB_FINAL:Destroy() end
end)

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

-- Crear ScreenGui con respaldo seguro
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SUIRIU_HUB_FINAL"
screenGui.ResetOnSpawn = false

local success, err = pcall(function()
    screenGui.Parent = game:GetService("CoreGui")
end)
if not success then
    screenGui.Parent = player:WaitForChild("PlayerGui")
end

-- Ventana principal sólida y visible
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 220)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -110)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 15, 28)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(130, 40, 230)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Barra de título limpia
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -35, 0, 32)
titleLabel.Position = UDim2.new(0, 5, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "SUIRIU HUB | TSB (DIRECTO)"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.TextSize = 13
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

-- Botón de Cierre directo
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 28, 0, 28)
closeButton.Position = UDim2.new(1, -30, 0, 2)
closeButton.BackgroundColor3 = Color3.fromRGB(180, 30, 50)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.TextSize = 12
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = mainFrame

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Estados de los botones
local toggles = {
    ["Teleport Behind"] = false,
    ["Auto Abilities"] = false,
    ["Auto Click"] = false,
    ["Auto Reset"] = false
}

local namesList = {"Teleport Behind", "Auto Abilities", "Auto Click", "Auto Reset"}

-- Coordenadas fijas para asegurar que se dibujen dentro del marco sin contenedores extraños
local coords = {
    UDim2.new(0, 10, 0, 45),
    UDim2.new(0, 195, 0, 45),
    UDim2.new(0, 10, 0, 125),
    UDim2.new(0, 195, 0, 125)
}

-- Referencias de los botones guardadas para actualizar su texto al apagarse
local buttonObjects = {}

-- Creación explícita de los 4 botones
for index, featName in ipairs(namesList) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 175, 0, 65)
    btn.Position = coords[index]
    btn.BackgroundColor3 = Color3.fromRGB(35, 25, 55)
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(90, 30, 150)
    btn.Text = featName .. "\n[OFF]"
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.Parent = mainFrame

    buttonObjects[featName] = btn

    -- Evento de clic ultra directo
    btn.MouseButton1Click:Connect(function()
        toggles[featName] = not toggles[featName]
        if toggles[featName] then
            btn.Text = featName .. "\n[ON]"
            btn.BackgroundColor3 = Color3.fromRGB(110, 30, 190)
            btn.TextColor3 = Color3.new(1, 1, 1)
        else
            btn.Text = featName .. "\n[OFF]"
            btn.BackgroundColor3 = Color3.fromRGB(35, 25, 55)
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end)
end

-- Variable para registrar el conteo exacto de kills del Auto Reset
local startingKillsForReset = nil

-- Bucle de funciones automáticas de juego optimizado y seguro
task.spawn(function()
    while true do
        pcall(function()
            -- 1. Auto Click
            if toggles["Auto Click"] then
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
            
            -- 2. Auto Abilities
            if toggles["Auto Abilities"] then
                local keys = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four}
                for _, key in ipairs(keys) do
                    if not toggles["Auto Abilities"] then break end
                    VirtualInputManager:SendKeyEvent(true, key, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, key, false, game)
                    task.wait(0.3)
                end
            end

            -- 3. Teleport Behind
            if toggles["Teleport Behind"] then
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (char.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                            if dist < 200 then
                                char:PivotTo(p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4))
                                break
                            end
                        end
                    end
                end
            end

            -- 4. Auto Reset (Arreglado: Suma exactamente 10 kills desde el momento exacto de activación)
            if toggles["Auto Reset"] then
                local leaderstats = player:FindFirstChild("leaderstats")
                if leaderstats then
                    local kills = leaderstats:FindFirstChild("Kills") or leaderstats:FindFirstChild("Streak")
                    if kills then
                        if not startingKillsForReset then
                            startingKillsForReset = kills.Value
                        end

                        if kills.Value >= (startingKillsForReset + 10) then
                            if player.Character and player.Character:FindFirstChild("Humanoid") then
                                player.Character.Humanoid.Health = 0
                                startingKillsForReset = nil
                                toggles["Auto Reset"] = false
                                
                                -- Apagar visualmente el botón en pantalla
                                if buttonObjects["Auto Reset"] then
                                    buttonObjects["Auto Reset"].Text = "Auto Reset\n[OFF]"
                                    buttonObjects["Auto Reset"].BackgroundColor3 = Color3.fromRGB(35, 25, 55)
                                    buttonObjects["Auto Reset"].TextColor3 = Color3.fromRGB(200, 200, 200)
                                end
                            end
                        end
                    end
                end
            else
                startingKillsForReset = nil
            end
        end)
        task.wait(0.1)
    end
end)

print("¡SUIRIU HUB - CARGADO CON ÉXITO!")
