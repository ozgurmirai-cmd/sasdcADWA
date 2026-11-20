-- ZXC v8 | Synapse X / KRNL / Fluxus
-- key: 4444 | magic bullet=namecall hook | kill all=tool fire | hitmarker | kill counter

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput  = game:GetService("UserInputService")
local TweenSvc   = game:GetService("TweenService")
local Lighting   = game:GetService("Lighting")
local Debris     = game:GetService("Debris")
local Camera     = workspace.CurrentCamera
local lp         = Players.LocalPlayer
local mouse      = lp:GetMouse()

local C = {
    bg=Color3.fromRGB(8,8,14), sidebar=Color3.fromRGB(6,6,10),
    card=Color3.fromRGB(15,15,24), cardH=Color3.fromRGB(19,19,30),
    acc=Color3.fromRGB(108,60,240), acc2=Color3.fromRGB(148,95,255),
    accD=Color3.fromRGB(70,35,180),
    danger=Color3.fromRGB(215,48,48), danger2=Color3.fromRGB(255,72,72),
    gold=Color3.fromRGB(255,195,45), gold2=Color3.fromRGB(255,220,80),
    ok=Color3.fromRGB(38,195,88),
    text=Color3.fromRGB(218,218,232), muted=Color3.fromRGB(95,95,120),
    white=Color3.fromRGB(255,255,255), track=Color3.fromRGB(26,26,42),
    div=Color3.fromRGB(30,30,48), keyBg=Color3.fromRGB(5,5,9),
}

local Cfg = {
    espOn=false, espColor=Color3.fromRGB(255,50,50), espFill=0.65,
    tracersOn=false, hbarsOn=false, nametagOn=false,
    aimbotOn=false, aimbotFOV=150, aimbotSmooth=0.18, aimbotPart="Head",
    showFOV=false,
    silentOn=false, silentFOV=250,
    magicBullet=false, magicDamage=25,
    autoShoot=false, autoKill=false,
    killAura=false, killRange=20,
    hitmarker=false,
    flyOn=false, flySpeed=60,
    noclipOn=false,
    walkSpeed=16, jumpPower=50,
    infJump=false, bhop=false,
    gravity=196, spinSelf=false, spinSpeed=8,
    godMode=false, invisible=false,
    antiAFK=false, noFall=false, clickTP=false,
    fullBright=false, noFog=false,
    fov=70, crosshairOn=false, crosshairSize=10,
    freezeAll=false, spinAll=false, spinAllSpd=8,
    launchPow=130, annoyOn=false,
    scaleAll=1, chatSpam=false, chatMsg="ZXC",
    ragdollAll=false,
}

local flyBody={} local espHL={} local prevFly=false
local guiOpen=true local annoyIdx=1
local lastChat=0 local lastAnnoy=0 local lastAutoKill=0
local killCount=0

local function getChar() return lp.Character end
local function getHRP()  local c=getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c=getChar(); return c and c:FindFirstChildOfClass("Humanoid") end

lp.CharacterAdded:Connect(function()
    for _,h in pairs(espHL) do pcall(function() h:Destroy() end) end
    espHL={}; prevFly=false; flyBody={}
end)

lp.Idled:Connect(function()
    if Cfg.antiAFK then pcall(function()
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.zero)
    end) end
end)

-- ════════════════════════════════════════════════
-- AIM HEDEF
-- ════════════════════════════════════════════════
local function getAimTarget(fov,part)
    fov=fov or Cfg.aimbotFOV; part=part or Cfg.aimbotPart
    local cx=Camera.ViewportSize.X/2; local cy=Camera.ViewportSize.Y/2
    local best,bd=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and p.Character then
            local pt=p.Character:FindFirstChild(part) or p.Character:FindFirstChild("HumanoidRootPart")
            if pt then
                local ok,sp,vis=pcall(function() return Camera:WorldToScreenPoint(pt.Position) end)
                if ok and vis then
                    local d=math.sqrt((sp.X-cx)^2+(sp.Y-cy)^2)
                    if d<fov and d<bd then bd=d; best=pt end
                end
            end
        end
    end
    return best
end

local function getSilentTarget()
    local cx=Camera.ViewportSize.X/2; local cy=Camera.ViewportSize.Y/2
    local best,bd=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and p.Character then
            local pt=p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
            if pt then
                local ok,sp,vis=pcall(function() return Camera:WorldToScreenPoint(pt.Position) end)
                if ok and vis then
                    local d=math.sqrt((sp.X-cx)^2+(sp.Y-cy)^2)
                    if d<Cfg.silentFOV and d<bd then bd=d; best=pt end
                end
            end
        end
    end
    return best
end

-- ════════════════════════════════════════════════
-- SILENT AIM -- raycast hook
-- ════════════════════════════════════════════════
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
    workspace.Raycast=function(self,og,dir,p)
        if Cfg.silentOn then local t=getSilentTarget()
            if t then pcall(function() dir=(t.Position-og).Unit*dir.Magnitude end) end end
        return o(self,og,dir,p) end
end)

-- ════════════════════════════════════════════════
-- MAGIC BULLET -- __namecall FireServer intercept
-- duvardan calisir: server'a giden hit pozisyonunu
-- hedefin pozisyonuna cevirir
-- ════════════════════════════════════════════════
pcall(function()
    local mt=getrawmetatable(game)
    local oldNC=mt.__namecall
    setreadonly(mt,false)
    mt.__namecall=newcclosure(function(self,...)
        local method=getnamecallmethod()
        if Cfg.magicBullet and method=="FireServer" then
            if pcall(function() return self:IsA("RemoteEvent") end) and self:IsA("RemoteEvent") then
                local args={...}
                local target=getAimTarget(math.huge,Cfg.aimbotPart)
                if target then
                    for i,arg in ipairs(args) do
                        if typeof(arg)=="CFrame" then
                            args[i]=CFrame.new(target.Position); break
                        elseif typeof(arg)=="Vector3" then
                            args[i]=target.Position; break
                        end
                    end
                    -- target instance argumani da degistir
                    for i,arg in ipairs(args) do
                        if typeof(arg)=="Instance" and pcall(function() return arg:IsA("BasePart") end) and arg:IsA("BasePart") then
                            args[i]=target; break
                        end
                    end
                    return oldNC(self,table.unpack(args))
                end
            end
        end
        return oldNC(self,...)
    end)
    setreadonly(mt,true)
end)

-- ════════════════════════════════════════════════
-- HITMARKER
-- ════════════════════════════════════════════════
local hmLines={}
pcall(function()
    for i=1,4 do
        local l=Drawing.new("Line")
        l.Color=Color3.fromRGB(255,255,255); l.Thickness=1.8
        l.Transparency=0; l.Visible=false
        hmLines[i]=l
    end
end)
local hmTimer=0
local function flashHitmarker()
    if #hmLines<4 then return end
    hmTimer=0.3
    local cx=Camera.ViewportSize.X/2; local cy=Camera.ViewportSize.Y/2
    local s=8
    hmLines[1].From=Vector2.new(cx-s,cy-s); hmLines[1].To=Vector2.new(cx-3,cy-3); hmLines[1].Color=Color3.fromRGB(255,60,60)
    hmLines[2].From=Vector2.new(cx+s,cy-s); hmLines[2].To=Vector2.new(cx+3,cy-3); hmLines[2].Color=Color3.fromRGB(255,60,60)
    hmLines[3].From=Vector2.new(cx-s,cy+s); hmLines[3].To=Vector2.new(cx-3,cy+3); hmLines[3].Color=Color3.fromRGB(255,60,60)
    hmLines[4].From=Vector2.new(cx+s,cy+s); hmLines[4].To=Vector2.new(cx+3,cy+3); hmLines[4].Color=Color3.fromRGB(255,60,60)
    for _,l in ipairs(hmLines) do l.Visible=true end
end

