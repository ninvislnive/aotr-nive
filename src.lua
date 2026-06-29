-- Nive AOTR Ultimate Horizontal Menu (No dark screen, Alt toggles black hole)
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
    -- Movement
    -- (отдельные флаги уже есть)
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

-- ==================== BLACK HOLE (only for hiding) ====================
local blackHoleGui = Instance.new("ScreenGui", CoreGui)
blackHoleGui.Name = "NiveBlackHole"
local blackHole = Instance.new("Frame", blackHoleGui)
blackHole.Size = UDim2.new(0,0,0,0)
blackHole.Position = UDim2.new(0.5,0,0.5,0)
blackHole.AnchorPoint = Vector2.new(0.5,0.5)
blackHole.BackgroundColor3 = Color3.new(0,0,0)
blackHole.BackgroundTransparency = 0
blackHole.BorderSizePixel = 0
blackHole.Visible = false

for i = 1, 3 do
    local ring = Instance.new("Frame", blackHole)
    ring.Size = UDim2.new(0, 150 + i*30, 0, 150 + i*30)
    ring.Position = UDim2.new(0.5, -75 - i*15, 0.5, -75 - i*15)
    ring.BackgroundColor3 = Color3.new(1,1,1)
    ring.BackgroundTransparency = 0.9
    ring.BorderSizePixel = 1
    ring.BorderColor3 = Color3.fromRGB(160, 80, 255)
    ring.Rotation = i * 45
    spawn(function()
        while ring and ring.Parent do
            ring.Rotation = ring.Rotation + 0.5
            task.wait()
        end
    end)
end

-- ==================== MAIN GUI ====================
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "NiveAOTR"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 720, 0, 400)
main.Position = UDim2.new(0.5, -360, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(15,10,30)
main.BorderSizePixel = 2
main.BorderColor3 = Color3.fromRGB(160,80,255)
main.Visible = Settings.MenuOpen
main.Active = true

-- появление без затемнения
main.BackgroundTransparency = 1
main.Position = UDim2.new(0.5, -360, 0.5, -150)
TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
    BackgroundTransparency = 0,
    Position = UDim2.new(0.5, -360, 0.5, -200)
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
titleBar.Size = UDim2.new(1, 0, 0, 24)
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

-- вкладки слева
local tabFrame = Instance.new("Frame", main)
tabFrame.Size = UDim2.new(0, 150, 1, -24)
tabFrame.Position = UDim2.new(0, 0, 0, 24)
tabFrame.BackgroundColor3 = Color3.fromRGB(10, 8, 20)
tabFrame.BorderSizePixel = 1
tabFrame.BorderColor3 = Color3.fromRGB(100, 50, 150)

local uiListLayout = Instance.new("UIListLayout", tabFrame)
uiListLayout.Padding = UDim.new(0, 4)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- контент справа
local contentArea = Instance.new("Frame", main)
contentArea.Size = UDim2.new(1, -154, 1, -24)
contentArea.Position = UDim2.new(0, 154, 0, 24)
contentArea.BackgroundTransparency = 1

local tabNames = {"Farm", "Combat", "Visual", "Movement", "Defense", "Teleport", "Nive", "Settings", "Credits"}
local tabBtns = {}
local contents = {}

for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton", tabFrame)
    btn.Size = UDim2.new(1, -8, 0, 30)
    btn.Text = name
    btn.BackgroundColor3 = i == 1 and Color3.fromRGB(100, 50, 150) or Color3.fromRGB(30, 25, 50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(120,100,180)
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
        for _, b in ipairs(tabBtns) do b.BackgroundColor3 = Color3.fromRGB(30, 25, 50) end
        btn.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
        for _, c in ipairs(contents) do c.Visible = false end
        content.Visible = true
    end)
end

-- UI helpers
local function addToggle(content, text, key)
    local btn = Instance.new("TextButton", content)
    btn.Size = UDim2.new(1, -4, 0, 28)
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
    content.CanvasSize += UDim2.new(0,0,0,32)
end

local function addSlider(content, text, key, min, max)
    local frame = Instance.new("Frame", content)
    frame.Size = UDim2.new(1, -4, 0, 48)
    frame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 16)
    label.Text = text .. ": " .. Settings[key]
    label.TextColor3 = Color3.new(0.8,0.8,1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSans
    label.TextSize = 12
    local input = Instance.new("TextBox", frame)
    input.Size = UDim2.new(1, 0, 0, 22)
    input.Position = UDim2.new(0, 0, 0, 18)
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
    content.CanvasSize += UDim2.new(0,0,0,52)
end

local function addButton(content, text, callback)
    local btn = Instance.new("TextButton", content)
    btn.Size = UDim2.new(1, -4, 0, 28)
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
    content.CanvasSize += UDim2.new(0,0,0,32)
end

-- ==================== ЗАПОЛНЕНИЕ ВКЛАДОК ====================
-- Farm
addToggle(contents[1], "Auto Farm Titans", "AutoFarm")
addToggle(contents[1], "Auto Quests", "AutoQuest")
addToggle(contents[1], "Auto Boss", "AutoBoss")
addToggle(contents[1], "Infinite Gas", "InfiniteGas")
addToggle(contents[1], "Infinite Blades", "InfiniteBlades")
addToggle(contents[1], "5 Crits Per Hit", "FiveCrits")

-- Combat
addToggle(contents[2], "Kill Aura", "KillAura")
addToggle(contents[2], "Auto Skill", "AutoSkill")

-- Visual
addToggle(contents[3], "ESP", "ESP")
addSlider(contents[3], "Walk Speed", "Speed", 16, 200)
addToggle(contents[3], "NoClip", "NoClip")

-- Movement
addToggle(contents[4], "Flight", "Flight")
addToggle(contents[4], "Infinite Jump", "InfJump")

-- Defense
addToggle(contents[5], "God Mode", "GodMode")
addToggle(contents[5], "Anti-Ban", "AntiBan")
addSlider(contents[5], "Action Delay", "ActionDelay", 0.1, 2.0)

-- Teleport
addButton(contents[6], "Teleport to Titan", function()
    local root = getRoot() if not root then return end
    local nearest = findNearestTitan()
    if nearest then root.CFrame = CFrame.new(nearest.Position + Vector3.new(0,5,0)) end
end)
addButton(contents[6], "Teleport to Center", function()
    local root = getRoot() if root then root.CFrame = CFrame.new(0, 10, 0) end
end)

-- Nive
addToggle(contents[7], "Auto Load (All ON)", "AutoLoad")
addToggle(contents[7], "Auto Emote", "AutoEmote")
addSlider(contents[7], "Emote Interval", "EmoteInterval", 1, 10)
addButton(contents[7], "Set Hide Key", function()
    local conn
    conn = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.RightAlt or input.KeyCode == Enum.KeyCode.LeftAlt or
           input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.LeftControl then
            Settings.HideKey = input.KeyCode.Name
            conn:Disconnect()
        end
    end)
end)

