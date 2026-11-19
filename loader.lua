-- lang: Luau | Roblox Universal | Synapse X / KRNL / Fluxus
-- ZXC v6 — gradient UI · troll kataloğu · god mode · invisible · bhop · gravity · spin · freeze · launch · chat spam

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput  = game:GetService("UserInputService")
local TweenSvc   = game:GetService("TweenService")
local Debris     = game:GetService("Debris")
local Camera     = workspace.CurrentCamera
local lp         = Players.LocalPlayer

-- ══════════════════════════════════════════════════
-- RENKLER
-- ══════════════════════════════════════════════════
local C = {
    bg       = Color3.fromRGB(10,10,16),
    sidebar  = Color3.fromRGB(7,7,13),
    card     = Color3.fromRGB(18,18,28),
    accent   = Color3.fromRGB(100,65,220),
    accent2  = Color3.fromRGB(140,90,255),
    danger   = Color3.fromRGB(210,55,55),
    danger2  = Color3.fromRGB(240,80,80),
    success  = Color3.fromRGB(45,195,95),
    text     = Color3.fromRGB(220,220,230),
    muted    = Color3.fromRGB(110,110,135),
    white    = Color3.fromRGB(255,255,255),
    track    = Color3.fromRGB(32,32,50),
    div      = Color3.fromRGB(35,35,55),
}

-- ══════════════════════════════════════════════════
-- AYARLAR
-- ══════════════════════════════════════════════════
local Cfg = {
    -- ESP
    espOn=false, espColor=Color3.fromRGB(255,50,50), espFill=0.65,
    -- Combat
    aimbotOn=false, aimbotFOV=150, aimbotSmooth=0.18, aimbotPart="Head",
    showFOV=false,
    silentOn=false, silentFOV=250,
    magicOn=false,  magicSize=8,
    -- Hareket
    flyOn=false,    flySpeed=60,
    noclipOn=false,
    walkSpeed=16,   jumpPower=50,
    infJump=false,  bhop=false,
    gravity=196.2,  antiAFK=false,
    spinSelf=false, spinSpeed=8,
    godMode=false,  invisible=false,
    -- Troll
    freezeAll=false,
    spinAll=false,  spinAllSpeed=8,
    launchPow=120,
    annoyOn=false,
    scaleAll=1.0,
    chatSpam=false, chatMsg="ZXC hile",
    -- Combat
    killAura=false, killRange=20,
}

local flyBody={} local espHL={} local prevFly=false local guiOpen=true
local annoyIndex=1 local lastChat=0 local lastAnnoy=0

local function getChar() return lp.Character end
local function getHRP()  local c=getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c=getChar(); return c and c:FindFirstChildOfClass("Humanoid") end

lp.CharacterAdded:Connect(function()
    for _,h in pairs(espHL) do pcall(function() h:Destroy() end) end
    espHL={}; prevFly=false; flyBody={}
end)

-- Anti-AFK
lp.Idled:Connect(function()
    if Cfg.antiAFK then pcall(function()
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.zero)
    end) end
end)

-- ══════════════════════════════════════════════════
-- SILENT AIM
-- ══════════════════════════════════════════════════
local function getSilentTarget()
    local cx=Camera.ViewportSize.X/2; local cy=Camera.ViewportSize.Y/2
    local best,bd=nil,math.huge
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp and plr.Character then
            local part=plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local ok,sp,vis=pcall(function() return Camera:WorldToScreenPoint(part.Position) end)
                if ok and vis then
                    local d=math.sqrt((sp.X-cx)^2+(sp.Y-cy)^2)
                    if d<Cfg.silentFOV and d<bd then bd=d; best=part end
                end
            end
        end
    end
    return best
end
pcall(function()
    local o=workspace.FindPartOnRay
    workspace.FindPartOnRay=function(self,ray,...)
        if Cfg.silentOn then local t=getSilentTarget()
            if t then local ok,r=pcall(Ray.new,ray.Origin,(t.Position-ray.Origin).Unit*ray.Direction.Magnitude)
                if ok then ray=r end end end; return o(self,ray,...) end
end)
pcall(function()
    local o=workspace.FindPartOnRayWithIgnoreList
    workspace.FindPartOnRayWithIgnoreList=function(self,ray,il,...)
        if Cfg.silentOn then local t=getSilentTarget()
            if t then local ok,r=pcall(Ray.new,ray.Origin,(t.Position-ray.Origin).Unit*ray.Direction.Magnitude)
                if ok then ray=r end end end; return o(self,ray,il,...) end
end)
pcall(function()
    local o=workspace.Raycast
    workspace.Raycast=function(self,origin,dir,params)
        if Cfg.silentOn then local t=getSilentTarget()
            if t then pcall(function() dir=(t.Position-origin).Unit*dir.Magnitude end) end end
        return o(self,origin,dir,params) end
end)

-- ══════════════════════════════════════════════════
-- GUI  W=620 H=338
-- ══════════════════════════════════════════════════
local W,H=620,338

local sg=Instance.new("ScreenGui")
sg.Name="ZXCv6"; sg.ResetOnSpawn=false
sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
sg.Parent=game:GetService("CoreGui")

