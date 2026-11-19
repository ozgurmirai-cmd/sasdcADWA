-- lang: Luau | Roblox Universal | Synapse X / KRNL / Fluxus
-- ZXC v5 — full fix: scroll, aimbot, fly, silent aim, esp, 8 toggle

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput  = game:GetService("UserInputService")
local TweenSvc   = game:GetService("TweenService")
local Camera     = workspace.CurrentCamera
local lp         = Players.LocalPlayer

local Cfg = {
    espOn      = false,  espColor  = Color3.fromRGB(255,50,50),
    aimbotOn   = false,  aimbotFOV = 150, aimbotSmooth = 0.18, aimbotPart = "Head",
    showFOV    = false,
    silentOn   = false,  silentFOV = 250,
    magicOn    = false,  magicSize = 8,
    flyOn      = false,  flySpeed  = 60,
    noclipOn   = false,
    walkSpeed  = 16,     jumpPower = 50,  infJump = false,
    killAura   = false,  killRange = 20,
}

local flyBody = {}
local espHL   = {}
local prevFly = false
local guiOpen = true

local function getChar() return lp.Character end
local function getHRP()  local c=getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c=getChar(); return c and c:FindFirstChildOfClass("Humanoid") end

lp.CharacterAdded:Connect(function()
    for _,h in pairs(espHL) do pcall(function() h:Destroy() end) end
    espHL={}; prevFly=false; flyBody={}
end)

-- ════════════════════════════════════════
-- SILENT AIM — her hook ayrı pcall
-- ════════════════════════════════════════
local function getSilentTarget()
    local cx = Camera.ViewportSize.X/2
    local cy = Camera.ViewportSize.Y/2
    local best,bd = nil,math.huge
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character then
            local part = plr.Character:FindFirstChild("Head")
                      or plr.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local ok,sp,vis = pcall(function()
                    return Camera:WorldToScreenPoint(part.Position)
                end)
                if ok and vis then
                    local d = math.sqrt((sp.X-cx)^2+(sp.Y-cy)^2)
                    if d < Cfg.silentFOV and d < bd then bd=d; best=part end
                end
            end
        end
    end
    return best
end

pcall(function()
    local o = workspace.FindPartOnRay
    workspace.FindPartOnRay = function(self,ray,...)
        if Cfg.silentOn then
            local t = getSilentTarget()
            if t then
                local ok,r = pcall(Ray.new, ray.Origin,
                    (t.Position-ray.Origin).Unit * ray.Direction.Magnitude)
                if ok then ray=r end
            end
        end
        return o(self,ray,...)
    end
end)

pcall(function()
    local o = workspace.FindPartOnRayWithIgnoreList
    workspace.FindPartOnRayWithIgnoreList = function(self,ray,il,...)
        if Cfg.silentOn then
            local t = getSilentTarget()
            if t then
                local ok,r = pcall(Ray.new, ray.Origin,
                    (t.Position-ray.Origin).Unit * ray.Direction.Magnitude)
                if ok then ray=r end
            end
        end
        return o(self,ray,il,...)
    end
end)

pcall(function()
    local o = workspace.Raycast
    workspace.Raycast = function(self,origin,dir,params)
        if Cfg.silentOn then
            local t = getSilentTarget()
            if t then
                pcall(function() dir=(t.Position-origin).Unit*dir.Magnitude end)
            end
        end
        return o(self,origin,dir,params)
    end
end)

-- ════════════════════════════════════════
-- GUI  590 × 316
-- ════════════════════════════════════════
local W,H = 590,316

local sg = Instance.new("ScreenGui")
sg.Name="ZXCv5"; sg.ResetOnSpawn=false
sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
sg.Parent=game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Size=UDim2.new(0,W,0,H)
Main.Position=UDim2.new(0.5,-W/2,0.5,-H/2)
Main.BackgroundColor3=Color3.fromRGB(12,12,18)
Main.BorderSizePixel=0; Main.ClipsDescendants=true; Main.Parent=sg
local _=Instance.new("UICorner",Main); _.CornerRadius=UDim.new(0,10)
local stroke=Instance.new("UIStroke",Main)
stroke.Color=Color3.fromRGB(85,55,195); stroke.Thickness=1.2; stroke.Transparency=0.4

