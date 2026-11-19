-- lang: Luau | Roblox Universal | Synapse X / KRNL / Fluxus
-- ZXC v3: yatay GUI · G=tam kapat · silent aim · magic bullet · esp renk · fov dairesi

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput  = game:GetService("UserInputService")
local TweenSvc   = game:GetService("TweenService")
local Camera     = workspace.CurrentCamera

local lp = Players.LocalPlayer

-- ══════════════════════════════════════════════════════
-- AYARLAR
-- ══════════════════════════════════════════════════════
local Cfg = {
    -- ESP
    espEnabled   = false,
    espColor     = Color3.fromRGB(255, 50, 50),
    -- Aimbot
    aimbotOn     = false,
    aimbotFOV    = 150,
    aimbotSmooth = 0.18,
    aimbotPart   = "Head",   -- "Head" | "HumanoidRootPart"
    showFOV      = false,
    -- Silent Aim
    silentOn     = false,
    silentFOV    = 250,
    -- Magic Bullet (hitbox genişletme)
    magicOn      = false,
    magicSize    = 8,        -- studs
    -- Hareket
    flyOn        = false,
    flySpeed     = 60,
    noclipOn     = false,
    walkSpeed    = 16,
    jumpPower    = 50,
    infJump      = false,
    -- Combat
    killAura     = false,
    killRange    = 20,
}

local flyBody       = {}
local espHL         = {}   -- highlight tablosu
local prevFly       = false
local guiOpen       = true

local function getChar() return lp.Character end
local function getHRP()
    local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid")
end

lp.CharacterAdded:Connect(function()
    for _, h in pairs(espHL) do h:Destroy() end
    espHL = {}; prevFly = false; flyBody = {}
end)

-- ══════════════════════════════════════════════════════
-- SILENT AIM — RAYCAST HOOK
-- ══════════════════════════════════════════════════════
local function getSilentTarget()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local best, bd = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character then
            local part = plr.Character:FindFirstChild("Head") or
                         plr.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local sp, onScreen = Camera:WorldToScreenPoint(part.Position)
                if onScreen then
                    local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if d < Cfg.silentFOV and d < bd then bd = d; best = part end
                end
            end
        end
    end
    return best
end

local oldFPOR   = workspace.FindPartOnRay
local oldFPORWI = workspace.FindPartOnRayWithIgnoreList
local oldRaycast = workspace.Raycast

workspace.FindPartOnRay = function(self, ray, ignore, ...)
    if Cfg.silentOn then
        local t = getSilentTarget()
        if t then
            ray = Ray.new(ray.Origin, (t.Position - ray.Origin).Unit * ray.Direction.Magnitude)
        end
    end
    return oldFPOR(self, ray, ignore, ...)
end

workspace.FindPartOnRayWithIgnoreList = function(self, ray, ignoreList, ...)
    if Cfg.silentOn then
        local t = getSilentTarget()
        if t then
            ray = Ray.new(ray.Origin, (t.Position - ray.Origin).Unit * ray.Direction.Magnitude)
        end
    end
    return oldFPORWI(self, ray, ignoreList, ...)
end

workspace.Raycast = function(self, origin, direction, params)
    if Cfg.silentOn then
        local t = getSilentTarget()
        if t then
            direction = (t.Position - origin).Unit * direction.Magnitude
        end
    end
    return oldRaycast(self, origin, direction, params)
end

-- ══════════════════════════════════════════════════════
-- GUI — 590 × 318, yatay dikdörtgen
-- ══════════════════════════════════════════════════════
local W, H = 590, 318

local sg = Instance.new("ScreenGui")
sg.Name           = "ZXCv3"
sg.ResetOnSpawn   = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent         = game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Size              = UDim2.new(0, W, 0, H)
Main.Position          = UDim2.new(0.5, -W/2, 0.5, -H/2)
Main.BackgroundColor3  = Color3.fromRGB(12, 12, 18)
Main.BorderSizePixel   = 0
Main.ClipsDescendants  = true
Main.Parent            = sg

