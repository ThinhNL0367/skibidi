-- Credit: Skibidi Bucu Messi
-- AppleLibrary Build (Updated Teleports & Rescues)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

-- Load Library
local ok, library = pcall(function()
    return loadstring(game:HttpGet("https://github.com/GoHamza/AppleLibrary/blob/main/main.lua?raw=true"))()
end)

if not ok or not library then
    return warn("[NYX] Không thể tải thư viện UI!")
end

local window = library:init("Skibidi Hub", true, Enum.KeyCode.RightShift, true)

local TOGGLES = {
    BringEnabled = false,
    BringGoo = false,
    InfAmmo = false,
    FireRate = false,
    InfHeal = false,
    KillAura = false,
    AutoStore = false,
    AutoDrop = false,
    TweenAround = false
}

local CONFIG = {
    KillAura_ID = 1037501, 
    KillAura_Range = 1000,
    KillAura_Delay = 0.03,
    Store_Delay = 0.1,
    Drop_Delay = 0.1,
    StoreMode = "Pallet",
    BringMode = "Pallet",
    BagID = 6763635,
    Drop_ID = 2992966,
    Drop_Pos = Vector3.new(275, 156, -246),
    Tween_Speed = 50
}

local StoreKeywords = {
    Pallet = {"pallet"},
    Scrap = {"scrap", "anchor", "engine", "carbattery", "propellor", "metalbeam"}
}

-- ================== AUTO-SCAN NETWORK ==================
local function getNetworkEvent()
    for _, service in ipairs(game:GetChildren()) do
        local re = service:FindFirstChild("RemoteEvent")
        if re and re:IsA("RemoteEvent") then return re end
    end
    return nil
end

local function getNetworkFunction()
    for _, service in ipairs(game:GetChildren()) do
        local rf = service:FindFirstChild("RemoteFunction")
        if rf and rf:IsA("RemoteFunction") then return rf end
    end
    return nil
end

local function getHiddenObject(keyword)
    if not getnilinstances then return nil end
    for _, obj in pairs(getnilinstances()) do
        if obj.Name:lower():find(keyword) then return obj end
    end
    return nil
end

-- Hàm hỗ trợ
local function fireNearbyPrompts(count)
    for i = 1, count do
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Enabled then
                    local part = obj.Parent
                    if part and part:IsA("BasePart") then
                        if (part.Position - root.Position).Magnitude <= 25 then
                            obj.HoldDuration = 0
                            fireproximityprompt(obj)
                        end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end

local function doTeleportAndPrompt(pos, waitTime, promptCount)
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    root.CFrame = CFrame.new(pos)
    task.wait(waitTime)
    fireNearbyPrompts(promptCount)
end

-- ================== LOGIC ==================
-- Bring Logic (Pallet/Scrap)
local function getTargets(mode)
    local targets = {}
    local debris = workspace:FindFirstChild("DebrisField") or workspace
    local keywords = StoreKeywords[mode]
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
    if not TOGGLES.BringEnabled then return end
    local targets = getTargets(CONFIG.BringMode)
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

-- Bring Goo Logic (Dummy/Ragdoll)
local goo_idx, goo_placed = 1, 0
RunService.Heartbeat:Connect(function()
    if not TOGGLES.BringGoo then return end
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local targets = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:find("goo") or n:find("dummy") or n:find("ragdoll") then
                table.insert(targets, obj)
            end
        end
    end

    if #targets == 0 then return end

    local processed = 0
    while processed < 30 do
        if goo_idx > #targets then goo_idx = 1; goo_placed = 0; break end
        local obj = targets[goo_idx]
        if obj and obj.Parent then
            local primary = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
            if primary then
                local col, row = goo_placed % 5, math.floor(goo_placed / 5)
                local x_off, z_off = (col - 2.5 + 0.5) * 3, -5 - (row * 3)
                local target_cf = root.CFrame * CFrame.new(x_off, 0, z_off)
                if primary.Anchored then primary.Anchored = false end
                pcall(function() primary:SetNetworkOwner(LP) end)
                pcall(function() primary.CanCollide = false end)
                if obj:IsA("Model") then obj:PivotTo(target_cf) else primary.CFrame = target_cf end
                primary.AssemblyLinearVelocity = Vector3.zero
                primary.AssemblyAngularVelocity = Vector3.zero
                goo_placed = goo_placed + 1
            end
        end
        goo_idx = goo_idx + 1
        processed = processed + 1
    end
end)