-- Başlık
local TBar=Instance.new("Frame",Main)
TBar.Size=UDim2.new(1,0,0,30)
TBar.BackgroundColor3=Color3.fromRGB(85,55,195); TBar.BorderSizePixel=0
local tbc=Instance.new("UICorner",TBar); tbc.CornerRadius=UDim.new(0,10)
local tbfix=Instance.new("Frame",TBar)
tbfix.Size=UDim2.new(1,0,0.5,0); tbfix.Position=UDim2.new(0,0,0.5,0)
tbfix.BackgroundColor3=Color3.fromRGB(85,55,195); tbfix.BorderSizePixel=0
local tbLbl=Instance.new("TextLabel",TBar)
tbLbl.Size=UDim2.new(1,-12,1,0); tbLbl.Position=UDim2.new(0,12,0,0)
tbLbl.BackgroundTransparency=1; tbLbl.TextColor3=Color3.fromRGB(255,255,255)
tbLbl.Font=Enum.Font.GothamBold; tbLbl.TextSize=13
tbLbl.TextXAlignment=Enum.TextXAlignment.Left
tbLbl.Text="ZXC  ·  8 = aç/kapat"

-- Sürükle
local dragging,dragStart,dragBase
TBar.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true; dragStart=i.Position; dragBase=Main.Position end
end)
TBar.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
end)
UserInput.InputChanged:Connect(function(i)
    if dragging and i.UserInputType==Enum.UserInputType.MouseMove then
        local d=i.Position-dragStart
        Main.Position=UDim2.new(dragBase.X.Scale,dragBase.X.Offset+d.X,
                                 dragBase.Y.Scale,dragBase.Y.Offset+d.Y)
    end
end)

-- Sol tab bar 112px
local TabBar=Instance.new("Frame",Main)
TabBar.Size=UDim2.new(0,112,1,-30); TabBar.Position=UDim2.new(0,0,0,30)
TabBar.BackgroundColor3=Color3.fromRGB(8,8,14); TabBar.BorderSizePixel=0
local tll=Instance.new("UIListLayout",TabBar)
tll.Padding=UDim.new(0,3); tll.SortOrder=Enum.SortOrder.LayoutOrder
local tpp=Instance.new("UIPadding",TabBar)
tpp.PaddingTop=UDim.new(0,10); tpp.PaddingLeft=UDim.new(0,7); tpp.PaddingRight=UDim.new(0,7)
local divLine=Instance.new("Frame",Main)
divLine.Size=UDim2.new(0,1,1,-30); divLine.Position=UDim2.new(0,112,0,30)
divLine.BackgroundColor3=Color3.fromRGB(38,38,60); divLine.BorderSizePixel=0

-- Sağ içerik
local CA=Instance.new("Frame",Main)
CA.Size=UDim2.new(1,-113,1,-30); CA.Position=UDim2.new(0,113,0,30)
CA.BackgroundTransparency=1; CA.ClipsDescendants=true

-- ════════════════════════════════════════
-- UI HELPERS
-- ════════════════════════════════════════
local function newSF()
    local sf=Instance.new("ScrollingFrame",CA)
    sf.Size=UDim2.new(1,0,1,0); sf.BackgroundTransparency=1
    sf.BorderSizePixel=0; sf.ScrollBarThickness=3
    sf.ScrollBarImageColor3=Color3.fromRGB(85,55,195)
    sf.CanvasSize=UDim2.new(0,0,0,0); sf.Visible=false
    local ll=Instance.new("UIListLayout",sf)
    ll.Padding=UDim.new(0,5); ll.SortOrder=Enum.SortOrder.LayoutOrder
    -- scroll canvas güncelle — AutomaticCanvasSize yerine listener
    ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize=UDim2.new(0,0,0,ll.AbsoluteContentSize.Y+20)
    end)
    local pp=Instance.new("UIPadding",sf)
    pp.PaddingTop=UDim.new(0,10); pp.PaddingLeft=UDim.new(0,10); pp.PaddingRight=UDim.new(0,14)
    return sf
end

local function mkHead(p,txt)
    local l=Instance.new("TextLabel",p)
    l.Size=UDim2.new(1,0,0,13); l.BackgroundTransparency=1
    l.TextColor3=Color3.fromRGB(85,55,195); l.Font=Enum.Font.GothamBold
    l.TextSize=10; l.TextXAlignment=Enum.TextXAlignment.Left
    l.Text=txt:upper(); return l
end