-- Kill track -- diger oyuncular olunce say
for _,p in ipairs(Players:GetPlayers()) do
    if p~=lp then
        p.CharacterRemoving:Connect(function()
            if Cfg.hitmarker then flashHitmarker() end
            killCount=killCount+1
        end)
    end
end
Players.PlayerAdded:Connect(function(p)
    p.CharacterRemoving:Connect(function()
        if Cfg.hitmarker then flashHitmarker() end
        killCount=killCount+1
    end)
end)

-- ════════════════════════════════════════════════
-- KILL ALL -- tool fire + TakeDamage
-- ════════════════════════════════════════════════
local function killAll()
    local char=getChar(); if not char then return end
    local hum=getHum(); if not hum then return end

    -- Elindeki tool'u bul, yoksa backpack'ten al
    local tool=char:FindFirstChildOfClass("Tool")
    if not tool then
        for _,item in ipairs(lp.Backpack:GetChildren()) do
            if item:IsA("Tool") then
                pcall(function() hum:EquipTool(item) end)
                task.wait(0.12); tool=char:FindFirstChildOfClass("Tool"); break
            end
        end
    end

    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and p.Character then
            local ehr=p.Character:FindFirstChild("HumanoidRootPart")
            local head=p.Character:FindFirstChild("Head")
            local plrHum=p.Character:FindFirstChildOfClass("Humanoid")
            if ehr then
                -- Method 1: tool ile ates et
                if tool and head then
                    local hrp=getHRP()
                    if hrp then
                        pcall(function()
                            local origCF=hrp.CFrame
                            hrp.CFrame=CFrame.lookAt(hrp.Position,head.Position)
                            task.wait(0.02)
                            tool:Activate()
                            task.wait(0.06)
                            hrp.CFrame=origCF
                        end)
                    end
                end
                -- Method 2: TakeDamage fallback
                if plrHum then
                    pcall(function() plrHum:TakeDamage(plrHum.MaxHealth) end)
                end
                -- Method 3: tool remote fire
                if tool then
                    for _,v in ipairs(tool:GetDescendants()) do
                        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                            pcall(function()
                                v:FireServer(CFrame.new(ehr.Position), ehr, head)
                            end)
                        end
                    end
                end
            end
        end
    end
end

-- ════════════════════════════════════════════════
-- SCREENGU
-- ════════════════════════════════════════════════
local sg=Instance.new("ScreenGui")
sg.Name="ZXCv8"; sg.ResetOnSpawn=false
sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
sg.Parent=game:GetService("CoreGui")

-- ════════════════════════════════════════════════
-- KEY EKRANI
-- ════════════════════════════════════════════════
local KS=Instance.new("Frame",sg)
KS.Size=UDim2.new(1,0,1,0); KS.BackgroundColor3=C.keyBg; KS.BorderSizePixel=0; KS.ZIndex=50
local kGrad=Instance.new("UIGradient",KS)
kGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(6,4,14)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(10,6,20))}); kGrad.Rotation=135

local kBox=Instance.new("Frame",KS)
kBox.Size=UDim2.new(0,320,0,230); kBox.Position=UDim2.new(0.5,-160,0.5,-115)
kBox.BackgroundColor3=Color3.fromRGB(11,11,18); kBox.BorderSizePixel=0; kBox.ZIndex=51
local kbc=Instance.new("UICorner",kBox); kbc.CornerRadius=UDim.new(0,14)
local kSt=Instance.new("UIStroke",kBox); kSt.Color=C.acc; kSt.Thickness=1.5; kSt.Transparency=0.4

local kTB=Instance.new("Frame",kBox)
kTB.Size=UDim2.new(1,0,0,4); kTB.BackgroundColor3=C.acc; kTB.BorderSizePixel=0; kTB.ZIndex=52
local ktbc=Instance.new("UICorner",kTB); ktbc.CornerRadius=UDim.new(0,14)
local ktfix=Instance.new("Frame",kTB)
ktfix.Size=UDim2.new(1,0,0.5,0); ktfix.Position=UDim2.new(0,0,0.5,0)
ktfix.BackgroundColor3=C.acc; ktfix.BorderSizePixel=0
local kBarGrad=Instance.new("UIGradient",kTB)
kBarGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,C.accD),
    ColorSequenceKeypoint.new(0.5,C.acc2),ColorSequenceKeypoint.new(1,C.accD)}); kBarGrad.Rotation=90

local function kLabel(txt,size,yPos,color,bold)
    local l=Instance.new("TextLabel",kBox)
    l.Size=UDim2.new(1,0,0,size); l.Position=UDim2.new(0,0,0,yPos)
    l.BackgroundTransparency=1; l.TextColor3=color or C.white
    l.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham
    l.TextSize=size==50 and 24 or 12; l.Text=txt; l.ZIndex=52; return l
end
kLabel("ZXC v8",50,16,C.white,true)
kLabel(">> KEY GIRINIZ",20,58,C.muted,false)

local kIW=Instance.new("Frame",kBox)
kIW.Size=UDim2.new(1,-40,0,38); kIW.Position=UDim2.new(0,20,0,86)
kIW.BackgroundColor3=C.track; kIW.BorderSizePixel=0; kIW.ZIndex=52
local kiwc=Instance.new("UICorner",kIW); kiwc.CornerRadius=UDim.new(0,8)
local kSt2=Instance.new("UIStroke",kIW); kSt2.Color=C.div; kSt2.Thickness=1; kSt2.Transparency=0.3

local kInput=Instance.new("TextBox",kIW)
kInput.Size=UDim2.new(1,-16,1,0); kInput.Position=UDim2.new(0,8,0,0)
kInput.BackgroundTransparency=1; kInput.TextColor3=C.text
kInput.PlaceholderColor3=C.muted; kInput.PlaceholderText="Keyinizi girin..."
kInput.Font=Enum.Font.Gotham; kInput.TextSize=14
kInput.TextXAlignment=Enum.TextXAlignment.Center; kInput.ZIndex=53

local kStatus=Instance.new("TextLabel",kBox)
kStatus.Size=UDim2.new(1,-40,0,20); kStatus.Position=UDim2.new(0,20,0,132)
kStatus.BackgroundTransparency=1; kStatus.TextColor3=C.muted
kStatus.Font=Enum.Font.Gotham; kStatus.TextSize=11; kStatus.Text=""; kStatus.ZIndex=52

local kSubmit=Instance.new("TextButton",kBox)
kSubmit.Size=UDim2.new(1,-40,0,40); kSubmit.Position=UDim2.new(0,20,0,160)
kSubmit.BackgroundColor3=C.acc; kSubmit.TextColor3=C.white
kSubmit.Font=Enum.Font.GothamBold; kSubmit.TextSize=14
kSubmit.Text=">> DEVAM ET"; kSubmit.BorderSizePixel=0; kSubmit.ZIndex=52
local ksbc=Instance.new("UICorner",kSubmit); ksbc.CornerRadius=UDim.new(0,8)
local ksbG=Instance.new("UIGradient",kSubmit)
ksbG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,C.acc),ColorSequenceKeypoint.new(1,C.acc2)})
ksbG.Rotation=90

-- ════════════════════════════════════════════════
-- ANA GUI
-- ════════════════════════════════════════════════
local W,H=648,352

local Main=Instance.new("Frame",sg)
Main.Size=UDim2.new(0,0,0,0); Main.Position=UDim2.new(0.5,0,0.5,0)
Main.BackgroundColor3=C.bg; Main.BorderSizePixel=0
Main.ClipsDescendants=true; Main.Visible=false
local mc=Instance.new("UICorner",Main); mc.CornerRadius=UDim.new(0,13)
local mSt=Instance.new("UIStroke",Main)
mSt.Color=C.acc; mSt.Thickness=1.5; mSt.Transparency=0.45

