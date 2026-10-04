--[[
    ╔══════════════════════════════════════════════════════╗
    ║          ROBLOX FULL GAME DUMPER v3.0               ║
    ║               GUI Edition  🔴                       ║
    ╚══════════════════════════════════════════════════════╝

    loadstring(game:HttpGet("https://raw.githubusercontent.com/TU_USUARIO/TU_REPO/main/GameDumper.lua"))()
--]]

-- ══════════════════════════════════════════════════════════
--  VERIFICACIÓN DE APIs
-- ══════════════════════════════════════════════════════════
if not (type(writefile) == "function" and type(makefolder) == "function") then
    error("[DUMPER] Executor no compatible. Usa Synapse X, Wave, KRNL o Fluxus.")
end

-- ══════════════════════════════════════════════════════════
--  CONFIGURACIÓN
-- ══════════════════════════════════════════════════════════
local CONFIG = {
    outputFolder     = "GameDump_" .. game.PlaceId,
    decompileScripts = true,
    dumpWorkspace    = true,
    dumpAnimations   = true,
    dumpGUIs         = true,
    dumpRemotes      = true,
    dumpSounds       = true,
}

-- ══════════════════════════════════════════════════════════
--  UTILIDADES
-- ══════════════════════════════════════════════════════════
local function safeWrite(path, content)
    pcall(writefile, path, tostring(content))
end

local function safeFolder(path)
    pcall(makefolder, path)
end

local function sanitize(name)
    local s = tostring(name):gsub('[<>:"/\\|?*%z]', '_'):gsub('^%s+', ''):gsub('%s+$', '')
    return s ~= "" and s or "Unnamed"
end

local function getPath(obj)
    local parts = {}
    local cur = obj
    while cur and cur ~= game do
        table.insert(parts, 1, sanitize(cur.Name))
        cur = cur.Parent
    end
    return table.concat(parts, "/")
end

local results = { scripts = 0, animations = 0, remotes = 0, sounds = 0, guis = 0 }

-- ══════════════════════════════════════════════════════════
--  GUI
-- ══════════════════════════════════════════════════════════
local gui_parent = (type(gethui) == "function" and gethui())
                or game:GetService("CoreGui")

pcall(function()
    local old = gui_parent:FindFirstChild("_DumperGUI")
    if old then old:Destroy() end
end)

local ScreenGui            = Instance.new("ScreenGui")
ScreenGui.Name             = "_DumperGUI"
ScreenGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn     = false
ScreenGui.Parent           = gui_parent

local Main                 = Instance.new("Frame")
Main.Name                  = "Main"
Main.Size                  = UDim2.new(0, 340, 0, 420)
Main.Position              = UDim2.new(0.5, -170, 0.5, -210)
Main.BackgroundColor3      = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel       = 0
Main.ClipsDescendants      = true
Main.Parent                = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Stroke               = Instance.new("UIStroke", Main)
Stroke.Color               = Color3.fromRGB(200, 30, 30)
Stroke.Thickness           = 1.5
Stroke.Transparency        = 0.3

-- Header
local Header               = Instance.new("Frame")
Header.Size                = UDim2.new(1, 0, 0, 48)
Header.BackgroundColor3    = Color3.fromRGB(200, 30, 30)
Header.BorderSizePixel     = 0
Header.Parent              = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local HeaderFix            = Instance.new("Frame")
HeaderFix.Size             = UDim2.new(1, 0, 0.5, 0)
HeaderFix.Position         = UDim2.new(0, 0, 0.5, 0)
HeaderFix.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
HeaderFix.BorderSizePixel  = 0
HeaderFix.Parent           = Header

local Title                = Instance.new("TextLabel")
Title.Size                 = UDim2.new(1, -60, 1, 0)
Title.Position             = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Font                 = Enum.Font.GothamBold
Title.Text                 = "🔴  GAME DUMPER v3.0"
Title.TextColor3           = Color3.fromRGB(255, 255, 255)
Title.TextSize             = 15
Title.TextXAlignment       = Enum.TextXAlignment.Left
Title.Parent               = Header

