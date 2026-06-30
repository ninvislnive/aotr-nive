-- Nive AOTR LEGENDARY SCRIPT (FIXED GUI)
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/ninvislnive/aotr-legendary/main/src.lua"))()
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

-- Настройки
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
    -- Visual
    ESP = false,
    Speed = 50,
    NoClip = false,
    Flight = false,
    InfJump = false,
    -- Defense
    GodMode = false,
    AntiBan = true,
    ActionDelay = 0.3,
    LastAction = 0,
    -- Teleport
    TeleportTarget = "Titan",
    -- Nive
    AutoLoad = false,
    AutoEmote = false,
    EmoteInterval = 3,
    HideKey = "RightAlt",
    -- Settings
    AutoSpinFamily = false,
    MenuOpen = true
}

-- ==================== Чёрная дыра при инжекте ====================
spawn(function()
    local bg = Instance.new("ScreenGui", CoreGui)
    local f = Instance.new("Frame", bg)
    f.Size = UDim2.new(1,0,1,0)
    f.BackgroundColor3 = Color3.new(0,0,0)
    f.BackgroundTransparency = 1
    TweenService:Create(f, TweenInfo.new(1.5, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.3}):Play()

    -- Вихрь колец
    for i = 1, 5 do
        local ring = Instance.new("Frame", bg)
        ring.Size = UDim2.new(0, 100 + i*50, 0, 100 + i*50)
        ring.Position = UDim2.new(0.5, -50 - i*25, 0.5, -50 - i*25)
        ring.BackgroundColor3 = Color3.new(1,1,1)
        ring.BackgroundTransparency = 0.8
        ring.BorderSizePixel = 1
        ring.BorderColor3 = Color3.fromRGB(160, 80, 255)
        ring.Rotation = i * 30
        spawn(function()
            while ring and ring.Parent do
                ring.Rotation = ring.Rotation + (5 - i)
                TweenService:Create(ring, TweenInfo.new(2), {BackgroundTransparency = 0.95}):Play()
                task.wait(1)
                TweenService:Create(ring, TweenInfo.new(2), {BackgroundTransparency = 0.8}):Play()
            end
        end)
    end

    -- Частицы
    for i = 1, 30 do
        local p = Instance.new("Frame", bg)
        p.Size = UDim2.new(0, 6, 0, 6)
        p.BackgroundColor3 = Color3.new(1,1,1)
        p.Position = UDim2.new(0.5, math.random(-250,250), 0.5, math.random(-250,250))
        p.AnchorPoint = Vector2.new(0.5,0.5)
        p.BorderSizePixel = 0
        local t = TweenService:Create(p, TweenInfo.new(2.5, Enum.EasingStyle.InQuad), {
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        })
        t:Play()
        task.delay(2.5, function() p:Destroy() end)
    end

    -- Логотип с анимацией появления
    local logo = Instance.new("TextLabel", bg)
    logo.Size = UDim2.new(0, 250, 0, 60)
    logo.Position = UDim2.new(0.5, -125, 0.4, -30)
    logo.Text = "NIVE AOTR"
    logo.TextColor3 = Color3.fromRGB(180, 100, 255)
    logo.Font = Enum.Font.SciFi
    logo.TextSize = 28
    logo.BackgroundTransparency = 1
    logo.TextTransparency = 1
    TweenService:Create(logo, TweenInfo.new(1.5, Enum.EasingStyle.Bounce), {TextTransparency = 0}):Play()
    wait(2.5)
    bg:Destroy()
end)

-- ==================== СОЗДАНИЕ GUI ====================
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "NiveAOTR"

-- Главное меню
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 740, 0, 420)
main.Position = UDim2.new(0.5, -370, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(10, 5, 25)
main.BorderSizePixel = 2
main.BorderColor3 = Color3.fromRGB(180, 100, 255)
main.Visible = true
main.Active = true

-- Плавное появление
main.BackgroundTransparency = 1
main.Position = UDim2.new(0.5, -370, 0.5, -140)
TweenService:Create(main, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
    BackgroundTransparency = 0,
    Position = UDim2.new(0.5, -370, 0.5, -210)
}):Play()