local function mkToggle(p,label,getS,setS)
    local row=Instance.new("Frame",p)
    row.Size=UDim2.new(1,0,0,30); row.BackgroundColor3=Color3.fromRGB(19,19,29)
    row.BorderSizePixel=0
    local rc=Instance.new("UICorner",row); rc.CornerRadius=UDim.new(0,6)
    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-52,1,0); lbl.Position=UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency=1; lbl.TextColor3=Color3.fromRGB(205,205,205)
    lbl.Font=Enum.Font.Gotham; lbl.TextSize=12
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Text=label
    local pill=Instance.new("Frame",row)
    pill.Size=UDim2.new(0,36,0,18); pill.Position=UDim2.new(1,-44,0.5,-9)
    pill.BackgroundColor3=Color3.fromRGB(42,42,62); pill.BorderSizePixel=0
    local pc=Instance.new("UICorner",pill); pc.CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame",pill)
    knob.Size=UDim2.new(0,14,0,14); knob.Position=UDim2.new(0,2,0.5,-7)
    knob.BackgroundColor3=Color3.fromRGB(165,165,165); knob.BorderSizePixel=0
    local kc=Instance.new("UICorner",knob); kc.CornerRadius=UDim.new(1,0)
    local function refresh()
        local on=getS()
        TweenSvc:Create(pill,TweenInfo.new(0.13),{
            BackgroundColor3=on and Color3.fromRGB(85,55,195) or Color3.fromRGB(42,42,62)
        }):Play()
        TweenSvc:Create(knob,TweenInfo.new(0.13),{
            Position=on and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7),
            BackgroundColor3=on and Color3.fromRGB(255,255,255) or Color3.fromRGB(165,165,165)
        }):Play()
    end
    local btn=Instance.new("TextButton",row)
    btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""
    btn.MouseButton1Click:Connect(function() setS(not getS()); refresh() end)
    refresh(); return row
end

local function mkSlider(p,label,minV,maxV,defV,isFloat,cb)
    local con=Instance.new("Frame",p)
    con.Size=UDim2.new(1,0,0,48); con.BackgroundColor3=Color3.fromRGB(19,19,29)
    con.BorderSizePixel=0
    local cc=Instance.new("UICorner",con); cc.CornerRadius=UDim.new(0,6)
    local fmt=function(v) return isFloat and string.format("%.2f",v) or tostring(math.floor(v)) end
    local lbl=Instance.new("TextLabel",con)
    lbl.Size=UDim2.new(1,-10,0,18); lbl.Position=UDim2.new(0,10,0,6)
    lbl.BackgroundTransparency=1; lbl.TextColor3=Color3.fromRGB(205,205,205)
    lbl.Font=Enum.Font.Gotham; lbl.TextSize=11
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Text=label..":  "..fmt(defV)
    local track=Instance.new("Frame",con)
    track.Size=UDim2.new(1,-20,0,5); track.Position=UDim2.new(0,10,0,33)
    track.BackgroundColor3=Color3.fromRGB(36,36,56); track.BorderSizePixel=0
    local tc=Instance.new("UICorner",track); tc.CornerRadius=UDim.new(1,0)
    local pct=math.clamp((defV-minV)/(maxV-minV),0,1)
    local fill=Instance.new("Frame",track)
    fill.Size=UDim2.new(pct,0,1,0); fill.BackgroundColor3=Color3.fromRGB(85,55,195)
    fill.BorderSizePixel=0
    local fc=Instance.new("UICorner",fill); fc.CornerRadius=UDim.new(1,0)
    local handle=Instance.new("Frame",track)
    handle.Size=UDim2.new(0,13,0,13); handle.Position=UDim2.new(pct,-6,0.5,-6)
    handle.BackgroundColor3=Color3.fromRGB(220,220,220); handle.BorderSizePixel=0
    local hc=Instance.new("UICorner",handle); hc.CornerRadius=UDim.new(1,0)
    -- büyük hitbox — tüm track tıklanabilir
    local hb=Instance.new("TextButton",track)
    hb.Size=UDim2.new(1,0,0,30); hb.Position=UDim2.new(0,0,0.5,-15)
    hb.BackgroundTransparency=1; hb.Text=""
    local sdrag=false
    local function applyDrag(px)
        local t=math.clamp((px-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        local v=isFloat and (minV+t*(maxV-minV)) or math.floor(minV+t*(maxV-minV))
        fill.Size=UDim2.new(t,0,1,0); handle.Position=UDim2.new(t,-6,0.5,-6)
        lbl.Text=label..":  "..fmt(v); cb(v)
    end
    hb.MouseButton1Down:Connect(function(x,_) sdrag=true; applyDrag(x) end)
    hb.MouseButton1Up:Connect(function() sdrag=false end)
    UserInput.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then sdrag=false end
    end)
    UserInput.InputChanged:Connect(function(i)
        if sdrag and i.UserInputType==Enum.UserInputType.MouseMove then
            applyDrag(i.Position.X)
        end
    end)
    return con
end

local function mkButton(p,label,cb)
    local btn=Instance.new("TextButton",p)
    btn.Size=UDim2.new(1,0,0,30); btn.BackgroundColor3=Color3.fromRGB(85,55,195)
    btn.TextColor3=Color3.fromRGB(255,255,255); btn.Font=Enum.Font.GothamBold
    btn.TextSize=12; btn.Text=label; btn.BorderSizePixel=0
    local bc=Instance.new("UICorner",btn); bc.CornerRadius=UDim.new(0,6)
    btn.MouseEnter:Connect(function()
        TweenSvc:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(105,75,225)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenSvc:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(85,55,195)}):Play()
    end)
    btn.MouseButton1Click:Connect(cb); return btn