local Sub                  = Instance.new("TextLabel")
Sub.Size                   = UDim2.new(1, -12, 0, 16)
Sub.Position               = UDim2.new(0, 12, 1, -18)
Sub.BackgroundTransparency = 1
Sub.Font                   = Enum.Font.Gotham
Sub.Text                   = "PlaceId: " .. tostring(game.PlaceId)
Sub.TextColor3             = Color3.fromRGB(255, 200, 200)
Sub.TextSize               = 11
Sub.TextXAlignment         = Enum.TextXAlignment.Left
Sub.Parent                 = Header

local CloseBtn             = Instance.new("TextButton")
CloseBtn.Size              = UDim2.new(0, 32, 0, 32)
CloseBtn.Position          = UDim2.new(1, -40, 0, 8)
CloseBtn.BackgroundColor3  = Color3.fromRGB(255, 60, 60)
CloseBtn.Font              = Enum.Font.GothamBold
CloseBtn.Text              = "✕"
CloseBtn.TextColor3        = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize          = 14
CloseBtn.BorderSizePixel   = 0
CloseBtn.Parent            = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Log scroll
local LogScroll                  = Instance.new("ScrollingFrame")
LogScroll.Size                   = UDim2.new(1, -20, 0, 200)
LogScroll.Position               = UDim2.new(0, 10, 0, 58)
LogScroll.BackgroundColor3       = Color3.fromRGB(10, 10, 15)
LogScroll.BorderSizePixel        = 0
LogScroll.ScrollBarThickness     = 4
LogScroll.ScrollBarImageColor3   = Color3.fromRGB(200, 30, 30)
LogScroll.CanvasSize             = UDim2.new(0, 0, 0, 0)
LogScroll.AutomaticCanvasSize    = Enum.AutomaticSize.Y
LogScroll.Parent                 = Main
Instance.new("UICorner", LogScroll).CornerRadius = UDim.new(0, 6)
local LogLayout = Instance.new("UIListLayout", LogScroll)
LogLayout.SortOrder = Enum.SortOrder.LayoutOrder
LogLayout.Padding   = UDim.new(0, 2)
local LogPad = Instance.new("UIPadding", LogScroll)
LogPad.PaddingLeft  = UDim.new(0, 6)
LogPad.PaddingTop   = UDim.new(0, 4)
LogPad.PaddingRight = UDim.new(0, 6)

local logIndex = 0
local function addLog(text, color)
    logIndex = logIndex + 1
    color = color or Color3.fromRGB(180, 180, 200)
    local lbl = Instance.new("TextLabel")
    lbl.Size                 = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Font                 = Enum.Font.Code
    lbl.Text                 = text
    lbl.TextColor3           = color
    lbl.TextSize             = 11
    lbl.TextXAlignment       = Enum.TextXAlignment.Left
    lbl.TextWrapped          = true
    lbl.AutomaticSize        = Enum.AutomaticSize.Y
    lbl.LayoutOrder          = logIndex
    lbl.Parent               = LogScroll
    task.defer(function()
        LogScroll.CanvasPosition = Vector2.new(0, math.huge)
    end)
end

-- Barra de progreso
local ProgBg               = Instance.new("Frame")
ProgBg.Size                = UDim2.new(1, -20, 0, 8)
ProgBg.Position            = UDim2.new(0, 10, 0, 268)
ProgBg.BackgroundColor3    = Color3.fromRGB(30, 30, 40)
ProgBg.BorderSizePixel     = 0
ProgBg.Parent              = Main
Instance.new("UICorner", ProgBg).CornerRadius = UDim.new(0, 4)

local ProgBar              = Instance.new("Frame")
ProgBar.Size               = UDim2.new(0, 0, 1, 0)
ProgBar.BackgroundColor3   = Color3.fromRGB(200, 30, 30)
ProgBar.BorderSizePixel    = 0
ProgBar.Parent             = ProgBg
Instance.new("UICorner", ProgBar).CornerRadius = UDim.new(0, 4)

local ProgLabel            = Instance.new("TextLabel")
ProgLabel.Size             = UDim2.new(1, -20, 0, 16)
ProgLabel.Position         = UDim2.new(0, 10, 0, 280)
ProgLabel.BackgroundTransparency = 1
ProgLabel.Font             = Enum.Font.Gotham
ProgLabel.Text             = "Listo para iniciar..."
ProgLabel.TextColor3       = Color3.fromRGB(150, 150, 170)
ProgLabel.TextSize         = 11
ProgLabel.TextXAlignment   = Enum.TextXAlignment.Left
ProgLabel.Parent           = Main

