-- Nive AOTR Cosmic Ultimate Script (Xeno compatible, no lag, anti-ban)
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/ninvislnive/aotr-nive/main/src.lua"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")

-- ==================== SETTINGS ====================
local Settings = {
    -- Farm
    AutoFarm = false,
    AutoQuest = false,
    AutoBoss = false,
    InfiniteGas = false,
    InfiniteBlades = false,
    FiveCrits = false,
    -- Combat
    KillAura = false,
    AutoSkill = false,
    -- Nive (ключ скрытия)
    HideKey = "RightAlt",  -- RightAlt, LeftAlt, RightControl, etc.
    AutoLoad = false,
    -- Settings
    AutoSpinFamily = false,
    -- Visual
    ESP = false,
    Speed = 50,
    NoClip = false,
    Flight = false,
    -- Defense
    GodMode = false,
    AntiBan = true,
    ActionDelay = 0.3,
    LastAction = 0,
    MenuOpen = true
}

-- ==================== BLACK HOLE INTRO ====================
spawn(function()
    local bg = Instance.new("ScreenGui", CoreGui)
    local f = Instance.new("Frame", bg)
    f.Size = UDim2.new(1,0,1,0)
    f.BackgroundColor3 = Color3.new(0,0,0)
    f.BackgroundTransparency = 1
    TweenService:Create(f, TweenInfo.new(1.5), {BackgroundTransparency = 0.2}):Play()
    for _=1,20 do
        local p = Instance.new("Frame", bg)
        p.Size = UDim2.new(0,4,0,4)
        p.BackgroundColor3 = Color3.new(1,1,1)
        p.Position = UDim2.new(0.5, math.random(-200,200), 0.5, math.random(-200,200))
        p.AnchorPoint = Vector2.new(0.5,0.5)
        local t = TweenService:Create(p, TweenInfo.new(2, Enum.EasingStyle.InQuad), {
            Position = UDim2.new(0.5,0,0.5,0),
            Size = UDim2.new(0,0,0,0),
            BackgroundTransparency = 1
        })
        t:Play()
        task.delay(2.5, function() p:Destroy() end)
    end
    local logo = Instance.new("TextLabel", bg)
    logo.Size = UDim2.new(0,200,0,50)
    logo.Position = UDim2.new(0.5,-100,0.4,-25)
    logo.Text = "NIVE"
    logo.TextColor3 = Color3.fromRGB(180,100,255)
    logo.Font = Enum.Font.SciFi
    logo.TextSize = 24
    logo.BackgroundTransparency = 1
    logo.TextTransparency = 1
    TweenService:Create(logo, TweenInfo.new(1.5), {TextTransparency = 0}):Play()
    wait(2.5)
    bg:Destroy()
end)

-- ==================== MAIN GUI ====================
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "NiveAOTR"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 360, 0, 420)
main.Position = UDim2.new(0.5, -180, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(15,10,30)
main.BorderSizePixel = 2
main.BorderColor3 = Color3.fromRGB(160,80,255)
main.Visible = Settings.MenuOpen
main.Active = true

-- анимация появления
main.BackgroundTransparency = 1
main.Position = UDim2.new(0.5, -180, 0.5, -160)
TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
    BackgroundTransparency = 0,
    Position = UDim2.new(0.5, -180, 0.5, -210)
}):Play()

-- пульсирующая рамка
spawn(function()
    while main and main.Parent do
        local r = math.sin(tick() * 3) * 0.2 + 0.8
        main.BorderColor3 = Color3.fromRGB(160 * r, 80 * r, 255)
        task.wait()
    end
end)

-- перетаскивание
local titleBar = Instance.new("TextButton", main)
titleBar.Size = UDim2.new(1, 0, 0, 28)
titleBar.Text = "🌌 NIVE AOTR"
titleBar.BackgroundColor3 = Color3.fromRGB(18, 12, 35)
titleBar.TextColor3 = Color3.new(1, 1, 1)
titleBar.Font = Enum.Font.SciFi
titleBar.TextSize = 14
titleBar.AutoButtonColor = false

