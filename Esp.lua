local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Состояние функций
local ESP_Boxes = false
local ESP_Lines = false
local ESP_Names = false

local Speed_Enabled = false
local Jump_Enabled = false

-- Хранилище для графики
local ESP_Cache = {}

-- Создание графики для игрока
local function CreateESP(player)
    if player == LocalPlayer then return end

    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(0, 255, 150) -- Неоново-зеленый
    Box.Thickness = 1.5
    Box.Filled = false

    local Line = Drawing.new("Line")
    Line.Visible = false
    Line.Color = Color3.fromRGB(0, 150, 255) -- Неоново-синий
    Line.Thickness = 1

    local Name = Drawing.new("Text")
    Name.Visible = false
    Name.Color = Color3.fromRGB(255, 255, 255)
    Name.Size = 14
    Name.Center = true
    Name.Outline = true

    ESP_Cache[player] = {Box = Box, Line = Line, Name = Name}
end

local function RemoveESP(player)
    if ESP_Cache[player] then
        ESP_Cache[player].Box:Remove()
        ESP_Cache[player].Line:Remove()
        ESP_Cache[player].Name:Remove()
        ESP_Cache[player] = nil
    end
end

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- Рендер ESP
RunService.RenderStepped:Connect(function()
    for player, objs do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") and player.Character.Humanoid.Health > 0 then
            local hrp = player.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

            if onScreen then
                local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
                local sizeX = 2000 / distance
                local sizeY = 3000 / distance

                -- Коробки
                if ESP_Boxes then
                    objs.Box.Size = Vector2.new(sizeX, sizeY)
                    objs.Box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)
                    objs.Box.Visible = true
                else
                    objs.Box.Visible = false
                end

                -- Линии
                if ESP_Lines then
                    objs.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    objs.Line.To = Vector2.new(pos.X, pos.Y + (sizeY / 2))
                    objs.Line.Visible = true
                else
                    objs.Line.Visible = false
                end

                -- Ники
                if ESP_Names then
                    objs.Name.Position = Vector2.new(pos.X, pos.Y - (sizeY / 2) - 15)
                    objs.Name.Text = player.Name .. " [" .. math.floor(distance) .. "m]"
                    objs.Name.Visible = true
                else
                    objs.Name.Visible = false
                end
            else
                objs.Box.Visible = false
                objs.Line.Visible = false
                objs.Name.Visible = false
            end
        else
            objs.Box.Visible = false
            objs.Line.Visible = false
            objs.Name.Visible = false
        end
    end

    -- Настройки персонажа (Speed / Jump)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if Speed_Enabled then hum.WalkSpeed = 60 else hum.WalkSpeed = 16 end
        if Jump_Enabled then hum.JumpPower = 100 else hum.JumpPower = 50 end
    end
end)

--- ========================================== ---
---            ИНТЕРФЕЙС С НЕОНОМ              ---
--- ========================================== ---

if CoreGui:FindFirstChild("DeltaPremium_Gui") then
    CoreGui.DeltaPremium_Gui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaPremium_Gui"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Главное меню
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 320)
MainFrame.Position = UDim2.new(0.5, -120, 0.4, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Подсветка (Бордюр)
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 255, 150)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- Шапка
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
Title.Text = "DELTA v2 | PREMIUM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = Title

-- Кнопка Х (Закрыть)
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.Parent = MainFrame

-- Список для кнопок (UIListLayout автоматизирует расположение)
local List = Instance.new("Frame")
List.Size = UDim2.new(1, -20, 1, -50)
List.Position = UDim2.new(0, 10, 0, 45)
List.BackgroundTransparency = 1
List.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = List

-- Шаблон для красивых кнопок
local function CreateMenuButton(text, order, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 38)
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.LayoutOrder = order
    Btn.Parent = List

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(50, 50, 60)
    Stroke.Thickness = 1
    Stroke.Parent = Btn

    local enabled = false
    Btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        callback(enabled)
        if enabled then
            Btn.BackgroundColor3 = Color3.fromRGB(0, 100, 60)
            Btn.TextColor3 = Color3.fromRGB(0, 255, 150)
            Stroke.Color = Color3.fromRGB(0, 255, 150)
        else
            Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            Stroke.Color = Color3.fromRGB(50, 50, 60)
        end
    end)
end

-- Добавляем функции в меню
CreateMenuButton("ESP Boxes (Коробки)", 1, function(val) ESP_Boxes = val end)
CreateMenuButton("ESP Lines (Трейсеры)", 2, function(val) ESP_Lines = val end)
CreateMenuButton("ESP Names (Ники)", 3, function(val) ESP_Names = val end)
CreateMenuButton("SpeedHack (Бег x4)", 4, function(val) Speed_Enabled = val end)
CreateMenuButton("Super Jump (Прыжок)", 5, function(val) Jump_Enabled = val end)


--- ========================================== ---
---          ФИКС КНОПКИ ОТКРЫТИЯ              ---
--- ========================================== ---

local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.new(0, 45, 0, 45)
OpenButton.Position = UDim2.new(0, 15, 0, 15)
OpenButton.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
OpenButton.Text = "MENU"
OpenButton.TextColor3 = Color3.fromRGB(0, 255, 150)
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 11
OpenButton.Visible = false
OpenButton.Active = true
OpenButton.Draggable = true
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenButton

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = Color3.fromRGB(0, 255, 150)
OpenStroke.Thickness = 1.5
OpenStroke.Parent = OpenButton

-- Умная логика клика без ложных срабатываний при перетаскивании
local dragStartPos = nil
OpenButton.MouseButton1Down:Connect(function()
    dragStartPos = OpenButton.Position
end)

OpenButton.MouseButton1Click:Connect(function()
    -- Проверяем, сдвинулась ли кнопка. Если сдвинулась незначительно — это клик.
    if dragStartPos then
        local dist = (Vector2.new(OpenButton.Position.X.Offset, OpenButton.Position.Y.Offset) - Vector2.new(dragStartPos.X.Offset, dragStartPos.Y.Offset)).Magnitude
        if dist < 5 then -- Если сдвиг меньше 5 пикселей, открываем меню
            MainFrame.Visible = true
            OpenButton.Visible = false
        end
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenButton.Visible = true
end)
