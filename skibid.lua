-- Credit: Skibidi Bucu Messi
-- NYX HUB (Core GUI)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local parent = (gethui and gethui()) or LP:WaitForChild("PlayerGui")

local old = parent:FindFirstChild("SkibidiHubGui")
if old then old:Destroy() end

local THEME = {
    bg = Color3.fromRGB(15, 15, 18),
    surface = Color3.fromRGB(25, 25, 30),
    accent = Color3.fromRGB(138, 43, 226),
    text = Color3.fromRGB(255, 255, 255),
    text_dim = Color3.fromRGB(150, 150, 160),
    success = Color3.fromRGB(40, 200, 100),
    danger = Color3.fromRGB(220, 50, 50)
}

local screen = Instance.new("ScreenGui")
screen.Name = "SkibidiHubGui"
screen.ResetOnSpawn = false
screen.DisplayOrder = 999
screen.Parent = parent

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 400, 0, 300)
main.Position = UDim2.new(0.5, -200, 0.5, -150)
main.BackgroundColor3 = THEME.bg
main.BorderSizePixel = 0
main.Active = true
main.Parent = screen
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", main)
stroke.Color = THEME.accent
stroke.Thickness = 1.5

local dragging, dragInput, dragStart, startPos
main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundTransparency = 1
header.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 200, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Skibidi"
title.TextColor3 = THEME.text
title.TextSize = 18
title.Font = Enum.Font.GothamBlack
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subTitle = Instance.new("TextLabel")
subTitle.Size = UDim2.new(0, 100, 1, 0)
subTitle.Position = UDim2.new(1, -115, 0, 2)
subTitle.BackgroundTransparency = 1
subTitle.Text = "#thinh"
subTitle.TextColor3 = THEME.text_dim
subTitle.TextSize = 12
subTitle.Font = Enum.Font.Gotham
subTitle.TextXAlignment = Enum.TextXAlignment.Right
subTitle.Parent = header

local line = Instance.new("Frame")
line.Size = UDim2.new(1, -30, 0, 1)
line.Position = UDim2.new(0, 15, 0, 40)
line.BackgroundColor3 = THEME.surface
line.BorderSizePixel = 0
line.Parent = main

local tabMenu = Instance.new("Frame")
tabMenu.Size = UDim2.new(0, 90, 1, -55)
tabMenu.Position = UDim2.new(0, 10, 0, 45)
tabMenu.BackgroundTransparency = 1
tabMenu.Parent = main

local tabLayout = Instance.new("UIListLayout")
tabLayout.Padding = UDim.new(0, 4)
tabLayout.Parent = tabMenu

local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -110, 1, -55)
contentArea.Position = UDim2.new(0, 100, 0, 45)
contentArea.BackgroundTransparency = 1
contentArea.Parent = main

local tabs = {}
local currentTab = nil

local function createTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = THEME.surface
    btn.Text = name
    btn.TextColor3 = THEME.text_dim
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.Parent = tabMenu
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.Visible = false
    page.Parent = contentArea
    Instance.new("UIListLayout", page).Padding = UDim.new(0, 5)
    
    tabs[name] = page
    
    btn.MouseButton1Click:Connect(function()
        for n, p in pairs(tabs) do p.Visible = false end
        for _, c in ipairs(tabMenu:GetChildren()) do
            if c:IsA("TextButton") then
                c.BackgroundColor3 = THEME.surface
                c.TextColor3 = THEME.text_dim
            end
        end
        btn.BackgroundColor3 = THEME.accent
        btn.TextColor3 = THEME.text
        page.Visible = true
    end)
    
    if not currentTab then
        currentTab = btn
        btn.BackgroundColor3 = THEME.accent
        btn.TextColor3 = THEME.text
        page.Visible = true
    end
    
    return page
end

local FarmTab = createTab("Farm")
local CollectTab = createTab("Collect")
local TeleportTab = createTab("Teleport")
local MiscTab = createTab("Misc")

local function createToggle(page, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.BackgroundColor3 = THEME.surface
    frame.BorderSizePixel = 0
    frame.Parent = page
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = THEME.text
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 30, 0, 15)
    switch.Position = UDim2.new(1, -40, 0.5, -7)
    switch.BackgroundColor3 = default and THEME.success or THEME.surface
    switch.Text = ""
    switch.BorderSizePixel = 0
    switch.Parent = frame
    Instance.new("UICorner", switch).CornerRadius = UDim.new(0, 15)
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 13, 0, 13)
    circle.Position = default and UDim2.new(0, 15, 0, 1) or UDim2.new(0, 1, 0, 1)
    circle.BackgroundColor3 = THEME.text
    circle.Parent = switch
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    local state = default
    switch.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = state and THEME.success or THEME.surface}):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(0, 15, 0, 1) or UDim2.new(0, 1, 0, 1)}):Play()
        if callback then callback(state) end
    end)
end

