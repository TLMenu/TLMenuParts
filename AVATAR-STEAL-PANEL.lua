


local GLOBAL_ENV = (typeof(getgenv) == "function" and getgenv()) or _G
local RUNTIME_KEY = "__TLSteal_AvatarOutfitPanelRuntime"

local prev = GLOBAL_ENV and GLOBAL_ENV[RUNTIME_KEY]
if type(prev) == "table" and type(prev.cleanup) == "function" then
    pcall(prev.cleanup)
end

local outfitPanelAPI = nil
local initAvatarOutfit

local T = {
	saved_outfits_title="Saved Outfits", saved_outfits_sub="Manage your outfits",
	new_folder="New Folder", folder_prefix="Folder: ", unknown="Unknown",
	no_outfits_saved="Keine Outfits gespeichert",
}
local COMMUNITY_API_BASE = "https://outfit-api.outfit-api.workers.dev"

local _isMobile do
	local cam = workspace.CurrentCamera
	_isMobile = cam and (cam.ViewportSize.X < 600 or cam.ViewportSize.Y < 800) or false
end

initAvatarOutfit = function()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local AvatarEditorService = game:GetService("AvatarEditorService")
local LocalPlayer = Players.LocalPlayer

local C = {
	THUMBTYPE="AvatarBust", PANEL_W=450, PANEL_H=340, CARD_W=108, CARD_H=136, GAP=8,
	SUB_W=480, SUB_H=360, SUB_OUT_W=120, OUT_W=98, OUT_H=128, OUTFIT_THUMB_SIZE=420,
	THUMB_PRI=8, THUMB_BATCH=6, THUMB_DELAY=0.05,
	panelBg=Color3.fromRGB(10,10,10),
	panelHdr=Color3.fromRGB(20,20,20),
	bg3=Color3.fromRGB(28,28,28),
	accent=Color3.fromRGB(99,102,241),
	BG_SOFT=Color3.fromRGB(16,16,18), TITLEBAR=Color3.fromRGB(5,5,6),
	CARD=Color3.fromRGB(20,20,22), CARD_HOVER=Color3.fromRGB(30,30,33),
	ACCENT=Color3.fromRGB(99,102,241),
	TEXT1=Color3.fromRGB(255,255,255),
	TEXT2=Color3.fromRGB(156,156,156),
	BORDER=Color3.fromRGB(70,70,74), BORDER_SOFT=Color3.fromRGB(46,46,50),
	CLOSE_HOVER=Color3.fromRGB(200,30,30),
	CLOSE_IMG="rbxassetid://121032825074289", KEYBIND=Enum.KeyCode.L,
	WROOT="TLSteal", CACHE_DIR="Cache", SAVED_DIR="SavedOutfits",
	DISK_DIR="TLSteal/Cache", DISK_TTL=86400, SAVED_FILE="saved_outfits.dat",
	REMOTE="BLINK_RELIABLE_REMOTE", DEBUG=false,
}
local PANEL_H_BASE, PANEL_H_CARDS = 192, 440

local runtime = {connections={}, instances={}, destroyed=false}
runtime.cleanup = function()
	if runtime.destroyed then return end; runtime.destroyed = true
	for _, c in ipairs(runtime.connections) do pcall(function() c:Disconnect() end) end
	runtime.connections = {}
	for i = #runtime.instances, 1, -1 do
		pcall(function() local inst = runtime.instances[i]; if inst and inst.Parent then inst:Destroy() end end)
	end
	runtime.instances = {}
	if GLOBAL_ENV and GLOBAL_ENV[RUNTIME_KEY] == runtime then GLOBAL_ENV[RUNTIME_KEY] = nil end
end
if GLOBAL_ENV then GLOBAL_ENV[RUNTIME_KEY] = runtime end
local function regInst(inst) table.insert(runtime.instances, inst); return inst end
local function bind(sig, fn) local c = sig:Connect(fn); table.insert(runtime.connections, c); return c end
local function log(...) if C.DEBUG then print(...) end end

local _tiPool = {}
local function getTI(t, s, d, rep, rev, del)
	s = s or Enum.EasingStyle.Quad; d = d or Enum.EasingDirection.Out
	local k = string.format("%s_%s_%s_%s_%s_%s", tostring(t), s.Name, d.Name, tostring(rep or 0), tostring(rev and 1 or 0), tostring(del or 0))
	if not _tiPool[k] then _tiPool[k] = TweenInfo.new(t, s, d, rep or 0, rev or false, del or 0) end
	return _tiPool[k]