do  -- köşe + stroke
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,10); c.Parent = Main
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(85,55,195); s.Thickness = 1.2; s.Transparency = 0.35; s.Parent = Main
end

-- Başlık
local TBar = Instance.new("Frame")
TBar.Size             = UDim2.new(1,0,0,30)
TBar.BackgroundColor3 = Color3.fromRGB(85,55,195)
TBar.BorderSizePixel  = 0
TBar.Parent           = Main

do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,10); c.Parent = TBar
    local fix = Instance.new("Frame")   -- alt köşe düzeltici
    fix.Size = UDim2.new(1,0,0.5,0); fix.Position = UDim2.new(0,0,0.5,0)
    fix.BackgroundColor3 = Color3.fromRGB(85,55,195); fix.BorderSizePixel = 0; fix.Parent = TBar
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-12,1,0); lbl.Position = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency = 1; lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = "ZXC  ·  G = kapat / aç"; lbl.Parent = TBar
end

-- Sürükleme
local dragging, dragStart, dragBase
TBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = inp.Position; dragBase = Main.Position
    end
end)
TBar.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UserInput.InputChanged:Connect(function(inp)
    if dragging and inp.UserInputType == Enum.UserInputType.MouseMove then
        local d = inp.Position - dragStart
        Main.Position = UDim2.new(dragBase.X.Scale, dragBase.X.Offset + d.X,
                                   dragBase.Y.Scale, dragBase.Y.Offset + d.Y)
    end
end)

-- Sol Tab çubuğu (112px)
local TabBar = Instance.new("Frame")
TabBar.Size             = UDim2.new(0, 112, 1, -30)
TabBar.Position         = UDim2.new(0, 0, 0, 30)
TabBar.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
TabBar.BorderSizePixel  = 0
TabBar.Parent           = Main

do
    local ll = Instance.new("UIListLayout"); ll.Padding = UDim.new(0,3)
    ll.SortOrder = Enum.SortOrder.LayoutOrder; ll.Parent = TabBar
    local pp = Instance.new("UIPadding")
    pp.PaddingTop = UDim.new(0,10); pp.PaddingLeft = UDim.new(0,7); pp.PaddingRight = UDim.new(0,7)
    pp.Parent = TabBar
    local div = Instance.new("Frame")
    div.Size = UDim2.new(0,1,1,-30); div.Position = UDim2.new(0,112,0,30)
    div.BackgroundColor3 = Color3.fromRGB(38,38,60); div.BorderSizePixel = 0; div.Parent = Main
end

-- Sağ içerik alanı
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1,-113,1,-30)
ContentArea.Position = UDim2.new(0,113,0,30)
ContentArea.BackgroundTransparency = 1
ContentArea.ClipsDescendants = true
ContentArea.Parent = Main

-- ══════════════════════════════════════════════════════
-- UI YARDIMCILARI
-- ══════════════════════════════════════════════════════
local function newSF()   -- scrolling frame (tab içeriği)
    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1,0,1,0); sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0; sf.ScrollBarThickness = 3
    sf.ScrollBarImageColor3 = Color3.fromRGB(85,55,195)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.CanvasSize = UDim2.new(0,0,0,0); sf.Visible = false; sf.Parent = ContentArea
    local ll = Instance.new("UIListLayout"); ll.Padding = UDim.new(0,5)
    ll.SortOrder = Enum.SortOrder.LayoutOrder; ll.Parent = sf
    local pp = Instance.new("UIPadding")
    pp.PaddingTop = UDim.new(0,10); pp.PaddingLeft = UDim.new(0,10); pp.PaddingRight = UDim.new(0,14)
    pp.Parent = sf
    return sf
end

local function mkHead(p, txt)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,0,0,13); l.BackgroundTransparency = 1
    l.TextColor3 = Color3.fromRGB(85,55,195); l.Font = Enum.Font.GothamBold
    l.TextSize = 10; l.TextXAlignment = Enum.TextXAlignment.Left
    l.Text = txt:upper(); l.Parent = p; return l
end