local dragging, dragStart, startPos = false, nil, nil
titleBar.MouseButton1Down:Connect(function()
    dragging = true
    dragStart = UserInputService:GetMouseLocation()
    startPos = main.Position
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = UserInputService:GetMouseLocation() - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- вкладки
local tabFrame = Instance.new("Frame", main)
tabFrame.Size = UDim2.new(1, 0, 0, 24)
tabFrame.Position = UDim2.new(0, 0, 0, 30)
tabFrame.BackgroundTransparency = 1

local tabNames = {"Farm", "Nive", "Visual", "Defense", "Teleport", "Settings", "Credits"}
local tabContents = {}
local tabBtns = {}

for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton", tabFrame)
    btn.Size = UDim2.new(1/#tabNames, -2, 1, 0)
    btn.Position = UDim2.new((i-1)/#tabNames, 1, 0, 0)
    btn.Text = name
    btn.BackgroundColor3 = i == 1 and Color3.fromRGB(100, 50, 150) or Color3.fromRGB(40, 30, 70)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 10
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(120,100,180)
    btn.AutoButtonColor = false
    table.insert(tabBtns, btn)

    local content = Instance.new("ScrollingFrame", main)
    content.Size = UDim2.new(1, 0, 1, -56)
    content.Position = UDim2.new(0, 0, 0, 56)
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.ScrollBarThickness = 3
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.Visible = i == 1
    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0, 4)
    table.insert(tabContents, content)

    btn.MouseButton1Click:Connect(function()
        for _, b in ipairs(tabBtns) do b.BackgroundColor3 = Color3.fromRGB(40,30,70) end
        btn.BackgroundColor3 = Color3.fromRGB(100,50,150)
        for _, c in ipairs(tabContents) do c.Visible = false end
        content.Visible = true
    end)
end

-- функция создания тоггла
local function addToggle(content, text, key)
    local btn = Instance.new("TextButton", content)
    btn.Size = UDim2.new(1, -4, 0, 30)
    btn.Text = "  " .. text .. ": " .. (Settings[key] and "ON" or "OFF")
    btn.BackgroundColor3 = Color3.fromRGB(35, 25, 55)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(80,60,120)
    btn.AutoButtonColor = false
    btn.MouseButton1Click:Connect(function()
        Settings[key] = not Settings[key]
        btn.Text = "  " .. text .. ": " .. (Settings[key] and "ON" or "OFF")
    end)
    content.CanvasSize += UDim2.new(0,0,0,34)
end

local function addButton(content, text, callback)
    local btn = Instance.new("TextButton", content)
    btn.Size = UDim2.new(1, -4, 0, 30)
    btn.Text = "  " .. text
    btn.BackgroundColor3 = Color3.fromRGB(35, 25, 55)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(80,60,120)
    btn.AutoButtonColor = false
    btn.MouseButton1Click:Connect(callback)
    content.CanvasSize += UDim2.new(0,0,0,34)
end

local function addSlider(content, text, key, min, max)
    local frame = Instance.new("Frame", content)
    frame.Size = UDim2.new(1, -4, 0, 52)
    frame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 18)
    label.Text = text .. ": " .. Settings[key]
    label.TextColor3 = Color3.new(0.8,0.8,1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSans
    label.TextSize = 12
    local input = Instance.new("TextBox", frame)
    input.Size = UDim2.new(1, 0, 0, 24)
    input.Position = UDim2.new(0, 0, 0, 20)
    input.Text = tostring(Settings[key])
    input.BackgroundColor3 = Color3.fromRGB(35,25,55)
    input.TextColor3 = Color3.new(1,1,1)
    input.Font = Enum.Font.SourceSans
    input.BorderSizePixel = 1
    input.BorderColor3 = Color3.fromRGB(80,60,120)
    input.FocusLost:Connect(function()
        local num = tonumber(input.Text)
        if num then
            num = math.clamp(num, min, max)
            Settings[key] = num
            input.Text = tostring(num)
            label.Text = text .. ": " .. num
        end
    end)
    content.CanvasSize += UDim2.new(0,0,0,56)
end

-- ================ ЗАПОЛНЕНИЕ ВКЛАДОК ================
-- Farm
addToggle(tabContents[1], "Auto Farm Titans", "AutoFarm")
addToggle(tabContents[1], "Auto Quests", "AutoQuest")
addToggle(tabContents[1], "Auto Boss", "AutoBoss")
addToggle(tabContents[1], "Infinite Gas", "InfiniteGas")
addToggle(tabContents[1], "Infinite Blades", "InfiniteBlades")
addToggle(tabContents[1], "5 Crits Per Hit", "FiveCrits")

-- Nive
addToggle(tabContents[2], "Auto Load (All ON)", "AutoLoad")
addButton(tabContents[2], "Set Hide Key (click)", function()
    -- простой выбор: запомним следующий нажатый Alt/Control
    local conn
    conn = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.RightAlt or input.KeyCode == Enum.KeyCode.LeftAlt or
           input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.LeftControl then
            Settings.HideKey = input.KeyCode.Name
            addToggle(tabContents[2], "Hide Key: " .. Settings.HideKey, "HideKey")
            conn:Disconnect()
        end
    end)
end)

-- Visual
addToggle(tabContents[3], "ESP", "ESP")
addSlider(tabContents[3], "Walk Speed", "Speed", 16, 200)
addToggle(tabContents[3], "NoClip", "NoClip")
addToggle(tabContents[3], "Flight", "Flight")

-- Defense
addToggle(tabContents[4], "God Mode", "GodMode")
addToggle(tabContents[4], "Anti-Ban", "AntiBan")
addSlider(tabContents[4], "Action Delay", "ActionDelay", 0.1, 2.0)

-- Teleport
addButton(tabContents[5], "Teleport to Titan", function()
    local root = getRoot() if not root then return end
    local nearest = findNearestTitan()
    if nearest then root.CFrame = CFrame.new(nearest.Position + Vector3.new(0,5,0)) end
end)
addButton(tabContents[5], "Teleport to Center", function()
    local root = getRoot() if root then root.CFrame = CFrame.new(0, 10, 0) end
end)

-- Settings
addToggle(tabContents[6], "Auto Spin Family", "AutoSpinFamily")

-- Credits
local cred = Instance.new("TextLabel", tabContents[7])
cred.Size = UDim2.new(1, 0, 0, 60)
cred.Text = "Nive AOTR Ultimate\nCreated by Nive\nSupport: donationalerts.com/r/nive"
cred.TextColor3 = Color3.new(0.8,0.6,1)
cred.BackgroundTransparency = 1
cred.Font = Enum.Font.SourceSans
cred.TextSize = 13
cred.TextWrapped = true
tabContents[7].CanvasSize += UDim2.new(0,0,0,60)

-- ==================== BLACK HOLE TOGGLE (by Alt or chosen key) ====================
local blackHole = Instance.new("Frame", gui)
blackHole.Size = UDim2.new(0,0,0,0)
blackHole.Position = UDim2.new(0.5,0,0.5,0)
blackHole.AnchorPoint = Vector2.new(0.5,0.5)
blackHole.BackgroundColor3 = Color3.new(0,0,0)
blackHole.BorderSizePixel = 0
blackHole.Visible = false

local function toggleMenu()
    Settings.MenuOpen = not Settings.MenuOpen
    if Settings.MenuOpen then
        main.Visible = true
        main.BackgroundTransparency = 1
        main.Position = UDim2.new(0.5, -180, 0.5, -160)
        TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            BackgroundTransparency = 0,
            Position = UDim2.new(0.5, -180, 0.5, -210)
        }):Play()
        blackHole.Visible = false
    else
        blackHole.Size = UDim2.new(0,0,0,0)
        blackHole.BackgroundTransparency = 0
        blackHole.Visible = true
        local expand = TweenService:Create(blackHole, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0,300,0,300)
        })
        expand:Play()
        expand.Completed:Connect(function()
            local shrink = TweenService:Create(blackHole, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0,0,0,0)
            })
            shrink:Play()
            shrink.Completed:Connect(function() blackHole.Visible = false end)
        end)
        TweenService:Create(main, TweenInfo.new(0.2), {
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, -180, 0.5, -160)
        }):Play()
        task.wait(0.2)
        main.Visible = false
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local keyName = input.KeyCode.Name
    if keyName == Settings.HideKey then
        toggleMenu()
    end