local Main=Instance.new("Frame",sg)
Main.Size=UDim2.new(0,W,0,H)
Main.Position=UDim2.new(0.5,-W/2,0.5,-H/2)
Main.BackgroundColor3=C.bg; Main.BorderSizePixel=0; Main.ClipsDescendants=true
local _=Instance.new("UICorner",Main); _.CornerRadius=UDim.new(0,12)
local mainStroke=Instance.new("UIStroke",Main)
mainStroke.Color=C.accent; mainStroke.Thickness=1.5; mainStroke.Transparency=0.5

-- Gölge
local shadow=Instance.new("Frame",Main)
shadow.Size=UDim2.new(1,0,1,0); shadow.Position=UDim2.new(0,0,0,0)
shadow.BackgroundTransparency=1; shadow.ZIndex=0
local _=Instance.new("UICorner",shadow); _.CornerRadius=UDim.new(0,12)
local sStroke=Instance.new("UIStroke",shadow)
sStroke.Color=C.accent2; sStroke.Thickness=0.5; sStroke.Transparency=0.7

-- ── Başlık ─────────────────────────────────────
local TBar=Instance.new("Frame",Main)
TBar.Size=UDim2.new(1,0,0,34); TBar.BackgroundColor3=C.accent; TBar.BorderSizePixel=0
local tbc=Instance.new("UICorner",TBar); tbc.CornerRadius=UDim.new(0,12)
local tbfix=Instance.new("Frame",TBar)
tbfix.Size=UDim2.new(1,0,0.5,0); tbfix.Position=UDim2.new(0,0,0.5,0)
tbfix.BackgroundColor3=C.accent; tbfix.BorderSizePixel=0

-- Gradient başlık
local grad=Instance.new("UIGradient",TBar)
grad.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,C.accent),
    ColorSequenceKeypoint.new(0.5,Color3.fromRGB(120,75,235)),
    ColorSequenceKeypoint.new(1,C.accent),
})
grad.Rotation=90

local tbTitle=Instance.new("TextLabel",TBar)
tbTitle.Size=UDim2.new(1,-16,1,0); tbTitle.Position=UDim2.new(0,14,0,0)
tbTitle.BackgroundTransparency=1; tbTitle.TextColor3=C.white
tbTitle.Font=Enum.Font.GothamBold; tbTitle.TextSize=14
tbTitle.TextXAlignment=Enum.TextXAlignment.Left
tbTitle.Text="⚡  ZXC  ·  8 = aç/kapat"

-- Versiyon badge
local vBadge=Instance.new("TextLabel",TBar)
vBadge.Size=UDim2.new(0,30,0,16); vBadge.Position=UDim2.new(1,-38,0.5,-8)
vBadge.BackgroundColor3=Color3.fromRGB(0,0,0)
vBadge.BackgroundTransparency=0.4
vBadge.TextColor3=C.white; vBadge.Font=Enum.Font.GothamBold
vBadge.TextSize=10; vBadge.Text="v6"; vBadge.BorderSizePixel=0
local vc=Instance.new("UICorner",vBadge); vc.CornerRadius=UDim.new(0,4)

-- Sürükleme
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
                                 dragBase.Y.Scale,dragBase.Y.Offset+d.Y) end
end)

-- ── Sol Tab Bar ─────────────────────────────────
local TabBar=Instance.new("Frame",Main)
TabBar.Size=UDim2.new(0,118,1,-34); TabBar.Position=UDim2.new(0,0,0,34)
TabBar.BackgroundColor3=C.sidebar; TabBar.BorderSizePixel=0
local tbGrad=Instance.new("UIGradient",TabBar)
tbGrad.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,C.sidebar),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(9,9,15)),
})
tbGrad.Rotation=270
local tll=Instance.new("UIListLayout",TabBar)
tll.Padding=UDim.new(0,2); tll.SortOrder=Enum.SortOrder.LayoutOrder
local tpp=Instance.new("UIPadding",TabBar)
tpp.PaddingTop=UDim.new(0,8); tpp.PaddingLeft=UDim.new(0,6); tpp.PaddingRight=UDim.new(0,6)

local divLine=Instance.new("Frame",Main)
divLine.Size=UDim2.new(0,1,1,-34); divLine.Position=UDim2.new(0,118,0,34)
divLine.BackgroundColor3=C.div; divLine.BorderSizePixel=0

-- ── İçerik Alanı ───────────────────────────────
local CA=Instance.new("Frame",Main)
CA.Size=UDim2.new(1,-119,1,-34); CA.Position=UDim2.new(0,119,0,34)
CA.BackgroundTransparency=1; CA.ClipsDescendants=true

-- ══════════════════════════════════════════════════
-- UI HELPERS
-- ══════════════════════════════════════════════════
local function newSF()
    local sf=Instance.new("ScrollingFrame",CA)
    sf.Size=UDim2.new(1,0,1,0); sf.BackgroundTransparency=1
    sf.BorderSizePixel=0; sf.ScrollBarThickness=3
    sf.ScrollBarImageColor3=C.accent2
    sf.CanvasSize=UDim2.new(0,0,0,0); sf.Visible=false
    local ll=Instance.new("UIListLayout",sf)
    ll.Padding=UDim.new(0,5); ll.SortOrder=Enum.SortOrder.LayoutOrder
    ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize=UDim2.new(0,0,0,ll.AbsoluteContentSize.Y+20)
    end)
    local pp=Instance.new("UIPadding",sf)
    pp.PaddingTop=UDim.new(0,10); pp.PaddingLeft=UDim.new(0,10); pp.PaddingRight=UDim.new(0,14)
    return sf
end

