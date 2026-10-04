--[[
    ╔══════════════════════════════════════════════════════╗
    ║          ROBLOX FULL GAME DUMPER v4.0               ║
    ║        Single File Output + GUI Edition 🔴          ║
    ╚══════════════════════════════════════════════════════╝

    loadstring(game:HttpGet("https://raw.githubusercontent.com/GULSDASDAS/roblox-dumper/main/GameDumper.lua"))()

    Todo el dump va a UN SOLO ARCHIVO:
    → workspace/GameDump_PLACEID.txt
--]]

if not (type(writefile) == "function") then
    error("[DUMPER] Executor no compatible. Usa Synapse X, Wave, KRNL o Fluxus.")
end

-- ══════════════════════════════════════════════════════════
--  BUFFER ÚNICO — todo se acumula aquí y se escribe al final
-- ══════════════════════════════════════════════════════════
local OUTPUT_FILE = "GameDump_" .. game.PlaceId .. ".txt"
local buffer      = {}

local function write(line)
    table.insert(buffer, tostring(line or ""))
end

local function section(title)
    write("")
    write("╔" .. string.rep("═", 58) .. "╗")
    write("║  " .. title .. string.rep(" ", 56 - #title) .. "║")
    write("╚" .. string.rep("═", 58) .. "╝")
    write("")
end

local function flush()
    writefile(OUTPUT_FILE, table.concat(buffer, "\n"))
end

-- ══════════════════════════════════════════════════════════
--  UTILIDADES
-- ══════════════════════════════════════════════════════════
local function sanitize(name)
    local s = tostring(name):gsub('[<>:"/\\|?*%z]', '_'):gsub('^%s+',''):gsub('%s+$','')
    return s ~= "" and s or "Unnamed"
end

local function getPath(obj)
    local parts = {}
    local cur = obj
    while cur and cur ~= game do
        table.insert(parts, 1, sanitize(cur.Name))
        cur = cur.Parent
    end
    return table.concat(parts, ".")
end

local results = { scripts = 0, animations = 0, remotes = 0, sounds = 0, guis = 0 }

-- ══════════════════════════════════════════════════════════
--  GUI
-- ══════════════════════════════════════════════════════════
local gui_parent = (type(gethui) == "function" and gethui()) or game:GetService("CoreGui")
pcall(function()
    local old = gui_parent:FindFirstChild("_DumperGUI")
    if old then old:Destroy() end
end)

local ScreenGui          = Instance.new("ScreenGui")
ScreenGui.Name           = "_DumperGUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn   = false
ScreenGui.Parent         = gui_parent

local Main               = Instance.new("Frame")
Main.Name                = "Main"
Main.Size                = UDim2.new(0, 340, 0, 420)
Main.Position            = UDim2.new(0.5, -170, 0.5, -210)
Main.BackgroundColor3    = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel     = 0
Main.ClipsDescendants    = true
Main.Parent              = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Stroke             = Instance.new("UIStroke", Main)
Stroke.Color             = Color3.fromRGB(200, 30, 30)
Stroke.Thickness         = 1.5
Stroke.Transparency      = 0.3

-- Header
local Header             = Instance.new("Frame")
Header.Size              = UDim2.new(1, 0, 0, 48)
Header.BackgroundColor3  = Color3.fromRGB(200, 30, 30)
Header.BorderSizePixel   = 0
Header.Parent            = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local HeaderFix          = Instance.new("Frame")
HeaderFix.Size           = UDim2.new(1, 0, 0.5, 0)
HeaderFix.Position       = UDim2.new(0, 0, 0.5, 0)
HeaderFix.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
HeaderFix.BorderSizePixel  = 0
HeaderFix.Parent           = Header

local Title              = Instance.new("TextLabel")
Title.Size               = UDim2.new(1, -60, 1, 0)
Title.Position           = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Font               = Enum.Font.GothamBold
Title.Text               = "🔴  GAME DUMPER v4.0"
Title.TextColor3         = Color3.fromRGB(255, 255, 255)
Title.TextSize           = 15
Title.TextXAlignment     = Enum.TextXAlignment.Left
Title.Parent             = Header

local Sub                = Instance.new("TextLabel")
Sub.Size                 = UDim2.new(1, -12, 0, 16)
Sub.Position             = UDim2.new(0, 12, 1, -18)
Sub.BackgroundTransparency = 1
Sub.Font                 = Enum.Font.Gotham
Sub.Text                 = "→ GameDump_" .. game.PlaceId .. ".txt"
Sub.TextColor3           = Color3.fromRGB(255, 200, 200)
Sub.TextSize             = 11
Sub.TextXAlignment       = Enum.TextXAlignment.Left
Sub.Parent               = Header

local CloseBtn           = Instance.new("TextButton")
CloseBtn.Size            = UDim2.new(0, 32, 0, 32)
CloseBtn.Position        = UDim2.new(1, -40, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.Font            = Enum.Font.GothamBold
CloseBtn.Text            = "✕"
CloseBtn.TextColor3      = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize        = 14
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent          = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Log
local LogScroll                = Instance.new("ScrollingFrame")
LogScroll.Size                 = UDim2.new(1, -20, 0, 200)
LogScroll.Position             = UDim2.new(0, 10, 0, 58)
LogScroll.BackgroundColor3     = Color3.fromRGB(10, 10, 15)
LogScroll.BorderSizePixel      = 0
LogScroll.ScrollBarThickness   = 4
LogScroll.ScrollBarImageColor3 = Color3.fromRGB(200, 30, 30)
LogScroll.CanvasSize           = UDim2.new(0, 0, 0, 0)
LogScroll.AutomaticCanvasSize  = Enum.AutomaticSize.Y
LogScroll.Parent               = Main
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
    color    = color or Color3.fromRGB(180, 180, 200)
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
local ProgBg             = Instance.new("Frame")
ProgBg.Size              = UDim2.new(1, -20, 0, 8)
ProgBg.Position          = UDim2.new(0, 10, 0, 268)
ProgBg.BackgroundColor3  = Color3.fromRGB(30, 30, 40)
ProgBg.BorderSizePixel   = 0
ProgBg.Parent            = Main
Instance.new("UICorner", ProgBg).CornerRadius = UDim.new(0, 4)

local ProgBar            = Instance.new("Frame")
ProgBar.Size             = UDim2.new(0, 0, 1, 0)
ProgBar.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
ProgBar.BorderSizePixel  = 0
ProgBar.Parent           = ProgBg
Instance.new("UICorner", ProgBar).CornerRadius = UDim.new(0, 4)

local ProgLabel          = Instance.new("TextLabel")
ProgLabel.Size           = UDim2.new(1, -20, 0, 16)
ProgLabel.Position       = UDim2.new(0, 10, 0, 280)
ProgLabel.BackgroundTransparency = 1
ProgLabel.Font           = Enum.Font.Gotham
ProgLabel.Text           = "Listo para iniciar..."
ProgLabel.TextColor3     = Color3.fromRGB(150, 150, 170)
ProgLabel.TextSize       = 11
ProgLabel.TextXAlignment = Enum.TextXAlignment.Left
ProgLabel.Parent         = Main

local TweenService = game:GetService("TweenService")
local function setProgress(pct, label)
    TweenService:Create(ProgBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad),
        { Size = UDim2.new(pct, 0, 1, 0) }):Play()
    ProgLabel.Text = label or ""
end

-- Stats
local StatsFrame           = Instance.new("Frame")
StatsFrame.Size            = UDim2.new(1, -20, 0, 70)
StatsFrame.Position        = UDim2.new(0, 10, 0, 300)
StatsFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
StatsFrame.BorderSizePixel = 0
StatsFrame.Parent          = Main
Instance.new("UICorner", StatsFrame).CornerRadius = UDim.new(0, 6)

local statLabels = {}
local statDefs   = {
    { key = "scripts",    icon = "📜", label = "Scripts",  col = 0 },
    { key = "animations", icon = "🎭", label = "Anims",    col = 1 },
    { key = "remotes",    icon = "📡", label = "Remotes",  col = 2 },
    { key = "sounds",     icon = "🔊", label = "Sounds",   col = 3 },
    { key = "guis",       icon = "🖥️", label = "GUIs",     col = 4 },
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

local function updateStat(key, n)
    results[key] = n
    if statLabels[key] then statLabels[key].Text = tostring(n) end
end

-- Botón
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
    Main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = i.Position; startPos = Main.Position
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                      startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- ══════════════════════════════════════════════════════════
--  COLECTORES — todo va al buffer, nada a archivos separados
-- ══════════════════════════════════════════════════════════

-- ── METADATA ─────────────────────────────────────────────
local function collectMeta()
    section("METADATA DEL JUEGO")
    write("PlaceId      : " .. tostring(game.PlaceId))
    write("GameId       : " .. tostring(game.GameId))
    write("PlaceVersion : " .. tostring(game.PlaceVersion))
    write("CreatorId    : " .. tostring(game.CreatorId))
    write("CreatorType  : " .. tostring(game.CreatorType))
    write("JobId        : " .. tostring(game.JobId))
    write("Gravity      : " .. tostring(workspace.Gravity))
    write("Fecha        : " .. os.date("%Y-%m-%d %H:%M:%S"))
end

-- ── SCRIPTS ───────────────────────────────────────────────
local function collectScripts()
    section("SCRIPTS  (LocalScript / ModuleScript / Script)")
    local count = 0

    local function getSource(s)
        if type(decompile) == "function" then
            local ok, r = pcall(decompile, s)
            if ok and type(r) == "string" and #r > 5 then return r, "decompile" end
        end
        if type(getscriptbytecode) == "function" then
            local ok, r = pcall(getscriptbytecode, s)
            if ok and r then return "-- [bytecode crudo, usar decompilador externo]", "bytecode" end
        end
        local ok, r = pcall(function() return s.Source end)
        if ok and type(r) == "string" and #r > 0 then return r, "source" end
        return "-- [sin acceso al código fuente]", "none"
    end

    local function scan(obj)
        local ok, ch = pcall(function() return obj:GetChildren() end)
        if not ok then return end
        for _, c in ipairs(ch) do
            if c:IsA("LuaSourceContainer") then
                local src, method = getSource(c)
                count = count + 1
                write(string.rep("-", 60))
                write("-- [" .. count .. "] " .. c.ClassName)
                write("-- Nombre  : " .. c.Name)
                write("-- Path    : " .. getPath(c))
                write("-- Método  : " .. method)
                write(string.rep("-", 60))
                write(src)
                write("")
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

    -- getscripts() del executor
    if type(getscripts) == "function" then
        local ok, list = pcall(getscripts)
        if ok then
            for _, s in ipairs(list) do
                local src, method = getSource(s)
                count = count + 1
                write(string.rep("-", 60))
                write("-- [executor:" .. count .. "] " .. s.ClassName)
                write("-- Nombre : " .. s.Name)
                write("-- Método : " .. method)
                write(string.rep("-", 60))
                write(src)
                write("")
                updateStat("scripts", count)
            end
        end
    end

    write(">>> Total scripts: " .. count)
    return count
end

-- ── WORKSPACE ─────────────────────────────────────────────
local function collectWorkspace()
    section("WORKSPACE  (objetos y propiedades)")
    local count = 0

    local function scan(obj, depth)
        depth = depth or 0
        local pad = string.rep("  ", depth)
        local ok, ch = pcall(function() return obj:GetChildren() end)
        if not ok then return end
        for _, c in ipairs(ch) do
            count = count + 1
            write(pad .. "[" .. c.ClassName .. "] " .. c.Name)
            -- Propiedades relevantes
            local props = {"Position","Size","Color","Material","Anchored",
                           "Transparency","CFrame","Visible","Text","Value",
                           "CanCollide","CastShadow","BrickColor"}
            for _, prop in ipairs(props) do
                local pok, v = pcall(function() return c[prop] end)
                if pok and v ~= nil then
                    write(pad .. "  ." .. prop .. " = " .. tostring(v))
                end
            end
            scan(c, depth + 1)
        end
    end

    pcall(scan, workspace)
    write("")
    write(">>> Total objetos workspace: " .. count)
    addLog("  🏗️ Workspace: " .. count .. " objetos", Color3.fromRGB(140, 180, 255))
end

-- ── REPLICATED STORAGE ────────────────────────────────────
local function collectReplicatedStorage()
    section("REPLICATED STORAGE  (objetos y propiedades)")
    local count = 0

    local function scan(obj, depth)
        depth = depth or 0
        local pad = string.rep("  ", depth)
        local ok, ch = pcall(function() return obj:GetChildren() end)
        if not ok then return end
        for _, c in ipairs(ch) do
            count = count + 1
            write(pad .. "[" .. c.ClassName .. "] " .. c.Name)
            local props = {"Value","Disabled","ClassName"}
            for _, prop in ipairs(props) do
                local pok, v = pcall(function() return c[prop] end)
                if pok and v ~= nil then
                    write(pad .. "  ." .. prop .. " = " .. tostring(v))
                end
            end
            scan(c, depth + 1)
        end
    end

    pcall(scan, game:GetService("ReplicatedStorage"))
    pcall(scan, game:GetService("ReplicatedFirst"))
    write("")
    write(">>> Total objetos: " .. count)
    addLog("  📦 ReplicatedStorage: " .. count .. " objetos", Color3.fromRGB(160, 200, 255))
end

-- ── ANIMACIONES ───────────────────────────────────────────
local function collectAnimations()
    section("ANIMACIONES")
    local found, count = {}, 0
    local ok, desc = pcall(function() return game:GetDescendants() end)
    if ok then
        for _, d in ipairs(desc) do
            if d:IsA("Animation") then
                local id = tostring(d.AnimationId)
                if not found[id] then
                    found[id] = true
                    count = count + 1
                    write(count .. ". [Animation]  Id=" .. id .. "  Nombre=" .. d.Name .. "  Path=" .. getPath(d))
                    updateStat("animations", count)
                end
            end
            if d:IsA("Humanoid") then
                local tok, tracks = pcall(function() return d:GetPlayingAnimationTracks() end)
                if tok then
                    for _, t in ipairs(tracks) do
                        local id = tostring(t.Animation.AnimationId)
                        if not found[id] then
                            found[id] = true
                            count = count + 1
                            write(count .. ". [Playing]    Id=" .. id)
                            updateStat("animations", count)
                        end
                    end
                end
            end
        end
    end
    write("")
    write(">>> Total animaciones únicas: " .. count)
    addLog("  🎭 " .. count .. " animaciones", Color3.fromRGB(255, 200, 100))
    return count
end

-- ── GUIs ──────────────────────────────────────────────────
local function collectGUIs()
    section("GUIs  (StarterGui / PlayerGui / CoreGui)")
    local count = 0

    local function scan(obj, depth)
        depth = depth or 0
        local pad = string.rep("  ", depth)
        local ok, ch = pcall(function() return obj:GetChildren() end)
        if not ok then return end
        for _, c in ipairs(ch) do
            if c ~= ScreenGui then
                count = count + 1
                write(pad .. "[" .. c.ClassName .. "] " .. c.Name)
                local props = {"Size","Position","Visible","Text","ZIndex","Enabled","BackgroundColor3"}
                for _, prop in ipairs(props) do
                    local pok, v = pcall(function() return c[prop] end)
                    if pok and v ~= nil then
                        write(pad .. "  ." .. prop .. " = " .. tostring(v))
                    end
                end
                scan(c, depth + 1)
                updateStat("guis", count)
            end
        end
    end

    local srcs = {
        { game:GetService("StarterGui"),      "StarterGui" },
        { game.Players.LocalPlayer.PlayerGui, "PlayerGui"  },
    }
    pcall(function() table.insert(srcs, { game:GetService("CoreGui"), "CoreGui" }) end)

    for _, pair in ipairs(srcs) do
        local svc, name = pair[1], pair[2]
        write("── " .. name .. " ──")
        pcall(scan, svc)
        write("")
    end

    write(">>> Total elementos GUI: " .. count)
    addLog("  🖥️ " .. count .. " elementos GUI", Color3.fromRGB(180, 140, 255))
    return count
end

-- ── REMOTES ───────────────────────────────────────────────
local function collectRemotes()
    section("REMOTES  (RemoteEvent / RemoteFunction / Bindable)")
    local count = 0
    local rtypes = {"RemoteEvent","RemoteFunction","BindableEvent",
                    "BindableFunction","UnreliableRemoteEvent"}

    local function scan(obj)
        local ok, desc = pcall(function() return obj:GetDescendants() end)
        if not ok then return end
        for _, d in ipairs(desc) do
            if table.find(rtypes, d.ClassName) then
                count = count + 1
                write(count .. ". [" .. d.ClassName .. "]  " .. getPath(d))
                updateStat("remotes", count)
            end
        end
    end

    pcall(scan, game:GetService("ReplicatedStorage"))
    pcall(scan, game:GetService("ReplicatedFirst"))
    pcall(scan, workspace)
    write("")
    write(">>> Total remotes: " .. count)
    addLog("  📡 " .. count .. " remotes", Color3.fromRGB(100, 200, 255))
    return count
end

-- ── SOUNDS ────────────────────────────────────────────────
local function collectSounds()
    section("SOUNDS")
    local count = 0
    local ok, desc = pcall(function() return game:GetDescendants() end)
    if ok then
        for _, d in ipairs(desc) do
            if d:IsA("Sound") then
                count = count + 1
                write(count .. ".  SoundId=" .. tostring(d.SoundId)
                    .. "  Vol=" .. tostring(d.Volume)
                    .. "  Nombre=" .. d.Name
                    .. "  Path=" .. getPath(d))
                updateStat("sounds", count)
            end
        end
    end
    write("")
    write(">>> Total sounds: " .. count)
    addLog("  🔊 " .. count .. " sounds", Color3.fromRGB(255, 160, 80))
    return count
end

-- ══════════════════════════════════════════════════════════
--  BOTÓN — ORQUESTADOR
-- ══════════════════════════════════════════════════════════
local running = false

StartBtn.MouseButton1Click:Connect(function()
    if running then return end
    running = true
    StartBtn.Text             = "⏳  Dumpeando..."
    StartBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)

    task.spawn(function()
        -- Encabezado del archivo
        write("╔" .. string.rep("═", 58) .. "╗")
        write("║        ROBLOX FULL GAME DUMP  v4.0" .. string.rep(" ", 22) .. "║")
        write("║        PlaceId: " .. tostring(game.PlaceId) .. string.rep(" ", 41 - #tostring(game.PlaceId)) .. "║")
        write("╚" .. string.rep("═", 58) .. "╝")

        addLog("▶ Iniciando — salida: " .. OUTPUT_FILE, Color3.fromRGB(255, 80, 80))
        addLog("─────────────────────────────")

        setProgress(0.05, "Metadata...")
        collectMeta()
        task.wait(0.05)

        setProgress(0.15, "Extrayendo scripts...")
        addLog("[ Scripts ]", Color3.fromRGB(200, 200, 255))
        collectScripts()
        task.wait(0.05)

        setProgress(0.35, "Workspace...")
        addLog("[ Workspace ]", Color3.fromRGB(200, 200, 255))
        collectWorkspace()
        task.wait(0.05)

        setProgress(0.50, "ReplicatedStorage...")
        addLog("[ ReplicatedStorage ]", Color3.fromRGB(200, 200, 255))
        collectReplicatedStorage()
        task.wait(0.05)

        setProgress(0.65, "Animaciones...")
        addLog("[ Animaciones ]", Color3.fromRGB(200, 200, 255))
        collectAnimations()
        task.wait(0.05)

        setProgress(0.75, "GUIs...")
        addLog("[ GUIs ]", Color3.fromRGB(200, 200, 255))
        collectGUIs()
        task.wait(0.05)

        setProgress(0.87, "Remotes...")
        addLog("[ Remotes ]", Color3.fromRGB(200, 200, 255))
        collectRemotes()
        task.wait(0.05)

        setProgress(0.95, "Sounds...")
        addLog("[ Sounds ]", Color3.fromRGB(200, 200, 255))
        collectSounds()
        task.wait(0.05)

        -- Pie del archivo
        section("RESUMEN FINAL")
        write("Scripts    : " .. tostring(results.scripts))
        write("Animaciones: " .. tostring(results.animations))
        write("Remotes    : " .. tostring(results.remotes))
        write("Sounds     : " .. tostring(results.sounds))
        write("GUIs       : " .. tostring(results.guis))
        write("")
        write("Archivo    : " .. OUTPUT_FILE)
        write("Fecha      : " .. os.date("%Y-%m-%d %H:%M:%S"))

        -- ✅ ESCRIBIR UN SOLO ARCHIVO
        flush()
        setProgress(1.0, "✅  Listo!  →  " .. OUTPUT_FILE)

        addLog("─────────────────────────────")
        addLog("✅  UN SOLO ARCHIVO GUARDADO", Color3.fromRGB(80, 255, 120))
        addLog("📄  " .. OUTPUT_FILE, Color3.fromRGB(200, 200, 80))
        addLog(("📜%d  🎭%d  📡%d  🔊%d  🖥️%d"):format(
            results.scripts, results.animations, results.remotes, results.sounds, results.guis),
            Color3.fromRGB(200, 200, 200))

        StartBtn.Text             = "✅  " .. OUTPUT_FILE
        StartBtn.BackgroundColor3 = Color3.fromRGB(30, 160, 80)

        TweenService:Create(Stroke, TweenInfo.new(0.4),
            { Color = Color3.fromRGB(80, 255, 120) }):Play()
        task.wait(1.5)
        TweenService:Create(Stroke, TweenInfo.new(0.4),
            { Color = Color3.fromRGB(200, 30, 30) }):Play()
        running = false
    end)
end)

-- ══════════════════════════════════════════════════════════
--  TOAST  — aparece arriba a la derecha al ejecutar
-- ══════════════════════════════════════════════════════════
local Toast              = Instance.new("Frame")
Toast.Name               = "Toast"
Toast.Size               = UDim2.new(0, 260, 0, 52)
Toast.Position           = UDim2.new(1, 10, 0, 20)
Toast.BackgroundColor3   = Color3.fromRGB(20, 20, 28)
Toast.BorderSizePixel    = 0
Toast.ZIndex             = 10
Toast.Parent             = ScreenGui
Instance.new("UICorner", Toast).CornerRadius = UDim.new(0, 8)

local ToastStroke        = Instance.new("UIStroke", Toast)
ToastStroke.Color        = Color3.fromRGB(80, 255, 120)
ToastStroke.Thickness    = 1.5

local ToastIcon          = Instance.new("TextLabel")
ToastIcon.Size           = UDim2.new(0, 40, 1, 0)
ToastIcon.BackgroundTransparency = 1
ToastIcon.Font           = Enum.Font.GothamBold
ToastIcon.Text           = "✅"
ToastIcon.TextSize       = 22
ToastIcon.TextColor3     = Color3.fromRGB(80, 255, 120)
ToastIcon.ZIndex         = 11
ToastIcon.Parent         = Toast

local ToastTitle         = Instance.new("TextLabel")
ToastTitle.Size          = UDim2.new(1, -48, 0, 22)
ToastTitle.Position      = UDim2.new(0, 44, 0, 6)
ToastTitle.BackgroundTransparency = 1
ToastTitle.Font          = Enum.Font.GothamBold
ToastTitle.Text          = "Script ejecutado"
ToastTitle.TextColor3    = Color3.fromRGB(255, 255, 255)
ToastTitle.TextSize      = 13
ToastTitle.TextXAlignment = Enum.TextXAlignment.Left
ToastTitle.ZIndex        = 11
ToastTitle.Parent        = Toast

local ToastSub           = Instance.new("TextLabel")
ToastSub.Size            = UDim2.new(1, -48, 0, 16)
ToastSub.Position        = UDim2.new(0, 44, 0, 28)
ToastSub.BackgroundTransparency = 1
ToastSub.Font            = Enum.Font.Gotham
ToastSub.Text            = "Game Dumper v4.0 · PlaceId " .. game.PlaceId
ToastSub.TextColor3      = Color3.fromRGB(120, 200, 140)
ToastSub.TextSize        = 10
ToastSub.TextXAlignment  = Enum.TextXAlignment.Left
ToastSub.ZIndex          = 11
ToastSub.Parent          = Toast

-- ══════════════════════════════════════════════════════════
--  SECUENCIA DE ARRANQUE
-- ══════════════════════════════════════════════════════════
task.spawn(function()

    -- ventana entra desde abajo con slide-in
    Main.Position               = UDim2.new(0.5, -170, 1, 20)
    Main.BackgroundTransparency = 1

    TweenService:Create(Main, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position               = UDim2.new(0.5, -170, 0.5, -210),
        BackgroundTransparency = 0,
    }):Play()
    task.wait(0.5)

    -- toast entra desde la derecha
    TweenService:Create(Toast, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -276, 0, 20),
    }):Play()
    task.wait(0.4)

    -- flash verde en borde principal
    TweenService:Create(Stroke, TweenInfo.new(0.3),
        { Color = Color3.fromRGB(80, 255, 120), Transparency = 0 }):Play()
    task.wait(0.4)
    TweenService:Create(Stroke, TweenInfo.new(0.5),
        { Color = Color3.fromRGB(200, 30, 30), Transparency = 0.3 }):Play()

    -- logs de bienvenida
    addLog("✅  Script cargado correctamente", Color3.fromRGB(80, 255, 120))
    addLog("📄  Salida → " .. OUTPUT_FILE, Color3.fromRGB(200, 200, 80))
    addLog("─────────────────────────────", Color3.fromRGB(60, 60, 80))
    addLog("Presioná ▶ para comenzar", Color3.fromRGB(150, 150, 160))

    -- toast desaparece a los 3s
    task.wait(3)
    TweenService:Create(Toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.new(1, 10, 0, 20),
    }):Play()
    task.wait(0.35)
    Toast:Destroy()
end)