end)

-- ==================== UTILITY FUNCTIONS ====================
local function getRoot() return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") end
local function getHum() return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") end

local function findNearestTitan()
    local root = getRoot() if not root then return nil end
    local nearest, ndist = nil, 300
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("titan") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
            local hrp = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
            if hrp then
                local dist = (root.Position - hrp.Position).Magnitude
                if dist < ndist then ndist = dist; nearest = hrp end
            end
        end
    end
    return nearest
end

local function findNearestQuestGiver()
    -- ищем NPC с квестом (например, с ProximityPrompt или Billboard)
    local root = getRoot() if not root then return nil end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local part = obj.Parent
            if part:IsA("BasePart") then
                return part
            end
        end
    end
    return nil
end

local function canAct()
    if not Settings.AntiBan then return true end
    local now = tick()
    if now - Settings.LastAction >= Settings.ActionDelay then
        Settings.LastAction = now + (math.random() * 0.2 - 0.1) -- рандомизация
        return true
    end
    return false
end

local function safeTeleport(targetPos)
    local root = getRoot() if not root then return end
    if not canAct() then return end
    root.CFrame = CFrame.new(targetPos + Vector3.new(0,3,0))
end

-- ==================== FEATURE FUNCTIONS ====================
-- Auto Farm (убийство титанов)
local function autoFarm()
    if not Settings.AutoFarm then return end
    local root = getRoot() if not root then return end
    local nearest = findNearestTitan()
    if not nearest then return end
    safeTeleport(nearest.Position)
    -- быстрые удары (5 критов)
    for i = 1, (Settings.FiveCrits and 5 or 1) do
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0) -- левый клик
        task.wait(0.02)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        if Settings.FiveCrits and i < 5 then task.wait(0.05) end
    end
