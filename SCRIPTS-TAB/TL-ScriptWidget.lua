local M = {}
local _cfg = {}
local _TL_WIDGET_CLOSE_ICON = "rbxassetid://111119570195816"

function M.init(cfg)
    _cfg = cfg or {}
end

function M.makeWidgetOpenBtn(parent, xPos, yPos, label, callback)
    local C = _cfg.C or _G.C or {}
    local _C3_WHITE = _cfg._C3_WHITE or Color3.fromRGB(255, 255, 255)
    local corner = _cfg.corner or function() end
    local _makeDummyStroke = _cfg._makeDummyStroke or function() end
    local twP = _cfg.twP or _cfg.tw or function() end
    local _sc = _cfg._sc or {}

    local wrap = Instance.new("Frame", parent)
    wrap.Size = UDim2.new(0, 56, 0, 28)
    wrap.Position = UDim2.new(0, xPos, 0, yPos)
    wrap.BackgroundColor3 = C.bg2
    wrap.BackgroundTransparency = 0.35
    wrap.BorderSizePixel = 0
    wrap.ZIndex = 8
    corner(wrap, 8)
    local str = _makeDummyStroke(wrap)
    str.Thickness = 1.2; str.Color = C.accent; str.Transparency = 0.5
    local ico = Instance.new("TextLabel", wrap)
    ico.Size = UDim2.new(0, 20, 1, 0); ico.Position = UDim2.new(0, 6, 0, 0)
    ico.BackgroundTransparency = 1; ico.Text = "+"
    ico.Font = Enum.Font.GothamBlack; ico.TextSize = 11
    ico.TextColor3 = C.accent; ico.ZIndex = 9
    local txt = Instance.new("TextLabel", wrap)
    txt.Size = UDim2.new(1, -28, 1, 0); txt.Position = UDim2.new(0, 24, 0, 0)
    txt.BackgroundTransparency = 1; txt.Text = label or "OPEN"
    txt.Font = Enum.Font.GothamBlack; txt.TextSize = 9
    txt.TextColor3 = C.sub; txt.ZIndex = 9
    local btn = Instance.new("TextButton", wrap)
    btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1
    btn.Text = ""; btn.ZIndex = 12
    btn.MouseEnter:Connect(function()
        pcall(function() _sc._playHoverSound() end)
        twP(wrap, 0.1, { BackgroundTransparency = 0.2, BackgroundColor3 = C.bg3 })
        twP(ico, 0.1, { TextColor3 = _C3_WHITE })
        twP(txt, 0.1, { TextColor3 = _C3_WHITE })
        str.Transparency = 0.22
    end)
    btn.MouseLeave:Connect(function()
        twP(wrap, 0.1, { BackgroundTransparency = 0.35, BackgroundColor3 = C.bg2 })
        twP(ico, 0.1, { TextColor3 = C.accent2 })
        twP(txt, 0.1, { TextColor3 = C.sub })
        str.Transparency = 0.5
    end)
    btn.MouseButton1Click:Connect(callback)
    return wrap, txt, ico
end