-- Auto Store Logic
task.spawn(function()
    while task.wait(CONFIG.Store_Delay) do
        if not TOGGLES.AutoStore then continue end
        local net_event = getNetworkEvent()
        if not net_event then continue end
        local target_obj = nil
        local keywords = StoreKeywords[CONFIG.StoreMode]
        for _, obj in ipairs(workspace:GetDescendants()) do
            if (obj:IsA("Model") or obj:IsA("BasePart")) then
                local n = obj.Name:lower()
                for _, k in ipairs(keywords) do if n:find(k) then target_obj = obj; break end end
            end
            if target_obj then break end
        end
        if not target_obj and getnilinstances then
            for _, k in ipairs(keywords) do
                target_obj = getHiddenObject(k)
                if target_obj then break end
            end
        end
        if target_obj then
            pcall(function() net_event:FireServer(CONFIG.BagID, "StoreItem", target_obj) end)
        end
    end
end)

-- Auto Drop Logic
task.spawn(function()
    while task.wait(CONFIG.Drop_Delay) do
        if not TOGGLES.AutoDrop then continue end
        local net_event = getNetworkEvent()
        if not net_event then continue end
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        local dist = (root.Position - CONFIG.Drop_Pos).Magnitude
        if dist > 5 then
            root.CFrame = CFrame.new(CONFIG.Drop_Pos)
            task.wait(0.2)
        end
        pcall(function() net_event:FireServer(CONFIG.Drop_ID, "DropItem") end)
    end
end)

-- ================== KILL AURA LOGIC ==================
task.spawn(function()
    while task.wait(CONFIG.KillAura_Delay) do
        if not TOGGLES.KillAura then continue end
        local net_func = getNetworkFunction()
        if not net_func then continue end
        
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        
        local sniper = char:FindFirstChild("Sniper Rifle")
        if not sniper then continue end
        local handle = sniper:FindFirstChild("Handle")
        if not handle then continue end
        
        local container = workspace:FindFirstChild("CreatureContainer") or workspace
        local nearest = nil
        local min_dist = CONFIG.KillAura_Range
        
        for _, obj in ipairs(container:GetChildren()) do
            if obj:IsA("Model") then
                if not string.find(obj.Name, "_CLIENT") then
                    local hrp = obj:FindFirstChild("HumanoidRootPart") 
                             or obj:FindFirstChild("RootPart") 
                             or obj.PrimaryPart
                             or obj:FindFirstChildWhichIsA("BasePart")
                    
                    if hrp then
                        local isAlive = true
                        local hum = obj:FindFirstChildOfClass("Humanoid")
                        if hum then
                            isAlive = hum.Health > 0
                        else
                            local healthVal = obj:FindFirstChild("Health") or obj:FindFirstChild("HP")
                            if healthVal and (healthVal:IsA("NumberValue") or healthVal:IsA("IntValue")) then
                                isAlive = healthVal.Value > 0
                            end
                        end
                        
                        if isAlive then
                            local d = (root.Position - hrp.Position).Magnitude
                            if d < min_dist then 
                                min_dist = d
                                nearest = hrp 
                            end
                        end
                    end
                end
            end
        end
        
        if nearest then
            local t_pos = nearest.Position
            local dir = (t_pos - root.Position).Unit
            local v_str = string.format("~t{1=~f%.4f,%.4f,%.4f:%.4f,%.4f,%.4fZ-1}", t_pos.X, t_pos.Y, t_pos.Z, dir.X, dir.Y, dir.Z)
            task.spawn(function()
                pcall(function() net_func:InvokeServer(CONFIG.KillAura_ID, "ToolReplicator", "~sGun", "~sShoot", handle, v_str) end)
            end)
        end
    end
end)

-- ================== TWEEN AROUND LOGIC ==================
local tweenAngle = 0
local tweenRadius = 0
local tweenCenter = nil
local heartbeatConn = nil

local function startTween()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    tweenCenter = root.CFrame
    tweenAngle = 0
    tweenRadius = 0
    
    workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
    root.Anchored = true
    if char:FindFirstChild("Humanoid") then char.Humanoid.PlatformStand = true end
    
    if heartbeatConn then heartbeatConn:Disconnect() end
    heartbeatConn = RunService.Heartbeat:Connect(function(dt)
        if not TOGGLES.TweenAround then return end
        
        workspace.CurrentCamera.CFrame = CFrame.new(tweenCenter.Position + Vector3.new(0, 25, 0), tweenCenter.Position)
        
        if tweenRadius < 2000 then
            tweenRadius = tweenRadius + (CONFIG.Tween_Speed * dt)
            if tweenRadius > 2000 then tweenRadius = 2000 end
        end
        
        tweenAngle = tweenAngle + (2 * dt)
        
        local x = tweenCenter.Position.X + math.cos(tweenAngle) * tweenRadius
        local z = tweenCenter.Position.Z + math.sin(tweenAngle) * tweenRadius
        local targetPos = Vector3.new(x, tweenCenter.Position.Y, z)
        local lookDir = Vector3.new(math.cos(tweenAngle + math.pi/2), 0, math.sin(tweenAngle + math.pi/2))
        
        root.CFrame = CFrame.new(targetPos, targetPos + lookDir)
    end)