end

-- Auto Quests (принятие и выполнение)
local function autoQuest()
    if not Settings.AutoQuest then return end
    -- сначала ищем квестодателя, подходим, жмём E
    local npc = findNearestQuestGiver()
    if npc then
        safeTeleport(npc.Position)
        task.wait(0.3)
        -- активируем ProximityPrompt
        fireproximityprompt(npc:FindFirstChildWhichIsA("ProximityPrompt"))
    end
    -- затем ищем кнопки Claim в GUI
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local questsFrame = playerGui:FindFirstChild("QuestsFrame") or playerGui:FindFirstChild("QuestGui")
    if questsFrame then
        for _, child in ipairs(questsFrame:GetDescendants()) do
            if child:IsA("TextButton") and (child.Text:lower():find("claim") or child.Text:lower():find("complete")) then
                fireclickdetector(child)
            end
        end
    end
end

-- Auto Boss (аналогично, ищем босса и бьём)
local function autoBoss()
    if not Settings.AutoBoss then return end
    local root = getRoot() if not root then return end
    -- боссы обычно крупные и с особыми именами (Boss, Beast, и т.п.)
    local boss = nil
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name:lower():find("boss") or obj.Name:lower():find("beast")) and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
            local hrp = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
            if hrp then boss = hrp; break end
        end
    end
    if boss then
        safeTeleport(boss.Position)
        for _ = 1, 5 do
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.02)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
    end
end

-- Infinite Gas/Blades (установка значений)
local function infiniteGas()
    if not Settings.InfiniteGas then return end
    local char = LocalPlayer.Character
    if not char then return end
    local gas = char:FindFirstChild("Gas") or char:FindFirstChild("CurrentGas")
    if gas and gas:IsA("IntValue") then
        gas.Value = 100
    end
end

local function infiniteBlades()
    if not Settings.InfiniteBlades then return end
    local char = LocalPlayer.Character
    if not char then return end
    local blades = char:FindFirstChild("Blades") or char:FindFirstChild("BladeDurability")
    if blades and blades:IsA("IntValue") then
        blades.Value = 100
    end
end

-- Auto Spin Family (прокрутка спинов)
local function autoSpinFamily()
    if not Settings.AutoSpinFamily then return end
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local spinButton = playerGui:FindFirstChild("MainGui") and playerGui.MainGui:FindFirstChild("SpinButton")
    if not spinButton then
        -- ищем кнопку "Spin" или "Family"
        for _, obj in ipairs(playerGui:GetDescendants()) do
            if obj:IsA("TextButton") and (obj.Text:lower():find("spin") or obj.Text:lower():find("family")) then
                spinButton = obj
                break
            end
        end
    end
    if spinButton and spinButton.Visible then
        fireclickdetector(spinButton)
    end
end

-- ESP (подсветка титанов и игроков)
local lastESP = 0
local function esp()
    if not Settings.ESP then return end
    if tick() - lastESP < 3 then return end
    lastESP = tick()
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v.Name == "ESP_Tag" and v:IsA("BillboardGui") then v:Destroy() end
    end
    -- игроки
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local h = plr.Character.Head
            local b = Instance.new("BillboardGui", h)
            b.Name = "ESP_Tag"; b.Adornee = h; b.Size = UDim2.new(0,100,0,20); b.AlwaysOnTop = true
            local t = Instance.new("TextLabel", b)
            t.Size = UDim2.new(1,0,1,0); t.BackgroundTransparency = 1; t.Text = plr.Name
            t.TextColor3 = Color3.new(1,0.5,0); t.Font = Enum.Font.SourceSansBold; t.TextSize = 12
        end
    end
    -- титаны
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("titan") and obj:FindFirstChild("Head") then
            local h = obj.Head
            if not h:FindFirstChild("ESP_Tag") then
                local b = Instance.new("BillboardGui", h)
                b.Name = "ESP_Tag"; b.Adornee = h; b.S