-- Kill counter overlay
local kcFrame=Instance.new("Frame",sg)
kcFrame.Size=UDim2.new(0,120,0,32); kcFrame.Position=UDim2.new(1,-130,0,10)
kcFrame.BackgroundColor3=C.card; kcFrame.BorderSizePixel=0; kcFrame.Visible=false
local kcfc=Instance.new("UICorner",kcFrame); kcfc.CornerRadius=UDim.new(0,8)
local kcSt=Instance.new("UIStroke",kcFrame); kcSt.Color=C.acc; kcSt.Thickness=1; kcSt.Transparency=0.5
local kcLabel=Instance.new("TextLabel",kcFrame)
kcLabel.Size=UDim2.new(1,0,1,0); kcLabel.BackgroundTransparency=1
kcLabel.TextColor3=C.text; kcLabel.Font=Enum.Font.GothamBold; kcLabel.TextSize=12
kcLabel.Text=">> Oldurulen: 0"

-- Baslik
local TBar=Instance.new("Frame",Main)
TBar.Size=UDim2.new(1,0,0,36); TBar.BackgroundColor3=C.acc; TBar.BorderSizePixel=0
local tbc=Instance.new("UICorner",TBar); tbc.CornerRadius=UDim.new(0,13)
local tbfix=Instance.new("Frame",TBar)
tbfix.Size=UDim2.new(1,0,0.5,0); tbfix.Position=UDim2.new(0,0,0.5,0)
tbfix.BackgroundColor3=C.acc; tbfix.BorderSizePixel=0
local tbG=Instance.new("UIGradient",TBar)
tbG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,C.accD),
    ColorSequenceKeypoint.new(0.4,C.acc2),ColorSequenceKeypoint.new(1,C.accD)}); tbG.Rotation=90
local tbLbl=Instance.new("TextLabel",TBar)
tbLbl.Size=UDim2.new(1,-16,1,0); tbLbl.Position=UDim2.new(0,14,0,0)
tbLbl.BackgroundTransparency=1; tbLbl.TextColor3=C.white
tbLbl.Font=Enum.Font.GothamBold; tbLbl.TextSize=14
tbLbl.TextXAlignment=Enum.TextXAlignment.Left; tbLbl.Text=">> ZXC v8   |   8 = kapat / ac"
local vLbl=Instance.new("TextLabel",TBar)
vLbl.Size=UDim2.new(0,52,0,18); vLbl.Position=UDim2.new(1,-58,0.5,-9)
vLbl.BackgroundColor3=Color3.fromRGB(0,0,0); vLbl.BackgroundTransparency=0.4
vLbl.TextColor3=C.gold; vLbl.Font=Enum.Font.GothamBold; vLbl.TextSize=10
vLbl.Text="UNLIMITED"; vLbl.BorderSizePixel=0
local vlc=Instance.new("UICorner",vLbl); vlc.CornerRadius=UDim.new(0,4)

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

local TabBar=Instance.new("Frame",Main)
TabBar.Size=UDim2.new(0,120,1,-36); TabBar.Position=UDim2.new(0,0,0,36)
TabBar.BackgroundColor3=C.sidebar; TabBar.BorderSizePixel=0
local tbgr=Instance.new("UIGradient",TabBar)
tbgr.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,C.sidebar),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(8,8,13))}); tbgr.Rotation=270
local tll=Instance.new("UIListLayout",TabBar)
tll.Padding=UDim.new(0,2); tll.SortOrder=Enum.SortOrder.LayoutOrder
local tpp=Instance.new("UIPadding",TabBar)
tpp.PaddingTop=UDim.new(0,8); tpp.PaddingLeft=UDim.new(0,6); tpp.PaddingRight=UDim.new(0,6)
local divLine=Instance.new("Frame",Main)
divLine.Size=UDim2.new(0,1,1,-36); divLine.Position=UDim2.new(0,120,0,36)
divLine.BackgroundColor3=C.div; divLine.BorderSizePixel=0

local CA=Instance.new("Frame",Main)
CA.Size=UDim2.new(1,-121,1,-36); CA.Position=UDim2.new(0,121,0,36)
CA.BackgroundTransparency=1; CA.ClipsDescendants=true

-- ════════════════════════════════════════════════
-- UI HELPERS
-- ════════════════════════════════════════════════
local function newSF()
    local sf=Instance.new("ScrollingFrame",CA)
    sf.Size=UDim2.new(1,0,1,0); sf.BackgroundTransparency=1
    sf.BorderSizePixel=0; sf.ScrollBarThickness=3
    sf.ScrollBarImageColor3=C.acc2
    sf.CanvasSize=UDim2.new(0,0,0,0); sf.Visible=false
    local ll=Instance.new("UIListLayout",sf)
    ll.Padding=UDim.new(0,5); ll.SortOrder=Enum.SortOrder.LayoutOrder
    ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize=UDim2.new(0,0,0,ll.AbsoluteContentSize.Y+20) end)
    local pp=Instance.new("UIPadding",sf)
    pp.PaddingTop=UDim.new(0,10); pp.PaddingLeft=UDim.new(0,10); pp.PaddingRight=UDim.new(0,14)
    return sf
end

local function mkHead(p,txt,cl)
    cl=cl or C.acc
    local w=Instance.new("Frame",p); w.Size=UDim2.new(1,0,0,19); w.BackgroundTransparency=1
    local line=Instance.new("Frame",w)
    line.Size=UDim2.new(1,0,0,1); line.Position=UDim2.new(0,0,1,-1)
    line.BackgroundColor3=cl; line.BackgroundTransparency=0.78; line.BorderSizePixel=0
    local l=Instance.new("TextLabel",w)
    l.Size=UDim2.new(1,0,1,-2); l.BackgroundTransparency=1
    l.TextColor3=cl; l.Font=Enum.Font.GothamBold; l.TextSize=10
    l.TextXAlignment=Enum.TextXAlignment.Left; l.Text=">> "..txt:upper()
    return w
end

local function mkToggle(p,label,getS,setS,danger)
    local ac=danger and C.danger or C.acc; local ac2=danger and C.danger2 or C.acc2
    local row=Instance.new("Frame",p)
    row.Size=UDim2.new(1,0,0,32); row.BackgroundColor3=C.card; row.BorderSizePixel=0
    local rc=Instance.new("UICorner",row); rc.CornerRadius=UDim.new(0,8)
    local bar=Instance.new("Frame",row)
    bar.Size=UDim2.new(0,3,0.56,0); bar.Position=UDim2.new(0,0,0.22,0)
    bar.BackgroundColor3=C.muted; bar.BorderSizePixel=0
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
        TweenSvc:Create(pill,TweenInfo.new(0.14),{BackgroundColor3=on and ac or C.track}):Play()
        TweenSvc:Create(knob,TweenInfo.new(0.14),{
            Position=on and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8),
            BackgroundColor3=on and C.white or C.muted
        }):Play()
    end
    local btn=Instance.new("TextButton",row); btn.Size=UDim2.new(1,0,1,0)
    btn.BackgroundTransparency=1; btn.Text=""
    btn.MouseButton1Click:Connect(function() setS(not getS()); refresh() end)
    btn.MouseEnter:Connect(function()
        TweenSvc:Create(row,TweenInfo.new(0.1),{BackgroundColor3=C.cardH}):Play() end)
    btn.MouseLeave:Connect(function()
        TweenSvc:Create(row,TweenInfo.new(0.1),{BackgroundColor3=C.card}):Play() end)
    refresh(); return row
end