local function createButton(page, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = THEME.surface
    btn.Text = text
    btn.TextColor3 = THEME.text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.Parent = page
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = THEME.accent}):Play()
        task.delay(0.2, function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = THEME.surface}):Play()
        end)
        if callback then callback() end
    end)
end

-- Hàm tạo Dropdown (Chọn vật phẩm)
local function createDropdown(page, text, options, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.BackgroundColor3 = THEME.surface
    frame.BorderSizePixel = 0
    frame.Parent = page
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -100, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = THEME.text
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    local selectBtn = Instance.new("TextButton")
    selectBtn.Size = UDim2.new(0, 70, 0, 24)
    selectBtn.Position = UDim2.new(1, -80, 0.5, -12)
    selectBtn.BackgroundColor3 = THEME.bg
    selectBtn.Text = default
    selectBtn.TextColor3 = THEME.text_dim
    selectBtn.Font = Enum.Font.Gotham
    selectBtn.TextSize = 11
    selectBtn.BorderSizePixel = 0
    selectBtn.Parent = frame
    Instance.new("UICorner", selectBtn).CornerRadius = UDim.new(0, 4)
    
    local dropFrame = Instance.new("Frame")
    dropFrame.Size = UDim2.new(0, 70, 0, #options * 24)
    dropFrame.Position = UDim2.new(1, -80, 1, 5)
    dropFrame.BackgroundColor3 = THEME.bg
    dropFrame.BorderSizePixel = 0
    dropFrame.Visible = false
    dropFrame.ZIndex = 10
    dropFrame.Parent = frame
    Instance.new("UICorner", dropFrame).CornerRadius = UDim.new(0, 4)
    
    local dropLayout = Instance.new("UIListLayout")
    dropLayout.Parent = dropFrame
    
    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 24)
        optBtn.BackgroundTransparency = 1
        optBtn.Text = opt
        optBtn.TextColor3 = THEME.text_dim
        optBtn.Font = Enum.Font.Gotham
        optBtn.TextSize = 11
        optBtn.ZIndex = 11
        optBtn.Parent = dropFrame
        
        optBtn.MouseButton1Click:Connect(function()
            selectBtn.Text = opt
            dropFrame.Visible = false
            if callback then callback(opt) end
        end)
    end
    
    selectBtn.MouseButton1Click:Connect(function()
        dropFrame.Visible = not dropFrame.Visible
    end)
end

-- ================== CHỨC NĂNG TAB FARM ==================
local BringEnabled = false
local BringMode = "Pallet"

local function getTargets(mode)
    local targets = {}
    local debris = workspace:FindFirstChild("DebrisField") or workspace
    local keywords = {}
    if mode == "Pallet" then keywords = {"pallet"}
    elseif mode == "Scrap" then keywords = {"anchor", "engine", "carbattery", "propellor", "metalbeam"} end
    
    for _, obj in ipairs(debris:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local n = obj.Name:lower()
            for _, k in ipairs(keywords) do if n:find(k) then table.insert(targets, obj); break end end
        end
    end
    return targets
end

local placed_count, current_idx = 0, 1
RunService.Heartbeat:Connect(function()
    if not BringEnabled then return end
    local targets = getTargets(BringMode)
    if #targets == 0 then return end
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local processed = 0
    while processed < 30 do
        if current_idx > #targets then current_idx = 1; placed_count = 0; break end
        local obj = targets[current_idx]
        if obj and obj.Parent then
            local primary = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
            if primary then
                local col, row = placed_count % 5, math.floor(placed_count / 5)
                local x_off, z_off = (col - 2.5 + 0.5) * 3, -5 - (row * 3)
                local target_cf = root.CFrame * CFrame.new(x_off, 0, z_off)
                
                if primary.Anchored then primary.Anchored = false end
                pcall(function() primary:SetNetworkOwner(LP) end)
                pcall(function() primary.CanCollide = false end)
                
                if obj:IsA("Model") then obj:PivotTo(target_cf) else primary.CFrame = target_cf end
                primary.AssemblyLinearVelocity = Vector3.zero
                primary.AssemblyAngularVelocity = Vector3.zero
                placed_count = placed_count + 1
            end
        end
        current_idx = current_idx + 1
        processed = processed + 1
    end
end)

createDropdown(FarmTab, "Select Object", {"Pallet", "Scrap"}, "Pallet", function(val)
    BringMode = val
    current_idx = 1
    placed_count = 0
end)

createToggle(FarmTab, "Bring Objects", false, function(state)
    BringEnabled = state
    if state then current_idx = 1; placed_count = 0 end
end)

-- Nút ẩn/hiện thu nhỏ
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 20, 0, 20)
closeBtn.Position = UDim2.new(1, -25, 0, 10)
closeBtn.BackgroundColor3 = THEME.danger
closeBtn.Text = "X"
closeBtn.TextColor3 = THEME.text
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.BorderSizePixel = 0
closeBtn.Parent = main
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
closeBtn.MouseButton1Click:Connect(function() screen:Destroy() end)