local TweenService = game:GetService("TweenService")
local function setProgress(pct, label)
    TweenService:Create(ProgBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad),
        { Size = UDim2.new(pct, 0, 1, 0) }):Play()
    ProgLabel.Text = label or ""
end

-- Stats grid
local StatsFrame           = Instance.new("Frame")
StatsFrame.Size            = UDim2.new(1, -20, 0, 70)
StatsFrame.Position        = UDim2.new(0, 10, 0, 300)
StatsFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
StatsFrame.BorderSizePixel = 0
StatsFrame.Parent          = Main
Instance.new("UICorner", StatsFrame).CornerRadius = UDim.new(0, 6)

local statLabels = {}
local statDefs = {
    { key = "scripts",    icon = "📜", label = "Scripts",     col = 0 },
    { key = "animations", icon = "🎭", label = "Anims",       col = 1 },
    { key = "remotes",    icon = "📡", label = "Remotes",     col = 2 },
    { key = "sounds",     icon = "🔊", label = "Sounds",      col = 3 },
    { key = "guis",       icon = "🖥️", label = "GUIs",        col = 4 },
}

for _, def in ipairs(statDefs) do
    local colW  = 1 / #statDefs
    local frame = Instance.new("Frame")
    frame.Size             = UDim2.new(colW, -4, 1, -8)
    frame.Position         = UDim2.new(def.col * colW, 2, 0, 4)
    frame.BackgroundTransparency = 1
    frame.Parent           = StatsFrame

    local icon = Instance.new("TextLabel")
    icon.Size              = UDim2.new(1, 0, 0, 22)
    icon.BackgroundTransparency = 1
    icon.Font              = Enum.Font.GothamBold
    icon.Text              = def.icon
    icon.TextSize          = 18
    icon.TextColor3        = Color3.fromRGB(255, 255, 255)
    icon.Parent            = frame

    local num = Instance.new("TextLabel")
    num.Name               = "Num"
    num.Size               = UDim2.new(1, 0, 0, 18)
    num.Position           = UDim2.new(0, 0, 0, 22)
    num.BackgroundTransparency = 1
    num.Font               = Enum.Font.GothamBold
    num.Text               = "0"
    num.TextSize           = 15
    num.TextColor3         = Color3.fromRGB(200, 30, 30)
    num.Parent             = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size               = UDim2.new(1, 0, 0, 14)
    lbl.Position           = UDim2.new(0, 0, 0, 42)
    lbl.BackgroundTransparency = 1
    lbl.Font               = Enum.Font.Gotham
    lbl.Text               = def.label
    lbl.TextSize           = 9
    lbl.TextColor3         = Color3.fromRGB(120, 120, 140)
    lbl.Parent             = frame

    statLabels[def.key]    = num
end

local function updateStat(key, val)
    results[key] = val
    if statLabels[key] then statLabels[key].Text = tostring(val) end
end

-- Botón START
local StartBtn             = Instance.new("TextButton")
StartBtn.Size              = UDim2.new(1, -20, 0, 38)
StartBtn.Position          = UDim2.new(0, 10, 1, -48)
StartBtn.BackgroundColor3  = Color3.fromRGB(200, 30, 30)
StartBtn.Font              = Enum.Font.GothamBold
StartBtn.Text              = "▶   INICIAR DUMP COMPLETO"
StartBtn.TextColor3        = Color3.fromRGB(255, 255, 255)
StartBtn.TextSize          = 13
StartBtn.BorderSizePixel   = 0
StartBtn.AutoButtonColor   = false
StartBtn.Parent            = Main
Instance.new("UICorner", StartBtn).CornerRadius = UDim.new(0, 8)

StartBtn.MouseEnter:Connect(function()
    TweenService:Create(StartBtn, TweenInfo.new(0.15),
        { BackgroundColor3 = Color3.fromRGB(230, 50, 50) }):Play()
end)
StartBtn.MouseLeave:Connect(function()
    TweenService:Create(StartBtn, TweenInfo.new(0.15),
        { BackgroundColor3 = Color3.fromRGB(200, 30, 30) }):Play()
end)