local function mkSlider(p,label,minV,maxV,defV,isFloat,cb,danger)
    local ac=danger and C.danger or C.acc
    local con=Instance.new("Frame",p)
    con.Size=UDim2.new(1,0,0,52); con.BackgroundColor3=C.card; con.BorderSizePixel=0
    local cc=Instance.new("UICorner",con); cc.CornerRadius=UDim.new(0,8)
    local bar=Instance.new("Frame",con)
    bar.Size=UDim2.new(0,3,0.52,0); bar.Position=UDim2.new(0,0,0.24,0)
    bar.BackgroundColor3=ac; bar.BorderSizePixel=0
    local brc=Instance.new("UICorner",bar); brc.CornerRadius=UDim.new(1,0)
    local fmt=function(v) return isFloat and string.format("%.2f",v) or tostring(math.floor(v)) end
    local lbl=Instance.new("TextLabel",con)
    lbl.Size=UDim2.new(1,-12,0,20); lbl.Position=UDim2.new(0,14,0,7)
    lbl.BackgroundTransparency=1; lbl.TextColor3=C.text
    lbl.Font=Enum.Font.Gotham; lbl.TextSize=11
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Text=label..":  "..fmt(defV)
    local track=Instance.new("Frame",con)
    track.Size=UDim2.new(1,-24,0,5); track.Position=UDim2.new(0,14,0,35)
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
        if i.UserInputType==Enum.UserInputType.MouseButton1 then sdrag=false end end)
    UserInput.InputChanged:Connect(function(i)
        if sdrag and i.UserInputType==Enum.UserInputType.MouseMove then applyDrag(i.Position.X) end end)
    return con
end

local function mkButton(p,label,cb,danger,gold)
    local ac=gold and C.gold or (danger and C.danger or C.acc)
    local ac2=gold and C.gold2 or (danger and C.danger2 or C.acc2)
    local tc=gold and Color3.fromRGB(20,10,0) or C.white
    local btn=Instance.new("TextButton",p)
    btn.Size=UDim2.new(1,0,0,32); btn.BackgroundColor3=ac
    btn.TextColor3=tc; btn.Font=Enum.Font.GothamBold
    btn.TextSize=12; btn.Text=label; btn.BorderSizePixel=0
    local bc=Instance.new("UICorner",btn); bc.CornerRadius=UDim.new(0,8)
    local bg=Instance.new("UIGradient",btn)
    bg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,ac),ColorSequenceKeypoint.new(1,ac2)})
    bg.Rotation=90
    btn.MouseEnter:Connect(function()
        TweenSvc:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=ac2}):Play() end)
    btn.MouseLeave:Connect(function()
        TweenSvc:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=ac}):Play() end)
    btn.MouseButton1Click:Connect(cb); return btn
end

-- ════════════════════════════════════════════════
-- TAB SISTEMI
-- ════════════════════════════════════════════════
local tabFrames,tabBtns,activeTab={},{},nil
local function switchTab(name)
    for n,f in pairs(tabFrames) do f.Visible=(n==name) end
    for n,b in pairs(tabBtns) do
        if n==name then
            b.BackgroundTransparency=0; b.BackgroundColor3=Color3.fromRGB(20,14,38)
            b.TextColor3=C.white
            if b:FindFirstChild("ind") then b.ind.BackgroundTransparency=0 end
        else
            b.BackgroundTransparency=1; b.TextColor3=C.muted
            if b:FindFirstChild("ind") then b.ind.BackgroundTransparency=1 end
        end
    end; activeTab=name
end

local function addTab(name,sym,danger,gold)
    local ac=gold and C.gold or (danger and C.danger or C.acc2)
    local sf=newSF(); tabFrames[name]=sf
    local btn=Instance.new("TextButton",TabBar)
    btn.Name=name; btn.Size=UDim2.new(1,0,0,36); btn.BackgroundTransparency=1
    btn.TextColor3=C.muted; btn.Font=Enum.Font.Gotham; btn.TextSize=12
    btn.Text=sym.."  "..name; btn.TextXAlignment=Enum.TextXAlignment.Left; btn.BorderSizePixel=0
    local bc=Instance.new("UICorner",btn); bc.CornerRadius=UDim.new(0,7)
    local ind=Instance.new("Frame",btn); ind.Name="ind"
    ind.Size=UDim2.new(0,3,0.58,0); ind.Position=UDim2.new(0,0,0.21,0)
    ind.BackgroundColor3=ac; ind.BackgroundTransparency=1; ind.BorderSizePixel=0
    local ic=Instance.new("UICorner",ind); ic.CornerRadius=UDim.new(1,0)
    tabBtns[name]=btn
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    btn.MouseEnter:Connect(function()
        if activeTab~=name then TweenSvc:Create(btn,TweenInfo.new(0.1),{
            BackgroundTransparency=0.82,
            BackgroundColor3=danger and C.danger or (gold and C.gold or C.acc)
        }):Play() end end)
    btn.MouseLeave:Connect(function()
        if activeTab~=name then TweenSvc:Create(btn,TweenInfo.new(0.1),{BackgroundTransparency=1}):Play() end end)
    return sf
end

-- ════════════════════════════════════════════════
-- >> ESP TAB
-- ════════════════════════════════════════════════
local espTab=addTab("ESP","*")
mkHead(espTab,"gorunurluk")
mkToggle(espTab,"ESP  (duvardan gorme)",function() return Cfg.espOn end,function(v) Cfg.espOn=v end)
mkToggle(espTab,"Tracerlar",function() return Cfg.tracersOn end,function(v) Cfg.tracersOn=v end)
mkToggle(espTab,"Health Bar",function() return Cfg.hbarsOn end,function(v) Cfg.hbarsOn=v end)
mkToggle(espTab,"Nametag  (isim + HP)",function() return Cfg.nametagOn end,function(v) Cfg.nametagOn=v end)
mkSlider(espTab,"Fill Opakligi",0,1,0.65,true,function(v) Cfg.espFill=v end)
-- renk paleti
local cRow=Instance.new("Frame",espTab)
cRow.Size=UDim2.new(1,0,0,42); cRow.BackgroundColor3=C.card; cRow.BorderSizePixel=0
local crc=Instance.new("UICorner",cRow); crc.CornerRadius=UDim.new(0,8)
local cbar=Instance.new("Frame",cRow); cbar.Size=UDim2.new(0,3,0.6,0); cbar.Position=UDim2.new(0,0,0.2,0)
cbar.BackgroundColor3=C.acc; cbar.BorderSizePixel=0
local cbrc=Instance.new("UICorner",cbar); cbrc.CornerRadius=UDim.new(1,0)
local cLbl=Instance.new("TextLabel",cRow)
cLbl.Size=UDim2.new(0,66,1,0); cLbl.Position=UDim2.new(0,14,0,0)
cLbl.BackgroundTransparency=1; cLbl.TextColor3=C.text; cLbl.Font=Enum.Font.Gotham
cLbl.TextSize=11; cLbl.TextXAlignment=Enum.TextXAlignment.Left; cLbl.Text="ESP Renk"
local pal={Color3.fromRGB(255,50,50),Color3.fromRGB(50,230,100),Color3.fromRGB(50,140,255),
    Color3.fromRGB(255,215,45),Color3.fromRGB(255,255,255),Color3.fromRGB(180,50,255),
    Color3.fromRGB(255,120,30),Color3.fromRGB(255,80,180)}
local selDot=nil
for i,c in ipairs(pal) do
    local dot=Instance.new("TextButton",cRow)
    dot.Size=UDim2.new(0,21,0,21); dot.Position=UDim2.new(0,78+(i-1)*27,0.5,-10)
    dot.BackgroundColor3=c; dot.Text=""; dot.BorderSizePixel=2; dot.BorderColor3=Color3.fromRGB(0,0,0)
    local dc=Instance.new("UICorner",dot); dc.CornerRadius=UDim.new(1,0)
    local cc=c
    dot.MouseButton1Click:Connect(function()
        Cfg.espColor=cc
        for _,h in pairs(espHL) do pcall(function() h.FillColor=cc; h.OutlineColor=cc end) end
        if selDot then selDot.BorderColor3=Color3.fromRGB(0,0,0) end
        dot.BorderColor3=C.white; selDot=dot
    end)
end