-- Пульсирующая рамка
spawn(function()
    while main and main.Parent do
        local r = math.sin(tick() * 3) * 0.2 + 0.8
        main.BorderColor3 = Color3.fromRGB(180 * r, 100 * r, 255)
        task.wait()
    end
end)

-- Заголовок
local titleBar = Instance.new("TextButton", main)
titleBar.Size = UDim2.new(1, 0, 0, 26)
titleBar.Text = "🌌 NIVE AOTR — LEGENDARY"
titleBar.BackgroundColor3 = Color3.fromRGB(15, 8, 35)
titleBar.TextColor3 = Color3.new(1, 1, 1)
titleBar.Font = Enum.Font.SciFi
titleBar.TextSize = 14
titleBar.AutoButtonColor = false

-- Перетаскивание
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

-- Вкладки слева
local tabFrame = Instance.new("Frame", main)
tabFrame.Size = UDim2.new(0, 160, 1, -26)
tabFrame.Position = UDim2.new(0, 0, 0, 26)
tabFrame.BackgroundColor3 = Color3.fromRGB(8, 4, 18)
tabFrame.BorderSizePixel = 1
tabFrame.BorderColor3 = Color3.fromRGB(120, 60, 180)

local uiListLayout = Instance.new("UIListLayout", tabFrame)
uiListLayout.Padding = UDim.new(0, 6)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Контентная область справа
local contentArea = Instance.new("Frame", main)
contentArea.Size = UDim2.new(1, -164, 1, -26)
contentArea.Position = UDim2.new(0, 164, 0, 26)
contentArea.BackgroundTransparency = 1

-- Список вкладок
local tabNames = {"Farm", "Combat", "Visual", "Movement", "Defense", "Teleport", "Nive", "Settings", "Credits"}
local tabBtns = {}
local contents = {}

for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton", tabFrame)
    btn.Size = UDim2.new(1, -12, 0, 32)
    btn.Text = "  " .. name
    btn.BackgroundColor3 = i == 1 and Color3.fromRGB(100, 50, 150) or Color3.fromRGB(25, 20, 45)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(140, 100, 200)
    btn.AutoButtonColor = false
    table.insert(tabBtns, btn)

    local content = Instance.new("ScrollingFrame", contentArea)
    content.Size = UDim2.new(1, 0, 1, 0)
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.ScrollBarThickness = 3
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.Visible = i == 1
    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0, 4)
    table.insert(contents, content)

    btn.MouseButton1Click:Connect(function()
        for _, b in ipairs(tabBtns) do b.BackgroundColor3 = Color3.fromRGB(25, 20, 45) end
        btn.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
        for _, c in ipairs(contents) do c.Visible = false end
        content.Visible = true
    end)
end

-- Вспомогательные функции UI
local function addToggle(content, text, key)
    local btn = Instance.new("TextButton", content)
    btn.Size = UDim2.new(1, -4, 0, 30)
    btn.Text = "  " .. text .. ": " .. (Settings[key] and "ON" or "OFF")
    btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
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
    btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
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

-- ==================== ЗАПОЛНЕНИЕ ВКЛАДОК ====================
addToggle(contents[1], "Auto Farm Titans", "AutoFarm")
addToggle(contents[1], "Auto Quests", "AutoQuest")
addToggle(contents[1], "Auto Boss", "AutoBoss")
addToggle(contents[1], "Infinite Gas", "InfiniteGas")
addToggle(contents[1], "Infinite Blades", "InfiniteBlades")
addToggle(contents[1], "5 Crits Per Hit", "FiveCrits")

addToggle(contents[2], "Kill Aura", "KillAura")
addToggle(contents[2], "Auto Skill", "AutoSkill")

addToggle(contents[3], "ESP", "ESP")
addToggle(contents[3], "NoClip", "NoClip")

addToggle(contents[4], "Flight", "Flight")
addToggle(contents[4], "Infinite Jump", "InfJump")

addToggle(contents[5], "God Mode", "GodMode")
addToggle(contents[5], "Anti-Ban", "AntiBan")