local function mkToggle(p, label, getS, setS)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,0,0,30); row.BackgroundColor3 = Color3.fromRGB(19,19,29)
    row.BorderSizePixel = 0; row.Parent = p
    local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0,6); rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-52,1,0); lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1; lbl.TextColor3 = Color3.fromRGB(205,205,205)
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = label; lbl.Parent = row

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0,36,0,18); pill.Position = UDim2.new(1,-44,0.5,-9)
    pill.BackgroundColor3 = Color3.fromRGB(42,42,62); pill.BorderSizePixel = 0; pill.Parent = row
    local pc = Instance.new("UICorner"); pc.CornerRadius = UDim.new(1,0); pc.Parent = pill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,14,0,14); knob.Position = UDim2.new(0,2,0.5,-7)
    knob.BackgroundColor3 = Color3.fromRGB(165,165,165); knob.BorderSizePixel = 0; knob.Parent = pill
    local kc = Instance.new("UICorner"); kc.CornerRadius = UDim.new(1,0); kc.Parent = knob

    local function refresh()
        local on = getS()
        TweenSvc:Create(pill, TweenInfo.new(0.13), {
            BackgroundColor3 = on and Color3.fromRGB(85,55,195) or Color3.fromRGB(42,42,62)
        }):Play()
        TweenSvc:Create(knob, TweenInfo.new(0.13), {
            Position = on and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7),
            BackgroundColor3 = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(165,165,165)
        }):Play()
    end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.Parent = row
    btn.MouseButton1Click:Connect(function() setS(not getS()); refresh() end)
    refresh(); return row
end

local function mkSlider(p, label, minV, maxV, defV, isFloat, cb)
    local con = Instance.new("Frame")
    con.Size = UDim2.new(1,0,0,48); con.BackgroundColor3 = Color3.fromRGB(19,19,29)
    con.BorderSizePixel = 0; con.Parent = p
    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0,6); cc.Parent = con

    local fmt = function(v) return isFloat and string.format("%.2f",v) or tostring(math.floor(v)) end

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-10,0,18); lbl.Position = UDim2.new(0,10,0,6)
    lbl.BackgroundTransparency = 1; lbl.TextColor3 = Color3.fromRGB(205,205,205)
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = label .. ":  " .. fmt(defV); lbl.Parent = con

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1,-20,0,5); track.Position = UDim2.new(0,10,0,33)
    track.BackgroundColor3 = Color3.fromRGB(36,36,56); track.BorderSizePixel = 0; track.Parent = con
    local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(1,0); tc.Parent = track

    local pct  = math.clamp((defV-minV)/(maxV-minV),0,1)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(pct,0,1,0); fill.BackgroundColor3 = Color3.fromRGB(85,55,195)
    fill.BorderSizePixel = 0; fill.Parent = track
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(1,0); fc.Parent = fill

    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0,13,0,13); handle.Position = UDim2.new(pct,-6,0.5,-6)
    handle.BackgroundColor3 = Color3.fromRGB(220,220,220); handle.BorderSizePixel = 0; handle.Parent = track
    local hc = Instance.new("UICorner"); hc.CornerRadius = UDim.new(1,0); hc.Parent = handle

    local hb = Instance.new("TextButton")
    hb.Size = UDim2.new(1,0,0,26); hb.Position = UDim2.new(0,0,0.5,-13)
    hb.BackgroundTransparency = 1; hb.Text = ""; hb.Parent = track

    local drag = false
    hb.MouseButton1Down:Connect(function() drag = true end)
    UserInput.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
    UserInput.InputChanged:Connect(function(i)
        if not drag or i.UserInputType ~= Enum.UserInputType.MouseMove then return end
        local t = math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local v = isFloat and (minV+t*(maxV-minV)) or math.floor(minV+t*(maxV-minV))
        fill.Size = UDim2.new(t,0,1,0); handle.Position = UDim2.new(t,-6,0.5,-6)
        lbl.Text = label .. ":  " .. fmt(v); cb(v)
    end)
    return con
end