-- ════════════════════════════════════════════════
-- >> COMBAT TAB
-- ════════════════════════════════════════════════
local combatTab=addTab("Combat","+")
mkHead(combatTab,"aimbot  -  sag tik")
mkToggle(combatTab,"Aimbot",function() return Cfg.aimbotOn end,function(v) Cfg.aimbotOn=v end)
mkToggle(combatTab,"FOV Dairesi",function() return Cfg.showFOV end,function(v) Cfg.showFOV=v end)
mkSlider(combatTab,"FOV Yaricapi",30,500,150,false,function(v) Cfg.aimbotFOV=v end)
mkSlider(combatTab,"Smooth  (dusuk=hizli)",0.02,0.6,0.18,true,function(v) Cfg.aimbotSmooth=v end)
local pRow=Instance.new("Frame",combatTab)
pRow.Size=UDim2.new(1,0,0,32); pRow.BackgroundColor3=C.card; pRow.BorderSizePixel=0
local prc=Instance.new("UICorner",pRow); prc.CornerRadius=UDim.new(0,8)
local pLbl=Instance.new("TextLabel",pRow)
pLbl.Size=UDim2.new(0.46,0,1,0); pLbl.Position=UDim2.new(0,14,0,0)
pLbl.BackgroundTransparency=1; pLbl.TextColor3=C.text; pLbl.Font=Enum.Font.Gotham
pLbl.TextSize=12; pLbl.TextXAlignment=Enum.TextXAlignment.Left; pLbl.Text="Hedef:  Head"
local function mkPB(lbl,xOff,part)
    local b=Instance.new("TextButton",pRow)
    b.Size=UDim2.new(0,76,0,22); b.Position=UDim2.new(1,xOff,0.5,-11)
    b.BackgroundColor3=part==Cfg.aimbotPart and C.acc or C.track
    b.TextColor3=C.white; b.Font=Enum.Font.GothamBold; b.TextSize=10
    b.Text=lbl; b.BorderSizePixel=0
    local bc=Instance.new("UICorner",b); bc.CornerRadius=UDim.new(0,5); return b
end
local hBtn=mkPB("Head",-164,"Head"); local tBtn=mkPB("Torso",-82,"HumanoidRootPart")
hBtn.MouseButton1Click:Connect(function()
    Cfg.aimbotPart="Head"; pLbl.Text="Hedef:  Head"
    hBtn.BackgroundColor3=C.acc; tBtn.BackgroundColor3=C.track end)
tBtn.MouseButton1Click:Connect(function()
    Cfg.aimbotPart="HumanoidRootPart"; pLbl.Text="Hedef:  Torso"
    tBtn.BackgroundColor3=C.acc; hBtn.BackgroundColor3=C.track end)

mkHead(combatTab,"silent aim")
mkToggle(combatTab,"Silent Aim",function() return Cfg.silentOn end,function(v) Cfg.silentOn=v end)
mkSlider(combatTab,"Silent FOV",30,600,250,false,function(v) Cfg.silentFOV=v end)

mkHead(combatTab,"magic bullet  -  duvardan hasar  (namecall hook)")
mkToggle(combatTab,"Magic Bullet  (FireServer intercept)",function() return Cfg.magicBullet end,function(v) Cfg.magicBullet=v end)
mkToggle(combatTab,"Auto Shoot  (surekli hasar)",function() return Cfg.autoShoot end,function(v) Cfg.autoShoot=v end)
mkSlider(combatTab,"Hasar Miktari",5,100,25,false,function(v) Cfg.magicDamage=v end)

mkHead(combatTab,"kill")
mkToggle(combatTab,"Hitmarker  (oldurunce goster)",function() return Cfg.hitmarker end,function(v)
    Cfg.hitmarker=v; kcFrame.Visible=v end)
mkButton(combatTab,">> KILL ALL  (simdi oldur)",function()
    task.spawn(killAll)
end,true)
mkToggle(combatTab,"Auto Kill  (surekli oldur)",function() return Cfg.autoKill end,function(v) Cfg.autoKill=v end,true)
mkHead(combatTab,"kill aura")
mkToggle(combatTab,"Kill Aura",function() return Cfg.killAura end,function(v) Cfg.killAura=v end)
mkSlider(combatTab,"Kill Range (studs)",5,100,20,false,function(v) Cfg.killRange=v end)

-- ════════════════════════════════════════════════
-- >> HAREKET TAB
-- ════════════════════════════════════════════════
local moveTab=addTab("Hareket",">")
mkHead(moveTab,"fly")
mkToggle(moveTab,"Fly  (W/A/S/D - Space - Shift)",function() return Cfg.flyOn end,function(v) Cfg.flyOn=v end)
mkSlider(moveTab,"Fly Hizi",20,300,60,false,function(v) Cfg.flySpeed=v end)
mkHead(moveTab,"hareket")
mkToggle(moveTab,"Noclip",function() return Cfg.noclipOn end,function(v) Cfg.noclipOn=v end)
mkToggle(moveTab,"Sonsuz Ziplamama",function() return Cfg.infJump end,function(v) Cfg.infJump=v end)
mkToggle(moveTab,"Bhop",function() return Cfg.bhop end,function(v) Cfg.bhop=v end)
mkToggle(moveTab,"Spin  (kendi etrafinda)",function() return Cfg.spinSelf end,function(v) Cfg.spinSelf=v end)
mkToggle(moveTab,"Click TP  (Q tusu)",function() return Cfg.clickTP end,function(v) Cfg.clickTP=v end)
mkSlider(moveTab,"WalkSpeed",16,500,16,false,function(v)
    Cfg.walkSpeed=v; local h=getHum(); if h then h.WalkSpeed=v end end)
mkSlider(moveTab,"JumpPower",7,300,50,false,function(v)
    Cfg.jumpPower=v; local h=getHum(); if h then h.JumpPower=v end end)
mkSlider(moveTab,"Yercekimi",0,400,196,false,function(v)
    Cfg.gravity=v; pcall(function() workspace.Gravity=v end) end)