end

-- ════════════════════════════════════════
-- TAB SİSTEMİ
-- ════════════════════════════════════════
local tabFrames,tabBtns,activeTab={},{},nil

local function switchTab(name)
    for n,f in pairs(tabFrames) do f.Visible=(n==name) end
    for n,b in pairs(tabBtns) do
        if n==name then
            b.BackgroundTransparency=0
            b.BackgroundColor3=Color3.fromRGB(85,55,195)
            b.TextColor3=Color3.fromRGB(255,255,255)
        else
            b.BackgroundTransparency=1
            b.TextColor3=Color3.fromRGB(130,130,150)
        end
    end
    activeTab=name
end

local function addTab(name,icon)
    local sf=newSF(); tabFrames[name]=sf
    local btn=Instance.new("TextButton",TabBar)
    btn.Size=UDim2.new(1,0,0,34); btn.BackgroundTransparency=1
    btn.TextColor3=Color3.fromRGB(130,130,150); btn.Font=Enum.Font.Gotham
    btn.TextSize=12; btn.Text=icon.."  "..name
    btn.TextXAlignment=Enum.TextXAlignment.Left; btn.BorderSizePixel=0
    local bc=Instance.new("UICorner",btn); bc.CornerRadius=UDim.new(0,6)
    tabBtns[name]=btn
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    btn.MouseEnter:Connect(function()
        if activeTab~=name then
            TweenSvc:Create(btn,TweenInfo.new(0.1),{
                BackgroundTransparency=0.8,
                BackgroundColor3=Color3.fromRGB(85,55,195)
            }):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if activeTab~=name then
            TweenSvc:Create(btn,TweenInfo.new(0.1),{BackgroundTransparency=1}):Play()
        end
    end)
    return sf
end

-- ════════════════════════════════════════
-- ─── ESP ─────────────────────────────────
-- ════════════════════════════════════════
local espTab=addTab("ESP","👁")
mkHead(espTab,"görünürlük")
mkToggle(espTab,"ESP  (duvardan görme)",
    function() return Cfg.espOn end,
    function(v) Cfg.espOn=v end)

local cRow=Instance.new("Frame",espTab)
cRow.Size=UDim2.new(1,0,0,38); cRow.BackgroundColor3=Color3.fromRGB(19,19,29)
cRow.BorderSizePixel=0
local crc=Instance.new("UICorner",cRow); crc.CornerRadius=UDim.new(0,6)
local cLbl=Instance.new("TextLabel",cRow)
cLbl.Size=UDim2.new(0,64,1,0); cLbl.Position=UDim2.new(0,10,0,0)
cLbl.BackgroundTransparency=1; cLbl.TextColor3=Color3.fromRGB(205,205,205)
cLbl.Font=Enum.Font.Gotham; cLbl.TextSize=11
cLbl.TextXAlignment=Enum.TextXAlignment.Left; cLbl.Text="ESP Renk"