local function mkButton(p, label, cb)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,30); btn.BackgroundColor3 = Color3.fromRGB(85,55,195)
    btn.TextColor3 = Color3.fromRGB(255,255,255); btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12; btn.Text = label; btn.BorderSizePixel = 0; btn.Parent = p
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0,6); bc.Parent = btn
    btn.MouseEnter:Connect(function()
        TweenSvc:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(105,75,225)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenSvc:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(85,55,195)}):Play()
    end)
    btn.MouseButton1Click:Connect(cb); return btn
end

-- ══════════════════════════════════════════════════════
-- TAB SİSTEMİ
-- ══════════════════════════════════════════════════════
local tabFrames, tabBtns, activeTab = {}, {}, nil

local function switchTab(name)
    for n, f in pairs(tabFrames) do f.Visible = (n == name) end
    for n, b in pairs(tabBtns) do
        if n == name then
            b.BackgroundTransparency = 0
            b.BackgroundColor3 = Color3.fromRGB(85,55,195)
            b.TextColor3 = Color3.fromRGB(255,255,255)
        else
            b.BackgroundTransparency = 1
            b.TextColor3 = Color3.fromRGB(130,130,150)
        end
    end
    activeTab = name
end

local function addTab(name, icon)
    local sf = newSF(); tabFrames[name] = sf

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,34); btn.BackgroundTransparency = 1
    btn.TextColor3 = Color3.fromRGB(130,130,150); btn.Font = Enum.Font.Gotham
    btn.TextSize = 12; btn.Text = icon .. "  " .. name
    btn.TextXAlignment = Enum.TextXAlignment.Left; btn.BorderSizePixel = 0; btn.Parent = TabBar
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0,6); bc.Parent = btn
    tabBtns[name] = btn

    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    btn.MouseEnter:Connect(function()
        if activeTab ~= name then
            TweenSvc:Create(btn,TweenInfo.new(0.1),{
                BackgroundTransparency = 0.8,
                BackgroundColor3 = Color3.fromRGB(85,55,195)
            }):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if activeTab ~= name then
            TweenSvc:Create(btn,TweenInfo.new(0.1),{BackgroundTransparency=1}):Play()
        end
    end)
    return sf
end

-- ══════════════════════════════════════════════════════
-- ─── ESP TAB ──────────────────────────────────────────
-- ══════════════════════════════════════════════════════
local espTab = addTab("ESP", "👁")
mkHead(espTab, "görünürlük")
mkToggle(espTab, "ESP  (Duvardan Görme)", function() return Cfg.espEnabled end,
    function(v) Cfg.espEnabled = v end)

-- Renk paleti
local colorRow = Instance.new("Frame")
colorRow.Size = UDim2.new(1,0,0,38); colorRow.BackgroundColor3 = Color3.fromRGB(19,19,29)
colorRow.BorderSizePixel = 0; colorRow.Parent = espTab
local crc = Instance.new("UICorner"); crc.CornerRadius = UDim.new(0,6); crc.Parent = colorRow

local clbl = Instance.new("TextLabel")
clbl.Size = UDim2.new(0,64,1,0); clbl.Position = UDim2.new(0,10,0,0)
clbl.BackgroundTransparency = 1; clbl.TextColor3 = Color3.fromRGB(205,205,205)
clbl.Font = Enum.Font.Gotham; clbl.TextSize = 11; clbl.TextXAlignment = Enum.TextXAlignment.Left
clbl.Text = "ESP Renk"; clbl.Parent = colorRow

local palette = {
    Color3.fromRGB(255,50,50),   Color3.fromRGB(50,230,100),
    Color3.fromRGB(50,140,255),  Color3.fromRGB(255,215,45),
    Color3.fromRGB(255,255,255), Color3.fromRGB(180,50,255),
    Color3.fromRGB(255,120,30),  Color3.fromRGB(255,80,180),
}