local function mkHead(p,txt,color)
    color=color or C.accent
    local wrap=Instance.new("Frame",p)
    wrap.Size=UDim2.new(1,0,0,18); wrap.BackgroundTransparency=1
    local line=Instance.new("Frame",wrap)
    line.Size=UDim2.new(1,0,0,1); line.Position=UDim2.new(0,0,1,-1)
    line.BackgroundColor3=color; line.BackgroundTransparency=0.75; line.BorderSizePixel=0
    local lbl=Instance.new("TextLabel",wrap)
    lbl.Size=UDim2.new(1,0,1,-2); lbl.BackgroundTransparency=1
    lbl.TextColor3=color; lbl.Font=Enum.Font.GothamBold
    lbl.TextSize=10; lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.Text="▸  "..txt:upper()
    return wrap
end

local function mkToggle(p,label,getS,setS,danger)
    local ac=danger and C.danger or C.accent
    local ac2=danger and C.danger2 or C.accent2
    local row=Instance.new("Frame",p)
    row.Size=UDim2.new(1,0,0,32); row.BackgroundColor3=C.card; row.BorderSizePixel=0
    local rc=Instance.new("UICorner",row); rc.CornerRadius=UDim.new(0,7)
    -- left accent bar
    local bar=Instance.new("Frame",row)
    bar.Size=UDim2.new(0,3,0.6,0); bar.Position=UDim2.new(0,0,0.2,0)
    bar.BackgroundColor3=ac; bar.BorderSizePixel=0
    local brc=Instance.new("UICorner",bar); brc.CornerRadius=UDim.new(1,0)
    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-58,1,0); lbl.Position=UDim2.new(0,14,0,0)
    lbl.BackgroundTransparency=1; lbl.TextColor3=C.text
    lbl.Font=Enum.Font.Gotham; lbl.TextSize=12
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Text=label
    local pill=Instance.new("Frame",row)
    pill.Size=UDim2.new(0,38,0,20); pill.Position=UDim2.new(1,-46,0.5,-10)
    pill.BackgroundColor3=C.track; pill.BorderSizePixel=0
    local pc=Instance.new("UICorner",pill); pc.CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame",pill)
    knob.Size=UDim2.new(0,16,0,16); knob.Position=UDim2.new(0,2,0.5,-8)
    knob.BackgroundColor3=C.muted; knob.BorderSizePixel=0
    local kc=Instance.new("UICorner",knob); kc.CornerRadius=UDim.new(1,0)
    local function refresh()
        local on=getS()
        bar.BackgroundColor3=on and ac or C.muted
        TweenSvc:Create(pill,TweenInfo.new(0.15),{BackgroundColor3=on and ac or C.track}):Play()
        TweenSvc:Create(knob,TweenInfo.new(0.15),{
            Position=on and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8),
            BackgroundColor3=on and C.white or C.muted
        }):Play()
    end
    local btn=Instance.new("TextButton",row)
    btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""
    btn.MouseButton1Click:Connect(function() setS(not getS()); refresh() end)
    btn.MouseEnter:Connect(function()
        TweenSvc:Create(row,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(22,22,35)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenSvc:Create(row,TweenInfo.new(0.1),{BackgroundColor3=C.card}):Play()
    end)
    refresh(); return row
end

local function mkSlider(p,label,minV,maxV,defV,isFloat,cb,danger)
    local ac=danger and C.danger or C.accent
    local con=Instance.new("Frame",p)
    con.Size=UDim2.new(1,0,0,52); con.BackgroundColor3=C.card; con.BorderSizePixel=0
    local cc=Instance.new("UICorner",con); cc.CornerRadius=UDim.new(0,7)
    local bar=Instance.new("Frame",con)
    bar.Size=UDim2.new(0,3,0.55,0); bar.Position=UDim2.new(0,0,0.22,0)
    bar.BackgroundColor3=ac; bar.BorderSizePixel=0
    local brc=Instance.new("UICorner",bar); brc.CornerRadius=UDim.new(1,0)
    local fmt=function(v) return isFloat and string.format("%.2f",v) or tostring(math.floor(v)) end
    local lbl=Instance.new("TextLabel",con)
    lbl.Size=UDim2.new(1,-12,0,20); lbl.Position=UDim2.new(0,14,0,6)
    lbl.BackgroundTransparency=1; lbl.TextColor3=C.text
    lbl.Font=Enum.Font.Gotham; lbl.TextSize=11
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Text=label..":  "..fmt(defV)
    local track=Instance.new("Frame",con)
    track.Size=UDim2.new(1,-24,0,5); track.Position=UDim2.new(0,14,0,34)
    track.BackgroundColor3=C.track; track.BorderSizePixel=0
    local tc=Instance.new("UICorner",track); tc.CornerRadius=UDim.new(1,0)
    local pct=math.clamp((defV-minV)/(maxV-minV),0,1)
    local fill=Instance.new("Frame",track)
    fill.Size=UDim2.new(pct,0,1,0); fill.BackgroundColor3=ac; fill.BorderSizePixel=0
    local fc=Instance.new("UICorner",fill); fc.CornerRadius=UDim.new(1,0)
    local handle=Instance.new("Frame",track)
    handle.Size=UDim2.new(0,14,0,14); handle.Position=UDim2.new(pct,-7,0.5,-7)
    handle.BackgroundColor3=C.white; handle.BorderSizePixel=0
    local hc=Instance.new("UICorner",handle); hc.CornerRadius=UDim.new(1,0)
    local hb=Instance.new("TextButton",track)
    hb.Size=UDim2.new(1,0,0,32); hb.Position=UDim2.new(0,0,0.5,-16)
    hb.BackgroundTransparency=1; hb.Text=""
    local sdrag=false
    local function applyDrag(px)
        local t=math.clamp((px-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        local v=isFloat and (minV+t*(maxV-minV)) or math.floor(minV+t*(maxV-minV))
        fill.Size=UDim2.new(t,0,1,0); handle.Position=UDim2.new(t,-7,0.5,-7)
        lbl.Text=label..":  "..fmt(v); cb(v)
    end
    hb.MouseButton1Down:Connect(function(x) sdrag=true; applyDrag(x) end)
    UserInput.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then sdrag=false end
    end)
    UserInput.InputChanged:Connect(function(i)
        if sdrag and i.UserInputType==Enum.UserInputType.MouseMove then applyDrag(i.Position.X) end
    end)
    return con
end

local function mkButton(p,label,cb,danger)
    local ac=danger and C.danger or C.accent
    local ac2=danger and C.danger2 or C.accent2
    local btn=Instance.new("TextButton",p)
    btn.Size=UDim2.new(1,0,0,32); btn.BackgroundColor3=ac
    btn.TextColor3=C.white; btn.Font=Enum.Font.GothamBold
    btn.TextSize=12; btn.Text=label; btn.BorderSizePixel=0
    local bc=Instance.new("UICorner",btn); bc.CornerRadius=UDim.new(0,7)
    local bg=Instance.new("UIGradient",btn)
    bg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,ac),ColorSequenceKeypoint.new(1,ac2)})
    bg.Rotation=90
    btn.MouseEnter:Connect(function()
        TweenSvc:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=ac2}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenSvc:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=ac}):Play()
    end)
    btn.MouseButton1Click:Connect(cb); return btn