local pal={
    Color3.fromRGB(255,50,50),  Color3.fromRGB(50,230,100),
    Color3.fromRGB(50,140,255), Color3.fromRGB(255,215,45),
    Color3.fromRGB(255,255,255),Color3.fromRGB(180,50,255),
    Color3.fromRGB(255,120,30), Color3.fromRGB(255,80,180),
}
local selDot=nil
for i,c in ipairs(pal) do
    local dot=Instance.new("TextButton",cRow)
    dot.Size=UDim2.new(0,19,0,19); dot.Position=UDim2.new(0,76+(i-1)*25,0.5,-9)
    dot.BackgroundColor3=c; dot.Text=""; dot.BorderSizePixel=2
    dot.BorderColor3=Color3.fromRGB(0,0,0)
    local dc=Instance.new("UICorner",dot); dc.CornerRadius=UDim.new(1,0)
    local cc=c
    dot.MouseButton1Click:Connect(function()
        Cfg.espColor=cc
        for _,h in pairs(espHL) do
            pcall(function() h.FillColor=cc; h.OutlineColor=cc end)
        end
        if selDot then selDot.BorderColor3=Color3.fromRGB(0,0,0) end
        dot.BorderColor3=Color3.fromRGB(255,255,255); selDot=dot
    end)
end

-- ════════════════════════════════════════
-- ─── AİMBOT ──────────────────────────────
-- ════════════════════════════════════════
local aimTab=addTab("Aimbot","🎯")
mkHead(aimTab,"görsel aimbot  —  sağ tık ile aktif")
mkToggle(aimTab,"Aimbot",function() return Cfg.aimbotOn end,function(v) Cfg.aimbotOn=v end)
mkToggle(aimTab,"FOV Dairesi",function() return Cfg.showFOV end,function(v) Cfg.showFOV=v end)
mkSlider(aimTab,"FOV Yarıçapı",30,500,Cfg.aimbotFOV,false,function(v) Cfg.aimbotFOV=v end)
mkSlider(aimTab,"Smooth  (düşük=hızlı)",0.02,0.6,Cfg.aimbotSmooth,true,function(v) Cfg.aimbotSmooth=v end)

-- Hedef seçimi
local pRow=Instance.new("Frame",aimTab)
pRow.Size=UDim2.new(1,0,0,30); pRow.BackgroundColor3=Color3.fromRGB(19,19,29)
pRow.BorderSizePixel=0
local prc=Instance.new("UICorner",pRow); prc.CornerRadius=UDim.new(0,6)
local pLbl=Instance.new("TextLabel",pRow)
pLbl.Size=UDim2.new(0.5,0,1,0); pLbl.Position=UDim2.new(0,10,0,0)
pLbl.BackgroundTransparency=1; pLbl.TextColor3=Color3.fromRGB(205,205,205)
pLbl.Font=Enum.Font.Gotham; pLbl.TextSize=12
pLbl.TextXAlignment=Enum.TextXAlignment.Left; pLbl.Text="Hedef:  Head"
local function mkPB(lbl,xOff,part)
    local b=Instance.new("TextButton",pRow)
    b.Size=UDim2.new(0,72,0,20); b.Position=UDim2.new(1,xOff,0.5,-10)
    b.BackgroundColor3=part==Cfg.aimbotPart and Color3.fromRGB(85,55,195) or Color3.fromRGB(38,38,58)
    b.TextColor3=Color3.fromRGB(255,255,255); b.Font=Enum.Font.GothamBold
    b.TextSize=10; b.Text=lbl; b.BorderSizePixel=0
    local bc=Instance.new("UICorner",b); bc.CornerRadius=UDim.new(0,4); return b
end
local hBtn=mkPB("Head",-156,"Head")
local tBtn=mkPB("Torso",-78,"HumanoidRootPart")
hBtn.MouseButton1Click:Connect(function()
    Cfg.aimbotPart="Head"; pLbl.Text="Hedef:  Head"
    hBtn.BackgroundColor3=Color3.fromRGB(85,55,195)
    tBtn.BackgroundColor3=Color3.fromRGB(38,38,58)
end)
tBtn.MouseButton1Click:Connect(function()
    Cfg.aimbotPart="HumanoidRootPart"; pLbl.Text="Hedef:  Torso"
    tBtn.BackgroundColor3=Color3.fromRGB(85,55,195)
    hBtn.BackgroundColor3=Color3.fromRGB(38,38,58)
end)

