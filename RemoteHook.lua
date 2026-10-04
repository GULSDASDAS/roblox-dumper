--[[
    HOOK DE REMOTES - Monitor de tráfico en tiempo real
    Ejecuta este script ANTES del dump principal para capturar
    todos los RemoteEvents que se disparan durante la sesión.

    Úsalo para entender cómo el servidor procesa las acciones del cliente.
]]

local RemoteHook = {}
local log_data = {}
local folder = "GameDump_" .. game.PlaceId .. "/RemoteHooks"

-- Asegurar que la carpeta exista
pcall(makefolder, "GameDump_" .. game.PlaceId)
pcall(makefolder, folder)

-- ─── Hook RemoteEvent:FireServer ─────────────────────────────────────────────
local originalFireServer = game:GetService("ReplicatedStorage").RemoteEvent -- placeholder

-- Usamos hookfunction si el executor lo soporta (Synapse X, Wave)
local function hookAllRemotes()
    local function serialize(v)
        local t = type(v)
        if t == "string" then return '"' .. v .. '"'
        elseif t == "number" or t == "boolean" then return tostring(v)
        elseif t == "table" then
            local parts = {}
            for k, val in pairs(v) do
                table.insert(parts, tostring(k) .. "=" .. serialize(val))
            end
            return "{" .. table.concat(parts, ", ") .. "}"
        elseif t == "userdata" then
            local ok, str = pcall(tostring, v)
            return ok and str or "[userdata]"
        end
        return "[" .. t .. "]"
    end

    local function logFire(remote, method, ...)
        local args = {...}
        local serialized = {}
        for _, a in ipairs(args) do
            table.insert(serialized, serialize(a))
        end

        local entry = string.format("[%s] %s::%s(%s)",
            os.date("%H:%M:%S"),
            remote:GetFullName(),
            method,
            table.concat(serialized, ", ")
        )

        table.insert(log_data, entry)
        print("[HOOK] " .. entry)

        -- Guardar cada N llamadas
        if #log_data % 50 == 0 then
            writefile(folder .. "/remote_traffic.txt", table.concat(log_data, "\n"))
        end
    end

    -- Hook usando hookfunction (Synapse X / Wave)
    if type(hookfunction) == "function" then
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)

        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if self:IsA("RemoteEvent") or self:IsA("RemoteFunction") or self:IsA("UnreliableRemoteEvent") then
                if method == "FireServer" or method == "InvokeServer" then
                    logFire(self, method, ...)
                end
            end
            return oldNamecall(self, ...)
        end)

        setreadonly(mt, true)
        print("[HOOK] ✓ namecall hookeado con hookfunction")

    elseif type(getrawmetatable) == "function" then
        -- Alternativa sin hookfunction
        local mt = getrawmetatable(game)
        if mt then
            local oldNC = rawget(mt, "__namecall")
            if oldNC then
                local ok = pcall(function()
                    rawset(mt, "__namecall", function(self, ...)
                        local method = getnamecallmethod and getnamecallmethod() or ""
                        if self:IsA("RemoteEvent") or self:IsA("RemoteFunction") then
                            if method == "FireServer" or method == "InvokeServer" then
                                logFire(self, method, ...)
                            end
                        end
                        return oldNC(self, ...)
                    end)
                end)
                if ok then print("[HOOK] ✓ namecall hookeado (fallback)")
                else print("[HOOK] ✗ No se pudo hookear namecall") end
            end
        end
    else
        print("[HOOK] ✗ Executor no soporta hooks de metatable")
        print("[HOOK]   Recomendado: Synapse X o Wave")
    end
end

hookAllRemotes()

-- Guardar al salir / automáticamente cada 30s
task.spawn(function()
    while true do
        task.wait(30)
        if #log_data > 0 then
            writefile(folder .. "/remote_traffic.txt", table.concat(log_data, "\n"))
            print("[HOOK] Auto-guardado: " .. #log_data .. " entradas")
        end
    end
end)

print("[HOOK] Monitor de remotes activo. Jugá normalmente y los FireServer se registrarán.")
print("[HOOK] Salida: " .. folder .. "/remote_traffic.txt")