end

local function mkTextInput(p,placeholder,onChange)
    local con=Instance.new("Frame",p)
    con.Size=UDim2.new(1,0,0,32); con.BackgroundColor3=C.card; con.BorderSizePixel=0
    local cc=Instance.new("UICorner",con); cc.CornerRadius=UDim.new(0,7)
    local stroke=Instance.new("UIStroke",con)
    stroke.Color=C.div; stroke.Thickness=1; stroke.Transparency=0.3
    local tb=Instance.new("TextBox",con)
    tb.Size=UDim2.new(1,-20,1,0); tb.Position=UDim2.new(0,10,0,0)
    tb.BackgroundTransparency=1; tb.TextColor3=C.text
    tb.PlaceholderColor3=C.muted; tb.PlaceholderText=placeholder
    tb.Font=Enum.Font.Gotham; tb.TextSize=12
    tb.TextXAlignment=Enum.TextXAlignment.Left; tb.Text=""
    tb.FocusLost:Connect(function() if onChange then onChange(tb.Text) end end)
    return con,tb
end

-- ══════════════════════════════════════════════════
-- TAB SİSTEMİ
-- ══════════════════════════════════════════════════
local tabFrames,tabBtns,activeTab={},{},nil

local function switchTab(name)
    for n,f in pairs(tabFrames) do f.Visible=(n==name) end
    for n,b in pairs(tabBtns) do
        if n==name then
            b.BackgroundTransparency=0
            b.BackgroundColor3=Color3.fromRGB(22,16,40)
            b.TextColor3=C.white
            if b:FindFirstChild("indicator") then
                b.indicator.BackgroundTransparency=0
            end
        else
            b.BackgroundTransparency=1
            b.TextColor3=C.muted
            if b:FindFirstChild("indicator") then
                b.indicator.BackgroundTransparency=1
            end
        end
    end
    activeTab=name
end