local selDot = nil
for i, c in ipairs(palette) do
    local dot = Instance.new("TextButton")
    dot.Size = UDim2.new(0,19,0,19); dot.Position = UDim2.new(0, 76+(i-1)*25, 0.5, -9)
    dot.BackgroundColor3 = c; dot.Text = ""; dot.BorderSizePixel = 2
    dot.BorderColor3 = Color3.fromRGB(0,0,0); dot.Parent = colorRow
    local dc = Instance.new("UICorner"); dc.CornerRadius = UDim.new(1,0); dc.Parent = dot
    local cc = c
    dot.MouseButton1Click:Connect(function()
        Cfg.espColor = cc
        for _, h in pairs(espHL) do h.FillColor = cc; h.OutlineColor = cc end
        if selDot then selDot.BorderColor3 = Color3.fromRGB(0,0,0) end
        dot.BorderColor3 = Color3.fromRGB(255,255,255); selDot = dot
    end)
end

-- ══════════════════════════════════════════════════════
-- ─── AİMBOT TAB ───────────────────────────────────────
-- ══════════════════════════════════════════════════════
local aimTab = addTab("Aimbot", "🎯")

mkHead(aimTab, "görsel aimbot  (sağ tık)")
mkToggle(aimTab, "Aimbot", function() return Cfg.aimbotOn end,
    function(v) Cfg.aimbotOn = v end)
mkToggle(aimTab, "FOV Dairesi", function() return Cfg.showFOV end,
    function(v) Cfg.showFOV = v end)
mkSlider(aimTab, "FOV Yarıçapı", 30, 500, Cfg.aimbotFOV, false, function(v)
    Cfg.aimbotFOV = v
end)
mkSlider(aimTab, "Smooth  (düşük = hızlı)", 0.02, 0.6, Cfg.aimbotSmooth, true, function(v)
    Cfg.aimbotSmooth = v
end)

-- Hedef part seçimi
local partRow = Instance.new("Frame")
partRow.Size = UDim2.new(1,0,0,30); partRow.BackgroundColor3 = Color3.fromRGB(19,19,29)
partRow.BorderSizePixel = 0; partRow.Parent = aimTab
local prc = Instance.new("UICorner"); prc.CornerRadius = UDim.new(0,6); prc.Parent = partRow

local partLbl = Instance.new("TextLabel")
partLbl.Size = UDim2.new(0.5,0,1,0); partLbl.Position = UDim2.new(0,10,0,0)
partLbl.BackgroundTransparency = 1; partLbl.TextColor3 = Color3.fromRGB(205,205,205)
partLbl.Font = Enum.Font.Gotham; partLbl.TextSize = 12; partLbl.TextXAlignment = Enum.TextXAlignment.Left
partLbl.Text = "Hedef:  Head"; partLbl.Parent = partRow

local function mkPartBtn(label, xOff, part)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0,72,0,20); b.Position = UDim2.new(1, xOff, 0.5, -10)
    b.BackgroundColor3 = part == Cfg.aimbotPart and Color3.fromRGB(85,55,195) or Color3.fromRGB(38,38,58)
    b.TextColor3 = Color3.fromRGB(255,255,255); b.Font = Enum.Font.GothamBold
    b.TextSize = 10; b.Text = label; b.BorderSizePixel = 0; b.Parent = partRow
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0,4); bc.Parent = b
    return b
end

local headBtn  = mkPartBtn("Head",   -156, "Head")
local torsoBtn = mkPartBtn("Torso",  -78,  "HumanoidRootPart")

headBtn.MouseButton1Click:Connect(function()
    Cfg.aimbotPart = "Head"; partLbl.Text = "Hedef:  Head"
    headBtn.BackgroundColor3  = Color3.fromRGB(85,55,195)
    torsoBtn.BackgroundColor3 = Color3.fromRGB(38,38,58)
end)
torsoBtn.MouseButton1Click:Connect(function()
    Cfg.aimbotPart = "HumanoidRootPart"; partLbl.Text = "Hedef:  Torso"
    torsoBtn.BackgroundColor3 = Color3.fromRGB(85,55,195)
    headBtn.BackgroundColor3  = Color3.fromRGB(38,38,58)
end)

mkHead(aimTab, "silent aim  (görünmez kilitlenme)")
mkToggle(aimTab, "Silent Aim  (raycast yönlendirme)", function() return Cfg.silentOn end,
    function(v) Cfg.silentOn = v end)