function M.createScriptWidget(scriptName, accentCol, onToggleFn, initState, extraBuilder)
    local C = _cfg.C or _G.C or {}
    local _C3_WHITE = _cfg._C3_WHITE or Color3.fromRGB(255, 255, 255)
    local ScreenGui = _cfg.ScreenGui or _cfg._sc
    local MDARK = _cfg.MDARK or Color3.fromRGB(15, 15, 18)
    local MHDR = _cfg.MHDR or Color3.fromRGB(25, 25, 28)
    local MGLOW = _cfg.MGLOW or _C3_WHITE
    local corner = _cfg.corner or function() end
    local stroke = _cfg.stroke or function() end
    local _makeDummyStroke = _cfg._makeDummyStroke or function() end
    local tw = _cfg.tw or function() end
    local twP = _cfg.twP or tw
    local getNearestPlayer = _cfg.getNearestPlayer or function() end
    local UserInputService = game:GetService("UserInputService")

    local ac = accentCol or C.accent or Color3.fromRGB(0, 160, 255)
    local acDim = C.sub or Color3.fromRGB(120, 120, 125)
    local WW = 240
    local HDR_H = 40
    local existingWidget = ScreenGui:FindFirstChild("SW_" .. scriptName)
    if existingWidget then
        local existingShadow = ScreenGui:FindFirstChild("SW_shadow_" .. scriptName)
        pcall(function() existingWidget:Destroy() end)
        pcall(function() if existingShadow then existingShadow:Destroy() end end)
        task.wait()
    end
    local shadow = Instance.new("ImageLabel", ScreenGui)
    shadow.Name = "SW_shadow_" .. scriptName
    shadow.Size = UDim2.new(0, WW + 28, 0, 0)
    shadow.Position = UDim2.new(0.5, -(WW + 28) / 2 + 4, 0.5, 0)
    shadow.BackgroundTransparency = 1; shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.new(0, 0, 0); shadow.ImageTransparency = 0.55
    shadow.ScaleType = Enum.ScaleType.Slice; shadow.SliceCenter = Rect.new(15, 15, 113, 113)
    shadow.ZIndex = 9499
    local W = Instance.new("Frame", ScreenGui)
    W.Name = "SW_" .. scriptName; W.Size = UDim2.new(0, WW, 0, HDR_H)
    W.Position = UDim2.new(0.5, -WW / 2, 0.5, -100); W.BackgroundColor3 = MDARK
    W.BackgroundTransparency = 0; W.BorderSizePixel = 0; W.ZIndex = 9500
    W.Active = true; W.Draggable = false; corner(W, 12); stroke(W, 1, C.bg3, 0.3)
    local hdr = Instance.new("Frame", W)
    hdr.Size = UDim2.new(1, 0, 0, HDR_H); hdr.BackgroundColor3 = MHDR
    hdr.BackgroundTransparency = 0; hdr.BorderSizePixel = 0; hdr.ZIndex = 9501; corner(hdr, 12)
    local hdrSep = Instance.new("Frame", W); hdrSep.Size = UDim2.new(1, 0, 0, 1); hdrSep.Position = UDim2.new(0, 0, 0, HDR_H)
    hdrSep.BackgroundColor3 = C.bg3; hdrSep.BackgroundTransparency = 0.5; hdrSep.BorderSizePixel = 0; hdrSep.ZIndex = 9501
    local titleLbl = Instance.new("TextLabel", hdr)
    titleLbl.Size = UDim2.new(1, -70, 1, 0); titleLbl.Position = UDim2.new(0, 14, 0, 0)
    titleLbl.BackgroundTransparency = 1; titleLbl.Text = string.upper(scriptName)
    titleLbl.Font = Enum.Font.GothamBlack; titleLbl.TextSize = 11; titleLbl.TextColor3 = MGLOW
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left; titleLbl.ZIndex = 9503
    local closeBtn = Instance.new("TextButton", hdr)
    closeBtn.Size = UDim2.new(0, 24, 0, 24); closeBtn.Position = UDim2.new(1, -30, 0.5, -12)
    closeBtn.BackgroundColor3 = C.bg3; closeBtn.BackgroundTransparency = 0.5; closeBtn.Text = ""; closeBtn.ZIndex = 9505; corner(closeBtn, 6)
    local closeBtnIco = Instance.new("ImageLabel", closeBtn)
    closeBtnIco.Size = UDim2.new(0, 18, 0, 18); closeBtnIco.Position = UDim2.new(0.5, -9, 0.5, -9)
    local closeIconId = (scriptName == "Rush" or scriptName == "Fling") and "rbxassetid://121032825074289" or _TL_WIDGET_CLOSE_ICON
    closeBtnIco.BackgroundTransparency = 1; closeBtnIco.Image = closeIconId; closeBtnIco.ImageColor3 = _C3_WHITE; closeBtnIco.ZIndex = 9506
    closeBtn.MouseButton1Click:Connect(function() W:Destroy() end)
    do
        local dragging, dragStart, startPos
        hdr.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = input.Position; startPos = W.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                W.Position = newPos
                shadow.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset + 4, newPos.Y.Scale, newPos.Y.Offset + 4)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end
    W.Destroying:Connect(function()
        if shadow then shadow:Destroy(); shadow = nil end
    end)
    local body = Instance.new("Frame", W)
    body.Size = UDim2.new(1, 0, 1, -HDR_H); body.Position = UDim2.new(0, 0, 0, HDR_H)
    body.BackgroundTransparency = 1; body.BorderSizePixel = 0; body.ZIndex = 9501
    local stPill = Instance.new("Frame", body)
    stPill.Size = UDim2.new(1, -24, 0, 32); stPill.Position = UDim2.new(0, 12, 0, 10)
    stPill.BackgroundColor3 = C.bg2; stPill.BackgroundTransparency = 0.4; corner(stPill, 8)
    local st_Stroke = _makeDummyStroke(stPill); st_Stroke.Thickness = 1; st_Stroke.Color = acDim; st_Stroke.Transparency = 0.6
    local stLbl = Instance.new("TextLabel", stPill)
    stLbl.Size = UDim2.new(1, -60, 1, 0); stLbl.Position = UDim2.new(0, 12, 0, 0)
    stLbl.BackgroundTransparency = 1; stLbl.Text = initState and "ACTIVE" or "INACTIVE"
    stLbl.Font = Enum.Font.GothamBlack; stLbl.TextSize = 10; stLbl.TextColor3 = initState and ac or acDim; stLbl.TextXAlignment = Enum.TextXAlignment.Left
    local TW2, TH2 = 34, 18
    local togTrack = Instance.new("Frame", stPill)
    togTrack.Size = UDim2.new(0, TW2, 0, TH2); togTrack.Position = UDim2.new(1, -(TW2 + 8), 0.5, -TH2 / 2)
    togTrack.BackgroundColor3 = initState and ac or C.bg3; togTrack.BackgroundTransparency = initState and 0.4 or 0.2; corner(togTrack, 99)
    local togKnob = Instance.new("Frame", togTrack)
    togKnob.Size = UDim2.new(0, 12, 0, 12); togKnob.Position = initState and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
    togKnob.BackgroundColor3 = _C3_WHITE; corner(togKnob, 99)
    local toggleState = initState or false
    local function setToggle(on)
        toggleState = on; stLbl.Text = on and "ACTIVE" or "INACTIVE"; stLbl.TextColor3 = on and ac or acDim
        twP(togTrack, 0.15, { BackgroundColor3 = on and ac or C.bg3, BackgroundTransparency = on and 0.4 or 0.2 })
        twP(togKnob, 0.15, { Position = on and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6) })
        twP(st_Stroke, 0.15, { Color = on and ac or acDim, Transparency = on and 0.4 or 0.6 })
        if onToggleFn then onToggleFn(on) end
    end
    local togBtn = Instance.new("TextButton", stPill)
    togBtn.Size = UDim2.new(1, 0, 1, 0); togBtn.BackgroundTransparency = 1; togBtn.Text = ""; togBtn.ZIndex = 9510
    togBtn.MouseButton1Click:Connect(function() setToggle(not toggleState) end)
    local tgtRow = Instance.new("Frame", body)
    tgtRow.Size = UDim2.new(1, -24, 0, 26); tgtRow.Position = UDim2.new(0, 12, 0, 52)
    tgtRow.BackgroundColor3 = C.bg2; tgtRow.BackgroundTransparency = 0.6; corner(tgtRow, 6)
    local tgtLbl = Instance.new("TextLabel", tgtRow)
    tgtLbl.Size = UDim2.new(0, 50, 1, 0); tgtLbl.Position = UDim2.new(0, 10, 0, 0)
    tgtLbl.BackgroundTransparency = 1; tgtLbl.Text = "TARGET:"; tgtLbl.Font = Enum.Font.GothamBold; tgtLbl.TextSize = 8; tgtLbl.TextColor3 = acDim
    local tgtVal = Instance.new("TextLabel", tgtRow)
    tgtVal.Size = UDim2.new(1, -70, 1, 0); tgtVal.Position = UDim2.new(0, 60, 0, 0)
    tgtVal.BackgroundTransparency = 1; tgtVal.Text = "NONE"; tgtVal.Font = Enum.Font.GothamBlack; tgtVal.TextSize = 10; tgtVal.TextColor3 = _C3_WHITE; tgtVal.TextXAlignment = Enum.TextXAlignment.Left; tgtVal.TextTruncate = Enum.TextTruncate.AtEnd
    local baseContentH = 88
    local startExtraY = 82
    local finalH = HDR_H + baseContentH
    if extraBuilder then
        local extraH = extraBuilder(body, WW, startExtraY, ac, setToggle)
        finalH = finalH + (extraH or 0)
    end
    W.Size = UDim2.new(0, WW, 0, finalH + 12)
    shadow.Size = UDim2.new(0, WW + 6, 0, finalH + 6)
    shadow.Position = UDim2.new(0.5, -(WW + 6) / 2, 0.5, -(finalH + 6) / 2)
    shadow.ImageTransparency = 0.7
    tw(W, 0.35, { Position = UDim2.new(0.5, -WW / 2, 0.5, -(finalH / 2)) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    task.spawn(function()
        while W and W.Parent do
            pcall(function()
                local np = getNearestPlayer()
                tgtVal.Text = np and string.upper(np.DisplayName) or "NONE"
            end)
            task.wait(1)
        end
    end)
    return { W = W, setToggle = setToggle }
end

return M