local function addTab(name,icon,danger)
    local sf=newSF(); tabFrames[name]=sf
    local btn=Instance.new("TextButton",TabBar)
    btn.Name=name
    btn.Size=UDim2.new(1,0,0,36); btn.BackgroundTransparency=1
    btn.TextColor3=C.muted; btn.Font=Enum.Font.Gotham
    btn.TextSize=12; btn.Text=icon.."  "..name
    btn.TextXAlignment=Enum.TextXAlignment.Left; btn.BorderSizePixel=0
    local bc=Instance.new("UICorner",btn); bc.CornerRadius=UDim.new(0,7)
    -- aktif indicator
    local ind=Instance.new("Frame",btn); ind.Name="indicator"
    ind.Size=UDim2.new(0,3,0.6,0); ind.Position=UDim2.new(0,0,0.2,0)
    ind.BackgroundColor3=danger and C.danger or C.accent2
    ind.BackgroundTransparency=1; ind.BorderSizePixel=0
    local ic=Instance.new("UICorner",ind); ic.CornerRadius=UDim.new(1,0)
    tabBtns[name]=btn
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    btn.MouseEnter:Connect(function()
        if activeTab~=name then
            TweenSvc:Create(btn,TweenInfo.new(0.1),{
                BackgroundTransparency=0.85,
                BackgroundColor3=danger and C.danger or C.accent
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

-- ══════════════════════════════════════════════════
-- ─── ESP ─────────────────────────────────────────
-- ══════════════════════════════════════════════════
local espTab=addTab("ESP","👁")
mkHead(espTab,"görünürlük")
mkToggle(espTab,"ESP  (duvardan görme)",
    function() return Cfg.espOn end,function(v) Cfg.espOn=v end)

-- Renk
local cRow=Instance.new("Frame",espTab)
cRow.Size=UDim2.new(1,0,0,42); cRow.BackgroundColor3=C.card; cRow.BorderSizePixel=0
local crc=Instance.new("UICorner",cRow); crc.CornerRadius=UDim.new(0,7)
local cbar=Instance.new("Frame",cRow); cbar.Size=UDim2.new(0,3,0.6,0); cbar.Position=UDim2.new(0,0,0.2,0)
cbar.BackgroundColor3=C.accent; cbar.BorderSizePixel=0
local cbrc=Instance.new("UICorner",cbar); cbrc.CornerRadius=UDim.new(1,0)
local cLbl=Instance.new("TextLabel",cRow)
cLbl.Size=UDim2.new(0,64,1,0); cLbl.Position=UDim2.new(0,14,0,0)
cLbl.BackgroundTransparency=1; cLbl.TextColor3=C.text
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
    dot.Size=UDim2.new(0,20,0,20); dot.Position=UDim2.new(0,76+(i-1)*26,0.5,-10)
    dot.BackgroundColor3=c; dot.Text=""; dot.BorderSizePixel=2
    dot.BorderColor3=Color3.fromRGB(0,0,0)
    local dc=Instance.new("UICorner",dot); dc.CornerRadius=UDim.new(1,0)
    local cc=c
    dot.MouseButton1Click:Connect(function()
        Cfg.espColor=cc
        for _,h in pairs(espHL) do pcall(function() h.FillColor=cc; h.OutlineColor=cc end) end
        if selDot then selDot.BorderColor3=Color3.fromRGB(0,0,0) end
        dot.BorderColor3=Color3.fromRGB(255,255,255); selDot=dot
    end)
end
mkSlider(espTab,"Fill Opaklık (düşük=şeffaf)",0,1,0.65,true,function(v) Cfg.espFill=v end)

-- ══════════════════════════════════════════════════
-- ─── COMBAT ──────────────────────────────────────
-- ══════════════════════════════════════════════════
local combatTab=addTab("Combat","🎯")
mkHead(combatTab,"görsel aimbot  —  sağ tık")
mkToggle(combatTab,"Aimbot",function() return Cfg.aimbotOn end,function(v) Cfg.aimbotOn=v end)
mkToggle(combatTab,"FOV Dairesi",function() return Cfg.showFOV end,function(v) Cfg.showFOV=v end)
mkSlider(combatTab,"FOV Yarıçapı",30,500,150,false,function(v) Cfg.aimbotFOV=v end)
mkSlider(combatTab,"Smooth  (düşük=hızlı)",0.02,0.6,0.18,true,function(v) Cfg.aimbotSmooth=v end)
-- Hedef seçimi
local pRow=Instance.new("Frame",combatTab)
pRow.Size=UDim2.new(1,0,0,32); pRow.BackgroundColor3=C.card; pRow.BorderSizePixel=0
local prc=Instance.new("UICorner",pRow); prc.CornerRadius=UDim.new(0,7)
local pLbl=Instance.new("TextLabel",pRow)
pLbl.Size=UDim2.new(0.45,0,1,0); pLbl.Position=UDim2.new(0,14,0,0)
pLbl.BackgroundTransparency=1; pLbl.TextColor3=C.text
pLbl.Font=Enum.Font.Gotham; pLbl.TextSize=12
pLbl.TextXAlignment=Enum.TextXAlignment.Left; pLbl.Text="Hedef:  Head"
local function mkPB(lbl,xOff,part)
    local b=Instance.new("TextButton",pRow)
    b.Size=UDim2.new(0,76,0,22); b.Position=UDim2.new(1,xOff,0.5,-11)
    b.BackgroundColor3=part==Cfg.aimbotPart and C.accent or C.track
    b.TextColor3=C.white; b.Font=Enum.Font.GothamBold
    b.TextSize=10; b.Text=lbl; b.BorderSizePixel=0
    local bc=Instance.new("UICorner",b); bc.CornerRadius=UDim.new(0,5); return b
end
local hBtn=mkPB("Head",-162,"Head")
local tBtn=mkPB("Torso",-80,"HumanoidRootPart")
hBtn.MouseButton1Click:Connect(function()
    Cfg.aimbotPart="Head"; pLbl.Text="Hedef:  Head"
    hBtn.BackgroundColor3=C.accent; tBtn.BackgroundColor3=C.track end)
tBtn.MouseButton1Click:Connect(function()
    Cfg.aimbotPart="HumanoidRootPart"; pLbl.Text="Hedef:  Torso"
    tBtn.BackgroundColor3=C.accent; hBtn.BackgroundColor3=C.track end)

mkHead(combatTab,"silent aim")
mkToggle(combatTab,"Silent Aim",function() return Cfg.silentOn end,function(v) Cfg.silentOn=v end)
mkSlider(combatTab,"Silent FOV",30,600,250,false,function(v) Cfg.silentFOV=v end)
mkHead(combatTab,"magic bullet")
mkToggle(combatTab,"Magic Bullet  (hitbox genişlet)",function() return Cfg.magicOn end,function(v) Cfg.magicOn=v end)
mkSlider(combatTab,"Hitbox Boyutu",2,30,8,false,function(v) Cfg.magicSize=v end)
mkHead(combatTab,"kill aura")
mkToggle(combatTab,"Kill Aura",function() return Cfg.killAura end,function(v) Cfg.killAura=v end)
mkSlider(combatTab,"Kill Range (studs)",5,100,20,false,function(v) Cfg.killRange=v end)

-- ══════════════════════════════════════════════════
-- ─── HAREKET ─────────────────────────────────────
-- ══════════════════════════════════════════════════
local moveTab=addTab("Hareket","🏃")
mkHead(moveTab,"fly")
mkToggle(moveTab,"Fly  (W/A/S/D · Space · Shift)",function() return Cfg.flyOn end,function(v) Cfg.flyOn=v end)
mkSlider(moveTab,"Fly Hızı",20,300,60,false,function(v) Cfg.flySpeed=v end)
mkHead(moveTab,"hareket")
mkToggle(moveTab,"Noclip",function() return Cfg.noclipOn end,function(v) Cfg.noclipOn=v end)
mkToggle(moveTab,"Sonsuz Zıplama",function() return Cfg.infJump end,function(v) Cfg.infJump=v end)
mkToggle(moveTab,"Bhop",function() return Cfg.bhop end,function(v) Cfg.bhop=v end)
mkToggle(moveTab,"Spin  (kendi etrafında dön)",function() return Cfg.spinSelf end,function(v) Cfg.spinSelf=v end)
mkSlider(moveTab,"WalkSpeed",16,500,16,false,function(v)
    Cfg.walkSpeed=v; local h=getHum(); if h then h.WalkSpeed=v end end)
mkSlider(moveTab,"JumpPower",7,300,50,false,function(v)
    Cfg.jumpPower=v; local h=getHum(); if h then h.JumpPower=v end end)
mkSlider(moveTab,"Yerçekimi",0,400,196,false,function(v)
    Cfg.gravity=v; pcall(function() workspace.Gravity=v end) end)
mkHead(moveTab,"karakter")
mkToggle(moveTab,"God Mode",function() return Cfg.godMode end,function(v) Cfg.godMode=v end)
mkToggle(moveTab,"Invisible  (kendin görürsün)",function() return Cfg.invisible end,function(v) Cfg.invisible=v end)
mkToggle(moveTab,"Anti-AFK",function() return Cfg.antiAFK end,function(v) Cfg.antiAFK=v end)

-- ══════════════════════════════════════════════════
-- ─── TROLL ───────────────────────────────────────
-- ══════════════════════════════════════════════════
local trollTab=addTab("Troll","💀",true)
mkHead(trollTab,"toplu saldırı",C.danger)

mkButton(trollTab,"💥  Herkesi Fırlat",function()
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp and plr.Character then
            local hrp=plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then pcall(function()
                local bv=Instance.new("BodyVelocity",hrp)
                bv.Velocity=Vector3.new(math.random(-40,40),Cfg.launchPow,math.random(-40,40))
                bv.MaxForce=Vector3.new(1e5,1e5,1e5)
                Debris:AddItem(bv,0.15)
            end) end
        end
    end
end,true)
mkSlider(trollTab,"Fırlatma Gücü",50,500,120,false,function(v) Cfg.launchPow=v end,true)

mkButton(trollTab,"📌  Herkesi Üst Üste Stack",function()
    local hrp=getHRP(); if not hrp then return end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp and plr.Character then
            local ehr=plr.Character:FindFirstChild("HumanoidRootPart")
            if ehr then pcall(function() ehr.CFrame=hrp.CFrame+Vector3.new(0,2,0) end) end
        end
    end
end,true)

mkHead(trollTab,"sürekli efektler",C.danger)
mkToggle(trollTab,"Freeze All  (herkesi dondur)",function() return Cfg.freezeAll end,function(v) Cfg.freezeAll=v end,true)
mkToggle(trollTab,"Spin All  (herkesi döndür)",function() return Cfg.spinAll end,function(v) Cfg.spinAll=v end,true)
mkToggle(trollTab,"Annoy  (herkese sürekli TP)",function() return Cfg.annoyOn end,function(v) Cfg.annoyOn=v end,true)
mkSlider(trollTab,"Spin Hızı (derece)",1,30,8,false,function(v) Cfg.spinAllSpeed=v end,true)

mkHead(trollTab,"boyut",C.danger)
mkSlider(trollTab,"Scale All (1=normal)",0.1,5,1,true,function(v)
    Cfg.scaleAll=v
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp and plr.Character then
            local hum=plr.Character:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function()
                hum.BodyDepthScale.Value=v
                hum.BodyHeightScale.Value=v
                hum.BodyWidthScale.Value=v
                hum.HeadScale.Value=v
            end) end
        end
    end
end,true)

mkHead(trollTab,"chat spam",C.danger)
mkToggle(trollTab,"Chat Spam",function() return Cfg.chatSpam end,function(v) Cfg.chatSpam=v end,true)
local _,chatInput=mkTextInput(trollTab,"Mesaj yaz...  (Enter ile kaydet)",function(txt)
    if txt and txt~="" then Cfg.chatMsg=txt end
end)

-- ══════════════════════════════════════════════════
-- ─── OYUNCULAR ───────────────────────────────────
-- ══════════════════════════════════════════════════
local playTab=addTab("Oyuncular","👥")
mkHead(playTab,"toplu tp")
mkButton(playTab,"⬇  Herkesi Yanıma Çek",function()
    local hrp=getHRP(); if not hrp then return end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp and plr.Character then
            local ehr=plr.Character:FindFirstChild("HumanoidRootPart")
            if ehr then pcall(function()
                ehr.CFrame=hrp.CFrame+Vector3.new(math.random(-5,5),0,math.random(-5,5))
            end) end
        end
    end
end)
mkButton(playTab,"🎲  Rastgele Birine TP",function()
    local pool={}
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(pool,plr) end end
    if #pool==0 then return end
    local t=pool[math.random(1,#pool)]; local hrp=getHRP()
    if hrp then pcall(function()
        hrp.CFrame=t.Character.HumanoidRootPart.CFrame+Vector3.new(2,0,0) end) end
end)
mkHead(playTab,"liste")
local plH=Instance.new("Frame",playTab)
plH.Size=UDim2.new(1,0,0,0); plH.BackgroundTransparency=1
local plL=Instance.new("UIListLayout",plH)
plL.Padding=UDim.new(0,4); plL.SortOrder=Enum.SortOrder.LayoutOrder
plL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    plH.Size=UDim2.new(1,0,0,plL.AbsoluteContentSize.Y) end)

local function refreshList()
    for _,c in ipairs(plH:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp then
            local row=Instance.new("Frame",plH)
            row.Size=UDim2.new(1,0,0,30); row.BackgroundColor3=C.card; row.BorderSizePixel=0
            local rc=Instance.new("UICorner",row); rc.CornerRadius=UDim.new(0,7)
            local nl=Instance.new("TextLabel",row)
            nl.Size=UDim2.new(1,-68,1,0); nl.Position=UDim2.new(0,10,0,0)
            nl.BackgroundTransparency=1; nl.TextColor3=C.text
            nl.Font=Enum.Font.Gotham; nl.TextSize=11
            nl.TextXAlignment=Enum.TextXAlignment.Left
            nl.Text=plr.DisplayName.."  (@"..plr.Name..")"
            nl.TextTruncate=Enum.TextTruncate.AtEnd
            local tb=Instance.new("TextButton",row)
            tb.Size=UDim2.new(0,56,0,22); tb.Position=UDim2.new(1,-62,0.5,-11)
            tb.BackgroundColor3=C.accent; tb.TextColor3=C.white
            tb.Font=Enum.Font.GothamBold; tb.TextSize=10; tb.Text="TP Git"; tb.BorderSizePixel=0
            local tc=Instance.new("UICorner",tb); tc.CornerRadius=UDim.new(0,5)
            local cp=plr
            tb.MouseButton1Click:Connect(function()
                local hrp=getHRP()
                if hrp and cp.Character and cp.Character:FindFirstChild("HumanoidRootPart") then
                    pcall(function() hrp.CFrame=cp.Character.HumanoidRootPart.CFrame+Vector3.new(2,0,0) end)
                end
            end)
        end
    end
end
mkButton(playTab,"🔄  Yenile",function() refreshList() end)
refreshList()

switchTab("ESP")

-- ══════════════════════════════════════════════════
-- 8 TUŞU
-- ══════════════════════════════════════════════════
local openY=Main.Position.Y.Offset
local closeY=openY+H+60
UserInput.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if inp.KeyCode~=Enum.KeyCode.Eight then return end
    guiOpen=not guiOpen
    if guiOpen then
        Main.Visible=true
        TweenSvc:Create(Main,TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{
            Position=UDim2.new(Main.Position.X.Scale,Main.Position.X.Offset,Main.Position.Y.Scale,openY)
        }):Play()
    else
        local tw=TweenSvc:Create(Main,TweenInfo.new(0.22,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{
            Position=UDim2.new(Main.Position.X.Scale,Main.Position.X.Offset,Main.Position.Y.Scale,closeY)
        })
        tw:Play(); tw.Completed:Connect(function() Main.Visible=false end)
    end
end)

-- ══════════════════════════════════════════════════
-- FOV DAİRESİ
-- ══════════════════════════════════════════════════
local fovC=nil
pcall(function()
    fovC=Drawing.new("Circle")
    fovC.Visible=false; fovC.Thickness=1.5
    fovC.Color=Color3.fromRGB(220,220,220)
    fovC.Filled=false; fovC.NumSides=64
end)

-- ══════════════════════════════════════════════════
-- FLY
-- ══════════════════════════════════════════════════
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

-- ══════════════════════════════════════════════════
-- ESP — iterate-safe
-- ══════════════════════════════════════════════════
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
                    h.FillTransparency=Cfg.espFill; h.OutlineTransparency=0
                    h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                    h.Adornee=plr.Character; h.Parent=workspace
                    espHL[plr.UserId]=h
                end)
            else
                pcall(function()
                    espHL[plr.UserId].FillColor=Cfg.espColor
                    espHL[plr.UserId].OutlineColor=Cfg.espColor
                    espHL[plr.UserId].FillTransparency=Cfg.espFill
                end)
            end
        end
    end
end

-- ══════════════════════════════════════════════════
-- AİMBOT HEDEF
-- ══════════════════════════════════════════════════
local function getAimTarget()
    local cx=Camera.ViewportSize.X/2; local cy=Camera.ViewportSize.Y/2
    local best,bd=nil,math.huge
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp and plr.Character then
            local part=plr.Character:FindFirstChild(Cfg.aimbotPart)
            if part then
                local ok,sp,vis=pcall(function() return Camera:WorldToScreenPoint(part.Position) end)
                if ok and vis then
                    local d=math.sqrt((sp.X-cx)^2+(sp.Y-cy)^2)
                    if d<Cfg.aimbotFOV and d<bd then bd=d; best=part end
                end
            end
        end
    end
    return best
end

-- ══════════════════════════════════════════════════
-- SONSUZ ZIPLAMAMA
-- ══════════════════════════════════════════════════
UserInput.JumpRequest:Connect(function()
    if Cfg.infJump then
        local h=getHum()
        if h then pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end) end
    end
end)

-- ══════════════════════════════════════════════════
-- RENDERSTEPPED
-- ══════════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    pcall(updateESP)

    if Cfg.flyOn~=prevFly then
        if Cfg.flyOn then enableFly() else disableFly() end
        prevFly=Cfg.flyOn
    end

    if Cfg.flyOn and flyBody.bv and flyBody.bg then
        pcall(function()
            local cf=Camera.CFrame; local dir=Vector3.zero
            if UserInput:IsKeyDown(Enum.KeyCode.W) then dir=dir+cf.LookVector end
            if UserInput:IsKeyDown(Enum.KeyCode.S) then dir=dir-cf.LookVector end
            if UserInput:IsKeyDown(Enum.KeyCode.A) then dir=dir-cf.RightVector end
            if UserInput:IsKeyDown(Enum.KeyCode.D) then dir=dir+cf.RightVector end
            if UserInput:IsKeyDown(Enum.KeyCode.Space) then dir=dir+Vector3.new(0,1,0) end
            if UserInput:IsKeyDown(Enum.KeyCode.LeftShift) then dir=dir-Vector3.new(0,1,0) end
            flyBody.bv.Velocity=dir.Magnitude>0 and dir.Unit*Cfg.flySpeed or Vector3.zero
            flyBody.bg.CFrame=cf
        end)
    end

    if Cfg.noclipOn then
        pcall(function()
            local c=getChar(); if not c then return end
            for _,p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide=false end
            end
        end)
    end

    if Cfg.spinSelf then
        pcall(function()
            local hrp=getHRP(); if not hrp then return end
            hrp.CFrame=hrp.CFrame*CFrame.Angles(0,math.rad(Cfg.spinSpeed),0)
        end)
    end

    if Cfg.invisible then
        pcall(function()
            local c=getChar(); if not c then return end
            for _,p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
                    p.LocalTransparencyModifier=1
                end
            end
        end)
    end

    if Cfg.aimbotOn and UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        pcall(function()
            local t=getAimTarget()
            if t then
                Camera.CFrame=Camera.CFrame:Lerp(
                    CFrame.lookAt(Camera.CFrame.Position,t.Position),Cfg.aimbotSmooth)
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

-- ══════════════════════════════════════════════════
-- STEPPED
-- ══════════════════════════════════════════════════
RunService.Stepped:Connect(function()
    local now=tick()
    pcall(function()
        local h=getHum()
        if h then
            if not Cfg.flyOn then h.WalkSpeed=Cfg.walkSpeed; h.JumpPower=Cfg.jumpPower end
            if Cfg.godMode then h.Health=h.MaxHealth end
            if Cfg.bhop and h:GetState()==Enum.HumanoidStateType.Landed then
                h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)

    -- Kill Aura
    if Cfg.killAura then pcall(function()
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
    end) end

    -- Freeze All
    if Cfg.freezeAll then pcall(function()
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=lp and plr.Character then
                local ehr=plr.Character:FindFirstChild("HumanoidRootPart")
                if ehr then ehr.Anchored=true end
            end
        end
    end) else pcall(function()
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=lp and plr.Character then
                local ehr=plr.Character:FindFirstChild("HumanoidRootPart")
                if ehr and ehr.Anchored then ehr.Anchored=false end
            end
        end
    end) end

    -- Spin All
    if Cfg.spinAll then pcall(function()
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=lp and plr.Character then
                local ehr=plr.Character:FindFirstChild("HumanoidRootPart")
                if ehr then ehr.CFrame=ehr.CFrame*CFrame.Angles(0,math.rad(Cfg.spinAllSpeed),0) end
            end
        end
    end) end

    -- Annoy — her 0.4s'de bir
    if Cfg.annoyOn and now-lastAnnoy>0.4 then
        lastAnnoy=now
        pcall(function()
            local list={}
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr~=lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    table.insert(list,plr) end end
            if #list==0 then return end
            annoyIndex=annoyIndex%#list+1
            local t=list[annoyIndex]; local hrp=getHRP()
            if hrp and t.Character then
                local ehr=t.Character:FindFirstChild("HumanoidRootPart")
                if ehr then hrp.CFrame=ehr.CFrame+Vector3.new(1,0,0) end
            end
        end)
    end

    -- Chat Spam — her 2s'de bir
    if Cfg.chatSpam and now-lastChat>2 then
        lastChat=now
        pcall(function()
            local rs=game:GetService("ReplicatedStorage")
            local ev=rs:FindFirstChild("DefaultChatSystemChatEvents")
            if ev then
                local say=ev:FindFirstChild("SayMessageRequest")
                if say then say:FireServer(Cfg.chatMsg,"All") end
            end
        end)
    end
end)

print("[ZXC v6]  8 = kapat/aç  |  troll kataloğu aktif")