end

local function stopTween()
    if heartbeatConn then heartbeatConn:Disconnect(); heartbeatConn = nil end
    local char = LP.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if root and tweenCenter then root.CFrame = tweenCenter end
        if root then root.Anchored = false end
        if hum then hum.PlatformStand = false end
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        workspace.CurrentCamera.CameraSubject = hum
    end
end

-- Inf Ammo & Fire Rate
task.spawn(function()
    while task.wait(0.5) do
        if TOGGLES.InfAmmo then
            pcall(function()
                LP:SetAttribute("SniperAmmo", 9999)
                LP:SetAttribute("RifleAmmo", 9999)
                LP:SetAttribute("ShotgunAmmo", 9999)
                LP:SetAttribute("Ammo", 9999)
            end)
        end
    end
end)

task.spawn(function()
    task.wait(1)
    local success, GlobalAPI = pcall(function() return require(game.ReplicatedStorage.GlobalAPI) end)
    if success and GlobalAPI and GlobalAPI.RealWait then
        local oldRealWait = GlobalAPI.RealWait
        GlobalAPI.RealWait = newcclosure(function(t)
            if not TOGGLES.FireRate then return oldRealWait(t) end
            if t > 1 then return oldRealWait(0.05) end
            if t >= 0.2 and t <= 2 then return oldRealWait(0) end
            if t == 0.12 then return oldRealWait(0.02) end
            if t == 0.2 then return oldRealWait(0.02) end
            return oldRealWait(t)
        end)
    end
end)

-- Inf Heal
task.spawn(function()
    local mt = getrawmetatable(game)
    local old_namecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Activate" and self:IsA("Tool") and (self.Name == "Bandage" or self.Name == "Medkit") then
            return nil 
        end
        return old_namecall(self, ...)
    end)
    setreadonly(mt, true)
end)

task.spawn(function()
    while task.wait(0.1) do
        if TOGGLES.InfHeal then
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and hum.Health < hum.MaxHealth then
                local backpack = LP:FindFirstChild("Backpack")
                local bandage = char:FindFirstChild("Bandage") or (backpack and backpack:FindFirstChild("Bandage"))
                local medkit = char:FindFirstChild("Medkit") or (backpack and backpack:FindFirstChild("Medkit"))
                if bandage then
                    pcall(function() bandage:Activate() end)
                    if _G.ToolProcessor then pcall(function() _G.ToolProcessor("Bandage", "Heal") end) end
                elseif medkit then
                    pcall(function() medkit:Activate() end)
                    if _G.ToolProcessor then pcall(function() _G.ToolProcessor("Medkit", "Heal", char) end) end
                end
            end
        end
    end
end)

-- ================== UI SETUP ==================

-- FARM TAB
local farmSection = window:Section("Farm")

farmSection:Divider("Bring Objects")
farmSection:Select("Bring Type", {"Pallet", "Scrap"}, "Pallet", function(val)
    CONFIG.BringMode = val
    current_idx = 1; placed_count = 0
end)
farmSection:Switch("Bring Objects", false, function(val)
    TOGGLES.BringEnabled = val
    if val then current_idx = 1; placed_count = 0 end
end)

farmSection:Switch("Bring Goo", false, function(val)
    TOGGLES.BringGoo = val
    if val then goo_idx = 1; goo_placed = 0 end
end)

farmSection:Divider("Auto Store")
farmSection:Select("Store Type", {"Pallet", "Scrap"}, "Pallet", function(val)
    CONFIG.StoreMode = val
end)
farmSection:Switch("Auto Store (Vét Sạch)", false, function(val)
    TOGGLES.AutoStore = val
end)

farmSection:Divider("Auto Drop")
farmSection:Switch("Auto Drop (Bán Đồ)", false, function(val)
    TOGGLES.AutoDrop = val
end)

farmSection:Divider("Kill Aura")
farmSection:TextField("Gun ID (Lấy từ Cobalt)", tostring(CONFIG.KillAura_ID), function(val)
    CONFIG.KillAura_ID = tonumber(val) or CONFIG.KillAura_ID
end)
farmSection:Switch("Kill Aura (Cần Sniper)", false, function(val)
    TOGGLES.KillAura = val
end)