-- Settings
addToggle(contents[8], "Auto Spin Family", "AutoSpinFamily")

-- Credits
local cred = Instance.new("TextLabel", contents[9])
cred.Size = UDim2.new(1, 0, 0, 80)
cred.Text = "Nive AOTR Ultimate\nCreated by Nive\nSupport: donationalerts.com/r/nive"
cred.TextColor3 = Color3.new(0.8,0.6,1)
cred.BackgroundTransparency = 1
cred.Font = Enum.Font.SourceSans
cred.TextSize = 13
cred.TextWrapped = true
contents[9].CanvasSize += UDim2.new(0,0,0,80)

-- ==================== TOGGLE MENU ====================
local function toggleMenu()
    Settings.MenuOpen = not Settings.MenuOpen
    if Settings.MenuOpen then
        main.Visible = true
        main.BackgroundTransparency = 1
        main.Position = UDim2.new(0.5, -360, 0.5, -150)
        TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            BackgroundTransparency = 0,
            Position = UDim2.new(0.5, -360, 0.5, -200)
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
            Position = UDim2.new(0.5, -360, 0.5, -150)
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

-- ==================== UTILITIES ====================
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

local function findNearestQuestGiver()
    local root = getRoot() if not root then return nil end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local part = obj.Parent
            if part:IsA("BasePart") then return part end
        end
    end
    return nil
end

local function findBoss()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name:lower():find("boss") or obj.Name:lower():find("beast")) and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
            local hrp = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
            if hrp then return hrp end
        end
    end
    return nil
end

-- ==================== FEATURE FUNCTIONS ====================
-- Auto Farm
local lastFarm = 0
local function autoFarm()
    if not Settings.AutoFarm then return end
    local root = getRoot() if not root then return end
    local nearest = findNearestTitan()
    if not nearest then return end
    if tick() - lastFarm < 0.5 then return end
    lastFarm = tick()
    if not canAct() then return end
    root.CFrame = CFrame.new(nearest.Position + Vector3.new(0,5,0))
    for i = 1, (Settings.FiveCrits and 5 or 1) do
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.02)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        if Settings.FiveCrits and i < 5 then task.wait(0.05) end
    end
end

-- Auto Quest
local lastQuest = 0
local function autoQuest()
    if not Settings.AutoQuest then return end
    if tick() - lastQuest < 3 then return end
    local npc = findNearestQuestGiver()
    if not npc then return end
    lastQuest = tick()
    if not canAct() then return end
    local root = getRoot() if not root then return end
    root.CFrame = CFrame.new(npc.Position + Vector3.new(0,3,0))
    task.wait(0.3)
    local prompt = npc:FindFirstChildWhichIsA("ProximityPrompt")
    if prompt then fireproximityprompt(prompt) end
    -- claim buttons
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

-- Auto Boss
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

-- Infinite Gas/Blades
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

-- Kill Aura (упрощённо)
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

-- Auto Skill (заглушка)
-- Flight
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

-- NoClip
local function noclip()
    if not Settings.NoClip then return end
    local char = LocalPlayer.Character if char then for _, v in ipairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
end

-- GodMode
local function godMode()
    if not Settings.GodMode then return end
    local char = LocalPlayer.Character if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if hum then hum.Health = hum.MaxHealth; hum.MaxHealth = 1e9; hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end
    for _, v in ipairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
end

-- ESP
local lastESP = 0
local function esp()
    if not Settings.ESP then return end
    if tick() - lastESP < 3 then return end
    lastESP = tick()
    for _, v in ipairs(Workspace:GetDescendants()) do
  