mkSlider(aimTab, "Silent FOV", 30, 600, Cfg.silentFOV, false, function(v)
    Cfg.silentFOV = v
end)

mkHead(aimTab, "magic bullet  (hitbox genişlet)")
mkToggle(aimTab, "Magic Bullet", function() return Cfg.magicOn end,
    function(v) Cfg.magicOn = v end)
mkSlider(aimTab, "Hitbox Boyutu (studs)", 2, 30, Cfg.magicSize, false, function(v)
    Cfg.magicSize = v
end)

-- ══════════════════════════════════════════════════════
-- ─── HAREKET TAB ──────────────────────────────────────
-- ══════════════════════════════════════════════════════
local moveTab = addTab("Hareket", "🏃")
mkHead(moveTab, "fly")
mkToggle(moveTab, "Fly  (W/A/S/D · Space · Shift)", function() return Cfg.flyOn end,
    function(v) Cfg.flyOn = v end)
mkSlider(moveTab, "Fly Hızı", 20, 300, Cfg.flySpeed, false, function(v) Cfg.flySpeed = v end)
mkHead(moveTab, "zemin")
mkToggle(moveTab, "Noclip", function() return Cfg.noclipOn end, function(v) Cfg.noclipOn = v end)
mkToggle(moveTab, "Sonsuz Zıplama", function() return Cfg.infJump end, function(v) Cfg.infJump = v end)
mkSlider(moveTab, "WalkSpeed", 16, 500, Cfg.walkSpeed, false, function(v)
    Cfg.walkSpeed = v; local h = getHum(); if h then h.WalkSpeed = v end
end)
mkSlider(moveTab, "JumpPower", 7, 300, Cfg.jumpPower, false, function(v)
    Cfg.jumpPower = v; local h = getHum(); if h then h.JumpPower = v end
end)

-- ══════════════════════════════════════════════════════
-- ─── OYUNCULAR TAB ────────────────────────────────────
-- ══════════════════════════════════════════════════════
local playTab = addTab("Oyuncular", "👥")
mkHead(playTab, "kill aura")
mkToggle(playTab, "Kill Aura", function() return Cfg.killAura end, function(v) Cfg.killAura = v end)
mkSlider(playTab, "Kill Range (studs)", 5, 100, Cfg.killRange, false, function(v) Cfg.killRange = v end)