addButton(contents[6], "Teleport to Titan", function()
    local root = getRoot() if not root then return end
    local nearest = findNearestTitan()
    if nearest then root.CFrame = CFrame.new(nearest.Position + Vector3.new(0,5,0)) end
end)
addButton(contents[6], "Teleport to Center", function()
    local root = getRoot() if root then root.CFrame = CFrame.new(0, 10, 0) end
end)

addToggle(contents[7], "Auto Load (All ON)", "AutoLoad")
addToggle(contents[7], "Auto Emote", "AutoEmote")

addToggle(contents[8], "Auto Spin Family", "AutoSpinFamily")

local cred = Instance.new("TextLabel", contents[9])
cred.Size = UDim2.new(1, 0, 0, 80)
cred.Text = "Nive AOTR Legendary Script\nCreated by Nive\nSupport: donationalerts.com/r/nive"
cred.TextColor3 = Color3.new(0.8,0.6,1)
cred.BackgroundTransparency = 1
cred.Font = Enum.Font.SourceSans
cred.TextSize = 13
cred.TextWrapped = true
contents[9].CanvasSize += UDim2.new(0,0,0,80)

-- ==================== ЧЁРНАЯ ДЫРА ПРИ СКРЫТИИ (ALT) ====================
local blackHoleContainer = Instance.new("ScreenGui", CoreGui)
local blackHole = Instance.new("Frame", blackHoleContainer)
blackHole.Size = UDim2.new(0,0,0,0)
blackHole.Position = UDim2.new(0.5,0,0.5,0)
blackHole.AnchorPoint = Vector2.new(0.5,0.5)
blackHole.BackgroundColor3 = Color3.new(0,0,0)
blackHole.BorderSizePixel = 0
blackHole.Visible = false

-- Кольца
for i = 1, 4 do
    local ring = Instance.new("Frame", blackHole)
    ring.Size = UDim2.new(0, 200 + i*50, 0, 200 + i*50)
    ring.Position = UDim2.new(0.5, -100 - i*25, 0.5, -100 - i*25)
    ring.BackgroundColor3 = Color3.new(1,1,1)
    ring.BackgroundTransparency = 0.85
    ring.BorderSizePixel = 1
    ring.BorderColor3 = Color3.fromRGB(180, 120, 255)
    ring.Rotation = i * 60
    spawn(function()
        while ring and ring.Parent do
            ring.Rotation = ring.Rotation + (6 - i*0.5)
            task.wait()
        end
    end)
end

-- Частицы
for i = 1, 15 do
    local p = Instance.new("Frame", blackHole)
    p.Size = UDim2.new(0, 5, 0, 5)
    p.BackgroundColor3 = Color3.new(1,1,1)
    p.Position = UDim2.new(0.5, math.random(-180,180), 0.5, math.random(-180,180))
    p.AnchorPoint = Vector2.new(0.5,0.5)
    p.BorderSizePixel = 0
    spawn(function()
        while p and p.Parent do
            TweenService:Create(p, TweenInfo.new(1.5, Enum.EasingStyle.Quad), {
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            }):Play()
            task.wait(1.5)
            p.Position = UDim2.new(0.5, math.random(-180,180), 0.5, math.random(-180,180))
            p.Size = UDim2.new(0, 5, 0, 5)
            p.BackgroundTransparency = 0
        end
    end)
end

local function toggleMenu()
    Settings.MenuOpen = not Settings.MenuOpen
    if Settings.MenuOpen then
        main.Visible = true
        main.BackgroundTransparency = 1
        main.Position = UDim2.new(0.5, -370, 0.5, -140)
        TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
            BackgroundTransparency = 0,
            Position = UDim2.new(0.5, -370, 0.5, -210)
        }):Play()
        blackHole.Visible = false
    else
        blackHole.Size = UDim2.new(0,0,0,0)
        blackHole.BackgroundTransparency = 0.2
        blackHole.Visible = true
        local expand = TweenService:Create(blackHole, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 400, 0, 400)
        })
        expand:Play()
        expand.Completed:Connect(function()
            local shrink = TweenService:Create(blackHole, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 0, 0, 0)
            })
            shrink:Play()
            shrink.Completed:Connect(function() blackHole.Visible = false end)
        end)
        TweenService:Create(main, TweenInfo.new(0.3), {
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, -370, 0.5, -140)
        }):Play()
        task.wait(0.3)
        main.Visible = false
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode[Settings.HideKey] then
        toggleMenu()
    end
