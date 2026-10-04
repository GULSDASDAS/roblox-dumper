# 🔴 Roblox Full Game Dumper v2.0

Extrae **absolutamente todo** de cualquier juego de Roblox:
scripts, modelos, animaciones, GUIs, remotes, sounds y más.

---

## 📁 Estructura del proyecto

```
roblox-dumper/
├── GameDumper.lua      ← Script principal (ejecutar primero)
├── RemoteHook.lua      ← Monitor de tráfico de remotes en vivo
└── README.md           ← Este archivo
```

---

## ⚙️ Requisitos

Necesitás un **executor** con soporte para `writefile`, `makefolder` y opcionalmente `decompile`:

| Executor       | writefile | decompile | hookfunction | Recomendado |
|----------------|:---------:|:---------:|:------------:|:-----------:|
| **Synapse X**  | ✅        | ✅        | ✅           | ⭐⭐⭐      |
| **Wave**       | ✅        | ✅        | ✅           | ⭐⭐⭐      |
| **Script-Ware**| ✅        | ✅        | ✅           | ⭐⭐⭐      |
| **KRNL**       | ✅        | ⚠️ parcial | ✅          | ⭐⭐        |
| **Fluxus**     | ✅        | ❌        | ⚠️           | ⭐          |
| **Hydrogen**   | ✅        | ❌        | ✅           | ⭐⭐        |

---

## 🚀 Instrucciones de uso

### Dump completo
1. Abrí Roblox y unite al juego objetivo
2. Abrí tu executor e inyectalo
3. Pegá el contenido de `GameDumper.lua` y ejecutalo
4. Esperá el mensaje `DUMP COMPLETO ✓` en la consola
5. Los archivos estarán en `workspace/GameDump_{PlaceId}/` del executor

### Monitoreo de remotes (opcional, pero recomendado)
1. **Antes** de ejecutar el dump principal, ejecutá `RemoteHook.lua`
2. Jugá normalmente — todas las llamadas `FireServer` se registran
3. El log se guarda en `GameDump_{PlaceId}/RemoteHooks/remote_traffic.txt`

---

## 📦 Qué se extrae

### 📜 Scripts (`/Scripts/`)
- `Script`, `LocalScript`, `ModuleScript` de todo el DataModel
- Código fuente decompilado (si el executor lo soporta)
- Fallback a bytecode crudo si no hay decompilador
- Metadata: clase, path completo, método de obtención

### 🏗️ Workspace y Modelos (`/Workspace/`, `/ReplicatedStorage/`)
- Serialización XML del workspace completo (`.rbxmx`)
- Todos los modelos de `ReplicatedStorage`
- Propiedades: Position, Size, Color, Material, CFrame, etc.

### 🎭 Animaciones (`/Animations/`)
- IDs de todas las animaciones en el DataModel
- Tracks en reproducción (humanoids activos)
- Lista consolidada de IDs en `_animation_ids.txt`

### 🖥️ GUIs (`/GUIs/`)
- `StarterGui`, `PlayerGui`, `CoreGui`
- Serialización de cada `ScreenGui` y sus hijos

### 📡 Remotes (`/Remotes/`)
- Catálogo de todos los `RemoteEvent`, `RemoteFunction`,
  `BindableEvent`, `BindableFunction`, `UnreliableRemoteEvent`
- Path completo de cada remote para análisis

### 🔊 Sounds (`/Sounds/`)
- Catálogo de todos los objetos `Sound`
- SoundId, nombre, path y volumen

---

## 🔧 Configuración

Editá el bloque `CONFIG` al inicio de `GameDumper.lua`:

```lua
local CONFIG = {
    outputFolder     = "GameDump_" .. game.PlaceId,  -- carpeta de salida
    decompileScripts = true,   -- intentar decompilar código
    dumpWorkspace    = true,   -- volcar workspace
    dumpAnimations   = true,   -- extraer animaciones
    dumpGUIs         = true,   -- extraer interfaces
    dumpRemotes      = true,   -- catalogar remotes
    dumpSounds       = true,   -- catalogar sonidos
    verbose          = true,   -- mostrar logs en consola
}
```

---

## 📂 Estructura de salida

```
GameDump_{PlaceId}/
├── metadata.txt              ← Info del juego (PlaceId, GameId, etc.)
├── Scripts/
│   ├── Workspace__Script1.lua
│   ├── ReplicatedStorage__Module.module.lua
│   └── __executor__/         ← Scripts de getscripts()
├── Workspace/
│   └── workspace_dump.rbxmx
├── ReplicatedStorage/
│   └── (modelos organizados)
├── Animations/
│   ├── AnimName_1.txt
│   └── _animation_ids.txt    ← lista de IDs
├── GUIs/
│   ├── StarterGui_MainMenu.rbxmx
│   └── PlayerGui_HUD.rbxmx
├── Remotes/
│   └── remotes_catalog.txt
├── Sounds/
│   └── sounds_catalog.txt
└── RemoteHooks/
    └── remote_traffic.txt    ← (si usaste RemoteHook.lua)
```

---

## ⚠️ Notas

- Juegos con **FE (FilteringEnabled)** protegen el servidor — solo verás el lado cliente
- Juegos con **anti-cheat** (BedWars, Doors, etc.) pueden detectar el executor
- Los scripts del servidor (`Script`) no son accesibles desde el cliente — solo los `LocalScript` y `ModuleScript` del lado cliente
- Para decompilación completa, Synapse X o Wave dan los mejores resultados