-- Drag
do
    local dragging, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = input.Position
            startPos  = Main.Position
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- ══════════════════════════════════════════════════════════
--  LÓGICA DE DUMP
-- ══════════════════════════════════════════════════════════
local function dumpScripts(base)
    local folder = base .. "/Scripts"
    safeFolder(folder)
    local count = 0

    local function getSource(s)
        if CONFIG.decompileScripts then
            local ok, r = pcall(decompile, s)
            if ok and type(r) == "string" and #r > 5 then return r, "decompile" end
        end
        if type(getscriptbytecode) == "function" then
            local ok, r = pcall(getscriptbytecode, s)
            if ok and r then return "-- [bytecode]\n" .. tostring(r), "bytecode" end
        end
        local ok, r = pcall(function() return s.Source end)
        if ok and type(r) == "string" and #r > 0 then return r, "source" end
        return "-- [sin acceso]\n-- " .. s.ClassName .. " @ " .. getPath(s), "none"
    end

    local function scan(obj)
        local ok, ch = pcall(function() return obj:GetChildren() end)
        if not ok then return end
        for _, c in ipairs(ch) do
            if c:IsA("LuaSourceContainer") then
                local src, method = getSource(c)
                local ext = c.ClassName == "ModuleScript" and ".module.lua" or ".lua"
                local name = sanitize(getPath(c)):gsub("/", "__")
                local header = ("-- [%s] %s\n-- Path: %s\n-- Método: %s\n\n"):format(
                    c.ClassName, c.Name, getPath(c), method)
                safeWrite(folder .. "/" .. name .. ext, header .. src)
                count = count + 1
                addLog("  📜 " .. c.Name, Color3.fromRGB(140, 200, 140))
                updateStat("scripts", count)
            end
            scan(c)
        end
    end

    for _, s in ipairs({
        workspace, game:GetService("ReplicatedStorage"),
        game:GetService("ReplicatedFirst"), game:GetService("ServerScriptService"),
        game:GetService("ServerStorage"), game:GetService("StarterGui"),
        game:GetService("StarterPack"), game:GetService("StarterPlayer"),
        game:GetService("Lighting"), game:GetService("Chat"),
    }) do pcall(scan, s) end

    if type(getscripts) == "function" then
        local ok, list = pcall(getscripts)
        if ok then
            safeFolder(folder .. "/__executor")
            for _, s in ipairs(list) do
                local src = getSource(s)
                local ext = s.ClassName == "ModuleScript" and ".module.lua" or ".lua"
                safeWrite(folder .. "/__executor/" .. sanitize(s.Name) .. ext, src)
                count = count + 1
                updateStat("scripts", count)
            end
        end
    end
    return count
end

local function dumpWorkspace(base)
    local folder = base .. "/Workspace"
    safeFolder(folder)
    local function ser(inst, d)
        d = d or 0
        local pad = ("  "):rep(d)
        local lines = { pad .. '<Item class="'..inst.ClassName..'" name="'..sanitize(inst.Name)..'">' }
        for _, prop in ipairs({"Position","Size","Color","Material","Anchored",
                               "Transparency","CFrame","Visible","Text","Value"}) do
            local ok, v = pcall(function() return inst[prop] end)
            if ok and v ~= nil then
                table.insert(lines, pad.."  <"..prop..">"..tostring(v).."</"..prop..">")
            end
        end
        local ok, ch = pcall(function() return inst:GetChildren() end)
        if ok then for _, c in ipairs(ch) do
            for _, l in ipairs(ser(c, d+1)) do table.insert(lines, l) end
        end end
        table.insert(lines, pad.."</Item>")
        return lines
    end
    local out = {'<?xml version="1.0"?>', "<roblox>"}
    local ok, ch = pcall(function() return workspace:GetChildren() end)
    if ok then for _, c in ipairs(ch) do
        for _, l in ipairs(ser(c, 1)) do table.insert(out, l) end
    end end
    table.insert(out, "</roblox>")
    safeWrite(folder .. "/workspace.rbxmx", table.concat(out, "\n"))
    addLog("  🏗️ Workspace serializado", Color3.fromRGB(140, 180, 255))
end