mkHead(moveTab,"karakter")
mkToggle(moveTab,"God Mode",function() return Cfg.godMode end,function(v) Cfg.godMode=v end)
mkToggle(moveTab,"Invisible",function() return Cfg.invisible end,function(v) Cfg.invisible=v end)
mkToggle(moveTab,"No Fall Damage",function() return Cfg.noFall end,function(v) Cfg.noFall=v end)
mkToggle(moveTab,"Anti-AFK",function() return Cfg.antiAFK end,function(v) Cfg.antiAFK=v end)
mkButton(moveTab,">> Server Hop",function()
    pcall(function()
        local TS=game:GetService("TeleportService")
        local servers={}
        local ok,result=pcall(function()
            return game:GetService("HttpService"):JSONDecode(
                game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=10"))
        end)
        if ok and result and result.data then
            for _,s in ipairs(result.data) do
                if s.id~=game.JobId then table.insert(servers,s.id) end
            end
        end
        if #servers>0 then
            TS:TeleportToPlaceInstance(game.PlaceId,servers[math.random(1,#servers)],lp)
        else
            TS:Teleport(game.PlaceId,lp)
        end
    end)
end,false,true)
mkButton(moveTab,">> Rejoin",function()
    pcall(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId,lp)
    end)
end)

-- ════════════════════════════════════════════════
-- >> GORSEL TAB
-- ════════════════════════════════════════════════
local visTab=addTab("Gorsel","-",false,true)
mkHead(visTab,"aydinlatma",C.gold)
mkToggle(visTab,"Full Bright",function() return Cfg.fullBright end,function(v)
    Cfg.fullBright=v
    pcall(function()
        if v then
            Lighting.Brightness=2.5; Lighting.ClockTime=14; Lighting.FogEnd=100000
            Lighting.GlobalShadows=false; Lighting.Ambient=Color3.fromRGB(255,255,255)
            Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255)
        end
    end)
end)
mkToggle(visTab,"No Fog",function() return Cfg.noFog end,function(v)
    Cfg.noFog=v
    pcall(function() Lighting.FogEnd=v and 100000 or 1000; Lighting.FogStart=v and 99999 or 0 end)
end)
mkHead(visTab,"kamera",C.gold)
mkSlider(visTab,"FOV",30,120,70,false,function(v)
    Cfg.fov=v; pcall(function() Camera.FieldOfView=v end) end)
mkHead(visTab,"crosshair / hitmarker",C.gold)
mkToggle(visTab,"Custom Crosshair",function() return Cfg.crosshairOn end,function(v) Cfg.crosshairOn=v end)
mkSlider(visTab,"Crosshair Boyutu",4,30,10,false,function(v) Cfg.crosshairSize=v end)

-- ════════════════════════════════════════════════
-- >> TROLL TAB
-- ════════════════════════════════════════════════
local trollTab=addTab("Troll","x",true)
mkHead(trollTab,"toplu saldiri",C.danger)
mkButton(trollTab,">> Herkesi Firlatdir",function()
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and p.Character then
            local hrp=p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then pcall(function()
                local bv=Instance.new("BodyVelocity",hrp)
                bv.Velocity=Vector3.new(math.random(-40,40),Cfg.launchPow,math.random(-40,40))
                bv.MaxForce=Vector3.new(1e5,1e5,1e5); Debris:AddItem(bv,0.15) end) end
        end
    end
end,true)
mkSlider(trollTab,"Firlatma Gucu",50,600,130,false,function(v) Cfg.launchPow=v end,true)
mkButton(trollTab,">> Herkesi Stack",function()
    local hrp=getHRP(); if not hrp then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and p.Character then
            local ehr=p.Character:FindFirstChild("HumanoidRootPart")
            if ehr then pcall(function() ehr.CFrame=hrp.CFrame+Vector3.new(0,2,0) end) end
        end
    end
end,true)
mkButton(trollTab,">> Herkesi Ragdoll",function()
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and p.Character then
            local hum=p.Character:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end) end
        end
    end
end,true)
mkHead(trollTab,"surekli efektler",C.danger)
mkToggle(trollTab,"Freeze All",function() return Cfg.freezeAll end,function(v) Cfg.freezeAll=v end,true)
mkToggle(trollTab,"Spin All",function() return Cfg.spinAll end,function(v) Cfg.spinAll=v end,true)
mkToggle(trollTab,"Annoy  (surekli TP)",function() return Cfg.annoyOn end,function(v) Cfg.annoyOn=v end,true)
mkSlider(trollTab,"Spin Hizi",1,30,8,false,function(v) Cfg.spinAllSpd=v end,true)
mkHead(trollTab,"boyut",C.danger)
mkSlider(trollTab,"Scale All  (1=normal)",0.1,5,1,true,function(v)
    Cfg.scaleAll=v
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and p.Character then
            local hum=p.Character:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function()
                hum.BodyDepthScale.Value=v; hum.BodyHeightScale.Value=v
                hum.BodyWidthScale.Value=v; hum.HeadScale.Value=v end) end
        end
    end
end,true)
mkHead(trollTab,"chat spam",C.danger)
mkToggle(trollTab,"Chat Spam",function() return Cfg.chatSpam end,function(v) Cfg.chatSpam=v end,true)
local cboxW=Instance.new("Frame",trollTab)
cboxW.Size=UDim2.new(1,0,0,32); cboxW.BackgroundColor3=C.card; cboxW.BorderSizePixel=0
local cwc=Instance.new("UICorner",cboxW); cwc.CornerRadius=UDim.new(0,8)
local cSt=Instance.new("UIStroke",cboxW); cSt.Color=C.div; cSt.Thickness=1; cSt.Transparency=0.3
local chatTB=Instance.new("TextBox",cboxW)
chatTB.Size=UDim2.new(1,-16,1,0); chatTB.Position=UDim2.new(0,8,0,0)
chatTB.BackgroundTransparency=1; chatTB.TextColor3=C.text
chatTB.PlaceholderColor3=C.muted; chatTB.PlaceholderText="Spam mesaji..."
chatTB.Font=Enum.Font.Gotham; chatTB.TextSize=12; chatTB.TextXAlignment=Enum.TextXAlignment.Left
chatTB.FocusLost:Connect(function() if chatTB.Text~="" then Cfg.chatMsg=chatTB.Text end end)