-- COLLECT TAB
local collectSection = window:Section("Collect")
collectSection:Divider("Auto Rescue")

collectSection:Button("Auto Rescue 1", function()
    task.spawn(function()
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local orig_pos = root.CFrame
        
        doTeleportAndPrompt(Vector3.new(1512, 236, -1285), 1, 2)
        
        task.wait(0.5) root.CFrame = orig_pos
    end)
end)

collectSection:Button("Auto Rescue 2", function()
    task.spawn(function()
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local orig_pos = root.CFrame
        
        doTeleportAndPrompt(Vector3.new(-322, 199, 3725), 1, 3)
        doTeleportAndPrompt(Vector3.new(-345, 185, 3658), 1, 9)
        doTeleportAndPrompt(Vector3.new(-308, 175, 3608), 1, 12)
        doTeleportAndPrompt(Vector3.new(-343, 167, 3584), 1, 2)
        
        task.wait(0.5) root.CFrame = orig_pos
    end)
end)

collectSection:Button("Auto Rescue 3", function()
    task.spawn(function()
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        doTeleportAndPrompt(Vector3.new(-2844, 158, -1131), 1, 1)
        doTeleportAndPrompt(Vector3.new(-2952, 192, -1210), 1, 1)
        doTeleportAndPrompt(Vector3.new(-2839, 157, -1290), 1, 1)
        
        task.wait(10) -- Đợi 10s
        
        doTeleportAndPrompt(Vector3.new(-2890, 199, -1210), 1, 2)
        
        -- TP về Base
        root.CFrame = CFrame.new(277, 162, -256)
    end)
end)

collectSection:Divider("Auto Stronghold")
collectSection:Switch("Auto Stronghold", false, function(state)
    if state then
        task.spawn(function()
            local char = LP.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local orig_pos = root.CFrame
            
            doTeleportAndPrompt(Vector3.new(-1018, 175, -321), 1.25, 1)
            doTeleportAndPrompt(Vector3.new(-229, 168, 2101), 1.25, 1)
            doTeleportAndPrompt(Vector3.new(3258, 198, -1965), 2, 1)
            
            task.wait(0.5) root.CFrame = orig_pos
        end)
    end
end)

-- SELF TAB
local selfSection = window:Section("Self")
selfSection:Switch("Inf Ammo", false, function(val) TOGGLES.InfAmmo = val end)
selfSection:Switch("Fire Rate", false, function(val) TOGGLES.FireRate = val end)
selfSection:Switch("Inf Heal", false, function(val) TOGGLES.InfHeal = val end)

selfSection:Divider("Tween Around")
selfSection:TextField("Tween Speed", tostring(CONFIG.Tween_Speed), function(val)
    CONFIG.Tween_Speed = tonumber(val) or CONFIG.Tween_Speed
end)
selfSection:Switch("Tween Around", false, function(val)
    TOGGLES.TweenAround = val
    if val then startTween() else stopTween() end
end)

selfSection:Divider("Auto Unlock Rigs")
selfSection:Switch("Auto Unlock Rigs", false, function(state)
    if state then
        task.spawn(function()
            local char = LP.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local orig_pos = root.CFrame
            
            doTeleportAndPrompt(Vector3.new(-331, 172, 566), 1.5, 1)
            doTeleportAndPrompt(Vector3.new(1861, 172, 121), 1.5, 1)
            doTeleportAndPrompt(Vector3.new(23, 172, -1436), 1.5, 1)
            
            task.wait(0.5) root.CFrame = orig_pos
        end)
    end
end)

-- TELEPORT TAB
local tpSection = window:Section("Teleport")

tpSection:Button("Ghost Galleon", function()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then root.CFrame = CFrame.new(4130, 359, -2165) end
end)

tpSection:Button("CargoShip", function()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then root.CFrame = CFrame.new(-1629, 233, 3042) end
end)

tpSection:Button("Base", function()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then root.CFrame = CFrame.new(277, 162, -256) end
end)

tpSection:Button("Rig1", function()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then root.CFrame = CFrame.new(-680, 179, -1225) end
end)
tpSection:Button("Rig2", function()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then root.CFrame = CFrame.new(2177, 206, -572) end
end)
tpSection:Button("Rig3", function()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then root.CFrame = CFrame.new(3428, 234, -3094) end
end)

window:TempNotify("Loaded!", "Skibidi Hub đã sẵn sàng.", "rbxassetid://12608259004")