end
local TI = {}
for _, v in ipairs({{0.12,"_012"},{0.15,"_015"},{0.16,"_016"},{0.18,"_018"},{0.20,"_020"},{0.08,"_008"},{0.10,"_010"},{0.14,"_014"},{0.80,"_080"}}) do TI[v[2]] = getTI(v[1]) end
TI._025 = getTI(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
TI._022 = getTI(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
TI._090_SHIMMER = getTI(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
TI._012_BACK = getTI(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
TI._008_IN = getTI(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
TI._018_BACK = getTI(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
TI._007_IN = getTI(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local function tween(obj, info, props) return TweenService:Create(obj, info, props) end
local function twP(obj, dur, props)
	local ti = getTI(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tw = TweenService:Create(obj, ti, props)
	tw:Play()
	return tw
end

local function _resolveGlobal(name)
	local v = rawget(_G, name)
	if v ~= nil then return v end
	if typeof(getgenv) == "function" then
		local env = getgenv()
		if env then v = env[name]; if v ~= nil then return v end end
	end
	return nil
end

local FS_rawRead=_resolveGlobal("readfile")
local FS_rawWrite=_resolveGlobal("writefile")
local function _fsRead(path)
	if not FS_rawRead then return nil end
	local ok, raw = pcall(FS_rawRead, path)
	if not ok or not raw then return nil end
	local pL = path:lower()
	if pL:find("tlsteal") then return _TL_deobf(raw) end
	return raw
end
local function _fsWrite(path, content)
	if not FS_rawWrite then return end
	local pL = path:lower()
	local final = pL:find("tlsteal") and _TL_obf(content) or content
	pcall(FS_rawWrite, path, final)
end
local FS = {
	read=_fsRead,
	write=_fsWrite,
	isfile=_resolveGlobal("isfile"),
	isfolder=_resolveGlobal("isfolder"),
	mkdir=_resolveGlobal("makefolder") or _resolveGlobal("createfolder"),
	del=_resolveGlobal("delfile") or _resolveGlobal("removefile"),
}
local diskCacheAvail = FS.read and FS.write and FS.isfile and FS.mkdir
local _madeFolders = {}
local function ensureFolder(p)
	if _madeFolders[p] then return end; _madeFolders[p] = true
	if not FS.mkdir then return end
	if FS.isfolder then if not FS.isfolder(p) then pcall(FS.mkdir, p) end
	else pcall(FS.mkdir, p) end
end
local function ensureBaseFolders()
	ensureFolder(C.WROOT); ensureFolder(C.WROOT.."/"..C.CACHE_DIR); ensureFolder(C.WROOT.."/"..C.SAVED_DIR)
end
if diskCacheAvail then ensureBaseFolders() end

local function _dummyStroke(p) return setmetatable({}, {__index=function()return function()end end, __newindex=function()end}) end
local function corner(p, r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=p; return c end
local function stroke(p, t, col, tr) local s=Instance.new("UIStroke"); s.Thickness=t or 1; s.Color=col or Color3.new(1,1,1); s.Transparency=tr or 0; s.Parent=p; return s end
local function applyTextStyle(obj, m)
	if not obj then return end; obj.Font = Enum.Font.GothamBold
	if m then obj.TextSize = math.max(obj.TextSize, m) end
	obj.TextColor3 = C.TEXT1 or Color3.new(1,1,1); obj.TextTransparency = 0; obj.TextStrokeTransparency = 1
end
local function styleThumbSurface(f, r)
	f.BorderSizePixel = 0; f.ClipsDescendants = true; f.BackgroundColor3 = Color3.fromRGB(12,12,14)
	corner(f, r or 8); return stroke(f, 1, C.bg3 or Color3.fromRGB(45,45,45), 0.28)
end
local function getPopScale(f) local s=f:FindFirstChild("PopScale"); if not s then s=Instance.new("UIScale",f); s.Name="PopScale" end; return s end

local function mkCloseBtn(parent, sz, posX, posY, anchX, anchY)
	local as = _isMobile and (sz+6) or sz
	local btn = Instance.new("ImageButton"); btn.Size = UDim2.fromOffset(as,as)
	btn.Position = UDim2.new(posX, posY, anchX or 0.5, 0); btn.AnchorPoint = Vector2.new(anchY or 0, 0.5)
	btn.BackgroundTransparency = 1; btn.BorderSizePixel = 0; btn.Image = C.CLOSE_IMG
	btn.ScaleType = Enum.ScaleType.Fit; btn.ZIndex = 22; btn.Parent = parent; corner(btn, 9)
	bind(btn.MouseButton1Down, function() tween(btn, TI._008, {Size=UDim2.fromOffset(as-1,as-1)}):Play() end)
	bind(btn.MouseButton1Up, function() tween(btn, TI._008, {Size=UDim2.fromOffset(as,as)}):Play() end)
	return btn
end

local function mkIconBtn(parent, sz, posX, icon, z, extraBind)
	local btn = Instance.new("ImageButton"); btn.Size = UDim2.fromOffset(sz,sz)
	btn.Position = UDim2.new(1, posX, 0.5, 0); btn.AnchorPoint = Vector2.new(1, 0.5)
	btn.BackgroundTransparency = 1; btn.BorderSizePixel = 0; btn.ScaleType = Enum.ScaleType.Fit
	btn.Image = icon; btn.ImageColor3 = Color3.fromRGB(255,255,255); btn.ZIndex = z or 14
	btn.Parent = parent; corner(btn, 6)
	bind(btn.MouseEnter, function() tween(btn, TI._012, {ImageColor3=Color3.fromRGB(200,200,200), Size=UDim2.fromOffset(sz+1,sz+1)}):Play() end)
	bind(btn.MouseLeave, function() tween(btn, TI._012, {ImageColor3=Color3.fromRGB(255,255,255), Size=UDim2.fromOffset(sz,sz)}):Play() end)
	bind(btn.MouseButton1Down, function() tween(getPopScale(btn), TI._008, {Scale=0.88}):Play() end)
	bind(btn.MouseButton1Up, function() tween(getPopScale(btn), TI._016, {Scale=1}):Play() end)
	if extraBind then bind(btn.MouseButton1Click, extraBind) end
	return btn
end

local function mkIconBtnPlain(parent, sz, posX, icon, z)
	local btn = Instance.new("ImageButton"); btn.Size = UDim2.fromOffset(sz,sz)
	btn.Position = UDim2.new(1, posX, 0.5, 0); btn.AnchorPoint = Vector2.new(1, 0.5)
	btn.BackgroundTransparency = 1; btn.BorderSizePixel = 0; btn.ScaleType = Enum.ScaleType.Fit
	btn.Image = icon; btn.ZIndex = z or 22; btn.Parent = parent; corner(btn, 5)
	bind(btn.MouseButton1Down, function() tween(getPopScale(btn), TI._008, {Scale=0.88}):Play() end)
	bind(btn.MouseButton1Up, function() tween(getPopScale(btn), TI._016, {Scale=1}):Play() end)
	return btn
end

local function makeDraggable(titleBar, panel)
	local dragging, dragStart, startPos
	bind(titleBar.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true; dragStart = input.Position; startPos = panel.Position
		end
	end)
	bind(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - dragStart
			panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
		end
	end)
	bind(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
	end)
end

local function tweenOpen(frame, w, h)
	frame.Size = UDim2.fromOffset(w, h); frame.BackgroundTransparency = 0; frame.Visible = true
	local s = getPopScale(frame); s.Scale = 0.94
	tween(s, TI._012_BACK, {Scale=1}):Play()
end

local function tweenClose(frame, w, h, cb)
	local s = getPopScale(frame)
	tween(s, TI._008_IN, {Scale=0.94}):Play()
	task.delay(0.08, function() frame.Visible = false; s.Scale = 1; if cb then cb() end end)
end

local function OBF(r) return "TLSteal::AvatarOutfitPanel" end
local OBF_KEY = OBF()
local OBF_LEN = #OBF_KEY

local _TL_OBF_HDR = "--[TL-OBF]\n"
local _TL_OBF_HDR_LEN = #_TL_OBF_HDR
local function _TL_obf(d)
	if typeof(d) ~= "string" then return d end
	local r = {}
	for i = 1, #d do r[i] = string.char((d:byte(i) + 42) % 256) end
	return _TL_OBF_HDR .. table.concat(r):reverse()
end
local function _TL_deobf(d)
	if typeof(d) ~= "string" or d:sub(1, _TL_OBF_HDR_LEN) ~= _TL_OBF_HDR then return d end
	local b = d:sub(_TL_OBF_HDR_LEN + 1):reverse()
	local r = {}
	for i = 1, #b do r[i] = string.char((b:byte(i) - 42) % 256) end
	return table.concat(r)
end

local function obfuscateString(raw)
	local out = table.create(#raw)
	for i = 1, #raw do
		local src = string.byte(raw, i)
		local keyB = string.byte(OBF_KEY, ((i-1) % OBF_LEN) + 1)
		out[i] = string.format("%02x", (src + keyB + i) % 256)
	end
	return "TLS1:" .. table.concat(out)
end

local function deobfuscateString(raw)
	if type(raw) ~= "string" then return nil, "Kein String" end
	if raw:sub(1,5) ~= "TLS1:" then return raw, nil end
	local hex = raw:sub(6)
	if (#hex % 2) ~= 0 then return nil, "Ungueltige Obfuskation" end
	local chars, outIdx = table.create(#hex/2), 0
	for pos = 1, #hex, 2 do
		outIdx = outIdx + 1
		local part = tonumber(hex:sub(pos, pos+1), 16)
		if not part then return nil, "Ungueltige Hex-Daten" end
		local keyB = string.byte(OBF_KEY, ((outIdx-1) % OBF_LEN) + 1)
		chars[outIdx] = string.char((part - keyB - outIdx) % 256)
	end
	return table.concat(chars), nil
end

local function encodeStoredJson(data)
	local ok, json = pcall(HttpService.JSONEncode, HttpService, data)
	return (ok and json) and obfuscateString(json) or nil
end

local function decodeStoredJson(raw)
	local decodedRaw, decErr = deobfuscateString(raw)
	if not decodedRaw then return nil, decErr end
	local ok, data = pcall(HttpService.JSONDecode, HttpService, decodedRaw)
	if not ok or type(data) ~= "table" then return nil, "JSON-Fehler" end
	return data, nil
end

local function diskCachePath(uid) return C.WROOT.."/"..C.CACHE_DIR.."/cache_"..tostring(uid)..".dat" end
local function legacyDiskCachePath(uid) return "AvatarOutfitCache/"..tostring(uid)..".json" end

local function diskCacheRead(uid)
	if not diskCacheAvail then return nil end
	local path = diskCachePath(uid)
	local ok, raw = pcall(FS.read, path)
	local migrateLegacy = false
	if not ok or not raw or raw == "" then
		local lok, legRaw = pcall(FS.read, legacyDiskCachePath(uid))
		if lok and legRaw and legRaw ~= "" then raw = legRaw; migrateLegacy = true
		else return nil end
	end
	local data = decodeStoredJson(raw)
	if type(data) ~= "table" then return nil end
	if C.DISK_TTL > 0 and (os.time() - (data.timestamp or 0)) > C.DISK_TTL then
		if FS.del then pcall(FS.del, path) end; return nil
	end
	if type(data.outfits) == "table" and #data.outfits == 0 then
		if FS.del then pcall(FS.del, path) end; return nil
	end
	if migrateLegacy then
		local encoded = encodeStoredJson({userId=uid, timestamp=os.time(), outfits=data.outfits or {}})
		if encoded then pcall(FS.write, path, encoded) end
	end
	return data
end

local function diskCacheWrite(uid, outfits)
	if not diskCacheAvail then return end
	local encoded = encodeStoredJson({userId=uid, timestamp=os.time(), outfits=outfits})
	if encoded then pcall(FS.write, diskCachePath(uid), encoded) end
end

local function diskCacheInvalidate(uid)
	if not diskCacheAvail then return end
	if FS.del then pcall(FS.del, diskCachePath(uid)); pcall(FS.del, legacyDiskCachePath(uid)) end
end

local Cache = {TTL=120, LRU_MAX=64, outfits={}, lruOrder={}, lruSet={}}
local function lruTouch(uid)
	if Cache.lruSet[uid] then
		for i, v in ipairs(Cache.lruOrder) do if v == uid then table.remove(Cache.lruOrder, i); break end end
	end
	table.insert(Cache.lruOrder, uid); Cache.lruSet[uid] = true
	while #Cache.lruOrder > Cache.LRU_MAX do
		local evict = table.remove(Cache.lruOrder, 1)
		Cache.lruSet[evict] = nil; Cache.outfits[evict] = nil
	end
end
local function cacheGet(uid)
	local e = Cache.outfits[uid]
	if e and (tick() - e.timestamp) < Cache.TTL then lruTouch(uid); return e.outfits end
	return nil
end
local function cacheSet(uid, outfits) Cache.outfits[uid] = {outfits=outfits, timestamp=tick()}; lruTouch(uid) end
local function cacheDel(uid) Cache.outfits[uid] = nil; Cache.lruSet[uid] = nil end

local SavedOutfitsState = {
	outfits={}, workspaceFolder=C.WROOT.."/"..C.SAVED_DIR,
	workspacePath=C.WROOT.."/"..C.SAVED_DIR.."/", loaded=false, lastLoad=0, syncInterval=2,
}
local function getSavedOutfitsFilePath() return SavedOutfitsState.workspacePath .. C.SAVED_FILE end
local function legacySavedOutfitsFilePath() return "TLMenu_Outfits/TLSavedOutfits.json" end

local function persistSavedOutfits()
	local encoded = encodeStoredJson(SavedOutfitsState.outfits)
	if encoded then ensureBaseFolders(); pcall(FS.write, getSavedOutfitsFilePath(), encoded)
		SavedOutfitsState.loaded = true; SavedOutfitsState.lastLoad = tick() end
end

local function loadSavedOutfitsFromCache(forceReload)
	if not forceReload and SavedOutfitsState.loaded and (tick() - SavedOutfitsState.lastLoad) < SavedOutfitsState.syncInterval then return end
	local ok, content = pcall(FS.read or function() end, getSavedOutfitsFilePath())
	local migrateLegacy = false
	if not ok or not content or content == "" then
		local lok, lc = pcall(FS.read or function() end, legacySavedOutfitsFilePath())
		if lok and lc and lc ~= "" then content = lc; migrateLegacy = true
		else SavedOutfitsState.loaded = true; SavedOutfitsState.lastLoad = tick(); return end
	end
	local data = decodeStoredJson(content)
	if type(data) == "table" then
		SavedOutfitsState.outfits = data; SavedOutfitsState.loaded = true; SavedOutfitsState.lastLoad = tick()
		if migrateLegacy then
			ensureBaseFolders(); local enc = encodeStoredJson(SavedOutfitsState.outfits)
			if enc then pcall(FS.write, getSavedOutfitsFilePath(), enc) end
		end
	end
end

local function saveOutfitToCache(outfitId, outfitName, playerName, displayName, userId)
	if not SavedOutfitsState.loaded then loadSavedOutfitsFromCache(true) end
	local key = tostring(userId).."_"..tostring(outfitId)
	SavedOutfitsState.outfits[key] = {outfitId=outfitId, outfitName=outfitName, playerName=playerName, displayName=displayName, userId=userId, savedAt=tick()}
	persistSavedOutfits()
end

local function removeOutfitFromCache(outfitId, userId)
	if not SavedOutfitsState.loaded then loadSavedOutfitsFromCache(true) end
	local key = tostring(userId).."_"..tostring(outfitId)
	local entry = SavedOutfitsState.outfits[key]
	if entry and entry.isFolder then
		for _, so in pairs(SavedOutfitsState.outfits) do if so.parentFolder == tostring(outfitId) then so.parentFolder = nil end end
	end
	SavedOutfitsState.outfits[key] = nil; persistSavedOutfits()
end

local function countSavedOutfits() local n=0; for _ in pairs(SavedOutfitsState.outfits) do n=n+1 end; return n end
ensureBaseFolders(); loadSavedOutfitsFromCache(true)

local HTTP_CFG = {MIN_DELAY=0.10, MAX_RETRIES=3, BACKOFF_BASE=1.0, RATE_LIMIT_WAIT=2.5, RATE_LIMIT_JITTER=0.25, MIN_DELAY_JITTER=0.04, ITEMS_PAGE=100, MAX_PAGES=200}

local PROXY_HOSTS = {"avatar.roproxy.com"}
local proxyHealth = {}
for _, host in ipairs(PROXY_HOSTS) do proxyHealth[host] = {failures=0, lastFailure=0, cooldownUntil=0, successCount=0, blacklisted=false} end
local PROXY_FAIL_THRESH, PROXY_FAIL_CD, PROXY_SW_CD = 3, 30, 5
local globalProxyCooldownUntil, lastProxySwitch, proxyIndex = 0, 0, 1

local function getNextProxy()
	local now = tick()
	if now < globalProxyCooldownUntil or now - lastProxySwitch < PROXY_SW_CD then return PROXY_HOSTS[proxyIndex] end
	local attempts = 0
	while attempts < #PROXY_HOSTS do
		local h = proxyHealth[PROXY_HOSTS[proxyIndex]]
		if h and not h.blacklisted and h.failures < PROXY_FAIL_THRESH then return PROXY_HOSTS[proxyIndex] end
		proxyIndex = (proxyIndex % #PROXY_HOSTS) + 1; attempts = attempts + 1
	end
	lastProxySwitch = now; return PROXY_HOSTS[proxyIndex]
end

local function getCurrentProxy()
	local attempts = 0
	while attempts < #PROXY_HOSTS do
		local h = proxyHealth[PROXY_HOSTS[proxyIndex]]
		if h and not h.blacklisted then return PROXY_HOSTS[proxyIndex] end
		proxyIndex = (proxyIndex % #PROXY_HOSTS) + 1; attempts = attempts + 1
	end
	return PROXY_HOSTS[proxyIndex]
end

local function rotateProxyForNextLoad() proxyIndex = (proxyIndex % #PROXY_HOSTS) + 1 end
local function markProxySuccess(host) if proxyHealth[host] then proxyHealth[host].failures = math.max(0, proxyHealth[host].failures-1); proxyHealth[host].successCount = proxyHealth[host].successCount+1 end end
local function markProxyFailure(host) if proxyHealth[host] then proxyHealth[host].failures = proxyHealth[host].failures+1; proxyHealth[host].lastFailure = tick(); if proxyHealth[host].failures >= PROXY_FAIL_THRESH then proxyHealth[host].cooldownUntil = tick()+PROXY_FAIL_CD end end end
local function isProxyInCooldown(host) local h = proxyHealth[host]; return h and tick() < h.cooldownUntil end
local function buildUrl(host, userId, token)
	local base = string.format("https://%s/v2/avatar/users/%d/outfits?itemsPerPage=%d", host, userId, HTTP_CFG.ITEMS_PAGE)
	if token and token ~= "" then base = base.."&paginationToken="..tostring(token) end
	return base
end

local HttpQueue = {rateLimitCooldown=0, requestQueue={}, queueRunning=false, inFlightOutfits={}, inFlightDetails={}}

local function _resolveHttpFunc()
	local raw = (syn and type(syn.request)=="function" and syn.request)
		or (http and type(http.request)=="function" and http.request)
		or (fluxus and type(fluxus.request)=="function" and fluxus.request)
		or (typeof(request)=="function" and request)
		or (typeof(http_request)=="function" and http_request) or nil
	if not raw then return nil end
	return function(opts)
		local ok, resp = pcall(raw, opts)
		if not ok or type(resp) ~= "table" then return nil end
		local code = tonumber(resp.StatusCode or resp.statusCode or resp.status_code) or 0
		return {StatusCode=code, Body=resp.Body or resp.body or "", Headers=resp.Headers or resp.headers or {}}
	end
end
local httpFunc = _resolveHttpFunc()

local function getJitter(max) return math.random() * (max or 0) end
local function parseRetryAfter(resp)
	if type(resp) ~= "table" or type(resp.Headers) ~= "table" then return nil end
	return tonumber(resp.Headers["Retry-After"] or resp.Headers["retry-after"] or "")
end

local function runSingleFlight(store, key, fn)
	local ex = store[key]
	if ex then local co = coroutine.running(); table.insert(ex.waiters, co); return coroutine.yield() end
	local entry = {waiters={}}; store[key] = entry
	local packed = table.pack(pcall(fn))
	local results = packed[1] and table.pack(table.unpack(packed, 2, packed.n)) or table.pack(nil, tostring(packed[2]))
	store[key] = nil
	for _, co in ipairs(entry.waiters) do task.spawn(function() pcall(coroutine.resume, co, table.unpack(results, 1, results.n)) end) end
	return table.unpack(results, 1, results.n)
end

local enqueueRequest
enqueueRequest = function(fn)
	local co = coroutine.running()
	table.insert(HttpQueue.requestQueue, function()
		local r = table.pack(fn())
		task.spawn(function() pcall(coroutine.resume, co, table.unpack(r, 1, r.n)) end)
	end)
	if not HttpQueue.queueRunning then
		HttpQueue.queueRunning = true
		task.spawn(function()
			while #HttpQueue.requestQueue > 0 do
				local rem = HttpQueue.rateLimitCooldown - tick()
				if rem > 0 then task.wait(rem + getJitter(HTTP_CFG.RATE_LIMIT_JITTER * 0.35)) end
				table.remove(HttpQueue.requestQueue, 1)()
				task.wait(HTTP_CFG.MIN_DELAY + getJitter(HTTP_CFG.MIN_DELAY_JITTER))
			end
			HttpQueue.queueRunning = false
		end)
	end
	return coroutine.yield()
end

local function httpGetWithRetry(url)
	if not httpFunc then return nil, "Kein HTTP-Executor" end
	local lastErr, currentHost = nil, url:match("https://([^/]+)")
	for attempt = 1, HTTP_CFG.MAX_RETRIES do
		if currentHost and isProxyInCooldown(currentHost) then
			local np = getNextProxy()
			if np ~= currentHost then currentHost = np; url = url:gsub("https://[^/]+", "https://"..np, 1) end
		end
		local ok, resp = pcall(httpFunc, {Url=url, Method="GET", Headers={["Accept"]="application/json"}})
		if ok and resp then
			local code = resp.StatusCode
			if code == 200 then
				if currentHost then markProxySuccess(currentHost) end; return resp.Body, nil
			elseif code == 429 then
				lastErr = "429 Rate Limit"; if currentHost then markProxyFailure(currentHost) end
				local ra = parseRetryAfter(resp)
				local wait = math.max(HTTP_CFG.RATE_LIMIT_WAIT, ra or 0) + getJitter(HTTP_CFG.RATE_LIMIT_JITTER)
				HttpQueue.rateLimitCooldown = math.max(HttpQueue.rateLimitCooldown, tick()+wait)
				local np = getNextProxy()
				if np ~= currentHost then currentHost = np; url = url:gsub("https://[^/]+", "https://"..np, 1) end
				task.wait(0.5 + getJitter(0.2))
			elseif code == 403 then
				lastErr = "403 Forbidden"; if currentHost then markProxyFailure(currentHost) end
				local np = getNextProxy()
				if np ~= currentHost then currentHost = np; url = url:gsub("https://[^/]+", "https://"..np, 1) end
				task.wait(0.3 + getJitter(0.15))
			elseif code >= 500 then
				lastErr = "Server "..code
				task.wait((HTTP_CFG.BACKOFF_BASE * (attempt - 0.25)) + getJitter(0.35))
			else return nil, "HTTP "..code end
		else
			lastErr = "pcall-Fehler"; if currentHost then markProxyFailure(currentHost) end
			task.wait(0.45 + getJitter(0.25))
		end
	end
	return nil, lastErr or "Max Versuche erreicht"
end

local function fetchOutfitsViaHttp(uid)
	local cached = cacheGet(uid); if cached then return cached, nil end
	local diskEntry = diskCacheRead(uid)
	if diskEntry and type(diskEntry.outfits) == "table" and #diskEntry.outfits > 0 then cacheSet(uid, diskEntry.outfits); return diskEntry.outfits, nil end
	if not httpFunc then return nil, "Kein HTTP-Executor" end
	return runSingleFlight(HttpQueue.inFlightOutfits, uid, function()
		local fc = cacheGet(uid); if fc then return fc, nil end
		local fd = diskCacheRead(uid)
		if fd and type(fd.outfits) == "table" and #fd.outfits > 0 then cacheSet(uid, fd.outfits); return fd.outfits, nil end
		rotateProxyForNextLoad()
		local all, token = {}, ""
		for page = 1, HTTP_CFG.MAX_PAGES do
			local url = buildUrl(getCurrentProxy(), uid, token)
			local body, err = httpGetWithRetry(url)
			if err then if #all > 0 then break end; return nil, err end
			local ok, parsed = pcall(HttpService.JSONDecode, HttpService, body)
			if not ok or type(parsed) ~= "table" then break end
			if parsed.errors and #parsed.errors > 0 then return nil, "Inventar ist Privat" end
			if not parsed.data then break end
			for _, item in ipairs(parsed.data) do table.insert(all, {name=item.name, id=item.id}) end
			token = parsed.paginationToken; if not token or token == "" then break end
			task.wait(HTTP_CFG.MIN_DELAY + getJitter(HTTP_CFG.MIN_DELAY_JITTER))
		end
		if #all > 0 then cacheSet(uid, all); diskCacheWrite(uid, all)
		else cacheDel(uid); diskCacheInvalidate(uid) end
		return all, nil
	end)
end

local _activeOutfitId = nil
local function applyOutfit(outfitId)
	local success, bridgeNet = pcall(function()
		return require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BridgeNet"))
	end)
	if not success then
		warn("[AvatarOutfitPanel] Internal Error: an internal conflict with data happened, please open a ticket and report this.")
		return false
	end
	if bridgeNet then
		bridgeNet.CreateBridge("Communication/SetCharacter"):InvokeServerAsync(outfitId)
		_activeOutfitId = outfitId
		return true
	end
	return false
end

local _activeOutfitRespawnToken = 0
local function queueActiveOutfitReapply()
	if not _activeOutfitId then return end
	_activeOutfitRespawnToken = _activeOutfitRespawnToken + 1
	local token = _activeOutfitRespawnToken
	task.spawn(function()
		for _, delaySec in ipairs({0.15, 0.45, 0.9, 1.5}) do
			task.wait(delaySec)
			if token ~= _activeOutfitRespawnToken or not _activeOutfitId then return end
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if hum and hrp and hum.Health > 0 then if applyOutfit(_activeOutfitId) then return end end
		end
	end)
end

bind(LocalPlayer.CharacterAdded, function() queueActiveOutfitReapply() end)
pcall(function()
	bind(LocalPlayer.CharacterAppearanceLoaded, function(char)
		if char == LocalPlayer.Character then queueActiveOutfitReapply() end
	end)
end)

local existingPG = LocalPlayer:FindFirstChild("PlayerGui")
if existingPG then
	for _, n in ipairs({"AvatarOutfitPanel", "AvatarOutfitPanelHint"}) do
		local e = existingPG:FindFirstChild(n); if e then pcall(e.Destroy, e) end
	end
end

local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "AvatarOutfitPanel"
ScreenGui.ResetOnSpawn = false; ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
regInst(ScreenGui); pcall(function() ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)

local _avatarThumbCache = {}
local function avatarThumbUrl(uid) if not _avatarThumbCache[uid] then _avatarThumbCache[uid] = string.format("rbxthumb://type=%s&id=%d&w=150&h=150", C.THUMBTYPE, uid) end; return _avatarThumbCache[uid] end
local _outfitThumbCache = {}
local function outfitThumbUrl(outfitId)
	local n = tonumber(outfitId); if not n then return "" end
	if not _outfitThumbCache[n] then _outfitThumbCache[n] = string.format("rbxthumb://type=Outfit&id=%d&w=%d&h=%d", n, C.OUTFIT_THUMB_SIZE, C.OUTFIT_THUMB_SIZE) end
	return _outfitThumbCache[n]
end

local closeOutfitPanel, currentSubPlayer, _skipPanelReopen = nil, nil, false

local Panel, TitleBar, SearchBox, SearchStatusLabel, ConfirmBtn, SavedOutfitsBtn, RefreshBtn, CloseBtn, PlayerCardsScroll, PlayerCardsLabel, PlayerCardsSep, TabUI = (function()
	local Panel = Instance.new("Frame")
	Panel.Name = "Panel"; Panel.Size = UDim2.fromOffset(C.PANEL_W, 130)
	Panel.Position = UDim2.fromScale(0.5, 0.5); Panel.AnchorPoint = Vector2.new(0.5, 0.5)
	Panel.BackgroundColor3 = C.panelBg; Panel.BorderSizePixel = 0; Panel.ClipsDescendants = true
	Panel.ZIndex = 11; Panel.Visible = false; Panel.Parent = ScreenGui; corner(Panel, 10)
	stroke(Panel, 1.2, C.bg3 or Color3.fromRGB(45,45,45), 0.2)

	local TitleBar = Instance.new("Frame"); TitleBar.Size = UDim2.new(1,0,0,44)
	TitleBar.BackgroundColor3 = C.panelHdr; TitleBar.BorderSizePixel = 0
	TitleBar.ClipsDescendants = true; TitleBar.ZIndex = 20; TitleBar.Parent = Panel; corner(TitleBar, 10)
	local sep = Instance.new("Frame", Panel); sep.Size = UDim2.new(1,0,0,1); sep.Position = UDim2.new(0,0,0,44)
	sep.BackgroundColor3 = C.bg3 or Color3.fromRGB(45,45,45); sep.BorderSizePixel = 0; sep.ZIndex = 12

	local TabBar = Instance.new("Frame"); TabBar.Size = UDim2.new(1,-16,0,30)
	TabBar.Position = UDim2.fromOffset(8,48); TabBar.BackgroundColor3 = Color3.fromRGB(22,22,22)
	TabBar.BorderSizePixel = 0; TabBar.ZIndex = 25; TabBar.Parent = Panel; corner(TabBar, 8)

	local tabW = math.floor((C.PANEL_W - 28) / 3)

	local ServerTabBtn = Instance.new("TextButton"); ServerTabBtn.Text = "Server"
	ServerTabBtn.Size = UDim2.fromOffset(tabW, 30); ServerTabBtn.Position = UDim2.new(0,0,0,0)
	ServerTabBtn.BackgroundColor3 = C.accent; ServerTabBtn.BackgroundTransparency = 0
	ServerTabBtn.TextColor3 = Color3.new(1,1,1); ServerTabBtn.TextSize = 12
	ServerTabBtn.Font = Enum.Font.GothamBold; ServerTabBtn.BorderSizePixel = 0
	ServerTabBtn.ZIndex = 26; ServerTabBtn.Parent = TabBar; applyTextStyle(ServerTabBtn); corner(ServerTabBtn, 8)

	local SearchTabBtn = Instance.new("TextButton"); SearchTabBtn.Text = "Suche"
	SearchTabBtn.Size = UDim2.fromOffset(tabW, 30); SearchTabBtn.Position = UDim2.fromOffset(tabW + 4, 0)
	SearchTabBtn.BackgroundColor3 = Color3.new(0,0,0); SearchTabBtn.BackgroundTransparency = 1
	SearchTabBtn.TextColor3 = C.TEXT2; SearchTabBtn.TextSize = 12
	SearchTabBtn.Font = Enum.Font.GothamBold; SearchTabBtn.BorderSizePixel = 0
	SearchTabBtn.ZIndex = 26; SearchTabBtn.Parent = TabBar; applyTextStyle(SearchTabBtn); corner(SearchTabBtn, 8)

	local OutfitSearchTabBtn = Instance.new("TextButton"); OutfitSearchTabBtn.Text = "Outfits"
	OutfitSearchTabBtn.Size = UDim2.fromOffset(tabW, 30); OutfitSearchTabBtn.Position = UDim2.new(1,0,0,0)
	OutfitSearchTabBtn.AnchorPoint = Vector2.new(1,0); OutfitSearchTabBtn.BackgroundColor3 = Color3.new(0,0,0)
	OutfitSearchTabBtn.BackgroundTransparency = 1; OutfitSearchTabBtn.TextColor3 = C.TEXT2
	OutfitSearchTabBtn.TextSize = 12; OutfitSearchTabBtn.Font = Enum.Font.GothamBold
	OutfitSearchTabBtn.BorderSizePixel = 0; OutfitSearchTabBtn.ZIndex = 26
	OutfitSearchTabBtn.Parent = TabBar; applyTextStyle(OutfitSearchTabBtn); corner(OutfitSearchTabBtn, 8)

	local tf = Instance.new("Frame"); tf.Size = UDim2.new(1,0,0,10); tf.Position = UDim2.new(0,0,1,-10)
	tf.BackgroundColor3 = C.TITLEBAR; tf.BorderSizePixel = 0; tf.ZIndex = 12; tf.Parent = TitleBar; corner(tf, 10)
	local tLine = Instance.new("Frame"); tLine.Size = UDim2.new(1,0,0,1); tLine.Position = UDim2.new(0,0,1,-1)
	tLine.BackgroundColor3 = C.ACCENT; tLine.BackgroundTransparency = 0.86; tLine.BorderSizePixel = 0; tLine.ZIndex = 13; tLine.Parent = TitleBar

	local tIcon = Instance.new("ImageLabel"); tIcon.ScaleType = Enum.ScaleType.Fit
	tIcon.Image = "rbxassetid://125139667304157"; tIcon.Size = UDim2.fromOffset(24,24); tIcon.Position = UDim2.fromOffset(6,10)
	tIcon.BackgroundTransparency = 1; tIcon.ImageColor3 = Color3.fromRGB(255,255,255); tIcon.ZIndex = 21; tIcon.Parent = TitleBar

	local tLabel = Instance.new("TextLabel"); tLabel.Text = "TLSTEAL AVATARS"
	tLabel.Size = UDim2.new(1,-158,1,0); tLabel.Position = UDim2.fromOffset(38,0)
	tLabel.BackgroundTransparency = 1; tLabel.TextSize = 13; tLabel.TextColor3 = C.TEXT1
	tLabel.TextXAlignment = Enum.TextXAlignment.Left; tLabel.ZIndex = 21; tLabel.Parent = TitleBar; applyTextStyle(tLabel)

	local padding, btnSize = 4, _isMobile and 32 or 26
	local posRefresh = -38 - padding
	local posSaved = posRefresh - btnSize - padding

	local SavedOutfitsBtn = mkIconBtn(TitleBar, btnSize, posSaved, "rbxassetid://71210277815919", 14)
	local RefreshBtn = mkIconBtn(TitleBar, btnSize, posRefresh, "rbxassetid://137689074320233", 14)
	local CloseBtn = mkCloseBtn(TitleBar, 26, 1, -38, 0.5, 0); CloseBtn.ZIndex = 14

	local SearchRow = Instance.new("Frame"); SearchRow.Size = UDim2.new(1,-16,0,34)
	SearchRow.Position = UDim2.fromOffset(8,88)
	SearchRow.BackgroundTransparency = 1; SearchRow.BorderSizePixel = 0; SearchRow.ZIndex = 12; SearchRow.Parent = Panel

	local SearchPill = Instance.new("Frame"); SearchPill.Size = UDim2.new(1,0,1,0)
	SearchPill.BackgroundColor3 = Color3.fromRGB(14,14,14); SearchPill.BorderSizePixel = 0
	SearchPill.ClipsDescendants = true; SearchPill.ZIndex = 12; SearchPill.Parent = SearchRow; corner(SearchPill, 16)
	local spGrad = Instance.new("UIGradient"); spGrad.Rotation = 90
	spGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(24,24,28)),ColorSequenceKeypoint.new(1,Color3.fromRGB(14,14,16))})
	spGrad.Parent = SearchPill
	local spS = stroke(SearchPill, 1, Color3.fromRGB(52,52,58), 0.1)

	local SearchIcon = Instance.new("TextLabel"); SearchIcon.Size = UDim2.fromOffset(20,34)
	SearchIcon.Position = UDim2.fromOffset(10,0); SearchIcon.BackgroundTransparency = 1; SearchIcon.Text = ""
	SearchIcon.TextSize = 16; SearchIcon.TextColor3 = Color3.fromRGB(90,90,96); SearchIcon.Font = Enum.Font.GothamBold
	SearchIcon.TextYAlignment = Enum.TextYAlignment.Center; SearchIcon.ZIndex = 13; SearchIcon.Parent = SearchPill

	local SearchBox = Instance.new("TextBox"); SearchBox.Name = "PlayerSearchBox"
	SearchBox.PlaceholderText = "Name, ID oder Outfitname..."; SearchBox.Text = ""; SearchBox.ClearTextOnFocus = false
	SearchBox.Size = UDim2.new(1,-42,1,0); SearchBox.Position = UDim2.fromOffset(32,0)
	SearchBox.BackgroundTransparency = 1; SearchBox.TextSize = 13; SearchBox.TextColor3 = C.TEXT1
	SearchBox.PlaceholderColor3 = C.TEXT2; SearchBox.TextXAlignment = Enum.TextXAlignment.Left
	SearchBox.TextYAlignment = Enum.TextYAlignment.Center; SearchBox.ZIndex = 13; SearchBox.Parent = SearchPill; applyTextStyle(SearchBox)

	bind(SearchBox.Focused, function()
		tween(spS, TI._008, {Color=Color3.fromRGB(255,255,255), Transparency=0, Thickness=1.4}):Play()
	end)
	bind(SearchBox.FocusLost, function()
		tween(spS, TI._012, {Color=Color3.fromRGB(52,52,58), Transparency=0.1, Thickness=1}):Play()
	end)
	bind(SearchPill.MouseEnter, function() if not SearchBox:IsFocused() then tween(spS, TI._008, {Color=Color3.fromRGB(80,80,88), Transparency=0}):Play() end end)
	bind(SearchPill.MouseLeave, function() if not SearchBox:IsFocused() then tween(spS, TI._012, {Color=Color3.fromRGB(52,52,58), Transparency=0.1}):Play() end end)

	local SearchStatusLabel = Instance.new("TextLabel"); SearchStatusLabel.Size = UDim2.new(1,-16,0,20)
	SearchStatusLabel.Position = UDim2.fromOffset(8,128); SearchStatusLabel.BackgroundTransparency = 1
	SearchStatusLabel.Text = ""; SearchStatusLabel.TextSize = 11; SearchStatusLabel.TextColor3 = C.TEXT2
	SearchStatusLabel.TextXAlignment = Enum.TextXAlignment.Left; SearchStatusLabel.ZIndex = 12; SearchStatusLabel.Parent = Panel; applyTextStyle(SearchStatusLabel)

	local ConfirmBtn = Instance.new("TextButton"); ConfirmBtn.Size = UDim2.new(1,-16,0,32)
	ConfirmBtn.Position = UDim2.fromOffset(8,152); ConfirmBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
	ConfirmBtn.BorderSizePixel = 0; ConfirmBtn.Text = "Suchen"; ConfirmBtn.TextSize = 13
	ConfirmBtn.Font = Enum.Font.Gotham; ConfirmBtn.TextColor3 = Color3.fromRGB(255,255,255)
	ConfirmBtn.TextStrokeTransparency = 1; ConfirmBtn.ZIndex = 12; ConfirmBtn.Parent = Panel; corner(ConfirmBtn, 8)
	local cs = stroke(ConfirmBtn, 1, Color3.fromRGB(52,52,58), 0.1)
	cs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	bind(ConfirmBtn.MouseEnter, function() tween(ConfirmBtn, TI._008, {BackgroundColor3=Color3.fromRGB(30,30,30)}):Play() end)
	bind(ConfirmBtn.MouseLeave, function() tween(ConfirmBtn, TI._012, {BackgroundColor3=Color3.fromRGB(0,0,0)}):Play() end)
	bind(ConfirmBtn.MouseButton1Down, function() tween(getPopScale(ConfirmBtn), TI._008, {Scale=0.96}):Play() end)
	bind(ConfirmBtn.MouseButton1Up, function() tween(getPopScale(ConfirmBtn), TI._016, {Scale=1}):Play() end)

	local PlayerCardsLabel = Instance.new("TextLabel"); PlayerCardsLabel.Size = UDim2.new(1,-16,0,16)
	PlayerCardsLabel.Position = UDim2.fromOffset(8,196); PlayerCardsLabel.BackgroundTransparency = 1
	PlayerCardsLabel.Text = "Spieler in dieser Instanz"; PlayerCardsLabel.TextSize = 10
	PlayerCardsLabel.TextColor3 = C.TEXT2; PlayerCardsLabel.TextXAlignment = Enum.TextXAlignment.Left
	PlayerCardsLabel.ZIndex = 12; PlayerCardsLabel.Parent = Panel; applyTextStyle(PlayerCardsLabel)

	local PlayerCardsSep = Instance.new("Frame", Panel); PlayerCardsSep.Size = UDim2.new(1,-16,0,1)
	PlayerCardsSep.Position = UDim2.fromOffset(8,214); PlayerCardsSep.BackgroundColor3 = C.bg3 or Color3.fromRGB(45,45,45)
	PlayerCardsSep.BackgroundTransparency = 0.5; PlayerCardsSep.BorderSizePixel = 0; PlayerCardsSep.ZIndex = 12

	local PlayerCardsScroll = Instance.new("ScrollingFrame"); PlayerCardsScroll.Name = "PlayerCardsScroll"
	PlayerCardsScroll.Size = UDim2.new(1,-16,0,212); PlayerCardsScroll.Position = UDim2.fromOffset(8,220)
	PlayerCardsScroll.BackgroundTransparency = 1; PlayerCardsScroll.BorderSizePixel = 0
	PlayerCardsScroll.ScrollBarThickness = 3; PlayerCardsScroll.ScrollBarImageColor3 = C.accent or Color3.fromRGB(100,100,255)
	PlayerCardsScroll.ScrollBarImageTransparency = 0.4; PlayerCardsScroll.ScrollingDirection = Enum.ScrollingDirection.Y
	PlayerCardsScroll.CanvasSize = UDim2.fromOffset(0,0); PlayerCardsScroll.ElasticBehavior = Enum.ElasticBehavior.Never
	PlayerCardsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; PlayerCardsScroll.ZIndex = 12; PlayerCardsScroll.Parent = Panel
	local pcGrid = Instance.new("UIGridLayout", PlayerCardsScroll); pcGrid.CellSize = UDim2.fromOffset(96,118)
	pcGrid.CellPadding = UDim2.fromOffset(8,8); pcGrid.SortOrder = Enum.SortOrder.LayoutOrder
	pcGrid.HorizontalAlignment = Enum.HorizontalAlignment.Left; pcGrid.VerticalAlignment = Enum.VerticalAlignment.Top
	local pcPad = Instance.new("UIPadding", PlayerCardsScroll)
	pcPad.PaddingLeft = UDim.new(0,4); pcPad.PaddingTop = UDim.new(0,4)
	pcPad.PaddingRight = UDim.new(0,4); pcPad.PaddingBottom = UDim.new(0,4)

	local SearchTabScroll = Instance.new("ScrollingFrame"); SearchTabScroll.Name = "SearchTabScroll"
	SearchTabScroll.Size = UDim2.new(1,-16,0,212); SearchTabScroll.Position = UDim2.fromOffset(8,220)
	SearchTabScroll.BackgroundTransparency = 1; SearchTabScroll.BorderSizePixel = 0
	SearchTabScroll.ScrollBarThickness = 3; SearchTabScroll.ScrollBarImageColor3 = C.accent or Color3.fromRGB(100,100,255)
	SearchTabScroll.ScrollBarImageTransparency = 0.4; SearchTabScroll.ScrollingDirection = Enum.ScrollingDirection.Y
	SearchTabScroll.CanvasSize = UDim2.fromOffset(0,0); SearchTabScroll.ElasticBehavior = Enum.ElasticBehavior.Never
	SearchTabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; SearchTabScroll.ZIndex = 20
	SearchTabScroll.Visible = false; SearchTabScroll.Parent = Panel
	local stGrid = Instance.new("UIGridLayout", SearchTabScroll); stGrid.CellSize = UDim2.fromOffset(96,118)
	stGrid.CellPadding = UDim2.fromOffset(8,8); stGrid.SortOrder = Enum.SortOrder.LayoutOrder
	stGrid.HorizontalAlignment = Enum.HorizontalAlignment.Left; stGrid.VerticalAlignment = Enum.VerticalAlignment.Top
	local stPad = Instance.new("UIPadding", SearchTabScroll)
	stPad.PaddingLeft = UDim.new(0,4); stPad.PaddingTop = UDim.new(0,4)
	stPad.PaddingRight = UDim.new(0,4); stPad.PaddingBottom = UDim.new(0,4)

	local SearchTabEmpty = Instance.new("TextLabel"); SearchTabEmpty.Text = "Keine Ergebnisse"
	SearchTabEmpty.Size = UDim2.new(1,-40,0,40); SearchTabEmpty.Position = UDim2.new(0.5,0,0.5,18)
	SearchTabEmpty.AnchorPoint = Vector2.new(0.5,0.5); SearchTabEmpty.BackgroundTransparency = 1
	SearchTabEmpty.TextSize = 14; SearchTabEmpty.TextColor3 = C.TEXT1
	SearchTabEmpty.TextXAlignment = Enum.TextXAlignment.Center; SearchTabEmpty.ZIndex = 21
	SearchTabEmpty.Visible = false; SearchTabEmpty.Parent = Panel; applyTextStyle(SearchTabEmpty)

	local SearchTabLoading = Instance.new("TextLabel"); SearchTabLoading.Text = "Suche nach Spielern..."
	SearchTabLoading.Size = UDim2.new(1,-40,0,40); SearchTabLoading.Position = UDim2.new(0.5,0,0.5,18)
	SearchTabLoading.AnchorPoint = Vector2.new(0.5,0.5); SearchTabLoading.BackgroundTransparency = 1
	SearchTabLoading.TextSize = 14; SearchTabLoading.TextColor3 = C.TEXT2
	SearchTabLoading.TextXAlignment = Enum.TextXAlignment.Center; SearchTabLoading.ZIndex = 21
	SearchTabLoading.Visible = false; SearchTabLoading.Parent = Panel; applyTextStyle(SearchTabLoading)

	local OutfitSearchScroll = Instance.new("ScrollingFrame"); OutfitSearchScroll.Name = "OutfitSearchScroll"
	OutfitSearchScroll.Size = UDim2.new(1,-16,0,212); OutfitSearchScroll.Position = UDim2.fromOffset(8,220)
	OutfitSearchScroll.BackgroundTransparency = 1; OutfitSearchScroll.BorderSizePixel = 0
	OutfitSearchScroll.ScrollBarThickness = 3; OutfitSearchScroll.ScrollBarImageColor3 = C.accent or Color3.fromRGB(100,100,255)
	OutfitSearchScroll.ScrollBarImageTransparency = 0.4; OutfitSearchScroll.ScrollingDirection = Enum.ScrollingDirection.Y
	OutfitSearchScroll.CanvasSize = UDim2.fromOffset(0,0); OutfitSearchScroll.ElasticBehavior = Enum.ElasticBehavior.Never
	OutfitSearchScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; OutfitSearchScroll.ZIndex = 20
	OutfitSearchScroll.Visible = false; OutfitSearchScroll.Parent = Panel
	local osGrid = Instance.new("UIGridLayout", OutfitSearchScroll); osGrid.CellSize = UDim2.fromOffset(96,118)
	osGrid.CellPadding = UDim2.fromOffset(8,8); osGrid.SortOrder = Enum.SortOrder.LayoutOrder
	osGrid.HorizontalAlignment = Enum.HorizontalAlignment.Left; osGrid.VerticalAlignment = Enum.VerticalAlignment.Top
	local osPad = Instance.new("UIPadding", OutfitSearchScroll)
	osPad.PaddingLeft = UDim.new(0,4); osPad.PaddingTop = UDim.new(0,4)
	osPad.PaddingRight = UDim.new(0,4); osPad.PaddingBottom = UDim.new(0,4)

	local OutfitSearchEmpty = Instance.new("TextLabel")
	OutfitSearchEmpty.Text = "Outfitnamen eingeben + Enter"
	OutfitSearchEmpty.Size = UDim2.new(1,-40,0,60); OutfitSearchEmpty.Position = UDim2.new(0.5,0,0.5,18)
	OutfitSearchEmpty.AnchorPoint = Vector2.new(0.5,0.5); OutfitSearchEmpty.BackgroundTransparency = 1
	OutfitSearchEmpty.TextSize = 13; OutfitSearchEmpty.TextColor3 = C.TEXT2
	OutfitSearchEmpty.TextXAlignment = Enum.TextXAlignment.Center; OutfitSearchEmpty.TextWrapped = true
	OutfitSearchEmpty.ZIndex = 21; OutfitSearchEmpty.Visible = false; OutfitSearchEmpty.Parent = Panel; applyTextStyle(OutfitSearchEmpty)

	local OutfitSearchLoading = Instance.new("TextLabel"); OutfitSearchLoading.Text = "Durchsuche Community DB..."
	OutfitSearchLoading.Size = UDim2.new(1,-40,0,40); OutfitSearchLoading.Position = UDim2.new(0.5,0,0.5,18)
	OutfitSearchLoading.AnchorPoint = Vector2.new(0.5,0.5); OutfitSearchLoading.BackgroundTransparency = 1
	OutfitSearchLoading.TextSize = 14; OutfitSearchLoading.TextColor3 = C.TEXT2
	OutfitSearchLoading.TextXAlignment = Enum.TextXAlignment.Center; OutfitSearchLoading.ZIndex = 21
	OutfitSearchLoading.Visible = false; OutfitSearchLoading.Parent = Panel; applyTextStyle(OutfitSearchLoading)

	makeDraggable(TitleBar, Panel)
	return Panel, TitleBar, SearchBox, SearchStatusLabel, ConfirmBtn, SavedOutfitsBtn, RefreshBtn, CloseBtn, PlayerCardsScroll, PlayerCardsLabel, PlayerCardsSep, {
		TabBar=TabBar, ServerTabBtn=ServerTabBtn, SearchTabBtn=SearchTabBtn,
		OutfitSearchTabBtn=OutfitSearchTabBtn, SearchTabScroll=SearchTabScroll,
		SearchTabEmpty=SearchTabEmpty, SearchTabLoading=SearchTabLoading,
		OutfitSearchScroll=OutfitSearchScroll, OutfitSearchEmpty=OutfitSearchEmpty,
		OutfitSearchLoading=OutfitSearchLoading,
	}
end)()

local _activeTab = "server"
local _searchResults = {}
local _searchPage = 1
local _searchQuery = ""
local _searchLoading = false
local _searchNextCursor = ""
local _outfitSearchLoading = false
local CARD_W_PC, CARD_H_PC = 96, 118

local function switchTab(tabName)
	if tabName == _activeTab then return end
	_activeTab = tabName
	tween(TabUI.ServerTabBtn, TI._012, {BackgroundTransparency=1}):Play()
	tween(TabUI.ServerTabBtn, TI._012, {TextColor3=C.TEXT2}):Play()
	tween(TabUI.SearchTabBtn, TI._012, {BackgroundTransparency=1}):Play()
	tween(TabUI.SearchTabBtn, TI._012, {TextColor3=C.TEXT2}):Play()
	tween(TabUI.OutfitSearchTabBtn, TI._012, {BackgroundTransparency=1}):Play()
	tween(TabUI.OutfitSearchTabBtn, TI._012, {TextColor3=C.TEXT2}):Play()
	PlayerCardsLabel.Visible = false; PlayerCardsSep.Visible = false; PlayerCardsScroll.Visible = false
	TabUI.SearchTabScroll.Visible = false; TabUI.SearchTabEmpty.Visible = false; TabUI.SearchTabLoading.Visible = false
	TabUI.OutfitSearchScroll.Visible = false; TabUI.OutfitSearchEmpty.Visible = false; TabUI.OutfitSearchLoading.Visible = false
	if tabName == "server" then
		tween(TabUI.ServerTabBtn, TI._012, {BackgroundColor3=C.accent, BackgroundTransparency=0}):Play()
		tween(TabUI.ServerTabBtn, TI._012, {TextColor3=Color3.new(1,1,1)}):Play()
		PlayerCardsLabel.Visible = true; PlayerCardsSep.Visible = true; PlayerCardsScroll.Visible = true
	elseif tabName == "search" then
		tween(TabUI.SearchTabBtn, TI._012, {BackgroundColor3=C.accent, BackgroundTransparency=0}):Play()
		tween(TabUI.SearchTabBtn, TI._012, {TextColor3=Color3.new(1,1,1)}):Play()
		TabUI.SearchTabScroll.Visible = true
		if #_searchResults == 0 and not _searchLoading then
			TabUI.SearchTabEmpty.Text = "Suchbegriff eingeben + Enter"; TabUI.SearchTabEmpty.Visible = true
		end
	elseif tabName == "outfitsearch" then
		tween(TabUI.OutfitSearchTabBtn, TI._012, {BackgroundColor3=C.accent, BackgroundTransparency=0}):Play()
		tween(TabUI.OutfitSearchTabBtn, TI._012, {TextColor3=Color3.new(1,1,1)}):Play()
		TabUI.OutfitSearchScroll.Visible = true
		local hasChildren = false
		for _, ch in ipairs(TabUI.OutfitSearchScroll:GetChildren()) do if ch:IsA("ImageButton") then hasChildren = true; break end end
		if not hasChildren then
			task.spawn(function()
				if not httpFunc then TabUI.OutfitSearchEmpty.Text = "Outfitnamen eingeben + Enter"; TabUI.OutfitSearchEmpty.Visible = true; return end
				local ok, resp = pcall(httpFunc, {Url=COMMUNITY_API_BASE.."/stats", Method="GET", Headers={["Accept"]="application/json"}})
				if ok and resp and resp.StatusCode == 200 then
					local d = HttpService:JSONDecode(resp.Body)
					TabUI.OutfitSearchEmpty.Text = string.format("Community Datenbank:\n%s Outfits von %s Spielern\n\nOutfitnamen eingeben + Enter", tostring(d.total_outfits or 0), tostring(d.total_users or 0))
				else TabUI.OutfitSearchEmpty.Text = "Outfitnamen eingeben + Enter" end
				TabUI.OutfitSearchEmpty.Visible = true
			end)
		end
	end
end

local function searchPlayers(query, cursor)
	local url = string.format("https://users.roproxy.com/v1/users/search?keyword=%s&limit=50", HttpService:UrlEncode(query))
	if cursor and cursor ~= "" then url = url.."&cursor="..HttpService:UrlEncode(cursor) end
	if not httpFunc then return nil, nil, "Kein HTTP-Executor" end
	local ok, response = pcall(httpFunc, {Url=url, Method="GET", Headers={["Accept"]="application/json"}})
	if not ok or not response or (response.StatusCode ~= 200) then return nil, nil, "HTTP Request fehlgeschlagen" end
	local decodeOk, parsed = pcall(HttpService.JSONDecode, HttpService, response.Body)
	if not decodeOk or type(parsed) ~= "table" then return nil, nil, "JSON-Fehler" end
	local results = {}
	if type(parsed.data) == "table" then
		for _, entry in ipairs(parsed.data) do
			table.insert(results, {userId=entry.id, name=entry.name, displayName=entry.displayName or entry.name})
		end
	end
	return results, parsed.nextPageCursor or "", nil
end

local openOutfitPanel

local function buildOutfitResultCard(parent, outfitData, idx)
	local card = Instance.new("ImageButton"); card.Name = "OSC_"..tostring(outfitData.outfitId)
	card.Size = UDim2.fromOffset(CARD_W_PC, CARD_H_PC); card.BackgroundColor3 = C.panelHdr or Color3.fromRGB(22,22,26)
	card.BackgroundTransparency = 0; card.BorderSizePixel = 0; card.ZIndex = 21; card.LayoutOrder = idx; card.Parent = parent; corner(card, 10)
	local cStroke = Instance.new("UIStroke", card); cStroke.Thickness = 1; cStroke.Color = C.bg3 or Color3.fromRGB(45,45,45); cStroke.Transparency = 0.4
	local thumb = Instance.new("ImageLabel", card); thumb.Size = UDim2.fromOffset(68,68)
	thumb.Position = UDim2.new(0.5,0,0,8); thumb.AnchorPoint = Vector2.new(0.5,0)
	thumb.BackgroundColor3 = Color3.fromRGB(14,14,14); thumb.BackgroundTransparency = 0; thumb.BorderSizePixel = 0
	thumb.ScaleType = Enum.ScaleType.Fit; thumb.ZIndex = 22; corner(thumb, 8)
	local nId = tonumber(outfitData.outfitId); if nId then thumb.Image = outfitThumbUrl(nId) end
	local thumbRing = Instance.new("UIStroke", thumb); thumbRing.Thickness = 1.5; thumbRing.Color = C.accent or Color3.fromRGB(100,100,255); thumbRing.Transparency = 0.6
	local nameLbl = Instance.new("TextLabel", card); nameLbl.Size = UDim2.new(1,-6,0,20); nameLbl.Position = UDim2.fromOffset(3,80)
	nameLbl.BackgroundTransparency = 1; nameLbl.Text = outfitData.outfitName or "Unnamed"; nameLbl.TextSize = 10
	nameLbl.TextColor3 = C.TEXT1; nameLbl.TextXAlignment = Enum.TextXAlignment.Center; nameLbl.TextWrapped = false
	nameLbl.TextTruncate = Enum.TextTruncate.AtEnd; nameLbl.ZIndex = 22; applyTextStyle(nameLbl)
	local ownerLbl = Instance.new("TextLabel", card); ownerLbl.Size = UDim2.new(1,-6,0,14); ownerLbl.Position = UDim2.fromOffset(3,100)
	ownerLbl.BackgroundTransparency = 1; ownerLbl.Text = "@"..(outfitData.playerName or "?"); ownerLbl.TextSize = 8
	ownerLbl.TextColor3 = C.TEXT2; ownerLbl.TextXAlignment = Enum.TextXAlignment.Center; ownerLbl.TextTruncate = Enum.TextTruncate.AtEnd; ownerLbl.ZIndex = 22; applyTextStyle(ownerLbl)
	local hoverBg = C.accent or Color3.fromRGB(100,100,255); local normalBg = C.panelHdr or Color3.fromRGB(22,22,26)
	bind(card.MouseEnter, function() tween(card, TI._008, {BackgroundColor3=hoverBg:lerp(normalBg,0.72)}):Play(); tween(cStroke, TI._008, {Color=hoverBg, Transparency=0}):Play(); tween(thumbRing, TI._008, {Transparency=0.1}):Play() end)
	bind(card.MouseLeave, function() tween(card, TI._012, {BackgroundColor3=normalBg}):Play(); tween(cStroke, TI._012, {Color=C.bg3 or Color3.fromRGB(45,45,45), Transparency=0.4}):Play(); tween(thumbRing, TI._012, {Transparency=0.6}):Play() end)
	local saveBtn = Instance.new("ImageButton"); saveBtn.Name = "SaveBtn"; saveBtn.Size = UDim2.fromOffset(22,22)
	saveBtn.Position = UDim2.new(1,-28,1,-38); saveBtn.Image = "rbxassetid://120703890568713"
	saveBtn.ImageColor3 = Color3.fromRGB(255,255,255); saveBtn.BackgroundTransparency = 1; saveBtn.BorderSizePixel = 0; saveBtn.ZIndex = 26; saveBtn.Parent = card; corner(saveBtn, 5)
	bind(saveBtn.MouseButton1Down, function() tween(getPopScale(saveBtn), TI._008, {Scale=0.85}):Play() end)
	bind(saveBtn.MouseButton1Up, function() tween(getPopScale(saveBtn), TI._016, {Scale=1}):Play() end)
	bind(saveBtn.MouseButton1Click, function()
		local uid = outfitData.userId or LocalPlayer.UserId; local uname = outfitData.playerName or LocalPlayer.Name; local dname = outfitData.displayName or LocalPlayer.DisplayName
		saveOutfitToCache(outfitData.outfitId, outfitData.outfitName or "Unnamed", uname, dname, uid)
		tween(saveBtn, getTI(0.15), {BackgroundColor3=Color3.fromRGB(28,46,28)}):Play()
		task.delay(0.6, function() tween(saveBtn, TI._020, {BackgroundColor3=Color3.fromRGB(18,18,18)}):Play() end)
	end)
	bind(card.MouseButton1Down, function() tween(getPopScale(card), TI._008, {Scale=0.93}):Play() end)
	bind(card.MouseButton1Up, function() tween(getPopScale(card), TI._016, {Scale=1}):Play() end)
	bind(card.MouseButton1Click, function() local noid = tonumber(outfitData.outfitId); if noid then applyOutfit(noid) end end)
	return card
end

local function executeOutfitNameSearch()
	if _outfitSearchLoading then return end
	local raw = SearchBox.Text:match("^%s*(.-)%s*$")
	if raw == "" then
		for _, ch in ipairs(TabUI.OutfitSearchScroll:GetChildren()) do if ch:IsA("ImageButton") or ch:IsA("Frame") then ch:Destroy() end end
		TabUI.OutfitSearchScroll.CanvasSize = UDim2.fromOffset(0,0); TabUI.OutfitSearchLoading.Visible = false
		TabUI.OutfitSearchEmpty.Text = "Outfitnamen eingeben + Enter"; TabUI.OutfitSearchEmpty.Visible = true
		task.spawn(function()
			if not httpFunc then return end
			local ok, resp = pcall(httpFunc, {Url=COMMUNITY_API_BASE.."/stats", Method="GET", Headers={["Accept"]="application/json"}})
			if ok and resp and resp.StatusCode == 200 then
				local d = HttpService:JSONDecode(resp.Body)
				TabUI.OutfitSearchEmpty.Text = string.format("Community Datenbank:\n%s Outfits von %s Spielern\n\nOutfitnamen eingeben + Enter", tostring(d.total_outfits or 0), tostring(d.total_users or 0))
			end
		end)
		return
	end
	_outfitSearchLoading = true
	for _, ch in ipairs(TabUI.OutfitSearchScroll:GetChildren()) do if ch:IsA("ImageButton") or ch:IsA("Frame") then ch:Destroy() end end
	TabUI.OutfitSearchScroll.CanvasSize = UDim2.fromOffset(0,0); TabUI.OutfitSearchScroll.CanvasPosition = Vector2.new(0,0)
	TabUI.OutfitSearchEmpty.Visible = false; TabUI.OutfitSearchLoading.Visible = true
	if _activeTab ~= "outfitsearch" then switchTab("outfitsearch") end
	task.spawn(function()
		if not httpFunc then _outfitSearchLoading = false; TabUI.OutfitSearchLoading.Visible = false; TabUI.OutfitSearchEmpty.Text = "HTTP nicht verfuegbar"; TabUI.OutfitSearchEmpty.Visible = true; return end
		local ok, resp = pcall(httpFunc, {Url=COMMUNITY_API_BASE.."/search?q="..HttpService:UrlEncode(raw).."&limit=100", Method="GET", Headers={["Accept"]="application/json"}})
		_outfitSearchLoading = false; TabUI.OutfitSearchLoading.Visible = false
		if not ok or not resp or resp.StatusCode ~= 200 then TabUI.OutfitSearchEmpty.Text = "Community API nicht erreichbar"; TabUI.OutfitSearchEmpty.Visible = true; return end
		local parsed; local okParse = pcall(function() parsed = HttpService:JSONDecode(resp.Body) end)
		if not okParse or not parsed or not parsed.results or #parsed.results == 0 then
			TabUI.OutfitSearchEmpty.Text = 'Kein Outfit "'..raw..'" gefunden\n\nTipp: Erst Spieler-Outfits laden!'; TabUI.OutfitSearchEmpty.Visible = true; return
		end
		TabUI.OutfitSearchEmpty.Visible = false
		for i, res in ipairs(parsed.results) do
			buildOutfitResultCard(TabUI.OutfitSearchScroll, {outfitId=res.id, outfitName=res.name, playerName=res.username, displayName=res.display_name, userId=res.user_id}, i)
		end
	end)
end

local function buildSearchResultCard(parent, userData, idx)
	local card = Instance.new("ImageButton"); card.Name = "SRC_"..userData.userId; card.Size = UDim2.fromOffset(CARD_W_PC, CARD_H_PC)
	card.BackgroundColor3 = C.panelHdr or Color3.fromRGB(22,22,26); card.BackgroundTransparency = 0; card.BorderSizePixel = 0; card.ZIndex = 21; card.LayoutOrder = idx; card.Parent = parent; corner(card, 10)
	local cStroke = Instance.new("UIStroke", card); cStroke.Thickness = 1; cStroke.Color = C.bg3 or Color3.fromRGB(45,45,45); cStroke.Transparency = 0.4
	local thumb = Instance.new("ImageLabel", card); thumb.Size = UDim2.fromOffset(68,68)
	thumb.Position = UDim2.new(0.5,0,0,8); thumb.AnchorPoint = Vector2.new(0.5,0)
	thumb.BackgroundColor3 = Color3.fromRGB(14,14,14); thumb.BackgroundTransparency = 0; thumb.BorderSizePixel = 0
	thumb.Image = avatarThumbUrl(userData.userId); thumb.ScaleType = Enum.ScaleType.Fit; thumb.ZIndex = 22; corner(thumb, 8)
	local thumbRing = Instance.new("UIStroke", thumb); thumbRing.Thickness = 1.5; thumbRing.Color = C.accent; thumbRing.Transparency = 0.6
	local nameLbl = Instance.new("TextLabel", card); nameLbl.Size = UDim2.new(1,-6,0,22); nameLbl.Position = UDim2.fromOffset(3,80)
	nameLbl.BackgroundTransparency = 1; nameLbl.Text = userData.displayName ~= userData.name and userData.displayName or userData.name
	nameLbl.TextSize = 10; nameLbl.TextColor3 = C.TEXT1; nameLbl.TextXAlignment = Enum.TextXAlignment.Center; nameLbl.TextWrapped = true; nameLbl.TextTruncate = Enum.TextTruncate.AtEnd; nameLbl.ZIndex = 22; applyTextStyle(nameLbl)
	if userData.displayName ~= userData.name then
		local unLbl = Instance.new("TextLabel", card); unLbl.Size = UDim2.new(1,-6,0,14); unLbl.Position = UDim2.fromOffset(3,100)
		unLbl.BackgroundTransparency = 1; unLbl.Text = "@"..userData.name; unLbl.TextSize = 8; unLbl.TextColor3 = C.TEXT2; unLbl.TextXAlignment = Enum.TextXAlignment.Center; unLbl.TextTruncate = Enum.TextTruncate.AtEnd; unLbl.ZIndex = 22; applyTextStyle(unLbl)
	end
	local hoverBg = C.accent; local normalBg = C.panelHdr or Color3.fromRGB(22,22,26)
	bind(card.MouseEnter, function() tween(card, TI._008, {BackgroundColor3=hoverBg:lerp(normalBg,0.72)}):Play(); tween(cStroke, TI._008, {Color=hoverBg, Transparency=0}):Play(); tween(thumbRing, TI._008, {Transparency=0.1}):Play() end)
	bind(card.MouseLeave, function() tween(card, TI._012, {BackgroundColor3=normalBg}):Play(); tween(cStroke, TI._012, {Color=C.bg3, Transparency=0.4}):Play(); tween(thumbRing, TI._012, {Transparency=0.6}):Play() end)
	bind(card.MouseButton1Down, function() tween(getPopScale(card), TI._008, {Scale=0.93}):Play() end)
	bind(card.MouseButton1Up, function() tween(getPopScale(card), TI._016, {Scale=1}):Play() end)
	bind(card.MouseButton1Click, function() openOutfitPanel({Name=userData.name, DisplayName=userData.displayName, UserId=userData.userId}) end)
	return card
end

local function executeSearch()
	local raw = SearchBox.Text:match("^%s*(.-)%s*$")
	if raw == "" then return end
	_searchQuery = raw; _searchResults = {}; _searchPage = 1; _searchNextCursor = ""; _searchLoading = true
	for _, ch in ipairs(TabUI.SearchTabScroll:GetChildren()) do if ch:IsA("ImageButton") or ch:IsA("Frame") then ch:Destroy() end end
	TabUI.SearchTabScroll.CanvasSize = UDim2.fromOffset(0,0); TabUI.SearchTabScroll.CanvasPosition = Vector2.new(0,0)
	TabUI.SearchTabEmpty.Visible = false; TabUI.SearchTabLoading.Visible = true
	if _activeTab ~= "search" then switchTab("search") end
	task.spawn(function()
		local results, nextCursor, err = searchPlayers(_searchQuery, "")
		_searchLoading = false
		if _activeTab ~= "search" then return end
		TabUI.SearchTabLoading.Visible = false
		if err then TabUI.SearchTabEmpty.Text = "Fehler: "..tostring(err); TabUI.SearchTabEmpty.Visible = true; return end
		if not results or #results == 0 then TabUI.SearchTabEmpty.Text = 'Keine Ergebnisse fuer "'.._searchQuery..'"'; TabUI.SearchTabEmpty.Visible = true; return end
		_searchResults = results; _searchNextCursor = nextCursor or ""
		for i, userData in ipairs(results) do buildSearchResultCard(TabUI.SearchTabScroll, userData, i) end
	end)
end

local SubUI = (function()
	local SubPanel = Instance.new("Frame"); SubPanel.Name = "SubPanel"
	SubPanel.Size = UDim2.fromOffset(C.SUB_W, C.SUB_H); SubPanel.Position = UDim2.fromScale(0.5, 0.5)
	SubPanel.AnchorPoint = Vector2.new(0.5, 0.5); SubPanel.BackgroundColor3 = C.panelBg
	SubPanel.BorderSizePixel = 0; SubPanel.ZIndex = 20; SubPanel.Visible = false
	SubPanel.Parent = ScreenGui; SubPanel.ClipsDescendants = true; corner(SubPanel, 14)
	stroke(SubPanel, 1.2, C.bg3, 0.2)
	local SubTitleBar = Instance.new("Frame"); SubTitleBar.Size = UDim2.new(1,0,0,50)
	SubTitleBar.BackgroundColor3 = C.panelHdr; SubTitleBar.BorderSizePixel = 0; SubTitleBar.ZIndex = 21; SubTitleBar.Parent = SubPanel; SubTitleBar.ClipsDescendants = true; corner(SubTitleBar, 14)
	local subSep = Instance.new("Frame", SubPanel); subSep.Size = UDim2.new(1,0,0,1); subSep.Position = UDim2.new(0,0,0,50)
	subSep.BackgroundColor3 = C.bg3; subSep.BorderSizePixel = 0; subSep.ZIndex = 21
	local stf = Instance.new("Frame"); stf.Size = UDim2.new(1,0,0,10); stf.Position = UDim2.new(0,0,1,-10)
	stf.BackgroundColor3 = C.TITLEBAR; stf.BorderSizePixel = 0; stf.ZIndex = 21; stf.Parent = SubTitleBar; corner(stf, 14)
	local SubAvatarThumb = Instance.new("ImageLabel"); SubAvatarThumb.Size = UDim2.fromOffset(34,34)
	SubAvatarThumb.Position = UDim2.fromOffset(10,8); SubAvatarThumb.BackgroundColor3 = Color3.fromRGB(18,18,18)
	SubAvatarThumb.BorderSizePixel = 0; SubAvatarThumb.ZIndex = 22; SubAvatarThumb.ScaleType = Enum.ScaleType.Fit
	SubAvatarThumb.Parent = SubTitleBar; styleThumbSurface(SubAvatarThumb, 10)
	local SubTitleName = Instance.new("TextLabel"); SubTitleName.Text = "Outfits"
	SubTitleName.Size = UDim2.new(1,-160,0,22); SubTitleName.Position = UDim2.fromOffset(52,6)
	SubTitleName.BackgroundTransparency = 1; SubTitleName.TextSize = 13; SubTitleName.TextColor3 = C.TEXT1
	SubTitleName.TextXAlignment = Enum.TextXAlignment.Left; SubTitleName.ZIndex = 22; SubTitleName.Parent = SubTitleBar; applyTextStyle(SubTitleName)
	local SubTitleSub = Instance.new("TextLabel"); SubTitleSub.Text = "Wird geladen..."
	SubTitleSub.Size = UDim2.new(1,-160,0,16); SubTitleSub.Position = UDim2.fromOffset(52,28)
	SubTitleSub.BackgroundTransparency = 1; SubTitleSub.TextSize = 10; SubTitleSub.TextColor3 = C.TEXT2
	SubTitleSub.TextXAlignment = Enum.TextXAlignment.Left; SubTitleSub.ZIndex = 22; SubTitleSub.Parent = SubTitleBar; applyTextStyle(SubTitleSub)
	local SubCloseBtn = mkCloseBtn(SubTitleBar, 26, 1, -38, 0.5, 0); SubCloseBtn.ZIndex = 23
	local padding, btnSize = 4, _isMobile and 32 or 26
	local posSubBack = -38 - padding; local posSubRefresh = posSubBack - btnSize - padding
	local SubBackBtn = Instance.new("ImageButton"); SubBackBtn.Size = UDim2.fromOffset(btnSize, btnSize)
	SubBackBtn.Position = UDim2.new(1, posSubBack, 0.5, 0); SubBackBtn.AnchorPoint = Vector2.new(1, 0.5)
	SubBackBtn.BackgroundTransparency = 1; SubBackBtn.ScaleType = Enum.ScaleType.Fit
	SubBackBtn.Image = "rbxassetid://93168176661050"; SubBackBtn.ZIndex = 23; SubBackBtn.Parent = SubTitleBar; corner(SubBackBtn, 6)
	bind(SubBackBtn.MouseButton1Down, function() tween(SubBackBtn, TI._008, {Size=UDim2.fromOffset(btnSize-1,btnSize-1)}):Play() end)
	bind(SubBackBtn.MouseButton1Up, function() tween(SubBackBtn, TI._008, {Size=UDim2.fromOffset(btnSize,btnSize)}):Play() end)
	bind(SubBackBtn.MouseButton1Click, function() currentSubPlayer = nil; closeOutfitPanel() end)
	local SubRefreshBtn = mkIconBtnPlain(SubTitleBar, btnSize, posSubRefresh, "rbxassetid://137689074320233", 22); SubRefreshBtn.Name = "SubRefreshBtn"
	local SubPageContainer = Instance.new("Frame"); SubPageContainer.Size = UDim2.fromOffset(100,26)
	SubPageContainer.Position = UDim2.new(1,-262,0.5,0); SubPageContainer.AnchorPoint = Vector2.new(0,0.5)
	SubPageContainer.BackgroundTransparency = 1; SubPageContainer.ZIndex = 22; SubPageContainer.Parent = SubTitleBar; SubPageContainer.Visible = false
	local function mkPageBtn(txt, pos)
		local btn = Instance.new("TextButton"); btn.Text = txt; btn.Size = UDim2.fromOffset(26,26); btn.Position = pos
		btn.BackgroundColor3 = C.bg3; btn.BorderSizePixel = 0; btn.TextSize = 10; btn.TextColor3 = C.TEXT2; btn.ZIndex = 22; btn.Parent = SubPageContainer; corner(btn, 5)
		bind(btn.MouseButton1Down, function() tween(getPopScale(btn), TI._008, {Scale=0.88}):Play() end)
		bind(btn.MouseButton1Up, function() tween(getPopScale(btn), TI._016, {Scale=1}):Play() end)
		return btn
	end
	local SubPagePrev = mkPageBtn("◀", UDim2.new(0,0,0,0))
	local SubPageNext = mkPageBtn("▶", UDim2.new(1,-26,0,0))
	local SubPageLabel = Instance.new("TextLabel"); SubPageLabel.Text = "1/1"
	SubPageLabel.Size = UDim2.new(1,-52,1,0); SubPageLabel.Position = UDim2.fromOffset(26,0)
	SubPageLabel.BackgroundTransparency = 1; SubPageLabel.TextSize = 10; SubPageLabel.TextColor3 = C.TEXT1; SubPageLabel.ZIndex = 22; SubPageLabel.Parent = SubPageContainer; applyTextStyle(SubPageLabel)
	local SubDivider = Instance.new("Frame"); SubDivider.Size = UDim2.new(1,-28,0,1); SubDivider.Position = UDim2.fromOffset(12,54)
	SubDivider.BackgroundColor3 = C.BORDER; SubDivider.BackgroundTransparency = 0.42; SubDivider.BorderSizePixel = 0; SubDivider.ZIndex = 21; SubDivider.Parent = SubPanel
	local OutfitScroll = Instance.new("ScrollingFrame"); OutfitScroll.Size = UDim2.new(1,-16,1,-62)
	OutfitScroll.Position = UDim2.fromOffset(8,58); OutfitScroll.BackgroundTransparency = 1; OutfitScroll.BorderSizePixel = 0
	OutfitScroll.ScrollBarThickness = 3; OutfitScroll.ScrollBarImageColor3 = C.accent; OutfitScroll.ZIndex = 21
	OutfitScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; OutfitScroll.CanvasSize = UDim2.fromOffset(0,0); OutfitScroll.Parent = SubPanel
	local oGrid = Instance.new("UIGridLayout"); oGrid.CellSize = UDim2.fromOffset(C.SUB_OUT_W, C.OUT_H)
	oGrid.CellPadding = UDim2.fromOffset(8,8); oGrid.SortOrder = Enum.SortOrder.Name; oGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center; oGrid.Parent = OutfitScroll
	local oPad = Instance.new("UIPadding"); oPad.PaddingLeft = UDim.new(0,6); oPad.PaddingTop = UDim.new(0,6); oPad.PaddingRight = UDim.new(0,6); oPad.PaddingBottom = UDim.new(0,8); oPad.Parent = OutfitScroll
	local OutfitLoading = Instance.new("TextLabel"); OutfitLoading.Text = "Lade Outfits..."
	OutfitLoading.Size = UDim2.fromScale(1,1); OutfitLoading.BackgroundTransparency = 1; OutfitLoading.TextSize = 14; OutfitLoading.TextColor3 = C.TEXT1; OutfitLoading.ZIndex = 22; OutfitLoading.Visible = false; OutfitLoading.Parent = OutfitScroll; applyTextStyle(OutfitLoading)
	local OutfitEmpty = Instance.new("TextLabel"); OutfitEmpty.Text = "Keine Outfits gespeichert"
	OutfitEmpty.Size = UDim2.new(1,-40,0,40); OutfitEmpty.Position = UDim2.new(0.5,0,0.5,18); OutfitEmpty.AnchorPoint = Vector2.new(0.5,0.5)
	OutfitEmpty.BackgroundTransparency = 1; OutfitEmpty.TextSize = 14; OutfitEmpty.TextColor3 = C.TEXT1; OutfitEmpty.TextXAlignment = Enum.TextXAlignment.Center; OutfitEmpty.ZIndex = 22; OutfitEmpty.Visible = false; OutfitEmpty.Parent = SubPanel; applyTextStyle(OutfitEmpty)
	local OutfitReloadBtn = Instance.new("ImageButton"); OutfitReloadBtn.Name = "OutfitReloadBtn"
	OutfitReloadBtn.Size = UDim2.fromOffset(34,34); OutfitReloadBtn.Position = UDim2.new(0.5,0,0.5,48); OutfitReloadBtn.AnchorPoint = Vector2.new(0.5,0.5)
	OutfitReloadBtn.BackgroundTransparency = 1; OutfitReloadBtn.BorderSizePixel = 0; OutfitReloadBtn.Image = "rbxassetid://137689074320233"
	OutfitReloadBtn.ZIndex = 22; OutfitReloadBtn.Visible = false; OutfitReloadBtn.Parent = SubPanel; corner(OutfitReloadBtn, 10)
	bind(OutfitReloadBtn.MouseButton1Down, function() tween(getPopScale(OutfitReloadBtn), TI._008, {Scale=0.88}):Play() end)
	bind(OutfitReloadBtn.MouseButton1Up, function() tween(getPopScale(OutfitReloadBtn), TI._016, {Scale=1}):Play() end)
	local OutfitReloadLabel = Instance.new("TextLabel"); OutfitReloadLabel.Text = "Reload Outfits"
	OutfitReloadLabel.Size = UDim2.new(1,-40,0,18); OutfitReloadLabel.Position = UDim2.new(0.5,0,0.5,76); OutfitReloadLabel.AnchorPoint = Vector2.new(0.5,0.5)
	OutfitReloadLabel.BackgroundTransparency = 1; OutfitReloadLabel.TextSize = 12; OutfitReloadLabel.TextColor3 = C.ACCENT; OutfitReloadLabel.TextXAlignment = Enum.TextXAlignment.Center
	OutfitReloadLabel.ZIndex = 22; OutfitReloadLabel.Visible = false; OutfitReloadLabel.Parent = SubPanel; applyTextStyle(OutfitReloadLabel)
	makeDraggable(SubTitleBar, SubPanel)
	return {Panel=SubPanel, TitleName=SubTitleName, TitleSub=SubTitleSub, AvatarThumb=SubAvatarThumb, CloseBtn=SubCloseBtn, BackBtn=SubBackBtn, RefreshBtn=SubRefreshBtn, PageContainer=SubPageContainer, PagePrev=SubPagePrev, PageNext=SubPageNext, PageLabel=SubPageLabel, Scroll=OutfitScroll, Loading=OutfitLoading, Empty=OutfitEmpty, ReloadBtn=OutfitReloadBtn, ReloadLabel=OutfitReloadLabel}
end)()

local openSavedPanel, closeSavedPanel, appendSavedOutfitCard, currentSavedFolderKey, pickingForFolder, SavedFolderBtn, SavedRenameBtn
local SavedPanel, SavedTitleBar, SavedTitleName, SavedTitleSub, SavedCloseBtn, SavedScroll, SavedEmpty, SavedBackBtn, SavedIcon
SavedPanel, SavedTitleBar, SavedTitleName, SavedTitleSub, SavedCloseBtn, SavedScroll, SavedEmpty, SavedBackBtn, SavedFolderBtn, SavedRenameBtn, SavedIcon = (function()
	local SavedPanel = Instance.new("Frame"); SavedPanel.Name = "SavedPanel"
	SavedPanel.Size = UDim2.fromOffset(C.SUB_W, C.SUB_H); SavedPanel.Position = UDim2.fromScale(0.5, 0.5)
	SavedPanel.AnchorPoint = Vector2.new(0.5, 0.5); SavedPanel.BackgroundColor3 = C.panelBg
	SavedPanel.BorderSizePixel = 0; SavedPanel.ZIndex = 25; SavedPanel.Visible = false
	SavedPanel.Parent = ScreenGui; SavedPanel.ClipsDescendants = true; corner(SavedPanel, 14)
	stroke(SavedPanel, 1.2, C.bg3, 0.2)
	local SavedTitleBar = Instance.new("Frame"); SavedTitleBar.Size = UDim2.new(1,0,0,50)
	SavedTitleBar.BackgroundColor3 = C.panelHdr; SavedTitleBar.BorderSizePixel = 0; SavedTitleBar.ZIndex = 26; SavedTitleBar.Parent = SavedPanel; SavedTitleBar.ClipsDescendants = true; corner(SavedTitleBar, 14)
	local savSep = Instance.new("Frame", SavedPanel); savSep.Size = UDim2.new(1,0,0,1); savSep.Position = UDim2.new(0,0,0,50)
	savSep.BackgroundColor3 = C.bg3; savSep.BorderSizePixel = 0; savSep.ZIndex = 26
	local stf2 = Instance.new("Frame"); stf2.Size = UDim2.new(1,0,0,10); stf2.Position = UDim2.new(0,0,1,-10)
	stf2.BackgroundColor3 = C.TITLEBAR; stf2.BorderSizePixel = 0; stf2.ZIndex = 26; stf2.Parent = SavedTitleBar; corner(stf2, 14)
	local SavedIcon = Instance.new("TextLabel"); SavedIcon.Text = "★"; SavedIcon.Size = UDim2.fromOffset(24,24)
	SavedIcon.Position = UDim2.fromOffset(14,13); SavedIcon.BackgroundTransparency = 1; SavedIcon.TextSize = 16
	SavedIcon.TextColor3 = Color3.fromRGB(255,255,255); SavedIcon.ZIndex = 27; SavedIcon.Parent = SavedTitleBar; applyTextStyle(SavedIcon)
	local SavedCloseBtn = mkCloseBtn(SavedTitleBar, 26, 1, -38, 0.5, 0); SavedCloseBtn.ZIndex = 28
	local padding, btnSize = 4, _isMobile and 32 or 26
	local posBack = -38 - padding; local posFolder = posBack - btnSize - padding; local posRename = posFolder - btnSize - padding
	local SavedBackBtn = Instance.new("ImageButton"); SavedBackBtn.Size = UDim2.fromOffset(btnSize, btnSize)
	SavedBackBtn.Position = UDim2.new(1, posBack, 0.5, 0); SavedBackBtn.AnchorPoint = Vector2.new(1, 0.5)
	SavedBackBtn.BackgroundTransparency = 1; SavedBackBtn.ScaleType = Enum.ScaleType.Fit
	SavedBackBtn.Image = "rbxassetid://93168176661050"; SavedBackBtn.ImageColor3 = Color3.fromRGB(255,255,255)
	SavedBackBtn.ZIndex = 28; SavedBackBtn.Visible = true; SavedBackBtn.Parent = SavedTitleBar; corner(SavedBackBtn, 6)
	bind(SavedBackBtn.MouseButton1Click, function()
		if pickingForFolder then pickingForFolder=nil; openSavedPanel()
		elseif currentSavedFolderKey then currentSavedFolderKey=nil; openSavedPanel()
		else closeSavedPanel() end
	end)
	local SavedTitleName = Instance.new("TextLabel"); SavedTitleName.Text = T.saved_outfits_title
	SavedTitleName.Size = UDim2.new(1,-150,0,22); SavedTitleName.Position = UDim2.fromOffset(42,5)
	SavedTitleName.BackgroundTransparency = 1; SavedTitleName.TextSize = 13; SavedTitleName.TextColor3 = C.TEXT1
	SavedTitleName.TextXAlignment = Enum.TextXAlignment.Left; SavedTitleName.ZIndex = 27; SavedTitleName.Parent = SavedTitleBar; applyTextStyle(SavedTitleName)
	local SavedTitleSub = Instance.new("TextLabel"); SavedTitleSub.Text = T.saved_outfits_sub
	SavedTitleSub.Size = UDim2.new(1,-150,0,16); SavedTitleSub.Position = UDim2.fromOffset(42,25)
	SavedTitleSub.BackgroundTransparency = 1; SavedTitleSub.TextSize = 10; SavedTitleSub.TextColor3 = C.TEXT2
	SavedTitleSub.TextXAlignment = Enum.TextXAlignment.Left; SavedTitleSub.ZIndex = 27; SavedTitleSub.Parent = SavedTitleBar; applyTextStyle(SavedTitleSub)
	local SavedFolderBtn = Instance.new("ImageButton"); SavedFolderBtn.Size = UDim2.fromOffset(btnSize, btnSize)
	SavedFolderBtn.Position = UDim2.new(1, posFolder, 0.5, 0); SavedFolderBtn.AnchorPoint = Vector2.new(1, 0.5)
	SavedFolderBtn.BackgroundTransparency = 1; SavedFolderBtn.ScaleType = Enum.ScaleType.Fit
	SavedFolderBtn.Image = "rbxassetid://135828379467778"; SavedFolderBtn.ZIndex = 28; SavedFolderBtn.Parent = SavedTitleBar
	bind(SavedFolderBtn.MouseButton1Click, function()
		local fid = "FOLDER_"..tostring(math.floor(tick()))
		if not SavedOutfitsState.loaded then loadSavedOutfitsFromCache(true) end
		SavedOutfitsState.outfits["_"..fid] = {outfitId=fid, outfitName=T.new_folder, isFolder=true, contents={}, userId=""}
		persistSavedOutfits(); openSavedPanel()
	end)
	local SavedRenameBtn = Instance.new("ImageButton"); SavedRenameBtn.Size = UDim2.fromOffset(btnSize, btnSize)
	SavedRenameBtn.Position = UDim2.new(1, posRename, 0.5, 0); SavedRenameBtn.AnchorPoint = Vector2.new(1, 0.5)
	SavedRenameBtn.BackgroundTransparency = 1; SavedRenameBtn.ScaleType = Enum.ScaleType.Fit
	SavedRenameBtn.Image = "rbxassetid://74424838226861"; SavedRenameBtn.ZIndex = 50; SavedRenameBtn.Visible = false; SavedRenameBtn.Parent = SavedTitleBar; corner(SavedRenameBtn, 6)
	bind(SavedRenameBtn.MouseButton1Click, function()
		if not currentSavedFolderKey then return end
		local fKey = "_"..currentSavedFolderKey; local fData = SavedOutfitsState.outfits[fKey] or SavedOutfitsState.outfits[currentSavedFolderKey]
		if not fData then return end
		SavedTitleName.Visible = false; SavedTitleSub.Visible = false
		local eb = Instance.new("TextBox"); eb.Size = UDim2.new(1,-120,0,28); eb.Position = UDim2.new(0,42,0,25)
		eb.AnchorPoint = Vector2.new(0,0.5); eb.Text = fData.outfitName; eb.BackgroundColor3 = Color3.fromRGB(25,25,30)
		eb.TextColor3 = Color3.new(1,1,1); eb.BorderSizePixel = 0; eb.ZIndex = 60; eb.Parent = SavedPanel
		corner(eb, 6); applyTextStyle(eb); eb:CaptureFocus()
		bind(eb.FocusLost, function()
			if eb.Text ~= "" and eb.Text ~= fData.outfitName then fData.outfitName = eb.Text; persistSavedOutfits(); openSavedPanel() end
			eb:Destroy(); SavedTitleName.Visible = true; SavedTitleSub.Visible = true
		end)
	end)
	local SavedDivider = Instance.new("Frame"); SavedDivider.Size = UDim2.new(1,-28,0,1); SavedDivider.Position = UDim2.fromOffset(12,54)
	SavedDivider.BackgroundColor3 = C.BORDER; SavedDivider.BackgroundTransparency = 0.42; SavedDivider.BorderSizePixel = 0; SavedDivider.ZIndex = 26; SavedDivider.Parent = SavedPanel
	local SavedScroll = Instance.new("ScrollingFrame"); SavedScroll.Size = UDim2.new(1,-16,1,-62)
	SavedScroll.Position = UDim2.fromOffset(8,58); SavedScroll.BackgroundTransparency = 1; SavedScroll.BorderSizePixel = 0
	SavedScroll.ScrollBarThickness = 3; SavedScroll.ScrollBarImageColor3 = C.accent; SavedScroll.ZIndex = 26
	SavedScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; SavedScroll.CanvasSize = UDim2.fromOffset(0,0); SavedScroll.Parent = SavedPanel
	local svGrid = Instance.new("UIGridLayout"); svGrid.CellSize = UDim2.fromOffset(C.OUT_W, C.OUT_H)
	svGrid.CellPadding = UDim2.fromOffset(8,8); svGrid.SortOrder = Enum.SortOrder.LayoutOrder; svGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center; svGrid.Parent = SavedScroll
	local svPad = Instance.new("UIPadding"); svPad.PaddingLeft = UDim.new(0,0); svPad.PaddingTop = UDim.new(0,6); svPad.PaddingRight = UDim.new(0,0); svPad.PaddingBottom = UDim.new(0,8); svPad.Parent = SavedScroll
	local SavedEmpty = Instance.new("TextLabel"); SavedEmpty.Text = "Keine gespeicherten Outfits"
	SavedEmpty.Size = UDim2.new(1,-40,0,40); SavedEmpty.Position = UDim2.new(0.5,0,0.5,18); SavedEmpty.AnchorPoint = Vector2.new(0.5,0.5)
	SavedEmpty.BackgroundTransparency = 1; SavedEmpty.TextSize = 14; SavedEmpty.TextColor3 = C.TEXT1; SavedEmpty.TextXAlignment = Enum.TextXAlignment.Center; SavedEmpty.ZIndex = 27
	SavedEmpty.Visible = false; SavedEmpty.Parent = SavedPanel; applyTextStyle(SavedEmpty)
	makeDraggable(SavedTitleBar, SavedPanel)
	return SavedPanel, SavedTitleBar, SavedTitleName, SavedTitleSub, SavedCloseBtn, SavedScroll, SavedEmpty, SavedBackBtn, SavedFolderBtn, SavedRenameBtn, SavedIcon
end)()

local activeShimmerTweens = {}
local function clearShimmerConns() for _, tw in ipairs(activeShimmerTweens) do pcall(function() tw:Cancel() end) end; activeShimmerTweens = {} end
local function clearParentFrames(parent) for _, ch in ipairs(parent:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end end

local function createSkeletonCard(parent, w, h)
	local card = Instance.new("Frame"); card.Name = "SkeletonCard"; card.Size = UDim2.fromOffset(w, h)
	card.BackgroundColor3 = C.CARD; card.BorderSizePixel = 0; card.ZIndex = 22; card.Parent = parent; corner(card, 10)
	local imgPh = Instance.new("Frame"); imgPh.Size = UDim2.new(1,-12,0,h-42); imgPh.Position = UDim2.fromOffset(6,6)
	imgPh.BackgroundColor3 = Color3.fromRGB(28,28,28); imgPh.BorderSizePixel = 0; imgPh.ZIndex = 23; imgPh.Parent = card; styleThumbSurface(imgPh, 8)
	local namePh = Instance.new("Frame"); namePh.Size = UDim2.new(0.7,0,0,7); namePh.Position = UDim2.fromOffset(6,h-32)
	namePh.BackgroundColor3 = Color3.fromRGB(38,38,42); namePh.BorderSizePixel = 0; namePh.ZIndex = 23; namePh.Parent = card; corner(namePh, 4)
	return card
end
local function showSkeletons(parent, count, w, h) for _ = 1, count do createSkeletonCard(parent, w, h) end end
local function estimateVisibleCardCount(sf, cellW, cellH, gap, extraRows)
	local aw, ah = math.max(1, sf.AbsoluteSize.X), math.max(1, sf.AbsoluteSize.Y)
	return math.max(1, math.floor((aw+gap)/(cellW+gap))) * math.max(1, math.ceil((ah+gap)/(cellH+gap)) + (extraRows or 1))
end

local activeThumbRenderToken, preloadedThumbUrls = 0, {}
local function nextThumbRenderToken() activeThumbRenderToken += 1; return activeThumbRenderToken end
local function invalidateThumbRenderToken() activeThumbRenderToken += 1 end

local function preloadOutfitThumbs(outfits, limit)
	local preloaders = {}
	for i = 1, math.min(#outfits, limit or C.THUMB_PRI) do
		local o = outfits[i]
		if o and o.id then local url=outfitThumbUrl(o.id)
			if url ~= "" and not preloadedThumbUrls[url] then preloadedThumbUrls[url]=true; local pl=Instance.new("ImageLabel"); pl.Image=url; table.insert(preloaders, pl) end
		end
	end
	if #preloaders == 0 then return end
	task.spawn(function() pcall(ContentProvider.PreloadAsync, ContentProvider, preloaders); for _, pl in ipairs(preloaders) do pl:Destroy() end end)
end

local function attachOutfitThumbnail(thumb, outfitId, renderToken, delay)
	thumb.ImageTransparency = 1
	if delay and delay > 0 then task.wait(delay) end
	if renderToken and activeThumbRenderToken ~= renderToken then return end
	local url = outfitThumbUrl(outfitId); if url == "" then return end
	thumb.Image = url; thumb.Visible = true; thumb.ImageTransparency = 0
end

local function refreshSavedPanelHeader()
	local n = countSavedOutfits()
	if n <= 0 then SavedEmpty.Text = "Keine gespeicherten Outfits"; SavedEmpty.Visible = true; SavedTitleSub.Text = "0 Outfits"
	else SavedEmpty.Visible = false; SavedTitleSub.Text = tostring(n).." Outfit(s)" end
end

currentSubPlayer = nil

local function resortSavedOutfitCards()
	local cards = {}
	for _, ch in ipairs(SavedScroll:GetChildren()) do if ch:IsA("Frame") and ch:GetAttribute("SavedKey") then table.insert(cards, ch) end end
	table.sort(cards, function(a, b)
		local function pri(x) local p=0; if x:GetAttribute("IsBackAction") then p=p+3 end; if x:GetAttribute("IsAddAction") then p=p+2 end; if x:GetAttribute("IsFolder") then p=p+1 end; return p end
		local pa, pb = pri(a), pri(b); if pa ~= pb then return pa > pb end
		local aAt, bAt = a:GetAttribute("SavedAt") or 0, b:GetAttribute("SavedAt") or 0
		if aAt ~= bAt then return aAt > bAt end
		return tostring(a:GetAttribute("SortName") or "") < tostring(b:GetAttribute("SortName") or "")
	end)
	for i, card in ipairs(cards) do card.LayoutOrder = i; card.Name = string.format("%04d_%s", i, tostring(card:GetAttribute("SortName") or "Saved")) end
end

local function findSavedCardByKey(key)
	for _, ch in ipairs(SavedScroll:GetChildren()) do if ch:IsA("Frame") and ch:GetAttribute("SavedKey") == key then return ch end end
	return nil
end

local function createOutfitCard(parent, idx, outfitName, outfitId, isSavedPanel, savedOutfitData, renderToken, thumbLoadDelay)
	local cardW = isSavedPanel and C.OUT_W or C.SUB_OUT_W
	local card = Instance.new("Frame"); card.Name = string.format("%04d_%s", idx, outfitName)
	card.Size = UDim2.fromOffset(cardW, C.OUT_H); card.LayoutOrder = idx; card.BackgroundColor3 = C.CARD
	card.BorderSizePixel = 0; card.ZIndex = 22; card.Parent = parent; corner(card, 10)
	local c_Stroke = _dummyStroke(card); c_Stroke.Color = C.bg3
	if isSavedPanel and savedOutfitData then
		local skey = tostring(savedOutfitData.userId).."_"..tostring(savedOutfitData.outfitId)
		if savedOutfitData.isFolder then skey = "_"..tostring(savedOutfitData.outfitId) end
		if savedOutfitData.isBackAction then skey = "___BACK" end
		if savedOutfitData.isAddAction then skey = "__ADD" end
		card:SetAttribute("SavedKey", skey); card:SetAttribute("SortName", tostring(outfitName or "Unnamed"))
		card:SetAttribute("IsFolder", savedOutfitData.isFolder == true); card:SetAttribute("IsAddAction", savedOutfitData.isAddAction == true)
		card:SetAttribute("IsBackAction", savedOutfitData.isBackAction == true); card:SetAttribute("SavedAt", savedOutfitData.savedAt or 0)
	end
	local thumb = Instance.new("ImageLabel"); thumb.Size = UDim2.new(1,-12,0,C.OUT_H-28); thumb.Position = UDim2.fromOffset(6,6)
	thumb.BackgroundColor3 = Color3.fromRGB(12,12,12); thumb.BorderSizePixel = 0; thumb.ZIndex = 23
	thumb.ScaleType = Enum.ScaleType.Fit; thumb.Parent = card; styleThumbSurface(thumb, 8)
	if savedOutfitData and savedOutfitData.isBackAction then thumb.Image = "rbxassetid://100634669779590"; thumb.ImageTransparency = 0
	elseif savedOutfitData and savedOutfitData.isAddAction then thumb.Image = "rbxassetid://120703890568713"; thumb.ImageTransparency = 0
	elseif savedOutfitData and savedOutfitData.isFolder then thumb.Image = "rbxassetid://123514430148126"; thumb.ImageTransparency = 0
	else task.spawn(function() attachOutfitThumbnail(thumb, outfitId, renderToken or activeThumbRenderToken, thumbLoadDelay) end) end
	local nameL = Instance.new("TextLabel"); nameL.Text = outfitName; nameL.Size = UDim2.new(1,-32,0,15)
	nameL.Position = UDim2.fromOffset(4, C.OUT_H-22); nameL.BackgroundTransparency = 1; nameL.TextSize = 11
	nameL.TextColor3 = C.TEXT1; nameL.TextTruncate = Enum.TextTruncate.AtEnd; nameL.TextXAlignment = Enum.TextXAlignment.Left; nameL.ZIndex = 23; nameL.Parent = card; applyTextStyle(nameL, 11)
	local hbtn = Instance.new("TextButton"); hbtn.Text = ""
	hbtn.Size = isSavedPanel and UDim2.new(1,-30,1,-30) or UDim2.fromScale(1,1); hbtn.BackgroundTransparency = 1; hbtn.ZIndex = 24; hbtn.Parent = card
	if not isSavedPanel then
		local player = currentSubPlayer
		local saveBtn = Instance.new("ImageButton"); saveBtn.Name = "SaveBtn"; saveBtn.Size = UDim2.fromOffset(22,22)
		saveBtn.Position = UDim2.new(1,-28,1,-38); saveBtn.Image = "rbxassetid://120703890568713"
		saveBtn.ImageColor3 = Color3.fromRGB(255,255,255); saveBtn.BackgroundTransparency = 1; saveBtn.BorderSizePixel = 0; saveBtn.ZIndex = 26; saveBtn.Parent = card; corner(saveBtn, 5)
		bind(saveBtn.MouseButton1Down, function() tween(getPopScale(saveBtn), TI._008, {Scale=0.85}):Play() end)
		bind(saveBtn.MouseButton1Up, function() tween(getPopScale(saveBtn), TI._016, {Scale=1}):Play() end)
		bind(saveBtn.MouseButton1Click, function()
			local p = currentSubPlayer or player; local entry
			if p then saveOutfitToCache(outfitId, outfitName or "Unnamed", p.Name, p.DisplayName, p.UserId); entry = {outfitId=outfitId, outfitName=outfitName or "Unnamed", playerName=p.Name, displayName=p.DisplayName, userId=p.UserId}
			else saveOutfitToCache(outfitId, outfitName or "Unnamed", LocalPlayer.Name, LocalPlayer.DisplayName, LocalPlayer.UserId); entry = {outfitId=outfitId, outfitName=outfitName or "Unnamed", playerName=LocalPlayer.Name, displayName=LocalPlayer.DisplayName, userId=LocalPlayer.UserId} end
			if SavedPanel.Visible and entry then local ok2, fn = pcall(function() return appendSavedOutfitCard end); if ok2 and fn then fn(entry) end end
			tween(saveBtn, getTI(0.15), {BackgroundColor3=Color3.fromRGB(28,46,28)}):Play()
			task.delay(0.6, function() tween(saveBtn, TI._020, {BackgroundColor3=Color3.fromRGB(18,18,18)}):Play() end)
		end)
	elseif savedOutfitData and not savedOutfitData.isAddAction and not savedOutfitData.isBackAction then
		local removeBtn = Instance.new("ImageButton"); removeBtn.Name = "RemoveBtn"; removeBtn.Size = UDim2.fromOffset(22,22)
		removeBtn.Position = UDim2.new(1,-28,1,-38); removeBtn.Image = "rbxassetid://85088330963329"
		removeBtn.ImageColor3 = Color3.fromRGB(255,255,255); removeBtn.BackgroundTransparency = 1; removeBtn.BorderSizePixel = 0; removeBtn.ZIndex = 26; removeBtn.Parent = card; corner(removeBtn, 8)
		bind(removeBtn.MouseButton1Down, function() tween(getPopScale(removeBtn), TI._008, {Scale=0.85}):Play() end)
		bind(removeBtn.MouseButton1Up, function() tween(getPopScale(removeBtn), TI._016, {Scale=1}):Play() end)
		bind(removeBtn.MouseButton1Click, function()
			removeBtn.Active = false; hbtn.Active = false
			tween(card, getTI(0.16, Enum.EasingStyle.Quad), {BackgroundTransparency=0.35}):Play()
			tween(thumb, TI._016, {ImageTransparency=1, BackgroundTransparency=1}):Play()
			tween(nameL, TI._014, {TextTransparency=1}):Play()
			task.delay(0.17, function()
				if currentSavedFolderKey ~= nil and savedOutfitData and not savedOutfitData.isFolder then savedOutfitData.parentFolder = nil; persistSavedOutfits()
				else removeOutfitFromCache(savedOutfitData.outfitId, savedOutfitData.userId) end
				if card and card.Parent then card:Destroy() end; refreshSavedPanelHeader()
			end)
		end)
	end
	bind(hbtn.MouseEnter, function() tween(card, TI._008, {BackgroundColor3=C.CARD_HOVER}):Play(); tween(thumb, TI._008, {Position=UDim2.fromOffset(6,4)}):Play() end)
	bind(hbtn.MouseLeave, function() tween(card, TI._008, {BackgroundColor3=C.CARD}):Play(); tween(thumb, TI._008, {Position=UDim2.fromOffset(6,6)}):Play() end)
	bind(hbtn.MouseButton1Down, function() tween(getPopScale(card), TI._008, {Scale=0.93}):Play() end)
	bind(hbtn.MouseButton1Up, function() tween(getPopScale(card), TI._018_BACK, {Scale=1}):Play() end)
	if savedOutfitData and savedOutfitData.isBackAction then
		bind(hbtn.MouseButton1Click, function() currentSavedFolderKey=nil; openSavedPanel() end)
	elseif savedOutfitData and savedOutfitData.isAddAction then
		bind(hbtn.MouseButton1Click, function() pickingForFolder=currentSavedFolderKey; openSavedPanel() end)
	elseif savedOutfitData and savedOutfitData.isFolder then
		bind(hbtn.MouseButton1Click, function() if pickingForFolder then return end; currentSavedFolderKey = outfitId; openSavedPanel() end)
	else
		bind(hbtn.MouseButton1Click, function()
			if pickingForFolder then savedOutfitData.parentFolder=pickingForFolder; pickingForFolder=nil; persistSavedOutfits(); openSavedPanel()
			else applyOutfit(outfitId) end
		end)
	end
	return card
end

function appendSavedOutfitCard(savedOutfitData)
	if not SavedPanel.Visible or not savedOutfitData then return end
	if (currentSavedFolderKey ~= nil) or (pickingForFolder ~= nil) then refreshSavedPanelHeader(); return end
	local cacheKey = tostring(savedOutfitData.userId).."_"..tostring(savedOutfitData.outfitId)
	if findSavedCardByKey(cacheKey) then refreshSavedPanelHeader(); resortSavedOutfitCards(); return end
	local rt = nextThumbRenderToken(); local nId = tonumber(savedOutfitData.outfitId)
	local card = createOutfitCard(SavedScroll, 9999, savedOutfitData.outfitName or "Unnamed", nId or savedOutfitData.outfitId, true, savedOutfitData, rt, 0)
	card.BackgroundTransparency = 1; card.Size = UDim2.fromOffset(C.OUT_W-8, C.OUT_H-8)
	resortSavedOutfitCards(); refreshSavedPanelHeader()
	tween(card, TI._016, {BackgroundTransparency=0, Size=UDim2.fromOffset(C.OUT_W, C.OUT_H)}):Play()
end

local function renderOutfitCards(parent, outfits, isSavedPanel, renderToken)
	local batchSize = math.max(1, C.THUMB_BATCH)
	for i, outfit in ipairs(outfits) do
		if not parent or not parent.Parent then return end
		local thumbDelay = 0
		if i > C.THUMB_PRI then thumbDelay = math.floor((i-C.THUMB_PRI-1)/batchSize+1)*C.THUMB_DELAY end
		createOutfitCard(parent, i, outfit.name or "Unnamed", outfit.id, isSavedPanel, outfit.savedOutfitData, renderToken, thumbDelay)
		if i % batchSize == 0 then task.wait() end
	end
end

function closeOutfitPanel()
	clearShimmerConns(); invalidateThumbRenderToken()
	SubUI.Loading.Visible = false; SubUI.Empty.Visible = false; SubUI.ReloadBtn.Visible = false; SubUI.ReloadLabel.Visible = false
	clearParentFrames(SubUI.Scroll); SubUI.Scroll.CanvasSize = UDim2.fromOffset(0,0); SubUI.Scroll.CanvasPosition = Vector2.new(0,0)
	tweenClose(SubUI.Panel, C.SUB_W, C.SUB_H, function()
		if Panel and not _skipPanelReopen then
			Panel.Position = SubUI.Panel.Position
			local hasCards = PlayerCardsScroll.Visible or _activeTab == "search" or _activeTab == "outfitsearch"
			tweenOpen(Panel, C.PANEL_W, hasCards and PANEL_H_CARDS or PANEL_H_BASE)
		end
	end)
end

closeSavedPanel = function()
	invalidateThumbRenderToken(); clearShimmerConns(); clearParentFrames(SavedScroll)
	SavedScroll.CanvasSize = UDim2.fromOffset(0,0); SavedScroll.CanvasPosition = Vector2.new(0,0)
	tweenClose(SavedPanel, C.SUB_W, C.SUB_H, function()
		if Panel and not _skipPanelReopen then
			Panel.Position = SavedPanel.Position
			local hasCards = PlayerCardsScroll.Visible or _activeTab == "search" or _activeTab == "outfitsearch"
			tweenOpen(Panel, C.PANEL_W, hasCards and PANEL_H_CARDS or PANEL_H_BASE)
		end
	end)
end

function openSavedPanel()
	if Panel and not SavedPanel.Visible then
		SavedPanel.Position = Panel.Position
		local _mp = Panel; local _mps = getPopScale(_mp)
		tween(_mps, TI._007_IN, {Scale=0.93}):Play()
		task.delay(0.07, function() _mp.Visible = false; _mps.Scale = 1 end)
	end
	if SavedRenameBtn then SavedRenameBtn.Visible = (currentSavedFolderKey ~= nil) end
	if SavedFolderBtn then SavedFolderBtn.Visible = (currentSavedFolderKey == nil) end
	SavedTitleName.Text = (currentSavedFolderKey ~= nil) and currentSavedFolderKey or T.saved_outfits_title
	SavedTitleSub.Text = (currentSavedFolderKey ~= nil) and "Ordneransicht" or "0 Outfits"
	SavedBackBtn.Visible = true; SavedIcon.Visible = true
	invalidateThumbRenderToken(); clearShimmerConns(); clearParentFrames(SavedScroll)
	SavedScroll.CanvasSize = UDim2.fromOffset(0,0); SavedScroll.CanvasPosition = Vector2.zero; SavedEmpty.Visible = false
	task.delay(0.05, function() tweenOpen(SavedPanel, C.SUB_W, C.SUB_H) end)
	loadSavedOutfitsFromCache(false)
	local savedList = {}
	if currentSavedFolderKey ~= nil and pickingForFolder == nil then
		table.insert(savedList, {name="Zurück", id="BACK", savedOutfitData={isBackAction=true}})
		table.insert(savedList, {name="Hinzufügen", id="ADD", savedOutfitData={isAddAction=true}})
	end
	for _, so in pairs(SavedOutfitsState.outfits) do
		local show = false
		if pickingForFolder then show = not so.isFolder and not so.parentFolder
		elseif currentSavedFolderKey == nil then show = so.isFolder or not so.parentFolder
		else show = so.parentFolder == currentSavedFolderKey end
		if show then table.insert(savedList, {name=so.outfitName or "Unnamed", id=tonumber(so.outfitId) or so.outfitId, savedOutfitData=so}) end
	end
	table.sort(savedList, function(a, b)
		local aD, bD = a.savedOutfitData, b.savedOutfitData
		local function pri(x) return x.isBackAction and 3 or (x.isAddAction and 2 or (x.isFolder and 1 or 0)) end
		local pa, pb = pri(aD), pri(bD); if pa ~= pb then return pa > pb end
		local aAt, bAt = aD.savedAt or 0, bD.savedAt or 0; if aAt ~= bAt then return aAt > bAt end
		return tostring(a.name) < tostring(b.name)
	end)
	if #savedList > 0 or currentSavedFolderKey ~= nil then
		local rt = nextThumbRenderToken(); preloadOutfitThumbs(savedList, C.THUMB_PRI)
		renderOutfitCards(SavedScroll, savedList, true, rt); resortSavedOutfitCards()
		if currentSavedFolderKey == nil then SavedTitleSub.Text = tostring(countSavedOutfits()).." Outfit(s)" end
	end
	if SavedFolderBtn then SavedFolderBtn.Visible = (currentSavedFolderKey == nil and pickingForFolder == nil) end
	if SavedRenameBtn then SavedRenameBtn.Visible = (currentSavedFolderKey ~= nil and pickingForFolder == nil) end
	if pickingForFolder then SavedTitleName.Text = "Outfit auswählen..."; SavedIcon.Visible = false; SavedBackBtn.Visible = true
	elseif currentSavedFolderKey then
		local fData = SavedOutfitsState.outfits["_"..currentSavedFolderKey] or SavedOutfitsState.outfits[currentSavedFolderKey]
		SavedTitleName.Text = T.folder_prefix..(fData and fData.outfitName or T.unknown); SavedIcon.Visible = false; SavedBackBtn.Visible = true
	else SavedTitleName.Text = "Saved Outfits"; SavedIcon.Visible = true; SavedBackBtn.Visible = true end
end

local currentOutfitPage, totalOutfitPages, currentOutfitsList = 1, 1, {}

local function renderOutfitPage(pageIndex, renderToken)
	if activeThumbRenderToken ~= renderToken then return end
	clearShimmerConns(); clearParentFrames(SubUI.Scroll)
	SubUI.Scroll.CanvasSize = UDim2.fromOffset(0,0); SubUI.Scroll.CanvasPosition = Vector2.zero
	local si = (pageIndex-1)*100+1; local ei = math.min(si+99, #currentOutfitsList)
	local pageOutfits = {} for i = si, ei do table.insert(pageOutfits, currentOutfitsList[i]) end
	renderOutfitCards(SubUI.Scroll, pageOutfits, false, renderToken)
	SubUI.PageLabel.Text = tostring(pageIndex).." / "..tostring(totalOutfitPages)
end

bind(SubUI.PagePrev.MouseButton1Click, function() if currentOutfitPage > 1 then currentOutfitPage -= 1; renderOutfitPage(currentOutfitPage, activeThumbRenderToken) end end)
bind(SubUI.PageNext.MouseButton1Click, function() if currentOutfitPage < totalOutfitPages then currentOutfitPage += 1; renderOutfitPage(currentOutfitPage, activeThumbRenderToken) end end)

openOutfitPanel = function(player)
	local _isLookupFlag = false; pcall(function() _isLookupFlag = player._isLookup == true end)
	if _isLookupFlag or (player.UserId and player.UserId < 0) then return end
	if Panel and not SubUI.Panel.Visible then
		SubUI.Panel.Position = Panel.Position
		local _mp = Panel; local _mps = getPopScale(_mp)
		tween(_mps, TI._007_IN, {Scale=0.93}):Play()
		task.delay(0.07, function() _mp.Visible = false; _mps.Scale = 1 end)
	end
	local renderToken = nextThumbRenderToken(); currentSubPlayer = player
	clearShimmerConns(); clearParentFrames(SubUI.Scroll)
	SubUI.Scroll.CanvasSize = UDim2.fromOffset(0,0); SubUI.Scroll.CanvasPosition = Vector2.zero
	SubUI.Loading.Visible = true; SubUI.Empty.Visible = false
	SubUI.Empty.Text = T.no_outfits_saved; SubUI.ReloadBtn.Visible = false; SubUI.ReloadLabel.Visible = false
	SubUI.AvatarThumb.Image = avatarThumbUrl(player.UserId); SubUI.TitleName.Text = (player.DisplayName.."'S OUTFITS"):upper()
	SubUI.TitleSub.Text = "Wird geladen..."
	task.delay(0.05, function() tweenOpen(SubUI.Panel, C.SUB_W, C.SUB_H) end)
	local cachedEntry = cacheGet(player.UserId)
	local visCount = estimateVisibleCardCount(SubUI.Scroll, C.SUB_OUT_W, C.OUT_H, 8, 1)
	local skCount = (cachedEntry and #cachedEntry > 0) and math.min(#cachedEntry, math.max(visCount, 6)) or math.max(visCount, 6)
	showSkeletons(SubUI.Scroll, skCount, C.SUB_OUT_W, C.OUT_H)
	task.spawn(function()
		local outfits = {}
		if player == LocalPlayer then
			local ok, pages = pcall(AvatarEditorService.GetOutfits, AvatarEditorService, Enum.OutfitSource.SavedOutfits)
			if ok and pages then
				local ok2, items = pcall(function() return pages:GetCurrentPage() end)
				if ok2 then for _, it in ipairs(items) do table.insert(outfits, {name=it.Name, id=it.Id}) end end
				while not pages.IsFinished do
					if not pcall(function() pages:AdvanceToNextPageAsync() end) then break end; task.wait()
					local ok3, more = pcall(function() return pages:GetCurrentPage() end)
					if ok3 then for _, it in ipairs(more) do table.insert(outfits, {name=it.Name, id=it.Id}) end end
				end
			end
			if #outfits == 0 then local h = fetchOutfitsViaHttp(player.UserId); if h then outfits = h end end
		else
			local h, err = fetchOutfitsViaHttp(player.UserId)
			if h then outfits = h
			else
				if activeThumbRenderToken ~= renderToken or currentSubPlayer ~= player then return end
				clearShimmerConns(); clearParentFrames(SubUI.Scroll); SubUI.Scroll.CanvasSize = UDim2.fromOffset(0,0)
				SubUI.Loading.Visible = false; SubUI.Empty.TextTransparency = 0
				SubUI.Empty.Text = "Fehler: "..(err or "Unbekannt"); SubUI.Empty.Visible = true; SubUI.TitleSub.Text = "Fehler"; return
			end
		end
		if activeThumbRenderToken ~= renderToken or currentSubPlayer ~= player then return end
		clearShimmerConns(); clearParentFrames(SubUI.Scroll); SubUI.Scroll.CanvasSize = UDim2.fromOffset(0,0); SubUI.Scroll.CanvasPosition = Vector2.zero
		SubUI.Loading.Visible = false; SubUI.Empty.Visible = false; SubUI.ReloadBtn.Visible = false; SubUI.ReloadLabel.Visible = false
		if #outfits == 0 then
			SubUI.Empty.TextTransparency = 0; SubUI.Empty.Text = "Keine Outfits gespeichert"; SubUI.Empty.Visible = true
			SubUI.ReloadBtn.Visible = true; SubUI.ReloadLabel.Visible = true; SubUI.TitleSub.Text = "0 Outfits"; return
		end
		preloadOutfitThumbs(outfits, C.THUMB_PRI); SubUI.TitleSub.Text = tostring(#outfits).." Outfit(s)"
		currentOutfitsList = outfits; totalOutfitPages = math.ceil(#outfits/100); currentOutfitPage = 1
		SubUI.PageContainer.Visible = #outfits >= 100
		renderOutfitPage(currentOutfitPage, renderToken)
	end)
end

local isOpen, _lookupPending = false, false
local function setSearchStatus(txt, col) SearchStatusLabel.Text = txt or ""; SearchStatusLabel.TextColor3 = col or C.TEXT2 end

local function triggerSearch()
	if _lookupPending then return end
	local raw = SearchBox.Text:match("^%s*(.-)%s*$")
	if raw == "" then setSearchStatus("Bitte einen Namen oder eine User ID eingeben.", Color3.fromRGB(255,160,60)); return end
	local numId = tonumber(raw)
	if numId then
		if numId <= 0 then setSearchStatus("Ungueltige User ID.", Color3.fromRGB(255,100,100)); return end
		local inGamePlayer = nil
		for _, p in ipairs(Players:GetPlayers()) do if p.UserId == numId then inGamePlayer = p; break end end
		if inGamePlayer then setSearchStatus(""); openOutfitPanel(inGamePlayer)
		else setSearchStatus("Lade Outfits fuer ID "..tostring(numId).."...")
			openOutfitPanel({Name=tostring(numId), DisplayName="ID "..tostring(numId), UserId=numId}) end
	else
		if #raw < 3 then setSearchStatus("Username zu kurz (min. 3 Zeichen).", Color3.fromRGB(255,100,100)); return end
		local inGamePlayer = nil
		for _, p in ipairs(Players:GetPlayers()) do if string.lower(p.Name) == string.lower(raw) then inGamePlayer = p; break end end
		if inGamePlayer then setSearchStatus(""); openOutfitPanel(inGamePlayer); return end
		_lookupPending = true; ConfirmBtn.Text = "Suche..."; setSearchStatus('Suche "'..raw..'"...')
		task.spawn(function()
			local ok, userId = pcall(function() return Players:GetUserIdFromNameAsync(raw) end)
			_lookupPending = false; ConfirmBtn.Text = "Suchen"
			if ok and userId then setSearchStatus(""); openOutfitPanel({Name=raw, DisplayName=raw, UserId=userId})
			else setSearchStatus('User "'..raw..'" nicht gefunden.', Color3.fromRGB(255,80,80)) end
		end)
	end
end

bind(ConfirmBtn.MouseButton1Click, function()
	_lookupPending = false; ConfirmBtn.Text = "Suchen"
	if _activeTab == "search" then executeSearch()
	elseif _activeTab == "outfitsearch" then executeOutfitNameSearch()
	else triggerSearch() end
end)

bind(SearchBox.FocusLost, function(enterPressed)
	if not enterPressed then return end
	_lookupPending = false; ConfirmBtn.Text = "Suchen"
	if _activeTab == "search" then executeSearch()
	elseif _activeTab == "outfitsearch" then executeOutfitNameSearch()
	else triggerSearch() end
end)

bind(TabUI.ServerTabBtn.MouseButton1Click, function() switchTab("server") end)
bind(TabUI.SearchTabBtn.MouseButton1Click, function() switchTab("search") end)
bind(TabUI.OutfitSearchTabBtn.MouseButton1Click, function() switchTab("outfitsearch") end)

local _searchScrollConn = nil
local function setupSearchInfiniteScroll()
	if _searchScrollConn then pcall(function() _searchScrollConn:Disconnect() end) end
	_searchScrollConn = bind(TabUI.SearchTabScroll:GetPropertyChangedSignal("CanvasPosition"), function()
		if _searchLoading or _searchNextCursor == "" then return end
		local pos = TabUI.SearchTabScroll.CanvasPosition.Y; local canvasH = TabUI.SearchTabScroll.CanvasSize.Y.Offset; local viewH = TabUI.SearchTabScroll.AbsoluteSize.Y
		if canvasH - pos - viewH < 60 then
			_searchLoading = true; local loadIdx = #_searchResults + 1
			task.spawn(function()
				local results, nextCursor, err = searchPlayers(_searchQuery, _searchNextCursor)
				_searchLoading = false
				if err or not results or #results == 0 then _searchNextCursor = ""; return end
				_searchNextCursor = nextCursor or ""
				for i, userData in ipairs(results) do table.insert(_searchResults, userData); buildSearchResultCard(TabUI.SearchTabScroll, userData, loadIdx + i - 1) end
			end)
		end
	end)
end
setupSearchInfiniteScroll()

local function buildPlayerCards()
	for _, ch in ipairs(PlayerCardsScroll:GetChildren()) do if ch:IsA("ImageButton") or ch:IsA("Frame") then ch:Destroy() end end
	local allPlayers = Players:GetPlayers()
	for idx, plr in ipairs(allPlayers) do
		local card = Instance.new("ImageButton"); card.Name = "PC_"..plr.UserId; card.Size = UDim2.fromOffset(CARD_W_PC, CARD_H_PC)
		card.BackgroundColor3 = C.panelHdr; card.BackgroundTransparency = 0; card.BorderSizePixel = 0; card.ZIndex = 13; card.LayoutOrder = idx; card.Parent = PlayerCardsScroll; corner(card, 10)
		local cStroke = Instance.new("UIStroke", card); cStroke.Thickness = 1; cStroke.Color = C.bg3; cStroke.Transparency = 0.4
		local thumb = Instance.new("ImageLabel", card); thumb.Size = UDim2.fromOffset(68,68)
		thumb.Position = UDim2.new(0.5,0,0,8); thumb.AnchorPoint = Vector2.new(0.5,0)
		thumb.BackgroundColor3 = Color3.fromRGB(14,14,14); thumb.BackgroundTransparency = 0; thumb.BorderSizePixel = 0
		thumb.Image = avatarThumbUrl(plr.UserId); thumb.ScaleType = Enum.ScaleType.Fit; thumb.ZIndex = 14; corner(thumb, 8)
		local thumbRing = Instance.new("UIStroke", thumb); thumbRing.Thickness = 1.5; thumbRing.Color = C.accent; thumbRing.Transparency = 0.6
		local nameLbl = Instance.new("TextLabel", card); nameLbl.Size = UDim2.new(1,-6,0,22); nameLbl.Position = UDim2.fromOffset(3,80)
		nameLbl.BackgroundTransparency = 1; nameLbl.Text = plr.DisplayName ~= plr.Name and plr.DisplayName or plr.Name
		nameLbl.TextSize = 10; nameLbl.TextColor3 = C.TEXT1; nameLbl.TextXAlignment = Enum.TextXAlignment.Center; nameLbl.TextWrapped = true; nameLbl.TextTruncate = Enum.TextTruncate.AtEnd; nameLbl.ZIndex = 14; applyTextStyle(nameLbl)
		if plr.DisplayName ~= plr.Name then
			local unLbl = Instance.new("TextLabel", card); unLbl.Size = UDim2.new(1,-6,0,14); unLbl.Position = UDim2.fromOffset(3,100)
			unLbl.BackgroundTransparency = 1; unLbl.Text = "@"..plr.Name; unLbl.TextSize = 8; unLbl.TextColor3 = C.TEXT2; unLbl.TextXAlignment = Enum.TextXAlignment.Center; unLbl.TextTruncate = Enum.TextTruncate.AtEnd; unLbl.ZIndex = 14; applyTextStyle(unLbl)
		end
		if plr == LocalPlayer then
			local badge = Instance.new("TextLabel", card); badge.Size = UDim2.fromOffset(24,14)
			badge.Position = UDim2.new(1,-4,0,4); badge.AnchorPoint = Vector2.new(1,0)
			badge.BackgroundColor3 = C.accent; badge.BackgroundTransparency = 0; badge.BorderSizePixel = 0; badge.Text = "Du"; badge.TextSize = 8; badge.TextColor3 = Color3.new(1,1,1)
			badge.TextXAlignment = Enum.TextXAlignment.Center; badge.ZIndex = 15; corner(badge, 4)
		end
		local hoverBg = C.accent; local normalBg = C.panelHdr
		bind(card.MouseEnter, function() tween(card, TI._008, {BackgroundColor3=hoverBg:lerp(normalBg,0.72)}):Play(); tween(cStroke, TI._008, {Color=hoverBg, Transparency=0}):Play(); tween(thumbRing, TI._008, {Transparency=0.1}):Play() end)
		bind(card.MouseLeave, function() tween(card, TI._012, {BackgroundColor3=normalBg}):Play(); tween(cStroke, TI._012, {Color=C.bg3, Transparency=0.4}):Play(); tween(thumbRing, TI._012, {Transparency=0.6}):Play() end)
		bind(card.MouseButton1Down, function() tween(getPopScale(card), TI._008, {Scale=0.93}):Play() end)
		bind(card.MouseButton1Up, function() tween(getPopScale(card), TI._016, {Scale=1}):Play() end)
		local _captured = plr
		bind(card.MouseButton1Click, function() setSearchStatus(""); SearchBox.Text = ""; openOutfitPanel(_captured) end)
	end
	local hasCards = #allPlayers > 0; PlayerCardsLabel.Visible = hasCards; PlayerCardsSep.Visible = hasCards; PlayerCardsScroll.Visible = hasCards
	return hasCards
end

local function openPanel()
	isOpen = true; buildPlayerCards(); switchTab(_activeTab)
	local hasCards = PlayerCardsScroll.Visible or _activeTab == "search" or _activeTab == "outfitsearch"
	tweenOpen(Panel, C.PANEL_W, hasCards and PANEL_H_CARDS or PANEL_H_BASE); setSearchStatus("")
end

local function closePanel()
	isOpen = false; _lookupPending = false; ConfirmBtn.Text = "Suchen"; currentSubPlayer = nil; _skipPanelReopen = true
	if SubUI.Panel.Visible then closeOutfitPanel() end; if SavedPanel.Visible then closeSavedPanel() end
	task.delay(0.15, function() _skipPanelReopen = false end)
	local hasCards = PlayerCardsScroll.Visible or _activeTab == "search" or _activeTab == "outfitsearch"
	tweenClose(Panel, C.PANEL_W, hasCards and PANEL_H_CARDS or PANEL_H_BASE)
end

bind(CloseBtn.MouseButton1Click, closePanel)
bind(RefreshBtn.MouseButton1Click, function()
	if not isOpen then return end
	if SubUI.Panel.Visible and currentSubPlayer then diskCacheInvalidate(currentSubPlayer.UserId); cacheDel(currentSubPlayer.UserId); openOutfitPanel(currentSubPlayer) end
end)
bind(SavedOutfitsBtn.MouseButton1Click, function() if SavedPanel.Visible then closeSavedPanel() else openSavedPanel() end end)
bind(SubUI.CloseBtn.MouseButton1Click, function() currentSubPlayer = nil; closeOutfitPanel() end)
bind(SubUI.BackBtn.MouseButton1Click, function() currentSubPlayer = nil; closeOutfitPanel() end)
bind(SavedCloseBtn.MouseButton1Click, closeSavedPanel)
bind(SubUI.RefreshBtn.MouseButton1Click, function()
	if not currentSubPlayer then return end
	tween(SubUI.RefreshBtn, getTI(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false), {Rotation=SubUI.RefreshBtn.Rotation+360}):Play()
	diskCacheInvalidate(currentSubPlayer.UserId); cacheDel(currentSubPlayer.UserId); openOutfitPanel(currentSubPlayer)
end)
bind(SubUI.ReloadBtn.MouseButton1Click, function()
	if not currentSubPlayer then return end
	SubUI.Empty.Visible = false; SubUI.ReloadBtn.Visible = false; SubUI.ReloadLabel.Visible = false; SubUI.Loading.Visible = true
	diskCacheInvalidate(currentSubPlayer.UserId); cacheDel(currentSubPlayer.UserId); openOutfitPanel(currentSubPlayer)
end)

bind(UserInputService.InputBegan, function(inp, gp)
	if gp then return end; if UserInputService:GetFocusedTextBox() then return end
	if inp.KeyCode == C.KEYBIND then if isOpen then closePanel() else openPanel() end end
end)

local function showKeybindHint()
	local hintGui = Instance.new("ScreenGui"); hintGui.Name = "AvatarOutfitPanelHint"
	hintGui.ResetOnSpawn = false; hintGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; regInst(hintGui)
	pcall(function() hintGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)
	local hintF = Instance.new("Frame"); hintF.Size = UDim2.fromOffset(220,28); hintF.Position = UDim2.new(0.5,0,1,-56)
	hintF.AnchorPoint = Vector2.new(0.5,1); hintF.BackgroundColor3 = Color3.fromRGB(8,8,8)
	hintF.BackgroundTransparency = 0.15; hintF.Parent = hintGui; corner(hintF, 6); stroke(hintF, 1, Color3.fromRGB(50,50,50), 0)
	local hintL = Instance.new("TextLabel"); hintL.Text = string.format("Avatar Panel [%s] | Local Only", C.KEYBIND.Name)
	hintL.Size = UDim2.fromScale(1,1); hintL.BackgroundTransparency = 1; hintL.TextSize = 10
	hintL.TextColor3 = Color3.fromRGB(160,160,160); hintL.ZIndex = 2; hintL.Font = Enum.Font.Gotham; hintL.Parent = hintF
	task.delay(4, function()
		twP(hintF, 0.80, {BackgroundTransparency=1, Position=UDim2.new(0.5,0,1,-76)})
		twP(hintL, 0.80, {TextTransparency=1})
		task.delay(0.9, function() hintGui:Destroy() end)
	end)
end
showKeybindHint()

log("[AvatarOutfitPanel] Geladen. Taste:", C.KEYBIND.Name, "| Community API:", COMMUNITY_API_BASE)

return {open=openPanel, close=closePanel, getIsOpen=function() return isOpen end, openForPlayer=openOutfitPanel}
end

initAvatarOutfit()