-- ════════════════════════════════════════════════
-- >> OYUNCULAR TAB
-- ════════════════════════════════════════════════
local playTab=addTab("Oyuncular","~")
mkHead(playTab,"toplu tp")
mkButton(playTab,">> Herkesi Yanima Cek",function()
    local hrp=getHRP(); if not hrp then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and p.Character then
            local ehr=p.Character:FindFirstChild("HumanoidRootPart")
            if ehr then pcall(function()
                ehr.CFrame=hrp.CFrame+Vector3.new(math.random(-5,5),0,math.random(-5,5)) end) end
        end
    end
end)
mkButton(playTab,">> Rastgele Birine TP",function()
    local pool={}
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then table.insert(pool,p) end end
    if #pool==0 then return end
    local t=pool[math.random(1,#pool)]; local hrp=getHRP()
    if hrp then pcall(function() hrp.CFrame=t.Character.HumanoidRootPart.CFrame+Vector3.new(2,0,0) end) end
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
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp then
            local row=Instance.new("Frame",plH)
            row.Size=UDim2.new(1,0,0,30); row.BackgroundColor3=C.card; row.BorderSizePixel=0
            local rc=Instance.new("UICorner",row); rc.CornerRadius=UDim.new(0,8)
            local nl=Instance.new("TextLabel",row)
            nl.Size=UDim2.new(1,-68,1,0); nl.Position=UDim2.new(0,10,0,0)
            nl.BackgroundTransparency=1; nl.TextColor3=C.text; nl.Font=Enum.Font.Gotham
            nl.TextSize=11; nl.TextXAlignment=Enum.TextXAlignment.Left
            nl.Text=p.DisplayName.."  (@"..p.Name..")"
            nl.TextTruncate=Enum.TextTruncate.AtEnd
            local tb=Instance.new("TextButton",row)
            tb.Size=UDim2.new(0,56,0,22); tb.Position=UDim2.new(1,-62,0.5,-11)
            tb.BackgroundColor3=C.acc; tb.TextColor3=C.white
            tb.Font=Enum.Font.GothamBold; tb.TextSize=10; tb.Text="TP Git"; tb.BorderSizePixel=0
            local tc=Instance.new("UICorner",tb); tc.CornerRadius=UDim.new(0,5)
            local cp=p
            tb.MouseButton1Click:Connect(function()
                local hrp=getHRP()
                if hrp and cp.Character and cp.Character:FindFirstChild("HumanoidRootPart") then
                    pcall(function() hrp.CFrame=cp.Character.HumanoidRootPart.CFrame+Vector3.new(2,0,0) end)
                end
            end)
        end
    end
end
mkButton(playTab,">> Listeyi Yenile",function() refreshList() end)
refreshList()
switchTab("ESP")

-- ════════════════════════════════════════════════
-- KEY DOGRULAMA
-- ════════════════════════════════════════════════
local KEY="4444"
local function shakeBox()
    local base=kBox.Position; local offs={9,-9,7,-7,4,-4,2,-2,0}; local i=0; local conn
    conn=RunService.RenderStepped:Connect(function()
        i=i+1; if i>#offs then conn:Disconnect(); kBox.Position=base; return end
        kBox.Position=UDim2.new(base.X.Scale,base.X.Offset+offs[i],base.Y.Scale,base.Y.Offset)
    end)
end
local function tryKey()
    if kInput.Text==KEY then
        kStatus.TextColor3=C.ok; kStatus.Text="-- erisim onaylandi"
        task.wait(0.4)
        TweenSvc:Create(KS,TweenInfo.new(0.45,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{
            Position=UDim2.new(0,0,-1,0)}):Play()
        task.wait(0.25)
        Main.Visible=true; Main.Size=UDim2.new(0,10,0,10); Main.Position=UDim2.new(0.5,-5,0.5,-5)
        TweenSvc:Create(Main,TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Size=UDim2.new(0,W,0,H),Position=UDim2.new(0.5,-W/2,0.5,-H/2)}):Play()
        task.wait(0.6); KS:Destroy()
    else
        kStatus.TextColor3=C.danger; kStatus.Text="-- yanlis key"
        TweenSvc:Create(kIW,TweenInfo.new(0.08),{BackgroundColor3=Color3.fromRGB(50,15,15)}):Play()
        shakeBox(); task.wait(0.4)
        TweenSvc:Create(kIW,TweenInfo.new(0.2),{BackgroundColor3=C.track}):Play()
        kStatus.Text="-- tekrar deneyin"
    end
end
kSubmit.MouseButton1Click:Connect(function() tryKey() end)
kInput.FocusLost:Connect(function(ep) if ep then tryKey() end end)
kSubmit.MouseEnter:Connect(function() TweenSvc:Create(kSubmit,TweenInfo.new(0.1),{BackgroundColor3=C.acc2}):Play() end)
kSubmit.MouseLeave:Connect(function() TweenSvc:Create(kSubmit,TweenInfo.new(0.1),{BackgroundColor3=C.acc}):Play() end)

-- ════════════════════════════════════════════════
-- 8 TUSU + Q TUSU
-- ════════════════════════════════════════════════
local openY=0; local closeY=0
task.spawn(function()
    while not Main.Visible do task.wait(0.1) end
    task.wait(0.65); openY=Main.Position.Y.Offset; closeY=openY+H+60
end)

UserInput.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if inp.KeyCode==Enum.KeyCode.Q and Cfg.clickTP then
        local hrp=getHRP()
        if hrp then pcall(function()
            hrp.CFrame=CFrame.new(mouse.Hit.Position+Vector3.new(0,3,0)) end) end
        return
    end
    if inp.KeyCode~=Enum.KeyCode.Eight then return end
    if not Main.Visible then
        guiOpen=true; Main.Visible=true
        TweenSvc:Create(Main,TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{
            Position=UDim2.new(Main.Position.X.Scale,Main.Position.X.Offset,Main.Position.Y.Scale,openY)
        }):Play(); return
    end
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
        tw:Play(); tw.Completed:Connect(function() if not guiOpen then Main.Visible=false end end)
    end
end)

-- ════════════════════════════════════════════════
-- DRAWING: FOV, CROSSHAIR, TRACERS, HEALTH BARS, NAMETAG
-- ════════════════════════════════════════════════
local fovC=nil; local crossLines={}; local tracers={}; local hbars={}; local nametags={}

pcall(function()
    fovC=Drawing.new("Circle"); fovC.Visible=false; fovC.Thickness=1.5
    fovC.Color=Color3.fromRGB(220,220,220); fovC.Filled=false; fovC.NumSides=64
end)
pcall(function()
    for i=1,4 do
        local l=Drawing.new("Line"); l.Color=C.white; l.Thickness=1.5; l.Transparency=0; l.Visible=false
        crossLines[i]=l
    end
end)

local function updateTracers()
    local dead={}
    for uid,line in pairs(tracers) do
        local p=Players:GetPlayerByUserId(uid)
        if not p or not p.Character or not Cfg.tracersOn then
            dead[#dead+1]=uid; pcall(function() line.Visible=false; line:Remove() end)
        end
    end
    for _,uid in ipairs(dead) do tracers[uid]=nil end
    if not Cfg.tracersOn then return end
    local origin=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y)
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and p.Character then
            local hrp=p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local ok,sp,vis=pcall(function() return Camera:WorldToScreenPoint(hrp.Position) end)
                if ok then
                    if not tracers[p.UserId] then
                        local l=Drawing.new("Line"); l.Thickness=1; l.Transparency=0.25; l.Color=Cfg.espColor
                        tracers[p.UserId]=l
                    end
                    local l=tracers[p.UserId]
                    l.From=origin; l.To=Vector2.new(sp.X,sp.Y); l.Visible=vis; l.Color=Cfg.espColor
                end
            end
        end
    end
end

local function updateHBars()
    local dead={}
    for uid,bars in pairs(hbars) do
        local p=Players:GetPlayerByUserId(uid)
        if not p or not p.Character or not Cfg.hbarsOn then
            dead[#dead+1]=uid
            pcall(function() bars.bg.Visible=false; bars.fill.Visible=false end)
        end
    end
    for _,uid in ipairs(dead) do hbars[uid]=nil end
    if not Cfg.hbarsOn then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and p.Character then
            local head=p.Character:FindFirstChild("Head")
            local hum=p.Character:FindFirstChildOfClass("Humanoid")
            if head and hum then
                local ok,sp,vis=pcall(function() return Camera:WorldToScreenPoint(head.Position) end)
                if ok and vis then
                    if not hbars[p.UserId] then
                        local bg=Drawing.new("Square"); bg.Filled=true; bg.Color=Color3.fromRGB(0,0,0); bg.Transparency=0.5; bg.Thickness=1
                        local fill=Drawing.new("Square"); fill.Filled=true; fill.Transparency=0.15
                        hbars[p.UserId]={bg=bg,fill=fill}
                    end
                    local bars=hbars[p.UserId]; local bw,bh=42,5
                    local bx=sp.X-bw/2; local by=sp.Y-32
                    bars.bg.Size=Vector2.new(bw,bh); bars.bg.Position=Vector2.new(bx,by); bars.bg.Visible=true
                    local pct=math.clamp(hum.Health/hum.MaxHealth,0,1)
                    bars.fill.Size=Vector2.new(bw*pct,bh); bars.fill.Position=Vector2.new(bx,by); bars.fill.Visible=true
                    bars.fill.Color=pct>0.5 and Color3.fromRGB(40,210,80) or pct>0.25 and Color3.fromRGB(255,175,30) or Color3.fromRGB(220,45,45)
                else
                    if hbars[p.UserId] then
                        pcall(function() hbars[p.UserId].bg.Visible=false; hbars[p.UserId].fill.Visible=false end)
                    end
                end
            end
        end
    end
end

local function updateNametags()
    local dead={}
    for uid,nt in pairs(nametags) do
        local p=Players:GetPlayerByUserId(uid)
        if not p or not p.Character or not Cfg.nametagOn then
            dead[#dead+1]=uid; pcall(function() nt.Visible=false; nt:Remove() end)
        end
    end
    for _,uid in ipairs(dead) do nametags[uid]=nil end
    if not Cfg.nametagOn then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and p.Character then
            local head=p.Character:FindFirstChild("Head")
            local hum=p.Character:FindFirstChildOfClass("Humanoid")
            if head and hum then
                local ok,sp,vis=pcall(function() return Camera:WorldToScreenPoint(head.Position) end)
                if ok and vis then
                    if not nametags[p.UserId] then
                        local t=Drawing.new("Text"); t.Size=13; t.Center=true; t.Outline=true
                        t.OutlineColor=Color3.fromRGB(0,0,0); t.Font=Drawing.Fonts.UI
                        nametags[p.UserId]=t
                    end
                    local nt=nametags[p.UserId]
                    nt.Text=p.DisplayName.."  ["..math.floor(hum.Health).."]"
                    nt.Color=Cfg.espColor; nt.Position=Vector2.new(sp.X,sp.Y-48); nt.Visible=true
                else
                    if nametags[p.UserId] then pcall(function() nametags[p.UserId].Visible=false end) end
                end
            end
        end
    end
end

-- ════════════════════════════════════════════════
-- FLY
-- ════════════════════════════════════════════════
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
    end); flyBody={}
    local h=getHum(); if h then pcall(function() h.PlatformStand=false end) end
end

-- ════════════════════════════════════════════════
-- ESP
-- ════════════════════════════════════════════════
local function updateESP()
    local dead={}
    for pid,h in pairs(espHL) do
        local p=Players:GetPlayerByUserId(pid)
        if not p or not p.Character or not Cfg.espOn then
            dead[#dead+1]=pid; pcall(function() h:Destroy() end)
        end
    end
    for _,pid in ipairs(dead) do espHL[pid]=nil end
    if not Cfg.espOn then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and p.Character then
            if not espHL[p.UserId] then
                pcall(function()
                    local h=Instance.new("Highlight")
                    h.FillColor=Cfg.espColor; h.OutlineColor=Cfg.espColor
                    h.FillTransparency=Cfg.espFill; h.OutlineTransparency=0
                    h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                    h.Adornee=p.Character; h.Parent=workspace
                    espHL[p.UserId]=h
                end)
            else
                pcall(function()
                    espHL[p.UserId].FillColor=Cfg.espColor; espHL[p.UserId].OutlineColor=Cfg.espColor
                    espHL[p.UserId].FillTransparency=Cfg.espFill
                end)
            end
        end
    end
end

-- ════════════════════════════════════════════════
-- ZIPLAMAMA
-- ════════════════════════════════════════════════
UserInput.JumpRequest:Connect(function()
    if Cfg.infJump then
        local h=getHum()
        if h then pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end) end
    end
end)

-- ════════════════════════════════════════════════
-- MAGIC BULLET SOL TIK -- TakeDamage backup
-- ════════════════════════════════════════════════
mouse.Button1Down:Connect(function()
    if not Cfg.magicBullet then return end
    local t=getAimTarget(math.huge,Cfg.aimbotPart)
    if t then
        local hum=t.Parent:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function() hum:TakeDamage(Cfg.magicDamage) end)
            if Cfg.hitmarker then flashHitmarker() end
        end
    end
end)

-- ════════════════════════════════════════════════
-- RENDERSTEPPED
-- ════════════════════════════════════════════════
RunService.RenderStepped:Connect(function(dt)
    pcall(updateESP); pcall(updateTracers); pcall(updateHBars); pcall(updateNametags)

    if Cfg.flyOn~=prevFly then
        if Cfg.flyOn then enableFly() else disableFly() end; prevFly=Cfg.flyOn
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
    if Cfg.noclipOn then pcall(function()
        local c=getChar(); if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end end
    end) end
    if Cfg.spinSelf then pcall(function()
        local hrp=getHRP(); if hrp then
            hrp.CFrame=hrp.CFrame*CFrame.Angles(0,math.rad(Cfg.spinSpeed),0) end
    end) end
    if Cfg.invisible then pcall(function()
        local c=getChar(); if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
                p.LocalTransparencyModifier=1 end
        end
    end) end
    if Cfg.aimbotOn and UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        pcall(function()
            local t=getAimTarget(); if t then
                Camera.CFrame=Camera.CFrame:Lerp(
                    CFrame.lookAt(Camera.CFrame.Position,t.Position),Cfg.aimbotSmooth) end
        end)
    end
    if Cfg.autoShoot then pcall(function()
        local t=getAimTarget(); if t then
            local hum=t.Parent:FindFirstChildOfClass("Humanoid")
            if hum then hum:TakeDamage(0.8) end
        end
    end) end

    -- Hitmarker timer
    if hmTimer>0 then
        hmTimer=hmTimer-dt
        if hmTimer<=0 then
            for _,l in ipairs(hmLines) do pcall(function() l.Visible=false end) end
        end
    end

    -- Kill counter guncelle
    kcLabel.Text=">> Oldurulen: "..killCount

    -- Crosshair
    if #crossLines>=4 then pcall(function()
        local cx=Camera.ViewportSize.X/2; local cy=Camera.ViewportSize.Y/2
        local s=Cfg.crosshairSize; local g=4
        if Cfg.crosshairOn then
            crossLines[1].From=Vector2.new(cx,cy-g-s); crossLines[1].To=Vector2.new(cx,cy-g); crossLines[1].Visible=true
            crossLines[2].From=Vector2.new(cx,cy+g);   crossLines[2].To=Vector2.new(cx,cy+g+s); crossLines[2].Visible=true
            crossLines[3].From=Vector2.new(cx-g-s,cy); crossLines[3].To=Vector2.new(cx-g,cy);   crossLines[3].Visible=true
            crossLines[4].From=Vector2.new(cx+g,cy);   crossLines[4].To=Vector2.new(cx+g+s,cy); crossLines[4].Visible=true
        else for _,l in ipairs(crossLines) do l.Visible=false end end
    end) end
    if fovC then pcall(function()
        fovC.Visible=Cfg.showFOV and Cfg.aimbotOn
        fovC.Radius=Cfg.aimbotFOV
        fovC.Position=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
    end) end
end)

-- ════════════════════════════════════════════════
-- STEPPED
-- ════════════════════════════════════════════════
RunService.Stepped:Connect(function()
    local now=tick()
    pcall(function()
        local h=getHum()
        if h then
            if not Cfg.flyOn then h.WalkSpeed=Cfg.walkSpeed; h.JumpPower=Cfg.jumpPower end
            if Cfg.godMode then h.Health=h.MaxHealth end
            if Cfg.bhop and h:GetState()==Enum.HumanoidStateType.Landed then
                h:ChangeState(Enum.HumanoidStateType.Jumping) end
            if Cfg.noFall and h:GetState()==Enum.HumanoidStateType.FallingDown then
                h:ChangeState(Enum.HumanoidStateType.GettingUp) end
        end
    end)
    if Cfg.killAura then pcall(function()
        local hrp=getHRP(); if not hrp then return end
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=lp and p.Character then
                local ehr=p.Character:FindFirstChild("HumanoidRootPart")
                if ehr and (ehr.Position-hrp.Position).Magnitude<=Cfg.killRange then
                    local orig=hrp.CFrame; hrp.CFrame=ehr.CFrame; task.wait(); hrp.CFrame=orig
                end
            end
        end
    end) end
    if Cfg.autoKill and now-lastAutoKill>0.5 then
        lastAutoKill=now; task.spawn(killAll) end
    if Cfg.freezeAll then pcall(function()
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=lp and p.Character then
                local ehr=p.Character:FindFirstChild("HumanoidRootPart")
                if ehr then ehr.Anchored=true end end end
    end) else pcall(function()
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=lp and p.Character then
                local ehr=p.Character:FindFirstChild("HumanoidRootPart")
                if ehr and ehr.Anchored then ehr.Anchored=false end end end
    end) end
    if Cfg.spinAll then pcall(function()
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=lp and p.Character then
                local ehr=p.Character:FindFirstChild("HumanoidRootPart")
                if ehr then ehr.CFrame=ehr.CFrame*CFrame.Angles(0,math.rad(Cfg.spinAllSpd),0) end end end
    end) end
    if Cfg.annoyOn and now-lastAnnoy>0.4 then
        lastAnnoy=now; pcall(function()
            local list={}
            for _,p in ipairs(Players:GetPlayers()) do
                if p~=lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    table.insert(list,p) end end
            if #list==0 then return end
            annoyIdx=annoyIdx%#list+1
            local t=list[annoyIdx]; local hrp=getHRP()
            if hrp and t.Character then
                local ehr=t.Character:FindFirstChild("HumanoidRootPart")
                if ehr then hrp.CFrame=ehr.CFrame+Vector3.new(1,0,0) end
            end
        end)
    end
    if Cfg.chatSpam and now-lastChat>2 then
        lastChat=now; pcall(function()
            local rs=game:GetService("ReplicatedStorage")
            local ev=rs:FindFirstChild("DefaultChatSystemChatEvents")
            if ev then
                local say=ev:FindFirstChild("SayMessageRequest")
                if say then say:FireServer(Cfg.chatMsg,"All") end
            end
        end)
    end
end)

print(">> ZXC v8  |  key: 4444  |  8 = menu")