end)

-- ==================== УТИЛИТЫ ====================
local function getRoot() return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") end
local function getHum() return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") end
local function canAct()
    if not Settings.AntiBan then return true end
    if tick() - Settings.LastAction >= Settings.ActionDelay then
        Settings.LastAction = tick() + (math.random() * 0.2 - 0.1)
        return true
    end
    return false
end

function findNearestTitan()
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

local function findBoss()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name:lower():find("boss") or obj.Name:lower():find("beast")) and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
            return obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
        end
    end
    return nil
end

local function findQuestGiver()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local part = obj.Parent
            if part:IsA("BasePart") then return part end
        end
    end
    return nil
end

-- ==================== ФУНКЦИИ ====================
local lastFarm = 0
local function autoFarm()
    if not Settings.AutoFarm then return end
    if tick() - lastFarm < 0.8 then return end
    lastFarm = tick()
    local root = getRoot() if not root then return end
    local nearest = findNearestTitan()
    if not nearest then return end
    if not canAct() then return end
    root.CFrame = CFrame.new(nearest.Position + Vector3.new(0,5,0))
    for i = 1, (Settings.FiveCrits and 5 or 1) do
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.02)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        if Settings.FiveCrits and i < 5 then task.wait(0.05) end
    end
end

local function autoQuest()
    if not Settings.AutoQuest or not canAct() then return end
    local npc = findQuestGiver()
    if not npc then return end
    local root = getRoot() if not root then return end
    root.CFrame = CFrame.new(npc.Position + Vector3.new(0,3,0))
    task.wait(0.3)
    local prompt = npc:FindFirstChildWhichIsA("ProximityPrompt")
    if prompt then fireproximityprompt(prompt) end
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local questFrame = playerGui:FindFirstChild("QuestsFrame") or playerGui:FindFirstChild("QuestGui")
    if questFrame then
        for _, child in ipairs(questFrame:GetDescendants()) do
            if child:IsA("TextButton") and (child.Text:lower():find("claim") or child.Text:lower():find("complete")) then
                fireclickdetector(child)
            end
        end
    end
end

local function autoBoss()
    if not Settings.AutoBoss then return end
    local boss = findBoss()
    if not boss then return end
    if not canAct() then return end
    local root = getRoot() if not root then return end
    root.CFrame = CFrame.new(boss.Position + Vector3.new(0,5,0))
    for _ = 1, 5 do
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        task.wait(0.05)
    end
end

local function infiniteGas()
    if not Settings.InfiniteGas then return end
    local char = LocalPlayer.Character if not char then return end
    local gas = char:FindFirstChild("Gas") or char:FindFirstChild("CurrentGas")
    if gas and gas:IsA("IntValue") then gas.Value = 100 end
end

local function infiniteBlades()
    if not Settings.InfiniteBlades then return end
    local char = LocalPlayer.Character if not char then return end
    local blades = char:FindFirstChild("Blades") or char:FindFirstChild("BladeDurability")
    if blades and blades:IsA("IntValue") then blades.Value = 100 end
end

local function killAura()
    if not Settings.KillAura then return end
    local nearest = findNearestTitan()
    if not nearest then return end
    if not canAct() then return end
    local root = getRoot() if not root then return end
    root.CFrame = CFrame.new(nearest.Position + Vector3.new(0,3,0))
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

local function flight()
    if not Settings.Flight then return end
    local root = getRoot() local hum = getHum() if not root or not hum then return end
    hum.PlatformStand = true
    local bf = root:FindFirstChild("FlyVel") or Instance.new("BodyVelocity", root)
    bf.Name = "FlyVel"; bf.MaxForce = Vector3.new(1e5,1e5,1e5)
    local dir = Vector3.new() local cam = Workspace.CurrentCamera
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir += Vector3.new(0,-1,0) end
    bf.Velocity = dir * 50
end

local function noclip()
    if not Settings.NoClip then return end
    local char = Lo