mkHead(aimTab,"silent aim")
mkToggle(aimTab,"Silent Aim",function() return Cfg.silentOn end,function(v) Cfg.silentOn=v end)
mkSlider(aimTab,"Silent FOV",30,600,Cfg.silentFOV,false,function(v) Cfg.silentFOV=v end)
mkHead(aimTab,"magic bullet")
mkToggle(aimTab,"Magic Bullet  (hitbox genişlet)",function() return Cfg.magicOn end,function(v) Cfg.magicOn=v end)
mkSlider(aimTab,"Hitbox Boyutu (studs)",2,30,Cfg.magicSize,false,function(v) Cfg.magicSize=v end)

-- ════════════════════════════════════════
-- ─── HAREKET ─────────────────────────────
-- ════════════════════════════════════════
local moveTab=addTab("Hareket","🏃")
mkHead(moveTab,"fly")
mkToggle(moveTab,"Fly  (W/A/S/D · Space · Shift)",function() return Cfg.flyOn end,function(v) Cfg.flyOn=v end)
mkSlider(moveTab,"Fly Hızı",20,300,Cfg.flySpeed,false,function(v) Cfg.flySpeed=v end)
mkHead(moveTab,"zemin")
mkToggle(moveTab,"Noclip",function() return Cfg.noclipOn end,function(v) Cfg.noclipOn=v end)
mkToggle(moveTab,"Sonsuz Zıplama",function() return Cfg.infJump end,function(v) Cfg.infJump=v end)
mkSlider(moveTab,"WalkSpeed",16,500,Cfg.walkSpeed,false,function(v)
    Cfg.walkSpeed=v; local h=getHum(); if h then h.WalkSpeed=v end end)
mkSlider(moveTab,"JumpPower",7,300,Cfg.jumpPower,false,function(v)
    Cfg.jumpPower=v; local h=getHum(); if h then h.JumpPower=v end end)