mkHead(playTab, "toplu tp")
mkButton(playTab, "⬇  Herkesi Yanıma Çek", function()
    local hrp = getHRP(); if not hrp then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character then
            local ehr = plr.Character:FindFirstChild("HumanoidRootPart")
            if ehr then ehr.CFrame = hrp.CFrame + Vector3.new(math.random(-5,5),0,math.random(-5,5)) end
        end
    end
end)
mkButton(playTab, "🎲  Rastgele Birine TP", function()
    local pool = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(pool, plr)
        end
    end
    if #pool == 0 then return end
    local t = pool[math.random(1,#pool)]
    local hrp = getHRP()
    if hrp then hrp.CFrame = t.Character.HumanoidRootPart.CFrame + Vector3.new(2,0,0) end
end)

mkHead(playTab, "liste")

local plHolder = Instance.new("Frame")
plHolder.Size = UDim2.new(1,0,0,0); plHolder.AutomaticSize = Enum.AutomaticSize.Y
plHolder.BackgroundTransparency = 1; plHolder.Parent = playTab
local pll = Instance.new("UIListLayout"); pll.Padding = UDim.new(0,4)
pll.SortOrder = Enum.SortOrder.LayoutOrder; pll.Parent = plHolder

local function refreshList()
    for _, c in ipairs(plHolder:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp then
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1,0,0,28); row.BackgroundColor3 = Color3.fromRGB(19,19,29)
            row.BorderSizePixel = 0; row.Parent = plHolder
            local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0,5); rc.Parent = row

            local nl = Instance.new("TextLabel")
            nl.Size = UDim2.new(1,-68,1,0); nl.Position = UDim2.new(0,8,0,0)
            nl.BackgroundTransparency = 1; nl.TextColor3 = Color3.fromRGB(205,205,205)
            nl.Font = Enum.Font.Gotham; nl.TextSize = 11; nl.TextXAlignment = Enum.TextXAlignment.Left
            nl.Text = plr.DisplayName .. "  (@" .. plr.Name .. ")"
            nl.TextTruncate = Enum.TextTruncate.AtEnd; nl.Parent = row

            local tb = Instance.new("TextButton")
            tb.Size = UDim2.new(0,56,0,20); tb.Position = UDim2.new(1,-62,0.5,-10)
            tb.BackgroundColor3 = Color3.fromRGB(85,55,195); tb.TextColor3 = Color3.fromRGB(255,255,255)
            tb.Font = Enum.Font.GothamBold; tb.TextSize = 10; tb.Text = "TP Git"
            tb.BorderSizePixel = 0; tb.Parent = row
            local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(0,4); tc.Parent = tb

            local cp = plr
            tb.MouseButton1Click:Connect(function()
                local hrp = getHRP()
                if hrp and cp.Character and cp.Character:FindFirstChild("HumanoidRootPart") then
                    hrp.CFrame = cp.Character.HumanoidRootPart.CFrame + Vector3.new(2,0,0)
                end
            end)
        end
    end
end

mkButton(playTab, "🔄  Yenile", function() refreshList() end)
refreshList()

switchTab("ESP")

-- ══════════════════════════════════════════════════════
-- G TUŞU — SMOOTH SLIDE KAPATMA (arka plan koşmaya devam)
-- ══════════════════════════════════════════════════════
local openPosY  = Main.Position.Y.Offset
local closePosY = openPosY + H + 60

UserInput.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode ~= Enum.KeyCode.G then return end
    guiOpen = not guiOpen
    if guiOpen then
        Main.Visible = true
        TweenSvc:Create(Main, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(Main.Position.X.Scale, Main.Position.X.Offset,
                                 Main.Position.Y.Scale, openPosY)
        }):Play()
    else
        local tw = TweenSvc:Create(Main, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(Main.Position.X.Scale, Main.Position.X.Offset,
                                 Main.Position.Y.Scale, closePosY)
        })
        tw:Play()
        tw.Completed:Connect(function() Main.Visible = false end)
    end
end)

-- ══════════════════════════════════════════════════════
-- FOV DAİRESİ
-- ══════════════════════════════════════════════════════
local fovCircle = nil
pcall(function()
    fovCircle = Drawing.new("Circle")
    fovCircle.Visible = false; fovCircle.Thickness = 1.4
    fovCircle.Color = Color3.fromRGB(220,220,220)
    fovCircle.Filled = false; fovCircle.NumSides = 64
end)

-- ══════════════════════════════════════════════════════
-- FLY
-- ══════════════════════════════════════════════════════
local function enableFly()
    local hrp = getHRP(); if not hrp then return end
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.zero; bv.MaxForce = Vector3.new(1e5,1e5,1e5); bv.Parent = hrp
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e5,1e5,1e5); bg.D = 50; bg.Parent = hrp
    flyBody = {bv=bv,bg=bg}
    local h = getHum(); if h then h.PlatformStand = true end
end

local function disableFly()
    if flyBody.bv then flyBody.bv:Destroy() end
    if flyBody.bg then flyBody.bg:Destroy() end
    flyBody = {}
    local h = getHum(); if h then h.PlatformStand = false end
end

-- ══════════════════════════════════════════════════════
-- ESP
-- ══════════════════════════════════════════════════════
local function updateESP()
    for pid, h in pairs(espHL) do
        local plr = Players:GetPlayerByUserId(pid)
        if not plr or not plr.Character or not Cfg.espEnabled then
            h:Destroy(); espHL[pid] = nil
        end
    end
    if not Cfg.espEnabled then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character then
            if not espHL[plr.UserId] then
                local h = Instance.new("Highlight")
                h.FillColor = Cfg.espColor; h.OutlineColor = Cfg.espColor
                h.FillTransparency = 0.65; h.OutlineTransparency = 0
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.Adornee = plr.Character; h.Parent = workspace
                espHL[plr.UserId] = h
            else
                espHL[plr.UserId].FillColor    = Cfg.espColor
                espHL[plr.UserId].OutlineColor = Cfg.espColor
            end
        end
    end