local function dumpAnimations(base)
    local folder = base .. "/Animations"
    safeFolder(folder)
    local found, ids, count = {}, {}, 0
    local ok, desc = pcall(function() return game:GetDescendants() end)
    if ok then
        for _, d in ipairs(desc) do
            if d:IsA("Animation") then
                local id = tostring(d.AnimationId)
                if not found[id] then
                    found[id] = true
                    count = count + 1
                    table.insert(ids, id)
                    safeWrite(folder.."/"..sanitize(d.Name).."_"..count..".txt",
                        "Id: "..id.."\nNombre: "..d.Name.."\nPath: "..getPath(d))
                    updateStat("animations", count)
                end
            end
            if d:IsA("Humanoid") then
                local tok, tracks = pcall(function() return d:GetPlayingAnimationTracks() end)
                if tok then
                    for _, t in ipairs(tracks) do
                        local id = tostring(t.Animation.AnimationId)
                        if not found[id] then found[id]=true; count=count+1; table.insert(ids,id); updateStat("animations",count) end
                    end
                end
            end
        end
    end
    safeWrite(folder.."/_all_ids.txt", table.concat(ids, "\n"))
    addLog("  🎭 "..count.." animaciones", Color3.fromRGB(255, 200, 100))
    return count
end

local function dumpGUIs(base)
    local folder = base .. "/GUIs"
    safeFolder(folder)
    local count = 0
    local function ser(inst, d)
        d = d or 0
        local pad = ("  "):rep(d)
        local lines = { pad..'<Item class="'..inst.ClassName..'" name="'..sanitize(inst.Name)..'">' }
        for _, prop in ipairs({"Size","Position","Visible","Text","BackgroundColor3","ZIndex","Enabled"}) do
            local ok, v = pcall(function() return inst[prop] end)
            if ok and v ~= nil then table.insert(lines, pad.."  <"..prop..">"..tostring(v).."</"..prop..">") end
        end
        local ok, ch = pcall(function() return inst:GetChildren() end)
        if ok then for _, c in ipairs(ch) do for _, l in ipairs(ser(c, d+1)) do table.insert(lines, l) end end end
        table.insert(lines, pad.."</Item>")
        return lines
    end
    local srcs = {{ game:GetService("StarterGui"), "StarterGui" }, { game.Players.LocalPlayer.PlayerGui, "PlayerGui" }}
    pcall(function() table.insert(srcs, { game:GetService("CoreGui"), "CoreGui" }) end)
    for _, pair in ipairs(srcs) do
        local svc, name = pair[1], pair[2]
        local ok, ch = pcall(function() return svc:GetChildren() end)
        if ok then
            for _, gui in ipairs(ch) do
                if gui ~= ScreenGui then
                    safeWrite(folder.."/"..name.."_"..sanitize(gui.Name)..".rbxmx", table.concat(ser(gui), "\n"))
                    count = count + 1
                    updateStat("guis", count)
                    addLog("  🖥️ "..name.."/"..gui.Name, Color3.fromRGB(180, 140, 255))
                end
            end
        end
    end
    return count
end

local function dumpRemotes(base)
    local folder = base .. "/Remotes"
    safeFolder(folder)
    local list, count = {}, 0
    local rtypes = {"RemoteEvent","RemoteFunction","BindableEvent","BindableFunction","UnreliableRemoteEvent"}
    local function scan(obj)
        local ok, desc = pcall(function() return obj:GetDescendants() end)
        if not ok then return end
        for _, d in ipairs(desc) do
            if table.find(rtypes, d.ClassName) then
                count = count + 1
                table.insert(list, "["..d.ClassName.."] "..getPath(d))
                updateStat("remotes", count)
            end
        end
    end
    pcall(scan, game:GetService("ReplicatedStorage"))
    pcall(scan, game:GetService("ReplicatedFirst"))
    pcall(scan, workspace)
    safeWrite(folder.."/remotes.txt", table.concat(list, "\n"))
    addLog("  📡 "..count.." remotes", Color3.fromRGB(100, 200, 255))
    return count
end

local function dumpSounds(base)
    local folder = base .. "/Sounds"
    safeFolder(folder)
    local list, count = {}, 0
    local ok, desc = pcall(function() return game:GetDescendants() end)
    if ok then
        for _, d in ipairs(desc) do
            if d:IsA("Sound") then
                count = count + 1
                table.insert(list, ("SoundId: %s | Vol: %s | %s"):format(
                    tostring(d.SoundId), tostring(d.Volume), getPath(d)))
                updateStat("sounds", count)
            end
        end
    end
    safeWrite(folder.."/sounds.txt", table.concat(list, "\n"))
    addLog("  🔊 "..count.." sounds", Color3.fromRGB(255, 160, 80))