-- ════════════════════════════════════════
-- ─── OYUNCULAR ───────────────────────────
-- ════════════════════════════════════════
local playTab=addTab("Oyuncular","👥")
mkHead(playTab,"kill aura")
mkToggle(playTab,"Kill Aura",function() return Cfg.killAura end,function(v) Cfg.killAura=v end)
mkSlider(playTab,"Kill Range (studs)",5,100,Cfg.killRange,false,function(v) Cfg.killRange=v end)
mkHead(playTab,"toplu tp")
mkButton(playTab,"⬇  Herkesi Yanıma Çek",function()
    local hrp=getHRP(); if not hrp then return end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp and plr.Character then
            local ehr=plr.Character:FindFirstChild("HumanoidRootPart")
            if ehr then
                pcall(function()
                    ehr.CFrame=hrp.CFrame+Vector3.new(math.random(-5,5),0,math.random(-5,5))
                end)
            end
        end
    end
end)
mkButton(playTab,"🎲  Rastgele Birine TP",function()
    local pool={}
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(pool,plr)
        end
    end
    if #pool==0 then return end
    local t=pool[math.random(1,#pool)]; local hrp=getHRP()
    if hrp then pcall(function()
        hrp.CFrame=t.Character.HumanoidRootPart.CFrame+Vector3.new(2,0,0)
    end) end
end)

mkHead(playTab,"liste")
local plH=Instance.new("Frame",playTab)
plH.Size=UDim2.new(1,0,0,0); plH.BackgroundTransparency=1
local plL=Instance.new("UIListLayout",plH)
plL.Padding=UDim.new(0,4); plL.SortOrder=Enum.SortOrder.LayoutOrder
plL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    plH.Size=UDim2.new(1,0,0,plL.AbsoluteContentSize.Y)
end)

local function refreshList()
    for _,c in ipairs(plH:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp then
            local row=Instance.new("Frame",plH)
            row.Size=UDim2.new(1,0,0,28); row.BackgroundColor3=Color3.fromRGB(19,19,29)
            row.BorderSizePixel=0
            local rc=Instance.new("UICorner",row); rc.CornerRadius=UDim.new(0,5)
            local nl=Instance.new("TextLabel",row)
            nl.Size=UDim2.new(1,-68,1,0); nl.Position=UDim2.new(0,8,0,0)
            nl.BackgroundTransparency=1; nl.TextColor3=Color3.fromRGB(205,205,205)
            nl.Font=Enum.Font.Gotham; nl.TextSize=11
            nl.TextXAlignment=Enum.TextXAlignment.Left
            nl.Text=plr.DisplayName.."  (@"..plr.Name..")"
            nl.TextTruncate=Enum.TextTruncate.AtEnd
            local tb=Instance.new("TextButton",row)
            tb.Size=UDim2.new(0,56,0,20); tb.Position=UDim2.new(1,-62,0.5,-10)
            tb.BackgroundColor3=Color3.fromRGB(85,55,195); tb.TextColor3=Color3.fromRGB(255,255,255)
            tb.Font=Enum.Font.GothamBold; tb.TextSize=10; tb.Text="TP Git"; tb.BorderSizePixel=0
            local tc=Instance.new("UICorner",tb); tc.CornerRadius=UDim.new(0,4)
            local cp=plr
            tb.MouseButton1Click:Connect(function()
                local hrp=getHRP()
                if hrp and cp.Character and cp.Character:FindFirstChild("HumanoidRootPart") then
                    pcall(function()
                        hrp.CFrame=cp.Character.HumanoidRootPart.CFrame+Vector3.new(2,0,0)
                    end)
                end
            end)
        end
    end
end
mkButton(playTab,"🔄  Yenile",function() refreshList() end)
refreshList()
switchTab("ESP")

-- ════════════════════════════════════════
-- 8 TUŞU TOGGLE
-- ════════════════════════════════════════
local openY=Main.Position.Y.Offset
local closeY=openY+H+60

UserInput.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if inp.KeyCode~=Enum.KeyCode.Eight then return end
    guiOpen=not guiOpen
    if guiOpen then
        Main.Visible=true
        TweenSvc:Create(Main,TweenInfo.new(0.28,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{
            Position=UDim2.new(Main.Position.X.Scale,Main.Position.X.Offset,
                               Main.Position.Y.Scale,openY)
        }):Play()
    else
        local tw=TweenSvc:Create(Main,TweenInfo.new(0.22,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{
            Position=UDim2.new(Main.Position.X.Scale,Main.Position.X.Offset,
                               Main.Position.Y.Scale,closeY)
        })
        tw:Play()
        tw.Completed:Connect(function() Main.Visible=false end)
    end
end)

-- ════════════════════════════════════════
-- FOV DAİRESİ
-- ════════════════════════════════════════
local fovC=nil
pcall(function()
    fovC=Drawing.new("Circle")
    fovC.Visible=false; fovC.Thickness=1.4
    fovC.Color=Color3.fromRGB(220,220,220)
    fovC.Filled=false; fovC.NumSides=64
end)

-- ════════════════════════════════════════
-- FLY
-- ════════════════════════════════════════
local function enableFly()
    local hrp=getHRP(); if not hrp then return end
    pcall(function()
        local bv=Instance.new("BodyVelocity",hrp)
        bv.Velocity=Vector3.zero; bv.MaxForce=Vector3.new(1e5,1e5,1e5)
        local bg=Instance.new("BodyGyro",hrp)
        bg.MaxTorque=Vector3.new(1e5,1e5,1e5); bg.D=50
        flyBody={bv=bv,bg=bg}
    end)
    local h=getHum(); if h then pcall(function() h.PlatformStand=true end) end
end

local function disableFly()
    pcall(function()
        if flyBody.bv then flyBody.bv:Destroy() end
        if flyBody.bg then flyBody.bg:Destroy() end
    end)
    flyBody={}
    local h=getHum(); if h then pcall(function() h.PlatformStand=false end) end
end

-- ════════════════════════════════════════
-- ESP — iterate-safe
-- ════════════════════════════════════════
local function updateESP()
    local dead={}
    for pid,h in pairs(espHL) do
        local plr=Players:GetPlayerByUserId(pid)
        if not plr or not plr.Character or not Cfg.espOn then
            dead[#dead+1]=pid; pcall(function() h:Destroy() end)
        end
    end
    for _,pid in ipairs(dead) do espHL[pid]=nil end
    if not Cfg.espOn then return end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp and plr.Character then
            if not espHL[plr.UserId] then
                pcall(function()
                    local h=Instance.new("Highlight")
                    h.FillColor=Cfg.espColor; h.OutlineColor=Cfg.espColor
                    h.FillTransparency=0.65; h.OutlineTransparency=0
                    h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                    h.Adornee=plr.Character; h.Parent=workspace
                    espHL[plr.UserId]=h
                end)
            else
                pcall(function()
                    espHL[plr.UserId].FillColor=Cfg.espColor
                    espHL[plr.UserId].OutlineColor=Cfg.espColor
                end)
            end
        end
    end
end

-- ════════════════════════════════════════
-- AİMBOT HEDEF
-- ════════════════════════════════════════
local function getAimTarget()
    local cx=Camera.ViewportSize.X/2
    local cy=Camera.ViewportSize.Y/2
    local best,bd=nil,math.huge
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp and plr.Character then
            local part=plr.Character:FindFirstChild(Cfg.aimbotPart)
            if part then
                local ok,sp,vis=pcall(function()
                    return Camera:WorldToScreenPoint(part.Position)
                end)
                if ok and vis then
                    local d=math.sqrt((sp.X-cx)^2+(sp.Y-cy)^2)
                    if d<Cfg.aimbotFOV and d<bd then bd=d; best=part end
                end
            end
        end
    end
    return best
end

-- ════════════════════════════════════════
-- SONSUZ ZIPLAMAMA
-- ════════════════════════════════════════
UserInput.JumpRequest:Connect(function()
    if Cfg.infJump then
        local h=getHum()
        if h then pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end) end
    end
end)

-- ════════════════════════════════════════
-- RENDERSTEPPED
-- ════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    pcall(updateESP)

    if Cfg.flyOn~=prevFly then
        if Cfg.flyOn then enableFly() else disableFly() end
        prevFly=Cfg.flyOn
    end

    if Cfg.flyOn and flyBody.bv and flyBody.bg then
        pcall(function()
            local cf=Camera.CFrame
            local dir=Vector3.zero
            -- += yok, executor uyumlu
            if UserInput:IsKeyDown(Enum.KeyCode.W) then
                dir=dir+cf.LookVector end
            if UserInput:IsKeyDown(Enum.KeyCode.S) then
                dir=dir-cf.LookVector end
            if UserInput:IsKeyDown(Enum.KeyCode.A) then
                dir=dir-cf.RightVector end
            if UserInput:IsKeyDown(Enum.KeyCode.D) then
                dir=dir+cf.RightVector end
            if UserInput:IsKeyDown(Enum.KeyCode.Space) then
                dir=dir+Vector3.new(0,1,0) end
            if UserInput:IsKeyDown(Enum.KeyCode.LeftShift) then
                dir=dir-Vector3.new(0,1,0) end
            flyBody.bv.Velocity=dir.Magnitude>0 and dir.Unit*Cfg.flySpeed or Vector3.zero
            flyBody.bg.CFrame=cf
        end)
    end

    if Cfg.noclipOn then
        pcall(function()
            local c=getChar()
            if c then
                for _,p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide=false end
                end
            end
        end)
    end

    if Cfg.aimbotOn and UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        pcall(function()
            local t=getAimTarget()
            if t then
                Camera.CFrame=Camera.CFrame:Lerp(
                    CFrame.lookAt(Camera.CFrame.Position,t.Position),
                    Cfg.aimbotSmooth)
            end
        end)
    end

    if Cfg.magicOn then
        pcall(function()
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr~=lp and plr.Character then
                    local hrp=plr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and hrp.Size.X~=Cfg.magicSize then
                        hrp.Size=Vector3.new(Cfg.magicSize,Cfg.magicSize,Cfg.magicSize)
                    end
                end
            end
        end)
    end

    if fovC then
        pcall(function()
            fovC.Visible=Cfg.showFOV and Cfg.aimbotOn
            fovC.Radius=Cfg.aimbotFOV
            fovC.Position=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
        end)
    end
end)

-- ════════════════════════════════════════
-- STEPPED
-- ════════════════════════════════════════
RunService.Stepped:Connect(function()
    pcall(function()
        local h=getHum()
        if h and not Cfg.flyOn then
            h.WalkSpeed=Cfg.walkSpeed
            h.JumpPower=Cfg.jumpPower
        end
    end)
    if Cfg.killAura then
        pcall(function()
            local hrp=getHRP(); if not hrp then return end
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr~=lp and plr.Character then
                    local ehr=plr.Character:FindFirstChild("HumanoidRootPart")
                    if ehr and (ehr.Position-hrp.Position).Magnitude<=Cfg.killRange then
                        local orig=hrp.CFrame
                        hrp.CFrame=ehr.CFrame; task.wait(); hrp.CFrame=orig
                    end
                end
            end
        end)
    end
end)

print("[ZXC v5]  8 = kapat/aç")