end

-- ══════════════════════════════════════════════════════
-- AİMBOT — HEDEF
-- ══════════════════════════════════════════════════════
local function getAimbotTarget()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local best, bd = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character then
            local part = plr.Character:FindFirstChild(Cfg.aimbotPart)
            if part then
                local sp, onScreen = Camera:WorldToScreenPoint(part.Position)
                if onScreen then
                    local d = (Vector2.new(sp.X,sp.Y) - center).Magnitude
                    if d < Cfg.aimbotFOV and d < bd then bd=d; best=part end
                end
            end
        end
    end
    return best
end

-- ══════════════════════════════════════════════════════
-- SONSUZ ZIPLAMAMA
-- ══════════════════════════════════════════════════════
UserInput.JumpRequest:Connect(function()
    if Cfg.infJump then
        local h = getHum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ══════════════════════════════════════════════════════
-- RENDERSTEPPED
-- ══════════════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    updateESP()

    -- Fly toggle
    if Cfg.flyOn ~= prevFly then
        if Cfg.flyOn then enableFly() else disableFly() end
        prevFly = Cfg.flyOn
    end

    -- Fly hareket
    if Cfg.flyOn and flyBody.bv and flyBody.bg then
        local cf = Camera.CFrame; local dir = Vector3.zero
        if UserInput:IsKeyDown(Enum.KeyCode.W)         then dir += cf.LookVector  end
        if UserInput:IsKeyDown(Enum.KeyCode.S)         then dir -= cf.LookVector  end
        if UserInput:IsKeyDown(Enum.KeyCode.A)         then dir -= cf.RightVector end
        if UserInput:IsKeyDown(Enum.KeyCode.D)         then dir += cf.RightVector end
        if UserInput:IsKeyDown(Enum.KeyCode.Space)     then dir += Vector3.yAxis  end
        if UserInput:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis  end
        flyBody.bv.Velocity = dir.Magnitude > 0 and dir.Unit * Cfg.flySpeed or Vector3.zero
        flyBody.bg.CFrame   = cf
    end

    -- Noclip
    if Cfg.noclipOn then
        local c = getChar()
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end

    -- Görsel Aimbot
    if Cfg.aimbotOn and UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = getAimbotTarget()
        if t then
            Camera.CFrame = Camera.CFrame:Lerp(
                CFrame.lookAt(Camera.CFrame.Position, t.Position), Cfg.aimbotSmooth
            )
        end
    end

    -- Magic Bullet — hitbox genişlet
    if Cfg.magicOn then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local s = Cfg.magicSize
                    if hrp.Size.X ~= s then
                        hrp.Size = Vector3.new(s, s, s)
                    end
                end
            end
        end
    end

    -- FOV dairesi güncelle
    if fovCircle then
        local showIt = Cfg.showFOV and Cfg.aimbotOn
        fovCircle.Visible  = showIt
        fovCircle.Radius   = Cfg.aimbotFOV
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    end
end)

-- ══════════════════════════════════════════════════════
-- STEPPED
-- ══════════════════════════════════════════════════════
RunService.Stepped:Connect(function()
    local h = getHum()
    if h and not Cfg.flyOn then
        h.WalkSpeed = Cfg.walkSpeed
        h.JumpPower = Cfg.jumpPower
    end

    if Cfg.killAura then
        local hrp = getHRP(); if not hrp then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and plr.Character then
                local ehr = plr.Character:FindFirstChild("HumanoidRootPart")
                if ehr and (ehr.Position-hrp.Position).Magnitude <= Cfg.killRange then
                    local orig = hrp.CFrame
                    hrp.CFrame = ehr.CFrame; task.wait(); hrp.CFrame = orig
                end
            end
        end
    end
end)

print("[ZXC v3]  G = kapat/aç")