end

local function dumpMeta(base)
    safeWrite(base.."/metadata.txt", ("PlaceId: %s\nGameId: %s\nCreatorId: %s\nJobId: %s\nFecha: %s"):format(
        tostring(game.PlaceId), tostring(game.GameId), tostring(game.CreatorId),
        tostring(game.JobId), os.date("%Y-%m-%d %H:%M:%S")))
end

-- ══════════════════════════════════════════════════════════
--  BOTÓN — ORQUESTADOR
-- ══════════════════════════════════════════════════════════
local running = false

StartBtn.MouseButton1Click:Connect(function()
    if running then return end
    running = true
    StartBtn.Text              = "⏳  Dumpeando..."
    StartBtn.BackgroundColor3  = Color3.fromRGB(80, 80, 100)

    task.spawn(function()
        local base = CONFIG.outputFolder
        safeFolder(base)
        dumpMeta(base)

        addLog("▶ PlaceId: " .. game.PlaceId, Color3.fromRGB(255, 80, 80))
        addLog("─────────────────────────────")
        task.wait(0.05)

        setProgress(0.05, "Extrayendo scripts...")
        addLog("[ Scripts ]", Color3.fromRGB(200, 200, 255))
        dumpScripts(base)
        setProgress(0.30, "Scripts listos")
        task.wait(0.05)

        if CONFIG.dumpWorkspace then
            setProgress(0.40, "Volcando workspace...")
            addLog("[ Workspace ]", Color3.fromRGB(200, 200, 255))
            dumpWorkspace(base)
            setProgress(0.50, "Workspace listo")
            task.wait(0.05)
        end

        if CONFIG.dumpAnimations then
            setProgress(0.60, "Extrayendo animaciones...")
            addLog("[ Animaciones ]", Color3.fromRGB(200, 200, 255))
            dumpAnimations(base)
            setProgress(0.70, "Animaciones listas")
            task.wait(0.05)
        end

        if CONFIG.dumpGUIs then
            setProgress(0.78, "Extrayendo GUIs...")
            addLog("[ GUIs ]", Color3.fromRGB(200, 200, 255))
            dumpGUIs(base)
            setProgress(0.86, "GUIs listas")
            task.wait(0.05)
        end

        if CONFIG.dumpRemotes then
            setProgress(0.92, "Catalogando remotes...")
            addLog("[ Remotes ]", Color3.fromRGB(200, 200, 255))
            dumpRemotes(base)
            setProgress(0.96, "Remotes listos")
            task.wait(0.05)
        end

        if CONFIG.dumpSounds then
            setProgress(0.99, "Sounds...")
            addLog("[ Sounds ]", Color3.fromRGB(200, 200, 255))
            dumpSounds(base)
        end

        setProgress(1.0, "✅  ¡Dump completo!")
        addLog("─────────────────────────────")
        addLog("✅  DUMP COMPLETO", Color3.fromRGB(80, 255, 120))
        addLog("📁  " .. base, Color3.fromRGB(200, 200, 80))
        addLog(("📜%d  🎭%d  📡%d  🔊%d  🖥️%d"):format(
            results.scripts, results.animations, results.remotes, results.sounds, results.guis),
            Color3.fromRGB(200, 200, 200))

        StartBtn.Text             = "✅  ¡LISTO!  →  " .. base
        StartBtn.BackgroundColor3 = Color3.fromRGB(30, 160, 80)
        TweenService:Create(Stroke, TweenInfo.new(0.4),
            { Color = Color3.fromRGB(80, 255, 120) }):Play()
        task.wait(1.5)
        TweenService:Create(Stroke, TweenInfo.new(0.4),
            { Color = Color3.fromRGB(200, 30, 30) }):Play()
        running = false
    end)
end)

addLog("GUI cargada  ·  PlaceId: " .. game.PlaceId, Color3.fromRGB(120, 120, 140))
addLog("Presioná ▶ para comenzar", Color3.fromRGB(150, 150, 160))
